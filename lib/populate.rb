require 'tasks/task_helpers'
require 'populate/populate_helpers'
require 'packages_zipper'

module Populate

  class << self

    def packages
      PopulateHelpers.empty_tables(Package)
      PackagesZipper.zip_all_packages do
        PackagesZipper.all_zips.each do |zip_file|
          Package.create(zip: File.open(zip_file))
        end
        puts "#{Package.count} packages created!"
      end
    end

    def apps
      100.times do
        App.create!(token: _token)
      end
      puts "#{App.count} apps created!"
    end

    def loaders
      apps = App.all
      1000.times do
        Loader.create!(app: apps.sample, site_token: _token, stage: Stage.stages.sample)
      end
      puts "#{Loader.count} loaders created!"
    end

    private

    def _token
      4.times.reduce('') { |a,e| a += ('a'..'z').to_a.sample + (0..9).to_a.sample.to_s }
    end

    def delete_all_files_in_public(*paths)
      paths.each do |path|
        if path.gsub('.', '') =~ /\w+/ # don't remove all files and directories in /public ! ;)
          print "Deleting all files and directories in /public/#{path}\n" if Rails.env.development?
          timed do
            Dir["#{Rails.public_path}/#{path}/**/*"].each do |filename|
              File.delete(filename) if File.file?(filename)
            end
            Dir["#{Rails.public_path}/#{path}/**/*"].each do |filename|
              Dir.delete(filename) if File.directory?(filename)
            end
          end
        end
      end
    end

  end

end
