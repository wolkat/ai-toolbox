/**
 * Agent Logger Plugin for OpenCode
 *
 * Logs agent and subagent activations to console.
 * Works with any agent system: oh-my-opencode-slim, OpenCode built-ins,
 * custom agents, or any model that sets message.role or uses subagent tools.
 *
 * Stored in ai-toolbox, symlinked to ~/.config/opencode/plugins/
 */

import { appendFileSync } from 'node:fs';

const LOG_FILE = '/Users/katops/.local/share/opencode/agent-logger.log';

function logToFile(line) {
  try {
    appendFileSync(LOG_FILE, `${new Date().toISOString()} ${line}\n`);
  } catch {}
}

const KNOWN_AGENTS = new Set([
  'orchestrator',
  'oracle',
  'council',
  'librarian',
  'explorer',
  'designer',
  'fixer',
  'observer',
  'review',
  'refactor',
]);

const SYSTEM_ROLES = new Set(['user', 'assistant', 'system', 'tool']);

function getAgentColor(name) {
  if (KNOWN_AGENTS.has(name)) return '\x1b[36m'; // cyan for known agents
  return '\x1b[33m'; // yellow for unknown/discovery
}

export default async () => {
  return {
    /**
     * Log session creation (debug level)
     */
    'session.created': async (input) => {
      const line = `[agent-logger] Session ${input?.sessionID?.slice(0, 8) ?? 'unknown'} created`;
      console.log(`\x1b[90m${line}\x1b[0m`);
      logToFile(line);
    },

    /**
     * Log any non-system message role as an agent activation.
     * Catches: oh-my-opencode-slim agents, custom agents, built-in subagents.
     */
    'message.updated': async (input) => {
      const role = input?.message?.role?.toLowerCase?.();
      if (!role || SYSTEM_ROLES.has(role)) return;

      const color = getAgentColor(role);
      const tag = KNOWN_AGENTS.has(role) ? '[AGENT]' : '[AGENT?]';
      const line = `${tag} ${role.toUpperCase()} activated (message.updated)`;
      console.log(`${color}${line}\x1b[0m`);
      logToFile(line);
    },

    /**
     * Log all subagent/agent tool invocations regardless of name.
     * Useful for discovering new agents and debugging delegation.
     */
    'tool.execute.before': async (input) => {
      const tool = input?.tool;
      if (tool !== 'subagent' && tool !== 'agent') return;

      const args = input?.args || input?.input || {};
      const name =
        args?.agent?.toLowerCase?.() ||
        args?.name?.toLowerCase?.() ||
        args?.agentName?.toLowerCase?.() ||
        'unknown';

      const color = getAgentColor(name);
      const tag = KNOWN_AGENTS.has(name) ? '[AGENT]' : '[AGENT?]';
      const line = `${tag} ${name.toUpperCase()} activated (via ${tool})`;
      console.log(`${color}${line}\x1b[0m`);
      logToFile(line);
    },
  };
};
