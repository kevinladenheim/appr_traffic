require_relative "base"
require "nokogiri"

module Fetchers
   class Traffic < Base
    MQ_BASE_URL = "http://www.mapquestapi.com"
    BING_BASE_URL = "http://dev.virtualearth.net"

    def initialize(lat1, lon1, lat2, lon2)
      @lat1 = lat1; 
      @lon1 = lon1; 
      @lat2 = lat2; 
      @lon2 = lon2;

      # is this the perfect place to read in keys or an evil place?
      # todo: make each line easily parseable key/value pair so order doesn't matter
      keys = IO.readlines("../keys.txt")

      @mq_api_key = keys[0].strip!
      @bing_api_key = keys[1].strip!      
    end

    # needs to catch error when request fails
    def fetch_mq
        http_request("#{MQ_BASE_URL}/traffic/v1/incidents?key=#{@mq_api_key}&callback=handleIncidentsResponse&boundingBox=#{@lat1},\
#{@lon1},#{@lat2},#{@lon2}&filters=construction,incidents&inFormat=kvp&outFormat=xml") do |body|
        doc = Nokogiri::XML(body) 
      
        # is it possible to supress the tags?
        severity = doc.xpath("//severity")
        fullDesc = doc.xpath("//fullDesc")
        lat = doc.xpath("//lat")
        lon = doc.xpath("//lng")
        utc = doc.xpath("//startTime")
        
        print "\n\n"

        descs = []
        severities = []
        lats = []
        lons = []
        utcs = []

        for i in 0..fullDesc.length - 1
          # both approaches seem too complicated          
          # if there are zero tag matches --> crash
          severities[i] = /.*<severity>(.*)<\/severity>.*/.match(severity[i].to_s)[1]  
          descs[i] = /.*<fullDesc>(.*)<\/fullDesc>.*/.match(fullDesc[i].to_s)[1]
          lats[i] = /.*<lat>(.*)<\/lat>.*/.match(lat[i].to_s)[1]
          lons[i] = /.*<lng>(.*)<\/lng>.*/.match(lon[i].to_s)[1]
          utcs[i] = /.*<startTime>(.*)<\/startTime>.*/.match(utc[i].to_s)[1]

          #severities[i] = severity[i].to_s.sub("<severity>","").sub("</severity>","")
          #descs[i] = fullDesc[i].to_s.sub("<fullDesc>", "").sub("</fullDesc>", "")          
        end
               
        @data = { mq_incidents: fullDesc.length, 
          mq_descs: descs,  
          mq_severities: severities,
          mq_latitudes: lats,
          mq_longitudes: lons, 
          mq_utcs: utcs }
        end 
      end


      def fetch_bing
        http_request("#{BING_BASE_URL}/REST/V1/Traffic/Incidents/#{@lat1},#{@lon1},#{@lat2},#{@lon2}/?&o=xml&key=#{@bing_api_key}") do |body|
        doc = Nokogiri::XML(body) 

        # the mapquest data didn't need a fully qualified XML namespace, 
        # maybe because it didn't define one like the bing data does
        severity = doc.xpath("//xmlns:Severity")
        fullDesc = doc.xpath("//xmlns:Description")
        latitude = doc.xpath("//xmlns:Latitude")
        longitude = doc.xpath("//xmlns:Longitude")
        utc = doc.xpath("//xmlns:LastModifiedUTC")

        descs = []  
        severities = []
        lats = []
        lons = []
        utcs = []

        for i in 0..fullDesc.length - 1
          severities[i] = severity[i].to_s.sub("<Severity>","").sub("</Severity>","")
          descs[i] = fullDesc[i].to_s.sub("<Description>", "").sub("</Description>", "")
          lats[i] = latitude[i].to_s.sub("<Latitude>","").sub("</Latitude>","")
          lons[i] = longitude[i].to_s.sub("<Longitude>","").sub("</Longitude>","")
          utcs[i] = utc[i].to_s.sub("<LastModifiedUTC>","").sub("</LastModifiedUTC>","")
        end

        @data = { bing_incidents: fullDesc.length,
            bing_descs: descs,
            bing_severities: severities,
            bing_latitudes: lats,
            bing_longitudes: lons,
            bing_utcs: utcs}
        end
      end
    end
 end




