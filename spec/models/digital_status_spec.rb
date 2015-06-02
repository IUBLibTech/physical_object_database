require 'rails_helper'
require 'debugger'

describe DigitalStatus do
	let!(:po) { FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode) }
	let!(:po_vid) { FactoryGirl.create(:physical_object, :betacam, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode) }
	let!(:start) { FactoryGirl.create(:digital_status, physical_object_id: po.id, physical_object_mdpi_barcode: po.mdpi_barcode) }
	let!(:start_vid) { FactoryGirl.create(:digital_status, physical_object_id: po_vid.id, physical_object_mdpi_barcode: po_vid.mdpi_barcode) }

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

			let!(:qc_wait_vid) {
				FactoryGirl.create(:digital_status,
					physical_object_id: po_vid.id,
					physical_object_mdpi_barcode: po_vid.mdpi_barcode,
					state: 'qc_wait',
					attention: true,
					message: 'waiting on manual QC',
					options: {"a"=>"to_distribute","b"=>"to_archive","c"=>"to_delete"},
					decided: nil
				)
			}

			before(:each) do
				time = start.created_at - 41.day
				vid_time = start.created_at - 31.day
				start.update_attributes(created_at: time)
				start_vid.update_attributes(created_at: vid_time)
				po.update_attributes(digital_start: time)
				po_vid.update_attributes(digital_start: vid_time)
			end

			it "is in qc_wait state" do
				expect(po.current_digital_status.state).to eq 'qc_wait'
				expect(po_vid.current_digital_status.state).to eq 'qc_wait'

				expect(DigitalStatus.expired_audio_physical_objects).to include po
				expect(DigitalStatus.expired_audio_physical_objects).not_to include po_vid
				expect(DigitalStatus.expired_video_physical_objects).not_to include po
				expect(DigitalStatus.expired_video_physical_objects).to include po_vid


				DigitalFileAutoAcceptor.instance.auto_accept

				expect(po.current_digital_status.decided).to eq "to_distribute"
				expect(po_vid.current_digital_status.decided).to eq "to_distribute"
			end

			it "is in investigate" do
				qc_wait.state = "investigate"
				qc_wait_vid.state = "investigate"
				qc_wait.save
				qc_wait_vid.save

				expect(po.current_digital_status.state).to eq 'investigate'
				expect(po_vid.current_digital_status.state).to eq 'investigate'

				expect(DigitalStatus.expired_audio_physical_objects).to include po
				expect(DigitalStatus.expired_audio_physical_objects).not_to include po_vid
				expect(DigitalStatus.expired_video_physical_objects).not_to include po
				expect(DigitalStatus.expired_video_physical_objects).to include po_vid

				DigitalFileAutoAcceptor.instance.auto_accept

				expect(po.current_digital_status.decided).to eq "to_archive"
				expect(po_vid.current_digital_status.decided).to eq "to_archive"
				
			end
		end


	end


end
