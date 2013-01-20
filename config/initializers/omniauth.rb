Rails.application.config.middleware.use OmniAuth::Builder do

  configure do |config|
    config.full_host = "#{APP_CONFIG['deployment']['full_host']}"
  end

  options = {:client_options => {:ssl => {:ca_path => "/etc/ssl/certs"}} }

  provider :google_oauth2, APP_CONFIG['omniauth']['google_oauth2']['secret_id'], APP_CONFIG['omniauth']['google_oauth2']['secret_key'], options
  provider :facebook, APP_CONFIG['omniauth']['facebook']['secret_id'], APP_CONFIG['omniauth']['facebook']['secret_key'], options
  provider :twitter, APP_CONFIG['omniauth']['twitter']['secret_id'], APP_CONFIG['omniauth']['twitter']['secret_key'], options
end