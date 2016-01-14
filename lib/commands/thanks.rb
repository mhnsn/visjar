module Visjar
  module Commands
    class Thanks
      @answers  = YAML.load_file(File.join(File.dirname(__FILE__), '../../config/answers.yml'))['thanks']

      def self.run(client, slack, recast)
        client.send_message(slack['channel'], @answers.sample)
      end

      Commands::register("thanks", self)
    end
  end
end
