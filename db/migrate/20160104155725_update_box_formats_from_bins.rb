class UpdateBoxFormatsFromBins < ActiveRecord::Migration
  def up
    boxes = Box.where(format: [nil, '']).where.not(bin_id: [nil, '', 0])
    puts "#{boxes.size} unformatted boxes assigned to bins"
    formattable = boxes.select { |box| !box.bin.format.blank? }
    unformattable = boxes.select { |box| box.bin.format.blank? }
    puts "#{unformattable.size} unformattable boxes; skipped"
    puts "#{formattable.size} formattable boxes to format"
    formattable.each do |box|
      box.save
      print "."
    end
    print "\n" if formattable.any?
    puts "#{Box.where(format: [nil, '']).where.not(bin_id: [nil, '', 0]).size} unformatted boxes remaining"

  end
  def down
    puts "No action on rollback"
  end
end
