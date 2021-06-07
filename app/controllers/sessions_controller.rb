# Does not inherit from ApplicationController to avoid requiring sign-in here
class SessionsController < ActionController::Base
  require 'net/http'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  before_action :set_cas_ticket, only: [:new, :validate_login]
  before_action :set_cas_user, only: [:validate_login]

  def new
    @cas_ticket.present? ? validate_login : redirect_to(cas_url(:login, service: secure_root_url))
  end

  def validate_login
    set_cas_user if @cas_user.blank?
    if @cas_user.present? && User.authenticate(@cas_user)
      sign_in(@cas_user) 
      redirect_back_or_to secure_root_url
    else
      redirect_to "#{secure_root_url}denied.html"
    end
  end

  def destroy
    sign_out
    redirect_to(cas_url(:logout))
  end

  private
    def cas_url(action = nil, **keywords)
      url_string = Pod.config[:auth][:cas_host] + Pod.config[:auth]["cas_#{action}_url"].to_s
      url_string += ("?" + keywords.map { |k, v| "#{k}=#{v}" }.join('&')) if keywords.any?
      url_string
    end

    def set_cas_ticket
      @cas_ticket = params[:ticket]
    end

    def set_cas_user
      begin
        uri = URI.parse(cas_url(:validate, ticket: @cas_ticket, service: secure_root_url))
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
