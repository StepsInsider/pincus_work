export const getDeploySourceFields = () => {
    const agentRunnerId = process.env.NETLIFY_AGENT_RUNNER_ID;
    const agentRunnerSessionId = process.env.NETLIFY_AGENT_RUNNER_SESSION_ID;
    return {
        deploy_source: process.env.NETLIFY_DEPLOY_SOURCE || 'cli',
        ...(agentRunnerId ? { agent_runner_id: agentRunnerId } : {}),
        ...(agentRunnerSessionId ? { agent_runner_session_id: agentRunnerSessionId } : {}),
    };
};
//# sourceMappingURL=deploy-source.js.map