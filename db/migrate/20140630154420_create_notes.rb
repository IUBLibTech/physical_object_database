class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.references :physical_object, index: true
      t.text :body
      t.string :user

      t.timestamps
    end
  end
end
