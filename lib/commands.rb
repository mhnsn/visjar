#encoding: utf-8

module Visjar
  module Commands
    @commands = {}

    def self.invoke(client, slack, recast)
      intent = recast['intents'].first['intent']

      @commands.each_pair do |route, klass|
        klass.run(client, slack, recast) if route == intent
      end
    rescue StandardError => e
      client.send_message(slack['channel'], "Sorry, something bad happened, my creators are on it already!")
      Log.error(e)
    end

    def self.register(route, klass)
      @commands[route] = klass
    end

    def self.commands
      @commands
    end
  end
end
