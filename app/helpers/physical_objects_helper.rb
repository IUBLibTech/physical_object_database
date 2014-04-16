module PhysicalObjectsHelper
	require 'csv'
	
	def PhysicalObjectsHelper.parse_csv(file)
  	count = 0
  	CSV.foreach(file, headers: true) do |r|
  		po = PhysicalObject.new(
  				mdpi_barcode: r["MDPI Barcode"].to_i,
      		iucat_barcode: r["IU Barcode"].to_i,
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
  		tm = po.create_tm(po.format)
  		tm.pack_deformation = "Severe"
  		po.save
  		tm.physical_object = po
  		tm.save
  		count += 1
  		
      #create duplicated records if there was a "Quantity" column specified
  		q = r["Quantity"]
  		if ! q.nil?
  			po.save
  			(q.to_i - 1).times do |i|
  				p_clone = po.dup
  				p_clone.save
  				count += 1
  				tm_clone = tm.dup
  				tm_clone.physical_object = p_clone
  				tm_clone.save
  			end
  		end
  	end
  	count
	end

end
