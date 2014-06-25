module Box
  class Session
    extend Memoist
    attr_accessor :client_id, :client_secret, :access_token, :refresh_token, :on_token_refresh, :oauth2_access_token
    attr_accessor :config

    class << self
        attr_accessor :on_token_refresh
        @on_token_refresh = -> (access_token, refresh_token) {}
    end

    OAUTH2_URLS = {
      site:          'https://www.box.com',
      authorize_url: '/api/oauth2/authorize',
      token_url:     '/api/oauth2/token'
    }

    def initialize(config = {})
      @config = config
      # We must have at least these variables
      @client_id     = config[:client_id]
      @client_secret = config[:client_secret]
      @access_token  = config[:access_token]
      @refresh_token = config[:refresh_token]

      if @access_token
        @oauth2_access_token = OAuth2::AccessToken.new(oauth2_client, @access_token, {refresh_token: @refresh_token})
      end
    end

    def oauth2_client
      OAuth2::Client.new(@client_id, @client_secret, OAUTH2_URLS.dup)
    end
    memoize :oauth2_client

    # {redirect_uri: value}
    def authorize_url(options = {})
      oauth2_client.auth_code.authorize_url(options)
    end

    # @return [OAuth2::AccessToken]
    def aquire_access_token(code)
      @oauth2_access_token = oauth2_client.auth_code.get_token(code)
      set_tokens!
      @oauth2_access_token
    end

    def set_tokens!
      @access_token  = @oauth2_access_token.token
      @refresh_token = @oauth2_access_token.refresh_token
    end

    def refresh_token!
      @oauth2_access_token = @oauth2_access_token.refresh!
      set_tokens!
      Box::Session.on_token_refresh.call(@oauth2_access_token.token, @oauth2_access_token.refresh_token)
      @oauth2_access_token
    rescue OAuth2::Error => e
      if e.code == 'invalid_client' || ((e.code == 'invalid_grant') && (e.description == 'Refresh token has expired' || e.description == 'Invalid refresh token'))
        raise e if @config[:disable_auth]
        puts "Error authenticating Box -> #{e.message}"
        puts 'Attempting to reauthorize and get new tokens'
        @oauth2_access_token = Box::Authorization.authorize(config)
        set_tokens!
        return @oauth2_access_token
      else
        raise e
      end
    end

  end
end