class CreateCassetteTapeTms < ActiveRecord::Migration
  def change
    create_table :cassette_tape_tms do |t|

      t.timestamps
    end
  end
end
