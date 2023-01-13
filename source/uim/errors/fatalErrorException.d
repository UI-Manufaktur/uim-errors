/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.errors;

@safe:
import uim.errors;


use Throwable;
/**
 * Represents a fatal error
 */
class FatalErrorException : UIMException {
    /**
     * Constructor
     *
     * @param string myMessage Message string.
     * @param int|null $code Code.
     * @param string|null myfile File name.
     * @param int|null $line Line number.
     * @param \Throwable|null $previous The previous exception.
     */
    this(
        string myMessage,
        Nullable!int $code = null,
        Nullable!string myfile = null,
        Nullable!int $line = null,
        ?Throwable $previous = null
    ) {
        super.this(myMessage, $code, $previous);
        if (myfile) {
            this.file = myfile;
        }
        if ($line) {
            this.line = $line;
        }
    }
}
