import execa from 'execa';
import { type Spinner } from '../lib/spinner.js';
export declare const getCommandName: (command: string) => string;
export declare const canReportMissingCommandName: (command: string) => boolean;
export declare const shouldUseShell: (command: string) => boolean;
/**
 * Registers a cleanup function to run before the process exits. The process
 * will call `process.exit()` after all registered cleanup functions complete.
 */
export declare const runBeforeProcessExit: (fn: () => Promise<void>) => void;
export declare const runCommand: (command: string, options: {
    spinner?: Spinner;
    env?: NodeJS.ProcessEnv;
    cwd: string;
}) => execa.ExecaChildProcess<string>;
export declare const isNonExistingCommandError: ({ command, error: commandError }: {
    command: string;
    error: unknown;
}) => boolean;
//# sourceMappingURL=shell.d.ts.map