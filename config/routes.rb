Rails.application.routes.draw do
  root 'pages#home'
  get  '/house_valuations/:zpid', to: 'houses#valuations'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
