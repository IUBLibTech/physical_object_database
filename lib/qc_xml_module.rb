module QcXmlModule
  
	# parses XML and assigns attributes to po and its constituent digiprov models, OR it
  # returns false if the parse failed (most likely due to invalid controlled vocabulary
  # in the XML)
  def parse_qc_xml(po, xml)
    # other methods may rely on namespaces so only remove them in a local document
    doc = Nokogiri::XML(xml).remove_namespaces!
    # parse the DigitalProvenance items first
    dp = po.ensure_digiprov
    dp.xml = xml
    # Hotfix: just stash xml until we resolve parsing
    dp.save
    return
    # end Hotfix
    if doc.at_css("IU Carrier Repaired") && yes_no?(doc.at_css("IU Carrier Repaired").content)
      dp.repaired = yes_no(doc.at_css("IU Carrier Repaired").content)
    else
      return false
    end
    dp.comments = comments(doc)
    dp.cleaning_date = cleaning_date(doc)
    dp.baking = baking_date(doc)
    dp.save

    # parse technical metadata values next
    # this may not be necessary... waiting for confirmation from Mike Casey
    # tm = po.technical_metadatum.as_technical_metadatum.parse_qc_xml(doc)
    # tm.save

    #parse digital file provenance last
    doc.css("IU Carrier Parts Part").each do |part|
      # df = DigitalFileProvenance.new(digital_provenance_id: dp.id)
      # df.filename = part.css("Files File").first.css("FileName").first.content
      # df.comment = part.css("Ingest Comments").first.content
      # df.created_by = part.css("Ingest Created_by").first.content
      # FIXME: commented out to get qc pushing working
      # df.player_serial_number = part.css("Ingest Player_serial_number").first.content
      # df.player_manufacturer = part.css("Ingest Player_manufacturer").first.content
      # df.player_model = part.css("Ingest Player_model").first.content
      # df.ad_serial_number = part.css("Ingest AD_serial_number").first.content
      # df.ad_manufacturer = part.css("Ingest AD_manufacturer").first.content
      # df.ad_model = part.css("Ingest AD_model").first.content
      # df.extraction_workstation = part.css("Ingest Extraction_workstation").first.content
      # df.speed_used = part.css("Ingest Speed_used").first.content
      # df.save
      checked = yes_no(part.css("ManualCheck").first.content) if part.css("ManualCheck").first
      po.memnon_qc_completed ||= checked
    end
    dp.save
    po.save
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
