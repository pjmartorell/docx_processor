Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "healthz" => "rails/health#show", as: :rails_health_check

  root 'docx#index'
  post 'process_docx', to: 'docx#process_docx'
  get 'check_status', to: 'docx#check_status'
  get 'download_docx', to: 'docx#download_docx'
end
