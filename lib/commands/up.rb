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
          if response.code != 200
            client.send_message(slack['channel'], "Looks like #{@url} is down from here.", {unfurl_links: false})
          else
            client.send_message(slack['channel'], "#{@url} seems up.", {unfurl_links: false})
          end
        else
          client.send_message(slack['channel'], "Sorry, I didn't understand the site you want me to check.")
        end
      rescue StandardError
        client.send_message(slack['channel'], "Looks like #{@url} is down from here.", {unfurl_links: false})
      end

      Commands::register("up", self)
    end
  end
end
