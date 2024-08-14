class CreateRooms < ActiveRecord::Migration[7.2]
  def change
    create_table :rooms do |t|
      t.string :name
      t.boolean :occupied

      t.timestamps
    end
  end
end
