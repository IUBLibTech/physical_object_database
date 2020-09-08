module ApplicationHelper

	# this method is based on the Luhn algorithm (aka Mod 10)
	# wikipedia provides a clear explanation of it: 
	# http://en.wikipedia.org/wiki/Luhn_algorithm#Implementation_of_standard_Mod_10
	def ApplicationHelper.valid_barcode?(barcode)
		if barcode.is_a? Numeric
			barcode = barcode.to_s
		end

		#since the database holds the barcode as an integer field, it will always have a default of 0
		#which in effect means the record has not been assigned a barcode
		if barcode == "0"
			return true
		end

		if barcode.nil? or barcode.length != 14 or barcode[0] != "4"
			return false
		end

		check_digit = barcode.chars.pop.to_i
		sum = 0
		barcode.reverse.chars.each_slice(2).map do |even, odd|
			o = (odd.to_i * 2).divmod(10)
			sum += o[0] == 0 ? o[1] : o[0] + o[1]
			sum += even.to_i
		end
		# need to remove the check_digit from the sum since it was added in the iteration and 
		# should not be part of the total sum
		((sum - check_digit) * 9) % 10 == check_digit
	end

	def ApplicationHelper.real_barcode?(barcode)
	  ApplicationHelper.valid_barcode?(barcode) && barcode.to_s != "0"
	end

	# this method checks to see whether any barcodable item (physical object, box, bin) 
	# has been assigned the specified barcode. returning the object if it does exist, otherwise
	# false
	def ApplicationHelper.barcode_assigned?(barcode)
		unless barcode == 0
			b = false
			if (po = PhysicalObject.where(mdpi_barcode: barcode).limit(1)).size == 1
				b = po[0]
			elsif (bin = Bin.where(mdpi_barcode: barcode).limit(1)).size == 1
				b = bin[0]
			elsif (box = Box.where(mdpi_barcode: barcode).limit(1)).size == 1
				b = box[0]
			end
			return b
		end
		false
	end

	def error_messages_for(object)
		render(partial: 'application/error_messages', locals: {object: object})		
	end

        def dp_requirement(field)
          "<span style='color: red;'>*</span>".html_safe if @tm.provenance_requirements[field]
        end

        def dp_na(field)
          true if @tm.provenance_requirements[field].nil?
        end

	def environment_notice
		if Rails.env.production?
			return ""
		else
			return "<div id='environment'>#{Rails.env.capitalize} Environment</div>".html_safe
		end
	end

  def hashify(array)
    Hash[array.map{ |v| [v.to_s,v.to_s] }]
  end

  # there is a disconnect between jquery datepicker and how rails parses datetime objects.
  # probably a better way than intercepting the params hash and normalizing it...
  def normalize_dates
    unless params[:digital_provenance].nil?
      if params[:digital_provenance][:cleaning_date]
        unless params[:digital_provenance][:cleaning_date].blank?
          params[:digital_provenance][:cleaning_date] = DateTime.strptime(params[:digital_provenance][:cleaning_date], "%m/%d/%Y")
        end
        unless params[:digital_provenance][:baking].blank?
          params[:digital_provenance][:baking] = DateTime.strptime(params[:digital_provenance][:baking], "%m/%d/%Y")
        end
        unless params[:digital_provenance][:digital_file_provenances_attributes].blank?
          params[:digital_provenance][:digital_file_provenances_attributes].each do |key, val|
            unless val[:date_digitized].blank?
              params[:digital_provenance][:digital_file_provenances_attributes][key][:date_digitized] = DateTime.strptime(val[:date_digitized], "%m/%d/%Y")
            end
          end
        end
      end
    end
  end

end
