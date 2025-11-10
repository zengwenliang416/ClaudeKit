#!/usr/bin/env node
import { readFileSync, existsSync } from 'fs';
import { join, resolve } from 'path';
import { homedir } from 'os';

interface HookInput {
    session_id: string;
    transcript_path: string;
    cwd: string;
    permission_mode: string;
    prompt: string;
}

interface PromptTriggers {
    keywords?: string[];
    intentPatterns?: string[];
}

interface SkillRule {
    type: 'guardrail' | 'domain';
    enforcement: 'block' | 'suggest' | 'warn';
    priority: 'critical' | 'high' | 'medium' | 'low';
    promptTriggers?: PromptTriggers;
}

interface SkillRules {
    version: string;
    skills: Record<string, SkillRule>;
}

interface MatchedSkill {
    name: string;
    matchType: 'keyword' | 'intent';
    config: SkillRule;
}

// Utility function to normalize and tokenize prompt for better matching
function normalizePrompt(prompt: string): string {
    return prompt
        .toLowerCase()
        .trim()
        // Normalize whitespace
        .replace(/\s+/g, ' ')
        // Remove common punctuation that might interfere with matching
        .replace(/[?!。？！]/g, '');
}

// Check if keyword matches with flexible matching
function keywordMatches(prompt: string, keyword: string): boolean {
    const normalizedPrompt = normalizePrompt(prompt);
    const normalizedKeyword = keyword.toLowerCase().trim();

    // Exact substring match
    if (normalizedPrompt.includes(normalizedKeyword)) {
        return true;
    }

    // Word boundary match for multi-word keywords
    const words = normalizedKeyword.split(/\s+/);
    if (words.length > 1) {
        // All words must appear in prompt (not necessarily consecutively)
        return words.every(word => normalizedPrompt.includes(word));
    }

    return false;
}

async function main() {
    try {
        // Read input from stdin
        const input = readFileSync(0, 'utf-8');
        const data: HookInput = JSON.parse(input);
        const prompt = data.prompt;

        // Determine project directory with proper fallbacks
        let projectDir = process.env.CLAUDE_PROJECT_DIR;

        if (!projectDir) {
            // Fallback 1: Try to detect from script location
            // Script is at PROJECT/.claude/hooks/skill-activation-prompt.ts
            const scriptDir = __dirname;
            if (scriptDir.includes('.claude/hooks')) {
                projectDir = resolve(scriptDir, '../..');
            } else {
                // Fallback 2: Use cwd from hook input
                projectDir = data.cwd;
            }
        }

        // Validate project directory
        if (!projectDir || !existsSync(projectDir)) {
            console.error(`[skill-activation-prompt] Invalid project directory: ${projectDir}`);
            process.exit(1);
        }

        // Load skill rules with validation
        const rulesPath = join(projectDir, '.claude', 'skills', 'skill-rules.json');

        if (!existsSync(rulesPath)) {
            console.error(`[skill-activation-prompt] skill-rules.json not found at: ${rulesPath}`);
            process.exit(1);
        }

        const rulesContent = readFileSync(rulesPath, 'utf-8');
        const rules: SkillRules = JSON.parse(rulesContent);

        const matchedSkills: MatchedSkill[] = [];

        // Check each skill for matches
        for (const [skillName, config] of Object.entries(rules.skills)) {
            const triggers = config.promptTriggers;
            if (!triggers) {
                continue;
            }

            let matched = false;

            // Keyword matching with improved flexibility
            if (triggers.keywords && !matched) {
                const keywordMatch = triggers.keywords.some(kw => keywordMatches(prompt, kw));
                if (keywordMatch) {
                    matchedSkills.push({ name: skillName, matchType: 'keyword', config });
                    matched = true;
                }
            }

            // Intent pattern matching (only if not already matched by keyword)
            if (triggers.intentPatterns && !matched) {
                const intentMatch = triggers.intentPatterns.some(pattern => {
                    try {
                        const regex = new RegExp(pattern, 'i');
                        return regex.test(prompt);
                    } catch (e) {
                        console.error(`[skill-activation-prompt] Invalid regex pattern "${pattern}" in skill "${skillName}":`, e);
                        return false;
                    }
                });
                if (intentMatch) {
                    matchedSkills.push({ name: skillName, matchType: 'intent', config });
                    matched = true;
                }
            }
        }

        // Generate output if matches found
        if (matchedSkills.length > 0) {
            let output = '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
            output += '🎯 SKILL ACTIVATION CHECK\n';
            output += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n';

            // Group by priority
            const critical = matchedSkills.filter(s => s.config.priority === 'critical');
            const high = matchedSkills.filter(s => s.config.priority === 'high');
            const medium = matchedSkills.filter(s => s.config.priority === 'medium');
            const low = matchedSkills.filter(s => s.config.priority === 'low');

            if (critical.length > 0) {
                output += '⚠️ CRITICAL SKILLS (REQUIRED):\n';
                critical.forEach(s => output += `  → ${s.name}\n`);
                output += '\n';
            }

            if (high.length > 0) {
                output += '📚 RECOMMENDED SKILLS:\n';
                high.forEach(s => output += `  → ${s.name}\n`);
                output += '\n';
            }

            if (medium.length > 0) {
                output += '💡 SUGGESTED SKILLS:\n';
                medium.forEach(s => output += `  → ${s.name}\n`);
                output += '\n';
            }

            if (low.length > 0) {
                output += '📌 OPTIONAL SKILLS:\n';
                low.forEach(s => output += `  → ${s.name}\n`);
                output += '\n';
            }

            output += 'ACTION: Use Skill tool BEFORE responding\n';
            output += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';

            console.log(output);
        }

        process.exit(0);
    } catch (err) {
        // Log error details for debugging
        console.error('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.error('❌ HOOK ERROR: skill-activation-prompt');
        console.error('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.error('Error:', err instanceof Error ? err.message : String(err));

        if (err instanceof Error && err.stack) {
            console.error('Stack:', err.stack);
        }

        console.error('Environment:');
        console.error('  CLAUDE_PROJECT_DIR:', process.env.CLAUDE_PROJECT_DIR || '(not set)');
        console.error('  __dirname:', __dirname);
        console.error('  cwd:', process.cwd());
        console.error('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // Exit with success to not block Claude
        // Hook failures should be visible but not blocking
        process.exit(0);
    }
}

main().catch(err => {
    console.error('Uncaught error in skill-activation-prompt:', err);
    // Exit with success to not block Claude
    process.exit(0);
});
