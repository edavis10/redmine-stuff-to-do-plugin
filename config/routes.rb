# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

if Rails::VERSION::MAJOR >= 3
  RedmineApp::Application.routes.draw do
    get 'stuff_to_do', controller: 'stuff_to_do', action: 'index'

    get 'time_grid', controller: 'stuff_to_do', action: 'time_grid'
    post 'time_grid', controller: 'stuff_to_do', action: 'time_grid'
    get 'time_grid/:date', controller: 'stuff_to_do', action: 'time_grid'

    get '/stuff_to_do/add', controller: 'stuff_to_do', action: 'add'
    post '/stuff_to_do/add', controller: 'stuff_to_do', action: 'add'
    get '/stuff_to_do/delete', controller: 'stuff_to_do', action: 'delete'
    post '/stuff_to_do/delete', controller: 'stuff_to_do', action: 'delete'
    get '/stuff_to_do/clear', controller: 'stuff_to_do', action: 'clear'
    post '/stuff_to_do/clear', controller: 'stuff_to_do', action: 'clear'
    get '/stuff_to_do/:action.:format', controller: 'stuff_to_do'
    post '/stuff_to_do/:action.:format', controller: 'stuff_to_do'

    get '/stuff_to_do/reportees', controller: 'stuff_to_do_reportee', action: 'index'
    get '/stuff_to_do/reportees_admin', controller: 'stuff_to_do_reportee', action: 'admin'

    get '/stuff_to_do/reportees/add', controller: 'stuff_to_do_reportee', action: 'add'
    post '/stuff_to_do/reportees/add', controller: 'stuff_to_do_reportee', action: 'add'
    get '/stuff_to_do/reportees/delete', controller: 'stuff_to_do_reportee', action: 'delete'
    post '/stuff_to_do/reportees/delete', controller: 'stuff_to_do_reportee', action: 'delete'
  end
else
  ActionController::Routing::Routes.draw do |map|
    map.with_options controller: 'stuff_to_do' do |stuff_routes|
      stuff_routes.with_options conditions: {method: :get} do |stuff_views|
        stuff_views.connect 'stuff_to_do', action: 'index'
        stuff_views.connect 'stuff_to_do/:action.:format'
      end
      stuff_routes.with_options conditions: {method: :post} do |stuff_views|
        stuff_views.connect 'stuff_to_do', action: 'index'
        stuff_views.connect 'stuff_to_do/:action.:format'
      end
    end
  end
end
