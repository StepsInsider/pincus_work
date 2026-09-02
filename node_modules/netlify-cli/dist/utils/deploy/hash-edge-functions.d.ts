import type { StatusCallback } from './status-cb.js';
import type { EdgeFunctionUploadFile } from './upload-files.js';
declare const hashEdgeFunctions: (edgeFunctionsDistPath: string | undefined, { hashAlgorithm, statusCb }: {
    hashAlgorithm?: string;
    statusCb: StatusCallback;
}) => Promise<{
    edgeFunctions: Record<string, string>;
    edgeFnShaMap: Record<string, EdgeFunctionUploadFile[]>;
}>;
export default hashEdgeFunctions;
//# sourceMappingURL=hash-edge-functions.d.ts.map