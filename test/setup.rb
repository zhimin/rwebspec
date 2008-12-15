require 'firewatir'

$loaded = false
unless $loaded
  sample_html = "file://" + File.expand_path(File.dirname(__FILE__) + "/test.html")
  $firefox = FireWatir::Firefox.new
  $firefox.goto(sample_html)
  $web_browser = RWebUnit::WebBrowser.new("test", $firefox,  :firefox => true)
  $loaded = true
end
