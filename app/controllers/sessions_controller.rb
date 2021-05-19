# Does not inherit from ApplicationController to avoid requiring sign-in here
class SessionsController < ActionController::Base
  require 'net/http'

  def cas
    # FIXME: handle real case
    "https://idp-stg.login.iu.edu/idp/profile"
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  def new
    params[:ticket].present? ? validate_login : get_ticket
  end

  def get_ticket
    redirect_to("#{cas}/cas/login?service=#{root_url}")
  end

  def validate_login
    @casticket=params[:ticket]
    uri = URI.parse("#{cas}/cas/serviceValidate?ticket=#{@casticket}&service=#{root_url}")
    request = Net::HTTP.new(uri.host, uri.port)
    request.use_ssl = true
    request.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = request.get("#{cas}/cas/serviceValidate?ticket=#{@casticket}&service=#{root_url}")
    @resp = response.body
    @xml = Nokogiri::XML(@resp)
    @resp_user = @xml.xpath('/cas:serviceResponse/cas:authenticationSuccess/cas:user').text
    if @resp_user.present? && User.authenticate(@resp_user)
      sign_in(@resp_user) 
      redirect_back_or_to root_url
    else
      redirect_to "#{root_url}denied.html"
    end
  end

  def destroy
    sign_out
    redirect_to "#{cas}/cas/logout"
  end
end
