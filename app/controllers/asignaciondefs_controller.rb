class AsignaciondefsController < ApplicationController
  # GET /asignacions
  # GET /asignacions.xml

 before_action :login_requerido
 before_action :admin?


  # DELETE /asignacions/1
  # DELETE /asignacions/1.xml
  def destroy
    @asignacion = Asignaciondef.find(params[:id])
    @asignacion.destroy

    respond_to do |format|
      format.html { render :nothing => true , :status => 200 }
      format.xml  { head :ok }
    end
  end

   def getAsignaciondef(id)
    @asignacion=Asignaciondef.where("id= ?",id).first
    titulo=getAsignacionTitulo(@asignacion)
    info=getAsignacionInfo(@asignacion)
    @asignacion=@asignacion.as_json

    @asignacion[:title]=titulo
    @asignacion[:info]=info
   return @asignacion
  end

  def grabar_asignacion
    # borrar las antiguas asignaciones definitivas, y sus solicitudes asociadas
    # leer asignaciones provisionales
    # grabarlas en definitivas
    # eliminar las provisionales

  
    @asignaciondefs=Asignaciondef.all
    if @asignaciondefs.size!=0
      solicitudes=@asignaciondefs.map{|a| a.solicitudlab_id}.uniq
      solicitudes.each{|s|  sol=Solicitudlab.find(s)
                            sol.destroy}
      @asignaciondefs.each{|a| a.peticionlab.destroy
                             a.destroy}
    end
    @asignacions=Asignacion.all
    @asignacions.each { |a| asig_def=Asignaciondef.new( :solicitudlab_id=>a.solicitudlab_id,
                                                        :peticionlab_id=>a.peticionlab_id,
                                                        :laboratorio_id=>a.laboratorio_id,
                                                        :horaini=>a.horaini,
                                                        :horafin=>a.horafin,
                                                        :dia_id=>a.dia_id,
                                                        :mov_dia=>a.mov_dia,
                                                        :mov_hora=>a.mov_hora)
                            
                            asig_def.save
                            sol=Solicitudlab.find(a.solicitudlab.id)
                            sol.asignado="D"
                            sol.save
                            a.destroy
                      }
    respond_to do |format|
      format.js
    end
  end
  
def anadirListaExterna
  #(session[:lista_externa] ||= []) << params[:id]
  @asignacion = Asignaciondef.find(params[:id])
  if(params[:copiar]=="true")
    #@asignacion = Asignaciondef.new(@asignacion.attributes)
    @asignacion = @asignacion.dup
  end
  @asignacion.temporal=true
  @asignacion.save!
  respond_to do |format|
    format.json {render json:@asignacion}
  end
end

def pegar
  ActiveRecord::Base.include_root_in_json = false
  @asignacion=Asignaciondef.find(params[:id])
  @asignacion.dia_id=params[:dia_id]
  @asignacion.temporal=false
  info=getAsignacionInfo(@asignacion)
  titulo=  getAsignacionTitulo(@asignacion)
  @asignacion.save
  @asignacion=@asignacion.as_json
  @asignacion[:titulo]=titulo
  @asignacion[:info]=info
   
  respond_to do |format|
    format.json {render json:@asignacion}
  end
end

def getAsignacionTitulo(asignacion)
  result=""

  if(asignacion.generica == nil || asignacion.generica.to_s == 'false')
    result=asignacion.solicitudlab.asignatura.abrevia_asig.to_s
  else
    result="RG"
  end

return result
end

def getAsignacionInfo(asignacion)
   #Obtener la ocupación del laboratorio para dicho evento
      ocupacion = " "                           
      info=" "
     if (asignacion.solicitudlab.tipo.to_s == "T")
          ocupacion = "Todo el período"
      elsif (asignacion.solicitudlab.tipo.to_s == "I")
       ocupacion = "Del " + asignacion.solicitudlab.fechaini.strftime("%d-%m-%Y") + " al " + asignacion.solicitudlab.fechafin.strftime("%d-%m-%Y")
      elsif (asignacion.solicitudlab.tipo.to_s == "X")
          ocupacion = "Asignación directa - Del " + asignacion.solicitudlab.fechaini.strftime("%d-%m-%Y") + " al " + asignacion.solicitudlab.fechafin.strftime("%d-%m-%Y")
      else
          ocupacion = "Puntual-" + asignacion.solicitudlab.fechaini.strftime("%d-%m-%Y")
    end
    info = "Puestos: " + asignacion.solicitudlab.npuestos.to_s 
    info= info + "%Profesor: " + asignacion.solicitudlab.usuario.nombre.to_s
    info= info +" "+  asignacion.solicitudlab.usuario.apellidos.to_s
    info= info + "%Soft: " + asignacion.solicitudlab.comentarios 
    info= info + "%Ocupación: " + ocupacion
    #Si la reserva no es genérica, necesitamos añadir la información de la asignatura
    #|| asignacion.generica.to_s == 'false'
    if asignacion.generica.nil? || asignacion.generica == false
       curso=asignacion.solicitudlab.curso == "0" ? "optativa" : asignacion.solicitudlab.curso
       asigInfo="Asig: " +asignacion.solicitudlab.asignatura.titulacion.abrevia+"(" +asignacion.solicitudlab.asignatura.abrevia_asig.to_s + ") %Curso: " + curso + "%"
       info = asigInfo + info
    else
       info = "Reserva genérica%"+info
    end
    return info   
  end

def asigna_directa
    @asignacion = Asignaciondef.new
    @asignacion.generica = false
    @asignacion.solicitudlab=Solicitudlab.new
    @asignacion.solicitudlab.asignatura=Asignatura.new(:curso =>0)
    @asignacion.solicitudlab.fechasol= Date.today
    @asignacion.solicitudlab.fechaini= Date.today
    @asignacion.solicitudlab.fechafin= Date.today
   
    getViewModel
    session[:tramos_horarios]=Solicitudhoraria.new
    session[:codigo_tramo]=0

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @asignacion.solicitudlab }
    end
  end
#aqui debe ir otra funcion tras captar el formulario anterior

  def graba
    @asignacion = Asignaciondef.new
    @asignacion.solicitudlab=Solicitudlab.new
    @asignacion.solicitudlab.asignatura=Asignatura.new
    @asignacion.solicitudlab.usuario_id = params[:usuario][:identificador].to_i

    if params[:asignacion][:generica] == "ReservaGenerica"
      @asignacion.generica = true
      titulacionId=Titulacion.where('abrevia = ?',"SD").first.id
      asignaturaId = Asignatura.where('abrevia_asig = ?', "Var. Sit.").first.id
      @asignacion.solicitudlab.asignatura.id = asignaturaId
      @asignacion.solicitudlab.asignatura_id = asignaturaId
      @asignacion.solicitudlab.asignatura.titulacion_id= titulacionId
      @asignacion.solicitudlab.asignatura.curso="optativa"
      @asignacion.solicitudlab.curso ="optativa"
    else
      @asignacion.generica = false
      asignaturaId = params[:asignatura][:id].to_i unless params[:asignatura].nil?
      @asignacion.solicitudlab.asignatura.id = asignaturaId
      @asignacion.solicitudlab.asignatura_id = asignaturaId
      @asignacion.solicitudlab.asignatura.titulacion_id=params[:titulacion][:titulacion_id]
      @asignacion.solicitudlab.asignatura.curso=params[:nivel].to_s 
      @asignacion.solicitudlab.curso =params[:nivel].to_s
    end
    @asignacion.solicitudlab.fechasol=Date.today
    @asignacion.solicitudlab.npuestos=Laboratorio.where("id= ?",params[:laboratorio][:laboratorio_id]).first.puestos
    @asignacion.solicitudlab.comentarios=params[:comentarios].to_s
    @asignacion.solicitudlab.asignado="D"
    @asignacion.solicitudlab.tipo="X"
    @asignacion.laboratorio_id=params[:laboratorio][:laboratorio_id].to_i
    
    @asignacion.solicitudlab.fechaini=params[:fechaini].to_date
    @asignacion.solicitudlab.fechafin=params[:fechafin].to_date
    getViewModel
    #@asignaturas=Asignatura.where('titulacion_id = ? and curso = ?',params[:titulacion][:titulacion_id],params[:nivel])
    respond_to do |format|
    if session[:tramos_horarios].solicitudes.empty? 
      flash.now[:notice]="No hay tramos horarios en su peticion"
      format.html { render :action => 'asigna_directa' }
    else
      if @asignacion.solicitudlab.save
        nuevo_id=@asignacion.solicitudlab.id                       
        @tramos=session[:tramos_horarios].solicitudes
        @tramos.each {|tramo| p=Peticionlab.new
                              p.solicitudlab_id=nuevo_id
                              p.diasemana=tramo.diasemana
                              p.horaini=tramo.horaini
                              p.horafin=tramo.horafin
                              p.save }
      # esto es lo quedebe cambiar, hay que ir a generar la asignacion nueva y hay que grabarla
      # y redirigir a la consulta de asignaciones  
      l=params[:laboratorio][:laboratorio_id].to_i
      peticiones=Peticionlab.where('solicitudlab_id = ?',@asignacion.solicitudlab.id).to_a
      peticiones.each {|p|  
                           hi=Horario.find_by_comienzo(p.horaini).id.to_i
                           hf=Horario.find_by_fin(p.horafin).id.to_i
                           dia_id=Dia.find_by_nombre(p.diasemana).id
                           for hora in hi..hf 
                               @asignacion=Asignacion.new(:solicitudlab_id=>@asignacion.solicitudlab.id,
                                                                 :laboratorio_id=>l,
                                                                 :peticionlab_id=>p.id,
                                                                 :dia_id=>dia_id,                      #aqui hay cambio
                                                                 :horaini=>Horario.find(hora).comienzo,
                                                                 :horafin=>Horario.find(hora).fin,
                                                                 :generica=>@asignacion.generica)
                               @asignacion.save
                           end
                       }
    # hasta aqui --------                   
        @asignacions = Asignaciondef.all
        format.html { redirect_to('/asignaciondefs/consulta') }
        format.xml  { render :xml => @solicitudlabs, :status => :created, :location => @solicitudlabs }
      else
        logger.debug @asignacion.solicitudlab.errors.full_messages

        format.html { render :action => "asigna_directa" }
        format.xml  { render :xml => @solicitudlabs.errors, :status => :unprocessable_entity }
      end
     end
    end
    
  end


def consulta
    ActiveRecord::Base.include_root_in_json = false

    @laboratorios=Laboratorio.all.select("id,nombre_lab, ssoo, puestos, especial")
    @laboratorios=@laboratorios.map{|lab| {:id => lab.id,
                                          :nombre_lab => lab.nombre_lab,
                                          :ssoo => lab.ssoo,
                                          :puestos => lab.puestos,
                                          :especial => lab.especial,
                                          :title => getLabInfo(lab)}}
    @laboratorios = @laboratorios.as_json

    #if(session[:lista_externa] == nil or session[:lista_externa].size == 0 )
    #  @asignacions = Asignaciondef.all
    #else
       #@asignacions = Asignaciondef.where("id not in (?)",session[:lista_externa]).all
       @asignacions=Asignaciondef.where("temporal= ?", 'f').all
    #end

    #if(session[:lista_externa] != nil)
      #@asignacionsListaExterna=Asignaciondef.where("id in (?)",session[:lista_externa]).all#.map{|r|{:id => r.id,:title => r.solicitudlab.asignatura.abrevia_asig.to_s}}
      @asignacionsListaExterna=Asignaciondef.where("temporal= ?", 't').all
    #end

    if @asignacions.size!=0
      @asignacionsListaExterna = @asignacionsListaExterna.reject{|a| !a.solicitudlab.nil? and a.solicitudlab.fechafin<Date.today}

      @asignacionsListaExterna = @asignacionsListaExterna.map { |r| {:id => r.id,
                                                                     :asignatura => r.solicitudlab.asignatura.abrevia_asig.to_s,
                                                                     :title => ((r.generica.to_s == 'null' || r.generica.to_s == 'false')? r.solicitudlab.asignatura.abrevia_asig.to_s : "RG"),
                                                                     :info =>getAsignacionInfo(r) }}
   
      #@asignacionsListaExterna = @asignacionsListaExterna.as_json                                                        
     @asignacions = @asignacions.reject{|a| !a.solicitudlab.nil? and a.solicitudlab.fechafin<Date.today }
     # ToDo:asignatura puede ser null en la base de datos, controlarlo...
    @asignacions = @asignacions.map { |r| {:id => r.id , :solicitudlab_id => r.solicitudlab_id, :room_id => r.laboratorio_id, :start => r.horaini, :end => r.horafin, :dia_id => r.dia_id, :title => getAsignacionTitulo(r), :info => getAsignacionInfo(r), :fechaIniSol => r.solicitudlab.fechaini.to_s, :fechaFinSol => r.solicitudlab.fechafin.to_s, :color => '#66FF33'} }    
    @asignacions = @asignacions.as_json 
    end

    @dias = Dia.where('en_uso = ?','t')
    #qué pasa si hay huecos? si hay horas intermedias que no se usan?
    #cómo ordenar las horas?qué es num?
    @horas = Horario.where('en_uso = ?','t').order("num")
    @horainicio = @horas.first.comienzo
    @horafin = @horas.last.fin

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @asignacions }
    end
  end

  def getLabInfo(lab)
   labEspecial = (lab.especial) == true  ? 'Sí' : 'No'
    labInfo = "Denominación: " + lab.ssoo + "%Num. puestos: " + lab.puestos.to_s + "%Lab especial?: " + labEspecial
    return labInfo
  end

  def actualizar
    @asignacionAntigua=getAsignaciondef(params[:asigna])
    #actualizar día de la semana, horaini, horafin y laboratorio
    Asignaciondef.update(params[:asigna], :horaini => params[:horaini], :horafin => params[:horafin], :dia_id => params[:dia_id],
                         :laboratorio_id => params[:lab_id], :temporal => params[:temporal])
    #session[:lista_externa].delete(params[:asigna])
    logger.debug session[:lista_externa]

    respond_to do |format|
      format.json {render json:@asignacionAntigua}
    end
    
  end
  
#aqui debe ir otra funcion tras captar el formulario anterior

  def graba
    @asignacion = Asignaciondef.new
    @asignacion.solicitudlab=Solicitudlab.new
    @asignacion.solicitudlab.asignatura=Asignatura.new
    @asignacion.solicitudlab.usuario_id = params[:usuario][:identificador].to_i

    if params[:asignaciondef][:generica] == "ReservaGenerica"
      @asignacion.generica = true
      titulacionId=Titulacion.where('abrevia = ?',"SD").first.id
      asignaturaId = Asignatura.where('abrevia_asig = ?', "Var. Sit.").first.id
      @asignacion.solicitudlab.asignatura.id = asignaturaId
      @asignacion.solicitudlab.asignatura_id = asignaturaId
      @asignacion.solicitudlab.asignatura.titulacion_id= titulacionId
      @asignacion.solicitudlab.asignatura.curso="optativa"
      @asignacion.solicitudlab.curso ="optativa"
    else
      @asignacion.generica = false
      asignaturaId = params[:asignatura][:id].to_i unless params[:asignatura].nil?
      @asignacion.solicitudlab.asignatura.id = asignaturaId
      @asignacion.solicitudlab.asignatura_id = asignaturaId
      @asignacion.solicitudlab.asignatura.titulacion_id=params[:titulacion][:titulacion_id]
      @asignacion.solicitudlab.asignatura.curso=params[:nivel].to_s 
      @asignacion.solicitudlab.curso =params[:nivel].to_s
    end
    @asignacion.solicitudlab.fechasol=Date.today
    @asignacion.solicitudlab.npuestos=Laboratorio.where("id= ?",params[:laboratorio][:laboratorio_id]).first.puestos
    @asignacion.solicitudlab.comentarios=params[:comentarios].to_s
    @asignacion.solicitudlab.asignado="D"
    @asignacion.solicitudlab.tipo="X"
    @asignacion.laboratorio_id=params[:laboratorio][:laboratorio_id].to_i
    
    @asignacion.solicitudlab.fechaini=params[:fechaini].to_date
    @asignacion.solicitudlab.fechafin=params[:fechafin].to_date
    getViewModel
    #@asignaturas=Asignatura.where('titulacion_id = ? and curso = ?',params[:titulacion][:titulacion_id],params[:nivel])
    respond_to do |format|
    if session[:tramos_horarios].solicitudes.empty? 
      flash.now[:notice]="No hay tramos horarios en su peticion"
      format.html { render :action => 'asigna_directa' }
    else
      if @asignacion.solicitudlab.save
        nuevo_id=@asignacion.solicitudlab.id                       
        @tramos=session[:tramos_horarios].solicitudes
        @tramos.each {|tramo| p=Peticionlab.new
                              p.solicitudlab_id=nuevo_id
                              p.diasemana=tramo.diasemana
                              p.horaini=tramo.horaini
                              p.horafin=tramo.horafin
                              p.save }
      # esto es lo quedebe cambiar, hay que ir a generar la asignacion nueva y hay que grabarla
      # y redirigir a la consulta de asignaciones  
      l=params[:laboratorio][:laboratorio_id].to_i
      peticiones=Peticionlab.where('solicitudlab_id = ?',@asignacion.solicitudlab.id).to_a
      peticiones.each {|p|  
                           hi=Horario.find_by_comienzo(p.horaini).id.to_i
                           hf=Horario.find_by_fin(p.horafin).id.to_i
                           dia_id=Dia.find_by_nombre(p.diasemana).id
                           for hora in hi..hf 
                               @asignacion=Asignaciondef.new(:solicitudlab_id=>@asignacion.solicitudlab.id,
                                                                 :laboratorio_id=>l,
                                                                 :peticionlab_id=>p.id,
                                                                 :dia_id=>dia_id,                      #aqui hay cambio
                                                                 :horaini=>Horario.find(hora).comienzo,
                                                                 :horafin=>Horario.find(hora).fin,
                                                                 :generica=>@asignacion.generica)
                               @asignacion.save
                           end
                       }
    # hasta aqui --------                   
        @asignacions = Asignaciondef.all
        format.html { redirect_to('/asignaciondefs/consulta') }
        format.xml  { render :xml => @solicitudlabs, :status => :created, :location => @solicitudlabs }
      else
        logger.debug @asignacion.solicitudlab.errors.full_messages

        format.html { render :action => "asigna_directa" }
        format.xml  { render :xml => @solicitudlabs.errors, :status => :unprocessable_entity }
      end
     end
    end
    
  end

  def borranormalasignada
    asignacion=Asignaciondef.find(params[:asigna])
    asignacion.delete
    #otrasasignaciones=Asignacion.where('solicitudlab_id = ?',asignacion.solicitudlab_id).to_a
    #otrasasignaciones.each {|o| o.delete }
    @asignacions=Asignaciondef.all
    respond_to do |format|
      format.js
    end
  end

  def borradirasignada
    asignacion=Asignaciondef.find(params[:asigna])
    #solicitudlab=Solicitudlab.find(asignacion.solicitudlab_id)
    #otrasasignaciones=Asignacion.where(:conditions=>['solicitudlab_id = ?',asignacion.solicitudlab_id]).to_a
    asignacion.delete
    #otrasasignaciones.each {|o| o.delete }
    #solicitudlab.delete
    @asignacions=Asignaciondef.all
    respond_to do |format|
      format.js
    end
  end

  def saveSolicitudLabModel(params)
    ##@solicitudlab.usuario_id = params[:usuario][:identificador].to_i
    if @solicitudlab.asignatura==nil
      @solicitudlab.asignatura=Asignatura.new
    end
    @solicitudlab.asignatura.id = params[:asignatura][:id].to_i unless params[:asignatura].nil?
    @solicitudlab.asignatura.titulacion_id=params[:titulacion][:titulacion_id]
    @solicitudlab.fechasol=Date.today
    @solicitudlab.asignatura.curso=params[:nivel].to_s
    @solicitudlab.fechaini=params[:fechaini].to_date
    @solicitudlab.fechafin=params[:fechafin].to_date
    @solicitudlab.comentarios=Iconv.conv('ascii//translit//ignore', 'utf-8', params[:comentarios])
    
    
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
    @dia= Date.today
    @tramos= []
    @usuarios=Usuario.order("apellidos").to_a
    @titulaciones=Titulacion.order("nombre").where.not(abrevia: "SD").to_a
    @laboratorios=Laboratorio.order("nombre_lab").to_a 
    asignatura = @asignacion.solicitudlab.asignatura
    @asignaturas=Asignatura.where('titulacion_id = ? and curso = ?',asignatura.titulacion_id,asignatura.curso)
    if(session[:tramos_horarios] != nil)
      @tramos=session[:tramos_horarios].solicitudes
    end
  end

end
