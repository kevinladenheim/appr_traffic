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
      # to do: make each line easily parseable key/value pair so order doesn't matter
      keys = IO.readlines("keys.txt")

      @mq_api_key = keys[0].strip!
      @bing_api_key = keys[1].strip!      
    end

    def fetch_mq
      http_request("#{MQ_BASE_URL}/traffic/v1/incidents?key=#{@mq_api_key}&callback=handleIncidentsResponse&boundingBox=#{@lat1},\
#{@lon1},#{@lat2},#{@lon2}&filters=construction,incidents&inFormat=kvp&outFormat=xml") do |body|
        doc = Nokogiri::XML(body) 
      
        severity = doc.xpath("//severity")
        fullDesc = doc.xpath("//fullDesc")

        print "\n\n"

        descs = []
        severities = []

        for i in 0..fullDesc.length - 1
          # this is bad, regexp would be better, what's best?
          severities[i] = severity[i].to_s.sub("<severity>","").sub("</severity>","")
          descs[i] = fullDesc[i].to_s.sub("<fullDesc>", "").sub("</fullDesc>", "")
        end
        
        # is data a keyword?
        @data = { mq_incidents: fullDesc.length, mq_descs: descs, mq_severities: severities}
        end 
     end


      def fetch_bing
        http_request("#{BING_BASE_URL}/REST/V1/Traffic/Incidents/#{@lat1},#{@lon1},#{@lat2},#{@lon2}/?&o=xml&key=#{@bing_api_key}") do |body|
        doc = Nokogiri::XML(body) 

        # the mapquest data didn't need a fully qualified XML namespace, 
        # maybe because it didn't define one like the bing data does
        severity = doc.xpath("//xmlns:Severity")
        fullDesc = doc.xpath("//xmlns:Description")        

        descs = []  
        severities = []

        for i in 0..fullDesc.length - 1
          severities[i] = severity[i].to_s.sub("<Severity>","").sub("</Severity>","")
          descs[i] = fullDesc[i].to_s.sub("<Description>", "").sub("</Description>", "")
        end

        @data = { bing_incidents: fullDesc.length, bing_descs: descs, bing_severities: severities}
      end
      end
    end
 end




