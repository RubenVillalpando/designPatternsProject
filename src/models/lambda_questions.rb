# Final Project: Quiz Application with Microservices
# Date: 10-Jun-2022
# Authors:
#          A01376331 Rubén Villalpando Bremont
#          A01747247 Zoe Caballero Dominguez
require 'json'
require './lambda_handler_template'

# Main function that calls various functions to format the questions to be returned.
#
# Parameter::
#    num_questions:: the number of the subset of questions taken from the json
#
# Returns:: +nil+ if an error happens while getting the json 
# or an invalid number of arguments is passed
def get_questions(num_questions)
    if num_questions < 11 && num_questions > 0
        questions_json = get_questions_json()
        get_random_questions(questions_json, num_questions)
    else
        nil
    end
end

# Reads and formats the json in the correct format.
#
# Returns:: +nil+ if an error happens while reading or parsing the json
def get_questions_json()
    begin
        raw_json = File.read('./questions.json')
    rescue
        return nil
    end
    begin
        questions_json = JSON.parse(raw_json)
    rescue
        nil
    end
end

# Gets a random number of questions from the total pool
#
# Parameter::
#    questions_json:: parsed json with all the questions
#    num_questions:: the number of the subset of questions taken from the json
#
# Returns:: An array of length 1 to 10 consisting of 
#     random questions depending on the requested amount
def get_random_questions(questions_json, num_questions)
    begin
        array_questions = questions_json["QUESTIONS"] 
        array_questions.sample(num_questions)
    rescue
        nil
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
    handler = LambdaHandlerQuestions.new()
    handler.handle_request(event)
end


# The +LambdaHandlerScores+ is an implementation of the ::LambdaHandlerTemplate class
# It overrides the ::handle_get functions to recognize it as a valid method.
class LambdaHandlerQuestions < LambdaHandlerTemplate
    
    # Handles the get method as a valid request for the questions
    #
    # Parameter::
    #    event:: The event that is fired when the lambda is triggered
    #
    # Returns:: An array with different hashes representing the quesions
    # with its respective answers
    def handle_get(event)
        num_questions_str = event.dig('queryStringParameters', 'n') || '0'
        num_questions = num_questions_str.to_i
        questions = get_questions(num_questions)
        if questions
            return_valid_get_response(questions)
        else
            return_error_response("There was an error fetching the questions")
        end
    end
    
end