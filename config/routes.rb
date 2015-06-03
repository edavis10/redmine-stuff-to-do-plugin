# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

if Rails::VERSION::MAJOR >= 3
  RedmineApp::Application.routes.draw do
    match 'stuff_to_do', :to => 'stuff_to_do#index', :via => 'get'
    match 'stuff_to_do/:action.:format', :controller => 'stuff_to_do', :via => [:get, :post]
  end
  match '/stuff_to_do/add', :to => 'stuff_to_do#add', :via =>  [:get, :post]
  match '/stuff_to_do/delete', :to => 'stuff_to_do#delete', :via =>  [:get, :post]
  match '/stuff_to_do/reportees', :to=> 'stuff_to_do_reportee#index', :via => 'get'
  match '/stuff_to_do/reportees_admin', :to=> 'stuff_to_do_reportee#admin', :via => 'get'
  match '/stuff_to_do/reportees/add', :to=> 'stuff_to_do_reportee#add', :via => [:get, :post]
  match '/stuff_to_do/reportees/delete', :to=> 'stuff_to_do_reportee#delete', :via => [:get, :post]
else
  ActionController::Routing::Routes.draw do |map|
    map.with_options :controller => 'stuff_to_do' do |stuff_routes|
      stuff_routes.with_options :conditions => {:method => :get} do |stuff_views|
        stuff_views.connect 'stuff_to_do', :action => 'index'
        stuff_views.connect 'stuff_to_do/:action.:format'
      end
      stuff_routes.with_options :conditions => {:method => :post} do |stuff_views|
        stuff_views.connect 'stuff_to_do', :action => 'index'
        stuff_views.connect 'stuff_to_do/:action.:format'
      end
    end
  end
end