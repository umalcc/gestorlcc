class ListadoController < ApplicationController

before_filter :login_requerido

  def asignacion_lectivo_impresa
    @asignacions = Asignaciondef.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @asignacions }
    end
  end

  def asignacion_lectivo_usuario_impresa
    @solicitudes = Solicitudlab.where("usuario_id = #{session[:user_id]}").all
    ids=@solicitudes.map {|s| s.id } unless @solicitudes.size==0
    @asignacions = Asignaciondef.order("solicitudlab_id,peticionlab_id,dia_id,laboratorio_id").where("solicitudlab_id in (?)", ids).all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @asignacions }
    end
  end

  def asignacion_examenes_impresa
    @asignacionexas = Asignacionlabexadef.order('dia,solicitudlabexa_id,laboratorio_id').all


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @asignacions }
    end
  end

  def asignacion_examenes_usuario_impresa

    @solicitudeslab = Solicitudlabexa.where("usuario_id = #{session[:user_id]}").all
    ids=@solicitudeslab.map {|s| s.id } unless @solicitudeslab.size==0
    @asignacionexas = Asignacionlabexadef.order('dia,solicitudlabexa_id,laboratorio_id').where("solicitudlabexa_id in (?)", ids).all
  end

end
