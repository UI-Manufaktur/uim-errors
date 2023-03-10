module uim.errors.renderers;

@safe:
import uim.errors;

/* use PDOException;
use Psr\Http\messages.IResponse;
use Throwable; */

/**
 * Web Exception Renderer.
 *
 * Captures and handles all unhandled exceptions. Displays helpful framework errors when debug is true.
 * When debug is false, WebExceptionRenderer will render 404 or 500 errors. If an uncaught exception is thrown
 * and it is a type that WebExceptionHandler does not know about it will be treated as a 500 error.
 *
 * ### Implementing application specific exception rendering
 *
 * You can implement application specific exception handling by creating a subclass of
 * WebExceptionRenderer and configure it to be the `exceptionRenderer` in config/error.php
 *
 * #### Using a subclass of WebExceptionRenderer
 *
 * Using a subclass of WebExceptionRenderer gives you full control over how Exceptions are rendered, you
 * can configure your class in your config/app.php.
 */
class WebExceptionRenderer : IExceptionRenderer
{
    /**
     * The exception being handled.
     *
     * @var \Throwable
     */
    protected $error;

    /**
     * Controller instance.
     *
     * @var uim.cake.controllers.Controller
     */
    protected $controller;

    /**
     * Template to render for {@link uim.cake.Core\exceptions.UIMException}
     */
    protected string $template = "";

    /**
     * The method corresponding to the Exception this object is for.
     */
    protected string $method = "";

    /**
     * If set, this will be request used to create the controller that will render
     * the error.
     *
     * @var uim.cake.http.ServerRequest|null
     */
    protected $request;

    /**
     * Map of exceptions to http status codes.
     *
     * This can be customized for users that don"t want specific exceptions to throw 404 errors
     * or want their application exceptions to be automatically converted.
     *
     * @var array<string, int>
     * @psalm-var array<class-string<\Throwable>, int>
     */
    protected $exceptionHttpCodes = [
        // Controller exceptions
        InvalidParameterException::class: 404,
        MissingActionException::class: 404,
        // Datasource exceptions
        PageOutOfBoundsException::class: 404,
        RecordNotFoundException::class: 404,
        // Http exceptions
        MissingControllerException::class: 404,
        // Routing exceptions
        MissingRouteException::class: 404,
    ];

    /**
     * Creates the controller to perform rendering on the error response.
     *
     * @param \Throwable $exception Exception.
     * @param uim.cake.http.ServerRequest|null $request The request if this is set it will be used
     *   instead of creating a new one.
     */
    this(Throwable $exception, ?ServerRequest $request = null) {
        this.error = $exception;
        this.request = $request;
        this.controller = _getController();
    }

    /**
     * Get the controller instance to handle the exception.
     * Override this method in subclasses to customize the controller used.
     * This method returns the built in `ErrorController` normally, or if an error is repeated
     * a bare controller will be used.
     *
     * @return uim.cake.controllers.Controller
     * @triggers Controller.startup $controller
     */
    protected function _getController(): Controller
    {
        $request = this.request;
        $routerRequest = Router::getRequest();
        // Fallback to the request in the router or make a new one from
        // _SERVER
        if ($request == null) {
            $request = $routerRequest ?: ServerRequestFactory::fromGlobals();
        }

        // If the current request doesn"t have routing data, but we
        // found a request in the router context copy the params over
        if ($request.getParam("controller") == null && $routerRequest != null) {
            $request = $request.withAttribute("params", $routerRequest.getAttribute("params"));
        }

        $errorOccured = false;
        try {
            $params = $request.getAttribute("params");
            $params["controller"] = "Error";

            $factory = new ControllerFactory(new Container());
            aClassName = $factory.getControllerClass($request.withAttribute("params", $params));

            if (!aClassName) {
                /** @var string aClassName */
                aClassName = App::className("Error", "Controller", "Controller");
            }

            /** @var uim.cake.controllers.Controller $controller */
            $controller = new aClassName($request);
            $controller.startupProcess();
        } catch (Throwable $e) {
            $errorOccured = true;
        }

        if (!isset($controller)) {
            return new Controller($request);
        }

        // Retry RequestHandler, as another aspect of startupProcess()
        // could have failed. Ignore any exceptions out of startup, as
        // there could be userland input data parsers.
        if ($errorOccured && isset($controller.RequestHandler)) {
            try {
                $event = new Event("Controller.startup", $controller);
                $controller.RequestHandler.startup($event);
            } catch (Throwable $e) {
            }
        }

        return $controller;
    }

    /**
     * Clear output buffers so error pages display properly.
     */
    protected void clearOutput() {
        if (hasAllValues(PHP_SAPI, ["cli", "phpdbg"])) {
            return;
        }
        while (ob_get_level()) {
            ob_end_clean();
        }
    }

    /**
     * Renders the response for the exception.
     *
     * @return uim.cake.http.Response The response to be sent.
     */
    function render(): IResponse
    {
        $exception = this.error;
        $code = this.getHttpCode($exception);
        $method = _method($exception);
        $template = _template($exception, $method, $code);
        this.clearOutput();

        if (method_exists(this, $method)) {
            return _customMethod($method, $exception);
        }

        $message = _message($exception, $code);
        $url = this.controller.getRequest().getRequestTarget();
        $response = this.controller.getResponse();

        if ($exception instanceof UIMException) {
            /** @psalm-suppress DeprecatedMethod */
            foreach ((array)$exception.responseHeader() as $key: $value) {
                $response = $response.withHeader($key, $value);
            }
        }
        if ($exception instanceof HttpException) {
            foreach ($exception.getHeaders() as $name: $value) {
                $response = $response.withHeader($name, $value);
            }
        }
        $response = $response.withStatus($code);

        $exceptions = [$exception];
        $previous = $exception.getPrevious();
        while ($previous != null) {
            $exceptions ~= $previous;
            $previous = $previous.getPrevious();
        }

        $viewVars = [
            "message": $message,
            "url": h($url),
            "error": $exception,
            "exceptions": $exceptions,
            "code": $code,
        ];
        $serialize = ["message", "url", "code"];

        $isDebug = Configure::read("debug");
        if ($isDebug) {
            $trace = (array)Debugger::formatTrace($exception.getTrace(), [
                "format": "array",
                "args": true,
            ]);
            $origin = [
                "file": $exception.getFile() ?: "null",
                "line": $exception.getLine() ?: "null",
            ];
            // Traces don"t include the origin file/line.
            array_unshift($trace, $origin);
            $viewVars["trace"] = $trace;
            $viewVars += $origin;
            $serialize ~= "file";
            $serialize ~= "line";
        }
        this.controller.set($viewVars);
        this.controller.viewBuilder().setOption("serialize", $serialize);

        if ($exception instanceof UIMException && $isDebug) {
            this.controller.set($exception.getAttributes());
        }
        this.controller.setResponse($response);

        return _outputMessage($template);
    }

    /**
     * Emit the response content
     *
     * @param \Psr\Http\messages.IResponse|string $output The response to output.
     */
    void write($output) {
        if (is_string($output)) {
            writeln($output;

            return;
        }

        $emitter = new ResponseEmitter();
        $emitter.emit($output);
    }

    /**
     * Render a custom error method/template.
     *
     * @param string $method The method name to invoke.
     * @param \Throwable $exception The exception to render.
     * @return uim.cake.http.Response The response to send.
     */
    protected function _customMethod(string $method, Throwable $exception): Response
    {
        $result = this.{$method}($exception);
        _shutdown();
        if (is_string($result)) {
            $result = this.controller.getResponse().withStringBody($result);
        }

        return $result;
    }

    /**
     * Get method name
     *
     * @param \Throwable $exception Exception instance.
     */
    protected string _method(Throwable $exception) {
        [, $baseClass] = namespaceSplit(get_class($exception));

        if (substr($baseClass, -9) == "Exception") {
            $baseClass = substr($baseClass, 0, -9);
        }

        // $baseClass would be an empty string if the exception class is \Exception.
        $method = $baseClass == "" ? "error500" : Inflector::variable($baseClass);

        return this.method = $method;
    }

    /**
     * Get error message.
     *
     * @param \Throwable $exception Exception.
     * @param int $code Error code.
     * @return string Error message
     */
    protected string _message(Throwable $exception, int $code) {
        $message = $exception.getMessage();

        if (
            !Configure::read("debug") &&
            !($exception instanceof HttpException)
        ) {
            if ($code < 500) {
                $message = __d("cake", "Not Found");
            } else {
                $message = __d("cake", "An Internal Error Has Occurred.");
            }
        }

        return $message;
    }

    /**
     * Get template for rendering exception info.
     *
     * @param \Throwable $exception Exception instance.
     * @param string $method Method name.
     * @param int $code Error code.
     * @return string Template name
     */
    protected string _template(Throwable $exception, string $method, int $code) {
        if ($exception instanceof HttpException || !Configure::read("debug")) {
            return this.template = $code < 500 ? "error400" : "error500";
        }

        if ($exception instanceof PDOException) {
            return this.template = "pdo_error";
        }

        return this.template = $method;
    }

    /**
     * Gets the appropriate http status code for exception.
     *
     * @param \Throwable $exception Exception.
     * @return int A valid HTTP status code.
     */
    protected int getHttpCode(Throwable $exception) {
        if ($exception instanceof HttpException) {
            return $exception.getCode();
        }

        return this.exceptionHttpCodes[get_class($exception)] ?? 500;
    }

    /**
     * Generate the response using the controller object.
     *
     * @param string $template The template to render.
     * @return uim.cake.http.Response A response object that can be sent.
     */
    protected function _outputMessage(string $template): Response
    {
        try {
            this.controller.render($template);

            return _shutdown();
        } catch (MissingTemplateException $e) {
            $attributes = $e.getAttributes();
            if (
                $e instanceof MissingLayoutException ||
                strpos($attributes["file"], "error500") != false
            ) {
                return _outputMessageSafe("error500");
            }

            return _outputMessage("error500");
        } catch (MissingPluginException $e) {
            $attributes = $e.getAttributes();
            if (isset($attributes["plugin"]) && $attributes["plugin"] == this.controller.getPlugin()) {
                this.controller.setPlugin(null);
            }

            return _outputMessageSafe("error500");
        } catch (Throwable $outer) {
            try {
                return _outputMessageSafe("error500");
            } catch (Throwable $inner) {
                throw $outer;
            }
        }
    }

    /**
     * A safer way to render error messages, replaces all helpers, with basics
     * and doesn"t call component methods.
     *
     * @param string $template The template to render.
     * @return uim.cake.http.Response A response object that can be sent.
     */
    protected function _outputMessageSafe(string $template): Response
    {
        $builder = this.controller.viewBuilder();
        $builder
            .setHelpers([], false)
            .setLayoutPath("")
            .setTemplatePath("Error");
        $view = this.controller.createView("View");

        $response = this.controller.getResponse()
            .withType("html")
            .withStringBody($view.render($template, "error"));
        this.controller.setResponse($response);

        return $response;
    }

    /**
     * Run the shutdown events.
     *
     * Triggers the afterFilter and afterDispatch events.
     *
     * @return uim.cake.http.Response The response to serve.
     */
    protected function _shutdown(): Response
    {
        this.controller.dispatchEvent("Controller.shutdown");

        return this.controller.getResponse();
    }

    /**
     * Returns an array that can be used to describe the internal state of this
     * object.
     *
     * @return array<string, mixed>
     */
    array __debugInfo() {
        return [
            "error": this.error,
            "request": this.request,
            "controller": this.controller,
            "template": this.template,
            "method": this.method,
        ];
    }
}
