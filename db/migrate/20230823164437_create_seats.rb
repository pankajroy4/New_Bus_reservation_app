class CreateSeats < ActiveRecord::Migration[7.0]
  def change
    create_table :seats do |t|
      t.integer :seat_no
      t.references :bus, null: false, foreign_key: true

      t.timestamps
    end
    # Reservation.delete_all ,uncomment this before rollback
  end
end
