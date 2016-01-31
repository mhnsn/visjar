require 'httparty'
require 'json'

module Visjar
  module Commands
    class Eat
      def self.run(client, slack, recast)
        recast    = recast['sentences'].first

        # Get informations about the request
        @location = recast['entities']['location'].first['value'] rescue nil
        @sort     = recast['entities']['sort'].first['value']     rescue nil
        @type     = get_type(recast['source'])

        # If no location/type found, use the default.
        @location = Config.location if @location == nil
        @type     = 'restaurant'    if @type == nil

        response = JSON.parse(HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{@location.gsub(/\s+/, '+')}&key=#{Config.google_key}").body)
        if response["status"] == 'OK'
          p1 = response['results'].first['geometry']['location']

          # Notify the user of the current research.
          client.send_message(slack['channel'], "Looking for #{@sort == nil ? '' : "the #{@sort}"} #{@type.pluralize} in a 1km radius around #{@location.titleize}.")

          # Perfom the places search.
          if @type == 'restaurant'
            response = JSON.parse(HTTParty.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{p1['lat']},#{p1['lng']}&radius=1000&types=food&key=#{Config.google_key}").body)
          else
            response = JSON.parse(HTTParty.get("https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{@type}&location=#{p1['lat']},#{p1['lng']}&radius=1000&types=food&key=#{Config.google_key}").body)
          end

          if response["status"] == 'OK'
            # Sort by the criterion of the user
            case @sort
            when 'best', 'most popular'
              response['results'].sort_by!{ |a| a['rating'] ? a['rating'] : -10 }.reverse!
            when 'worst', 'least popular'
              response['results'].sort_by!{ |a| a['rating'] ? a['rating'] : 10 }
            when 'costliest', 'fanciest', 'most expensive'
              response['results'].sort_by!{ |a| a['price_level'] ? a['price_level'] : -10 }.reverse!
            when 'cheapest', 'least expensive', 'most affordable'
              response['results'].sort_by!{ |a| a['price_level'] ? a['price_level'] : 10 }
            else
              response['results'].shuffle!
            end

            found = 0
            response['results'].each do |restau|
              p2 = {'lat' => restau['geometry']['location']['lat'], 'lng' => restau['geometry']['location']['lng']}

              rating = "#{restau['rating'] ? restau['rating'].to_f.round : '?'}/5"
              client.send_message(slack['channel'], "*#{restau['name']}*\n #{rating} (<https://maps.googleapis.com/maps/api/staticmap?size=600x300&maptype=roadmap&markers=color:green%7Clabel:A%7C#{p2['lat']},#{p2['lng']}&key=#{Config.google_key}|map>)", {unfurl_media: false})

              found += 1
              break if found >= Config.limit_eat
            end
          else
            client.send_message(slack['channel'], "Sorry, I could not find any restaurant near #{@location}...")
          end
        else
          client.send_message(slack['channel'], "Mmh, the location you asked for don't seem to exist...")
        end
      end

      # Helper to get the type criterion
      def self.get_type(sentence)
        sentence.split(/\s+|\;|\,}\:|\(|\)/).each do |w|
          return w if Utils::TYPES.include?(w.downcase)
        end

        nil
      end

      Commands::register("eat", self) if Config.location and Config.google_key and Config.google_key and Config.limit_eat != nil
    end
  end
end
