# Final Project: Quiz Application with Microservices
# Date: 10-Jun-2022
# Authors:
#          A01376331 Rubén Villalpando Bremont
#          A01747247 Zoe Caballero Dominguez
require 'sinatra'
require 'json'
require 'faraday'

set :sessions, true

# url to connect to the lambda API Gateway for the questions
QUESTIONS_LAMBDA_API_URL = "https://k8o5fsch4h.execute-api.us-east-1.amazonaws.com/default/lambda_questions"
# url to connect to the lambda API Gateway for the scores
SCORES_LAMBDA_API_URL = "https://m4onlnhheh.execute-api.us-east-1.amazonaws.com/default/lambdaScores"

# Class to encapsulate the different Faraday connections used in the server
# It allows you to create instances of various connections 
#to call the different lambda functions for each microservice
class Connection
    
    # Initializes the connection object to connect to the lambda API
    #
    # Parameter::
    #    url:: The url to connect to
    def initialize(url)
        @connection = Faraday.new(url)
    end 
    
    # Parses the body being recieved by the get method to format it and make
    # sure it works for the database
    #
    # Parameter::
    #    i:: The quantity of info to be obtained
    #
    # Returns:: the data from the response or +nil+ if the request 
    # isn't successful.
    def get_info(i)
        res = @connection.get do |req|
            req.params['n'] = i
        end
        if res.success?
            data = JSON.parse(res.body)
        else
            data = JSON.parse(res.body)
            errorMsg = data.dig('error')
            p errorMsg
            nil
        end
    end
    
    # Parses the body that will be sent by the post method to format it and make
    # sure it works for the database
    #
    # Parameter::
    #    body:: The body of the http request to be sent 
    #
    # Returns:: The body of the response or +nil+ if the request fails
    def post_info(body)
        res = @connection.post do |req|
            req.body = body.to_json
        end
        if res.success?
            data = JSON.parse(res.body)
        else
            data = JSON.parse(res.body)
            errorMsg = data.dig('error')
            p errorMsg
            nil
        end
    end
end


questions_connection = Connection.new(QUESTIONS_LAMBDA_API_URL)
scores_connection = Connection.new(SCORES_LAMBDA_API_URL)


get '/' do
    erb :home
end

get '/error' do
    erb :error
end

get '/questions' do
    @user = params['user']
    session[@user] = {}
    num_questions = params['num_questions']
    questions = questions_connection.get_info(num_questions)
    if questions
        session[@user]["questions"] =  questions
        session[@user]["i"] = questions.length() -1
        session[@user]["score"] = 0
        redirect "/question/#{@user}"
    else
        redirect "/error"
    end
end

get '/question/:user' do
    @user = params['user']
    @questions = session[@user]['questions']
    @question_num = session[@user]['i']
    @question_num < 0 ? redirect("/scores/#{@user}") :  erb(:currentQuestion)
end

get '/questionFeedback/:user' do
    @user = params['user']
    @answer_num = params['answer_num'].to_i()
    @questions = session[@user]['questions']
    @question_num= session[@user]['i']
    @answers = @questions[@question_num]['answers']
    @answer_chosen = @answers[@answer_num]['answer']
    @is_correct = @answers[@answer_num]['isCorrect']
    @correct_answer = "42"
    if @is_correct
        session[@user]['score'] += 1
        @correct_answer = @answer_chosen
    else
        @answers.each do |answer|
            if answer['isCorrect']
                @correct_answer = answer['answer']
                break
            end
        end
    end
    session[@user]['i'] -= 1
    erb :feedback
end

get '/scores/:user' do
    @scores = scores_connection.get_info("10")
    @user = params['user']
    @score = session[@user]['score']
    erb :scores
end

post '/scores/:user' do
    user = params['user']
    score = session[user]['score']
    body = {
        "USERNAME": user,
        "Score": score
    }
    scores_connection.post_info(body)
    redirect '/'
end