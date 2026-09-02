import type { FieldDef, QueryResult } from 'pg';
type StatementResult = QueryResult<Record<string, unknown>>;
export declare const formatQueryResult: (fields: FieldDef[], rows: Record<string, unknown>[], rowCount: number | null, command: string) => string;
export declare const formatStatementResults: (result: StatementResult | StatementResult[]) => string;
export declare const lastRowSet: (result: StatementResult | StatementResult[]) => Record<string, unknown>[];
export {};
//# sourceMappingURL=psql-formatter.d.ts.map