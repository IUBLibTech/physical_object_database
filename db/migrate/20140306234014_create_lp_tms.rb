class CreateLpTms < ActiveRecord::Migration
  def change
    create_table :lp_tms do |t|

      t.timestamps
    end
  end
end
