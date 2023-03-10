/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.errors.renderers.html;

@safe:
import uim.errors;

/**
 * Interactive HTML error rendering with a stack trace.
 *
 * Default output renderer for non CLI SAPI.
 */
class HtmlErrorRenderer : IErrorRenderer {

    void write(string outText) {
        // Output to stdout which is the server response.
        writeln(outText);
    }

    string render(DERRError anError, bool $debug) {
        if (!$debug) {
            return "";
        }
        $id = "cakeErr" ~ uniqid();
        $file = $error.getFile();

        // Some of the error data is not HTML safe so we escape everything.
        $description = h($error.getMessage());
        $path = h($file);
        $trace = h($error.getTraceAsString());
        $line = $error.getLine();

        $errorMessage = sprintf(
            "<b>%s</b> (%s)",
            h(ucfirst($error.getLabel())),
            h($error.getCode())
        );
        $toggle = this.renderToggle($errorMessage, $id, "trace");
        $codeToggle = this.renderToggle("Code", $id, "code");

        $excerpt = null;
        if ($file && $line) {
            $excerpt = Debugger::excerpt($file, $line, 1);
        }
        $code = implode("\n", $excerpt);

        return <<<HTML
<div class="cake-error">
    {$toggle}: {$description} [in <b>{$path}</b>, line <b>{$line}</b>]
    <div id="{$id}-trace" class="cake-stack-trace" style="display: none;">
        {$codeToggle}
        <pre id="{$id}-code" class="cake-code-dump" style="display: none;">{$code}</pre>
        <pre class="cake-trace">{$trace}</pre>
    </div>
</div>
HTML;
    }

    /**
     * Render a toggle link in the error content.
     *
     * @param string $text The text to insert. Assumed to be HTML safe.
     * @param string $id The error id scope.
     * @param string $suffix The element selector.
     * @return string
     */
    private string renderToggle(string $text, string $id, string $suffix) {
        $selector = $id ~ "-" ~ $suffix;

        // phpcs:disable
        return <<<HTML
<a href="javascript:void(0);"
  onclick="document.getElementById("{$selector}").style.display = (document.getElementById("{$selector}").style.display == "none" ? "" : "none")"
>
    {$text}
</a>
HTML;
        // phpcs:enable
    }
}
