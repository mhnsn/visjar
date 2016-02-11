module Visjar
  module Commands
    class Location
      def self.run(client, slack, recast)
        recast = recast['sentences'].first

        # Get informations about the request
        @location = recast['entities']['location'].first['value'] rescue nil
        if @location
          Config.location = @location
          client.send_message(slack['channel'], "Thanks, I just set your location to '#{@location.titleize}'.")
        else
          client.send_message(slack['channel'], "Woops, are you sure you provided your location?")
        end
      end

      Commands::register("location", self)
    end
  end
end
