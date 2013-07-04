require 'populate'

namespace :db do

  desc "Load all development fixtures."
  task populate: ['populate:clear', 'populate:all']

  namespace :populate do
    desc "Empty all the tables"
    task clear: :environment do
      Rails.cache.clear
      Sidekiq.redis { |con| con.flushall }
      timed { PopulateHelpers.empty_tables(Loader, App, Package) }
    end

    desc "Load all development fixtures. e.g.: rake 'db:populate:all[remy]'"
    task all: :environment do
      timed { Populate.packages }
      timed { Populate.apps }
      timed { Populate.loaders }
    end
  end

end
