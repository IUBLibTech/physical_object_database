describe InvoiceController do
	render_views
	before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }
#FIXME: add tests

end
