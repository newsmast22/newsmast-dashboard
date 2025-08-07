class AddAttachmentAvatarImageBannerImageToCollections < ActiveRecord::Migration[7.1]
  def self.up
    change_table :patchwork_collections do |t|
      t.attachment :avatar_image
      t.attachment :banner_image
    end
  end

  def self.down
    remove_attachment :patchwork_collections, :avatar_image
    remove_attachment :patchwork_collections, :banner_image
  end
end
