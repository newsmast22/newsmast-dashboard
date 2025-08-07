class AddStatusToCommunityAdmins < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def self.up
    change_table :patchwork_communities_admins do |t|
      t.integer :account_status, null: false, default: 0
    end
  end

  def self.down
    remove_column :patchwork_communities_admins, :account_status
    if column_exists?(:patchwork_communities_admins, :account_status)
      remove_column :patchwork_communities_admins, :account_status
    end
  end
end