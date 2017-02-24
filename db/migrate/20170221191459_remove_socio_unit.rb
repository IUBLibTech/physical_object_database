class RemoveSocioUnit < ActiveRecord::Migration
  def up
    old = Unit.find_by(abbreviation: 'B-SOCIO')
    new = Unit.find_by(abbreviation: 'B-CSHM')
    if old && new
      puts "Modifying #{old.physical_objects.size} objects:"
      old.physical_objects.each do |po|
        po.update_column :unit_id, new.id
        print '.'
      end
      puts "Destroying unit"
      old.reload
      old.destroy!
    else
      puts "Units not found"
    end
  end
  def down
    puts "No action on rollback"
  end
end
