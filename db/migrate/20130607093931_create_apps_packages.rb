class CreateAppsPackages < ActiveRecord::Migration
  def change
    create_table :apps_packages, id: false do |t|
      t.references :app, index: true
      t.references :package, index: true
    end
    add_index :apps_packages, [:app_id, :package_id], unique: true
  end
end
