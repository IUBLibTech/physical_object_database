class UpdateContainerFormatValues < ActiveRecord::Migration
  def up
    puts "Updating container format values"
    
    boxes = Box.where(format: [nil, ''])
    puts "#{boxes.size} unformatted boxes"
    filled = boxes.select { |box| box.physical_objects.any? }
    empty = boxes.select { |box| box.physical_objects.none? }
    puts "#{empty.size} empty boxes; skipped"
    puts "#{filled.size} filled boxes to format"
    filled.each do |box|
      box.physical_objects.first.set_container_format
      print "."
    end
    print "\n" if filled.any?
    puts "#{Box.where(format: [nil, '']).size} unformatted boxes remaining"

    puts "\n"
    bins = Bin.where(format: [nil, ''])
    puts "#{bins.size} unformatted bins"
    object_bins = bins.select { |bin| bin.physical_objects.any? }
    box_bins = bins.select { |bin| bin.boxes.any? }
    puts "#{bins.size - object_bins.size - box_bins.size} empty bins; skipped"
    puts "#{object_bins.size} unformatted object bins to format"
    object_bins.each do |bin|
      bin.physical_objects.first.set_container_format
      print "."
    end
    print "\n" if object_bins.any?
    puts "#{box_bins.size} unformatted box bins to format"
    box_bins.each do |bin|
      all_boxes = bin.boxes
      format_boxes = all_boxes.select { |box| !box.format.blank?}
      if format_boxes.any?
        format_boxes.first.set_container_format
        print "."
      else
        print "(#{bin.mdpi_barcode} skipped)"
      end
    end
    print "\n" if box_bins.any?
    puts "#{Bin.where(format: [nil, '']).size} unformatted bins remaining"

    puts "\n"
    batches = Batch.where(format: [nil, ''])
    puts "#{batches.size} unformatted batches"
    filled = batches.select { |batch| batch.bins.any? }
    empty = batches.select { |batch| batch.bins.none? }
    puts "#{empty.size} empty batches; skipped"
    puts "#{filled.size} filled batches to format"
    filled.each do |batch|
      batch.bins.first.set_container_format
      print "."
    end
    print "\n" if filled.any?
    puts "#{Batch.where(format: [nil, '']).size} unformatted batches remaining"

  end
  def down
    puts "No action on rollback"
  end
end
