class AddDuplicateObjectConditionStatus < ActiveRecord::Migration
  def up
    Rake::Task["db:seed_data"].invoke("add")
  end
  def down
    cst = ConditionStatusTemplate.find_by(name: "Duplicate Physical Object")
    cst.destroy! if cst
  end
end
