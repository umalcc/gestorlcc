class AsignacionsController < ApplicationController
  # GET /asignacions
  # GET /asignacions.xml

 before_filter :login_requerido
 before_filter :admin?



  # DELETE /asignacions/1
  # DELETE /asignacions/1.xml
  def destroy
    @asignacion = Asignacion.find(params[:id])
    @asignacion.destroy

    respond_to do |format|
      format.html { redirect_to(asignacions_url) }
      format.xml  { head :ok }
    end
  end


  def asignar
    @admision=Periodo.where("admision = ? and tipo= ?","t","Lectivo").to_a
    @totalprov=Asignacion.all.size

  end

  def asignar_continuar
       @asignacions=Asignacion.all
    
      respond_to do |format|
        format.js
    end
    

  end

# SI HIDDEN FIEL ES PRINCIPIO, SE LEEN SOLICITUDLAB, SINO DE ASIGNACIONPROV
  def asignar_iniciar
    solicitudes=Solicitudlab.where("fechafin >= ? and asignado <> ?",Date.today,"D").to_a
    @adjudicado=Periodo.where("activo = ? and tipo= ?","t","Lectivo").to_a

    if solicitudes.size!=0 
     
     @solicitudlabs=solicitudes.all

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
  
  def consulta
    @asignacions = Asignaciondef.all
    if @asignacions.size!=0
     @asignacions.reject{|a| !a.solicitudlab.nil? and a.solicitudlab.fechafin<Date.today}
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @asignacions }
    end
  end

  def asigna_directa
    @solicitudlab = Solicitudlab.new
    session[:tramos_horarios]=Solicitudhoraria.new
    session[:codigo_tramo]=0

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @solicitudlab }
    end
  end
#aqui debe ir otra funcion tras captar el formulario anterior

  def graba
    @solicitudlab = Solicitudlab.new(params[:solicitudlab])
    @solicitudlab.usuario_id = params[:usuario][:identificador].to_i
    @solicitudlab.asignatura_id = params[:asignatura][:id].to_i unless params[:asignatura].nil?
    @solicitudlab.fechasol=Date.today
    @solicitudlab.npuestos=Laboratorio.find_by_nombre_lab(params[:laboratorio_id][:nombre_lab]).puestos
    @solicitudlab.curso=params[:nivel].to_s
    @solicitudlab.comentarios=params[:comentarios].to_s
    @solicitudlab.asignado="D"
    @solicitudlab.tipo="X"
    
    if params[:fechaini]=~ /[0-3]?[0-9]\-[0-1]?[0-9]\-[0-9]{4}/
      nfechaini=formato_europeo(params[:fechaini])
      #nfechaini=params[:fechaini].to_s.split('-')
      #nfechaini=fecha[2]+"-"+fecha[1]+"-"+fecha[0]
      @solicitudlab.fechaini=nfechaini.to_date
    else
      @solicitudlab.fechaini=nil
    end
    
    if params[:fechafin]=~ /[0-3]?[0-9]\-[0-1]?[0-9]\-[0-9]{4}/
      nfechafin=formato_europeo(params[:fechafin])
      #fecha=params[:fechafin].to_s.split('-')
      #nfechafin=fecha[2]+"-"+fecha[1]+"-"+fecha[0]
      @solicitudlab.fechafin=nfechafin.to_date
    else
      @solicitudlab.fechafin=nil
    end
    
    respond_to do |format|
    if session[:tramos_horarios].solicitudes.empty?           # no permitiremos una peticion sin tramos
      flash[:notice]="No hay tramos horarios en su peticion"
      format.html { render :action => 'asigna_directa' }
    else
      if @solicitudlab.save
        nuevo_id=@solicitudlab.id                       
        @tramos=session[:tramos_horarios].solicitudes
        @tramos.each {|tramo| p=Peticionlab.new
                              p.solicitudlab_id=nuevo_id
                              p.diasemana=tramo.diasemana
                              p.horaini=tramo.horaini
                              p.horafin=tramo.horafin
                              p.save }
    # esto es lo quedebe cambiar, hay que ir a generar la asignacion nueva y hay que grabarla
    # y redirigir a la consulta de asignaciones  
      l=Laboratorio.find_by_nombre_lab(params[:laboratorio_id][:nombre_lab]).id
      peticiones=Peticionlab.where('solicitudlab_id = ?',@solicitudlab.id).to_a
      peticiones.each {|p|  
                           hi=Horario.find_by_comienzo(p.horaini).id.to_i
                           hf=Horario.find_by_fin(p.horafin).id.to_i
                           dia_id=Dia.find_by_nombre(p.diasemana).id
                           for hora in hi..hf 
                               asignacion=Asignaciondef.new(:solicitudlab_id=>@solicitudlab.id,
                                                                 :laboratorio_id=>l,
                                                                 :peticionlab_id=>p.id,
                                                                 :dia_id=>dia_id,                      #aqui hay cambio
                                                                 :horaini=>Horario.find(hora).comienzo,
                                                                 :horafin=>Horario.find(hora).fin)
                               asignacion.save
                           end
                       }
    # hasta aqui --------                   
        @asignacions = Asignaciondef.all
        format.html { redirect_to('/asignacions/consulta') }
        format.xml  { render :xml => @solicitudlabs, :status => :created, :location => @solicitudlabs }
      else
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

  def borranormalasignada
    asignacion=Asignaciondef.find(params[:asigna])
    asignacion.delete
    # otrasasignaciones=Asignacion.where(:conditions=>['solicitudlab_id = ?',asignacion.solicitudlab_id]).to_a
    # otrasasignaciones.each {|o| o.delete }
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

    

end
