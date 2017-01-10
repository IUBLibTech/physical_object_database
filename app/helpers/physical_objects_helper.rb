module PhysicalObjectsHelper
  require 'csv'

  #sets limit on spreadsheet rows; 0 disables
  ROW_LIMIT = 0

  #returns array of invalid headers
  def PhysicalObjectsHelper.invalid_csv_headers(file, filename)
    #FIXME: get valid headers list more elegantly?
    #start with list of headers not corresponding to fields in physical object or any tm
    valid_headers = ['Bin barcode', 'Bin identifier', 'Box barcode', 'Unit', 'Group key', 'Group total', 'Internal Notes', 'External Notes', 'Conditions']
    valid_headers += PhysicalObject.valid_headers
    TechnicalMetadatumModule.tm_class_formats.keys.each do |tm_class|
      valid_headers += tm_class.valid_headers
    end
    # parse_csv has already validated .csv, .xlsx filetype and parsing
    if filename.match /\.csv$/
      begin
        csv_headers = CSV.read(file, headers: false)[0]
      rescue
        opened_file = File.open(file, "r:ISO-8859-1:UTF-8")
        csv_headers = CSV.parse(opened_file, headers: false)[0]
      end
    elsif filename.match /\.xlsx$/
      csv_headers = Roo::Excelx.new(file, file_warning: :ignore).row(1)
    else
      #should never happen
    end
    invalid_headers_array = csv_headers.select { |x| !valid_headers.include?(x) }
    return invalid_headers_array
  end
  
  def PhysicalObjectsHelper.parse_csv(file, header_validation, picklist, filename, shipment = nil)
    succeeded = []
    failed = []
    index = 0
    current_group_key = ""
    previous_group_key = ""
    group_key_id = nil
    spreadsheet = Spreadsheet.new(filename: filename)
    if filename.match /\.csv$/
      filetype = :csv
      begin
        parsed_csv = CSV.read(file, headers: true)
      rescue
        opened_file = File.open(file, "r:ISO-8859-1:UTF-8")
        parsed_csv = CSV.parse(opened_file, headers: true)
      end
    elsif filename.match /\.xlsx$/
      filetype = :xlsx
      parsed_csv = Roo::Excelx.new(file, file_warning: :ignore)
    else
      spreadsheet.errors.add :base, "Invalid file format: #{file}"
      failed << [0, spreadsheet]
      return {"succeeded" => succeeded, "failed" => failed, spreadsheet: spreadsheet}
    end
    if filetype == :csv
      records_count = parsed_csv.length
    elsif filetype == :xlsx
      records_count = parsed_csv.last_row - 1
    end
    invalid_headers_array = (header_validation ? invalid_csv_headers(file, filename) : [])
    if invalid_headers_array.any?
      spreadsheet.errors.add :base, "The following headers are invalid: #{invalid_headers_array.inspect}.  Correct the file, or turn off header validation in upload submission."
      failed << [0, spreadsheet]
    elsif !ROW_LIMIT.zero? and records_count > ROW_LIMIT
      spreadsheet.errors.add :base, "The spreadsheet contains #{records_count} records, which exceeds the limit of #{ROW_LIMIT}."
      failed << [0, spreadsheet]
    elsif !spreadsheet.save
      failed << [0, spreadsheet]
    else
      parsed_csv.each_with_index do |r, i|
        index += 1
        if (filetype == :csv && r.fields.all? { |cell| cell.nil? || cell.blank? })
          #silently skip blank rows; commented blank row reporting below
          #spreadsheet.errors.add :base, "Blank row; skipped" unless spreadsheet.errors[:base].any?
          #failed << [index, spreadsheet]
	elsif (filetype == :xlsx && r.all? { |cell| cell.nil? || cell.blank? })
	  #as for blank csv row
	#skip first row for XLSX
        elsif (filetype == :csv) || (filetype == :xlsx && i > 0)
	  if filetype == :xlsx
            # convert to hash; correct xlsx float conversion as individual fields are read
            r = Hash[parsed_csv.row(1).zip(r)]
	  end
          #FIXME: probably can refactor this to be called once for the spreadsheet
          unit_id = nil
          unit = Unit.find_by(abbreviation: r["Unit"])
          unit_id = unit.id unless unit.nil?
    
          bin_id = nil
          bin = Bin.find_by(mdpi_barcode: r["Bin barcode"].to_i)
          bin_id = bin.id unless bin.nil?
          if bin_id.nil? && r["Bin barcode"].to_i > 0
            bin = Bin.new(mdpi_barcode: r["Bin barcode"].to_i, identifier: r["Bin identifier"], description: "Created by spreadsheet upload of " + filename + " at " + Time.now.to_s.split(" ")[0,2].join(" ") + ", Row " + (index + 1).to_s)
            bin.spreadsheet = spreadsheet
            bin.save
            bin_id = bin.id
          end
    
          box_id = nil
          box = Box.find_by(mdpi_barcode: r["Box barcode"].to_i)
          box_id = box.id unless box.nil?
          if box_id.nil? && r["Box barcode"].to_i > 0
            box = Box.new(mdpi_barcode: r["Box barcode"].to_i, bin_id: bin_id)
            box.spreadsheet = spreadsheet
            box.save
            box_id = box.id
          end
          #physical objects are only associated to one container
          bin_id = nil if !box_id.nil?
    
          current_group_key = r["Group key"]
          group_total = r["Group total"].to_i
          group_total = 1 if group_total.zero?
          if current_group_key.blank?
            group_key_id = nil
          elsif
            current_group_key != previous_group_key
            group_key = GroupKey.new
            group_key.group_total = group_total
            group_key.save
            group_key_id = group_key.id
            previous_group_key = current_group_key
          end
    
          group_position = r[PhysicalObject.human_attribute_name("group_position")].to_i
          group_position = 1 if group_position.zero?

	  # Convert floats to ints, coming from XLSX files read by Roo
	  [PhysicalObject.human_attribute_name("catalog_key"),
	   PhysicalObject.human_attribute_name("oclc_number"),
	   PhysicalObject.human_attribute_name("year")
	  ].each do |field_name|
	    r[field_name] = r[field_name].to_i if r[field_name].class == Float
	  end
    
          po = PhysicalObject.new(
              spreadsheet: spreadsheet,
              author: r[PhysicalObject.human_attribute_name("author")],
              bin_id: bin_id,
              box_id: box_id,
              call_number: r[PhysicalObject.human_attribute_name("call_number")],
              catalog_key: r[PhysicalObject.human_attribute_name("catalog_key")],
              collection_identifier: r[PhysicalObject.human_attribute_name("collection_identifier")],
              collection_name: r[PhysicalObject.human_attribute_name("collection_name")],
              format: r[PhysicalObject.human_attribute_name("format")],
              generation: r[PhysicalObject.human_attribute_name("generation")],
              group_key_id: group_key_id,
              group_position: group_position,
              home_location: r[PhysicalObject.human_attribute_name("home_location")],
              iucat_barcode: r[PhysicalObject.human_attribute_name("iucat_barcode")] ? r[PhysicalObject.human_attribute_name("iucat_barcode")].to_i : "0",
              mdpi_barcode: r[PhysicalObject.human_attribute_name("mdpi_barcode")] ? r[PhysicalObject.human_attribute_name("mdpi_barcode")].to_i : 0,
              oclc_number: r[PhysicalObject.human_attribute_name("oclc_number")],
              other_copies: !r[PhysicalObject.human_attribute_name("other_copies")].nil?,
              has_ephemera: !r[PhysicalObject.human_attribute_name("has_ephemera")].nil?,
              title: r[PhysicalObject.human_attribute_name("title")],
              title_control_number: r[PhysicalObject.human_attribute_name("title_control_number")],
              unit_id: unit_id,
              year: r[PhysicalObject.human_attribute_name("year")]
            )
          po.picklist = picklist unless picklist.nil?
          po.shipment = shipment unless shipment.nil?
          po.assign_inferred_workflow_status
          tm = po.ensure_tm
          tm.default_values_for_upload
          tm.class.parse_tm(tm, r) unless tm.nil?
          #Need extra check on box_id as we nullify bin_id for non-nil box_id
          if bin_id.nil? && r["Bin barcode"].to_i > 0 && box_id.nil?
            failed << [index, bin]
          elsif box_id.nil? && r["Box barcode"].to_i > 0
            failed << [index, box]
          elsif group_key_id.nil? && !current_group_key.blank?
            failed << [index, group_key] unless group_key.nil?
          elsif !po.valid?
            failed << [index, po]
          else
            if tm.nil?
              #error
            elsif tm.errors.any?
              failed << [index, tm]
            elsif po.save
              succeeded << po.id

              #import condition statuses
              conditions = r["Conditions"].to_s.split(/\s*\|+\s*/)
              conditions.each do |condition|
                condition_notes = ""
                if condition.match /:/
                  condition_note = condition.sub(/^.*?\s*:\s*/, '')
                  condition = condition.sub!(/\s*:.*/, '')
                end
                cst = ConditionStatusTemplate.find_by(name: condition, object_type: "Physical Object")
                cs = po.condition_statuses.new(condition_status_template: cst, notes: condition_note)
                if cst.nil?
                  cs.errors.add :base, "Invalid condition status: #{condition}"
                  failed << [index, cs]
                else
                  failed << [index, cs] unless cs.save
                end
              end

              #import notes
              notes = r["Internal Notes"].to_s.split(/\s*\|+\s*/)
              notes.each do |body_text|
                note = po.notes.new(body: body_text)
                failed << [index, note] unless note.save
              end
              notes = r["External Notes"].to_s.split(/\s*\|\s*/)
              notes.each do |body_text|
                note = po.notes.new(body: body_text, export: true )
                failed << [index, note] unless note.save
              end
            else
              #need to remove tm
              tm.destroy if tm.persisted?
              failed << [index, po]
            end
          end
        end
      end
      spreadsheet.created_at = spreadsheet.updated_at = Time.now
      spreadsheet.save
    end
    {"succeeded" => succeeded, "failed" => failed, spreadsheet: spreadsheet}
  end

end
