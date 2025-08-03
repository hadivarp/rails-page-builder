# frozen_string_literal: true

Rails::Page::Builder::Engine.routes.draw do
  resources :pages do
    member do
      get :preview
    end
  end
  
  root to: 'pages#index'
end