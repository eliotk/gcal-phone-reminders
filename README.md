### What is this?

A simple application that uses Google Calendar as a controller to schedule automated voice calls using the twilio voice API.

### Components

1. A sinatra web server (twiml_server.rb) that serves the [TwiML](https://www.twilio.com/docs/api/twiml) XML instructions
- A process (check-events.rb) to check for scheduled events and create a call if an event is found

### The flow

1. The check-events.rb process runs every hour
- Google Calendar API authentication occurs using an [Oauth 2.0 Service Account](https://developers.google.com/accounts/docs/OAuth2ServiceAccount)
- An API call is issued to list events filtered scoped to the event start time being earlier than the current time + 5 minutes and the end time being later than the current time, which selects for an event slotted to be taking place at the time of the process run.
