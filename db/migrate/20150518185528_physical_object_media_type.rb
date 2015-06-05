class PhysicalObjectMediaType < ActiveRecord::Migration
  def up
  	add_column :physical_objects, :audio, :boolean
  	add_column :physical_objects, :video, :boolean
  	PhysicalObject.where("format='LP' or format = 'CD-R' or format='DAT' or format='Open Reel Audio Tape'").update_all(video: false, audio: true)
  	PhysicalObject.where("format='Betacam'").update_all(video: true, audio: false)
  end
  def down
  	remove_column :physical_objects, :audio
  	remove_column :physical_objects, :video
  end
end
