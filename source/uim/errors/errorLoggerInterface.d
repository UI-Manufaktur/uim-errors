/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.errors.errorlogger;

@safe:
import uim.errors;

/* use Psr\Http\messages.IServerRequest;
use Throwable;  */

/**
 * Interface for error logging handlers.
 *
 * Used by the ErrorHandlerMiddleware and global
 * error handlers to log exceptions and errors.
 */
interface IErrorLogger
{
    /**
     * Log an error for an exception with optional request context.
     *
     * @param \Throwable myException The exception to log a message for.
     * @param \Psr\Http\messages.IServerRequest|null myRequest The current request if available.
     */
    bool log(
        Throwable myException,
        ?IServerRequest myRequest = null
    );

    /**
     * Log a an error message to the error logger.
     *
     * @param string|int $level The logging level
     * @param string myMessage The message to be logged.
     * @param array $context Context.
     */
    bool logMessage($level, string myMessage, array $context = null);
}
