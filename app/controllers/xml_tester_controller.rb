class XmlTesterController < ApplicationController
	require 'nokogiri'
	include BasicAuthenticationHelper
  include QcXmlModule
  before_action :authorize_xml_tester

	def index
	end

	def submit
		upload = params[:file]
		buffer = ""
                @xml = nil
                begin 
			File.open(upload.tempfile.path, "r") do |infile|
				while (line = infile.gets)
					buffer << line
				end
			end
                rescue
			@xml = "An error occurred while opening the file...\n#{$!}"
                end
		unless @xml
			begin
				parse_no_po(buffer)
				@xml = buffer
			rescue 
				@xml = "An error occurred while parsing the xml...\n#{$!}"
			end
		end
	end

  private
    def authorize_xml_tester
      authorize :xml_tester
    end
end
