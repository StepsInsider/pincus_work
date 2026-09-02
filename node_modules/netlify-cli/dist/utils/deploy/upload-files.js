import fs from 'fs';
import backoff from 'backoff';
import pMap from 'p-map';
import { UPLOAD_INITIAL_DELAY, UPLOAD_MAX_DELAY, UPLOAD_RANDOM_FACTOR } from './constants.js';
class MissingAssetTypeError extends Error {
    fileObj;
    constructor(fileObj) {
        super('File Object missing assetType property');
        this.fileObj = fileObj;
    }
}
const uploadFiles = async (api, deployId, uploadList, { concurrentUpload, maxRetry, statusCb }) => {
    if (!concurrentUpload || !maxRetry)
        throw new Error('Missing required option concurrentUpload');
    statusCb({
        type: 'upload',
        msg: `Uploading ${uploadList.length} files`,
        phase: 'start',
    });
    const uploadFile = async (fileObj, index) => {
        const { body, filepath, normalizedPath } = fileObj;
        const readStreamCtor = () => body ?? fs.createReadStream(filepath);
        statusCb({
            type: 'upload',
            msg: `(${index}/${uploadList.length}) Uploading ${normalizedPath}...`,
            phase: 'progress',
        });
        switch (fileObj.assetType) {
            case 'file': {
                return await retryUpload(() => api.uploadDeployFile({
                    body: readStreamCtor,
                    deployId,
                    path: encodeURI(normalizedPath),
                }), maxRetry);
            }
            case 'function': {
                const { invocationMode, runtime, timeout } = fileObj;
                return await retryUpload((retryCount) => {
                    const params = {
                        body: readStreamCtor,
                        deployId,
                        invocationMode,
                        timeout,
                        name: encodeURI(normalizedPath),
                        runtime,
                    };
                    if (retryCount > 0) {
                        params.xNfRetryCount = retryCount;
                    }
                    return api.uploadDeployFunction(params);
                }, maxRetry);
            }
            case 'edge-function': {
                return await retryUpload((retryCount) => {
                    const params = {
                        body: readStreamCtor,
                        deployId,
                        codeSha: normalizedPath,
                    };
                    if (retryCount > 0) {
                        params.xNfRetryCount = retryCount;
                    }
                    return api.uploadDeployEdgeFunction(params);
                }, maxRetry);
            }
            default: {
                throw new MissingAssetTypeError(fileObj);
            }
        }
    };
    const results = await pMap(uploadList, uploadFile, { concurrency: concurrentUpload });
    statusCb({
        type: 'upload',
        msg: `Finished uploading ${uploadList.length} assets`,
        phase: 'stop',
    });
    return results;
};
const getErrorStatus = (error) => typeof error === 'object' && error !== null && 'status' in error && typeof error.status === 'number'
    ? error.status
    : undefined;
const retryUpload = (uploadFn, maxRetry) => new Promise((resolve, reject) => {
    let lastError;
    const fibonacciBackoff = backoff.fibonacci({
        randomisationFactor: UPLOAD_RANDOM_FACTOR,
        initialDelay: UPLOAD_INITIAL_DELAY,
        maxDelay: UPLOAD_MAX_DELAY,
    });
    const tryUpload = async (retryIndex = -1) => {
        try {
            const results = await uploadFn(retryIndex + 1);
            resolve(results);
            return;
        }
        catch (error) {
            lastError = error;
            const status = getErrorStatus(error);
            // We don't need to retry for 400 or 422 errors
            if (status === 400 || status === 422) {
                reject(error);
                return;
            }
            // observed errors: 408, 401 (4** swallowed), 502
            if ((status !== undefined && status > 400) || (error instanceof Error && error.name === 'FetchError')) {
                fibonacciBackoff.backoff();
                return;
            }
            reject(error);
            return;
        }
    };
    fibonacciBackoff.failAfter(maxRetry);
    fibonacciBackoff.on('backoff', () => {
        // Do something when backoff starts, e.g. show to the
        // user the delay before next reconnection attempt.
    });
    // eslint-disable-next-line @typescript-eslint/no-misused-promises
    fibonacciBackoff.on('ready', tryUpload);
    fibonacciBackoff.on('fail', () => {
        reject(lastError);
    });
    tryUpload();
});
export default uploadFiles;
//# sourceMappingURL=upload-files.js.map