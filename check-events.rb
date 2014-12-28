require 'rubygems'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'twilio-ruby'
require 'open-uri'
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::INFO

logger.info("Checking google calendar events")

account_sid = ENV['account_sid'] # e.g. AC3094732a3c49700934481addd5ce1659
auth_token  = ENV['auth_token']
base_url    = ENV['base_url'] # used for the TwiML call back URL

client = Google::APIClient.new(
  :application_name => 'Cal events to voice',
  :application_version => '1.0.0'
)

key = OpenSSL::PKey::RSA.new ENV["p12_key"], 'notasecret'
client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/calendar',
  :issuer => ENV['google_service_account_email'],
  :signing_key => key)
client.authorization.fetch_access_token!

calendar = client.discovered_api('calendar', 'v3')

result = client.execute(
  :api_method => calendar.events.list,
  :parameters => {
    'calendarId' => ENV['calendar_id'],
    'timeMin'    => Time.now.to_datetime.rfc3339,
    'timeMax'    => (Time.now + (60*5)).to_datetime.rfc3339,
    'maxResults' => 2
  }
)

if result.data.items.first
  logger.info("Found one event w/ description: " + result.data.items.first.description)
  
  @client = Twilio::REST::Client.new account_sid, auth_token
  call = @client.account.calls.create(
    :url  => base_url + '/twiml?text=' + URI::encode(result.data.items.first.description),
    :to   => ENV['to_phone'],
    :from => ENV['from_phone']
  )

  logger.info("Twilio call triggered")
end