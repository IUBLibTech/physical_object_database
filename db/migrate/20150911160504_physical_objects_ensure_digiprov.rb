class PhysicalObjectsEnsureDigiprov < ActiveRecord::Migration
  def up
    total = PhysicalObject.all.size
    errors = []
    puts "Ensuring Digital Provenance and validity for #{total} Physical Objects"
    PhysicalObject.find_each do |po|
      if po.digital_provenance.nil?
        po.ensure_digiprov
	if po.digital_provenance.save
          if po.valid?
            print "."
          else
            puts po.errors.inspect
	    errors << po.errors
          end
	else
	  puts po.digital_provenance.errors.inspect
	  errors << po.digital_provenance.errors
	end
      else
        if po.valid?
	  print "-"
	else
	  puts po.errors.inspect
	  errors << po.errors
	end
      end
    end
    puts "Finished ensuring Digital Provenance."
    puts "errors: " + errors.inspect
  end
  def down
    puts "No action on rollback."
  end
end
