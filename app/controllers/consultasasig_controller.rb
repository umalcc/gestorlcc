class ConsultasasigController < ApplicationController

  before_filter :login_requerido

  def porusuario
    @solicitudes = Solicitudlab.where("usuario_id = ?",session[:user_id]).all
    ids=@solicitudes.map {|s| s.id } unless @solicitudes.size==0
    @asignacions = Asignaciondef.where("solicitudlab_id in (?)", ids).order("solicitudlab_id,peticionlab_id,dia_id,laboratorio_id").all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @asignacions }
    end
  end


  def general
    @asignacions = Asignaciondef.order('dia_id,solicitudlab_id,laboratorio_id').all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @asignacions }
    end
  end

  def labporusuario
    @solicitudeslab = Solicitudlabexa.where("usuario_id = ?",session[:user_id]).all
    ids=@solicitudeslab.map {|s| s.id } unless @solicitudeslab.size==0
    @asignacionexas = Asignacionlabexadef.order('dia,solicitudlabexa_id,laboratorio_id').where("solicitudlabexa_id in (?)", ids).all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @asignacionexas }
    end
  end

  def labgeneral
    @asignacionexas = Asignacionlabexadef.order('dia,solicitudlabexa_id,laboratorio_id').all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @asignacionexas }
    end
  end

  def listar
    cadena=params[:query]
   # para las fechas
    if cadena=~/\d{2}\-\d{2}\-(\d{4})/
        cadena=cadena.split('-')[2]+'-'+cadena.split('-')[1]+'-'+cadena.split('-')[0]
    else
        if cadena=~/\d{2}\-\d{2}/ || cadena=~/\d{2}\-\d{4}/
           cadena=cadena.split('-')[1]+'-'+cadena.split('-')[0]
        else
           if cadena=~/\d{2}\-/
               cadena='-'+cadena.split('-')[0]
           end
        end
    end
    if cadena=="-"
      cadena="sin curso"
    end
    cadena=(params[:query].nil?)? "%" : "%#{params[:query]}%"
    @titulaciones=Titulacion.where("abrevia||nombre LIKE ?",cadena).all
    codtits=@titulaciones.map{|t| t.id}
    @asignaturas=Asignatura.where("abrevia_asig||nombre_asig LIKE ? or titulacion_id in (?)",cadena,codtits).all
    codasigs=@asignaturas.map { |a| a.id}
    @profesores=Usuario.where("nombre||apellidos LIKE ?",cadena).all
    codprofs=@profesores.map {|p| p.id}
    @solicitudlabexas=Solicitudlabexa.where("asignatura_id in (?) or usuario_id in (?) or curso LIKE ?",codasigs,codprofs,cadena).all
    codsols=@solicitudlabexas.map{|s| s.id}
    @laboratorios=Laboratorio.where("nombre_lab LIKE ?",cadena).all
    codlabs=@laboratorios.map{|l| l.id}
    @asignacionexas=Asignacionlabexadef.where("solicitudlabexa_id in (?) or laboratorio_id in (?) or dia LIKE ?",codsols,codlabs,cadena).all

    #respond_to {|format| format.js }
  end
    

end
