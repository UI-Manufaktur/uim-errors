vuim.cake.Error;

import uim.cake.core.InstanceConfigTrait;
import uim.cake.errors.rendererss.ConsoleExceptionRenderer;
import uim.cake.events.EventDispatcherTrait;
import uim.cake.routings.Router;
use InvalidArgumentException;
use Psr\Http\messages.IServerRequest;
use Throwable;

/**
 * Entry point to UIM"s exception handling.
 *
 * Using the `register()` method you can attach an ExceptionTrap to PHP"s default exception handler and register
 * a shutdown handler to handle fatal errors.
 *
 * When exceptions are trapped the `Exception.beforeRender` event is triggered.
 * Then exceptions are logged (if enabled) and finally "rendered" using the defined renderer.
 *
 * Stopping the `Exception.beforeRender` event has no effect, as we always need to render
 * a response to an exception and custom renderers should be used if you want to replace or
 * skip rendering an exception.
 *
 * If undefined, an ExceptionRenderer will be selected based on the current SAPI (CLI or Web).
 */
class ExceptionTrap
{
    use EventDispatcherTrait;
    use InstanceConfigTrait;

    /**
     * Configuration options. Generally these will be defined in your config/app.php
     *
     * - `exceptionRenderer` - string - The class responsible for rendering uncaught exceptions.
     *   The chosen class will be used for for both CLI and web environments. If  you want different
     *   classes used in CLI and web environments you"ll need to write that conditional logic as well.
     *   The conventional location for custom renderers is in `src/Error`. Your exception renderer needs to
     *   implement the `render()` method and return either a string or Http\Response.
     * - `log` Set to false to disable logging.
     * - `logger` - string - The class name of the error logger to use.
     * - `trace` - boolean - Whether or not backtraces should be included in
     *   logged exceptions.
     * - `skipLog` - array - List of exceptions to skip for logging. Exceptions that
     *   extend one of the listed exceptions will also not be logged. E.g.:
     *   ```
     *   "skipLog": ["Cake\Http\exceptions.NotFoundException", "Cake\Http\exceptions.UnauthorizedException"]
     *   ```
     *   This option is forwarded to the configured `logger`
     * - `extraFatalErrorMemory` - int - The number of megabytes to increase the memory limit by when a fatal error is
     *   encountered. This allows breathing room to complete logging or error handling.
     * - `stderr` Used in console environments so that renderers have access to the current console output stream.
     *
     * @var array<string, mixed>
     */
    protected _defaultConfig = [
        "exceptionRenderer": null,
        "logger": ErrorLogger::class,
        "stderr": null,
        "log": true,
        "skipLog": [],
        "trace": false,
        "extraFatalErrorMemory": 4,
    ];

    /**
     * A list of handling callbacks.
     *
     * Callbacks are invoked for each error that is handled.
     * Callbacks are invoked in the order they are attached.
     *
     * @var array<\Closure>
     */
    protected $callbacks = null;

    /**
     * The currently registered global exception handler
     *
     * This is best effort as we can"t know if/when another
     * exception handler is registered.
     *
     * var DERRExceptionTrap|null
     */
    protected static $registeredTrap = null;

    /**
     * Track if this trap was removed from the global handler.
     */
    protected bool $disabled = false;

    /**
     * Constructor
     *
     * @param array<string, mixed> $options An options array. See _defaultConfig.
     */
    this(STRINGAA someOptions = null) {
        this.setConfig($options);
    }

    /**
     * Get an instance of the renderer.
     *
     * @param \Throwable $exception Exception to render
     * @param \Psr\Http\messages.IServerRequest|null $request The request if possible.
     * @return uim.cake.errors.ExceptionRendererInterface
     */
    function renderer(Throwable $exception, $request = null) {
        $request = $request ?? Router::getRequest();

        /** @var class-string|callable $class */
        $class = this.getConfig("exceptionRenderer");
        $deprecatedConfig = ($class == ExceptionRenderer::class && PHP_SAPI == "cli");
        if ($deprecatedConfig) {
            deprecationWarning(
                "Your application is using a deprecated `Error.exceptionRenderer`~ " ~
                "You can either remove the `Error.exceptionRenderer` config key to have UIM choose " ~
                "one of the default exception renderers, or define a class that is not `Cake\errors.ExceptionRenderer`."
            );
        }
        if (!$class || $deprecatedConfig) {
            // Default to detecting the exception renderer if we"re
            // in a CLI context and the Web renderer is currently selected.
            // This indicates old configuration or user error, in both scenarios
            // it is preferrable to use the Console renderer instead.
            $class = this.chooseRenderer();
        }

        if (is_string($class)) {
            /** @psalm-suppress ArgumentTypeCoercion */
            if (!(method_exists($class, "render") && method_exists($class, "write"))) {
                throw new InvalidArgumentException(
                    "Cannot use {$class} as an `exceptionRenderer`~ " ~
                    "It must implement render() and write() methods."
                );
            }

            /** @var class-string<uim.cake.errors.ExceptionRendererInterface> $class */
            return new $class($exception, $request, _config);
        }

        return $class($exception, $request);
    }

    /**
     * Choose an exception renderer based on config or the SAPI
     *
     * @return class-string<uim.cake.errors.ExceptionRendererInterface>
     */
    protected string chooseRenderer() {
        /** @var class-string<uim.cake.errors.ExceptionRendererInterface> */
        return PHP_SAPI == "cli" ? ConsoleExceptionRenderer::class : ExceptionRenderer::class;
    }

    /**
     * Get an instance of the logger.
     *
     * @return uim.cake.errors.ErrorLoggerInterface
     */
    function logger(): ErrorLoggerInterface
    {
        /** @var class-string<uim.cake.errors.ErrorLoggerInterface> $class */
        $class = this.getConfig("logger", _defaultConfig["logger"]);

        return new $class(_config);
    }

    /**
     * Attach this ExceptionTrap to PHP"s default exception handler.
     *
     * This will replace the existing exception handler, and the
     * previous exception handler will be discarded.
     */
    void register() {
        set_exception_handler([this, "handleException"]);
        register_shutdown_function([this, "handleShutdown"]);
        static::$registeredTrap = this;
    }

    /**
     * Remove this instance from the singleton
     *
     * If this instance is not currently the registered singleton
     * nothing happens.
     */
    void unregister() {
        if (static::$registeredTrap == this) {
            this.disabled = true;
            static::$registeredTrap = null;
        }
    }

    /**
     * Get the registered global instance if set.
     *
     * Keep in mind that the global state contained here
     * is mutable and the object returned by this method
     * could be a stale value.
     *
     * @return uim.cake.errors.ExceptionTrap|null The global instance or null.
     */
    static function instance(): ?self
    {
        return static::$registeredTrap;
    }

    /**
     * Handle uncaught exceptions.
     *
     * Uses a template method provided by subclasses to display errors in an
     * environment appropriate way.
     *
     * @param \Throwable $exception Exception instance.
     * @return void
     * @throws \Exception When renderer class not found
     * @see https://secure.php.net/manual/en/function.set-exception-handler.php
     */
    void handleException(Throwable $exception) {
        if (this.disabled) {
            return;
        }
        $request = Router::getRequest();

        this.logException($exception, $request);

        try {
            $renderer = this.renderer($exception);
            $renderer.write($renderer.render());
        } catch (Throwable $exception) {
            this.logInternalError($exception);
        }
        // Use this constant as a proxy for cakephp tests.
        if (PHP_SAPI == "cli" && !env("FIXTURE_SCHEMA_METADATA")) {
            exit(1);
        }
    }

    /**
     * Shutdown handler
     *
     * Convert fatal errors into exceptions that we can render.
     */
    void handleShutdown() {
        if (this.disabled) {
            return;
        }
        $megabytes = _config["extraFatalErrorMemory"] ?? 4;
        if ($megabytes > 0) {
            this.increaseMemoryLimit($megabytes * 1024);
        }
        $error = error_get_last();
        if (!is_array($error)) {
            return;
        }
        $fatals = [
            E_USER_ERROR,
            E_ERROR,
            E_PARSE,
        ];
        if (!hasAllValues($error["type"], $fatals, true)) {
            return;
        }
        this.handleFatalError(
            $error["type"],
            $error["message"],
            $error["file"],
            $error["line"]
        );
    }

    /**
     * Increases the PHP "memory_limit" ini setting by the specified amount
     * in kilobytes
     *
     * @param int $additionalKb Number in kilobytes
     */
    void increaseMemoryLimit(int $additionalKb) {
        $limit = ini_get("memory_limit");
        if ($limit == false || $limit == "" || $limit == "-1") {
            return;
        }
        $limit = trim($limit);
        $units = strtoupper(substr($limit, -1));
        $current = (int)substr($limit, 0, -1);
        if ($units == "M") {
            $current *= 1024;
            $units = "K";
        }
        if ($units == "G") {
            $current = $current * 1024 * 1024;
            $units = "K";
        }

        if ($units == "K") {
            ini_set("memory_limit", ceil($current + $additionalKb) ~ "K");
        }
    }

    /**
     * Display/Log a fatal error.
     *
     * @param int $code Code of error
     * @param string $description Error description
     * @param string $file File on which error occurred
     * @param int $line Line that triggered the error
     */
    void handleFatalError(int $code, string $description, string $file, int $line) {
        this.handleException(new FatalErrorException("Fatal Error: " ~ $description, 500, $file, $line));
    }

    /**
     * Log an exception.
     *
     * Primarily a function to ensure consistency between global exception handling
     * and the ErrorHandlerMiddleware. This method will apply the `skipLog` filter
     * skipping logging if the exception should not be logged.
     *
     * After logging is attempted the `Exception.beforeRender` event is triggered.
     *
     * @param \Throwable $exception The exception to log
     * @param \Psr\Http\messages.IServerRequest|null $request The optional request
     */
    void logException(Throwable $exception, ?IServerRequest $request = null) {
        $shouldLog = _config["log"];
        if ($shouldLog) {
            foreach (this.getConfig("skipLog") as $class) {
                if ($exception instanceof $class) {
                    $shouldLog = false;
                }
            }
        }
        if ($shouldLog) {
            $logger = this.logger();
            if (method_exists($logger, "logException")) {
                $logger.logException($exception, $request, _config["trace"]);
            } else {
                $loggerClass = get_class($logger);
                deprecationWarning(
                    "The configured logger `{$loggerClass}` should implement `logException()` " ~
                    "to be compatible with future versions of UIM."
                );
                this.logger().log($exception, $request);
            }
        }
        this.dispatchEvent("Exception.beforeRender", ["exception": $exception]);
    }

    /**
     * Trigger an error that occurred during rendering an exception.
     *
     * By triggering an E_USER_ERROR we can end up in the default
     * exception handling which will log the rendering failure,
     * and hopefully render an error page.
     *
     * @param \Throwable $exception Exception to log
     */
    void logInternalError(Throwable $exception) {
        $message = sprintf(
            "[%s] %s (%s:%s)", // Keeping same message format
            get_class($exception),
            $exception.getMessage(),
            $exception.getFile(),
            $exception.getLine(),
        );
        trigger_error($message, E_USER_ERROR);
    }
}