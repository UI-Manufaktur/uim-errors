/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.errors;

@safe:
import uim.errors;

/**
 * Interface for PHP error rendering implementations
 *
 * The core provided implementations of this interface are used
 * by Debugger and ErrorTrap to render PHP errors.
 */
interface IErrorRenderer
{
    /**
     * Render output for the provided error.
     *
     * @param uim.errors.DERRError $error The error to be rendered.
     * @param bool $debug Whether or not the application is in debug mode.
     * @return string The output to be echoed.
     */
    string render(DERRError anError, bool $debug);

    /**
     * Write output to the renderer"s output stream
     *
     * @param string $out The content to output.
     */
    void write(string outText);
}
