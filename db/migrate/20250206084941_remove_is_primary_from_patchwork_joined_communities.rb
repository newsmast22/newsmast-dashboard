class RemoveIsPrimaryFromPatchworkJoinedCommunities < ActiveRecord::Migration[7.1]
  def change
    remove_column :patchwork_joined_communities, :is_primary, :boolean
  end
end