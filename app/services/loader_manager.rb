require 'loader_file_manager'

# This class is responsible for delegating the loader generation and for
# creating or updating the Loader record for a given site.
#
class LoaderManager

  attr_reader :site_token, :app, :stage

  def initialize(site_token, app, stage = 'stable')
    @site_token, @app, @stage = site_token, app, stage
  end

  def update
    loader = Loader.find_or_initialize_by(site_token: site_token, stage: stage)
    loader.app = app
    loader.save!

    LoaderFileManager.new(site_token, app.token, stage).upload

    _increment_librato('update.succeed')

    true

  rescue ActiveRecord::RecordInvalid
    _increment_librato('update.failed')
    false
  end

  def delete
    if loader = Loader.find_by(site_token: site_token, stage: stage)
      loader.destroy!

      LoaderFileManager.new(site_token, app.token, stage).delete

      _increment_librato('delete.succeed')
    end
  end

  private

  def _increment_librato(action)
    Librato.increment "player.loader.#{action}", source: stage
  end

end
