module PhysicalObjectsHelper
	require 'csv'
	
	def PhysicalObjectsHelper.parse_csv(file)
  	succeeded = []
    failed = []
    index = 0
  	CSV.foreach(file, headers: true) do |r|
  		po = PhysicalObject.new(
          author: r["Author"],
      		call_number: r["Call Number"],
          catalog_key: r["Catalog Key"],
		      collection_identifier: r["Collection Identifier"],
          collection_name: r["Collection Name"],
          format: r["Format"],
          generation: r["Generation"],
		      home_location: r["Primary Location"],
          iucat_barcode: r["IU Barcode"] ? r["IU Barcode"].to_i : 0,
          mdpi_barcode: r["MDPI Barcode"] ? r["MDPI Barcode"] : 0,
          oclc_number: r["OCLC Number"],
          other_copies: !r["Other Copies"].nil?,
          has_media: !r["Has Ephemira"].nil?,
          title: r["Title"],
          title_control_number: r["Title Control Number"],
          unit: r["Unit"],
          year: r["Year"]
  			)
      index += 1;
  		if po.save
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
    else 

    end
  end

  def PhysicalObjectsHelper.open_reel_parse(tm, row)
    tm.pack_deformation = row["Pack Deformation"]
    tm.reel_size = row["Reel Size"]
    tm.tape_stock_brand = row["Tape Stock Brand"]
    #preservation problems
    unless row["Preservation Problems"].nil?
      probs = row["Preservation Problems"]
      tm.fungus = probs.include?(OpenReelTm.human_attribute_name("fungus"))
      tm.soft_binder_syndrome = probs.include?(OpenReelTm.human_attribute_name("soft_binder_syndrom"))
      tm.vinegar_syndrome = probs.include?(OpenReelTm.human_attribute_name("vinegar_syndrome"))
      tm.other_contaminants = probs.include?(OpenReelTm.human_attribute_name("other_contaminants"))
    end

    unless row["Playback Speed"].nil?
      pbs = row["Playback Speed"]
      tm.zero_point9375_ips = pbs.include?(OpenReelTm.human_attribute_name("zero_point9375_ips"))
      tm.one_point875_ips = pbs.include?(OpenReelTm.human_attribute_name("one_point875_ips"))
      tm.three_point75_ips = pbs.include?(OpenReelTm.human_attribute_name("three_point75_ips"))
      tm.seven_point5_ips = pbs.include?(OpenReelTm.human_attribute_name("seven_point5_ips"))
      tm.fifteen_ips = pbs.include?(OpenReelTm.human_attribute_name("fifteen_ips"))
      tm.thirty_ips = pbs.include?(OpenReelTm.human_attribute_name("thirty_ips"))
    end

    unless row["Track Configuration"].nil?
      tc = row["Track Configuration"]
      tm.full_track = tc.include?(OpenReelTm.human_attribute_name("full_track"))
      tm.half_track = tc.include?(OpenReelTm.human_attribute_name("half_track"))
      tm.quarter_track = tc.include?(OpenReelTm.human_attribute_name("quarter_track"))
      tm.unknown_track = tc.include?(OpenReelTm.human_attribute_name("unknown_track"))
    end

    unless row["Tape Thickness"].nil?
      tt = row["Tape Thickness"]
      tm.zero_point5_mils = tt.include?(OpenReelTm.human_attribute_name("zero_point5_mils"))
      tm.one_mils = tt.include?(OpenReelTm.human_attribute_name("one_mils"))
      tm.one_point5_mils = tt.include?(OpenReelTm.human_attribute_name("one_point5_mils"))
    end

    unless row["Sound Field"].nil?
      sf = row["Sound Field"]
      tm.mono = sf.include?(OpenReelTm.human_attribute_name("mono"))
      tm.stereo = sf.include?(OpenReelTm.human_attribute_name("stereo"))
      tm.unknown_sound_field = sf.include?(OpenReelTm.human_attribute_name("unknown_sound_field"))
    end

    # tape base
    unless row["Tape Base"].nil?
      tb = row["Tape Base"]
      tm.acetate_base = tb.include?(OpenReelTm.human_attribute_name("acetate_base"))
      tm.polyester_base = tb.include?(OpenReelTm.human_attribute_name("polyester_base"))
      tm.pvc_base = tb.include?(OpenReelTm.human_attribute_name("pvc_base"))
      tm.paper_base = tb.include?(OpenReelTm.human_attribute_name("paper_base"))
    end

    # directions recorded
    unless row["Directions Recorded"].nil?
      dr = row["Directions Recorded"]
      tm.one_direction = dr.include?(OpenReelTm.human_attribute_name("one_direction"))
      tm.two_directions = dr.include?(OpenReelTm.human_attribute_name("two_directions"))
      tm.unknown_direction = dr.include?(OpenReelTm.human_attribute_name("unknown_sound_field"))
    end

  end

end
