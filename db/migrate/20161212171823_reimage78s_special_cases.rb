# For 78s that were missed because they are not yet Archived
class Reimage78sSpecialCases < ActiveRecord::Migration
  def up
    picklist = Picklist.where(id: 255).first
    if picklist
      po_list = PhysicalObject.where(id: [ 297413,297414,297415,297416,385136,297380,297381,297449,297450,297451,297452,297453,297454,297455,297456,297457,297458,297459,297460,297461,297462,385159,385160,296538,296540,296541,296542,296545,296547,296548,296549,299031,299032,299037,299110,387931,387933,297937])
      puts "Updating #{po_list.size} objects:"
      po_list.each do |po|
        po.update_attributes!(picklist: picklist)
        po.apply_resend_status
        print '.'
      end
      puts "Finished."
    else
      puts "ERROR: Picklist not found"
    end
  end
  def down
    puts "No action on rollback."
  end
end

