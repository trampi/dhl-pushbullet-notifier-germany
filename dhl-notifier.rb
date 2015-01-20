#!/usr/bin/env ruby
require 'mechanize'
require 'optparse'

options = {
    sleep: 1800
}

optparse = OptionParser.new do |opts|
  opts.on(:REQUIRED, '-p TOKEN', '--pushsbullet-token TOKEN', 'Your pushbullet api token') do |token|
    options[:pushbullet_token] = token
  end

  opts.on(:REQUIRED, '-r REFERENCE', '--reference-number REFERENCE', 'Your DHL reference number') do |token|
    options[:reference_number] = token
  end

  opts.on(:REQUIRED, '-s SLEEP', '--sleep SLEEP', Integer, 'Interval between two checks for status updates (default 30 minutes)') do |token|
    options[:sleep] = token
  end

  opts.on(:NONE, '--test-pushbullet', 'Push a test notification and exit') do
    options[:test_pushbullet] = true
  end

  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end


def pushbullet_notification title, text, api_token
  uri = URI.parse('https://api.pushbullet.com/v2/pushes')
  header = {'Content-Type' => 'application/json'}
  push = {
      :type => 'note',
      :title => title,
      :body => text
  }

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.request_uri, header)
  request.basic_auth(api_token, '')
  request.body = push.to_json

  http.request(request)
end

def get_dhl_delivery_state reference_number
  puts 'Fetching now... ' + DateTime.now.to_s
  mechanize = Mechanize.new
  page = mechanize.get("http://nolp.dhl.de/nextt-online-public/set_identcodes.do?runtime=standalone&idc=#{reference_number}")
  node = page.at('.accordion-inner tr:last td:last')
  if node.nil?
    return ''
  else
    return node.text.strip
  end
end

optparse.parse!

if options.key?(:pushbullet_token) && options.key?(:test_pushbullet)
  http_response = pushbullet_notification 'Test notification from dhl-notifier', 'Pushbullet works!', options[:pushbullet_token]

  if http_response.code == '200'
    puts 'Notification sent successfully.'
  else
    puts 'Error sending notification. Pushbullet returned: '
    puts http_response.message
    puts http_response.body
  end
elsif options.key?(:pushbullet_token) && options.key?(:reference_number)

  current_state = get_dhl_delivery_state options[:reference_number]
  if current_state == ''
    puts 'The given tracking number is not yet trackable.'
    exit
  else
    puts 'Found your tracking number. Updates will be pushed via pushbullet.'
    puts 'Please note that this program will not terminate.'
  end

  while true do
    sleep(options[:sleep])
    new_state = get_dhl_delivery_state options[:reference_number]
    if current_state != new_state
      puts 'Update found, notifying via pushbullet ...'
      puts "New state: #{new_state}"
      pushbullet_notification 'dhl state updated', "#{new_state}, was #{current_state}", options[:pushbullet_token]
      current_state = new_state
    else
      puts 'no update found'
    end
  end
else
  puts "Please provide the TOKEN and the dhl REFERENCE to check.\n"
  puts optparse.help
end
