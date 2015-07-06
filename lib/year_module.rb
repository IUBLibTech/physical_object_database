# Provides year value for technical metadata formats that export it in reports
module YearModule
  def year
    if self.technical_metadatum && self.technical_metadatum.physical_object
      self.technical_metadatum.physical_object.year
    else
      nil
    end
  end
end
