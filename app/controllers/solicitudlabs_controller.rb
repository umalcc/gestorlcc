class SolicitudlabsController < ApplicationController

  include SolicitudesHelper

  before_action :login_requerido, :admin?
  before_action :initializeIndex, :only=> [:index,:listar]
  before_action :getViewModel, only: [:new, :edit]



  def initializeIndex
      @tiempoSolicitudes = ["Actuales", "Desde hace un año", "Desde hace dos años"]
  end

  def index
    
    @solicitudlabs = getCurrentRequests(Solicitudlab.all)
    @cuenta=@solicitudlabs.size


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @solicitudlabs }
    end
  end

  def new

    @solicitudlab = Solicitudlab.new
    @solicitudlab.fechaini=Date.today
    @solicitudlab.fechafin=Date.today
    @solicitudlab.preferencias=""
    @asignaturas = Asignatura.where('titulacion_id = ? and curso = ?',@titulaciones.first,0).to_a
    @solicitudlab.asignatura=@asignaturas.first

    session[:titulacion]=Titulacion.first
    session[:nivel]=Asignatura::CURSO.first

    # esto es para crear un carro no persistente  
    session[:tramos_horarios]=Solicitudhoraria.new
    # y una identificacion de tramos horarios para poder borrarlos individualmente. Se ira decrementando
    session[:codigo_tramo]=0
   
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @solicitudlab }
    end
  end

  # POST /solicitudlabs
  # POST /solicitudlabs.xml
  def create 
    @solicitudlab = Solicitudlab.new

    saveModel(params)

    getViewModel
    getSubjects(@solicitudlab)

    respond_to do |format|
    if session[:tramos_horarios].solicitudes.empty?           # no permitiremos una peticion sin tramos
      flash.now[:notice]="No hay tramos horarios en su peticion"
      format.js
      format.html {render :action=>"new"}

    else 

      if @solicitudlab.save
        nuevo_id=@solicitudlab.id                       
        @tramos=session[:tramos_horarios].solicitudes
        @correotramos=''
        @tramos.each {|tramo| p=Peticionlab.new
                              p.solicitudlab_id=nuevo_id
                              p.diasemana=tramo.diasemana
                              p.horaini=tramo.horaini
                              p.horafin=tramo.horafin
                              p.save
                              @correotramos+=' - '+p.diasemana+' de '+p.horaini+' a '+p.horafin }
         
        CorreoTecnicos::emitesolicitudlectivo(@solicitudlab,params[:fechaini],params[:fechafin],@correotramos,"Solicitud cursada por admin","Nueva ").deliver_later      
        
        format.js
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @solicitudlabs, :status => :created, :location => @solicitudlabs }
         
      else
        
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @solicitudlabs.errors, :status => :unprocessable_entity }
      end
     
     end
    end
    
  end


  def edit
    
    @solicitudlab = Solicitudlab.find(params[:id])
    getSubjects(@solicitudlab)

    session[:tramos_horarios]=Solicitudhoraria.new
    session[:tramos_horarios].solicitudes=Peticionlab.where("solicitudlab_id = ?",@solicitudlab.id).to_a 
    session[:codigo_tramo]=0
    session[:borrar]=[]

  end

  def update
    @solicitudlab = Solicitudlab.find(params[:id])

    saveModel(params)

    getViewModel
    getSubjects(@solicitudlab)

    respond_to do |format|    
    if session[:tramos_horarios].solicitudes.empty?           # no permitiremos una peticion sin tramos
      flash.now[:notice]="No hay tramos horarios en su peticion"
      @borrados=session[:borrar]
      format.html { render :action=> "edit"}

    else # VEREMOS SI LAS FECHAS SON CORRECTAS SEGUN EL PERIODO
      if @solicitudlab.save
        @tramos=session[:tramos_horarios].solicitudes
        @correotramos=''
        @tramos.each {|tramo| if tramo.id.to_i<0
                                p=Peticionlab.new
                                p.solicitudlab_id=@solicitudlab.id
                                p.diasemana=tramo.diasemana
                                p.horaini=tramo.horaini
                                p.horafin=tramo.horafin
                                p.save
                                @correotramos+=' - '+p.diasemana+' de '+p.horaini+' a '+p.horafin
                              end  }

        @borrados=session[:borrar].uniq
        @borrados.each {|tramo| if tramo.to_i > 0
                                  reg=Peticionlab.find(tramo)
                                  reg.destroy
                                end } unless @borrados.empty?
        CorreoTecnicos::emitesolicitudlectivo(@solicitudlab,params[:fechaini],params[:fechafin],@correotramos,"Solicitud cursada por admin","Cambios en ").deliver_later 
        @solicitudlabs = Solicitudlab.all
        format.html { redirect_to :action => "index" }
        format.xml  { head :ok }
      else
        format.html { render :controller=> @solicitudlabs, :action => "edit"}
        format.xml  { render :xml => @solicitudlab.errors, :status => :unprocessable_entity }
      end
    end
  end
end


def saveModel(params)
    @solicitudlab.usuario_id = params[:usuario][:identificador].to_i
    
    if params[:asignatura].nil?
      @solicitudlab.asignatura=Asignatura.new
    else
      @solicitudlab.asignatura_id = params[:asignatura][:id].to_i
    end

    @solicitudlab.asignatura.titulacion_id=params[:titulacion][:titulacion_id] unless params[:titulacion].nil? 
    @solicitudlab.asignatura.curso=params[:nivel]
    @solicitudlab.curso = params[:nivel].to_s == '0' ? 'optativa' : params[:nivel].to_s
    @solicitudlab.npuestos=params[:npuestos].to_i
    @solicitudlab.comentarios= params[:comentarios]
    @solicitudlab.asignado="N"
    @solicitudlab.fechasol=Date.today
    @solicitudlab.fechaini=params[:fechaini].to_date
    @solicitudlab.fechafin=params[:fechafin].to_date

    pref=""
    @especiales=Laboratorio.where('especial=?',"t").to_a
    for especial in @especiales do
      nombre=especial.ssoo.to_s
      if !params[:"#{nombre}"].nil? && params[:"#{nombre}"].to_s!='in'
        pref+=especial.nombre_lab.to_s+'-'+nombre+'-'+params[:"#{nombre}"]+";"
      end
    end

    @solicitudlab.preferencias=pref
    
    periodoact=Periodo.where("admision = ? and tipo = ? ","t","Lectivo").first
    if periodoact.nil?
       iniperiodoact=finperiodoact=Date.today 
    else 
       iniperiodoact=periodoact.inicio
       finperiodoact=periodoact.fin
    end

    if params[:fechaini]==params[:fechafin]
       @solicitudlab.tipo="S"
    else
       if params[:fechaini]==iniperiodoact and params[:fechafin]==finperiodoact
         @solicitudlab.tipo="T"
       else
         @solicitudlab.tipo="P"
       end
    end

end
  

def getViewModel
     @especiales=Laboratorio.where('especial=?',"t").to_a 
     @puestos=Laboratorio.find_by_sql(["select distinct(puestos) from laboratorios order by puestos"]).map{|l| l.puestos}
     @titulaciones=Titulacion.order("nombre").to_a
     @usuarios=Usuario.order("apellidos").to_a.reject{|u| u.identificador=="anonimo"}
     @dias=Dia.where('en_uso=?',"t").to_a
     @horas=Horario.where('en_uso=?',"t").to_a
end

def getSubjects(solicitudlab)
    curso = solicitudlab.curso == "optativa" ? 0 : solicitudlab.curso.to_i
    @asignaturas = Asignatura.where('titulacion_id = ? and curso = ?',solicitudlab.asignatura.titulacion_id,curso).to_a
end

  # DELETE /solicitudlabs/1
  # DELETE /solicitudlabs/1.xml
 def destroy
    @solicitudlab = Solicitudlab.find(params[:id])
    CorreoTecnicos::emitesolicitudlectivo(@solicitudlab,params[:fechaini],params[:fechafin],@correotramos,"Solicitud cursada por admin","Borrado de ").deliver_later 
    @tramos=Peticionlab.where("solicitudlab_id = ?",@solicitudlab.id).to_a # busco todos los tramos que tenian el id
    @correotramos=''
    @tramos.each {|tramo| @correotramos+=' - '+tramo.diasemana+' de '+tramo.horaini+' a '+tramo.horafin
                          tramo.destroy} # los elimino en cascada
    @solicitudlab.destroy
    respond_to do |format|
      format.html { redirect_to(solicitudlabs_url) }
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
    @tramos=Peticionlab.where("diasemana || horaini || horafin LIKE ?",cadena).to_a
    codigos_t=@tramos.map { |t| t.solicitudlab_id}
    @labs_especiales=Laboratorio.where("ssoo || nombre_lab like ? and especial=?",cadena,"t").to_a
    nombre_l=@labs_especiales.map {|l| l.nombre_lab+'-'+l.ssoo+'-'+'si'+';'}
    nombre_l=nombre_l+@labs_especiales.map {|l| l.nombre_lab+'-'+l.ssoo+'-'+'no'+';'}
    @solicitudlabs=Solicitudlab.where("npuestos || curso || fechaini || fechafin || fechasol LIKE ? or usuario_id in (?) or asignatura_id in (?) or id in (?) or preferencias in (?)", cadena, codigos_u, codigos_a, codigos_t,nombre_l).to_a
    
    tiempoSolicitud = params[:tiempoSolicitud]
    case tiempoSolicitud
      when '0' then @solicitudlabs = getCurrentRequests(@solicitudlabs)
      when '1' then @solicitudlabs = getFromLastYearRequests(@solicitudlabs)
      when '2' then @solicitudlabs = getFromLast2YearsRequests(@solicitudlabs)
    end

    @cuenta = @solicitudlabs.size

    respond_to {|format| format.js }
  end

end
