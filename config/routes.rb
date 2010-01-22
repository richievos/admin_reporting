ActionController::Routing::Routes.draw do |map|
  map.namespace 'admin' do |admin|
    admin.resources :reports, :only => 'show'
  end
end
