#!/usr/bin/env ruby

require 'optparse'
require 'httpclient'

options = {
  threads: 4,
  first_id: 'mHHi0',
  last_id: 'mHHi9',
  command_template: 'echo ""; wget -nv %<url>s -O %<id>s.%<extension>s'
}

OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options]"

  opts.on('-t', '--threads COUNT', Integer, "Number of threads to use (default: #{options[:threads]})") do |t|
    options[:threads] = t
  end

  opts.on('-f', '--first-id ID', "First ID to check (default: #{options[:first_id]})") do |id|
    options[:first_id] = id
  end

  opts.on('-l', '--last-id ID', "Last ID to check (default: #{options[:last_id]})") do |id|
    options[:last_id] = id
  end

  opts.on('-c', '--command TEMPLATE', "Command template to execute (default: #{options[:command_template]})") do |template|
    options[:command_template] = template
  end
end.parse!

http_client = HTTPClient.new(agent_name: 'Mozilla/5.0 (compatible; Googlebot-Image/1.01; +http://www.google.com/bot.html)')
http_client.cookie_manager = nil

ids = (options[:first_id]..options[:last_id]).to_a

threads = Array.new(options[:threads]) do
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

        command = format(options[:command_template], url: url, id: id, extension: response.contenttype.split('/')[1])
        system(command)
      else
        puts "[-] Status: #{response.status_code} Content-Type: #{response.contenttype} URL: #{url}"
      end
    end
  end
end

threads.each(&:join)
