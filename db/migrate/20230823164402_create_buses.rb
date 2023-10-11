class CreateBuses < ActiveRecord::Migration[7.0]
  def change
    create_table :buses do |t|
      t.string :name
      t.string :registration_no
      t.string :route
      t.integer :total_seat
      t.boolean :approved, default: false
      t.references :user, null: false
      t.timestamps
    end
  end
end
