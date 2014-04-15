class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :tm_partial_path

  # this method helps determine which view to use to render
  # a partial for a given technical metadatum type. It is assumed
  # that this pass value is the subclass (OpenReelTm, CassetteTapeTm, etc)
  # and not the super class TechnicalMetadatum
  def tm_partial_path(technical_metadatum)
    puts("Request for TM partial: #{technical_metadatum.class.name}")
  	if technical_metadatum.class.name == "OpenReelTm"
      "technical_metadatum/show_open_reel_tape_tm"
    else
      "technical_metadatum/show_unknown_tm"
    end
  end

end
