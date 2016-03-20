class IniciosController < ApplicationController

before_action :login_requerido, :admin?

  def new
  end

  def create
  end

  def destroy
  end

end
