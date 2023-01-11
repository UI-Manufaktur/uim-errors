module uim.cake.Error;

import uim.cake.core.exceptions.UIMException;
use Throwable;

/**
 * Represents a fatal error
 */
class FatalErrorException : UIMException {
    /**
     * Constructor
     *
     * @param string $message Message string.
     * @param int|null $code Code.
     * @param string|null $file File name.
     * @param int|null $line Line number.
     * @param \Throwable|null $previous The previous exception.
     */
    this(
        string $message,
        Nullable!int $code = null,
        Nullable!string $file = null,
        Nullable!int $line = null,
        ?Throwable $previous = null
    ) {
        super(($message, $code, $previous);
        if ($file) {
            this.file = $file;
        }
        if ($line) {
            this.line = $line;
        }
    }
}
