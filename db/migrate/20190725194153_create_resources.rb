class CreateResources < ActiveRecord::Migration[5.2]
  def change
    create_table :resources do |t|
      t.integer :uid
      t.string :name
      t.string :phone_number
      t.string :email
      t.string :skills, array: true, default: []
      t.string :portfolio
      t.date :start_date
      t.string :location
      t.string :manager

      t.timestamps
    end
  end
end
