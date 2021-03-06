# make sure we're running inside Merb
if defined?(Merb::Plugins)

  require 'liquid'
  require File.join(File.dirname(__FILE__), "merb_liquid", "liquid")
  
  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:liquid] = {
    :chickens => false
  }
  
  Merb::BootLoader.before_app_loads do
    # require code that must be loaded before the application
  end
  
  Merb::BootLoader.after_app_loads do
    # code that can be required after the application loads
  end
  
  Merb::Plugins.add_rakefiles "merb_liquid/merbtasks"
end