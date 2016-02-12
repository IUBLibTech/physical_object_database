class PopulateFormatAssociationsByInference < ActiveRecord::Migration
  def up
    puts "Machines:"
    Machine.all.each do |m|
      formats = PhysicalObject.joins(:digital_provenance => [ :digital_file_provenances => [ :signal_chain => [ :processing_steps => [ :machine]]]]).where(machines: { id: m.id }).map { |po| po.format }.uniq
      puts "(#{m.id}) #{m.category} | #{m.serial} | #{m.manufacturer} | #{m.model}: #{formats}"
      formats.each do |format|
        m.machine_formats.create(format: format)
      end
    end
    puts "Signal Chains:"
    SignalChain.all.each do |sc|
      formats = PhysicalObject.joins(:digital_provenance => [ :digital_file_provenances => [ :signal_chain]]).where(signal_chains: { id: sc.id }).map { |po| po.format }.uniq
      puts "(#{sc.id}) #{sc.name}: #{formats}"
      formats.each do |format|
        sc.signal_chain_formats.create(format: format)
      end
    end
  end
  def down
    puts "No action on rollback"
  end
end
