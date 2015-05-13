require 'rails_helper'
require 'debugger'

describe DigitalStatus do
	let!(:po) { FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode) }
	let!(:start) { FactoryGirl.create(:digital_status, physical_object_id: po.id, physical_object_mdpi_barcode: po.mdpi_barcode)}

	describe "auto accept finds the object" do

		context "with only a non-expired start time" do
			it "does nothing - po has not expired" do
				DigitalFileAutoAcceptor.instance.auto_accept
				expect(po.current_digital_status.decided).to be_nil 
			end
		end

		context "with an expired start time and in qc_wait" do
			let!(:qc_wait) {
				FactoryGirl.create(:digital_status,
					physical_object_id: po.id,
					physical_object_mdpi_barcode: po.mdpi_barcode,
					state: 'qc_wait',
					attention: true,
					message: 'waiting on manual QC',
					options: {"a"=>"to_distribute","b"=>"to_archive","c"=>"to_delete"},
					decided: nil
				)
			}

			before(:each) do
				time = start.created_at - 41.day
				start.update_attributes(created_at: time)
				po.update_attributes(digital_start: time)
				puts "done with the before..."
			end

			it "is in qc_wait state" do
				expect(po.current_digital_status.state).to eq 'qc_wait'
				expect(DigitalStatus.expired_audio_physical_objects).to include po
				DigitalFileAutoAcceptor.instance.auto_accept
				expect(po.current_digital_status.decided).to eq "to_distribute"
			end

			it "is in investigate" do
				qc_wait.state = "investigate"
				qc_wait.save
				expect(po.current_digital_status.state).to eq 'investigate'
				expect(DigitalStatus.expired_audio_physical_objects).to include po
				DigitalFileAutoAcceptor.instance.auto_accept
				expect(po.current_digital_status.decided).to eq "to_archive"
			end
		end


	end


end
