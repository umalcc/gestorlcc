class ListadoController < ApplicationController


#Se definen las propiedades del documento pdf a generar para las solicitudes
prawnto :prawn => { :top_margin => 35, :page_layout => :landscape} 


include SolicitudesHelper


before_action :login_requerido

  def asignacion_lectivo_impresa
    @asignacions = Asignaciondef.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @asignacions }
    end
  end

  def asignacion_lectivo_usuario_impresa
    @solicitudes = Solicitudlab.where("usuario_id = #{session[:user_id]}").to_a
    ids=@solicitudes.map {|s| s.id } unless @solicitudes.size==0
    @asignacions = Asignaciondef.order("solicitudlab_id,peticionlab_id,dia_id,laboratorio_id").where("solicitudlab_id in (?)", ids).to_a

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @asignacions }
    end
  end

  def asignacion_examenes_impresa
    @asignacionexas = Asignacionlabexadef.order('dia,solicitudlabexa_id,laboratorio_id').to_a


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @asignacions }
    end
  end

  def estadistica_examenes_impresa
    @estadisticas =Historicoasigexa.where(:periodo =>params[:tiempoSol])
 @todos=false
    @labs=Laboratorio.order("nombre_lab").to_a
    @titulaciones=Titulacion.order("nombre").to_a
    @dias=Dia.order("num").to_a
    @horas=Horasexa.order("num").select("comienzo,fin").to_a

    @periodos=Periodo.order("nombre").to_a

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @estadisticas }
      format.pdf { render :layout => false }
    end
  end

  def estadistica_lectivo_impresa
    periodo="%"
    @todos=true
    @labs=Laboratorio.order("nombre_lab").to_a
    @titulaciones=Titulacion.order("nombre").to_a
    @dias=Dia.order("num").to_a
    @horas=Horario.order("num").select("comienzo,fin").to_a

     @estadisticas =Historicoasig.find_by_sql("select historicoasigs.* from historicoasigs where periodo like '#{periodo}'  order by periodo,nombre_tit,nombre_asig")

    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @estadisticas }
      format.pdf { render :layout => false }
    end
  end

  def asignacion_examenes_usuario_impresa

    @solicitudeslab = Solicitudlabexa.where("usuario_id = #{session[:user_id]}").to_a
    ids=@solicitudeslab.map {|s| s.id } unless @solicitudeslab.size==0
    @asignacionexas = Asignacionlabexadef.order('dia,solicitudlabexa_id,laboratorio_id').where("solicitudlabexa_id in (?)", ids).to_a
  end

  def solicitud_lectivo_impresa
    
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
    @tramos=Peticionlab.where("diasemana || horaini || horafin LIKE ?",cadena).to_a
    codigos_t=@tramos.map { |t| t.solicitudlab_id}
    @labs_especiales=Laboratorio.where("ssoo || nombre_lab like ? and especial=?",cadena,"t").to_a
    nombre_l=@labs_especiales.map {|l| l.nombre_lab+'-'+l.ssoo+'-'+'si'+';'}
    nombre_l=nombre_l+@labs_especiales.map {|l| l.nombre_lab+'-'+l.ssoo+'-'+'no'+';'}
    @solicitudlabs=Solicitudlab.where("npuestos || curso || fechaini || fechafin || fechasol LIKE ? or usuario_id in (?) or asignatura_id in (?) or id in (?) or preferencias in (?)", cadena, codigos_u, codigos_a, codigos_t,nombre_l).to_a
    
    tiempoSolicitud = params[:tiempoSol]
    case tiempoSolicitud
      when '0' then @solicitudlabs = getCurrentRequests(@solicitudlabs)
      when '1' then @solicitudlabs = getCurrentCuatrimesterRequests(@solicitudlabs, true)
      when '2' then @solicitudlabs = getFromLastYearRequests(@solicitudlabs)
      when '3' then @solicitudlabs = getFromLast2YearsRequests(@solicitudlabs)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @solicitudlabs }
      format.pdf { render :layout => false }
    end
  end

  def solicitud_examen_impresa
    
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
    
    tiempoSolicitud = params[:tiempoSol]
    case tiempoSolicitud
      when '0' then @solicitudlabexas = getCurrentRequests(@solicitudlabexas)
      when '1' then @solicitudlabexas = getCurrentCuatrimesterRequests(@solicitudlabexas, false)
      when '2' then @solicitudlabexas = getFromLastYearRequests(@solicitudlabexas)
      when '3' then @solicitudlabexas = getFromLast2YearsRequests(@solicitudlabexas)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @solicitudlabexas }
      format.pdf { render :layout => false }
    end
  end

  def solicitud_recurso_impresa
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

    @recs=Recurso.where("descripcion || identificador LIKE ?", cadena).to_a
    recs=@recs.map {|r| r.identificador}
    @usuarios=Usuario.where("nombre || apellidos LIKE ?",cadena).to_a
    codigos_u=@usuarios.map { |t| t.id}
    @tramos=Peticion.where("diasemana || horaini || horafin LIKE ?",cadena).to_a
    codigos_t=@tramos.map { |t| t.solicitudrecurso_id}
    @solicitudrecursos=Solicitudrecurso.where("fechareserva ||  fechasol LIKE ? or usuario_id in (?) or id in (?) or tipo in (?)",cadena,codigos_u,codigos_t,recs).to_a
    
    tiempoSolicitud = params[:tiempoSol]
    case tiempoSolicitud
      when '0' then @solicitudrecursos = getCurrentRequests(@solicitudrecursos)
      when '1' then @solicitudrecursos = getFromLastYearRequests(@solicitudrecursos)
      when '3' then @solicitudrecursos = getFromLast2YearsRequests(@solicitudrecursos)
    end

    @cuenta = @solicitudrecursos.size

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @solicitudrecursos }
      format.pdf { render :layout => false }
    end

  end

end
