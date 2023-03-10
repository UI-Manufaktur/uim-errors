/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.errors.renderers.consoles.error;

@safe:
import uim.errors;


/**
 * Plain text error rendering with a stack trace.
 *
 * Writes to STDERR via a Cake\Console\ConsoleOutput instance for console environments
 */
class DERRConsoleErrorRenderer : IERRErrorRenderer {
  protected DCONConsoleOutput $output;

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


  void write(string outText) {
    this.output.write(outText);
  }


  string render(DERRError anError, bool $debug) {
    $trace = "";
    if (this.trace) {
      $trace = "\n<info>Stack Trace:</info>\n\n" ~ $error.getTraceAsString();
    }

    return 
      "<error>%s: %s :: %s</error> on line %s of %s%s".format(
        $error.getLabel(),
        $error.getCode(),
        $error.getMessage(),
        $error.getLine() ?? "",
        $error.getFile() ?? "",
        $trace            
    );
  }
}
