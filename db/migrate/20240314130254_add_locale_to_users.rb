class AddLocaleToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :locale, :string, limit: 10, default: "en"
  end

  def down
    remove_column :users, :locale
  end
end
