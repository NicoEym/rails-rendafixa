class DebenturesController < ApplicationController


  def index
    @debentures = Debenture.all
  end




end
