class CreateSignalChainFormats < ActiveRecord::Migration
  def change
    create_table :signal_chain_formats do |t|
      t.references :signal_chain, index: true
      t.string :format

      t.timestamps
    end
  end
end
