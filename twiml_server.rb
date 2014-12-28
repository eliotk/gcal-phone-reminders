require 'rubygems'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'sinatra'
require 'logger'
require 'twilio-ruby'
require 'open-uri'

enable :sessions

account_sid = ENV['account_sid'] # e.g. AC3094732a3c49700934481addd5ce1659
auth_token  = ENV['auth_token']
base_url    = ENV['base_url'] # used for the TwiML call back URL

def logger; settings.logger end

def api_client; settings.api_client; end

def calendar_api; settings.calendar; end

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', ENV['basic_auth_pw']]
  end
end

get '/' do
  protected!
end

post '/twiml' do
  protected!
  Twilio::TwiML::Response.new do |r|
    r.Say "#{params[:text]}", voice: 'alice', loop: '3'
  end.text
end
