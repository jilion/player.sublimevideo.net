class PackagesController < ApplicationController
  respond_to :json

  # TODO: Move this to active admin
  # POST /packages
  def create
    @package = Package.new(params[:package])
    PackageManager.new(@package).create
    respond_with @package, location: [@package]
  end
end
