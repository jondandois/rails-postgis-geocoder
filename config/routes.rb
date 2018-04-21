Rails.application.routes.draw do
  namespace :geocoder_api do
    scope module: :v1, defaults: { format: 'json' } do
      get 'geocode/search', to: 'geocode#search'
    end
  end

  match '*path', to: 'application#not_found', via: :all
end
