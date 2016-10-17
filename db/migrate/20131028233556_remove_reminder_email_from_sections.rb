class RemoveReminderEmailFromSections < ActiveRecord::Migration
  def up
    remove_column :sections, :reminder_email
  end

  def down
    add_column :sections, :reminder_email, :text
  end
end
