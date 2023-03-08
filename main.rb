#!/usr/bin/env ruby

require 'httpclient'

THREAD_COUNT = 4
FIRST_ID = 'mHHi0'
LAST_ID = 'mHHi9'
COMMAND_TEMPLATE = 'echo ""; wget -nv %<url>s -O %<id>s.%<extension>s'.freeze

http_client = HTTPClient.new(agent_name: 'Mozilla/5.0 (compatible; Googlebot-Image/1.01; +http://www.google.com/bot.html)')
http_client.cookie_manager = nil

ids = (FIRST_ID..LAST_ID).to_a

threads = Array.new(THREAD_COUNT) do
  Thread.new do
    until ids.empty?
      id = ids.pop
      url = "http://puu.sh/#{id}"
      
      begin
        response = http_client.head(url)
      rescue HTTPClient::BadResponseError => e
        puts "Status: #{e.res.status_code} (error) URL: #{url}"
        next
      end

      if response.contenttype.split('/')[0] == 'image'
        puts "[+] Status: #{response.status_code} Content-Type: #{response.contenttype} URL: #{url}"

        command = format(COMMAND_TEMPLATE, url: url, id: id, extension: response.contenttype.split('/')[1])
        system(command)
      else
        puts "[-] Status: #{response.status_code} Content-Type: #{response.contenttype} URL: #{url}"
      end
    end
  end
end

threads.each(&:join)
