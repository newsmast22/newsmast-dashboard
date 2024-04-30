class CreateServerSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :server_settings do |t|
      t.string :name
      t.boolean :value
      t.integer :position
      t.bigint :parent_id, null: true
      t.datetime :deleted_at
      t.timestamps
    end
  end

end
