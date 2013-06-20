class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :token

      t.timestamps
    end
    add_index :apps, :token
  end
end
