# log_duplicate_mdpi_barcodes.rake
# Rake tasks for logging duplicate non-zero MDPI barcodes
#
# Example use:
# rake pod:log_duplicate_mdpi_barcodes
#
namespace :pod do
  desc "Log duplicate MDPI barcodes"
    task :log_duplicate_mdpi_barcodes => :environment do |task|
      @logger = Logger.new(Rails.root.join('log', 'find_duplicate_barcodes.log'))
      duplicates = PhysicalObject.where.not(mdpi_barcode: '0').select(:mdpi_barcode).group(:mdpi_barcode).having("count('mdpi_barcode') > 1").size
      if duplicates.empty?
        @logger.info 'No duplicates found'
      else
        @logger.info "#{duplicates.size} duplicate cases found."
        @logger.info duplicates.to_yaml
        duplicates.keys.each do |barcode|
          PhysicalObject.where(mdpi_barcode: barcode).each { |po| @logger.info po.inspect }
        end
      end
    end
end
