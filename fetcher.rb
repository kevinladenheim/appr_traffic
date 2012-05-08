require_relative "base"
require "nokogiri"

module Fetchers
   class Traffic < Base
    BASE_URL = "http://www.mapquestapi.com"
    API_KEY = "Fmjtd%7Cluua2d6bl9%2Can%3Do5-hrr0d"


    def fetch
      http_request("#{BASE_URL}/traffic/v1/incidents?key=#{API_KEY}&callback=handleIncidentsResponse&boundingBox=39.503136,\
-76.887259,39.077998,-76.337942&filters=construction,incidents&inFormat=kvp&outFormat=xml") do |body|
        doc = Nokogiri::XML(body) 
      
        #doc = Nokogiri::XML(File.open(body)) do |config|
        #  config.options = Nokogiri::XML::ParseOptions.STRICT | Nokogiri::XML::ParseOptions.NOENT
        #end

        severity = doc.xpath("//severity")
        fullDesc = doc.xpath("//fullDesc")        
        
        # this is bad, regexp would be better, what's best?

        print "\n\n"

        for i in 0..fullDesc.length - 1
          severities = severity[i].to_s.sub("<severity>","").sub("</severity>","")
          full_descs = fullDesc[i].to_s.sub("<fullDesc>", "").sub("</fullDesc>", "")

          print "%2d==> (%s) " % [i, severities]
          print full_descs, "\n"
        end
                
        @data = {
          incidents: fullDesc.length,
        }

      end
    end
  end
end



