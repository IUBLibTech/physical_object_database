class UpdateDigitalStatusOptionsColumn < ActiveRecord::Migration
  def up
    objects = DigitalStatus.where('options = "--- {}\n"')
    puts "Updating #{objects.size} digital_status records..."
    query = 'UPDATE digital_statuses SET options = NULL WHERE options = "--- {}\n"'
    ActiveRecord::Base.connection.execute(query)
  end
  def down
    objects = DigitalStatus.where('options IS NULL')
    puts "Updating #{objects.size} digital_status records..."
    query = 'UPDATE digital_statuses SET options = "--- {}\n" WHERE options IS NULL'
    ActiveRecord::Base.connection.execute(query)
  end
end
