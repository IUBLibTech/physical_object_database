class NormalizeDigitizingEntity < ActiveRecord::Migration
  def up
    DigitalProvenance.transaction do
      # Where digital prov says IU but shipped to Memnon
      DigitalProvenance.find_by_sql(
        "SELECT digital_provenances.* "+
        "FROM physical_objects, digital_provenances, bins "+
        "WHERE physical_objects.id = digital_provenances.physical_object_id and physical_objects.bin_id = bins.id "+
        "AND digital_provenances.digitizing_entity like 'IU%' AND bins.destination = 'Memnon'"
      ).each do |dp|
        puts "Normalizing digital provenance on physical_object: #{dp.physical_object_id}: IU changed to Memnon"
        dp.update_attributes!(digitizing_entity: DigitalProvenance::MEMNON_DIGITIZING_ENTITY)
      end

      # Where digital prov says Memnon but shipped to IU
      DigitalProvenance.find_by_sql(
          "SELECT digital_provenances.* "+
          "FROM physical_objects, digital_provenances, bins "+
          "WHERE physical_objects.id = digital_provenances.physical_object_id and physical_objects.bin_id = bins.id "+
          "AND digital_provenances.digitizing_entity like 'Memnon%' AND bins.destination = 'IU'"
      ).each do |dp|
        puts "Normalizing digital provenance on po: #{dp.physical_object_id}: Memnon changed to IU"
        dp.update_attributes!(digitizing_entity: DigitalProvenance::IU_DIGITIZING_ENTITY)
      end
    end
  end

  def down
    # nothing we can undo...
  end
end
