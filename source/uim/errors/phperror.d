/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.errors.Error;

@safe:
import uim.errors;

/**
 * Object wrapper around PHP errors that are emitted by `trigger_error()`
 */
class PhpError
{
    /**
     * @var int
     */
    private $code;

    /**
     * @var string
     */
    private $message;

    /**
     * @var string|null
     */
    private $file;

    /**
     * @var int|null
     */
    private $line;

    /**
     * Stack trace data. Each item should have a `reference`, `file` and `line` keys.
     *
     * @var array<array<string, int>>
     */
    private $trace;

    /**
     * @var array<int, string>
     */
    private $levelMap = [
        E_PARSE: "error",
        E_ERROR: "error",
        E_CORE_ERROR: "error",
        E_COMPILE_ERROR: "error",
        E_USER_ERROR: "error",
        E_WARNING: "warning",
        E_USER_WARNING: "warning",
        E_COMPILE_WARNING: "warning",
        E_RECOVERABLE_ERROR: "warning",
        E_NOTICE: "notice",
        E_USER_NOTICE: "notice",
        E_STRICT: "strict",
        E_DEPRECATED: "deprecated",
        E_USER_DEPRECATED: "deprecated",
    ];

    /**
     * @var array<string, int>
     */
    private $logMap = [
        "error": LOG_ERR,
        "warning": LOG_WARNING,
        "notice": LOG_NOTICE,
        "strict": LOG_NOTICE,
        "deprecated": LOG_NOTICE,
    ];

    /**
     * Constructor
     *
     * @param int $code The PHP error code constant
     * @param string $message The error message.
     * @param string|null $file The filename of the error.
     * @param int|null $line The line number for the error.
     * @param array $trace The backtrace for the error.
     */
    this(
        int $code,
        string $message,
        Nullable!string $file = null,
        Nullable!int $line = null,
        array $trace = null
    ) {
        this.code = $code;
        this.message = $message;
        this.file = $file;
        this.line = $line;
        this.trace = $trace;
    }

    /**
     * Get the PHP error constant.
     */
    int getCode() {
        return this.code;
    }

    /**
     * Get the mapped LOG_ constant.
     */
    int getLogLevel() {
        $label = this.getLabel();

        return this.logMap[$label] ?? LOG_ERR;
    }

    /**
     * Get the error code label
     */
    string getLabel() {
        return this.levelMap[this.code] ?? "error";
    }

    /**
     * Get the error message.
     */
    string getMessage() {
        return this.message;
    }

    /**
     * Get the error file
     *
     */
    Nullable!string getFile() {
        return this.file;
    }

    /**
     * Get the error line number.
     *
     */
    Nullable!int getLine() {
        return this.line;
    }

    /**
     * Get the stacktrace as an array.
     */
    array getTrace() {
        return this.trace;
    }

    /**
     * Get the stacktrace as a string.
     */
    string getTraceAsString() {
        $out = null;
        foreach (this.trace as $frame) {
            $out[] = "{$frame["reference"]} {$frame["file"]}, line {$frame["line"]}";
        }

        return implode("\n", $out);
    }
}
