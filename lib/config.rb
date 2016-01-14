module Visjar
  class Config
    class << self
      attr_accessor :google_key
      attr_accessor :google_cx
      attr_accessor :recast_key
      attr_accessor :slack_key
      attr_accessor :forecast_key
      attr_accessor :location
      attr_accessor :limit_eat, :limit_news
      attr_accessor :id, :url, :team, :team_id, :names, :ims, :users

      def configure
        block_given? ? yield(self) : self
      end

      def regex_names
        regex = '('

        @names.each_with_index do |name, index|
          regex << name
          regex << '|' if index != @names.length - 1
        end

        regex << ')'

        regex
      end
    end
  end
end
