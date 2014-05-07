class CreatePreservationProblems < ActiveRecord::Migration
  def up
    create_table :preservation_problems do |t|
      t.belongs_to :open_reel_tm
      t.boolean :vinegar_odor
      t.boolean :fungus
      t.boolean :soft_binder_syndrome
      t.boolean :other_contaminants
      t.timestamps
    end
    #remove the column that this was broken out of
    remove_column :open_reel_tms, :preservation_problem
  end

  def down
    add_column :open_reel_tms, :preservation_problems, :string
    drop_table :preservation_problems
  end

end
