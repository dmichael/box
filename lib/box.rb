require "box/version"


module Box
  API_URL = 'https://api.box.com'
  UPLOAD_URL = 'https://upload.box.com/api/2.0'
  ISO_8601_TEST = Regexp.new(/^[0-9]{4}-[0-9]{2}-[0-9]{2}T/)

  class << self
    extend Memoist

    def client(config = {})
      config = {
        access_token:  config[:access_token] || ENV['BOX_ACCESS_TOKEN'],
        refresh_token: config[:refresh_token] || ENV['BOX_REFRESH_TOKEN'],
        client_id:     config[:client_id] || ENV['BOX_CLIENT_ID'],
        client_secret: config[:client_secret] || ENV['BOX_CLIENT_SECRET'],
        username:      config[:username] || ENV['BOX_USERNAME'],
        password:      config[:password] || ENV['BOX_PASSWORD']
      }

      # Box::Authorization.authorize client_id, client_secret
      session = create_session(config)
      Box::Client.new(session)
    end
    memoize :client

    def create_session(config = {})
      Box::Session.new config
    end

  end

  class BoxError < StandardError
  end

  class ArgumentError < BoxError
  end

  class NameConflict < BoxError
  end

  class ResourceNotFound < BoxError
  end

end