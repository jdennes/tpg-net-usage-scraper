
# Scrapes the TPG Internet site to retrieve usage stats for a DSL account
# Usage: ruby tpg-net-usage-scraper.rb username password

# Ensure that the mechanize and hpricot gems are installed
# and that you have libxml2 version > 2.6.16 (preferably the latest)

require 'rubygems'
require 'mechanize'
require 'hpricot'
require 'highline/import'

# Encapsulates login and scraping functionality
class TPGInternetUsageScraper
  
  attr_accessor :doc, :username, :password

  def initialize(username, password)
    @username = username
    @password = password
  end

  # Encapsulates the process of scraping  
  def scrape
    if self.login(@username, @password)
      package = self.get_package(@doc)
      puts '-----------------------------------------------------------------------'
      puts "Current usage for '#{@username}' using #{package}"
      puts '-----------------------------------------------------------------------'
      puts self.get_usage_stats(@doc)
      puts '-----------------------------------------------------------------------'
    else
      puts "Sorry, login to TPG Internet for #{@username} failed!"
    end
  end

  # Login and get the doc to parse
  def login(username, password)
    login_url = 'https://cyberstore.tpg.com.au/your_account/index.php'
    agent = WWW::Mechanize.new
    agent.get(login_url) do |page|
      page.encoding = 'UTF-8'
      account_page = page.form_with(:name => 'form') do |login|
        login.check_username = username
        login.password       = password
      end.click_button
      begin
        usage_page = agent.click(account_page.link_with(
          :href => '/your_account/index.php?function=checkaccountusage'))
        # It seems easier to use hpricot directly here, than the built-in mechanize stuff
        @doc = Hpricot(usage_page.body)
      rescue
        return false
      end
      return true
    end
  end

  # Get the ADSL package from the doc
  def get_package(doc) 
    return doc.search("//table[@class='light_box']/tr/td")[4].innerHTML.html_strip
  end

  # Get the stats from the doc  
  def get_usage_stats(doc)
    return doc.search("//table[@class='light_box']/tr/td")[8].innerHTML.gsub('<br />', "\n").html_strip
  end
end

class String
  def html_strip()
    return self.gsub(/<\/?[^>]*>/, "")
  end
end

# Where everything begins...
if __FILE__ == $0
  puts '-----------------------------------------------------------------------'
  puts 'TPG Internet Usage Scraper - alpha'
  puts '-----------------------------------------------------------------------'
  if ARGV.length == 2
    username = ARGV[0]
    password = ARGV[1]
  else 
    username = ask('Username: ')
    password = ask('Password: ') { |q| q.echo = false }
  end
  scr = TPGInternetUsageScraper.new(username, password)
  scr.scrape
end
