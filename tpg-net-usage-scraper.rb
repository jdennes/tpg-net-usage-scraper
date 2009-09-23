
# Scrapes the TPG Internet site to retrieve usage stats for a DSL account
# Usage: ruby tpg-net-usage-scraper.rb username password

# Ensure that the mechanize gem is installed
# and that you have libxml2 version > 2.6.16 (preferably the latest)

require 'rubygems'
require 'mechanize'

login_url = 'https://cyberstore.tpg.com.au/your_account/index.php'
agent = WWW::Mechanize.new

agent.get(login_url) do |page|
  page.encoding = 'UTF-8'
  account_page = page.form_with(:name => 'form') do |login|
    login.check_username = ARGV[0]
    login.password       = ARGV[1]
  end.click_button

  usage_page = agent.click(account_page.link_with(
    :href => '/your_account/index.php?function=checkaccountusage'))

  # TODO: To be continued... parsing of usage page...
  pp usage_page

end
