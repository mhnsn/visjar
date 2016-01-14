module Visjar
  module Commands
    class Help
      def self.run(client, slack, recast)
        client.send_message(slack['channel'], "In my current version, you can ask me to get the weather, to find a good restaurant near you, to get the latests news and to search on the web!")
      end

      Commands::register("help", self)
    end
  end
end
