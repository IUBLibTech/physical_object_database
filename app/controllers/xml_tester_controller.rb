class XmlTesterController < ApplicationController
	require 'nokogiri'
	include BasicAuthenticationHelper
  include QcXmlModule

	def index
		
	end

	def submit
		upload = params[:file]
		buffer = ""
		File.open(upload.tempfile.path, "r") do |infile|
			while (line = infile.gets)
				buffer << line
			end
		end
		begin
			parse_no_po(buffer)
			@xml = buffer
		rescue 
			@xml = "An error occurred while parsing the xml...\n#{$!}"
		end
	end


end
