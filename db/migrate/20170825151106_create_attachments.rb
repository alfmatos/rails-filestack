class CreateAttachments < ActiveRecord::Migration[5.1]
  def change
    create_table :attachments do |t|
      t.string :title
      t.string :handle

      t.timestamps
    end
  end
end
