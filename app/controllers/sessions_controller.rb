# Does not inherit from ApplicationController to avoid requiring sign-in here
class SessionsController < ActionController::Base
  require 'net/http'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  before_action :cas_ticket, only: [:new, :validate_login]
  before_action :cas_user, only: [:validate_login]

  def cas
    Pod.config[:cas_url]
  end

  def ticket_url(service)
    "#{cas}/login?service=#{service}"
  end

  def validation_url(ticket, service)
    "#{cas}/serviceValidate?ticket=#{ticket}&service=#{service}"
  end

  def logout_url
    "#{cas}/logout"
  end

  def new
    @cas_ticket.present? ? validate_login : redirect_to(ticket_url(root_url))
  end

  def validate_login
    if @cas_user.present? && User.authenticate(@cas_user)
      sign_in(@cas_user) 
      redirect_back_or_to root_url
    else
      redirect_to "#{root_url}denied.html"
    end
  end

  def destroy
    sign_out
    redirect_to(logout_url)
  end

  private
    def cas_ticket
      @cas_ticket = params[:ticket]
    end

    def cas_user
      begin
        uri = URI.parse(validation_url(@cas_ticket, root_url))
        request = Net::HTTP.new(uri.host, uri.port)
        request.use_ssl = true
        request.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = request.get(uri.to_s)
        @resp = response.body
        @xml = Nokogiri::XML(@resp)
        @cas_user = @xml.xpath('/cas:serviceResponse/cas:authenticationSuccess/cas:user').text
      rescue
        @cas_user ||= ''
      end
    end
end
