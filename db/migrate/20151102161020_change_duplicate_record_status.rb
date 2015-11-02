class ChangeDuplicateRecordStatus < ActiveRecord::Migration
  def up
    cst = ConditionStatusTemplate.find_by(name: "Duplicate Record")
    if cst
      cst.name = "Duplicate POD Record"
      cst.description = "Indicates that this POD record is a duplicate of another POD record for the same physical object."
      cst.save!
    end
  end
  def down
    cst = ConditionStatusTemplate.find_by(name: "Duplicate POD Record")
    if cst
      cst.name = "Duplicate Record"
      cst.description = "Indicates that this record is a duplicate of another record for the same item."
      cst.save!
    end
  end
end
