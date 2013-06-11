class PackageSettings
  extend Forwardable
  def_delegator :@settings, :[]

  def initialize
    @settings = []
  end

  def level(index)
    unless @settings[index]
      @settings[index] = {}
    end

    if block_given?
      yield(@settings[index])
    else
      @settings[index]
    end
  end

end
