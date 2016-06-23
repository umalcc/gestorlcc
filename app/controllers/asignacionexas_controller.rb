class AsignacionexasController < ApplicationController
  # GET /asignacionexas
  # GET /asignacionexas.xml

 before_action :login_requerido
 before_action :admin?
 before_action :getViewModel, only: [:asigna_directa, :graba]



  # DELETE /asignacions/1
  # DELETE /asignacions/1.xml
  def destroy
    @asignacionexa = Asignacionlabexa.find(params[:id])
    @asignacionexa.destroy

    respond_to do |format|
      format.html { redirect_to(asignacionlabexas_url) }
      format.xml  { head :ok }
    end
  end


  def asignar
    @admision=Periodo.where("admision = ? and tipo= ?","t","Examenes").to_a
    @totalprov=Asignacionlabexa.all.size

  end

  def asignar_continuar
      @asignacionexas=Asignacionlabexa.all
    
      respond_to do |format|
        format.js
    end
    

  end
# SI HIDDEN FIELD ES PRINCIPIO, SE LEEN SOLICITUDLAB, SINO DE ASIGNACIONEXAPROV
  def asignar_iniciar
    solicitudes=Solicitudlabexa.where("fecha >= ? and asignado <> ?",Date.today,"D").to_a
    #@adjudicado=Periodo.where(:conditions=>["activo = ? and tipo= ?","t","Examenes"]).to_a
    if solicitudes.size!=0 
     
     @solicitudlabexas=solicitudes

     logger.debug "Num de solicitudes:" + (@solicitudlabexas.size).to_s

     # ordenacion de solicitudes de examen segun metodo de ascenso de burbujas por los criterios:
     # 1- por numero de horas totales
     # 2- por numero de puestos descendentemente
     for i in 0..@solicitudlabexas.size-1
       for j in 0..@solicitudlabexas.size-2-i
         if horasexa(@solicitudlabexas[j])<horasexa(@solicitudlabexas[j+1])
             @solicitudlabexas[j],@solicitudlabexas[j+1]=@solicitudlabexas[j+1],@solicitudlabexas[j]
         end
       end
     end

      for i in 0..@solicitudlabexas.size-1
       for j in 0..@solicitudlabexas.size-2-i
         if horasexa(@solicitudlabexas[j])==horasexa(@solicitudlabexas[j+1]) and
           @solicitudlabexas[j].npuestos<@solicitudlabexas[j+1].npuestos
           @solicitudlabexas[j],@solicitudlabexas[j+1]=@solicitudlabexas[j+1],@solicitudlabexas[j]
         end
       end
     end

     # los componentes ordenados secuencialmente, se cargan en un array 3d de horas x labs x ### FECHA ####
     cuadrante=Array3d.new
     @asignacionexas=[]
   
     ####### VER FECHA EN NUMERICO ENTERO Y COMO MANTENER LA CONTINUIDAD DE HORAS (LAS DE IGUAL SOLICITUDLABEXA_ID)
     @nhoras=[]
     @solicitudlabexas.each { |sol|     #por cada una de las @solicitudlabexas, buscamos los lab que tienen ese n. de puestos
                   
         # tomamos la fecha, la hora de inicio y la de fin ###### FECHA NO DIA DE LA SEMANA ##################
         dia=sol.fecha.yday  ####### poner fecha en formato enteroooooooo
         hi=Horasexa.find_by_comienzo(sol.horaini).id.to_i  #### LA SOLICITUD TIENE HORAINI
         hf=Horasexa.find_by_fin(sol.horafin).id.to_i 
         nhoras=hf-hi+1 #### las horas a partir de la inicial que ocupa el examen
         # for hora in hi..hf     #   for cada hora del tramo,una asignacionexa MIRAR SI LIBRE LA PRIMERA HORA Y LAS RESTANTES 
          @nhoras<<nhoras
          
          numLabs = (sol.npuestos / 32.0).ceil

          numLab = 1
          lab=nil
          labApple = false

          while (numLab <= numLabs && !labApple)
      
            @todoslab=Laboratorio.order("nombre_lab").to_a
            # en principio el laboratorio asignado es ninguno y buscamos uno libre de ese tamaño
            if sol.preferencias=="" or sol.preferencias==nil
               @todoslab.each {|laboratorio|  
                                 if cuadrante[hi, laboratorio.id,dia].nil?           
                                    lab=[laboratorio.id]  # si el laboratorio está libre y cabe el num de puestos 
                                 end       
                              }

             # si no habia ninguno libre, colisionamos en el primero de los lab de esa capacidad  
             else # el usuario manifesto una preferencia favorable o desfavorable
             preferencias=sol.preferencias.split(";")        # troceo la cadena de preferencias por el ;  
             preferencias.each { |p| trestramos=p.split("-") # e itero sobre cada trozo y vuelvo a trocear
                                 l=Laboratorio.find_by_nombre_lab(trestramos[0]).id    #  en 3.1.4-Apple-no por el guion
                                 if trestramos[2]=="si"      # si ha dicho que si, ahí lo coloco
                                   labApple = true
                                   lab=[l]                   # si el laboratorio está libre y cabe el num de puestos
                                 else              # si ha dicho que no, elimino de la lista de laboratorios ese laboratorio
                                   @todoslab=@todoslab.reject{|n| n.id==l }
                                   @todoslab.each {|laboratorio|  #### todas las horas ######## HACER UN BUCLE DE HI A HF
                                   if cuadrante[hi, laboratorio.id,dia].nil?           
                                       lab=[laboratorio.id]   
                                   end       
                                   } # todoslab.each
                                 end 
                               } # preferencias.each
             
           end # if sol.preferencias
           if lab.nil?
             lab=[@todoslab.first.id]
           end

           numLab = numLab +1

           # siempre habra al menos una asignacionexa para todos
           # CONSTRUIR UNA LISTA Y UNA ITERACION  SOBRE ELLA DE ASIGNACIONES
           lab.each {|l| for hora in hi..hf
                         @asignacionexas<<asignacionexa=Asignacionlabexa.new(:solicitudlabexa_id=>sol.id,
                                                                 :laboratorio_id=>l,
                                                                 :dia=>sol.fecha,              #aqui hay cambio
                                                                 :horaini=>Horasexa.find(hora).comienzo,
                                                                 :horafin=>Horasexa.find(hora).fin,# POR CADA HORA ENTRE hi y hf
                                                                 :mov_dia=>"",
                                                                 :mov_hora=>"")
                    
                         if cuadrante[hora,l,dia].nil?
                            cuadrante[hora,l,dia]=[asignacionexa]
                         else
                            cuadrante[hora,l,dia]<<[asignacionexa]
                         end  

                         end # del for
                     } # de lab.each 
          end

     }  # for sol

    # finalmente, se vuelcan todas las asignacionexas sobre el archivo persistente
    # eliminando primero los registros que hubiera de una asignacionexa anterior
    # OJOOOOOO VER QUE HACER CUANDO SE ACTIVEN NUEVOS PERIODOS
    Asignacionlabexa.all.each { |a| a.destroy }

    @asignacionexas.each { |a| nueva_asig=Asignacionlabexa.new
                               nueva_asig=a
                               a.solicitudlabexa.asignado="P"
                               a.solicitudlabexa.save
                               nueva_asig.save}
    else
      @asignacionexas=[]
    end # de if 

    respond_to do |format|
        format.js
    end

  end

  def grabar_asignacion
    # borrar las antiguas asignaciones definitivas
    # leer asignacionexas provisionales
    # grabarlas en definitivas
    # eliminar las provisionales
     
    @asignacionlabexadefs=Asignacionlabexadef.all
    if @asignacionlabexadefs.size!=0
      solicitudes=@asignacionlabexadefs.map{|a| a.solicitudlabexa_id}.uniq
      solicitudes.each{|s| sol=Solicitudlabexa.find(s)
                           sol.destroy}
      @asignacionlabexadefs.each{|a| a.destroy}
    end
    @asignacionexas=Asignacionlabexa.all
    @asignacionexas.each { |a| asig_def=Asignacionlabexadef.new(:solicitudlabexa_id=>a.solicitudlabexa_id,
                                                                 :laboratorio_id=>a.laboratorio_id,
                                                                 :dia=>a.dia,              
                                                                 :horaini=>a.horaini,
                                                                 :horafin=>a.horafin,
                                                                 :mov_dia=>a.mov_dia,
                                                                 :mov_hora=>a.mov_hora)
                            asig_def.save
                            sol=Solicitudlabexa.find(a.solicitudlabexa.id)
                            sol.asignado="D"
                            sol.save
                            a.destroy
                      }
    respond_to do |format|
        format.js
      end
  end

  def mover
    @asignacionexa=Asignacionlabexa.find(params[:id]) #coger todas las que tengan la misma solicitudlabexa_id
    inicial_dia=@asignacionexa.dia                    #mover una por una con los cambios de día u hora o lab
    inicial_hora_ini=@asignacionexa.horaini
    inicial_hora_fin=@asignacionexa.horafin
    inicial_laboratorio=@asignacionexa.laboratorio
    laboratorio_id=Laboratorio.find_by_nombre_lab(params[:nombre_lab]).id
    horaini=Horasexa.find_by_comienzo(params[:comienzo]).comienzo
    horafin=Horasexa.find_by_comienzo(params[:comienzo]).fin


    if inicial_laboratorio!=laboratorio_id
      asignaciones=Asignacionlabexa.where('solicitudlabexa_id = ? and laboratorio_id = ?',@asignacionexa.solicitudlabexa,inicial_laboratorio).to_a
      for asignacionexa in asignaciones # todas las que haya que modificar
        asignacionexa.update_attributes(:laboratorio_id=>laboratorio_id) 
      end 
    end
    mov_dia=""
    if formato_europeo(inicial_dia) != params[:dia]
      mov_dia=" cambio de "+inicial_dia.to_s+" a "+params[:dia].to_s+"; "
      asignaciones=Asignacionlabexa.where('solicitudlabexa_id = ?',@asignacionexa.solicitudlabexa).to_a
      for asignacionexa in asignaciones # todas las que haya que modificar
        asignacionexa.update_attributes(:dia=> params[:dia], 
                                        :mov_dia=> mov_dia) 
      end  
    end
    mov_hora="" 
    if inicial_hora_ini != params[:comienzo]
      diferencia=Horasexa.find_by_comienzo(inicial_hora_ini).num-Horasexa.find_by_comienzo(params[:comienzo]).num
      mov_hora=" cambio de "+inicial_hora_ini+"-"+inicial_hora_fin+" a "+params[:comienzo]+"-"+horafin+"; "
      asignaciones=Asignacionlabexa.where('solicitudlabexa_id = ?',@asignacionexa.solicitudlabexa).to_a
      for asignacionexa in asignaciones # todas las que haya que modificar
        asignacionexa.update_attributes(:horaini=> Horasexa.find_by_num(Horasexa.find_by_comienzo(asignacionexa.horaini).num-diferencia).comienzo,
                                        :horafin=> Horasexa.find_by_num(Horasexa.find_by_comienzo(asignacionexa.horaini).num-diferencia).fin,
                                       :mov_hora=> mov_hora )
      end  
    end
        @asignacionexas=Asignacionlabexa.all
        respond_to do |format|
          format.js
        end  
  end  


  def revisar
    @asignacionexas=Asignacionlabexa.all
    cuadro=Array3d.new


    for asignacionexa in @asignacionexas
       dia=asignacionexa.dia.yday #el dia no es el de asignacionexa.peticionlab.diasemana, puede haber cambiado
       hora=Horasexa.find_by_comienzo(asignacionexa.horaini).id
       if cuadro[hora,asignacionexa.laboratorio_id,dia].nil?
          cuadro[hora,asignacionexa.laboratorio_id,dia]=1
       else
          cuadro[hora,asignacionexa.laboratorio_id,dia]+=1
       end
    end

    horas=Horasexa.all.map{|h| h.id}
    laboratorios=Laboratorio.all.map{|l| l.id}
    periodo=Periodo.where('tipo = ? and inicio > ?','Examenes',Date.today).first #cambiar Date.parse por Date.today
    

    @colision=0
    for hora in horas
      for lab in laboratorios
         for dia in periodo.inicio..periodo.fin
           if !cuadro[hora,lab,dia.yday].nil?
             @colision+=1 if cuadro[hora,lab,dia.yday]>1
           end    
            
         end
      end
    end
    respond_to do |format|
          format.js
    end
  end
  
  def consulta
    @asignacionexas = Asignacionlabexadef.order('dia,solicitudlabexa_id,laboratorio_id').to_a

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @asignacionexas }
    end
  end

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
  
  def getViewModel
    @usuarios=Usuario.order("apellidos").to_a
    @titulaciones=Titulacion.order("nombre").to_a
    @laboratorios=Laboratorio.order("nombre_lab").to_a
    @horas=Horasexa.where("en_uso=?","t").order("id").to_a
  end

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
                                              :dia=>@asignacionexa.solicitudlabexa.fecha,                      #aqui hay cambio
                                              :horaini=>Horasexa.find(hora).comienzo,
                                              :horafin=>Horasexa.find(hora).fin)
                               @asignacionexa.save
        end
                                          
        @asignacionexas = Asignacionlabexadef.all
        format.html { redirect_to('/asignacionexas/consulta') }
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

  def borranormal
    asignacionexa=Asignacionlabexa.find(params[:asigna])
    #asignacionexa.delete
    otrasasignacionexas=Asignacionlabexa.where('solicitudlabexa_id = ? and laboratorio_id = ?',asignacionexa.solicitudlabexa_id,asignacionexa.laboratorio_id).to_a
    otrasasignacionexas.each {|o| o.delete }
    @asignacionexas=Asignacionlabexa.all

    respond_to do |format|
      format.js
    end
  end

  def borranormalasignada 
    asignacionexa=Asignacionlabexa.find(params[:asigna])
    #asignacionexa.delete
    otrasasignacionexas=Asignacionlabexa.all('solicitudlabexa_id = ? and laboratorio_id = ?',asignacionexa.solicitudlabexa_id,asignacionexa.laboratorio_id)
    otrasasignacionexas.each {|o| o.delete }
    @asignacionexas=Asignacionlabexa.all
    respond_to do |format|
        format.js
    end
  end

  def borradirasignada
    asignacionexa=Asignacionlabexadef.find(params[:asigna].to_i)
    solicitudlab=Solicitudlabexa.find(asignacionexa.solicitudlabexa_id)
    otrasasignacionexas=Asignacionlabexadef.where('solicitudlabexa_id = ? and laboratorio_id = ?',asignacionexa.solicitudlabexa_id,asignacionexa.laboratorio_id).to_a
    #asignacionexa.delete
    otrasasignacionexas.each {|o| o.delete }
    #solicitudlab.delete
    @asignacionexas=Asignacionlabexadef.order('dia,solicitudlabexa_id,laboratorio_id').to_a
    respond_to do |format|
      format.js
    end
  end

  def borradir
    asignacionexa=Asignacionlabexa.find(params[:asigna])
    solicitudlab=Solicitudlab.find(asignacionexa.solicitudlabexa_id)
    otrasasignacionexas=Asignacionlabexa.all('solicitudlabexa_id = ?',asignacionexa.solicitudlab_id)
    #asignacionexa.delete
    otrasasignacionexas.each {|o| o.delete }
    #solicitudlab.delete
    @asignacionexas=Asignacionlabexa.all
    
    respond_to do |format|
      format.js
    end
  end

  def listar
    cadena=params[:query]
   # para las fechas
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
    if cadena=="-"
      cadena="sin curso"
    end
    cadena=(params[:query].nil?)? "%" : "%#{params[:query]}%"
    @titulaciones=Titulacion.where("abrevia||nombre LIKE ?",cadena).to_a
    codtits=@titulaciones.map{|t| t.id}
    @asignaturas=Asignatura.where("abrevia_asig||nombre_asig LIKE ? or titulacion_id in (?)",cadena,codtits).to_a
    codasigs=@asignaturas.map { |a| a.id}
    @profesores=Usuario.where("nombre||apellidos LIKE ?",cadena).to_a
    codprofs=@profesores.map {|p| p.id}
    @solicitudlabexas=Solicitudlabexa.where("asignatura_id in (?) or usuario_id in (?) or curso LIKE ?",codasigs,codprofs,cadena).to_a
    codsols=@solicitudlabexas.map{|s| s.id}
    @laboratorios=Laboratorio.where("nombre_lab LIKE ?",cadena).to_a
    codlabs=@laboratorios.map{|l| l.id}
    @asignacionexas=Asignacionlabexadef.where("solicitudlabexa_id in (?) or laboratorio_id in (?) or dia LIKE ?",codsols,codlabs,cadena).to_a

    respond_to do |format| 
      format.js 
  end
  
  end

end
