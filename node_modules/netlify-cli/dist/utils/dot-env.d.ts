import dotenv from 'dotenv';
export declare const loadDotEnvFiles: ({ envFiles, projectDir }: {
    envFiles: any;
    projectDir: any;
}) => Promise<({
    warning: string;
    file?: undefined;
    env?: undefined;
} | {
    warning?: undefined;
    file: string;
    env: dotenv.DotenvParseOutput;
} | undefined)[]>;
export declare const tryLoadDotEnvFiles: ({ dotenvFiles, projectDir }: {
    dotenvFiles?: string[] | undefined;
    projectDir: any;
}) => Promise<({
    warning: string;
    file?: undefined;
    env?: undefined;
} | {
    warning?: undefined;
    file: string;
    env: dotenv.DotenvParseOutput;
} | undefined)[]>;
//# sourceMappingURL=dot-env.d.ts.map