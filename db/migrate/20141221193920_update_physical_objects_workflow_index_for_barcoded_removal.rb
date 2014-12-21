class UpdatePhysicalObjectsWorkflowIndexForBarcodedRemoval < ActiveRecord::Migration
  def up
    barcoded_template = WorkflowStatusTemplate.find_by(object_type: "Physical Object", name: "Barcoded")
    on_picklist_template = WorkflowStatusTemplate.find_by(object_type: "Physical Object", name: "On Pick List")
    # update physical object workflow_status_template refs
    WorkflowStatus.where(workflow_status_template_id: barcoded_template.id).update_all(workflow_status_template_id: on_picklist_template.id)
    # destroy Barcoded
    barcoded_template.destroy
    # update following
    WorkflowStatusTemplate.where(object_type: "Physical Object", name: "On Pick List").update_all(sequence_index: 2)
    WorkflowStatusTemplate.where(object_type: "Physical Object", name: "Boxed").update_all(sequence_index: 3)
    WorkflowStatusTemplate.where(object_type: "Physical Object", name: "Binned").update_all(sequence_index: 4)
    WorkflowStatusTemplate.where(object_type: "Physical Object", name: "Unpacked").update_all(sequence_index: 5)
    WorkflowStatusTemplate.where(object_type: "Physical Object", name: "Returned to Unit").update_all(sequence_index: 6)
    # update physical object sequence_index
    update_workflow_indexes
  end
  def down
    # create Barcoded
    WorkflowStatusTemplate.create(object_type: "Physical Object", name: "Barcoded", description: "The item has been supplied with an MDPI barcode.", sequence_index: 2)
    # update following
    WorkflowStatusTemplate.where(object_type: "Physical Object", name: "On Pick List").update_all(sequence_index: 3)
    WorkflowStatusTemplate.where(object_type: "Physical Object", name: "Boxed").update_all(sequence_index: 4)
    WorkflowStatusTemplate.where(object_type: "Physical Object", name: "Binned").update_all(sequence_index: 5)
    WorkflowStatusTemplate.where(object_type: "Physical Object", name: "Unpacked").update_all(sequence_index: 6)
    WorkflowStatusTemplate.where(object_type: "Physical Object", name: "Returned to Unit").update_all(sequence_index: 7)
    # update physical object sequence_index
    update_workflow_indexes
  end
  def update_workflow_indexes
    PhysicalObject.all.each do |po|
      unless po.workflow_statuses.empty?
        po.workflow_index = po.workflow_statuses.last.workflow_status_template.sequence_index
        po.save
      end
    end
  end
end
