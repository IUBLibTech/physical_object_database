class AddDestinationToBatchesBinsPicklists < ActiveRecord::Migration
  def up
    add_column :batches, :destination, :string
    add_index :batches, :destination
    Batch.update_all(destination: "IU")

    add_column :bins, :destination, :string
    add_index :bins, :destination
    Bin.update_all(destination: "IU")

    add_column :picklists, :destination, :string
    add_index :picklists, :destination
    Picklist.update_all(destination: "IU")
  end
  def down
    remove_index :batches, column: :destination
    remove_column :batches, :destination

    remove_index :bins, column: :destination
    remove_column :bins, :destination

    remove_index :picklists, column: :destination
    remove_column :picklists, :destination
  end
end
