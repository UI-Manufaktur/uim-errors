


 *


 * @since         4.4.0
  */module uim.cake.errorss.renderers;

import uim.cake.errorss.ErrorRendererInterface;
import uim.cake.errorss.DERRError;

/**
 * Plain text error rendering with a stack trace.
 *
 * Useful in CLI environments.
 */
class TextErrorRenderer : ErrorRendererInterface
{

    void write(string $out) {
        writeln($out;
    }


    string render(DERRError $error, bool $debug) {
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
