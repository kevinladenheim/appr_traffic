#!/usr/bin/env ruby

require_relative "fetcher"


unless ARGV.length == 0
  print "No arguments\n\n"
  exit
end

@sym = {word: ARGV[0]}
report = Fetchers::Traffic.new(@sym)

report.fetch
message = report.message

print "\n\nHTTP Status: ", message, "\n\n"

if message.include? '404'
  print "Unknown Word\n\n"
  exit
end

print "Incidents:     ", report.data[:incidents], "\n"
print "\n\n"
