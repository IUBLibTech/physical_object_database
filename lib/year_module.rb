# Provides year value for technical metadata formats that export it in reports
# RSpec testing is via shared shared examples call in including models
#
module YearModule
  def year
    if self.technical_metadatum && self.technical_metadatum.physical_object
      self.technical_metadatum.physical_object.year
    else
      nil
    end
  end
end
