module Visjar
  module Commands
    class Help
      def self.run(client, slack, recast)
        client.send_message(slack['channel'], "Hi I'm #{Config.names.first}. :robot_face:\nYou can talk with me in DM or by pinging me (@#{Config.names.first.downcase}) at the begining of your sentence!\nIn my current version, you can ask me to get the weather, to find a good restaurant near you, to get the latests news, to check if a website is down or not and to search on the web! Also, you can set your prefered language (for the news), and your location (for the weather and the restaurants).")
        client.send_message(slack['channel'], 'See below for an example:',{attachments: [{fallback: "How'll be the weather in Paris tomorrow?", text: "@#{Config.names.first.downcase}: How'll be the weather in Paris tomorrow?", color: "#FFB300"}, {fallback: "Could you set my language to French?", text: "@#{Config.names.first.downcase}: Could you set my language to French?", color: "#FFCA28"}]})
      end

      Commands::register("help", self)
    end
  end
end
