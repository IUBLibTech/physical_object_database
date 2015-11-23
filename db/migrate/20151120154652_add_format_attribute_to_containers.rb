class AddFormatAttributeToContainers < ActiveRecord::Migration
  def up
    add_column :batches, :format, :string
    add_column :bins, :format, :string
    add_column :boxes, :format, :string

    [Box, Bin, Batch].each do |container_class|
      puts "\nUpdating #{container_class.all.size} #{container_class.to_s} records:"
      container_class.where(format: [nil, ""]).each do |container|
        container.format = container.media_format
        if container.save
          if container.format.nil?
            puts "\nNil format for #{container_class.to_s}: #{container.id}"
          else
            print "."
          end
        else
          puts "\nError saving container #{container_class.to_s}: #{container.id}: #{container.errors.full_messages.inspect}"
        end
      end
    end
  end
  def down
    remove_column :batches, :format
    remove_column :bins, :format
    remove_column :boxes, :format
  end
end
