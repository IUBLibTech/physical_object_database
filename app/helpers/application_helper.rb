module ApplicationHelper

	# this method is based on the Luhn algorithm (aka Mod 10)
	# wikipedia provides a clear explanation of it: 
	# http://en.wikipedia.org/wiki/Luhn_algorithm#Implementation_of_standard_Mod_10
	def ApplicationHelper.valid_barcode?(barcode)
		if barcode.is_a? Fixnum
			barcode = barcode.to_s
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

	def error_messages_for(object)
		render(partial: 'application/error_messages', locals: {object: object})		
	end

end
