xml.instruct! :xml, :version=>"1.0"

xml.metadata do
   if @physical_object
     xml.found true, type: :boolean
     xml.format @physical_object.format, type: :string
     xml.files @physical_object.technical_metadatum.master_copies, type: :integer
   else
     xml.found false, type: :boolean
   end
end
