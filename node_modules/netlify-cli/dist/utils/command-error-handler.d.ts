import { CommanderError, type HelpContext } from 'commander';
/** Every Commander error code caused by bad user input; these exit with `EXIT_CODES.USAGE_ERROR` */
export declare const USAGE_ERROR_CODES: Set<string>;
export declare const isOptionError: (error: CommanderError) => boolean;
export declare const handleOptionError: (command: {
    outputHelp: (context?: HelpContext) => void;
}) => void;
//# sourceMappingURL=command-error-handler.d.ts.map