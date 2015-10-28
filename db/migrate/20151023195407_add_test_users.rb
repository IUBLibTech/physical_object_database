class AddTestUsers < ActiveRecord::Migration
  
  def up
    if Rails.env.test?
      User::ROLES.each do |role|
		    u = User.new(username: role.to_s, name: role.to_s)
			  u.send("#{role}=", true)
			  puts "Saving new user: #{u.inspect}"
			  u.save!
      end
    end
  end
  def down
	  if Rails.env.test?
	    User::ROLES.each do |role|
		    u = User.where(username: role.to_s).first
        if u
			    puts "Destroying user: #{u.inspect}"
			    u.destroy!
        else
          puts "User not found: #{role}"
        end
		  end
		end
  end
end
