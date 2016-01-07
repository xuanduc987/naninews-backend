class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :url
      t.string :slug
      t.string :title
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :posts, :url, unique: true
    add_index :posts, :slug, unique: true
  end
end