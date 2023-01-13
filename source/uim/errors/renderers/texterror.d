/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.errors.renderers;

@safe:
import uim.errors;


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
