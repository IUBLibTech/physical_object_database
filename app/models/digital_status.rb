class DigitalStatus < ActiveRecord::Base
	require 'json/ext'

	serialize :options, Hash
	belongs_to :physical_object

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

	def from_json(json)
		obj = JSON.parse(json, symbolize_names: true)
		self.physical_object_mdpi_barcode = obj[:barcode]
		po = PhysicalObject.where(mdpi_barcode: self.physical_object_mdpi_barcode).first
		unless po.nil?
			self.physical_object_id = po.id
		end
		self.state = obj[:state]
		self.message = obj[:message]
		self.accepted = false
		self.attention = obj[:attention]
		self.decided = nil
		self.options = obj[:options]
		self
	end

	def invalid_physical_object?
		return physical_object.nil?
	end

	def valid_physical_object?
		return ! invalid_physical_object?
	end

	def requires_attention?
		attention and !decided		
	end

	def decided?
		!decided.nil?
	end
end
