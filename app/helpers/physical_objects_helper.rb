module PhysicalObjectsHelper
  require 'csv'

  #sets limit on spreadsheet rows; 0 disables
  ROW_LIMIT = 0

  #returns array of invalid headers
  def PhysicalObjectsHelper.invalid_csv_headers(file, filename)
    #FIXME: get valid headers list more elegantly?
    #start with list of headers not corresponding to fields in physical object or any tm
    valid_headers = ['Batch identifier', 'Batch description', 'Bin barcode', 'Bin identifier', 'Box barcode', 'Unit', 'Group key', 'Group total', 'Internal Notes', 'External Notes', 'Conditions', 'Film title', 'Replaces']
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

  # For FilmDB XML
  def PhysicalObjectsHelper.parse_xml(xml)
    results = {}
    batch_lookups = { 'Batch identifier' => 'identifier', 'Batch description' => 'description' }
    bin_lookups = { 'Bin barcode' => 'mdpiBarcode', 'Bin identifier' => 'identifier' }
    # FIXME: verify colorSpace mapping
    po_lookups = { 'Format' => 'format', 'MDPI barcode' => 'mdpiBarcode', 'IUCAT barcode' => 'iucatBarcode', 'Unit' => 'unit', 'Gauge' => 'gauge', 'Frame rate' => 'frameRate', 'Sound' => 'sound', 'Clean' => 'clean', 'Resolution' => 'resolution', 'Color space' => 'colorSpace', 'Mold' => 'mold', 'AD strip' => 'conditions/adStrip', 'Return to' => 'returnTo', 'Anamorphic' => 'anamorphic', 'Conservation actions' => 'conservationActions', 'Track count' => 'trackCount', 'Format duration' => 'duration', 'Footage' => 'footage', 'Title' => 'title', 'Collection name' => 'collectionName', 'Title control number' => 'iucatTitleControlNumber', 'Film title' => 'titleId',
     }
    # FIXME: add workflow, on_demand, return_on_original_reel
    multivalued_fieldsets = {
      'Aspect ratio' => {
        '1.33:1' => 'aspectRatios/ratio_1_33_1',
        '1.37:1' => 'aspectRatios/ratio_1_37_1',
        '1.66:1' => 'aspectRatios/ratio_1_66_1',
        '1.85:1' => 'aspectRatios/ratio_1_85_1',
        '2.35:1' => 'aspectRatios/ratio_2_35_1',
        '2.39:1' => 'aspectRatios/ratio_2_39_1',
        '2.59:1' => 'aspectRatios/ratio_2_59_1',
        '2.66:1' => 'aspectRatios/ratio_2_66_1',
      },
      'Film generation' => {
        'Projection print' => 'generations/projectionPrint',
        'A roll' => 'generations/aRoll',
        'B roll' => 'generations/bRoll',
        'C roll' => 'generations/cRoll',
        'D roll' => 'generations/dRoll',
        'Answer print' => 'generations/answerPrint',
        'Camera original' => 'generations/cameraOriginal',
        'Composite' => 'generations/composite',
        'Duplicate' => 'generations/duplicate',
        'Edited' => 'generations/edited',
        'Fine grain master' => 'generations/fineGrainMaster',
        'Intermediate' => 'generations/intermediate',
        'Kinescope' => 'generations/kinescope',
        'Magnetic track' => 'generations/magneticTrack',
        'Master' => 'generations/master',
        'Mezzanine' => 'generations/mezzanine',
        'Negative' => 'generations/negative',
        'Optical soundtrack' => 'generations/OpticalSoundTrack',
        'Original' => 'generations/original',
        'Outs and trims' => 'generations/outsAndTrims',
        'Positive' => 'generations/positive',
        'Reversal' => 'generations/reversal',
        'Separation master' => 'generations/separationMaster',
        'Work print' => 'generations/workPrint',
      },
      'Base' => {
        'Acetate' => 'bases/acetate',
        'Polyester' => 'bases/polyester',
        'Nitrate' => 'bases/nitrate',
        'Mixed' => 'bases/mixed',
      },
      'Color' => {
        'Black and white' => 'color/blackAndWhite',
        'Toned' => 'color/blackAndWhiteToned',
        'Tinted' => 'color/blackAndWhiteTinted',
        'Hand coloring' => 'color/handColoring',
        'Stencil coloring' => 'color/stencilColoring',
        'Color' => 'color/color',
        'Ektachrome' => 'color/ektachrome',
        'Kodachrome' => 'color/kodachrome',
        'Technicolor' => 'color/technicolor',
        'Anscochrome' => 'color/anscochrome',
        'Eco' => 'color/eco',
        'Eastman' => 'color/eastman',
      },
      'Sound field' => {
        'Mono' => 'soundConfigurations/mono',
        'Stereo' => 'soundConfigurations/stereo',
        'Surround' => 'soundConfigurations/surround',
        'Multi-track (i.e. Maurer)' => 'soundConfigurations/multiTrack',
        'Dual mono' => 'soundConfigurations/dual',
      },
      'Sound content type' => {
        'Music track' => 'soundContent/musicTrack',
        'Effects track' => 'soundContent/effectsTrack',
        'Composite track' => 'soundContent/compositeTrack',
        'Dialog' => 'soundContent/dialog',
        'Outtakes' => 'soundContent/outtakes',
      },
      'Sound format type' => {
        'Optical' => 'soundFormats/optical',
        'Optical: variable area' => 'soundFormats/opticalVariableArea',
        'Optical: variable density' => 'soundFormats/opticalVariableDensity',
        'Magnetic' => 'soundFormats/magnetic',
        'Digital: SDDS' => 'soundFormats/digitalSdds',
        'Digital: DTS' => 'soundFormats/digitalDts',
        'Digital: Dolby Digital' => 'soundFormats/dolbyDigital',
        'Digital: Dolby A' => 'soundFormats/dolbyA',
        'Digital: Dolby SR' => 'soundFormats/dolbySr',
        'Sound on separate media' => 'soundFormats/soundOnSeparateMedia',
      },
      'Stock' => {
        'Agfa' => 'stocks/agfa',
        'Ansco' => 'stocks/ansco',
        'Dupont' => 'stocks/dupont',
        'Orwo' => 'stocks/orwo',
        'Fuji' => 'stocks/fuji',
        'Gaevert' => 'stocks/gaevert',
        'Kodak' => 'stocks/kodak',
        'Ferrania' => 'stocks/ferrania',
        '3M' => 'stocks/three_m',
        'Agfa-Gevaert' => 'stocks/agfa_gevaert',
        'Pathe' => 'stocks/pathe',
        'Unknown' => 'stocks/unknown',
      }
    }
    condition_ratings = {
      'Brittle' => 'conditions/condition[type/text()="Brittle"]/value',
      'Broken' => 'conditions/condition[type/text()="Broken"]/value',
      'Channeling' => 'conditions/condition[type/text()="Channeling"]/value',
      'Color fade' => 'conditions/condition[type/text()="Color Fade"]/value',
      'Cue marks' => 'conditions/condition[type/text()="Cue Marks"]/value',
      'Dirty' => 'conditions/condition[type/text()="Dirty"]/value',
      'Edge damage' => 'conditions/condition[type/text()="Edge Damage"]/value',
      'Holes' => 'conditions/condition[type/text()="Holes"]/value',
      'Peeling' => 'conditions/condition[type/text()="Peeling"]/value',
      'Perforation damage' => 'conditions/condition[type/text()="Perforation Damage"]/value',
      'Rusty' => 'conditions/condition[type/text()="Rusty"]/value',
      'Scratches' => 'conditions/condition[type/text()="Scratches"]/value',
      'Soundtrack damage' => 'conditions/condition[type/text()="Soundtrack Damage"]/value',
      'Splice damage' => 'conditions/condition[type/text()="Splice Damage"]/value',
      'Stains' => 'conditions/condition[type/text()="Stains"]/value',
      'Sticky' => 'conditions/condition[type/text()="Sticky"]/value',
      'Tape residue' => 'conditions/condition[type/text()="Tape Residue"]/value',
      'Tearing' => 'conditions/condition[type/text()="Tearing"]/value',
      'Warp' => 'conditions/condition[type/text()="Warp"]/value',
      'Water damage' => 'conditions/condition[type/text()="Water Damage"]/value',
    }
    preservation_problems = {
      'Poor wind' => 'conditions/condition[type/text()="Poor Wind"]/type',
      'Not on core or reel' => 'conditions/condition[type/text()="Not on Core or Reel"]/type',
      'Lacquer treated' => 'conditions/condition[type/text()="Lacquer Treated"]/type',
      'Replasticized' => 'conditions/condition[type/text()="Replasticized"]/type',
      'Dusty' => 'conditions/condition[type/text()="Dusty"]/type',
      'Spoking' => 'conditions/condition[type/text()="Spoking"]/type',
    }

    valid_headers = batch_lookups.keys + bin_lookups.keys + po_lookups.keys + multivalued_fieldsets.keys + condition_ratings.keys + ['Preservation problems']

    tempfile = Tempfile.new(['filmdb_', '.csv'])
    begin
      CSV.open(tempfile.path, 'w') do |csv|
        csv << valid_headers
      end
      @xml = Nokogiri::XML(xml).remove_namespaces!
      @xml.xpath('//batch').each do |batch|
        batch_values = batch_lookups.values.map { |v| batch.xpath(v)&.first&.content.to_s }
        batch.xpath('bin').each do |bin|
          bin_values = bin_lookups.values.map { |v| bin.xpath(v)&.first&.content.to_s }
          bin.xpath('physicalObjects/physicalObject').each do |po|
            po_values = po_lookups.values.map { |v| po.xpath(v)&.first&.content.to_s }
            # replace true/false from FilmDB with yes/no for Memnon
            po_values.map! { |e| e.match(/^true$/i) ? 'Yes' : e }
            po_values.map! { |e| e.match(/^false$/i) ? 'No' : e }
# FIXME: add film title for group key, replaces
            condition_values = condition_ratings.values.map { |v| po.xpath(v)&.first&.content.to_s[0].to_i }
            multi_values = multivalued_fieldsets.values.map do |h|
              h.select { |k,v| po.xpath(v)&.first&.content.to_s == 'true' }.keys.join(', ')
            end 
            preservation_problem_values = Array.wrap(preservation_problems.select { |k,v| po.xpath(v)&.first&.content.to_s.present? }.keys.join(', '))
            CSV.open(tempfile.path, 'ab') do |csv|
               row = batch_values + bin_values + po_values + multi_values + condition_values + preservation_problem_values
               csv << row
            end
          end
        end
      end
      results = PhysicalObjectsHelper.parse_csv(tempfile.path, true, nil, Pathname.new(tempfile.path).basename.to_s)
    ensure
      tempfile.close
      tempfile.unlink
    end
    results
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

          batch_id = nil
          batch = Batch.find_by(identifier: r['Batch identifier'])
          batch_id = batch.id unless batch.nil?
# FIXME: read batch description, if available?
          if batch_id.nil? && r['Batch identifier'].present?
            batch = Batch.new(identifier: r['Batch identifier'], description: r['Batch description'], format: r[PhysicalObject.human_attribute_name("format")])
            # FIXME: add test for batch creation?
            batch.spreadsheet = spreadsheet
            batch.save # FIXME: catch failure case for batch save?  what about bin save?
            batch_id = batch.id
          end
    
          bin_id = nil
          bin = Bin.find_by(mdpi_barcode: r["Bin barcode"].to_i)
          bin_id = bin.id unless bin.nil?
#FIXME: read bin description, if available?
          if bin_id.nil? && r["Bin barcode"].to_i > 0
            bin = Bin.new(mdpi_barcode: r["Bin barcode"].to_i, identifier: r["Bin identifier"], description: "Created by spreadsheet upload of " + filename + " at " + Time.now.to_s.split(" ")[0,2].join(" ") + ", Row " + (index + 1).to_s, batch_id: batch_id, format: r[PhysicalObject.human_attribute_name("format")])
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
          film_title = r["Film title"].to_i
          group_total = r["Group total"].to_i
          group_total = 1 if group_total.zero?
          if current_group_key.blank?
            if film_title > 0
              group_key = PhysicalObjectsHelper.group_key_for_filmdb_title(film_title)
              group_key.group_total = group_total
              group_key.save
              group_key_id = group_key.id
            else
              group_key_id = nil
            end
          elsif current_group_key != previous_group_key
            group_key = PhysicalObjectsHelper.group_key_for_filmdb_title(film_title)
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
          unless tm.nil?
            tm.default_values_for_upload
            tm.class.parse_tm(tm, r)
          end
          if batch_id.nil? && r['Batch identifier'].present?
            failed << [index, batch]
          #Need extra check on box_id as we nullify bin_id for non-nil box_id
          elsif bin_id.nil? && r["Bin barcode"].to_i > 0 && box_id.nil?
            failed << [index, bin]
          elsif box_id.nil? && r["Box barcode"].to_i > 0
            failed << [index, box]
          elsif group_key_id.nil? && !current_group_key.blank?
            failed << [index, group_key] unless group_key.nil?
          elsif !po.valid?
            failed << [index, po]
          else
            if tm.nil?
              #error handled earlier
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

  def PhysicalObjectsHelper.group_key_for_filmdb_title(title_id)
    group_key = nil
    group_key = GroupKey.where(filmdb_title_id: title_id).first if title_id.to_i > 0
    group_key = GroupKey.create(filmdb_title_id: title_id) if group_key.nil?
    group_key
  end
end
