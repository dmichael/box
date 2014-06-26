module Box
  class BoxError < StandardError
  end

  class ArgumentError < BoxError
  end

  class NameConflict < BoxError
  end

  class ResourceNotFound < BoxError
  end

  class MalformedAuthHeaders < BoxError
  end
end