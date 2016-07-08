class AddAverageDurationToBins < ActiveRecord::Migration
  def change
    add_column :bins, :average_duration, :integer
  end
end
