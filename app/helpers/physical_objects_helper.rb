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
		      collection_identifier: r["Collection Primary ID"],
          collection_name: r["Collection Name"],
          format: r["Format"],
          generation: r["Generation"],
		      home_location: r["Primary Location"],
          iucat_barcode: r["IU Barcode"] ? r["IU Barcode"].to_i : 0,
          mdpi_barcode: r["MDPI Barcode"] ? r["MDPI Barcode"] : 0,
          oclc_number: r["OCLC Number"],
          other_copies: (!r["Other Copies"].nil? and r["Other Copies"].downcase == "true") ? true : false,
          has_media: (!r["Has Ephemira"].nil? and r["Has Ephemira"].downcase =="true") ? true : false,
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
    # TODO: handle multi value  
    
    tm.pack_deformation = row["Pack Deformation"]
    tm.reel_size = row["Reel Size"]

  end

end
