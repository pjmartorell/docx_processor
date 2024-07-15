Rails.application.routes.draw do
  root 'docx#index'
  post 'process_docx', to: 'docx#process_docx'
  get 'check_status', to: 'docx#check_status'
  get 'download_docx', to: 'docx#download_docx'
end
