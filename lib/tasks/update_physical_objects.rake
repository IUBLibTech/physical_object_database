# update_physical_objects.rake
# Rake tasks for updating attributes and grouping information
#
# Example use:
# rake pod:update_physical_objects[test] # default; no action taken, only logged
# rake pod:update_physical_objects[update]
#
namespace :pod do
  desc "update physical objects"
    task :update_physical_objects, [:mode] => :environment do |task, args|
      mode = args.mode || 'test'
      logger = Logger.new(Rails.root.join('log', 'update_physical_objects.log'))
      updates = YAML::load_file(Rails.root.join('lib','tasks', 'update_physical_objects.yml'))
      logger.info("Update physical objects called in mode: #{mode} in environment: #{Rails.env}")
      PhysicalObject.skip_callback(:save, :after, :resolve_group_position)
      updates.each_with_index do |row, index|
        row = row.with_indifferent_access
        id = row.delete(:id)
        mdpi_barcode = row.delete(:mdpi_barcode)
        if id.to_i.zero? && mdpi_barcode.to_i.zero?
          logger.info("Row #{index + 1}: No id or mdpi_barcode provided")
          next
        end
        atts = row.dup
        po_from_id = nil
        po_from_mdpi_barcode = nil
        if id.to_i.positive?
          begin
            po_from_id = PhysicalObject.find(id)
          rescue ActiveRecord::RecordNotFound
            logger.error("Row #{index + 1}: No record found for id #{id}")
            next
          end
        end
        if mdpi_barcode.to_i.positive?
          po_from_mdpi_barcode = PhysicalObject.where(mdpi_barcode: mdpi_barcode).first
          if po_from_mdpi_barcode.nil?
            logger.warn("Row #{index + 1}: No record found for mdpi_barcode #{mdpi_barcode}")
            next
          end
        end
        po = po_from_id || po_from_mdpi_barcode
        if po.nil?
          msg += 'NO ACTION: object not found'
          logger.info(msg)
        elsif (id.to_i.positive? && mdpi_barcode.to_i.positive?) && (po_from_id&.id != po_from_mdpi_barcode&.id)
          msg = "Row #{index + 1}: #{id} and #{mdpi_barcode} specify different objects!"
          logger.error(msg)
        else
          logger.info("Row #{index + 1}: Updating attributes: #{atts.keys.join(', ')}")
          atts.each do |att, value|
            msg = "unit: #{po.unit.abbreviation}, format: #{po.format}, title: #{po.title}, id: #{po.id}, #{po.mdpi_barcode}: "
            msg += "#{att}: "
            if po.send(att).to_s == value.to_s
              msg += "NO CHANGE: values (#{value}) match"
              logger.info(msg)
            else
              msg += "UPDATE: --#{value}-- replaces --#{po.send(att)}--"
              if mode == 'update'
                # special handling for grouping
                if att.to_s.in? ['group_total']
                  po.group_key.update_attribute(att, value)
                  if po.group_key.nil?
                    gk = GroupKey.create(id: po.group_key_id)
                    po.reload
                  end
                else
                  po.update_attribute(att, value)
                end
                if att.to_s.in? ['group_key_id']
                  if po.group_key.nil?
                    gk = GroupKey.create(id: po.group_key_id)
                    po.reload
                  end
                end
              end
              logger.info(msg)
            end
          end
        end
      end
      logger.info("Update physical objects completed.")
    end
end
