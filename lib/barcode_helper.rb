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

  def valid_mdpi_barcode
    generate_barcode(true)
  end

  def invalid_mdpi_barcode
    generate_barcode(false)
  end

  private
  def generate_barcode(valid = true)
    barcode = 4 * (10**13)
    barcode += SecureRandom.random_number(10**11)*10
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

