# Final Project: Quiz Application with Microservices
# Date: 10-Jun-2022
# Authors:
#          A01376331 Rubén Villalpando Bremont
#          A01747247 Zoe Caballero Dominguez

# The +LambdaHandlerTemplate+ is an implementation of the {Template Method}[https://en.wikipedia.org/wiki/Factory_method_pattern].
# It allows you to create instances of various ::LambdaHandler classes.
# Each one with the same logic starting with the ::handle_request, 
# just overriding methods that the implementation will accept.
class LambdaHandlerTemplate
    # a Status code indicating that all went well
    STATUS_OK = 200
    # a Status code indicating that the DB was updated successfuly
    STATUS_UPDATED = 201
    # a Status code indicating that something went wrong
    STATUS_BAD_REQUEST = 400
    # a Status code indicating that an unallowed method is being used
    STATUS_METHOD_NOT_ALLOWED = 405
    
    # Handle the request depending on what http request method that is used
    #
    # Returns:: A hash with the response body 
    def handle_request(event)
        method = event['httpMethod']
        case method
        when 'GET'
            handle_get(event)
        when 'POST'
            handle_post(event)
        when 'PUT'
            handle_put(event)
        when 'DELETE'
            handle_delete(event)
        else
            handle_bad_method(method)
        end
    end
    
    # Handles the situation when a non supported method is used
    #
    # Returns:: A hash with the response body
    def handle_bad_method(method)
        make_response(STATUS_METHOD_NOT_ALLOWED,
        {message: "Method not supported: #{method}"})
    end
    
    # Handle the get request (is implemented as bad method by default)
    #
    # Returns:: A hash with the response body
    def handle_get(event)
        handle_bad_method(event['httpMethod'])
    end
    
    # Handle the post request (is implemented as bad method by default)
    #
    # Returns:: A hash with the response body
    def handle_post(event)
        handle_bad_method(event['httpMethod'])
    end
    
    # Handle the put request (is implemented as bad method by default)
    #
    # Returns:: A hash with the response body
    def handle_put(event)
        handle_bad_method(event['httpMethod'])
    end
    
    # Handle the delete request (is implemented as bad method by default)
    #
    # Returns:: A hash with the response body
    def handle_delete(event)
        handle_bad_method(event['httpMethod'])
    end
    
    # Builds a valid response with the correct status and the body of 
    # what the get path returns
    #
    # Returns:: A hash with the response body
    def return_valid_get_response(body)
        make_response(STATUS_OK, body)
    end
    
    # Builds a valid response with the correct status and the body of 
    # what the post path uploads
    #
    # Returns:: A hash with the response body
    def return_valid_post_response(message)
        make_response(STATUS_UPDATED, {"success" => message})
    end
    
    # Builds an error response with the message provided
    #
    # Returns:: A hash with the response body
    def return_error_response(message)
        make_response(STATUS_BAD_REQUEST, {"error" => message})
    end
    
    # Builds the response that any return_... uses for code simplicity
    #
    # Returns:: A hash with the response body
    def make_response(code, body)
        {
            statusCode: code,
            headers: {
                "Content-Type" => "application/json; charset=utf-8"
            },
            body: JSON.generate(body)
        }
    end
end