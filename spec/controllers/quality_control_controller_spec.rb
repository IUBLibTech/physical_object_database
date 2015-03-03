require 'rails_helper'

RSpec.describe QualityControlController, :type => :controller do
	let!(:po) { FactoryGirl.create :physical_object, :open_reel, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode }
	let!(:po1) { FactoryGirl.create :physical_object, :cdr, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode }
	let!(:po2) { FactoryGirl.create :physical_object, :dat, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode }
	let(:ds) { FactoryGirl.create :digital_status, state: "failed" }
	let(:ds1) { FactoryGirl.create :digital_status, state: "accepted" }
	let(:ds2) { FactoryGirl.create :digital_status, state: "transfered" }
	describe "#index" do
		context "with no statuses" do
			before(:each) do
				get :index
			end
			it "finds 0 physical objects with statuses" do
				expect(DigitalStatus.unique_statuses.size).to eq 0 
			end
		end

		context "with statuses" do
			before(:each) do
				ds.physical_object_mdpi_barcode = po.mdpi_barcode
				ds.physical_object_id = po.id
				ds.save
				get :index
			end
			it "finds a status" do
				expect(DigitalStatus.unique_statuses.size).to eq 1	
				expect(DigitalStatus.current_status(ds.state)).to include(po)
			end
		end

		context "with multiple statuses on a given object" do
			before(:each) do
				# 2 states for the same physical object but the current state should be based on ds1
				ds.physical_object_id = po.id
				ds.save
				ds1.physical_object_id = po.id
				ds1.save

				# 1 different state for another physical object
				ds2.physical_object_id = po2.id
				ds2.save
			end

			it "finds the correct status" do
				expect(DigitalStatus.unique_statuses.size).to eq 2
				expect(DigitalStatus.current_status(ds1.state).size).to eq 1
				expect(DigitalStatus.current_status(ds1.state)).to include(po)
			end
		end

	end


end
