


module Box
  class Client
    VERSION = '2.0'

    def initialize(session)
      @session = session
    end

    def root
      Folder.new(self, id: 0)
    end

    def walk(root, &block)
      root.items.each do |item|
        if item.folder?
          walk(item, &block)
        elsif item.file?
          yield item
        else
          puts "Unknown item type #{item.id}:#{item.type}"
        end
      end
    end

    # Starting at the "root" of Box which is always "All Files", make successive requests untl you have reached the
    # final path in the input
    def folder(path) # /path/to/folder
      path = Pathname(path).each_filename.to_a
      folder = root
      path.each do |name|
        folder = folder.folders.select {|folder| folder.name == name}.first
        return nil unless folder
      end
      folder
    end

    def search(query, options = {})
      params = options.merge({query: query})

      response = get('search', params)
      parse_items(response.body)
    end

    # Process the Box "items" returned from a request
    def parse_items(results)
      return [] if results['entries'].empty?
      results['entries'].reduce([]) do |entries, entry|
        entries << case entry['type']
          when 'file'   then Box::File.new(self, entry)
          when 'folder' then Box::Folder.new(self, entry)
        end
        entries
      end
    end

    def connection
      conn = Faraday.new(Box::API_URL) do |builder|
        builder.request :json
        builder.request :multipart
        # builder.response :logger
        builder.response :json, :content_type => /\bjson$/
        # What a joke. This must be LAST to avoid encoding errors in JSON request body
        builder.adapter  :net_http
      end

      conn.headers['Authorization'] = "Bearer #{@session.access_token}"
      conn
    end

    def make_uri(path)

    end

    def get(path, params = {}, retries = 0)
      request('GET', path, params)
    end

    def post(path, params = {}, retries = 0)
      request('POST', path, params)
    end

    def put(path, params = {}, retries = 0)
      request('PUT', path, params)
    end

    def delete(path, params = {}, retries = 0)
      request('DELETE', path, params)
    end

    def upload(params = {}, retries = 0)
      # Basic parameters
      local_path, content_type, file_name, parent_id = params[:local_path], params[:content_type], params[:file_name], params[:parent_id]
      # If there is a file_id, it means we want to replace it.
      uri = if params[:box_id]
        "https://upload.box.com/api/2.0/files/#{params[:box_id]}/content"
      else
        'https://upload.box.com/api/2.0/files/content'
      end

      puts "[Box.com] POST #{uri}"

      # Construct the payload
      payload = {
        filename:  Faraday::UploadIO.new(local_path, content_type, file_name),
        parent_id: parent_id
      }

      response = connection.post(uri, payload) do |request|
        request.headers['Content-Type'] = 'multipart/form-data'
      end

      case response.status
        when 401
          try_token_refresh!
          return upload(params, retries + 1) if retries == 0
        else
          return handle_response(response)
      end
    end

    # Generic HTTP request method with retries for bad authorization
    def request(method, path, params = {}, retries = 0)
      uri = Addressable::URI.parse(::File.join(VERSION, path))
      if method == 'GET'
        uri.query_values = params
        # params = {}
      end

      puts "[Box.com] #{method} #{::File.join(Box::API_URL, uri.to_s)}"
      response = connection.send(method.downcase, uri.to_s, params)

      case response.status
        when 401
          try_token_refresh!
          return request(method, path, params, retries + 1) if retries == 0
        else
          return handle_response(response)
      end
    # TODO: We need to retry connection failures - or at least catch them
    # rescue Faraday::ConnectionFailed => e
    end

    def try_token_refresh!
      @session.refresh_token!
    rescue OAuth2::Error => e
      raise "Sorry, could not refresh tokens"
    end

    def handle_response(response)
      case response.status
        when 400
          raise Box::MalformedAuthHeaders, response.headers
        when 404
          raise Box::ResourceNotFound, JSON.dump(response.body)
        when 409
          raise Box::NameConflict,  JSON.dump(response.body)
        when 500
          ap response.body
      end
      return response
    end

  end
end