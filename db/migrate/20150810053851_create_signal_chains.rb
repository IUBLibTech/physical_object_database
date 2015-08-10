class CreateSignalChains < ActiveRecord::Migration
  def change
    create_table :signal_chains do |t|
      t.string :name

      t.timestamps
    end
  end
end
