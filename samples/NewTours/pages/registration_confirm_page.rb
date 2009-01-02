
class RegistrationConfirmPage < BasePublicPage

  def initialize(browser, text='Confirm your details')
    super(browser)
  end

  def click_radio_photo_permission(choice = "yes")
    click_radio_option("photo_permission", choice.downcase)
  end

  def click_radio_privacy_access(choice = "yes")
    click_radio_option("privacy_access", choice.downcase)
  end

  def accpet_terms_and_conditions
    check_checkbox("accept")
  end

  def click_confirm
    click_button_with_text("Confirm")
  end
end
