# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

if Rails::VERSION::MAJOR >= 3
  RedmineApp::Application.routes.draw do
    get 'stuff_to_do' => 'stuff_to_do#index'
    get 'stuff_to_do/:action.:format' => 'stuff_to_do'
    post 'stuff_to_do/:action.:format' => 'stuff_to_do'
    get 'time_grid' => 'stuff_to_do#time_grid'
    post 'time_grid' => 'stuff_to_do#time_grid'
    get 'time_grid/:date' => 'stuff_to_do#time_grid'
  end
end
if Rails::VERSION::MAJOR < 3
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
