class CreateRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :rooms do |t|
      t.string :name
      t.boolean :occupied

      t.timestamps
    end
  end
end
