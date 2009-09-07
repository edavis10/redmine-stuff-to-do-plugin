ActionController::Routing::Routes.draw do |map|
  map.connect 'stuff_to_do/:action.:format', :controller => 'stuff_to_do'
end
