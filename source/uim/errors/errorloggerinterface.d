/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.errors;

use Psr\Http\messages.IServerRequest;
use Throwable;

/**
 * Interface for error logging handlers.
 *
 * Used by the ErrorHandlerMiddleware and global
 * error handlers to log exceptions and errors.
 *
 * @method void logException(\Throwable $exception, ?\Psr\Http\messages.IServerRequest $request = null, bool $includeTrace = false)
 *   Log an exception with an optional HTTP request.
 * @method void logError(uim.errorss.DERRError $error, ?\Psr\Http\messages.IServerRequest $request = null, bool $includeTrace = false)
 *   Log an error with an optional HTTP request.
 */
interface ErrorLoggerInterface
{
    /**
     * Log an error for an exception with optional request context.
     *
     * @param \Throwable $exception The exception to log a message for.
     * @param \Psr\Http\messages.IServerRequest|null $request The current request if available.
     * @return bool
     * @deprecated 4.4.0 Implement `logException` instead.
     */
    bool log(
        Throwable $exception,
        ?IServerRequest $request = null
    );

    /**
     * Log a an error message to the error logger.
     *
     * @param string|int $level The logging level
     * @param string $message The message to be logged.
     * @param array $context Context.
     * @return bool
     * @deprecated 4.4.0 Implement `logError` instead.
     */
    bool logMessage($level, string $message, array $context = null);
}
