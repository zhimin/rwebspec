# load File.dirname(__FILE__) + '/maybe_your_template_page.rb'

class NewtoursBookFlightPage < RWebUnit::AbstractWebPage

  def initialize(browser)
    super(browser, "Please review your")
  end

  def enter_first_name(first_name)
    enter_text("passFirst0", first_name)
  end

  def enter_last_name(last_name)
    enter_text("passLast0", last_name)
  end

  def enter_credit_card_number(credit_card_number)
    enter_text("creditnumber", credit_card_number)
  end

  def check_ticketless_travel
    check_checkbox("ticketLess", "checkbox")
  end

  def click_secure_purchase
    click_button_with_image("purchase.gif")
  end

  
end
