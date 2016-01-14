module Visjar
  module Commands
    class Weather
      @icons = {
        'clear-day'           => ':sunny:',
        'clear-night'         => ':full_moon:',
        'rain'                => ':rain_cloud:',
        'snow'                => ':snow_cloud:',
        'sleet'               => ':wavy_dash:',
        'wind'                => ':dash:',
        'fog'                 => ':fog:',
        'cloudy'              => ':cloud:',
        'partly-cloudy-day'   => ':sunny::cloud:',
        'partly-cloudy-night' => ':full_moon::cloud:',
        'thunderstorm'        => ':lightning_cloud:',
        'tornado'             => ':tornado_cloud:',
      }

      def self.run(client, slack, recast)
        @datetime = nil
        @location = nil
        @duration = nil
        recast    = recast['intents'].first

        # Get informations about the request
        get_location(recast)
        get_datetime(recast)
        get_duration(recast)

        # If no location/type found, use the default.
        @location = Config.location if @location == nil

        response = JSON.parse(HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{@location.gsub(/\s+/, '+')}&key=#{Config.google_key}").body)
        if response['status'] == 'OK'
          pos = response['results'].first['geometry']['location']

          if @datetime != nil
            time = Chronic.parse(@datetime).to_i
          elsif @duration == nil
            time = Time.now.to_i
          end

          if time != nil
            forecast = ForecastIO.forecast(pos['lat'], pos['lng'], params:{units:'ca'}, time: time)
            answer   = generate_answer(recast, forecast.currently)

            client.send_message(slack['channel'], answer)
          else
            client.send_message(slack['channel'], 'Sorry, I can\'t handle time spans just yet!')
          end
        else
          client.send_message(slack['channel'], "Sorry, I didn't understood the location you asked for...")
        end
      end

      def self.generate_answer(recast, forecast)
        text = ""

        # Datetime
        text << (@datetime == nil ? "today" : @datetime).capitalize
        # Conjugation
        case recast['tense']
        when "past"
          text << " it was"
        when "future"
          text << " it will be"
        else
          text << " it is"
        end
        # Temperature
        text << " #{forecast.temperature.to_f.round(1)}°C"
        # Precipitation
        text << " with a #{(forecast.precipProbability.to_f * 100).round}% probability of #{forecast.precipType}" if forecast.precipProbability >= 0.10
        # Wind
        case forecast.windSpeed
        when 0..5
          text << " without wind"
        when 5..15
          text << " with a light breeze"
        when 15..30
          text << " with wind"
        when 30..60
          text << " with violent wind"
        when 60..999
          text << " with a storm"
        end
        # Convert forecast icons to slack icons
        text << " (#{@icons[forecast.icon]})"
        # Location
        text << " in " + @location.titleize

        text
      end

      # Helper to get the location
      # Will be removed after the next JSON iteration! TODO
      def self.get_location(recast)
        if recast['entity'] == 'location'
          @location = recast['value']
        elsif recast['at_location'].is_a?(String)
          @location = recast['at_location']
        end

        return if @location

        get_location(recast['at_value']) if recast['at_value'].is_a?(Hash)
        get_location(recast['for']) if recast['for']
        get_location(recast['agent']) if recast['agent']
        get_location(recast['action']) if recast['action']
        get_location(recast['theme']) if recast['theme']
        get_location(recast['attributes']) if recast['attributes']
        get_location(recast['temporal_modifier']) if recast['temporal_modifier'].is_a?(Hash)
        get_location(recast['at_location']) if recast['at_location'].is_a?(Hash)
      end

      # Helper to get the datetime of the sentence
      # Will be removed after the next JSON iteration! TODO
      def self.get_datetime(recast)
        if recast['entity'] == 'datetime'
          @datetime = recast['value']
        elsif recast['temporal_modifier'].is_a?(String)
          @datetime = recast['temporal_modifier']
        end

        return if @datetime

        get_datetime(recast['at_value']) if recast['at_value'].is_a?(Hash)
        get_datetime(recast['for']) if recast['for']
        get_datetime(recast['agent']) if recast['agent']
        get_datetime(recast['action']) if recast['action']
        get_datetime(recast['theme']) if recast['theme']
        get_datetime(recast['attributes']) if recast['attributes']
        get_datetime(recast['temporal_modifier']) if recast['temporal_modifier'].is_a?(Hash)
        get_datetime(recast['at_location']) if recast['at_location'].is_a?(Hash)
      end

      # Helper to get the duration from the sentence
      # Will be removed after the next JSON iteration! TODO
      def self.get_duration(recast)
        @duration = recast['value'] if recast['entity'] == 'duration'

        return if @duration

        get_duration(recast['at_value']) if recast['at_value'].is_a?(Hash)
        get_duration(recast['for']) if recast['for']
        get_duration(recast['agent']) if recast['agent']
        get_duration(recast['action']) if recast['action']
        get_duration(recast['theme']) if recast['theme']
        get_duration(recast['attributes']) if recast['attributes']
        get_duration(recast['temporal_modifier']) if recast['temporal_modifier'].is_a?(Hash)
        get_duration(recast['at_location']) if recast['at_location'].is_a?(Hash)
      end

      Commands::register("weather", self) if Config.google_key and ForecastIO.api_key
    end
  end
end
