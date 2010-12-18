require 'sinatra'
require 'twiliolib'
require 'erb'
require 'builder'

# Twilio authentication credentials
ACCOUNT_SID = 'XXXXXXXXXX'
ACCOUNT_TOKEN = 'XXXXXXXXXX'
 
# version of the Twilio REST API to use
API_VERSION = '2010-04-01'
 
# base URL of this application
BASE_URL = "http://XXXXXXXXX.com/"
 
# my Caller ID 
CALLER_ID = 'XXXXXXXXXX'


get '/' do
  erb :index
end

get '/no-number' do
  erb :nonumber
end

# generate the Twiml to utter Stevie's classic line
post '/sayit' do
  builder do |xml|
    xml.instruct!
    xml.Response do
      xml.Say("I just called to say I love you")
    end
  end
end

# if valid phone # present, make the call
post '/makecall' do
  if !params[:number] || params[:number].empty?
    # "oops you forgot number lol"
    redirect '/no-number'
  end

  # post the goodies to Twilio's api
  d = {
      'From' => CALLER_ID,
      'To' => params['number'],
      'Url' => BASE_URL + "sayit",
  }
  begin
      account = Twilio::RestAccount.new(ACCOUNT_SID, ACCOUNT_TOKEN)
      resp = account.request(
          "/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/Calls",
          'POST', d)
      resp.error! unless resp.kind_of? Net::HTTPSuccess
  rescue StandardError => bang
      serviceerror(bang)
  end
  alert(params[:number])
end

helpers do
  # help haxorz by playing http error messages back to browser
  def serviceerror(error)
    erb :serviceerror, :locals => { :msg => error }
  end 

  # let the user know you are dialing the number 
  def alert(number)
    erb :alert, :locals => { :number => number }
  end
end
