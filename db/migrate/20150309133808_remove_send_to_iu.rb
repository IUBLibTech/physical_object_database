class RemoveSendToIu < ActiveRecord::Migration
  def up
  	ConditionStatus.includes(:condition_status_template).where(condition_status_templates: {name: 'Send To IU'}).each do |cs|
  		cs.update(condition_status_template_id: ConditionStatusTemplate.where(name: "Cannot go to Memnon").first.id) 		
  	end
  	old = ConditionStatusTemplate.find_by(name: 'Send to IU')
  	unless old.nil?
  		old.destroy!
  	end
  end

  def down
  	ConditionStatusTemplate.new(name: 'Send to IU', object_type: 'Physical Object', description: "Item should be digitized by the IU facility.").save!
  end
end
