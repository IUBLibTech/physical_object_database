class CreatePodReports < ActiveRecord::Migration
  def change
    create_table :pod_reports do |t|
      t.string :status
      t.string :filename

      t.timestamps null: false
    end
  end
end
