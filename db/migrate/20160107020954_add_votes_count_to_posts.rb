class AddVotesCountToPosts < ActiveRecord::Migration

  def self.up

    add_column :posts, :votes_count, :integer, :null => false, :default => 0

  end

  def self.down

    remove_column :posts, :votes_count

  end

end
