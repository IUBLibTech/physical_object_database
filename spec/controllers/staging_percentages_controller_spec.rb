describe StagingPercentagesController do
	before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

	describe "percentages present?" do
		before(:each) {
			get :index
		}
		it 'ensured validate_formats installs unrepresented formats' do
			formats = PhysicalObject.valid_formats
			expect(formats.size).not_to be 0
			StagingPercentagesController::validate_formats
puts StagingPercentage.all.inspect
			expect(StagingPercentage.all.size).to eq formats.size
		end

		it 'ensured that unrepresented formats are present when calling #index' do
			expect(assigns(:percentages)).not_to be nil
			expect(assigns(:percentages).size).to eq PhysicalObject.valid_formats.size
		end

		it 'lists all default staging percentages' do
			assigns(:percentages).each do |p|
				expect(p.memnon_percent).to eq 10
				expect(p.iu_percent).to eq 10
			end
		end
	end


end
