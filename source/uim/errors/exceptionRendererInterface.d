module uim.errors;

@safe:
import uim.cake;

use Psr\Http\messages.IResponse; 
// IExceptionRenderer
interface IExceptionRenderer {
    /**
     * Renders the response for the exception.
     *
     * @return The response to be sent.
     */
    IResponse render();
}
