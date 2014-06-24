module Box
  class Folder < Item
    LIMIT = 1000
    def_delegators :@metadata, :name

    def load_info!
      @client.get("/folders/#{id}")
    end

    # Check to see if an item of the same name in the folder
    def has_item?(name)
      items.find {|item| item.name == name}
    end

    def subfolder(folder_name)
      folders = items.select {|item| item.folder? and item.name == folder_name}
      return nil if folders.empty?
      folders.first
    end

    def find_or_create_subfolder(folder_name)
      folder = subfolder(folder_name)
      return folder unless folder.nil?

      puts "[Box.com] Creating subfolder in #{self.name} for #{folder_name}"
      response = @client.post('folders', {name: folder_name, parent:{id: self.id}})

      if response.status == 201 # created
        folder = Box::Folder.new(@client, response.body)
        puts "[Box.com] Created folder for #{folder_name} in #{name} as #{folder.id}"
        folder
      else
        puts "[Box.com] Error creating folder, #{response.body}"
        nil
      end

    end

    # Warning: This gets on all files for a directory with no limit by recursively calling itself until it reaches
    # the limit
    def items(params = {}, collection = [])
      # Format params defaults
      params = {fields: 'sha1,name,path_collection,size', limit: LIMIT, offset: 0}.merge(params)
      # Add expected fields and limit
      response = @client.get("/folders/#{id}/items", params)
      ap response
      # Add the results to the total collection
      collection.push *@client.parse_items(response.body)

      total_count = response.body['total_count']
      offset      = (LIMIT * (params[:offset] + 1))

      if total_count > offset
        puts "[Box.com] Recursively calling for items in folder #{name} - #{LIMIT}, #{offset}, #{total_count}"
        return self.items({offset: offset}, collection)
      end

      collection
    end

    def folders
      items.select {|item| item.type == 'folder' }
    end
  end
end