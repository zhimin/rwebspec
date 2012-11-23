module Selenium
  module WebDriver
		class Element
			def exists?
				self.displayed?
			end
		end
	end
end