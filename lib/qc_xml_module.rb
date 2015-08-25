module QcXmlModule

	# parses XML and assigns attributes to po and its constituent digiprov models, OR it
  # returns false if the parse failed (most likely due to invalid controlled vocabulary
  # in the XML)
  def parse_qc_xml(po, xml)
    # other methods may rely on namespaces so only remove them in a local document
    doc = Nokogiri::XML(request.body.read).remove_namespaces!
    # parse the DigitalProvenance items first
    dp = po.digital_provenance
    dp.xml = xml
    if yes_no?(doc.at_css("IU Carrier Repaired").content)
      dp.repaired = yes_no(doc.at_css("IU Carrier Repaired").content)
    else
      return false
    end
    dp.comments = doc.at_css("IU Carrier Preview Comments").content
    dp.cleaning_date = date_parse(doc.at_css("IU Carrier Cleaning Date").content)
    dp.baking = date_parse(doc.at_css("IU Carrier Baking Date").content)
    dp.save

    # parse technical metadata values next
    # this may not be necessary... waiting for confirmation from Mike Casey
    # tm = po.technical_metadatum.as_technical_metadatum.parse_qc_xml(doc)
    # tm.save

    #parse digital file provenance last
    doc.css("IU Carrier Parts Part").each do |part|
      df = DigitalFileProvenance.new(digital_provenance_id: dp.id)
      df.filename = part.css("Files File").first.css("FileName").first.content
      df.comment = part.css("Ingest Comments").first.content
      df.created_by = part.css("Ingest Created_by").first.content
      # FIXME: commented out to get qc pushing working
      # df.player_serial_number = part.css("Ingest Player_serial_number").first.content
      # df.player_manufacturer = part.css("Ingest Player_manufacturer").first.content
      # df.player_model = part.css("Ingest Player_model").first.content
      # df.ad_serial_number = part.css("Ingest AD_serial_number").first.content
      # df.ad_manufacturer = part.css("Ingest AD_manufacturer").first.content
      # df.ad_model = part.css("Ingest AD_model").first.content
      # df.extraction_workstation = part.css("Ingest Extraction_workstation").first.content
      df.speed_used = part.css("Ingest Speed_used").first.content
      df.save
      checked = yes_no(part.css("ManualCheck").first.content)
      po.memnon_qc_completed ||= checked
    end

    dp.save
    po.save
    true
  end


end
