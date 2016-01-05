class CreateApiTokens < ActiveRecord::Migration
  def change
    create_table :api_tokens do |t|
      t.references :user, index: true, foreign_key: true
      t.string :token

      t.timestamps null: false
    end
    add_index :api_tokens, :token, unique: true
  end
end
