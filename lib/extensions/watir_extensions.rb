##  
# Watir's click_no_wait won't work without the line below in TestWise
#
# The idea is set to load rubygems correctly when invoke system("ruby") 
# in the framework
ENV["RUBYOPT"] = "-rubygems"