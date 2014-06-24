module Box
  class File < Item
    def_delegators :@metadata, :sha1, :name, :size, :etag, :parent

    def self.download_uri(id)
      response = Box.client.get("/files/#{id}/content")
      uri = nil
      uri = response.headers['location'] if response.status == 302
      uri
    end

    def size
      @metadata['size']
    end

    def path
      "/" + path_names.join('/')
    end

    def path_with_file
      ::File.join(path, name)
    end

    def paths
      @metadata['path_collection']['entries']
    end

    def path_names
      paths.map {|path| path['name']}
    end

    def self.delete_existing(id)
      Box.client.delete("files/#{id}")
    end


    # Ruby is such a pain in the ass with it's loosy goosy type
    # @return [Box::File] The newly created file on Box
    def copy_to(folder, options = {})
      raise Box::ArgumentError, 'folder must be a Box::Folder' unless folder.is_a?(Box::Folder)
      raise Box::ArgumentError, 'options must be a Hash' unless options.is_a?(Hash)

      folder_id = folder.id

      params = {parent: {id: folder_id}, name: options[:name]}
      # This response is a Box file object
      response = @client.post("files/#{id}/copy", params)
      Box::File.new(@client, response.body)
    end

    # Since this is just an update, this method is idempotent always returning a file
    def move_to(folder, options = {})
      folder_id = (folder.is_a?(Box::Folder)) ? folder.id : folder

      response = @client.put("files/#{id}", parent:{id: folder_id})
      Box::File.new(@client, response.body)
    end


  end
end