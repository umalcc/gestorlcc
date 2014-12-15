class SolicitudlabexasController < ApplicationController
  # GET /solicitudlabexas
  # GET /solicitudlabexas.xml

  before_action :login_requerido, :admin?

  def index
    @solicitudlabexas = Solicitudlabexa.order("fecha").to_a
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
    @especiales=Laboratorio.where('especial=?',"t").to_a 
    session[:titulacion]=Titulacion.first
    session[:nivel]=Asignatura::CURSO.first
    getViewModel
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @solicitudlabexa }
    end
  end

  # GET /solicitudlabs/1/edit
  def edit
    @solicitudlabexa = Solicitudlabexa.find(params[:id]) 
    getViewModel
       
    #@asignatura=Asignatura.find(@solicitudlabexa.asignatura_id)
    #@solicitudlabexa.fecha=fecha_europea(@solicitudlabexa.fecha)
   # @asignaturas=Asignatura.where('titulacion_id = ? and curso = ?', @asignatura.titulacion_id, @solicitudlabexa.asignatura.curso).order("nombre_asig").to_a
    #@usuarios=Usuario.order("apellidos").to_a.reject{|u| u.identificador=="anonimo"}
    getSelected
  end

  # POST /solicitudlabs
  # POST /solicitudlabs.xml
  def saveObject(params)
 
    @solicitudlabexa.usuario_id = params[:usuario][:identificador].to_i
    if params[:asignatura].nil?
      @solicitudlabexa.asignatura_id=nil
    else
      @solicitudlabexa.asignatura_id = params[:asignatura][:id].to_i
    end
    @solicitudlabexa.fechasol=Date.today
    @solicitudlabexa.npuestos=params[:npuestos].to_s
    @solicitudlabexa.curso=params[:nivel].to_s
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
  
    
    @solicitudlabexa = Solicitudlabexa.new(params[:solicitudlabexa])
     getViewModel
    saveObject(params)
  
    @solicitudlabexa.tipo="P"
    
    respond_to do |format|
    getSelected
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
  def getSelected
     if @solicitudlabexa.asignatura == nil
      @solicitudlabexa.asignatura=Asignatura.new
    end   
    if params[:titulacion] != nil 
       @titulacionselec=params[:titulacion][:titulacion_id]
     elsif @solicitudlabexa.asignatura.titulacion_id != nil
      @titulacionselec=@solicitudlabexa.asignatura.titulacion_id
     end
    @cursoselec=@solicitudlabexa.curso
    usuario=Usuario.find(@solicitudlabexa.usuario_id)
    @usuarioselec=usuario.apellidos+", "+usuario.nombre
    if @solicitudlabexa.asignatura_id != nil
      @asignaturaselec=@solicitudlabexa.asignatura_id
    end
  end

  def getViewModel
    @usuarios=Usuario.order("apellidos").to_a.reject{|u| u.identificador=="anonimo"} 
      @especiales=Laboratorio.where('especial=?',"t").to_a 
    @titulaciones=Titulacion.order("id").to_a
    @usuarios=Usuario.order("apellidos").to_a.reject{|u| u.identificador=="anonimo"}  
   if (@solicitudlabexa.asignatura_id == nil)
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
        getSelected

        if @solicitudlabexa.save
          CorreoTecnicos::emitesolicitudexamen(@solicitudlabexa,params[:fecha],"Solicitud cursada por admin","Cambios en ").deliver_later       
          @solicitudlabexas = Solicitudlabexa.all
          format.html { redirect_to :action => "index" }
          format.xml  { head :ok }
      else
        getSelected
        format.html { render :action => "edit"}
        format.xml  { render :xml => @solicitudlabexa.errors, :status => :unprocessable_entity }
   end
 end
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
    @cuenta=@solicitudlabexas.size
    respond_to do |format|
      format.js 
    end
  end

private
def solicitudlabexas_params
  params.require(:solicitudlabexa).permit()
end

 
end
