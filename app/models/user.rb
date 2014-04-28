class User

  #rewrite to look up allowed users
  def User.authenticate(username)
    #FIXME: testing line below
    return username == "aploshay"
    #return true
  end

end
