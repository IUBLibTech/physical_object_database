module QcXmlModule
  
  # parses XML and assigns attributes to po's constituent DigitalProvenance model, OR it
  # returns false if the parse failed (most likely due to invalid controlled vocabulary
  # in the XML). IT DOES NOT 
  def parse_qc_xml(po, xml, doc)
    # parse the DigitalProvenance items first
    dp = po.ensure_digiprov
    dp.xml = xml
    dp.save!
    entity = doc.css("IU Carrier Parts DigitizingEntity").first.content

    po.digital_provenance.digitizing_entity = entity
    #parse digital file provenance last
    doc.css("IU Carrier Parts Part").each do |part|
      checked = false
      unless part.css("ManualCheck").size == 0 or part.css("ManualCheck").first.content.blank?
        checked = yes_no(part.css("ManualCheck").first.content) if part.css("ManualCheck").first
      end
      po.memnon_qc_completed ||= checked
    end
    po.save!
    dp.save!
    true
  end

  def parse_no_po(xml)
    doc = Nokogiri::XML(xml).remove_namespaces!
    comments(doc)
    cleaning_date(doc)
    baking_date(doc)
    repaired(doc)
  end

  private
  def repaired(doc)
    if yes_no?(doc.at_css("IU Carrier Repaired").content)
      yes_no(doc.at_css("IU Carrier Repaired").content)
    else
      return false
    end
  end

  def comments(doc)
    if doc.at_css("IU Carrier Preview Comments")
      doc.at_css("IU Carrier Preview Comments").content
    else
      ""
    end
  end

  def cleaning_date(doc)
    if doc.at_css("IU Carrier Cleaning Date")
      date_parse(doc.at_css("IU Carrier Cleaning Date").content)
    else
      nil
    end
  end

  def baking_date(doc)
    if doc.at_css("IU Carrier Baking Date")
      date_parse(doc.at_css("IU Carrier Baking Date").content)
    else
      nil
    end
  end

  def repaired(doc)
    checked = false
    doc.css("IU Carrier Parts Part").each do |part|
      checked ||= yes_no(part.css("ManualCheck").first.content)
    end
    checked
  end

  # checks to see if the passed node values is either "Yes or No"
  def yes_no?(node_val)
    node_val == "Yes" or node_val == "No"
  end

  # returns a boolean based on "Yes"/"No' values passed, or nil if a non-yes/no value is passed
  def yes_no(val)
    if yes_no?(val)
      val == "Yes" ? true : false
    else
      return nil
    end
  end

  def date_parse(val)
    unless val.nil? or val.length == 0
      val.to_datetime
    else
      nil
    end
  end

end
