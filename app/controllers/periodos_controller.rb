class PeriodosController < ApplicationController
  # GET /periodos
  # GET /periodos.xml


  before_action :login_requerido
  before_action :admin?
 

  @@tipo=''

  def index
    @periodos = Periodo.order("inicio").to_a
    session[:cambia_activo]=cambia_admision=false

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @periodos }
    end
  end

  # GET /periodos/new
  # GET /periodos/new.xml
  def new
    @periodo = Periodo.new
    @periodo.inicio = Date.today
    @periodo.fin = Date.today
    @periodo.iniciosol = Date.today
    @periodo.finsol = Date.today
    ##@dia=formato_europeo(Date.today)
    #hoy=Date.today.to_s.split('-') 
    #@dia=hoy[2]+'-'+hoy[1]+'-'+hoy[0]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @periodo }
    end
  end

  # GET /periodos/1/edit
  def edit
    @periodo = Periodo.find(params[:id])
    @tipoact=@periodo.tipo
    @activo="NO" unless @periodo.activo?
    @admision="NO" unless @periodo.admision? 
  end

  # POST /periodos
  # POST /periodos.xml
  def create
    @periodo = Periodo.new
    saveModel(params)
    ###@periodo.tipo=params[:tipo]
    #@periodo.activo=params[:activo]=="SI"

    respond_to do |format|
      if @periodo.save
        @periodos = Periodo.order("inicio").to_a
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @periodo, :status => :created, :location => @periodo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @periodo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /periodos/1
  # PUT /periodos/1.xml
  def update
    @periodo = Periodo.find(params[:id])
    saveModel(params)
    @periodo.activo=params[:activo]=="1"
    @periodo.admision=params[:admision]=="1"

    respond_to do |format|
      if @periodo.update(periodo_params)  
         @periodos = Periodo.order("inicio").to_a
         format.html { redirect_to :action => "index" }
         format.xml  { head :ok }
      else
         format.html { render :action => "edit" }
         format.xml  { render :xml => @periodo.errors, :status => :unprocessable_entity }
      end
    end
  end

  def cambia_activo 

     @p=Periodo.find(session[:periodo])
     respond_to do |format|
      format.js
    end  
  end

  def enviar_correo_activo_on
   if params[:tipo]=="Lectivo"
    CorreoTecnicos::adjudicalectivo.deliver_later 
   else
    CorreoTecnicos::adjudicaexamen.deliver_later 
   end
    @mensaje="Correo enviado"

    respond_to do |format|
      format.js
    end  
    #render :update do |page|
   #     page.replace_html(:'activo', :partial=>"control_adjudicacion_on", :object=>@mensaje)
   # end
  end

  def enviar_correo_activo_off
    if params[:tipo]=="Lectivo"
    CorreoTecnicos::cierreadjudicalectivo.deliver_later 
   else
    CorreoTecnicos::cierreadjudicaexamen.deliver_later 
   end
    @mensaje="Correo enviado"
     respond_to do |format|
      format.js
    end  
   # render :update do |page|
    #    page.replace_html(:'activo', :partial=>"control_adjudicacion_off", :object=>@mensaje)
    #end
  end

  def grabar_historico
    
### FALTA PASAR CADA ASIGNACION AL HISTORICO
 
    asignaciones=Asignaciondef.all

    if !asignaciones.nil?
      conta=0
      asignaciones.each {|a| if a.solicitudlab.tipo=="T"
                             h=Historicoasig.new
                             h.fecha_archivo=Date.today
                             h.periodo=Periodo.find(session[:periodo]).nombre
                             h.nombre_usu=a.solicitudlab.usuario.nombre
                             h.apellidos_usu=a.solicitudlab.usuario.apellidos
                             h.nombre_asig=a.solicitudlab.asignatura.nombre_asig
                             h.nombre_tit=a.solicitudlab.asignatura.titulacion.nombre
                             h.curso=a.solicitudlab.curso
                             h.nombre_lab=a.laboratorio.nombre_lab
                             h.puestos=a.laboratorio.puestos
                             h.horaini=a.horaini
                             h.horafin=a.horafin
                             h.diasem=a.dia.nombre
                             h.save
                             conta+=1 
                             end
                             a.destroy      }
    end
   
    solicitudes=Solicitudlab.where("asignado = ?","D").to_a
    solicitudes.each{|s| 
                   peticiones= Peticionlab.where("solicitudlab_id = ? ",s.id).to_a
                   peticiones.each{|p| p.destroy}
                   s.destroy}

    @mensaje="Grabadas en archivo historico "+conta.to_s+" asignaciones"
     respond_to do |format|
      format.js
    end  
    #render :update do |page|
    #    page.replace_html(:'activo', :partial=>"control_adjudicacion_off", :object=>@mensaje)
    #end

  end

  def grabar_historico_examen
    
### FALTA PASAR CADA ASIGNACION AL HISTORICO
 
    asignaciones=Asignacionlabexadef.all

    if !asignaciones.nil?
      conta=0
      asignaciones.each {|a| h=Historicoasigexa.new
                             h.fecha_archivo=Date.today
                             h.periodo=Periodo.find(session[:periodo]).nombre
                             h.nombre_usu=a.solicitudlabexa.usuario.nombre
                             h.apellidos_usu=a.solicitudlabexa.usuario.apellidos
                             h.nombre_asig=a.solicitudlabexa.asignatura.nombre_asig
                             h.nombre_tit=a.solicitudlabexa.asignatura.titulacion.nombre
                             h.curso=a.solicitudlabexa.curso
                             h.nombre_lab=a.laboratorio.nombre_lab
                             h.puestos=a.laboratorio.puestos
                             h.horaini=a.horaini
                             h.horafin=a.horafin
                             h.dia=a.dia
                             h.save
                             a.destroy
                             conta+=1 }
    end

    solicitudes=Solicitudlabexa.where("asignado = ?","D").to_a
    solicitudes.each{|s| s.destroy}

    @mensaje="Grabadas en archivo historico "+conta.to_s+" asignaciones"
     respond_to do |format|
      format.js
    end  
    #render :update do |page|
    #    page.replace_html(:'activo', :partial=>"control_adjudicacion_examen_off", :object=>@mensaje)
    #end

  end

  def cambia_admision
     session[:cambia_admision]=true

     @p=Periodo.find(session[:periodo])
     respond_to do |format|
      format.js
     end
  end


  def enviar_correo_lectivo_on
     p=Periodo.find(session[:periodo])
    if p.finsol ==nil
      @mensaje="El campo Fecha fin de solicitudes no puede ser vacio<br/>.Por favor, rellene este campo guarde los cambios y vuelva a intentarlo. "
    else
      @mensaje="Correo enviado"
     
      if p.tipo=="Lectivo"
        CorreoTecnicos::aperturalectivo(p.nombre,formato_europeo(p.finsol)).deliver_later 
      else
        CorreoTecnicos::aperturaexamen(p.nombre,formato_europeo(p.finsol)).deliver_later 
      end
    end
   
     respond_to do |format|
      format.js
    end  
    #render :update do |page|
    #    page.replace_html(:'admision', :partial=>"control_admision_on", :object=>@mensaje)
    #end
  end

  def enviar_correo_lectivo_off
   p=Periodo.find(session[:periodo])
   if p.tipo=="Lectivo"
    CorreoTecnicos::cierrelectivo(p.nombre).deliver_later 
   else
    CorreoTecnicos::cierreexamen(p.nombre).deliver_later 
   end
    @mensaje="Correo enviado"
     respond_to do |format|
      format.js
    end  
    #render :update do |page|
    #    page.replace_html(:'admision', :partial=>"control_admision_off", :object=>@mensaje)
    #end
  end


def enviar_correo_activo_on
   p=Periodo.find(session[:periodo])
   if p.tipo=="Lectivo"
    CorreoTecnicos::adjudicalectivo(p.nombre).deliver_later 
   else
    CorreoTecnicos::adjudicaexamen(p.nombre).deliver_later 
   end
    @mensaje="Correo enviado"
     respond_to do |format|
      format.js
    end  
    #render :update do |page|
    #    page.replace_html(:'activo', :partial=>"control_adjudicacion_on", :object=>@mensaje)
    #end
  end

  def enviar_correo_activo_off
   p=Periodo.find(session[:periodo])
   if p.tipo=="Lectivo"
    CorreoTecnicos::cierreadjudicalectivo(p.nombre).deliver_later 
   else
    CorreoTecnicos::cierreadjudicaexamen(p.nombre).deliver_later 
   end
    @mensaje="Correo enviado"
     respond_to do |format|
      format.js
    end  
    #render :update do |page|
    #    page.replace_html(:'activo', :partial=>"control_adjudicacion_off", :object=>@mensaje)
    #end
  end

  # DELETE /periodos/1
  # DELETE /periodos/1.xml
  def destroy
    @periodo = Periodo.find(params[:id])
    @periodo.destroy

    respond_to do |format|
      format.html { redirect_to(periodos_url) }
      format.xml  { head :ok }
    end
  end

  private

   def saveModel(params)
    @periodo.nombre = params[:nombre]
    @periodo.tipo=params[:tipo]
    @periodo.inicio=params[:inicio]
    @periodo.fin=params[:fin]
    @periodo.iniciosol=params[:iniciosol]
    @periodo.finsol=params[:finsol]
   end

   def periodo_params
      params.require(:periodo).permit(:nombre, :inicio, :fin, :tipo, :iniciosol, :finsol, :admision, :activo)
   end


end
