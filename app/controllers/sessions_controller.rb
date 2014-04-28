#FIXME: remove puts calls
#remove FIXME lines
#FIXME: add security to other controllers besides bin

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
        puts "@resp_user: -#{@resp_user}-"
        puts "current_user: -#{current_user}-"
        if User.authenticate(@resp_user)
          sign_in(@resp_user) 
          puts "@resp_user: -#{@resp_user}-"
          puts "current_user: -#{current_user}-"
          redirect_back_or_to physical_objects_path
        else
          redirect_to "#{root_url}denied.html"
        end
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
    redirect_to root_url
    #FIXME: add logout url
  end

  def check_name(name)
    if name.nil? || name.blank?
      return false
    else
      return true
    end
  end


end
