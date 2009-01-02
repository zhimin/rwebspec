class RegistrationPage < BasePublicPage

  def initialize(browser, text='Sign up:')
    super(browser, text)
  end

  def enter_first_name(first_name)
    enter_text("player[first_name]", first_name)
  end

  def enter_last_name(last_name)
    enter_text("player[last_name]", last_name)
  end

  def enter_birthdate(birth_date)
    enter_text("player[birth_date]", birth_date)
  end

  def select_club(club)
    select_option("player[belonging_club_id]", club)
  end

  def enter_address(address_line1, suburb, state, postcode)
    enter_text("player[address_line1]", address_line1)
    enter_text("player[suburb]", suburb)
    select_option("player[state]", state)
    enter_text("player[postcode]", postcode)
  end

  def select_category(category)
    select_option("player[player_category]", category)
  end

  def enter_email(email)
    enter_text("player[email]", email)
  end

  def click_signup
    click_button_with_text("Signup")
    expect_page RegistrationConfirmPage
  end


  # select_option("player[belonging_club_id]","Rockets")
  # enter_text("player[birth_date]", "10/07/1998")
  # enter_text("player[email]", "bob@mysportsworx.com")
  # enter_text("player[address_line1]", "40 Pember Street")
  # enter_text("player[suburb]", "Sunnybank")
  # enter_text("player[postcode]", "4109")
  # click_button_with_text("Signup")

end