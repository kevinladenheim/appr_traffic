#!/usr/bin/env ruby

require_relative "fetcher"


unless ARGV.length == 4
  print "Four arguments: lat1 lon1 lat2 lon2\n"
  print "Example: 39.0 -77.0 40.0 -76.0\n\n"
  exit
end

# to do: bounds check args
@lat1 = ARGV[0]
@lon1 = ARGV[1]
@lat2 = ARGV[2]
@lon2 = ARGV[3]

def dump(incidents, severities, descriptions, latitudes, longitudes, utcs)
  for i in 0..incidents - 1
    print "%2d (%2.2f,%2.2f) [%s] ==> (%s) " % [i, latitudes[i], longitudes[i], utcs[i], severities[i]]
    print descriptions[i], "\n"
  end
end

report = Fetchers::Traffic.new(@lat1, @lon1, @lat2, @lon2)

# is it better to have a def dump(report) and hide all this?
report.fetch_mq
print "\nStatus: ", report.message, " ", report.code, "\n\n"
dump(report.data[:mq_incidents], report.data[:mq_severities], report.data[:mq_descs], report.data[:mq_latitudes], report.data[:mq_longitudes], report.data[:mq_utcs]) 
print "\n\n"

report.fetch_bing
print "\nStatus: ", report.message, " ", report.code, "\n\n"
dump(report.data[:bing_incidents], report.data[:bing_severities], report.data[:bing_descs], report.data[:bing_latitudes], report.data[:bing_longitudes], report.data[:bing_utcs]) 
print "\n\n"



