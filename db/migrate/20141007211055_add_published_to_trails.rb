class AddPublishedToTrails < ActiveRecord::Migration
  def up
    add_column :trails, :published, :boolean, default: false, null: false
    update("UPDATE trails SET published = true")
    add_index :trails, :published
  end

  def down
    remove_column :trails, :published
  end
end
