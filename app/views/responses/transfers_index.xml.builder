xml.instruct! :xml, :version=>"1.0"

xml.pod do
  if @success
    xml.success true
    xml.data do
      @pos.each do |p|
      	xml.object do
      		xml.mdpi_barcode p.mdpi_barcode
      		xml.destination "No way to specify destination yet..."
      	end
      end
    end
  end
end