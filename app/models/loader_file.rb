require 'templated_file'

class LoaderFile
  include TemplatedFile

  attr_reader :site_token, :app_token, :stage

  def initialize(site_token, app_token, stage)
    @site_token, @app_token, @stage = site_token, app_token, stage
  end

  def path
    path = "js2/#{site_token}"
    path += "-#{stage}" unless stage == 'stable'

    "#{path}.js"
  end

  def content
    _tempfile.print _template("loader-#{stage}.js.erb").result(binding)
    _tempfile.rewind
    _tempfile
  end

  # Binded in the template.
  #
  def host
    case Rails.env
    when 'staging'
      '//cdn.sublimevideo-staging.net'
    else
      '//cdn.sublimevideo.net'
    end
  end

end
