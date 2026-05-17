/**
 * Agent Logger Plugin for OpenCode
 *
 * Logs oh-my-opencode-slim agent activations to console.
 * Hybrid detection: message.role + subagent tool parsing.
 *
 * Stored in ai-toolbox, symlinked via stow to ~/.config/opencode/plugins/
 */

const KNOWN_AGENTS = [
  'orchestrator',
  'oracle',
  'council',
  'librarian',
  'explorer',
  'designer',
  'fixer',
  'observer',
];

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
     * Primary detection: check message.role for known agent names
     */
    'message.updated': async (input) => {
      const role = input?.message?.role?.toLowerCase?.();
      if (role && KNOWN_AGENTS.includes(role)) {
        console.log(
          `\x1b[36m[AGENT]\x1b[0m \x1b[1m${role.toUpperCase()}\x1b[0m activated`,
        );
      }
    },

    /**
     * Fallback detection: parse subagent/agent tool invocations
     */
    'tool.execute.before': async (input) => {
      const tool = input?.tool;
      if (tool !== 'subagent' && tool !== 'agent') return;

      const args = input?.args || input?.input || {};
      const name =
        args?.agent?.toLowerCase?.() ||
        args?.name?.toLowerCase?.() ||
        args?.agentName?.toLowerCase?.();

      if (name && KNOWN_AGENTS.includes(name)) {
        console.log(
          `\x1b[36m[AGENT]\x1b[0m \x1b[1m${name.toUpperCase()}\x1b[0m activated (via ${tool})`,
        );
      }
    },
  };
};
