class SolicitudusuariolabsController < ApplicationController

   before_action :login_requerido,:usuario?
   #before_action :getIndexView, :only=> [:index,:copy]

  def index
     
    getIndexView

    getCopyInfo

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @solicitudusuariolab }
    end
  end

  #método para realizar la copia de solicitudes del año anterior
  def copy
    

    getCopyInfo

    #actualizar fechaini, fechafin y fechasol al curso académico actual
    #y guardar las solicitudes en la bbdd
    solicitudesIds = Hash.new
    @solicitudlabsAñoPasado.each do |s| 
      nuevaSolicitud = Solicitudlab.new

      if s.fechaini.month <= @periodo.inicio.month and s.fechaini.day <= @periodo.inicio.day
        nuevaSolicitud.fechaini = @periodo.inicio
      else
        nuevaSolicitud.fechaini = Date.new(s.fechaini.next_year.year,s.fechaini.month, s.fechaini.day)
      end
      
      if s.fechafin.month >= @periodo.fin.month and s.fechafin.day >= @periodo.fin.day
        nuevaSolicitud.fechafin = @periodo.fin
      else
        nuevaSolicitud.fechafin = Date.new(s.fechafin.next_year.year, s.fechafin.month, s.fechafin.day)
      end
      
      nuevaSolicitud.fechasol = Date.today
      nuevaSolicitud.usuario_id = s.usuario_id
      nuevaSolicitud.asignatura_id = s.asignatura_id
      nuevaSolicitud.curso = s.curso
      nuevaSolicitud.npuestos = s.npuestos
      nuevaSolicitud.comentarios = s.comentarios
      nuevaSolicitud.preferencias = s.preferencias
      nuevaSolicitud.tipo = s.tipo
      nuevaSolicitud.asignado = 'N'  
      nuevaSolicitud.save

      logger.debug(nuevaSolicitud.errors.inspect) 
      solicitudesIds[s.id] = nuevaSolicitud.id
    end

    #obtener las peticiones de laboratorios asociadas a las solicitudes del año pasado
    #y guardarlas actualizas en la bbdd
    peticionlabsAñoPasado = getLabPetitionsLastYear(@solicitudlabsAñoPasado)
    peticionlabsAñoPasado.each do |p|
        nuevaPeticion = Peticionlab.new
        nuevaPeticion.diasemana = p.diasemana
        nuevaPeticion.horaini = p.horaini
        nuevaPeticion.horafin = p.horafin
        nuevaPeticion.solicitudlab_id = solicitudesIds[p.solicitudlab_id]
        if !nuevaPeticion.solicitudlab_id.nil?
            nuevaPeticion.save
        end
    end
 
    getIndexView

    #ToDo: enviar info de error al ajax
    respond_to do |format| format.js  end

  end

  def edit
    
    @solicitudlab = Solicitudlab.find(params[:id])
    session[:tramos_horarios]=Solicitudhoraria.new
    session[:tramos_horarios].solicitudes=Peticionlab.where("solicitudlab_id = ? ",@solicitudlab.id).to_a 
    session[:codigo_tramo]=0
    session[:borrar]=[]
    @asignatura=Asignatura.find(@solicitudlab.asignatura_id)
    @asignaturas=Asignatura.where('titulacion_id = ? and curso = ?', @asignatura.titulacion_id, @solicitudlab.asignatura.curso).order("nombre_asig").to_a
    #@solicitudlab.fechaini=formato_europeo(@solicitudlab.fechaini)
    #@solicitudlab.fechafin=formato_europeo(@solicitudlab.fechafin)
    getViewModel
    respond_to do |format|
      format.html
      format.xml  { render :xml => @solicitudusuariolab }
    end


  end

def new
    @periodo=Periodo.where("admision = ?",'t').first
    @solicitudlab = Solicitudlab.new
    @solicitudlab.preferencias=""
    @solicitudlab.fechafin= @periodo.fin
    @solicitudlab.fechaini=@periodo.inicio
    @solicitudlab.asignatura=Asignatura.new
    if (Asignatura::CURSO).first=="optativa"
      as='0'
    else
      as=Asignatura::CURSO.first
    end
    getViewModel
    @asignaturas=Asignatura.where("titulacion_id = ? AND curso = ?",@titulaciones.first.id,as).to_a 
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

  
  def create
    @solicitudlab = Solicitudlab.new
    #if (Asignatura::CURSO).first=="optativa"
    #  as='0'
    #else
    #  as=Asignatura::CURSO.first
    #end
    saveModel(params)
    #@asignaturas=Asignatura.where("titulacion_id = ? AND curso = ?",@titulaciones.first.id,as).to_a 
# HACER UN DRYYYYYYY!!!!!
    getViewModel
    respond_to do |format|
    if session[:tramos_horarios].solicitudes.empty?           # no permitiremos una peticion sin tramos
      flash[:notice]="No hay tramos horarios en su peticion"
      format.html { render :action => "new" }
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
                              @correotramos+=' - '+p.diasemana+' de '+p.horaini+' a '+p.horafin}

      
        CorreoTecnicos::emitesolicitudlectivo(@solicitudlab,params[:fechaini],params[:fechafin],@correotramos,"","Nueva ").deliver_later                        
        @solicitudlabs = Solicitudlab.where("usuario_id = ?",@usuario_actual.id).to_a
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @solicitudlabs, :status => :created, :location => @solicitudlabs }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @solicitudlabs.errors, :status => :unprocessable_entity }
      end
     end
    end
    
  end

def getViewModel
@titulaciones=Titulacion.order("id").to_a
@puestos=Laboratorio.find_by_sql(["select distinct(puestos) from laboratorios order by puestos"]).map{|l| l.puestos}
if(@solicitudlab.asignatura == nil)
  @solicitudlab.asignatura=Asignatura.new
end
@asignaturas=Asignatura.where('titulacion_id = ? and curso = ?', @solicitudlab.asignatura.titulacion_id, @solicitudlab.asignatura.curso).order("nombre_asig").to_a

end

def saveModel(params)
  @solicitudlab.usuario_id = @usuario_actual.id
  if @solicitudlab.asignatura==nil
      @solicitudlab.asignatura=Asignatura.new
  end
  @solicitudlab.asignatura_id = params[:asignatura][:id].to_i unless params[:asignatura].nil?
  @solicitudlab.asignatura.titulacion_id = params[:titulacion][:titulacion_id].to_i
  @solicitudlab.asignatura.curso = params[:nivel].to_s
  @solicitudlab.comentarios=Iconv.conv('ascii//translit//ignore', 'utf-8', params[:comentarios])
  @solicitudlab.fechaini=params[:fechaini].to_date
  @solicitudlab.fechafin = params[:fechafin].to_date
  @solicitudlab.usuario_id = @usuario_actual.id

  @solicitudlab.npuestos = params[:npuestos].to_s
  @solicitudlab.fechasol = Date.today
  periodoact=Periodo.where("admision = ? and tipo = ? ","t","Lectivo").first
  if periodoact.nil? # si es un user no puede cursar en periodo sin activaRRRRRRRR!!!!!!!!!
    iniperiodoact=finperiodoact=Date.today 
  else 
    iniperiodoact=periodoact.inicio
    finperiodoact=periodoact.fin
  end
  @solicitudlab.asignado="N"
   if params[:fechaini]==params[:fechafin]
       @solicitudlab.tipo="S"
    else
       if params[:fechaini]==iniperiodoact and params[:fechafin]==finperiodoact
         @solicitudlab.tipo="T"
       else
         @solicitudlab.tipo="P"
       end
    end
     pref=""
   @especiales=Laboratorio.where("especial=?","t").to_a
    for especial in @especiales do
      nombre=especial.ssoo.to_s
      if params[:"#{nombre}"].to_s!='in'
        pref+=especial.nombre_lab.to_s+'-'+nombre+'-'+params[:"#{nombre}"]+";"
      end
    end
    @solicitudlab.preferencias=pref
end

def update
    @solicitudlab = Solicitudlab.where("id = ? ",params[:solicitudlab][:id]).first
    saveModel(params)
   
    respond_to do |format|
    getViewModel
# UN DRYYY!!!!!
    if session[:tramos_horarios].solicitudes.empty?           # no permitiremos una peticion sin tramos
      flash[:notice]="No hay tramos horarios en su peticion"
      format.html { render :action => "edit" }
    else     
      if @solicitudlab.save

        @tramos=session[:tramos_horarios].solicitudes
        @tramos.each {|tramo| if tramo.id.to_i<0
                                p=Peticionlab.new
                                p.solicitudlab_id=@solicitudlab.id
                                p.diasemana=tramo.diasemana
                                p.horaini=tramo.horaini
                                p.horafin=tramo.horafin
                                p.save
                              end  }
        @borrados=session[:borrar]
        @borrados.each {|tramo| if tramo.to_i > 0
                                  reg=Peticionlab.find(tramo)
                                  reg.destroy
                                end } unless @borrados.empty?
        # flash[:notice] = 'Solicitudrecurso was successfully updated.'
        CorreoTecnicos::emitesolicitudlectivo(@solicitudlab,params[:fechaini],params[:fechafin],@correotramos,"","Cambios en ").deliver_later       
        @solicitudlabs = Solicitudlab.where("usuario_id = ?", @usuario_actual.id).to_a
        format.html { render :action => "index" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @solicitudusuariolab.errors, :status => :unprocessable_entity }
      end
    end
    end
  end
  # DELETE /solicitudlabs/1
  # DELETE /solicitudlabs/1.xml
 def destroy
    @solicitudlab = Solicitudlab.find(params[:id])
    @tramos=Peticionlab.where("solicitudlab_id = ?", @solicitudlab.id).to_a # busco todos los tramos que tenian el id
    @tramos.each {|tramo| tramo.destroy} # los elimino en cascada
    CorreoTecnicos::emitesolicitudlectivo(@solicitudlab,params[:fechaini],params[:fechafin],@correotramos,"","Borrado de ").deliver_later       
    @solicitudlab.destroy
    respond_to do |format|
      format.html { redirect_to(solicitudusuariolabs_url) }
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
    
    
    @asignaturas=Asignatura.where("nombre_asig || curso LIKE ?",cadena).to_a
    codigos_a=@asignaturas.map { |t| t.id}
    @tramos=Peticionlab.where("diasemana || horaini || horafin LIKE ?",cadena).to_a
    codigos_t=@tramos.map { |t| t.solicitudlab_id}
    @labs_especiales=Laboratorio.where("ssoo || nombre_lab like ? and especial=?",cadena,"t").to_a
    nombre_l=@labs_especiales.map {|l| l.nombre_lab+'-'+l.ssoo+'-'+'si'+';'}
    nombre_l=nombre_l+@labs_especiales.map {|l| l.nombre_lab+'-'+l.ssoo+'-'+'no'+';'}
    @solicitudlabs=Solicitudlab.where("usuario_id == ? and (npuestos || curso || fechaini || fechafin || fechasol LIKE ? or asignatura_id in (?) or id in (?) or preferencias in (?))", session[:user_id],cadena, codigos_a, codigos_t,nombre_l).to_a
    @cuenta=@solicitudlabs.size
    respond_to {|format| format.js }
  end

  private

    def solicitudusuariolab_params
      params.require(:solicitudlab).permit(:id)
    end

    def getPeriodWithAdmission
      # Obtener el período lectivo que permite admisiones
      @periodo=Periodo.where("admision = ? AND tipo = ?","t","Lectivo").first
      return @periodo
    end

    def isLabRequestCurrent?(labRequest)
      primerCuatrimestre=Periodo.where("id =?",1).first
      segundoCuatrimestre=Periodo.where("id =?",2).first
      
      return true if (labRequest.fechaini >= primerCuatrimestre.inicio and labRequest.fechafin <= primerCuatrimestre.fin) or
      (labRequest.fechaini >= segundoCuatrimestre.inicio and labRequest.fechafin <= segundoCuatrimestre.fin)
    end

    def labRequestsAllowed?     
       return (getPeriodWithAdmission.nil? == false) 
    end

    def getLabRequestsLastYear
      primerCuatrimestre=Periodo.where("id =?",1).first
      segundoCuatrimestre=Periodo.where("id =?",2).first

      iniCursoAcademicoPasado = Date.new(primerCuatrimestre.inicio.prev_year.year,9,1)
      finCursoAcademicoPasado = Date.new(segundoCuatrimestre.inicio.prev_year.year,9,1)

      @solicitudlabs= Solicitudlab.where("usuario_id = ?",@usuario_actual.id).to_a
      return @solicitudlabs.select {|s| s.fechaini >= iniCursoAcademicoPasado and s.fechaini< finCursoAcademicoPasado}

    end

    def getLabPetitionsLastYear(labRequestsLastYear)
      labRequestsLastYearIds = labRequestsLastYear.collect {|r| r.id}.to_a
      labPetitionsLastYear = Peticionlab.all.select {|p| labRequestsLastYearIds.include?(p.solicitudlab_id)}
      return labPetitionsLastYear
    end

    def filterLabRequestsLastYearForPeriod(labRequestsLastYear, periodo)
    
    solicitudlabs=Array.new

    if (!periodo.nil?)
      if (periodo.id == 1) #primer cuatrimestre: asignaturas del primer cuatrimestre y anuales en el primer cuatrimestre
        solicitudlabs = labRequestsLastYear.select{|a| !a.asignatura.nil? and (a.asignatura.cuatrimestre == 1 or (a.asignatura.cuatrimestre==0 and a.fechafin.month <= periodo.fin.month))}.uniq
      end
      if (periodo.id == 2) #segundo cuatrimestre: asignaturas del segundo cuatrimestre y anuales en el segundo cuatrimestre
        solicitudlabs = labRequestsLastYear.select{|a| !a.asignatura.nil? and (a.asignatura.cuatrimestre == 2 or (a.asignatura.cuatrimestre==0 and a.fechaini.month >= periodo.inicio.month))}.uniq
      end
    end

    return solicitudlabs

    end

    def getIndexView
      @solicitudlabs= Solicitudlab.where("usuario_id = ?",@usuario_actual.id).to_a
      #mostrar sólo las solicitudes del curso académico actual
      @solicitudlabs = @solicitudlabs.select{|s| isLabRequestCurrent?(s)}
      @cuenta=@solicitudlabs.size

    end

    def getCopyInfo
      #ver si hay solicitudes del año pasado
      @solicitudlabsAñoPasado = getLabRequestsLastYear
      #coger sólo las solicitudes correspondientes al período lectivo actual con admision = true
      @periodo = getPeriodWithAdmission
      @solicitudlabsAñoPasado = filterLabRequestsLastYearForPeriod(@solicitudlabsAñoPasado, @periodo)
      @numSolLabAñoPasado = @solicitudlabsAñoPasado.size
      @labRequestsAllowed = !@periodo.nil?
    end


end
