require 'support/fixtures_helpers'

RSpec.configure do |config|
  config.before :suite do
    require 'zip/zip'
    extend Spec::Support::FixturesHelpers

    packages_folder = fixture_dir.join('packages')
    # Dir[packages_folder.join('*.zip')].each do |zip_file|
    #   File.unlink(zip_file)
    # end

    Dir[packages_folder.join('*')].each do |entry|
      if File.directory?(entry) && !File.exists?(entry + '.zip')
        # puts "creating : #{entry}.zip"
        Zip::ZipFile.open(entry + '.zip', Zip::ZipFile::CREATE) do |zip_file|
          Dir["#{entry}/**/*"].each do |file|
            # puts "file.sub(entry, '') : #{file.sub(%r{#{entry}/}, '')}"
            zip_file.add(file.sub(%r{#{entry}/}, ''), file)
          end
        end
      end
    end
  end

  config.after :suite do
    extend Spec::Support::FixturesHelpers

    Dir[fixture_dir.join('packages').join('*.zip')].each do |zip_file|
      # puts "unlinking : #{zip_file}"
      File.unlink(zip_file)
    end
  end
end
