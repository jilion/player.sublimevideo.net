class CreateLoaders < ActiveRecord::Migration
  def change
    create_table :loaders do |t|
      t.references :app, index: true
      t.string :site_token
      t.string :stage

      t.timestamps
    end
    add_index :loaders, :site_token
    add_index :loaders, [:site_token, :stage]
    add_index :loaders, [:app_id, :site_token, :stage], unique: true
  end
end
