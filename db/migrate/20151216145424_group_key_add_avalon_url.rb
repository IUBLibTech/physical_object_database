class GroupKeyAddAvalonUrl < ActiveRecord::Migration
  def change
    add_column :group_keys, :avalon_url, :string
  end
end
