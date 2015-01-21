class ChangeDefaultDestinationValue < ActiveRecord::Migration
  def up
    puts "Updating #{Batch.all.size} Batches to a destination of Memnon..."
    Batch.update_all(destination: "Memnon")
    puts "Updating #{Bin.all.size} Bins to a destination of Memnon..."
    Bin.update_all(destination: "Memnon")
    puts "Updating #{Picklist.all.size} Picklists to a destination of Memnon..."
    Picklist.update_all(destination: "Memnon")
  end
  def down
    puts "Updating #{Batch.all.size} Batches to a destination of IU..."
    Batch.update_all(destination: "IU")
    puts "Updating #{Bin.all.size} Bins to a destination of IU..."
    Bin.update_all(destination: "IU")
    puts "Updating #{Picklist.all.size} Picklists to a destination of IU..."
    Picklist.update_all(destination: "IU")
  end
end
