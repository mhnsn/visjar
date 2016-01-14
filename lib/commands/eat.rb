require 'httparty'
require 'json'

module Visjar
  module Commands
    class Eat
      def self.run(client, slack, recast)
        @location = nil
        @sort     = nil
        @type     = nil
        recast    = recast['intents'].first

        # Get informations about the request
        get_location(recast)
        get_sort(recast)
        get_type(recast)

        # If no location/type found, use the default.
        @location = Config.location if @location == nil
        @type     = 'restaurant' if @type == nil

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
          client.send_message(slack['channel'], "Sorry, I didn't understood the location you asked for...")
        end
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

      # Helper to get the sort criterion
      # Will be removed after the next JSON iteration! TODO
      def self.get_sort(recast)
        @sort = recast['value'] if recast['entity'] == 'sort'

        return if @sort

        get_sort(recast['at_value']) if recast['at_value'].is_a?(Hash)
        get_sort(recast['for']) if recast['for']
        get_sort(recast['agent']) if recast['agent']
        get_sort(recast['action']) if recast['action']
        get_sort(recast['theme']) if recast['theme']
        get_sort(recast['attributes']) if recast['attributes']
        get_sort(recast['temporal_modifier']) if recast['temporal_modifier'].is_a?(Hash)
        get_sort(recast['at_location']) if recast['at_location'].is_a?(Hash)
      end

      # Helper to get the type criterion
      # Will be removed after the next JSON iteration! TODO
      def self.get_type(recast)
        if recast['entity'] == 'list'
          recast['values'].each do |v|
            @type = v['value'] if Utils::TYPES.include?(v['value'])
          end
        else
          @type = recast['value'] if Utils::TYPES.include?(recast['value'])
        end

        return if @type

        get_type(recast['at_value']) if recast['at_value'].is_a?(Hash)
        get_type(recast['for']) if recast['for']
        get_type(recast['agent']) if recast['agent']
        get_type(recast['action']) if recast['action']
        get_type(recast['theme']) if recast['theme']
        get_type(recast['attributes']) if recast['attributes']
        get_type(recast['temporal_modifier']) if recast['temporal_modifier'].is_a?(Hash)
        get_type(recast['at_location']) if recast['at_location'].is_a?(Hash)
      end

      Commands::register("eat", self) if Config.location and Config.google_key and Config.google_key and Config.limit_eat != nil
    end
  end
end
