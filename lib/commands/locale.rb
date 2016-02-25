module Visjar
  module Commands
    class Locale
      def self.run(client, slack, recast)
        recast = recast['sentences'].first

        # Get informations about the request
        @nationality = recast['entities']['nationality'].first rescue nil
        @language    = recast['entities']['language'].first rescue nil

        if @nationality
          Config.locale = @nationality['code']
          client.send_message(slack['channel'], "Thanks, you'll now receive the news in '#{@nationality['raw'].capitalize}'.")
        elsif @language
          Config.locale = @language['code']
          client.send_message(slack['channel'], "Thanks, you'll now receive the news in '#{@language['raw'].capitalize}'.")
        else
          client.send_message(slack['channel'], "Woops, are you sure you provided your language?")
        end
      end

      Commands::register("locale", self)
    end
  end
end
