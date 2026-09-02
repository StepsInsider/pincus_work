import type { OptionValues } from 'commander';
import type BaseCommand from '../base-command.js';
export declare const STATUS_ERROR_CODES: {
    readonly NOT_LOGGED_IN: 'NOT_LOGGED_IN';
    readonly NOT_LINKED: 'NOT_LINKED';
};
export declare const status: (options: OptionValues, command: BaseCommand) => Promise<undefined>;
//# sourceMappingURL=status.d.ts.map