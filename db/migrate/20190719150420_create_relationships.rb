class CreateRelationships < ActiveRecord::Migration[5.2]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    # Multiple-key index that enforces uniqueness of follower_id followed_id pairs, so that a user can't follow another user more than once
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
