xml.instruct! :xml, :version=>"1.0"

xml.pod do
   if @physical_object
     xml.success true
     xml.data do
       xml.format @physical_object.format
       xml.files @physical_object.technical_metadatum.master_copies
     end
   else
     xml.success false
     if params[:mdpi_barcode].to_i.zero?
       xml.message "MDPI Barcode cannot be 0, blank, or unspecified"
     else
       xml.message "MDPI Barcode #{params[:mdpi_barcode]} does not exist"
     end
   end
end
