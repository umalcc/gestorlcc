class SolicitudlabsController < ApplicationController


  before_action :login_requerido, :admin?

  def index
    @solicitudlabs = Solicitudlab.all
    @cuenta = @solicitudlabs.size
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @solicitudlabs }
    end
  end

  def new
    
    @solicitudlab = Solicitudlab.new

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

  # GET /solicitudlabs/1/edit
  def edit
    
    @solicitudlab = Solicitudlab.find(params[:id])
   
    session[:tramos_horarios]=Solicitudhoraria.new
    session[:tramos_horarios].solicitudes=Peticionlab.where("solicitudlab_id = ?",@solicitudlab.id).to_a 
    session[:codigo_tramo]=0
    session[:borrar]=[]
    @solicitudlab.fechaini=formato_europeo(@solicitudlab.fechaini)
    fecha=@solicitudlab.fechaini.to_s.split('-')
    nfechaini=fecha[2]+"-"+fecha[1]+"-"+fecha[0]
    @solicitudlab.fechaini=nfechaini
    fecha=@solicitudlab.fechafin.to_s.split('-')
    nfechaini=fecha[2]+"-"+fecha[1]+"-"+fecha[0]
  end

  # POST /solicitudlabs
  # POST /solicitudlabs.xml
  def create 
    @solicitudlab = Solicitudlab.new(params[:solicitudlab])
    @solicitudlab.usuario_id = params[:usuario][:identificador].to_i
    @solicitudlab.asignatura_id = params[:asignatura][:id].to_i unless params[:asignatura].nil?
    @solicitudlab.fechasol=Date.today
    @solicitudlab.npuestos=params[:npuestos].to_s
    @solicitudlab.curso=params[:nivel].to_s
    @solicitudlab.comentarios=Iconv.conv('ascii//translit//ignore', 'utf-8', params[:comentarios])
    @solicitudlab.asignado="N"
   
# HACER UN DRYYYYYYY!!!!! COMPROBAR SI DETECTA BIEN EL PERIODO

   periodoact=Periodo.where("admision = ? and tipo = ? ","t","Lectivo").first
    if periodoact.nil?
       iniperiodoact=finperiodoact=Date.today 
    else 
       iniperiodoact=periodoact.inicio
       finperiodoact=periodoact.fin
       if formato_europeo(params[:fechaini])<iniperiodoact.to_s
          params[:fechaini]=formato_europeo(iniperiodoact)
       end
       if formato_europeo(params[:fechafin])>finperiodoact.to_s
          params[:fechafin]=formato_europeo(finperiodoact)
       end
    end
     

    if params[:fechaini]==params[:fechafin]
       @solicitudlab.tipo="S"
    else
       if params[:fechaini]==iniperiodoact and params[:fechafin]==finperiodoact
         @solicitudlab.tipo="T"
       else
         @solicitudlab.tipo="P"
       end
    end

    if params[:fechaini]=~ /[0-3]?[0-9]\-[0-1]?[0-9]\-[0-9]{4}/
      nfechaini=formato_europeo(params[:fechaini])
      @solicitudlab.fechaini=nfechaini.to_date
    else
      @solicitudlab.fechaini=nil
    end
    
    if params[:fechafin]=~ /[0-3]?[0-9]\-[0-1]?[0-9]\-[0-9]{4}/
      nfechafin=formato_europeo(params[:fechafin])
      @solicitudlab.fechafin=nfechafin.to_date
    else
      @solicitudlab.fechafin=nil
    end

    pref=""
    @especiales=Laboratorio.where('especial=?',"t").to_a
    for especial in @especiales do
      nombre=especial.ssoo.to_s
      if params[:"#{nombre}"].to_s!='in'
        pref+=especial.nombre_lab.to_s+'-'+nombre+'-'+params[:"#{nombre}"]+";"
      end
    end

    @solicitudlab.preferencias=pref
    respond_to do |format|
    if session[:tramos_horarios].solicitudes.empty?           # no permitiremos una peticion sin tramos
      flash[:notice]="No hay tramos horarios en su peticion"
      format.js
      format.html {render :action=>"new"}

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
                              @correotramos+=' - '+p.diasemana+' de '+p.horaini+' a '+p.horafin }
         
        CorreoTecnicos::emitesolicitudlectivo(@solicitudlab,params[:fechaini],params[:fechafin],@correotramos,"Solicitud cursada por admin","Nueva ").deliver_later      
        
        format.js
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @solicitudlabs, :status => :created, :location => @solicitudlabs }
         
      else
        format.js
	      format.html { render :action => "new" }
        format.xml  { render :xml => @solicitudlabs.errors, :status => :unprocessable_entity }
      end
     
     end
    end
    
  end

  # PUT /solicitudlabs/1
  # PUT /solicitudlabs/1.xml

 def update
    @solicitudlab = Solicitudlab.find(params[:id])

    respond_to do |format|

# UN DRYYY!!!!!

    periodoact=Periodo.where("admision = ? and tipo = ? ","t","Lectivo").first
    if periodoact.nil?
       iniperiodoact=finperiodoact=Date.today 
    else 
       iniperiodoact=periodoact.inicio
       finperiodoact=periodoact.fin
    #   if formato_europeo(params[:fechaini])<iniperiodoact.to_s
    #      params[:fechaini]=formato_europeo(iniperiodoact)
    #   end
    #   if formato_europeo(params[:fechafin])>finperiodoact.to_s
    #      params[:fechafin]=formato_europeo(finperiodoact)
    #   end
    end


    if params[:fechaini]==params[:fechafin]
       @solicitudlab.tipo="S"
    else
       if params[:fechaini]==iniperiodoact and params[:fechafin]==finperiodoact
         @solicitudlab.tipo="T"
       else
         @solicitudlab.tipo="P"
       end
    end
    if params[:fechaini]=~ /[0-3]?[0-9]\-[0-1]?[0-9]\-[0-9]{4}/
      nfechaini=formato_europeo(params[:fechaini])
    end
    
    if params[:fechafin]=~ /[0-3]?[0-9]\-[0-1]?[0-9]\-[0-9]{4}/
      nfechafin=formato_europeo(params[:fechafin])
    end

    pref=""
    @especiales=Laboratorio.where('especial=?',"t").to_a 
    for especial in @especiales do
      nombre=especial.ssoo.to_s
      if params[:"#{nombre}"].to_s!='in'
        pref+=especial.nombre_lab.to_s+'-'+nombre+'-'+params[:"#{nombre}"]+";"
      end
    end
    @solicitudlab.preferencias=pref

    if session[:tramos_horarios].solicitudes.empty?           # no permitiremos una peticion sin tramos
      flash[:notice]="No hay tramos horarios en su peticion"
      @borrados=session[:borrar]
      format.html { render :action=> "edit"}

    else # VEREMOS SI LAS FECHAS SON CORRECTAS SEGUN EL PERIODO

    nombrecomp = params[:usuario][:identificador].to_s.split(', ')
      if @solicitudlab.update_attributes(:fechaini => nfechaini,
                                             :fechafin => nfechafin,
                                             :usuario_id => params[:usuario][:identificador].to_i,
                                             :asignatura_id =>  params[:asignatura][:id].to_i,
                                             :fechasol => Date.today,
					     :curso => params[:nivel].to_s,
					     :npuestos => params[:npuestos].to_s,
                                             :comentarios => Iconv.conv('ascii//translit//ignore', 'utf-8', params[:comentarios]))

        @tramos=session[:tramos_horarios].solicitudes
        @correotramos=''
        @tramos.each {|tramo| if tramo.id.to_i<0
                                p=Peticionlab.new
                                p.solicitudlab_id=@solicitudlab.id
                                p.diasemana=tramo.diasemana
                                p.horaini=tramo.horaini
                                p.horafin=tramo.horafin
                                p.save
                                @correotramos+=' - '+p.diasemana+' de '+p.horaini+' a '+p.horafin
                              end  }
        @borrados=session[:borrar]
        @borrados.each {|tramo| if tramo.to_i > 0
                                  reg=Peticionlab.find(tramo)
                                  reg.destroy
                                end } unless @borrados.empty?
        CorreoTecnicos::emitesolicitudlectivo(@solicitudlab,params[:fechaini],params[:fechafin],@correotramos,"Solicitud cursada por admin","Cambios en ").deliver_later 

        @solicitudlabs = Solicitudlab.all
        format.html { redirect_to :action => "index" }
        format.xml  { head :ok }
      else
        format.html { render :controller=> @solicitudlabs, :action => "edit"}
        format.xml  { render :xml => @solicitudlab.errors, :status => :unprocessable_entity }
      end
    end
    end
  end

  

  # DELETE /solicitudlabs/1
  # DELETE /solicitudlabs/1.xml
 def destroy
    @solicitudlab = Solicitudlab.find(params[:id])
    @solicitudlab.destroy
    @tramos=Peticionlab.where("solicitudlab_id = ?",@solicitudlab.id).to_a # busco todos los tramos que tenian el id
    @correotramos=''
    @tramos.each {|tramo| @correotramos+=' - '+tramo.diasemana+' de '+tramo.horaini+' a '+tramo.horafin
                          tramo.destroy} # los elimino en cascada
    CorreoTecnicos::emitesolicitudlectivo(@solicitudlab,params[:fechaini],params[:fechafin],@correotramos,"Solicitud cursada por admin","Borrado de ").deliver_later 
    respond_to do |format|
      format.html { redirect_to(solicitudlabs_url) }
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
    @tramos=Peticionlab.where("diasemana || horaini || horafin LIKE ?",cadena).to_a
    codigos_t=@tramos.map { |t| t.solicitudlab_id}
    @labs_especiales=Laboratorio.where("ssoo || nombre_lab like ? and especial=?",cadena,"t").to_a
    nombre_l=@labs_especiales.map {|l| l.nombre_lab+'-'+l.ssoo+'-'+'si'+';'}
    nombre_l=nombre_l+@labs_especiales.map {|l| l.nombre_lab+'-'+l.ssoo+'-'+'no'+';'}
    @solicitudlabs=Solicitudlab.where("npuestos || curso || fechaini || fechafin || fechasol LIKE ? or usuario_id in (?) or asignatura_id in (?) or id in (?) or preferencias in (?)", cadena, codigos_u, codigos_a, codigos_t,nombre_l).to_a
    @cuenta=@solicitudlabs.size
    respond_to {|format| format.js }
  end

end
