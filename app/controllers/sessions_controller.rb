# Does not inherit from ApplicationController to avoid requiring sign-in here
class SessionsController < ActionController::Base
  require 'net/http'

  def cas_reg
    "https://cas-reg.uits.iu.edu"
  end
  def cas
    "https://cas.iu.edu"
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  def new
    redirect_to("#{cas}/cas/login?cassvc=ANY&casurl=#{root_url}sessions/validate_login")
  end

  def validate_login
    @casticket=params[:casticket]
    uri = URI.parse("#{cas}/cas/validate?cassvc=ANY&casticket=#{@casticket}&casurl=#{root_url}")
    request = Net::HTTP.new(uri.host, uri.port)
    request.use_ssl = true
    request.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = request.get("#{cas}/cas/validate?cassvc=ANY&casticket=#{@casticket}&casurl=#{root_url}")
    @resp = response.body
    if @resp.slice(0,3) == 'yes'
      @resp_true = @resp.slice(0,3)
      @nlength=@resp.length - 7
      @resp_user=@resp.slice(5,@nlength)
      if User.authenticate(@resp_user)
        sign_in(@resp_user) 
        redirect_back_or_to root_url
      else
        redirect_to "#{root_url}denied.html"
      end
    else
      @resp_true = @resp.slice(0,2)
      redirect_to "#{root_url}denied.html"
    end
  end

  def destroy
    sign_out
    redirect_to 'https://cas.iu.edu/cas/logout'
  end

end
