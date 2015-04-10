#
# Methods to generate valid/invalid MDPI barcodes
#
# Automatically included in model and controller specs
# In FactoryGirl, call via:
#   BarcodeHelper.valid_mdpi_barcode
#   BarcodeHelper.invalid_mdpi_barcode
#

module BarcodeHelper
  extend self

  def valid_mdpi_barcode(seed = 0, prefix = 0)
    generate_barcode(true, seed, prefix)
  end

  def invalid_mdpi_barcode(seed = 0, prefix = 0)
    generate_barcode(false, seed, prefix)
  end

  private
  def generate_barcode(valid = true, seed = 0, prefix = 0)
    if prefix.zero? 
      barcode = 4 * (10**13)
    else
      prefix = 4.to_s + prefix.to_s
      barcode = prefix.to_i * (10**(14 - prefix.length))
    end
    if seed.zero?
      barcode += SecureRandom.random_number(10**11)*10
    else
      barcode += seed * 10
    end
    check_digit = 0
    (0..9).each do |x|
      check_digit = x
      break if valid == ApplicationHelper::valid_barcode?(barcode + check_digit)
    end
    return barcode + check_digit
  end

end

RSpec.configure do |config|
  config.include BarcodeHelper, type: :model
  config.include BarcodeHelper, type: :controller
end

