#!/usr/bin/env ruby

require_relative "fetcher"


unless ARGV.length == 4
  print "Four arguments: lat1 lon1 lat2 lon2\n"
  print "Example: 39.0 -77.0 40.0 -76.0\n\n"
  exit
end

@lat1 = ARGV[0]
@lon1 = ARGV[1]
@lat2 = ARGV[2]
@lon2 = ARGV[3]

report = Fetchers::Traffic.new(@lat1, @lon1, @lat2, @lon2)

def dump(incidents, severities, descriptions)
  for i in 0..incidents - 1
    print "%2d==> (%s) " % [i, severities[i]]
    print descriptions[i], "\n"
  end
end

report.fetch_mq
dump(report.data[:mq_incidents], report.data[:mq_severities], report.data[:mq_descs]) 
print "\n\n"

report.fetch_bing
dump(report.data[:bing_incidents], report.data[:bing_severities], report.data[:bing_descs]) 
print "\n\n"

#message = report.message

#print "\n\nHTTP Status: ", message, "\n\n"

#if message.include? '404'
#  print "Unknown Word\n\n"

#end

#print "Mapquest desc: ", report.descs[1]

