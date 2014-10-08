
Devise.setup do |config|
  config.omniauth :vphticket,
    host: Air.config.vph.host,
    roles_map: Air.config.vph.roles_map,
    ssl_verify: Air.config.vph.ssl_verify

  Warden::Strategies.add(:token_authenticatable, Devise::Strategies::TokenAuthenticatable)
  Warden::Strategies.add(:mi_token_authenticatable, Devise::Strategies::MiTokenAuthenticatable)

  strategies = [:token_authenticatable, :mi_token_authenticatable]

  config.warden do |manager|
    manager.intercept_401 = false
    strategies.each do |strategy|
      manager.default_strategies(:scope => :user).unshift strategy
    end
  end
end