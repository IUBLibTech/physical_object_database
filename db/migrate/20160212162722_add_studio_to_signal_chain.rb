class AddStudioToSignalChain < ActiveRecord::Migration
  def change
    add_column :signal_chains, :studio, :string
  end
end
