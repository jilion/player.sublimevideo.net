require 'app_files_manager'

class AppManager

  attr_reader :app_token, :packages, :stage

  def initialize(app_token, packages = [], stage = 'stable')
    @app_token, @packages, @stage = app_token, packages, stage
  end

  def create
    App.create!(token: app_token, packages: packages)
    AppFilesManager.new(app_token, packages, stage).upload

    _increment_librato('create.succeed')

    true

  rescue ActiveRecord::RecordInvalid
    _increment_librato('create.failed')
    false
  end

  def delete
    if app = App.find_by_token(app_token)
      app.destroy!

      AppFilesManager.new(app_token, [], stage).delete

      _increment_librato('delete.succeed')
    end
  end

  private

  def _increment_librato(action)
    Librato.increment "player.app.#{action}", source: stage
  end

end
