require 'redmine'

Redmine::Plugin.register :stuff_to_do_plugin do
  name 'Stuff To Do Plugin'
  author 'Eric Davis'
  description "The Stuff To Do plugin allows a user to order and prioritize the issues they are doing into a specific order. It will also allow other privilged users to reorder the user's workload."
  version '0.1.0'

  menu(:top_menu, :stuff_to_do, {:controller => "stuff_to_do", :action => 'index'}, :caption => :stuff_to_do_title)
  

end

