class AddIndexToResourcesUid < ActiveRecord::Migration[5.2]
  def change
    add_index :resources, :uid, unique: true
  end
end
