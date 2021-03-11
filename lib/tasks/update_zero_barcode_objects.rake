# update_zero_barcode_objects.rake
# Rake tasks for updating attributes and grouping information
#
# Example use:
# rake pod:update_zero_barcode_objects[test] # default; no action taken, only logged
# rake pod:update_zero_barcode_objects[update]
#
namespace :pod do
  desc "update zero_barcode objects"
    task :update_zero_barcode_objects, [:mode] => :environment do |task, args|
      mode = args.mode || 'test'
      logger = Logger.new(Rails.root.join('log', 'update_zero_barcode_objects.log'))
      updates = YAML::load_file(Rails.root.join('lib','tasks', 'update_zero_barcode_objects.yml'))
      logger.info("Update zero_barcode objects called in mode: #{mode} in environment: #{Rails.env}")
      PhysicalObject.skip_callback(:save, :after, :resolve_group_position)
      updates.each_with_index do |row, index|
        row = row.with_indifferent_access
        group_key_id = row.delete(:group_key_id)
        mdpi_barcode = row.delete(:mdpi_barcode)
        unless mdpi_barcode.to_i.zero?
          logger.info("Row #{index + 1}: MDPI Barcode wasn't zero, skipping")
          next
        end
        unless group_key_id.positive?
          logger.info("Row #{index + 1}: No group key provided, skipping")
          next
        end
        atts = row.dup
        po_from_group_key = PhysicalObject.where(group_key_id: group_key_id, mdpi_barcode: [0, '0', nil])
        po = po_from_group_key.first
        if po.nil?
          msg = "Row #{index + 1}: group_key_id #{group_key_id} found zero objects, skipping"
          logger.info(msg)
        elsif po_from_group_key.size > 1
          msg = "Row #{index + 1}: group_key_id #{group_key_id} found multiple objects: #{po_from_group_key.map(&:id)}, skipping"
          logger.info(msg)
        else
          msg = "Row #{index + 1}: group_key_id #{group_key_id} found object #{po.id}"
          logger.info(msg)

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
                else
                  po.update_attribute(att, value)
                end
              end
              logger.info(msg)
            end
          end
        end
      end
      logger.info("Update zero_barcode objects completed.")
    end
end
