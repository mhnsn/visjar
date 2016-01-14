#encoding: utf-8

module Visjar
  module Commands
    @commands = {}

    def self.invoke(client, slack, recast)
      intent = recast['intents'].first['intent']

      @commands.each_pair do |route, klass|
        klass.run(client, slack, recast) if route == intent
      end
    end

    def self.register(route, klass)
      @commands[route] = klass
    end

    def self.commands
      @commands
    end
  end
end
