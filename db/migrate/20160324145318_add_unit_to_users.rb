class AddUnitToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :unit, index: true
  end
end
