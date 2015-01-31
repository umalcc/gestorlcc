class AsignacionsController < ApplicationController
  # GET /asignacions
  # GET /asignacions.xml

 before_action :login_requerido
 before_action :admin?

  
  def asignar
    @admision=Periodo.where("admision = ? and tipo= ?","t","Lectivo").to_a
    @totalprov=Asignacion.all.size

  end

  def asignar_continuar
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
       @asignacions=Asignacion.where("temporal= ?", 'f').all
    #end

    #if(session[:lista_externa] != nil)
      #@asignacionsListaExterna=Asignaciondef.where("id in (?)",session[:lista_externa]).all#.map{|r|{:id => r.id,:title => r.solicitudlab.asignatura.abrevia_asig.to_s}}
      @asignacionsListaExterna=Asignacion.where("temporal= ?", 't').all
    #end

    if @asignacions.size!=0
      @asignacionsListaExterna = @asignacionsListaExterna.map { |r| {:id => r.id,
                                                                     :asignatura => r.solicitudlab.asignatura.abrevia_asig.to_s,
                                                                     :title => ((r.generica.to_s == 'null' || r.generica.to_s == 'false')? r.solicitudlab.asignatura.abrevia_asig.to_s : "RG"),
                                                                     :info =>getAsignacionInfo(r) }}
      #@asignacionsListaExterna = @asignacionsListaExterna.as_json                                                        
     #@asignacions = @asignacions.reject{|a| !a.solicitudlab.nil? and a.solicitudlab.fechafin<Date.today}
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
      format.js
      format.html # index.html.erb
      format.xml { render :xml => @asignacions }
    end
  end

def anadirListaExterna
  #(session[:lista_externa] ||= []) << params[:id]
  @asignacion = Asignacion.find(params[:id])
  if(params[:copiar]=="true")
    #@asignacion = Asignacion.new(@asignacion.attributes)
    @asignacion = @asignacion.dup
  end
  @asignacion.temporal=true
  @asignacion.save!
  respond_to do |format|
    format.json {render json:@asignacion}
  end
end

# SI HIDDEN FIEL ES PRINCIPIO, SE LEEN SOLICITUDLAB, SINO DE ASIGNACIONPROV
  def asignar_iniciar
    solicitudes=Solicitudlab.where("fechafin >= ? and asignado <> ?",Date.today,"D").to_a
    @adjudicado=Periodo.where("activo = ? and tipo= ?","t","Lectivo").to_a

    if solicitudes.size!=0 
     
     @solicitudlabs=solicitudes

  # ordenacion de solicitudes segun metodo de ascenso de burbujas por tres criterios:
  # 1- por coeficiente de experimentabilidad, inicialmente el mismo en todas
  # 2- por numero de horas totales
  # 3- por tipo de solicitud (1- T:todo el periodo, 2- I:intervalo, 3- C:dias concretos)
  # 4- por numero de puestos descendentemente
  # 5- por numero de tramos horarios de la peticion   

     for i in 0..@solicitudlabs.size-1
       for j in 0..@solicitudlabs.size-2-i
         if @solicitudlabs[j].asignatura.coeficiente_exp<@solicitudlabs[j+1].asignatura.coeficiente_exp
           @solicitudlabs[j],@solicitudlabs[j+1]=@solicitudlabs[j+1],@solicitudlabs[j]
         end
       end
     end

     for i in 0..@solicitudlabs.size-1
       for j in 0..@solicitudlabs.size-2-i
         if @solicitudlabs[j].asignatura.coeficiente_exp==@solicitudlabs[j+1].asignatura.coeficiente_exp and
           horas(@solicitudlabs[j])<horas(@solicitudlabs[j+1])
             @solicitudlabs[j],@solicitudlabs[j+1]=@solicitudlabs[j+1],@solicitudlabs[j]
         end
       end
     end


      for i in 0..@solicitudlabs.size-1
       for j in 0..@solicitudlabs.size-2-i
         if @solicitudlabs[j].asignatura.coeficiente_exp==@solicitudlabs[j+1].asignatura.coeficiente_exp and
            horas(@solicitudlabs[j])==horas(@solicitudlabs[j+1]) and
            @solicitudlabs[j].tipo<@solicitudlabs[j+1].tipo
           @solicitudlabs[j],@solicitudlabs[j+1]=@solicitudlabs[j+1],@solicitudlabs[j]
         end
       end
     end

      for i in 0..@solicitudlabs.size-1
       for j in 0..@solicitudlabs.size-2-i
         if @solicitudlabs[j].asignatura.coeficiente_exp==@solicitudlabs[j+1].asignatura.coeficiente_exp and
            horas(@solicitudlabs[j])==horas(@solicitudlabs[j+1]) and
            @solicitudlabs[j].tipo==@solicitudlabs[j+1].tipo and
            @solicitudlabs[j].npuestos<@solicitudlabs[j+1].npuestos
           @solicitudlabs[j],@solicitudlabs[j+1]=@solicitudlabs[j+1],@solicitudlabs[j]
         end
       end
     end

     for i in 0..@solicitudlabs.size-1
       for j in 0..@solicitudlabs.size-2-i
         if @solicitudlabs[j].asignatura.coeficiente_exp==@solicitudlabs[j+1].asignatura.coeficiente_exp and
            horas(@solicitudlabs[j])==horas(@solicitudlabs[j+1]) and
            @solicitudlabs[j].tipo==@solicitudlabs[j+1].tipo and
            @solicitudlabs[j].npuestos==@solicitudlabs[j+1].npuestos and
            @solicitudlabs[j].peticionlab.size<@solicitudlabs[j+1].peticionlab.size
           @solicitudlabs[j],@solicitudlabs[j+1]=@solicitudlabs[j+1],@solicitudlabs[j]
         end
       end
     end

     # los componentes ordenados secuencialmente, se cargan en un array 3d de horas x labs x diasemana


     cuadrante=Array3d.new
     @asignacions=[]
   
    
     @solicitudlabs.each { |sol|     #por cada una de las @solicitudlabs, buscamos los lab que tienen ese n. de puestos
       sol.peticionlab.each { |pet|     #por cada peticion de tramo de cada solicitud
        
         # tomamos el dia, la hora de inicio y la de fin
         dia=Dia.find_by_nombre(pet.diasemana).id
         hi=Horario.find_by_comienzo(pet.horaini).id.to_i
         hf=Horario.find_by_fin(pet.horafin).id.to_i
         for hora in hi..hf     #   for cada hora del tramo, una asignacion
          if sol.npuestos<Laboratorio::DOS_LAB 
           
            @todoslab=Laboratorio.order("nombre_lab desc").where("puestos = ?",sol.npuestos).to_a
            # en principio el laboratorio asignado es ninguno y buscamos uno libre de ese tamaño
            lab=nil
          if sol.preferencias=="" or sol.preferencias==nil
            @todoslab.each {|laboratorio|  
                                if sol.npuestos<=laboratorio.puestos and cuadrante[hora, laboratorio.id,dia].nil?           
                                  lab=[laboratorio.id]  # si el laboratorio está libre y cabe el num de puestos 
                                end       
                          }
               # si no habia ninguno libre, colisionamos en el primero de los lab de esa capacidad  
          else # el usuario manifesto una preferencia favorable o desfavorable
             preferencias=sol.preferencias.split(";")        # troceo la cadena de preferencias por el ;  
             preferencias.each { |p| trestramos=p.split("-") # e itero sobre cada trozo y vuelvo a trocear
                                 l=Laboratorio.find_by_nombre_lab(trestramos[0]).id    #  en 3.1.4-Apple-no por el guion
                                 if trestramos[2]=="si"      # si ha dicho que si, ahí lo coloco
                                   lab=[l]
                                 else
                                   @todoslab=@todoslab.reject{|n| n.id==l }
                                   @todoslab.each {|laboratorio|  
                                   if sol.npuestos<=laboratorio.puestos and cuadrante[hora, laboratorio.id,dia].nil?           
                                       lab=[laboratorio.id]  # si el laboratorio está libre y cabe el num de puestos 
                                   end       
                                }
                                 end 
                               }
             # si ha dicho que no, elimino de la lista de laboratorios ese laboratorio
           end
           if lab.nil?
             lab=[@todoslab.first.id]
           end
           
          else 
           uno=Laboratorio.find_by_nombre_lab("3.1.1").id
           dos=Laboratorio.find_by_nombre_lab("3.1.2").id
           tres=Laboratorio.find_by_nombre_lab("3.1.3").id
           cinco=Laboratorio.find_by_nombre_lab("3.1.5").id
           ocho=Laboratorio.find_by_nombre_lab("3.1.8").id 
           nueve=Laboratorio.find_by_nombre_lab("3.1.9").id
           if sol.npuestos==Laboratorio::DOS_LAB
               # se asignan "a mano los lab 1 y 2 o bien el 8 y el 9 que son contiguos
                
               if cuadrante[hora,uno,dia]==nil and cuadrante[hora,dos,dia]==nil
                lab=[uno,dos]
               else 
                lab=[ocho,nueve]
                
               end #if 
           else
             lab=[uno,dos,ocho,nueve]
             if sol.npuestos==150
                 lab+=[tres,cinco]
               
             end # if == 150
           end # if ==59 DOSLAB
          end # if <59 DOSLAB
           # siempre habra al menos una asignacion para todos
           # CONSTRUIR UNA LISTA Y UNA ITERACION  SOBRE ELLA DE ASIGNACIONES
           lab.each {|l| @asignacions<<asignacion=Asignacion.new(:solicitudlab_id=>sol.id,
                                                                 :laboratorio_id=>l,
                                                                 :peticionlab_id=>pet.id,
                                                                 :dia_id=>dia,                      #aqui hay cambio
                                                                 :horaini=>Horario.find(hora).comienzo,
                                                                 :horafin=>Horario.find(hora).fin,
                                                                 :mov_dia=>"",
                                                                 :mov_hora=>"")
                    
                         if cuadrante[hora,l,dia].nil?
                            cuadrante[hora,l,dia]=[asignacion]
                         else
                            cuadrante[hora,l,dia]<<[asignacion]
                         end  
                     }       
          end # for horas
         
         
      } # for pet
     }  # for sol
     
    # finalmente, se vuelcan todas las asignaciones sobre el archivo persistente
    # eliminando primero los registros que hubiera de una asignacion anterior
    # OJOOOOOO VER QUE HACER CUANDO SE ACTIVEN NUEVOS PERIODOS

   
        Asignacion.all.each { |a| a.destroy }

        @asignacions.each { |a| nueva_asig=Asignacion.new
                            nueva_asig=a
                            a.solicitudlab.asignado="P"
                            a.solicitudlab.save
                            nueva_asig.save
                      }
    else
      @asignacions=[]
    end
	
    respond_to do |format|
        format.js
    end
    
  end
 
  def mover
    @asignacion=Asignacion.find(params[:id])
    inicial_dia=@asignacion.peticionlab.diasemana
    inicial_hora_ini=@asignacion.peticionlab.horaini
    inicial_hora_fin=@asignacion.peticionlab.horafin
    laboratorio_id=Laboratorio.find_by_nombre_lab(params[:nombre_lab]).id
    dia_id=Dia.find_by_nombre(params[:nombre]).id
    horafin=Horario.find_by_comienzo(params[:comienzo]).fin
    mov_dia=""
    if inicial_dia != params[:nombre]
      mov_dia=" cambio de "+inicial_dia+" a "+params[:nombre]+"; "
    end
    mov_hora="" 
    if inicial_hora_ini != params[:comienzo]
      mov_hora=" cambio de "+inicial_hora_ini+"-"+inicial_hora_fin+" a "+params[:comienzo]+"-"+horafin+"; "
    end
    
     if @asignacion.update_attributes(:laboratorio_id=>laboratorio_id,
                                      :dia_id=> dia_id,
                                      :horaini=> params[:comienzo],
                                      :horafin=> horafin,
                                      :mov_dia=> mov_dia,
                                      :mov_hora=> mov_hora ) 
        
        @asignacions=Asignacion.all
        respond_to do |format|
          format.js
        end
     end
    
  end  

   def getAsignacion(id)
    @asignacion=Asignacion.where("id= ?",id).first
    titulo=getAsignacionTitulo(@asignacion)
    info=getAsignacionInfo(@asignacion)
    @asignacion=@asignacion.as_json

    @asignacion[:title]=titulo
    @asignacion[:info]=info
    #respond_to do |format|
    #  format.json {render json:@asignacion}
    #end
    return @asignacion
  end

def destroy
    @asignacion = Asignacion.find(params[:id])
    @asignacion.destroy

    respond_to do |format|
      format.html { render :nothing => true , :status => 200 }
      format.xml  { head :ok }
    end
  end

  def revisar
    @asignaciones=Asignacion.all
    cuadro=Array3d.new


    for asignacion in @asignaciones
       dia=Dia.find(asignacion.dia_id).id #el dia no es el de asignacion.peticionlab.diasemana, puede haber cambiado
       hora=Horario.find_by_comienzo(asignacion.horaini).id
       if cuadro[hora,asignacion.laboratorio_id,dia].nil?
          cuadro[hora,asignacion.laboratorio_id,dia]=1
       else
          cuadro[hora,asignacion.laboratorio_id,dia]+=1
       end
    end

    horas=Horario.all.map{|h| h.id}
    laboratorios=Laboratorio.all.map{|l| l.id}
    dias=Dia.all.map{|d| d.id}

    @colision=0
    for hora in horas
      for lab in laboratorios
         for dia in dias
           if !cuadro[hora,lab,dia].nil?
             @colision+=1 if cuadro[hora,lab,dia]>1
           end    
            
         end
      end
    end
    respond_to do |format|
      format.js
    end
  end
  
def pegar
  ActiveRecord::Base.include_root_in_json = false
  @asignacion=Asignacion.find(params[:id])
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
      curso=asignacion.solicitudlab.curso== "0" ? "optativa" : asignacion.solicitudlab.curso
       asigInfo="Asig: " +asignacion.solicitudlab.asignatura.titulacion.abrevia+"(" +asignacion.solicitudlab.asignatura.abrevia_asig.to_s + ") %Curso: " + curso + "%"
       info = asigInfo + info
    else
       info = "Reserva genérica%"+info
    end
    return info   
  end


  def getLabInfo(lab)
    logger.debug "AAAAAAAAAAAAAA"+lab.especial.to_s
   labEspecial = (lab.especial) == true  ? 'Sí' : 'No'
    labInfo = "Denominación: " + lab.ssoo + "%Num. puestos: " + lab.puestos.to_s + "%Lab especial?: " + labEspecial
    return labInfo
  end

  def actualizar
    @asignacionAntigua=getAsignacion(params[:asigna])
    #actualizar día de la semana, horaini, horafin y laboratorio
    Asignacion.update(params[:asigna], :horaini => params[:horaini], :horafin => params[:horafin], :dia_id => params[:dia_id],
                         :laboratorio_id => params[:lab_id], :temporal => params[:temporal])
    #session[:lista_externa].delete(params[:asigna])
    #logger.debug session[:lista_externa]

    respond_to do |format|
      format.json {render json:@asignacionAntigua}
    end
  end

  def asigna_directa
    @asignacion = Asignacion.new
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
    @asignacion = Asignacion.new
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
      flash[:notice]="No hay tramos horarios en su peticion"
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
        @asignacions = Asignacion.all
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



  def borranormal
    asignacion=Asignacion.find(params[:asigna])
    asignacion.delete
    # otrasasignaciones=Asignacion.where(:conditions=>['solicitudlab_id = ?',asignacion.solicitudlab_id]).to_a
    # otrasasignaciones.each {|o| o.delete }
    @asignacions=Asignacion.all
    respond_to do |format|
      format.js
    end
  end


  def borradir
    asignacion=Asignacion.find(params[:asigna])
    #solicitudlab=Solicitudlab.find(asignacion.solicitudlab_id)
    #otrasasignaciones=Asignacion.where(:conditions=>['solicitudlab_id = ?',asignacion.solicitudlab_id]).to_a
    asignacion.delete
    #otrasasignaciones.each {|o| o.delete }
    #solicitudlab.delete
    @asignacions=Asignacion.all
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
    @titulaciones=Titulacion.order("id").where.not(abrevia: "SD").to_a
    @laboratorios=Laboratorio.order("nombre_lab").to_a 
    asignatura = @asignacion.solicitudlab.asignatura
    @asignaturas=Asignatura.where('titulacion_id = ? and curso = ?',asignatura.titulacion_id,asignatura.curso)
    if(session[:tramos_horarios] != nil)
      @tramos=session[:tramos_horarios].solicitudes
    end
  end

end
