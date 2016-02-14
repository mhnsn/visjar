require 'httparty'

module Visjar
  module Commands
    class Up
      def self.run(client, slack, recast)
        recast    = recast['sentences'].first

        # Get informations about the request
        @url  = recast['entities']['url'].first['value'] rescue nil

        if @url.nil? == false
          response = HTTParty.get(@url)
          if [500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511].include?(response.code)
            client.send_message(slack['channel'], "Looks like #{@url} is down from here.")
          else
            client.send_message(slack['channel'], "#{@url} seems up.")
          end
        else
          client.send_message(slack['channel'], "Sorry, I didn't understand the site you want me to check.")
        end
      rescue StandardError
        client.send_message(slack['channel'], "I have troubles checking the state of #{@url}...")
      end

      Commands::register("up", self)
    end
  end
end
