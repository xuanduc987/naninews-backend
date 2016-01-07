class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.references :post, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :votes, [:post_id, :user_id], unique: true
  end
end
