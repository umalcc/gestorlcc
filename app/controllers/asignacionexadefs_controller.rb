class AsignacionexadefsController < ApplicationController

 before_action :login_requerido
 before_action :admin?
 before_action :getViewModel, only: [:asigna_directa, :graba]



###### Métodos para gestionar el calendario con las asignaciones definitivas #######

def consulta
    ActiveRecord::Base.include_root_in_json = false

    @laboratorios=Laboratorio.all.select("id,nombre_lab, ssoo, puestos, especial").order("nombre_lab")
    @laboratorios=@laboratorios.map{|lab| {:id => lab.id,
                                          :nombre_lab => lab.nombre_lab,
                                          :ssoo => lab.ssoo,
                                          :puestos => lab.puestos,
                                          :especial => lab.especial,
                                          :title => getLabInfo(lab)}}
    @laboratorios = @laboratorios.as_json

    @asignacionexas=Asignacionlabexadef.where("temporal= ?", 'f').all
    @asignacionsexasListaExterna=Asignacionlabexadef.where("temporal= ?", 't').all


    if !@asignacionexasListaExterna.nil?

      @asignacionexasListaExterna = @asignacionexasListaExterna.reject{|a| !a.solicitudlabexa.nil? }

      @asignacionexasListaExterna = @asignacionexasListaExterna.map { |r| {:id => r.id,
                                                                     :asignatura => r.solicitudlabexa.asignatura.abrevia_asig.to_s,
                                                                     :title => r.solicitudlabexa.asignatura.abrevia_asig.to_s,
                                                                     :info =>getAsignacionInfo(r) }}
    end

    if @asignacionexas.size!=0
                                                          
     @asignacionexas = @asignacionexas.reject{|a| !a.solicitudlabexa.nil? }
     @asignacionexas = @asignacionexas.map { |r| {:id => r.id , :solicitudlab_id => r.solicitudlabexa_id, :room_id => r.laboratorio_id, :start => r.horaini, :end => r.horafin, :dia_id => r.dia, :title => r.solicitudlabexa.asignatura.abrevia_asig.to_s, :info => getAsignacionInfo(r), :fechaSol => r.solicitudlabexa.fechasol.to_s} }    
     @asignacionexas = @asignacionexas.as_json 
    end

    periodo=Periodo.where("tipo = ? and inicio > ?",'Examenes',Date.today).order('inicio').first 
    @inicioPeriodo = periodo.inicio
    @finPeriodo = periodo.fin
    @horas = Horario.where('en_uso = ?','t').order("num")
    @horainicio = @horas.first.comienzo
    @horafin = @horas.last.fin

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @asignacionexas }
    end
end

def getAsignaciondef(id)
    @asignacionexa=Asignacionlabexadef.where("id= ?",id).first
    titulo=@asignacionexa.solicitudlabexa.asignatura.abrevia_asig.to_s
    info=getAsignacionInfo(@asignacionexa)
    @asignacionexa=@asignacionexa.as_json

    @asignacionexa[:title]=titulo
    @asignacionexa[:info]=info
   return @asignacionexa
end


def getAsignacionInfo(asignacion)
      
    comentarios=asignacion.solicitudlabexa.comentarios
    comentarios=comentarios.blank? ?  " ": comentarios.gsub(/[\r\n]+/, "%")

    info = "Puestos: " + asignacion.solicitudlabexa.npuestos.to_s 
    #Añadir fecha de la solicitud, horaini y horafin pero sólo si la asignacion es temporal
    if asignacion.temporal == true
       info = info + "%Horario: " + asignacion.dia.nombre + " " + asignacion.horaini + " - " + asignacion.horafin
    end

    #Añadir información sobre la solicitud que genera la asignación
    horaini = asignacion.solicitudlabexa.horaini
    horafin = asignacion.solicitudlabexa.horafin
    diasemana = asignacion.solicitudlabexa.diasemana
    ini = Time.parse(horaini)
    fin = Time.parse(horafin)
    totalHoras = ((fin - ini)/1.hour).round
    info = info + "%Total horas: " + totalHoras.to_s
    
    info= info + "%Profesor: " + asignacion.solicitudlabexa.usuario.nombre.to_s
    info= info +" "+  asignacion.solicitudlabexa.usuario.apellidos.to_s
    info= info + "%Soft: " + comentarios
    curso=asignacion.solicitudlabexa.curso == "0" ? "optativa" : asignacion.solicitudlabexa.curso
    asigInfo="Asig: " +asignacion.solicitudlabexa.asignatura.titulacion.abrevia+"(" +asignacion.solicitudlabexa.asignatura.abrevia_asig.to_s + ") %Curso: " + curso + "%"
    info = asigInfo + info
   
    fechasol = "Fecha sol.: " + asignacion.solicitudlabexa.fechasol.strftime("%d-%m-%Y")
    horarioinicial = "Horario inicial: " + diasemana + " " + horaini + " - " + horafin
    info = fechasol + "%" + horarioinicial + "%" + info 

    return info   
end

def getLabInfo(lab)
    labEspecial = (lab.especial) == true  ? 'Sí' : 'No'
    labInfo = "Denominación: " + lab.ssoo + "%Num. puestos: " + lab.puestos.to_s + "%Lab especial?: " + labEspecial
    return labInfo
end

def anadirListaExterna
  @asignacionexa = Asignacionlabexadef.find(params[:id])
  if(params[:copiar]=="true")
    @asignacionexa = @asignacionexa.dup
  end
  @asignacionexa.temporal=true
  @asignacionexa.save!
  respond_to do |format|
    format.json {render json:@asignacionexa}
  end
end

def pegar
  ActiveRecord::Base.include_root_in_json = false
  @asignacionexa=Asignacionlabexadef.find(params[:id])
  @asignacionexa.dia_id=params[:dia_id]
  @asignacionexa.temporal=false
  info=getAsignacionInfo(@asignacionexa)
  titulo= @asignacionexa.solicitudlabexa.asignatura.abrevia_asig.to_s
  @asignacionexa.save
  @asignacionexa=@asignacion.as_json
  @asignacionexa[:titulo]=titulo
  @asignacionexa[:info]=info
   
  respond_to do |format|
    format.json {render json:@asignacionexa}
  end
end

def actualizar
    @asignacionexaAntigua=getAsignaciondef(params[:asigna])
    #actualizar día de la semana, horaini, horafin y laboratorio
    Asignacionlabexadef.update(params[:asigna], :horaini => params[:horaini], :horafin => params[:horafin], :dia_id => params[:dia_id],
                         :laboratorio_id => params[:lab_id], :temporal => params[:temporal])

    respond_to do |format|
      format.json {render json:@asignacionexaAntigua}
    end    
end

def destroy
  @asignacionexa = Asignacionlabexadef.find(params[:id])
  @asignacionexa.destroy

  respond_to do |format|
    format.html { render :nothing => true , :status => 200 }
    format.xml  { head :ok }
  end
end
  
def borranormalasignada
    asignacion=Asignacionlabexadef.find(params[:asigna])
    asignacion.delete
    
    @asignacionexas=Asignacionlabexadef.all
    respond_to do |format|
      format.js
    end
end

def borradirasignada
    asignacion=Asignacionlabexadef.find(params[:asigna])
    asignacion.delete
    
    @asignacionexas=Asignacionlabexadef.all
    respond_to do |format|
      format.js
    end
end
  

######### Métodos para realizar asignaciones directas #########

def asigna_directa

    @asignacionexa = Asignacionlabexadef.new
    @asignacionexa.solicitudlabexa = Solicitudlabexa.new
    @asignacionexa.solicitudlabexa.fechasol= Date.today
    @asignaturas = Asignatura.where('titulacion_id = ? and curso = ?',@titulaciones.first,0).to_a
    @asignacionexa.solicitudlabexa.asignatura = @asignaturas.first
    
    periodoact=Periodo.where("activo = ? AND tipo = ?","t","Examenes").first
    if (periodoact.nil?)
        inicio=Date.today
    else
        iniperiodoact=periodoact.inicio
        inicio=iniperiodoact
    end
    @asignacionexa.solicitudlabexa.fecha = inicio
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @asignacionexa.solicitudlabexa }
    end
end

#Crea una nueva solicitud y las asignaciones asociadas
def graba

    @asignacionexa = Asignacionlabexadef.new
    @asignacionexa.solicitudlabexa = Solicitudlabexa.new
    @asignacionexa.solicitudlabexa.asignatura=Asignatura.new
    @asignacionexa.solicitudlabexa.usuario_id = params[:usuario][:identificador].to_i
    asignaturaId = params[:asignatura][:id].to_i unless params[:asignatura].nil?
    @asignacionexa.solicitudlabexa.asignatura_id = asignaturaId
    @asignacionexa.solicitudlabexa.asignatura.id = asignaturaId
    @asignacionexa.solicitudlabexa.asignatura.titulacion_id=params[:titulacion][:titulacion_id] unless params[:titulacion].nil?
    @asignacionexa.solicitudlabexa.asignatura.curso=params[:nivel] 
    @asignacionexa.solicitudlabexa.curso =params[:nivel] == 0 ? "optativa" : params[:nivel].to_s
    @asignacionexa.solicitudlabexa.npuestos=Laboratorio.where("id= ?",params[:laboratorio_id][:nombre_lab]).first.puestos
    @asignacionexa.solicitudlabexa.fechasol=Date.today
    @asignacionexa.solicitudlabexa.fecha=params[:fecha].to_date
    @asignacionexa.solicitudlabexa.comentarios=params[:comentarios].to_s
    @asignacionexa.solicitudlabexa.horaini=params[:horaini][:comienzo]
    @asignacionexa.solicitudlabexa.horafin=params[:horafin][:fin]
    @asignacionexa.solicitudlabexa.tipo="X"
    @asignacionexa.solicitudlabexa.asignado="D"
    @labId=params[:laboratorio_id][:nombre_lab].to_i
    
    @asignaturas = Asignatura.where('titulacion_id = ? and curso = ?',@asignacionexa.solicitudlabexa.asignatura.titulacion_id,params[:nivel]).to_a

    respond_to do |format|
      if @asignacionexa.solicitudlabexa.save
          
        hi=Horasexa.find_by_comienzo(params[:horaini][:comienzo]).id.to_i
        hf=Horasexa.find_by_fin(params[:horafin][:fin]).id.to_i
        for hora in hi..hf 
           @asignacionexa=Asignacionlabexadef.new(:solicitudlabexa_id=>@asignacionexa.solicitudlabexa.id,
                                              :laboratorio_id=>@labId,
                                              :dia=>@asignacionexa.solicitudlabexa.fecha,                   
                                              :horaini=>Horasexa.find(hora).comienzo,
                                              :horafin=>Horasexa.find(hora).fin)
                          @asignacionexa.save
        end
                                          
        @asignacionexas = Asignacionlabexadef.all
        format.html { redirect_to('/asignacionexadefs/consulta') }
        format.xml  { render :xml => @solicitudlabs, :status => :created, :location => @solicitudlabs }
      else
         
        @asignacionexa.solicitudlabexa.errors.full_messages.each do |message|
             flash.now[:notice]=message   
        end

        format.html { render :action => "asigna_directa" }
        format.xml  { render :xml => @solicitudlabs.errors, :status => :unprocessable_entity }
      end
     end
  end

def getViewModel
    @dia= Date.today
    @tramos= []
    @usuarios=Usuario.order("apellidos").to_a
    @titulaciones=Titulacion.order("nombre").where.not(abrevia: "SD").to_a
    @laboratorios=Laboratorio.order("nombre_lab").to_a 
end

end