class PackagesController < ApplicationController
  respond_to :zip, only: [:show]
  respond_to :html, only: [:index]
  respond_to :json

  # GET /packages
  def index
    @packages = Package.all
  end

  # GET /packages/:id
  def show
    name = params[:id][/([\w\-]+)-\d+/, 1]
    version = params[:id][/[\w\-]+-(\d+.*)/, 1].gsub('_', '.')
    Rails.logger.info "name : #{name}"
    Rails.logger.info "version : #{version}"
    @package = Package.where(name: name, version: version).first
    respond_with @package do |format|
      format.zip { redirect_to @package.zip.url }
    end
  end

  # POST /packages
  def create
    @package = Package.new(params[:package])
    PackageManager.new(@package).create
    respond_with @package, location: [@package]
  end
end
