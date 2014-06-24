require 'forwardable'

module Box
  class Item
    attr_accessor :client, :metadata
    extend Forwardable
    extend Memoist

    def self.type
      self.name.demodulize.downcase
    end

    def initialize(*args)
      if args.size == 1
        @client, @metadata = Box.client, Hashie::Mash.new(args[0])
      else
        @client, @metadata = args[0], Hashie::Mash.new(args[1])
      end

    end

    def folder?
      type == 'folder'
    end

    def file?
      type == 'file'
    end

    def self.find(id)
      response = Box.client.get("#{type.pluralize}/#{id}")
      self.new(Box.client, response.body)
    rescue Box::ResourceNotFound => e
      nil
    end


    def_delegators :@metadata, :id, :type
  end
end