module Box
  class Authorization


    def self.authorize(config = {})
      puts '... attempting to authorize with username and password'
      client_id, client_secret = config[:client_id], config[:client_secret]
      username, password = config[:username], config[:password]

      agent   = Mechanize::new
      session = Session.new(client_id, client_secret)

      # Get the authorization URL from Box by specifying redirect URL
      # as the arbitrary but working Chase bank home page - this must match the address at Box
      # authorize_url = box_session.authorize_url('https://anywhere.airdye.com/oauth2callback')
      authorize_url = session.authorize_url(redirect_uri: 'https://www.chase.com')

      # process the first login screen
      login_page = agent.get(authorize_url)

      # get the login form where you enter the username and password
      login_form          = login_page.form_with(name: 'login_form')
      login_form.login    = username
      login_form.password = password

      # submit the form and get the allow/deny page back
      allow_page = agent.submit(login_form)

      # find the form that allows consent
      consent_form = allow_page.form_with(name: 'consent_form')

      # now find the button that submits the allow page with consent
      accept_button = consent_form.button_with(name: 'consent_accept')

      # Submit the form to cause the redirection with authentication code
      redirpage = agent.submit(consent_form, accept_button)

      # Use the CGI module to get a hash of the variables (stuff after ?)
      # and then the authentication code is embedded in [" and "] so
      # strip those
      code_query = CGI::parse(redirpage.uri.query)['code'].to_s
      code = code_query[2,code_query.length-4]

      # get the box access token using the authentication code
      session.aquire_access_token(code)

      # print the tokens to show we have them
      p session.access_token
      p session.refresh_token

      Box::Session.on_token_refresh.call(session.access_token, session.refresh_token)

      # Create a new Box client based on the authenticated session
      # ap Box.client.root.items

      return session.oauth2_access_token
    end
  end
end