require 'packages_zipper'

RSpec.configure do |config|
  config.before :suite do
    PackagesZipper.zip_all_packages
  end

  config.after :suite do
    PackagesZipper.delete_all_zipped_packages
  end
end
