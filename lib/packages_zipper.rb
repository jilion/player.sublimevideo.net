class PackagesZipper

  def self.zip_all_packages
    require 'zip/zip'

    packages_folder = Rails.root.join('spec', 'fixtures', 'packages')
    Dir[packages_folder.join('*')].each do |entry|
      if File.directory?(entry) && !File.exists?(entry + '.zip')
        Zip::ZipFile.open(entry + '.zip', Zip::ZipFile::CREATE) do |zip_file|
          Dir["#{entry}/**/*"].each do |file|
            zip_file.add(file.sub(%r{#{entry}/}, ''), file)
          end
        end
      end
    end

    if block_given?
      yield
      delete_all_zipped_packages
    end
  end

  def self.all_zips
    Dir[Rails.root.join('spec', 'fixtures', 'packages', '*.zip')]
  end

  def self.delete_all_zipped_packages
    all_zips.each do |zip_file|
      File.unlink(zip_file)
    end
  end

end
