class AddTypeWaitLists < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def self.up
    change_table :patchwork_wait_lists do |t|
      t.integer :channel_type, null: false, default: 0
    end
  end

  def self.down
    if column_exists?(:patchwork_wait_lists, :channel_type)
      remove_column :patchwork_wait_lists, :channel_type
    end
  end
end