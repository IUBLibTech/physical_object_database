class DigitalStatus < ActiveRecord::Base
	require 'json/ext'

	serialize :options, Hash
	belongs_to :physical_object

	# This scope returns an array of arrays containing all of the current digital statuses
	# and their respective counts: [['failed', 3], ['queued', 10], etc]
	scope :unique_statuses, -> {
		DigitalStatus.connection.execute(
			"SELECT y.state, count(*) as count 
			FROM (
				SELECT ds.id, ds.physical_object_id, ds.state AS state, ds.updated_at
				FROM (
					SELECT MAX(id) as id
					FROM digital_statuses
					GROUP BY physical_object_id
				) as x INNER JOIN digital_statuses as ds where ds.id = x.id
			) AS y
			GROUP BY state
			ORDER BY state"
		)
	}

	# this scope takes a status name ('start', 'transfered', 'accepted', failed', etc) and returns all
	# physical objects currently in that state
	scope :current_status, lambda {|i| 
    PhysicalObject.find_by_sql(
    	"SELECT physical_objects.*
			FROM (
				SELECT ds.physical_object_id as id
				FROM (
					SELECT MAX(id) as id
					FROM digital_statuses
					GROUP BY physical_object_id
				) as x INNER JOIN digital_statuses as ds 
				WHERE ds.id = x.id and state='#{i}'
			) as po_ids INNER JOIN physical_objects
			WHERE physical_objects.id = po_ids.id"
    )
  }

	def self.test(*barcode)
		barcode ||= "40000000031296"
		"{
			\"barcode\": #{barcode.first},
			\"state\":\"failed\",
			\"attention\":\"true\",
			\"message\":\"msg\",
			\"options\":{
     		\"to_delete\": \"Discard this object and redigitize or re-upload it\" 
				}
		}"
	end

	def self.unique_statuses_query
			"SELECT y.state, count(*) as count 
			FROM (
				SELECT ds.id, ds.physical_object_id, ds.state AS state, ds.updated_at
				FROM (
					SELECT MAX(id) as id
					FROM digital_statuses
					GROUP BY physical_object_id
				) as x INNER JOIN digital_statuses as ds where ds.id = x.id
			) AS y
			GROUP BY state
			ORDER BY state"
	end

        # FIXME: consider dropping physical_object_mdpi_barcode as attribute
        def from_xml(mdpi_barcode, xml)
          self.physical_object_mdpi_barcode = mdpi_barcode
          po = PhysicalObject.where(mdpi_barcode: self.physical_object_mdpi_barcode).first
          unless po.nil?
            self.physical_object_id = po.id
          end
          self.state = xml.xpath("/pod/data/state").text
          self.message = xml.xpath("/pod/data/message").text
          self.accepted = false
          self.attention = xml.xpath("/pod/data/attention").text
          self.decided = nil
          options_hash = {}
          xml.xpath("/pod/data/options/option").each do |option|
            options_hash[option.xpath("state").text.to_sym] = option.xpath("description").text
          end
          self.options = options_hash
          self
        end

	def requires_attention?
		attention and !decided.blank?
	end

	def decided?
		!decided.blank?
	end
end
