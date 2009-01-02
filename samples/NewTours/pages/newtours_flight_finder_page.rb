
class NewtoursFlightFinderPage < RWebUnit::AbstractWebPage

  def initialize(browser)
    super(browser, "Use our Flight Finder")
  end

  def select_departing_from(depart_from)
    select_option("fromPort", depart_from)
  end

  def select_departing_month(depart_month)
    select_option("fromMonth", depart_month)
  end

  def select_departing_day(depart_day)
    select_option("fromDay", depart_day)
  end

  def select_arriving_in(arriving_in)
    select_option("toPort", arriving_in)
  end

  def select_returning_month(return_month)
    select_option("toMonth", return_month)
  end

  def select_returning_day(return_day)
    select_option("toDay", return_day)
  end

  def select_service_class(service_class)
    click_radio_option("servClass", service_class)
  end

  def click_continue
    click_button_with_image("continue.gif")
    expect_page NewtoursSelectFlightPage
  end

end
