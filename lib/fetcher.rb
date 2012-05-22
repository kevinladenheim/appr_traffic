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
        #doc = Nokogiri.XML(body, nil, 'UTF-8') force encoding
        
        descs = []
        severities = []
        lats = []
        lons = []
        utcs = []        
        
        fullDesc = doc.xpath("//fullDesc")
        severity = doc.xpath("//severity")
        lat = doc.xpath("//lat")
        lon = doc.xpath("//lng")
        utc = doc.xpath("//startTime")
 
        incidents = fullDesc.length()

        while fullDesc.length() > 0
          descs << fullDesc.pop().inner_text()
          severities << severity.pop().inner_text()
          lats << lat.pop().inner_text()
          lons << lon.pop().inner_text()
          utcs << utc.pop().inner_text()
        end
     
        @data = { mq_incidents: incidents, 
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
        lat = doc.xpath("//xmlns:Latitude")
        lon = doc.xpath("//xmlns:Longitude")
        utc = doc.xpath("//xmlns:LastModifiedUTC")

        descs = []  
        severities = []
        lats = []
        lons = []
        utcs = []

        incidents = fullDesc.length()

        while fullDesc.length() > 0
          descs << fullDesc.pop().inner_text()
          severities << severity.pop().inner_text()
          lats << lat.pop().inner_text()
          lons << lon.pop().inner_text()
          utcs << utc.pop().inner_text()
        end

        @data = { bing_incidents: incidents,
            bing_descs: descs,
            bing_severities: severities,
            bing_latitudes: lats,
            bing_longitudes: lons,
            bing_utcs: utcs}
        end
      end
    end
 end




