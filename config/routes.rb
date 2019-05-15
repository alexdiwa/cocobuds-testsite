Rails.application.routes.draw do
  devise_for :users, path: "/", path_names: { sign_in: "login", sign_out: 'logout', sign_up: "signup" }, :controllers => { registrations: 'registrations' }
 
  root to: "users#home"
  get "/users/preview", to: "users#preview", as: "preview"
  resources :users
  get "/pages/donate", to: "pages#donate"
  get "/pages/underconstruction", to: "pages#underconstruction"
  post "/payments", to: "payments#stripe"
  get "/payments/success", to: "payments#success"

  get "/inbox", to: "conversations#index", as: "conversations"
  post "/inbox", to: "conversations#create"
  get "/inbox/:conversation_id/messages", to: "messages#index", as: "conversation_messages"
  post "/inbox/:conversation_id/messages", to: "messages#create"

  get "/saved", to: "follows#index", as: "saved"
  resources :follows, only: [:create, :destroy]
end