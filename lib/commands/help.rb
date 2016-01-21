module Visjar
  module Commands
    class Help
      def self.run(client, slack, recast)
        client.send_message(slack['channel'], "Hi I'm #{Config.names.first}. :robot_face:\nYou can talk with me in DM or by pinging me (@#{Config.names.first.downcase}) at the begining of your sentence!\nIn my current version, you can ask me to get the weather, to find a good restaurant near you, to get the latests news and to search on the web!")
        client.send_message(slack['channel'], 'See below for an example:',{attachments: [{fallback: "Test", text: "@#{Config.names.first.downcase}: How'll be the weather in Paris tomorrow ?", color: "#EAA724"}]})
      end

      Commands::register("help", self)
    end
  end
end
