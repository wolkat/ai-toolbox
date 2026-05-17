/**
 * Agent Logger Plugin for OpenCode
 *
 * Logs agent and subagent activations to console.
 * Works with any agent system: oh-my-opencode-slim, OpenCode built-ins,
 * custom agents, or any model that sets message.role or uses subagent tools.
 *
 * Stored in ai-toolbox, symlinked to ~/.config/opencode/plugins/
 */

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
      console.log(
        `\x1b[90m[agent-logger] Session ${input?.sessionID?.slice(0, 8) ?? 'unknown'} created\x1b[0m`,
      );
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
      console.log(
        `${color}${tag}\x1b[0m \x1b[1m${role.toUpperCase()}\x1b[0m activated`,
      );
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
      console.log(
        `${color}${tag}\x1b[0m \x1b[1m${name.toUpperCase()}\x1b[0m activated (via ${tool})`,
      );
    },
  };
};
