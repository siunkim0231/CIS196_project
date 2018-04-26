class AddAttachmentImageToStatuses < ActiveRecord::Migration[4.2]
  def self.up
    change_table :statuses do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :statuses, :image
  end
end
