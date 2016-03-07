class NormalizeIuDigitalProvenances < ActiveRecord::Migration
  def up
    dps = DigitalProvenance.find_by_sql("select digital_provenances.* from physical_objects, digital_provenances, bins, batches where physical_objects.bin_id = bins.id and bins.batch_id = batches.id and physical_objects.id = digital_provenances.physical_object_id AND batches.destination = 'IU' and digital_provenances.digitizing_entity like 'Memnon%' order by physical_objects.mdpi_barcode")
    dps.each do |d|
      d.update_attributes(digitizing_entity: DigitalProvenance::IU_DIGITIZING_ENTITY)
    end
    puts "Normalized #{dps.size} digital provenance records"
  end

  def down
    puts "Nothing that can be done to recover from normalizing digital provenance digitizing entities"
  end
end
