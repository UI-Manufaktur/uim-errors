


 *


 * @since         4.4.0
  */module uim.errors.renderers;

import uim.cake.consoles.ConsoleOutput;
import uim.errors.ErrorRendererInterface;
import uim.errors.PhpError;

/**
 * Plain text error rendering with a stack trace.
 *
 * Writes to STDERR via a Cake\Console\ConsoleOutput instance for console environments
 */
class ConsoleErrorRenderer : ErrorRendererInterface
{
    /**
     * @var uim.cake.consoles.ConsoleOutput
     */
    protected $output;

    /**
     */
    protected bool $trace = false;

    /**
     * Constructor.
     *
     * ### Options
     *
     * - `stderr` - The ConsoleOutput instance to use. Defaults to `php://stderr`
     * - `trace` - Whether or not stacktraces should be output.
     *
     * @param Json aConfig Error handling configuration.
     */
    this(Json aConfig) {
        this.output = aConfig["stderr"] ?? new ConsoleOutput("php://stderr");
        this.trace = (bool)(aConfig["trace"] ?? false);
    }


    void write(string $out) {
        this.output.write($out);
    }


    string render(PhpError $error, bool $debug) {
        $trace = "";
        if (this.trace) {
            $trace = "\n<info>Stack Trace:</info>\n\n" ~ $error.getTraceAsString();
        }

        return sprintf(
            "<error>%s: %s :: %s</error> on line %s of %s%s",
            $error.getLabel(),
            $error.getCode(),
            $error.getMessage(),
            $error.getLine() ?? "",
            $error.getFile() ?? "",
            $trace
        );
    }
}
