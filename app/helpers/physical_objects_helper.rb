module PhysicalObjectsHelper
  require 'csv'

  #returns array of invalid headers
  def PhysicalObjectsHelper.invalid_csv_headers(file)
    #FIXME: get valid headers list more elegantly?
    valid_headers = ['Bin barcode', 'Bin identifier', 'Box barcode', 'Unit', 'Group key', 'Copies']
    valid_headers += PhysicalObject.valid_headers
    TechnicalMetadatumModule::TM_CLASS_FORMATS.keys.each do |tm_class|
      valid_headers += tm_class.valid_headers
    end
    #FIXME: get CSV headers more more elegantly
    csv_headers = []
    CSV.foreach(file, headers: false) do |row|
      csv_headers = row.to_a
      break
    end
    invalid_headers_array = csv_headers.select { |x| !valid_headers.include?(x) }
    return invalid_headers_array
  end
  
  def PhysicalObjectsHelper.parse_csv(file, header_validation, picklist, filename)
    succeeded = []
    failed = []
    index = 0
    current_group_key = ""
    previous_group_key = ""
    group_key_id = nil
    spreadsheet = Spreadsheet.new(filename: filename)
    invalid_headers_array = (header_validation ? invalid_csv_headers(file) : [])
    if invalid_headers_array.any?
      spreadsheet.errors[:base] << "The following headers are invalid: #{invalid_headers_array.inspect}.  Correct the file, or turn off header validation in upload submission."
      failed << [0, spreadsheet]
    elsif !spreadsheet.save
      failed << [0, spreadsheet]
    else
      CSV.foreach(file, headers: true) do |r|
        index += 1
        if r.fields.all? { |cell| cell.nil? || cell.blank? }
	  #silently skip blank rows; commented blank row reporting below
	  #spreadsheet.errors[:base] << "Blank row; skipped" unless spreadsheet.errors[:base].any?
	  #failed << [index, spreadsheet]
	else
          #FIXME: probably can refactor this to be called once for the spreadsheet
          unit_id = nil
          unit = Unit.find_by(abbreviation: r["Unit"])
          unit_id = unit.id unless unit.nil?
    
          bin_id = nil
          bin = Bin.find_by(mdpi_barcode: r["Bin barcode"])
          bin_id = bin.id unless bin.nil?
          if bin_id.nil? && r["Bin barcode"].to_i > 0
            bin = Bin.new(mdpi_barcode: r["Bin barcode"].to_i, identifier: r["Bin identifier"], description: "Created by spreadsheet upload of " + filename + " at " + Time.now.to_s.split(" ")[0,2].join(" ") + ", Row " + (index + 1).to_s)
            bin.spreadsheet = spreadsheet
            bin.save
            bin_id = bin.id
          end
    
          box_id = nil
          box = Box.find_by(mdpi_barcode: r["Box barcode"])
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
          if current_group_key.blank?
            group_key_id = nil
          else
            if current_group_key != previous_group_key
              group_key = GroupKey.new
              group_key.save
              group_key_id = group_key.id
              previous_group_key = current_group_key
	    end
          end
    
          group_position = r[PhysicalObject.human_attribute_name("group_position")].to_i
          group_position = 1 if group_position.zero?
    
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
              iucat_barcode: r[PhysicalObject.human_attribute_name("iucat_barcode")] ? r[PhysicalObject.human_attribute_name("iucat_barcode")] : "0",
              mdpi_barcode: r[PhysicalObject.human_attribute_name("mdpi_barcode")] ? r[PhysicalObject.human_attribute_name("mdpi_barcode")] : 0,
              oclc_number: r[PhysicalObject.human_attribute_name("oclc_number")],
              other_copies: !r[PhysicalObject.human_attribute_name("other_copies")].nil?,
              has_ephemera: !r[PhysicalObject.human_attribute_name("has_ephemera")].nil?,
              title: r[PhysicalObject.human_attribute_name("title")],
              title_control_number: r[PhysicalObject.human_attribute_name("title_control_number")],
              unit_id: unit_id,
              year: r[PhysicalObject.human_attribute_name("year")]
            )
          po.picklist = picklist unless picklist.nil?
          #Need extra check on box_id as we nullify bin_id for non-nil box_id
          if bin_id.nil? && r["Bin barcode"].to_i > 0 && box_id.nil?
            failed << [index, bin]
          elsif box_id.nil? && r["Box barcode"].to_i > 0
            failed << [index, box]
          #FIXME: add check for group_key?
	  elsif !po.valid?
	    failed << [index, po]
          else
            tm = po.ensure_tm
            tm.class.parse_tm(tm, r) unless tm.nil?
            if tm.nil?
              #error
            elsif !tm.save
              failed << [index, tm]
            elsif po.save
              succeeded << po.id
              #create duplicated records if there was a "Quantity" column specified
              q = r["Quantity"]
              unless q.nil? || q.blank? || q.to_i < 2
                (q.to_i - 1).times do |i|
                  p_clone = po.dup
                  p_clone.save
                  succeeded << p_clone.id
                  tm_clone = tm.dup
                  tm_clone.physical_object = p_clone
                  tm_clone.save
                end
              end
            else
              #need to remove tm
              tm.destroy
              failed << [index, po]
            end
          end
	end
      end
    end
    {"succeeded" => succeeded, "failed" => failed, spreadsheet: spreadsheet}
  end

end
