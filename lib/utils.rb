#encoding: utf-8

module Visjar
  class Utils
    # Versioning
    MAJOR   = "0"
    MINOR   = "1"
    MICRO   = "0"
    VERSION = "#{MAJOR}.#{MINOR}.#{MICRO}"

    # Dirty hack because RecastAI can't detect food types jutst yet :(
    TYPES   = [
      'pizza',
      'crepe',
      'creperie',
      'burger',
      'sushi',
      'pasta',
      'kebab',
      'steak',
      'salad',
      'sandwich',
      'italian',
      'chinese',
      'japanese',
      'lebanese',
      'french',
      'corean',
    ]
  end
end

# This is a monkey-patch for slack-ruby-client's realtime client.
# The realtime client allow us to work on events, but we couldn't make the text formatting work.
# Thus, we are using the web_client for message formatting.
module Slack
  module RealTime
    class Client
      def send_message(channel, text, options = {})
        self.web_client.chat_postMessage({channel: channel, text: text, as_user: true}.merge(options))
      end
    end
  end
end
