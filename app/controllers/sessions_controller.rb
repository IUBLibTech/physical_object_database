class SessionsController < ApplicationController

  def new
    redirect_to("https://cas.iu.edu/cas/login?cassvc=ANY&casurl=#{root_url}sessions/validate_login")
  end

  def validate_login
    @casticket=params[:casticket]
    uri = URI.parse("https://cas.iu.edu/cas/validate?cassvc=ANY&casticket=#{@casticket}&casurl=#{root_url}")
    request = Net::HTTP.new(uri.host, uri.port)
    request.use_ssl = true
    request.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = request.get("https://cas.iu.edu/cas/validate?cassvc=ANY&casticket=#{@casticket}&casurl=#{root_url}")
    @resp = response.body
    if @resp.slice(0,3) == 'yes'
      @resp_true = @resp.slice(0,3)
      @nlength=@resp.length - 7
      @resp_user=@resp.slice(5,@nlength)
      if check_name(@resp_user)
        puts "current_user: -#{current_user}-"
        sign_in(@resp_user)
        puts "@resp_user: -#{@resp_user}-"
        puts "current_user: -#{current_user}-"
        #redirect_to root_url
        redirect_back_or_to root_url
        #redirect_to "http://www.google.com"
      else
        redirect_to(:action => 'logout', :id=>@resp_user)
      end
    else
      @resp_true = @resp.slice(0,2)
      redirect_to(:action => 'logout', id: @resp)
    end
  end

  def create
    if User.authenticate(params[:username])
      sign_in user
      redirect_back_or_to physical_objects_path
    else
      flash.now[:error] = 'Invalid email/password combination' #FIXME: change
      #render 'new'
      #FIXME
      redirect_to "http://www.google.com"
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

  def check_name(name)
    if name.nil? || name.blank?
      return false
    else
      return true
    end
  end


end
