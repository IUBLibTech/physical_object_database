class NormalizeIuStudioName < ActiveRecord::Migration
  def up
    DigitalProvenance.where(digitizing_entity: "IU").update_all(digitizing_entity: DigitalProvenance::IU_DIGITIZING_ENTITY)
  end
end
