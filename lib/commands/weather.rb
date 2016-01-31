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
        recast    = recast['sentences'].first

        # Get informations about the request
        @location = recast['entities']['location'].first['value'] rescue nil
        @datetime = recast['entities']['datetime'].first['value'] rescue nil
        @duration = recast['entities']['duration'].first['value'] rescue nil

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
          client.send_message(slack['channel'], "Mmh, the location you asked for don't seem to exist...")
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

      Commands::register("weather", self) if Config.google_key and ForecastIO.api_key
    end
  end
end
