require "typhoeus"

class Base
  attr_reader :data, :message

  def initialize(cue)
    @cue = cue
    @success = false
    @message = ""
  end

  def success?
    @success
  end

  private

  def http_request(url,options = {})
    hydra = Typhoeus::Hydra.new
    request = Typhoeus::Request.new(url,options)

    request.on_complete do |response|
      if response.success?
        @success = true
        @message = "Request succeeded"
        yield response.body
      elsif response.timed_out?
        @message = "Request timed out for #{url}"
      elsif response.code == 0
        @message = response.curl_error_message
      else
        @message = "HTTP request failed for #{url}: " + response.code.to_s
      end
    end

    hydra.queue(request)
    hydra.run
  end
end
