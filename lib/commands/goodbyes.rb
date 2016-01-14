module Visjar
  module Commands
    class Goodbyes
      @answers  = YAML.load_file(File.join(File.dirname(__FILE__), '../../config/answers.yml'))['goodbyes']

      def self.run(client, slack, recast)
        client.send_message(slack['channel'], @answers.sample)
      end

      Commands::register("goodbyes", self)
    end
  end
end
