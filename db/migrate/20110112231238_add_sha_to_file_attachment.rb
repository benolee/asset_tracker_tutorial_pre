class AddShaToFileAttachment < ActiveRecord::Migration
  def self.up
    add_column :file_attachments, :sha, :string
  end

  def self.down
    remove_column :file_attachments, :sha
  end
end
