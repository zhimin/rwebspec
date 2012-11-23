#***********************************************************
#* Copyright (c) 2006 - 2009 Zhimin Zhan.
#* Distributed open-source, see full license in MIT-LICENSE
#***********************************************************

module RWebSpec

  ##
  #  Store test optionns
  #
  class Context
    attr_accessor :base_url

    def initialize(base_url)
      set_base_url(base_url)
    end

    def set_base_url(baseUrl)
      @base_url = baseUrl
    end

  end

end
