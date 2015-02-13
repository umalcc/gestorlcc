class SolicitudusuariolabexasController < ApplicationController
  # GET /solicitudlabexas
  # GET /solicitudlabexas.xml

  before_action :login_requerido,:usuario?

  include SolicitudesHelper


  def index
    
    getIndexView
    
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
     @solicitudlabexa.fecha=Date.today
    @solicitudlabexa.preferencias=""
    session[:titulacion]=Titulacion.first
    session[:nivel]=Asignatura::CURSO.first
    @action="create"
    getViewModel
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @solicitudlabexa }
    end
  end

  # GET /solicitudlabs/1/edit
  def edit
    @solicitudlabexa = Solicitudlabexa.find(params[:id])
    @action="update" 
    getViewModel
       
    #@asignatura=Asignatura.find(@solicitudlabexa.asignatura_id)
    #@solicitudlabexa.fecha=fecha_europea(@solicitudlabexa.fecha)
   # @asignaturas=Asignatura.where('titulacion_id = ? and curso = ?', @asignatura.titulacion_id, @solicitudlabexa.asignatura.curso).order("nombre_asig").to_a
    #@usuarios=Usuario.order("apellidos").to_a.reject{|u| u.identificador=="anonimo"}
  end

  # POST /solicitudlabs
  # POST /solicitudlabs.xml
  def saveObject(params)
 
    @solicitudlabexa.usuario_id = @usuario_actual.id
    if params[:asignatura].nil?
      @solicitudlabexa.asignatura=Asignatura.new
      @solicitudlabexa.asignatura.titulacion_id=params[:titulacion][:titulacion_id]
      @solicitudlabexa.asignatura.curso=params[:nivel]
      @solicitudlabexa.asignatura.id=0
    else
      @solicitudlabexa.asignatura_id = params[:asignatura][:id].to_i
    end

    logger.debug "Asignaturaaass"+@solicitudlabexa.asignatura.titulacion_id.to_s
    
    @solicitudlabexa.fechasol=Date.today
    @solicitudlabexa.npuestos=params[:npuestos].to_s
    @solicitudlabexa.curso=params[:nivel].to_s == '0' ? 'optativa' : params[:nivel].to_s
    @solicitudlabexa.comentarios=Iconv.conv('ascii//translit//ignore', 'utf-8', params[:comentarios])
    @solicitudlabexa.horaini=params[:horaini][:comienzo]
    @solicitudlabexa.horafin=params[:horafin][:fin]
    @solicitudlabexa.asignado="N"
    
    pref=""
    @especiales=Laboratorio.where('especial=?',"t").to_a 
    for especial in @especiales do
      nombre=especial.ssoo.to_s
      if params[:"#{nombre}"].to_s!='in'
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

  def create   
    @solicitudlabexa = Solicitudlabexa.new
    saveObject(params)
     
    @solicitudlabexa.tipo="P"
    getViewModel
    respond_to do |format|
      if @solicitudlabexa.save      
         CorreoTecnicos::emitesolicitudexamen(@solicitudlabexa,params[:fecha],"","Nueva ").deliver_later                                  
        @solicitudlabexas = Solicitudlabexa.where("usuario_id = ?",@usuario_actual.id).to_a
        
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @solicitudlabexas, :status => :created, :location => @solicitudlabexas }
      else
        @action="create"
        format.html { render :action => "new" }
        format.xml  { render :xml => @solicitudlabexas.errors, :status => :unprocessable_entity }
      end
    end
  end

  def getViewModel
    @especiales=Laboratorio.where('especial=?',"t").to_a 
    @titulaciones=Titulacion.order("nombre").to_a
     if (@solicitudlabexa.asignatura_id == nil)
      #@solicitudlabexa.asignatura_id=0
      if (Asignatura::CURSO).first=="optativa"
         as='0'
      else 
         as=Asignatura::CURSO.first
      end
       @asignaturas=Asignatura.where('titulacion_id = ? and curso = ?',@titulaciones.first.id,as).to_a
   else
       @asignatura=Asignatura.find(@solicitudlabexa.asignatura_id)
       @asignaturas=Asignatura.where('titulacion_id = ? and curso = ?', @asignatura.titulacion_id, @solicitudlabexa.asignatura.curso).order("nombre_asig").to_a
   end
    
    @puestos=Laboratorio.find_by_sql(["select distinct(puestos) from laboratorios order by puestos"]).map{|l| l.puestos}
    @horas=Horasexa.where('en_uso=?',"t").order("id").to_a
  end
  # PUT /solicitudlabexas/1
  # PUT /solicitudlabexas/1.xml

 def update
    @solicitudlabexa = Solicitudlabexa.find(params[:id])
    saveObject(params)
    getViewModel
    respond_to do |format|

        if @solicitudlabexa.save
          CorreoTecnicos::emitesolicitudexamen(@solicitudlabexa,params[:fecha],"","Cambios en ").deliver_later   
          getIndexView
          format.html { redirect_to :action => "index" }
          format.xml  { head :ok }
      else
         @action="update"
        format.html { render :action => "edit"}
        format.xml  { render :xml => @solicitudlabexa.errors, :status => :unprocessable_entity }
   end
 end
  end

  # DELETE /solicitudlabexas/1
  # DELETE /solicitudlabexas/1.xml
 def destroy
    @solicitudlabexa = Solicitudlabexa.find(params[:id])
    CorreoTecnicos::emitesolicitudexamen(@solicitudlabexa,params[:fecha],"","Borrado de ").deliver_later   
    @solicitudlabexa.destroy
    respond_to do |format|
      format.html { redirect_to(solicitudusuariolabexas_url) }
      format.xml  { head :ok }
    end
  end

 
def listar  #está incompleto.....
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
    
    @asignaturas=Asignatura.where("nombre_asig || abrevia_asig || curso LIKE ?",cadena).to_a
    codigos_a=@asignaturas.map { |t| t.id}
    @labs_especiales=Laboratorio.where("ssoo || nombre_lab like ? and especial=?",cadena,"t").to_a
    nombre_l=@labs_especiales.map {|l| l.nombre_lab+'-'+l.ssoo+'-'+'si'+';'}
    nombre_l=nombre_l+@labs_especiales.map {|l| l.nombre_lab+'-'+l.ssoo+'-'+'no'+';'}
    @solicitudlabexas=Solicitudlabexa.where("usuario_id == ? and (npuestos || curso || fecha || fechasol LIKE ?  or asignatura_id in (?) or preferencias in (?))", session[:user_id], cadena, codigos_a, nombre_l).to_a
    @solicitudlabexas=@solicitudlabexas.select{|s| isLabRequestCurrent?(s)}
    @cuenta=@solicitudlabexas.size

    respond_to {|format| format.js }

end

def getIndexView

      @solicitudlabexas= Solicitudlabexa.where("usuario_id = ?",@usuario_actual.id).order("fecha").to_a
      @solicitudlabexas = @solicitudlabexas.select{|s| isLabRequestCurrent?(s)}
      @cuenta=@solicitudlabexas.size
end

private
def solicitudlabexas_params
  params.require(:solicitudlabexa).permit()
end

 
end
