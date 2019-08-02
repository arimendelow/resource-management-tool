class ReorderPhonenumberInResources < ActiveRecord::Migration[5.2]
  def change
    change_column :resources, :phone_number, :string, after: :name
  end
end
