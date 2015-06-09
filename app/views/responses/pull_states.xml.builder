xml.instruct! :xml, :version=>"1.0"

xml.pod do
	xml.success true
	xml.data do
		DigitalStatus.decided_action_barcodes.each do |ds|
			xml.object do
				xml.mdpi_barcode ds.physical_object_mdpi_barcode
				xml.state ds.state
				xml.decided ds.decided
				xml.message ds.message
				xml.options ds.options
				xml.accepted ds.accepted
			end
		end
	end
end