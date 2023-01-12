


 *


 * @since         4.4.0
  */module uim.errors.renderers;

import uim.errors.ErrorRendererInterface;
import uim.errors.PhpError;

/**
 * Plain text error rendering with a stack trace.
 *
 * Useful in CLI environments.
 */
class TextErrorRenderer : ErrorRendererInterface
{

    void write(string $out) {
        echo $out;
    }


    string render(PhpError $error, bool $debug) {
        if (!$debug) {
            return "";
        }

        return sprintf(
            "%s: %s :: %s on line %s of %s\nTrace:\n%s",
            $error.getLabel(),
            $error.getCode(),
            $error.getMessage(),
            $error.getLine() ?? "",
            $error.getFile() ?? "",
            $error.getTraceAsString(),
        );
    }
}
