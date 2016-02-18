#!/usr/bin/env ruby

require 'httpclient'

config = {
  :threads => 4,
  :first => 'mHHi0',
  :last => 'mHHi9',
  :command => 'echo ""; wget -nv %url% -O %id%.%extension%'
}

http_client = HTTPClient.new(
    :agent_name => 'Mozilla/5.0 (compatible; Googlebot-Image/1.01; +http://www.google.com/bot.html)'
)
http_client.cookie_manager = nil

targets = (config[:first]...config[:last].next!).to_a

threads_pull = []
config[:threads].times do
  threads_pull << Thread.new do
    until targets.empty?
      id = targets.pop
      url = 'http://puu.sh/'+id
      
      begin
        resp = http_client.head(url)
      rescue
        puts 'Status: '+resp.status.to_s+' (error) URL: '+url
        next
      end


      image_type = resp.contenttype.split('/')[1]

      if image_type != 'html'
        puts '[+] Status: '+resp.status.to_s+' Content-Type: '+resp.contenttype+' URL: '+url
        shell_command = config[:command].clone
        shell_command.sub! '%url%', url
        shell_command.sub! '%id%', id
        shell_command.sub! '%extension%', image_type

        `#{shell_command}`
      else
        puts '[-] Status: '+resp.status.to_s+' Content-Type: '+resp.contenttype+' URL: '+url
      end

    end
  end
end

threads_pull.each { |t| t.join }