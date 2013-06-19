class CreateAppBundles < ActiveRecord::Migration
  def change
    create_table :app_bundles do |t|
      t.string :token

      t.timestamps
    end
    add_index :app_bundles, :token
  end
end
