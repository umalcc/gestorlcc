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

    @laboratorios=Laboratorio.all.select("id,nombre_lab, ssoo, puestos, especial").order("nombre_lab")
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

    if @asignacionsListaExterna.size !=0
      @asignacionsListaExterna = @asignacionsListaExterna.reject{|a| !a.solicitudlab.nil? and a.solicitudlab.fechafin<Date.today}
      @asignacionsListaExterna = @asignacionsListaExterna.map { |r| {:id => r.id,
                                                                     :asignatura => r.solicitudlab.asignatura.abrevia_asig.to_s,
                                                                     :title => ((r.generica.to_s == 'null' || r.generica.to_s == 'false')? r.solicitudlab.asignatura.abrevia_asig.to_s : "RG"),
                                                                     :info =>getAsignacionInfo(r) }}
    end

    if @asignacions.size!=0                                                     
       @asignacions = @asignacions.reject{|a| !a.solicitudlab.nil? and a.solicitudlab.fechafin<Date.today}
       @asignacions = @asignacions.map { |r| {:id => r.id , :solicitudlab_id => r.solicitudlab_id, :room_id => r.laboratorio_id, :lab_nombre => r.laboratorio.nombre_lab, :start => r.horaini, :end => r.horafin, :dia_id => r.dia_id, :dia_nombre => r.dia.nombre, :title => getAsignacionTitulo(r), :emailProfesor => r.solicitudlab.usuario.email,:info => getAsignacionInfo(r), :fechaIniSol => r.solicitudlab.fechaini.to_s, :fechaFinSol => r.solicitudlab.fechafin.to_s} }    
    end

    @asignacions = @asignacions.as_json 
    @dias = Dia.where('en_uso = ?','t')
    @horas = Horario.where('en_uso = ?','t').order("num")
    @horainicio = @horas.first.comienzo
    @horafin = @horas.last.fin

    respond_to do |format|
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
    @todoslaboratorios = Laboratorio.order("nombre_lab desc").to_a
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
           
         # else
           #uno=Laboratorio.find_by_nombre_lab("3.1.1").id
           #dos=Laboratorio.find_by_nombre_lab("3.1.2").id
           #tres=Laboratorio.find_by_nombre_lab("3.1.3").id
           #cinco=Laboratorio.find_by_nombre_lab("3.1.5").id
           #ocho=Laboratorio.find_by_nombre_lab("3.1.8").id 
           #nueve=Laboratorio.find_by_nombre_lab("3.1.9").id
           #if sol.npuestos==Laboratorio::DOS_LAB
               # se asignan "a mano los lab 1 y 2 o bien el 8 y el 9 que son contiguos
                
              # if cuadrante[hora,uno,dia]==nil and cuadrante[hora,dos,dia]==nil
             #   lab=[uno,dos]
           #    else 
          #      lab=[ocho,nueve]
                
          #     end #if 
         #  else
         #    lab=[uno,dos,ocho,nueve]
         #    if sol.npuestos==150
         #        lab+=[tres,cinco]
               
         #    end # if == 150
         #  end # if ==59 DOSLAB
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


  # borrar las antiguas asignaciones definitivas, y sus solicitudes asociadas
  # leer asignaciones provisionales
  # grabarlas en definitivas
  # eliminar las provisionales
  def grabar_asignacion 
      
    statusMessage=""
    statusCode=200

    @asignacions=Asignacion.select{|a| a.temporal == false} # sólo deben grabarse aquellas con temporal = false
    if @asignacions.size == 0
       statusMessage = "No hay asignaciones para grabar"
       statusCode = 500
    else

        success = true
        Asignaciondef.transaction do
            @asignaciondefs=Asignaciondef.all
            if @asignaciondefs.size!=0
              solicitudes=@asignaciondefs.map{|a| a.solicitudlab}.uniq{|s| s.id}
              solicitudes.each{|s|  peticiones=Peticionlab.where("solicitudlab_id = ?",s.id).to_a # busco todos las peticiones que tiene la solicitud
                                    peticiones.each {|petición| success = petición.destroy && success}
                                    success = s.destroy && success}

              @asignaciondefs.each{|a| success = a.destroy && success}
            end

            @asignacions.each { |a| asig_def=Asignaciondef.new( :solicitudlab_id=>a.solicitudlab_id,
                                                                :peticionlab_id=>a.peticionlab_id,
                                                                :laboratorio_id=>a.laboratorio_id,
                                                                :horaini=>a.horaini,
                                                                :horafin=>a.horafin,
                                                                :dia_id=>a.dia_id,
                                                                :mov_dia=>a.mov_dia,
                                                                :mov_hora=>a.mov_hora)
                                    
                                    success = asig_def.save && success
                                    logger.debug asig_def.save
                                    sol=a.solicitudlab
                                    sol.asignado="D"
                                    success = sol.save && success
                                    succes = a.destroy && success
                              }
      end

      if success
          statusMessage = "Se han grabado las asignaciones.\nA partir de ahora se podrá activar el período correspondiente"
          statusCode = 200
      else
          statusMessage = "La grabación de asignaciones ha fallado"
          statusCode = 500
      end

    end

    respond_to do |format| 
      format.json {render :json => {:msg => statusMessage},:status => statusCode}  
    end

  end
 
  def mover

    @asignacion=Asignacion.find(params[:id])
    inicial_dia=@asignacion.peticionlab.diasemana
    inicial_dia_id=@asignacion.dia_id

    inicial_hora_ini=@asignacion.peticionlab.horaini
    inicial_hora_fin=@asignacion.peticionlab.horafin
    peticion_id = @asignacion.peticionlab.id
    inicial_laboratorio=@asignacion.laboratorio
    laboratorio_id=Laboratorio.find_by_nombre_lab(params[:nombre_lab]).id
    dia_id=Dia.find_by_nombre(params[:nombre]).id
    horafin=Horario.find_by_comienzo(params[:comienzo]).fin
    asignaciones=Asignacion.where('solicitudlab_id = ? and peticionlab_id = ?',@asignacion.solicitudlab,peticion_id).to_a

    #cambio de laboratorio
    if inicial_laboratorio.id!=laboratorio_id
      logger.debug("LABORATOROOO distinto"+inicial_laboratorio.id.to_s+laboratorio_id.to_s)
      for asignacion in asignaciones # todas las que haya que modificar
        asignacion.update_attributes(:laboratorio_id=>laboratorio_id) 
      end 
    end

    #buscar todas las asignaciones de una solicitud de laboratorio concreta
    #asignaciones=Asignacion.where('solicitudlab_id = ? and laboratorio_id = ?',@asignacion.solicitudlab,inicial_laboratorio).to_a

    #cambio de día de la semana
    mov_dia=""
    if inicial_dia != dia_id
            logger.debug("Dia distinto"+ inicial_dia.to_s+ params[:nombre])
         mov_dia=" cambio de "+inicial_dia+" a "+params[:nombre]+"; "
      for asignacion in asignaciones # todas las que haya que modificar
        asignacion.update_attributes(:dia_id=> dia_id, :mov_dia=> mov_dia) 
      end  
    end

    #cambio de hora inicial
    mov_hora="" 
    logger.debug("Hora distinto"+ inicial_hora_ini.to_s+ params[:comienzo])

      mov_hora=" cambio de "+inicial_hora_ini+"-"+inicial_hora_fin+" a "+params[:comienzo]+"-"+horafin+"; "
      diferencia=Horario.find_by_comienzo(inicial_hora_ini).num-Horario.find_by_comienzo(params[:comienzo]).num
      count =0
      for asignacion in asignaciones # todas las que haya que modificar
        asignacion.update_attributes(:horaini=> Horario.find_by_num(Horario.find_by_comienzo(asignacion.peticionlab.horaini).num+count-diferencia).comienzo,
                                     :horafin=> Horario.find_by_num(Horario.find_by_comienzo(asignacion.peticionlab.horaini).num+count-diferencia).fin,
                                     :mov_hora=> mov_hora)
        logger.debug "Diferencia " + diferencia.to_s
          count = count +1
      end
      
    @asignacions=Asignacion.all
        respond_to do |format|
          format.js
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
   
   info=" "
   
   #Obtener la ocupación del laboratorio para dicho evento
    ocupacion = " "                           
    if (asignacion.solicitudlab.tipo.to_s == "T")
          ocupacion = "Todo el período"
    elsif (asignacion.solicitudlab.tipo.to_s == "I")
          ocupacion = "Del " + asignacion.solicitudlab.fechaini.strftime("%d-%m-%Y") + " al " + asignacion.solicitudlab.fechafin.strftime("%d-%m-%Y")
    elsif (asignacion.solicitudlab.tipo.to_s == "X")
          ocupacion = "Asignación directa - Del " + asignacion.solicitudlab.fechaini.strftime("%d-%m-%Y") + " al " + asignacion.solicitudlab.fechafin.strftime("%d-%m-%Y")
    else
          ocupacion = "Puntual-" + asignacion.solicitudlab.fechaini.strftime("%d-%m-%Y")
    end
    
    comentarios=asignacion.solicitudlab.comentarios
    comentarios=comentarios.blank? ?  " ": comentarios.gsub(/[\r\n]+/, "%")

    info = "Puestos: " + asignacion.solicitudlab.npuestos.to_s 
    #Añadir fecha de la solicitud, horaini y horafin pero sólo si la asignacion es temporal
    if asignacion.temporal == true
       info = info + "%Horario: " + asignacion.dia.nombre + " " + asignacion.horaini + " - " + asignacion.horafin
    end

    #Añadir información sobre la solicitud que genera la asignación
    horaini = asignacion.peticionlab.horaini
    horafin = asignacion.peticionlab.horafin
    diasemana = asignacion.peticionlab.diasemana
    ini = Time.parse(asignacion.peticionlab.horaini)
    fin = Time.parse(asignacion.peticionlab.horafin)
    totalHoras = ((fin - ini)/1.hour).round
    info = info + "%Total horas: " + totalHoras.to_s
    
    info= info + "%Profesor: " + asignacion.solicitudlab.usuario.nombre.to_s
    info= info +" "+  asignacion.solicitudlab.usuario.apellidos.to_s
    info= info + "%Soft: " + comentarios
    info= info + "%Ocupación: " + ocupacion

    #Si la reserva no es genérica, necesitamos añadir la información de la asignatura
    #|| asignacion.generica.to_s == 'false'
    if asignacion.generica.nil? || asignacion.generica == false
       curso=asignacion.solicitudlab.curso== "0" ? "optativa" : asignacion.solicitudlab.curso
       asigInfo="Asig: " +asignacion.solicitudlab.asignatura.titulacion.abrevia+"(" +asignacion.solicitudlab.asignatura.abrevia_asig + ") %Curso: " + curso + "%"
       info = asigInfo + info
    else
       info = "Reserva genérica%"+info
    end

    fechasol = "Fecha sol.: " + asignacion.solicitudlab.fechasol.strftime("%d-%m-%Y")
    horarioinicial = "Horario inicial: " + diasemana + " " + horaini + " - " + horafin
    info = fechasol + "%" + horarioinicial + "%" + info 

    return info   
  end


  def getLabInfo(lab)
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
    @solicitudlab.asignatura.titulacion_id=params[:titulacion][:titulacion_id] unless params[:titulacion].nil?
    @solicitudlab.fechasol=Date.today
    @solicitudlab.asignatura.curso=params[:nivel]
    @solicitudlab.curso = params[:nivel] == 0 ? "optativa" : params[:nivel].to_s
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
