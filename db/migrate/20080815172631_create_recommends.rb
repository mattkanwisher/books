class CreateRecommends < ActiveRecord::Migration
  def self.up
    create_table :recommends do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :recommends
  end
end
