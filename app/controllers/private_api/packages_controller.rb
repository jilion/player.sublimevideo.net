require 'has_scope'

class PrivateApi::PackagesController < SublimeVideoPrivateApiController
  before_filter :_find_packages, only: [:index]
  before_filter :_find_package, only: [:show]

  has_scope :per

  # GET /private_api/packages
  def index
    expires_in 2.minutes, public: true
    respond_with(@packages)
  end

  # GET /private_api/packages/:id
  def show
    expires_in 2.minutes, public: true
    respond_with(@package) if stale?(@package)
  end

  private

  def _find_packages
    @packages = apply_scopes(Package.page(params[:page]))
  end

  def _find_package
    @package = Package.find(params[:id])
  end
end
