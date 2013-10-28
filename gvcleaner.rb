require 'selenium-webdriver'

class GVCleaner

  GV_URL = 'https://www.google.com/voice#history/p10'
  TIMEOUT = 10 # seconds

  def initialize(email, password)
    @email = email
    @password = password
  end

  def clean
    @delete_count = 0
    @driver = Selenium::WebDriver.for :firefox
    @wait = Selenium::WebDriver::Wait.new(:timeout => TIMEOUT)

    @driver.manage.timeouts.implicit_wait = TIMEOUT
    @driver.navigate.to GV_URL
    login
    @driver.navigate.to GV_URL
    delete

    puts "Finished deleting #{@delete_count} pages of Google Voice history"
  end

  def has_message
    begin
      @wait.until { @driver.find_element(:xpath, '//*[@id="gc-message-list"]/div[contains(@class, "gc-message")]') }
      true
    rescue Selenium::WebDriver::Error::TimeOutError
      false
    end
  end

  def login
    @driver.find_element(:id, 'Email').send_keys @email
    @driver.find_element(:id, 'Passwd').send_keys @password
    @driver.find_element(:id, 'signIn').click
  end

  def delete
    while has_message do
      @driver.find_element(:xpath, '//*[@id="gc-appbar"]//div[@class="jfk-checkbox-checkmark"]').click
      @wait.until { @driver.find_element(:xpath, '//*[@id="gc-appbar"]//div[text()="Delete"]').displayed? }
      @driver.find_element(:xpath, '//*[@id="gc-appbar"]//div[text()="Delete"]').click
      @wait.until { !@driver.find_element(:xpath, '//*[@id="gc-appbar"]//div[text()="Delete"]').displayed? }
      @delete_count += 1
      puts "Deleted page #{@delete_count}"
    end
  end
end

if __FILE__ == $0
  unless (ARGV.count == 2)
    raise ArgumentError, 'Missing Argument(s). Pass the email address as the first argument and the password as the second'
  end

  gv_cleaner = GVCleaner.new(ARGV[0], ARGV[1])
  gv_cleaner.clean
end
