class Settings < Settingslogic
  source "#{Rails.root}/config/air.yml"
  namespace Rails.env

  class << self
    def header_mi_authentication_key
      to_header_key(mi_authentication_key)
    end

    def header_project_key
      to_header_key(project_key)
    end

    private

    def to_header_key(key)
      key.upcase.gsub(/_/, '-')
    end
  end

  Settings['sidekiq'] ||= Settingslogic.new({})
  Settings.sidekiq['url'] ||= "redis://localhost:6379"
  Settings.sidekiq['namespace'] ||= "air"

  Settings['skip_pdp_for_admin'] = false if Settings['skip_pdp_for_admin'].nil?

  # Default config values for MetadataRegistry setup
  Settings['metadata'] ||= Settingslogic.new({})
  Settings.metadata['registry_endpoint'] = 'http://vphshare.atosresearch.eu/metadata-extended/rest/metadata/' if Settings.metadata['registry_endpoint'].nil?
  Settings.metadata['remote_connect'] = false if Settings.metadata['remote_connect'].nil?
  Settings.metadata['remote_publish'] = false if Settings.metadata['remote_publish'].nil?

  Settings['mi_authentication_key']    ||= 'mi_ticket'
  Settings['project_key'] ||= 'project'

  Settings['vph'] ||= Settingslogic.new({})
  Settings.vph['enabled'] = false if Settings.vph['enabled'].nil?
  Settings.vph['ssl_verify'] = true if Settings.vph['ssl_verify'].nil?
end
