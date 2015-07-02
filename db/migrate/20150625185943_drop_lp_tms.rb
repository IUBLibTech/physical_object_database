class DropLpTms < ActiveRecord::Migration
  def up
    drop_table :lp_tms
  end
  def down
    create_table :lp_tms do |t|
      t.timestamps
    end
  end
end
