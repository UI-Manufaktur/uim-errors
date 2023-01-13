


 *


 * @since         3.4.0
  */module uim.cake.Error;

use Psr\Http\messages.IResponse;

/**
 * Interface IExceptionRenderer
 *
 * @method \Psr\Http\messages.IResponse|string render() Render the exception to a string or Http Response.
 * @method void write(\Psr\Http\messages.IResponse|string $output) Write the output to the output stream.
 *  This method is only called when exceptions are handled by a global default exception handler.
 */
interface IExceptionRenderer
{
    /**
     * Renders the response for the exception.
     *
     * @return \Psr\Http\messages.IResponse The response to be sent.
     */
    function render(): IResponse;
}
