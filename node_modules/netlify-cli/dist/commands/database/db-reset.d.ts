import BaseCommand from '../base-command.js';
export interface ResetOptions {
    force?: boolean;
    json?: boolean;
}
export declare const reset: (options: ResetOptions, command: BaseCommand) => Promise<void>;
//# sourceMappingURL=db-reset.d.ts.map