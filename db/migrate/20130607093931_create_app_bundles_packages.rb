class CreateAppBundlesPackages < ActiveRecord::Migration
  def change
    create_table :app_bundles_packages, id: false do |t|
      t.references :app_bundle, index: true
      t.references :package, index: true
    end
  end
end
