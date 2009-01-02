require 'rwebunit'

spec "File attachment" do
  include RWebUnit::RSpecHelper

  @@test_page = File.join(File.dirname(File.expand_path(__FILE__)), "test_page.html")

  scenario "Upload file attachment" do
    open_browser("file://" + @@test_page)
    select_file_for_upload("upload", @@test_page)
    click_button_with_id("complete_btn")
    close_browser
  end

end
