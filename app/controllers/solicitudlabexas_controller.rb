class SolicitudlabexasController < ApplicationController

  include SolicitudesHelper

  before_action :login_requerido, :admin?
  before_action :initializeIndex, :only=> [:index,:listar]
  before_action :getViewModel, only: [:new]


  def initializeIndex
      @tiempoSolicitudes = ["Curso académico actual", "Cuatrimestre actual", "Desde hace un año", "Desde hace dos años"]
  end

  def index

    @solicitudlabexas = Solicitudlabexa.order("fecha").to_a
    @solicitudlabexas = getCurrentRequests(@solicitudlabexas, false) 
    @cuenta = @solicitudlabexas.size
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @solicitudlabexas }
    end
  end

  # GET /solicitudlabexas/new
  # GET /solicitudlabexas/new.xml
  def new
    @solicitudlabexa = Solicitudlabexa.new
    @solicitudlabexa.asignatura=Asignatura.new
    @periodo=Periodo.where("tipo= ? AND inicio >= ?","Examenes",Date.today).order("inicio").first
   
    if(@periodo.nil?)
      @solicitudlabexa.fecha=Date.today
    else
       @solicitudlabexa.fecha=@periodo.inicio
     end
    
    @solicitudlabexa.preferencias=""
    @asignaturas = Asignatura.where('titulacion_id = ? and curso = ?',@titulaciones.first,0).to_a
    @solicitudlabexa.asignatura=@asignaturas.first

    session[:titulacion]=Titulacion.first
    session[:nivel]=Asignatura::CURSO.first
 
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @solicitudlabexa }
    end
  end

  def create
    @solicitudlabexa = Solicitudlabexa.new(params[:solicitudlabexa])
    saveObject(params)
    @solicitudlabexa.tipo="P"
    getViewModel
    getSubjects(@solicitudlabexa)

    respond_to do |format|
      if @solicitudlabexa.save      
       CorreoTecnicos::emitesolicitudexamen(@solicitudlabexa,params[:fecha],"Solicitud cursada por admin","Nueva ").deliver_later        
              
        @solicitudlabexas = Solicitudlabexa.all
        
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @solicitudlabexas, :status => :created, :location => @solicitudlabexas }
      else
     
        format.html { render :action => "new" }
        format.xml  { render :xml => @solicitudlabexas.errors, :status => :unprocessable_entity }
      end
    end  
  end

  # GET /solicitudlabs/1/edit
  def edit
    @solicitudlabexa = Solicitudlabexa.find(params[:id]) 
    getViewModel
    getSubjects(@solicitudlabexa)    
  end


# PUT /solicitudlabexas/1
# PUT /solicitudlabexas/1.xml
def update
    @solicitudlabexa = Solicitudlabexa.find(params[:id])
    saveObject(params)
    getViewModel

    respond_to do |format|
        if @solicitudlabexa.save
          CorreoTecnicos::emitesolicitudexamen(@solicitudlabexa,params[:fecha],"Solicitud cursada por admin","Cambios en ").deliver_later       
          @solicitudlabexas = Solicitudlabexa.all
          format.html { redirect_to :action => "index" }
          format.xml  { head :ok }
      else
        format.html { render :action => "edit"}
        format.xml  { render :xml => @solicitudlabexa.errors, :status => :unprocessable_entity }
   end
 end
end


  # POST /solicitudlabs
  # POST /solicitudlabs.xml
  def saveObject(params)
 
    @solicitudlabexa.usuario_id = params[:usuario][:identificador].to_i
    if params[:asignatura].nil?
      @solicitudlabexa.asignatura=Asignatura.new
      @solicitudlabexa.asignatura.titulacion_id=params[:titulacion][:titulacion_id] unless params[:titulacion].nil? 
      @solicitudlabexa.asignatura.curso=params[:nivel]
      @solicitudlabexa.asignatura.id=0
    else
      @solicitudlabexa.asignatura_id = params[:asignatura][:id].to_i
    end
    @solicitudlabexa.fechasol=Date.today
    @solicitudlabexa.npuestos=params[:npuestos]
    @solicitudlabexa.curso=params[:nivel].to_s == '0' ? 'optativa' : params[:nivel].to_s
    @solicitudlabexa.comentarios=Iconv.conv('ascii//translit//ignore', 'utf-8', params[:comentarios].to_s)
    @solicitudlabexa.horaini=params[:horaini][:comienzo]
    @solicitudlabexa.horafin=params[:horafin][:fin]
    @solicitudlabexa.asignado="N"
    
    pref=""
    @especiales=Laboratorio.where('especial=?',"t").to_a 
    for especial in @especiales do
      nombre=especial.ssoo.to_s
      if params[:"#{nombre}"] and params[:"#{nombre}"].to_s!='in'
        pref+=especial.nombre_lab.to_s+'-'+nombre+'-'+params[:"#{nombre}"]+";"
      end
    end
    @solicitudlabexa.preferencias=pref

     if params[:fecha]=~ /[0-3]?[0-9]\-[0-1]?[0-9]\-[0-9]{4}/
      @solicitudlabexa.fecha=formato_europeo(params[:fecha])
    else
      @solicitudlabexa.fecha=nil
    end
  end


  def getViewModel
    @usuarios=Usuario.order("apellidos").to_a.reject{|u| u.identificador=="anonimo"} 
    @especiales=Laboratorio.where('especial=?',"t").to_a 
    @titulaciones=Titulacion.order("nombre").to_a
    @usuarios=Usuario.order("apellidos").to_a.reject{|u| u.identificador=="anonimo"}  
    @puestos=Laboratorio.find_by_sql(["select distinct(puestos) from laboratorios order by puestos"]).map{|l| l.puestos}
    @horas=Horasexa.where('en_uso=?',"t").order("id").to_a
  end

  def getSubjects(solicitudlabexa)

    logger.debug "Ahora se cargan las asignaturas"
    curso = solicitudlabexa.curso == "optativa" ? 0 : solicitudlabexa.curso.to_i
    @asignaturas = Asignatura.where('titulacion_id = ? and curso = ?',solicitudlabexa.asignatura.titulacion_id,curso).to_a
  end
  
 
  # DELETE /solicitudlabexas/1
  # DELETE /solicitudlabexas/1.xml
 def destroy
    @solicitudlabexa = Solicitudlabexa.find(params[:id])
    CorreoTecnicos::emitesolicitudexamen(@solicitudlabexa,params[:fecha],"Solicitud cursada por admin","Borrado de ").deliver_later       

    @solicitudlabexa.destroy


    respond_to do |format|
      format.html { redirect_to(solicitudlabexas_url) }
      format.xml  { head :ok }
    end
  end

 
  def listar
    cadena=params[:query]
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

    cadena=(cadena.nil?)? "%" : "%#{cadena}%"
    
    @usuarios=Usuario.where("nombre || apellidos LIKE ?",cadena).to_a
    codigos_u=@usuarios.map { |t| t.id}
    @asignaturas=Asignatura.where("nombre_asig || abrevia_asig || curso LIKE ?",cadena).to_a
    codigos_a=@asignaturas.map { |t| t.id}
    @labs_especiales=Laboratorio.where("ssoo || nombre_lab like ? and especial=?",cadena,"t").to_a
    nombre_l=@labs_especiales.map {|l| l.nombre_lab+'-'+l.ssoo+'-'+'si'+';'}
    nombre_l=nombre_l+@labs_especiales.map {|l| l.nombre_lab+'-'+l.ssoo+'-'+'no'+';'}
    @solicitudlabexas=Solicitudlabexa.where("npuestos || curso || fecha || fechasol LIKE ? or usuario_id in (?) or asignatura_id in (?) or preferencias in (?)", cadena, codigos_u, codigos_a, nombre_l).to_a
    
    tiempoSolicitud = params[:tiempoSolicitud]
    case tiempoSolicitud
      when '0' then @solicitudlabexas = getCurrentRequests(@solicitudlabexas, false)
      when '1' then @solicitudlabexas = getCurrentCuatrimesterRequests(@solicitudlabexas, false)
      when '2' then @solicitudlabexas = getFromLastYearRequests(@solicitudlabexas, false)
      when '3' then @solicitudlabexas = getFromLast2YearsRequests(@solicitudlabexas, false)

    end

    @cuenta = @solicitudlabexas.size
    
    respond_to do |format|
      format.js 
    end
  end

private
def solicitudlabexas_params
  params.require(:solicitudlabexa).permit()
end

 
end
