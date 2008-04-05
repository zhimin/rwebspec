#***********************************************************
#* Copyright (c) 2006, 2007 Zhimin Zhan.
#* Distributed open-source, see full license in MIT-LICENSE
#***********************************************************

module RWebUnit

  ##
  #  Store test optionns
  #
  class TestContext
    attr_accessor :base_url

    def initialize(base_url)
      set_base_url(base_url)
    end

    def set_base_url(baseUrl)
      @base_url = baseUrl
    end

  end

end
