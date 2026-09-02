export interface DeployEnvironmentVariable {
    key: string;
    value: string;
    is_secret: boolean;
    scopes: ['functions'];
}
export type DeployEnvVarFlag = '--env' | '--secret-env';
/**
 * Builds a Commander argument parser that accumulates `KEY=VALUE` arguments into a list of
 * deploy-scoped environment variables. This lets the flag be repeated.
 *
 * Throws `InvalidArgumentError` if the argument is not in `KEY=VALUE` format, or if the key would
 * be rejected by Envelope.
 */
export declare const parseDeployEnvVar: (flag: DeployEnvVarFlag) => (arg: string, previous?: DeployEnvironmentVariable[]) => DeployEnvironmentVariable[];
/**
 * Combines the variables collected by `--env` and `--secret-env` into the single list the API
 * expects.
 */
export declare const mergeDeployEnvVars: (env?: DeployEnvironmentVariable[], secretEnv?: DeployEnvironmentVariable[]) => DeployEnvironmentVariable[];
/**
 * Returns the first key that appears more than once, or `undefined` if all keys are unique.
 *
 * The API rejects duplicate keys, and a single flag's parser cannot see the other flag's values,
 * so callers must check the merged list.
 */
export declare const findDuplicateKey: (variables: DeployEnvironmentVariable[]) => string | undefined;
//# sourceMappingURL=deploy-env-vars.d.ts.map