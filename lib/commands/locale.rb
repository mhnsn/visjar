module Visjar
  module Commands
    class Locale
      def self.run(client, slack, recast)
        recast = recast['sentences'].first

        # Get informations about the request
        @nationality = recast['entities']['nationality'].first['value'] rescue nil
        if @nationality
          loc           = ISO_639.find_by_english_name(@nationality.capitalize)
          Config.locale = loc[2] if loc.any?
          client.send_message(slack['channel'], "Thanks, I just set your locale to '#{@nationality.capitalize}'.")
        else
          client.send_message(slack['channel'], "Woops, are you sure you provided your language?")
        end
      end

      Commands::register("locale", self)
    end
  end
end
