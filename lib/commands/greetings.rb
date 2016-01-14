module Visjar
  module Commands
    class Greetings
      @answers  = YAML.load_file(File.join(File.dirname(__FILE__), '../../config/answers.yml'))['greetings']

      def self.run(client, slack, recast)
        client.send_message(slack['channel'], @answers.sample)
      end

      Commands::register("greetings", self)
    end
  end
end
