class RemoveFolkDanceUnit < ActiveRecord::Migration
  def up
    u = Unit.find_by(abbreviation: 'B-FOLKDANCE')
    atm = Unit.find_by(abbreviation: 'B-ATM')
    if u
      puts "Modifying #{u.physical_objects.size} objects:"
      u.physical_objects.each do |po|
        po.collection_name = 'IU International Folkdancers'
        po.unit = atm
        po.save!
        print '.'
      end
      puts "Destroying unit"
      u.reload
      u.destroy!
    else
      puts "Folkdance unit not found"
    end
  end
  def down
    u = Unit.find_by(abbreviation: 'B-FOLKDANCE')
    atm = Unit.find_by(abbreviation: 'B-ATM')
    if u
      puts "Folkdance unit already present"
    else
      puts "Creating folkdance unit"
      u = Unit.create!(abbreviation: 'B-FOLKDANCE', name: 'IU International Folkdancers', institution: 'Indiana University', campus: 'Bloomington')
    end
    puts "Modifying #{atm.physical_objects.where(collection_name: 'IU International Folkdancers').size} objects:"
    atm.physical_objects.where(collection_name: 'IU International Folkdancers').each do |po|
      po.collection_name = ''
      po.unit = u
      po.save!
      print '.'
    end
  end
end
