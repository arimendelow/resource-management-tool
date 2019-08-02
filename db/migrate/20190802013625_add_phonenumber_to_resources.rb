class AddPhonenumberToResources < ActiveRecord::Migration[5.2]
  def change
    add_column :resources, :phone_number, :string
  end
end
