module PhysicalObjectsHelper
	require 'csv'
	
	def PhysicalObjectsHelper.parse_csv(file)
  	succeeded = []
    failed = []
    index = 0
  	CSV.foreach(file, headers: true) do |r|
  		po = PhysicalObject.new(
  				mdpi_barcode: r["MDPI Barcode"] ? r["MDPI Barcode"] : 0,
      		iucat_barcode: r["IU Barcode"] ? r["IU Barcode"].to_i : 0,
      		shelf_location: r["Shelf Location"],
      		call_number: r["Call Number"],
      		title: r["Title"],
      		title_control_number: r["Title Control Number"],
      		format: r["Format"],
      		unit: r["Unit"],
		      collection_identifier: r["Collection Primary ID"],
		      home_location: r["Primary Location"],
		      shelf_location: r["Secondary Location"],
		      format_duration: r["Duration"],
  			)
      index += 1;
  		if po.save
        tm = po.create_tm(po.format)	
    		tm.physical_object = po
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

end
