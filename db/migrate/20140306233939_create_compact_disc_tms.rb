class CreateCompactDiscTms < ActiveRecord::Migration
  def change
    create_table :compact_disc_tms do |t|

      t.timestamps
    end
  end
end
