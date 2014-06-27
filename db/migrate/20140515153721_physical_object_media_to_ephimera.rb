class PhysicalObjectMediaToEphimera < ActiveRecord::Migration
  def up
  	# rename_column :physical_objects, :has_media, :has_ephemira
  end

  def dow
  	# rename_column :physical_objects, :has_ephemira, :has_media
  end
end
