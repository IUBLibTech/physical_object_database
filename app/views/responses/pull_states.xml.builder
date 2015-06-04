xml.instruct! :xml, :version=>"1.0"

xml.pod do
	xml.success true
	xml.data do
		DigitalStatus.decided_action_barcodes.each do |set|
			xml.object do
				xml.mdpi_barcode set[0]
				xml.state set[1]
			end
		end
	end
end