=begin
  ** FindTheProblems **
  A Simple Ruby -> Prowl Site Monitor
  
  Copyright (c) 2009 Matthew Riley MacPherson (http://lonelyvegan.com)
  
  Released under an MIT-style License. See LICENSE.txt for the actual license text.
  This software uses my modified version of August Lilleaas's Prowl Library, also MIT-licensed
=end

$LOAD_PATH << File.expand_path("#{File.dirname(__FILE__)}/lib/prowl")

require 'net/https'
require 'prowl'
require 'uri'

# Put the URLs of sites you'd like to check in here.
Sites_To_Check = [
  'http://lonelyvegan.com',
]

# Prowl settings (See ./lib/prowl/lib/README and http://prowl.weks.net/api.php for more info)
Prowl_API_Keys = [
  # Put your API key here. If you want a few people to get notifications
  # that's cool: you can put up to five (5) API keys in here
  'REPLACE_ME_WITH_YOUR_PROWL_API_KEY(s)'
]
Priority = 2 # Priority can be -2..2
Provider_Key = '' # OPTIONAL: You can fill this in if you have a whitelisted provider key

# How many redirects should be followed before we give up?
Max_Redirects = 3

# You can stop editing now.

# Some silly constants
App_Name = 'FindTheProblems'
Error_SiteIsDown = 'Site is down'
Error_Timeout = 'Timed out'
Error_TooManyRedirects = 'Too many redirects'
User_Agent = App_Name + ': A Simple Ruby -> Prowl Site Monitor (http://github.com/tofumatt/FindTheProblems)'
Timeout_In_Seconds = 25

# Setup Prowl
@prowl = Prowl.new(
  :application => App_Name,
  :providerkey => Provider_Key,
  :priority => Priority,
  :apikey => Prowl_API_Keys
)

# Take a URL and perform a GET request on it. If we return a 2xx HTTP Status Code
# then we consider it a win; otherwise, return an error.
def check_site(url, redirects=0, original_url=nil)
  uri = URI.parse(url)
  
  # Build up our little HTTP request
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = Timeout_In_Seconds
  http.use_ssl = (url.index('https://') == 0) ? true : false;
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
  # Try to GET the URL. If we can't, let's say the site is down
  begin
    response = http.get(uri.request_uri, {'User-Agent' => User_Agent})
  rescue Errno::ETIMEDOUT
    error(url, Error_Timeout)
  end
  
  # Check the response
  case response
    # 2xx status code: It worked!
    when Net::HTTPSuccess then
      return
    # It's a redirect; increment our redirect counter
    when Net::HTTPRedirection then
      redirects+=1
      
      # We allow redirects, but if there are too many redirects, return an error
      error(original_url, Error_TooManyRedirects) if redirects > Max_Redirects
      
      # Otherwise, follow the redirect
      check_site(response['location'], redirects, url)
    # The site returned a non-2xx/redirect status code -- it's down :-(
    else
      error(url, Error_SiteIsDown)
    end
end

# Send out an error notification via Prowl
def error(url, error)
  # Other than ruby-prowl's own error handling, there isn't much in the way of
  # error handling here yet
  @prowl.add(:event => error, :description => url)
end

# Fun with threads; HTTP lib is thread-safe, so we'll make checking
# all these sites a bit more concurrent...
threads = []
for site in Sites_To_Check
  threads << Thread.new(site) { |s|
    check_site(s)
  }
end

# Stitch 'em back together...
threads.each { | thread | thread.join }