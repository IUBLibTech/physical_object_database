module PhysicalObjectsHelper
  require 'csv'
  
  def PhysicalObjectsHelper.parse_csv(file, picklist, filename="(unknown filename)")
    succeeded = []
    failed = []
    index = 0
    CSV.foreach(file, headers: true) do |r|
      #FIXME: probably can refactor this to be called once for the spreadsheet
      unit_id = nil
      unit = Unit.find_by(abbreviation: r["Unit"])
      unit_id = unit.id unless unit.nil?

      bin_id = nil
      bin = Bin.find_by(mdpi_barcode: r["Bin barcode"])
      bin_id = bin.id unless bin.nil?
      if bin_id.nil? && r["Bin barcode"].to_i > 0
        bin = Bin.new(mdpi_barcode: r["Bin barcode"].to_i, identifier: "Spreadsheet upload of " + filename + " at " + Time.now.to_s.split(" ")[0,2].join(" ") + ", Row " + (index + 1).to_s, description: "Created via spreadsheet upload")
        bin.save
        bin_id = bin.id
      end

      box_id = nil
      box = Box.find_by(mdpi_barcode: r["Box barcode"])
      box_id = box.id unless box.nil?
      if box_id.nil? && r["Box barcode"].to_i > 0
        box = Box.new(mdpi_barcode: r["Box barcode"].to_i, bin_id: bin_id)
        box.save
        box_id = box.id
      end

      po = PhysicalObject.new(
          author: r[PhysicalObject.human_attribute_name("author")],
          bin_id: bin_id,
          box_id: box_id,
          call_number: r[PhysicalObject.human_attribute_name("call_number")],
          catalog_key: r[PhysicalObject.human_attribute_name("catalog_key")],
          collection_identifier: r[PhysicalObject.human_attribute_name("collection_identifier")],
          collection_name: r[PhysicalObject.human_attribute_name("collection_name")],
          format: r[PhysicalObject.human_attribute_name("format")],
          generation: r[PhysicalObject.human_attribute_name("generation")],
          home_location: r[PhysicalObject.human_attribute_name("home_location")],
          iucat_barcode: r[PhysicalObject.human_attribute_name("iucat_barcode")] ? r[PhysicalObject.human_attribute_name("iucat_barcode")].to_i : 0,
          mdpi_barcode: r[PhysicalObject.human_attribute_name("mdpi_barcode")] ? r[PhysicalObject.human_attribute_name("mdpi_barcode")] : 0,
          oclc_number: r[PhysicalObject.human_attribute_name("oclc_number")],
          other_copies: !r[PhysicalObject.human_attribute_name("other_copies")].nil?,
          has_ephemera: !r[PhysicalObject.human_attribute_name("has_ephemera")].nil?,
          title: r[PhysicalObject.human_attribute_name("title")],
          title_control_number: r[PhysicalObject.human_attribute_name("title_control_number")],
          unit_id: unit_id,
          year: r[PhysicalObject.human_attribute_name("year")]
        )
      index += 1;
      po.picklist = picklist unless picklist.nil?
      if bin_id.nil? && r["Bin barcode"].to_i > 0
        failed << [index, bin]
      elsif box_id.nil? && r["Box barcode"].to_i > 0
        failed << [index, box]
      elsif po.save
        tm = po.create_tm(po.format)  
        tm.physical_object = po
        parse_tm(tm, r)
        tm.save
        succeeded << po.id
        #create duplicated records if there was a "Quantity" column specified
        q = r["Quantity"]
        if ! q.nil?
          po.save
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
       #failed contains pairs of spreadsheet row index and their constituent physical objects
       failed << [index, po]
      end
    end
    {"succeeded" => succeeded, "failed" => failed}
  end

  def PhysicalObjectsHelper.parse_tm(tm, row)
    if tm.is_a?(OpenReelTm)
      open_reel_parse(tm, row)
    elsif tm.is_a?(CdrTm)
      cdr_parse(tm, row)
    elsif tm.is_a?(DatTm)
      dat_parse(tm, row)
    else 

    end
  end

  def PhysicalObjectsHelper.cdr_parse(tm, row)
    tm.damage = row[CdrTm.human_attribute_name("damage")]
    tm.format_duration = row[CdrTm.human_attribute_name("format_duration")]

    #preservation problems
    unless row["Preservation problems"].nil?
      probs = row["Preservation problems"]
      tm.breakdown_of_materials = probs.include?(CdrTm.human_attribute_name("breakdown_of_materials"))
      tm.fungus = probs.include?(CdrTm.human_attribute_name("fungus"))
      tm.other_contaminants = probs.include?(CdrTm.human_attribute_name("other_contaminants"))
    end
  end

  def PhysicalObjectsHelper.dat_parse(tm, row)
    tm.format_duration = row[DatTm.human_attribute_name("format_duration")]
    tm.tape_stock_brand = row[DatTm.human_attribute_name("tape_stock_brand")]
    #sample rates
    unless row["Sample rate"].nil?
      probs = row["Sample rate"]
      tm.sample_rate_32k = probs.include?(DatTm.human_attribute_name("sample_rate_32k"))
      tm.sample_rate_44_1_k = probs.include?(DatTm.human_attribute_name("sample_rate_44_1_k"))
      tm.sample_rate_48k = probs.include?(DatTm.human_attribute_name("sample_rate_48k"))
      tm.sample_rate_96k = probs.include?(DatTm.human_attribute_name("sample_rate_96k"))
    end
    #preservation problems
    unless row["Preservation problems"].nil?
      probs = row["Preservation problems"]
      tm.fungus = probs.include?(DatTm.human_attribute_name("fungus"))
      tm.soft_binder_syndrome = probs.include?(DatTm.human_attribute_name("soft_binder_syndrome"))
      tm.other_contaminants = probs.include?(DatTm.human_attribute_name("other_contaminants"))
    end
  end

  def PhysicalObjectsHelper.open_reel_parse(tm, row)
    tm.pack_deformation = row[OpenReelTm.human_attribute_name("pack_deformation")]
    tm.reel_size = row[OpenReelTm.human_attribute_name("reel_size")]
    tm.tape_stock_brand = row[OpenReelTm.human_attribute_name("tape_stock_brand")]
    #preservation problems
    unless row["Preservation problems"].nil?
      probs = row["Preservation problems"]
      tm.fungus = probs.include?(OpenReelTm.human_attribute_name("fungus"))
      tm.soft_binder_syndrome = probs.include?(OpenReelTm.human_attribute_name("soft_binder_syndrom"))
      tm.vinegar_syndrome = probs.include?(OpenReelTm.human_attribute_name("vinegar_syndrome"))
      tm.other_contaminants = probs.include?(OpenReelTm.human_attribute_name("other_contaminants"))
    end

    unless row["Playback speed"].nil?
      pbs = row["Playback speed"]
      tm.zero_point9375_ips = pbs.include?(OpenReelTm.human_attribute_name("zero_point9375_ips"))
      tm.one_point875_ips = pbs.include?(OpenReelTm.human_attribute_name("one_point875_ips"))
      tm.three_point75_ips = pbs.include?(OpenReelTm.human_attribute_name("three_point75_ips"))
      tm.seven_point5_ips = pbs.include?(OpenReelTm.human_attribute_name("seven_point5_ips"))
      tm.fifteen_ips = pbs.include?(OpenReelTm.human_attribute_name("fifteen_ips"))
      tm.thirty_ips = pbs.include?(OpenReelTm.human_attribute_name("thirty_ips"))
    end

    unless row["Track configuration"].nil?
      tc = row["Track configuration"]
      tm.full_track = tc.include?(OpenReelTm.human_attribute_name("full_track"))
      tm.half_track = tc.include?(OpenReelTm.human_attribute_name("half_track"))
      tm.quarter_track = tc.include?(OpenReelTm.human_attribute_name("quarter_track"))
      tm.unknown_track = tc.include?(OpenReelTm.human_attribute_name("unknown_track"))
    end

    unless row["Tape thickness"].nil?
      tt = row["Tape thickness"]
      tm.zero_point5_mils = tt.include?(OpenReelTm.human_attribute_name("zero_point5_mils"))
      tm.one_mils = tt.include?(OpenReelTm.human_attribute_name("one_mils"))
      tm.one_point5_mils = tt.include?(OpenReelTm.human_attribute_name("one_point5_mils"))
    end

    unless row["Sound field"].nil?
      sf = row["Sound field"]
      tm.mono = sf.include?(OpenReelTm.human_attribute_name("mono"))
      tm.stereo = sf.include?(OpenReelTm.human_attribute_name("stereo"))
      tm.unknown_sound_field = sf.include?(OpenReelTm.human_attribute_name("unknown_sound_field"))
    end

    # tape base
    unless row["Tape base"].nil?
      tb = row["Tape base"]
      tm.acetate_base = tb.include?(OpenReelTm.human_attribute_name("acetate_base"))
      tm.polyester_base = tb.include?(OpenReelTm.human_attribute_name("polyester_base"))
      tm.pvc_base = tb.include?(OpenReelTm.human_attribute_name("pvc_base"))
      tm.paper_base = tb.include?(OpenReelTm.human_attribute_name("paper_base"))
    end

    # directions recorded
    unless row["Directions recorded"].nil?
      dr = row["Directions recorded"]
      tm.one_direction = dr.include?(OpenReelTm.human_attribute_name("one_direction"))
      tm.two_directions = dr.include?(OpenReelTm.human_attribute_name("two_directions"))
      tm.unknown_direction = dr.include?(OpenReelTm.human_attribute_name("unknown_sound_field"))
    end

  end

end
