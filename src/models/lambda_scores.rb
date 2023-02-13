# Final Project: Quiz Application with Microservices
# Date: 10-Jun-2022
# Authors:
#          A01376331 Rubén Villalpando Bremont
#          A01747247 Zoe Caballero Dominguez
require 'json'
require 'aws-sdk-dynamodb'
require './lambda_handler_template'

# The instance of the Database we are going to access
DYNAMODB = Aws::DynamoDB::Client.new
# Table from where the information is going to be stored and obtained
TABLE_NAME = 'Scores'

# Main function to be used by the ::handle_post method 
#
# Parameter::
#    body:: The body of the http request gotten
#
# Returns:: The response from DYNAMODB or +nil+ if it fails
def post_score(body)
    score_info = parse_body(body)
    score_info['USER_ID'] = get_next_id()
    if score_info 
        begin
            DYNAMODB.put_item(table_name: TABLE_NAME, item: score_info)
        rescue
            nil
        end
    else
        nil
    end
end


# Generates the next USER_ID to be used
#
# Returns:: the next USER_ID to be used in the database with the new entry
def get_next_id
    DYNAMODB.scan(table_name: TABLE_NAME).count + 1
end
    

# Parses the body being recieved by the post method to format it and make
# sure it works for the database
#
# Parameter::
#    body:: The body of the http request to be sent 
#
# Returns:: the body being requested or +nil+ if it fails in any step
def parse_body(body)
    if body
        begin
            score_info = JSON.parse(body)
            score_info.key?('Score') and score_info.key?('USERNAME')? score_info : nil
        rescue JSON::ParserError
            nil
        end
    else
        nil
    end
end 


# Function that is called from the ::handle_get it handles null values 
# and returns the top scores
#
# Returns:: A list of at most 10 items of the top scores or +nil+ if it fails
def get_scores
    begin
        items = DYNAMODB.scan(table_name: TABLE_NAME).items
    rescue
        return nil
    end
    get_top_ten(items)
end


# Calls the ::sort_items function and then picks the top 10
#
# Parameter::
#    items:: The items returned from the database
#
# Returns:: A list of at most 10 items of the top scores
def get_top_ten(items)
    sort_items(items)
    make_result_list(items).first(10)
end


# Sorts the items returned from the database.
#
# Parameter::
#    items:: The items returned from the database
#
# Returns:: A list of ordered items.
def sort_items(items)
    items.sort! {|a, b| a['Score'] <=> b['Score']}
end


# Makes sure the items returned from the database are in the correct format.
#
# Parameter::
#    items:: The items returned from the database
#
# Returns:: A list of standarized items with the correct format
def make_result_list(items)
    items.map do |item| {
        'USERNAME' => item['USERNAME'],
        'Score' => item['Score'].to_i
    }
    end
end


# Handles the lambda when it is called
#
# Parameter::
#    event:: The event that is fired when the lambda is triggered
#    context:: An object that has information about the invocation
#
# Returns:: The build response with the questions or an error message
def lambda_handler(event:, context:)
    handler = LambdaHandlerScores.new()
    handler.handle_request(event)
end


# The +LambdaHandlerScores+ is an implementation of the ::LambdaHandlerTemplate class
# It overrides the ::handle_post and ::handle_get functions to recognize them as 
# valid methods.
class LambdaHandlerScores < LambdaHandlerTemplate
    
    # Handles the get method as a valid request
    #
    # Parameter::
    #    event:: The event that is fired when the lambda is triggered
    #
    # Returns:: A hash with at most the top 10 scores and its corresponding username
    def handle_get(event)
        scores = get_scores()
        if scores
            return_valid_get_response(scores)
        else
            return_error_response("There was an error accesing the scores from the database")
        end
    end
    
    # Handles the get method as a valid request for the scores
    #
    # Parameter::
    #    event:: The event that is fired when the lambda is triggered
    #
    # Returns:: A message indicating wether the post method was successful
    def handle_post(event)
        body = event['body']
        dbUpdated = post_score(body)
        if dbUpdated 
            return_valid_post_response("Scores Table Updated") 
        else 
            return_error_response("Error updating the scores table")
        end
    end
    
end