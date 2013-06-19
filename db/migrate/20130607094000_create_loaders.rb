class CreateLoaders < ActiveRecord::Migration
  def change
    create_table :loaders do |t|
      t.string :site_token
      t.references :app_bundle, index: true

      t.timestamps
    end
  end
end
