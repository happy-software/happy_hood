Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'pages#home'
  get  '/house_valuations/:zpid', to: 'houses#valuations'
  post '/house_valuations/:zpid', to: 'houses#import'

  post '/find_zpid', to: 'houses#find_zpid'

  post '/onboard', controller: 'onboarding', action: 'hood_and_houses'
end
