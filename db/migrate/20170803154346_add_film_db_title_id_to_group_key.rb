class AddFilmDbTitleIdToGroupKey < ActiveRecord::Migration
  def change
    add_column :group_keys, :filmdb_title_id, :integer
  end
end
