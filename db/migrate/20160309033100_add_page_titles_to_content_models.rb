class AddPageTitlesToContentModels < ActiveRecord::Migration
  def change
    [:products, :trails, :videos].each do |table_name|
      add_column table_name, :page_title, :text, default: "", null: false
    end
  end
end
