class SolicitudrecursosController < ApplicationController
  # GET /solicitudrecursos
  # GET /solicitudrecursos.xml
  protect_from_forgery :only=>[:create,:update,:destroy]

  before_action :login_requerido, :admin?


  def index
    @solicitudrecursos = Solicitudrecurso.all
    @cuenta = @solicitudrecursos.size

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @solicitudrecursos }
    end
  end

  # GET /solicitudrecursos/new
  # GET /solicitudrecursos/new.xml

  def new  # modificacion para transacciones
    @solicitudrecurso = Solicitudrecurso.new  

    #cargo los usuarios y los diferentes recursos
    @usuarios=Usuario.order("apellidos").to_a.reject{|u| u.identificador=="anonimo"} 
    
    
    #identifico los tipos distintos de recurso
    @tipos = Recurso.all.map{ |i| i.descripcion }.uniq
    
    # cargo los dias y horas posibles para los select
    @dias=Dia.where('en_uso = ?',"t").to_a
    @horas=Horario.where('en_uso = ?',"t").to_a

    #obtengo y formateo la fecha actual 
    @dia=@solicitudrecurso.fechareserva=formato_europeo(Date.today)

    # esto es para crear un carro no persistente  
    session[:tramos_horarios]=Solicitudhoraria.new
    # y una identificacion de tramos horarios para poder borrarlos individualmente. Se ira decrementando
    session[:codigo_tramo]=0
    

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @solicitudrecurso }
    end
  end

  # GET /solicitudrecursos/1/edit
  def edit
    @solicitudrecurso = Solicitudrecurso.find(params[:id])
    @usuarios=Usuario.order("apellidos").to_a.reject{|u| u.identificador=="anonimo"}
    usuario=Usuario.find(@solicitudrecurso.usuario_id)
    @usuarioselec=usuario.apellidos+", "+usuario.nombre 
    @dia=Date.today.strftime("%d-%m-%Y")   
    @nfechareserva=@solicitudrecurso.fechareserva.strftime("%d-%m-%Y")
 
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @solicitudrecurso }
    end
    
  end

  # POST /solicitudrecursos
  # POST /solicitudrecursos.xml


  def create
    @solicitudrecurso = Solicitudrecurso.new
    @solicitudrecurso.tipo=params[:tipo]
    @solicitudrecurso.fechasol=Date.today
    @solicitudrecurso.horaini=params[:horai]
    @solicitudrecurso.horafin=params[:horaf]
    @solicitudrecurso.fechareserva=session[:fechares]
    @solicitudrecurso.usuario_id=session[:user_id]
    @solicitudrecurso.motivos=params[:motivos]
    nombrecomp = params[:usuario].to_s.split(', ')
    @solicitudrecurso.usuario_id = Usuario.where("nombre = :nombre and apellidos = :apellidos", {:nombre => nombrecomp[1], :apellidos => nombrecomp[0]}).first.id
    
       
      if @solicitudrecurso.save
        familia=Recurso.find_by_identificador(@solicitudrecurso.tipo).descripcion
        @recs=Recurso.where( 'descripcion = ? and disponible = ?',familia,"t").to_a
        @ids=@recs.map {|r| r.identificador}
        #session[:fechares]=params[:fecha]
        dia=formato_europeo(session[:fechares])
        #alreves=session[:fechares].to_s.split('-')
        #dia=alreves[2]+"-"+alreves[1]+"-"+alreves[0]
        @reservas = Solicitudrecurso.where('tipo in (?) and fechareserva = ?', @ids,dia).to_a

        respond_to do |format|
           format.js
        end
     
      end
    

  end


  # PUT /solicitudrecursos/1
  # PUT /solicitudrecursos/1.xml
  def update
    @solicitudrecurso = Solicitudrecurso.find(params[:id])
    

    respond_to do |format|

# UN DRYYY!!!!!
    if params[:fechareserva]=~ /[0-3]?[0-9]\-[0-1]?[0-9]\-[0-9]{4}/
      nfechareserva=formato_europeo(params[:fechareserva])
      #fecha=params[:fechareserva].to_s.split('-')
      #nfechareserva=fecha[2]+"-"+fecha[1]+"-"+fecha[0]
    end
    
    
      nombrecomp = params[:usuario][:identificador].to_s.split(', ')
      if @solicitudrecurso.update_attributes(
                                             :usuario_id => Usuario.where( "nombre = :nombre and apellidos = :apellidos", {:nombre => nombrecomp[1], :apellidos => nombrecomp[0]}).first.id,
                                             :motivos => params[:motivos])
               
        @solicitudrecursos = Solicitudrecurso.all
        format.html { redirect_to :action => "index" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @solicitudrecurso.errors, :status => :unprocessable_entity }
      end
    
    end
  end

  # DELETE /solicitudrecursos/1
  # DELETE /solicitudrecursos/1.xml
  def destroy
    @solicitudrecurso = Solicitudrecurso.find(params[:id])
    @tramos=Peticion.where("solicitudrecurso_id = ?",@solicitudrecurso.id).to_a # busco todos los tramos que tenian el id
    @tramos.each {|tramo| tramo.destroy} # los elimino en cascada
    @solicitudrecurso.destroy
    
    respond_to do |format|
      format.html { redirect_to(solicitudrecursos_url) }
      format.xml  { head :ok }
    end
  end

  def borrar_reservas
    solicitudes=Solicitudrecurso.all
    @total=0
    solicitudes.each{|s| s.destroy
                         @total+=1}
    respond_to do |format|
      format.js
    end
  end

  def borra
    @solicitudrecurso = Solicitudrecurso.find(params[:reserva])
    familia=Recurso.where("identificador = ?",@solicitudrecurso.tipo).first.descripcion
    @recs=Recurso.where('descripcion = ? and disponible = ?',familia,"t").to_a
    @solicitudrecurso.destroy
    @ids=@recs.map {|r| r.identificador}
    dia=formato_europeo(session[:fechares])
    @reservas = Solicitudrecurso.where('tipo in (?) and fechareserva = ?', @ids,dia).to_a

    respond_to do |format|
      format.js
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

    @recs=Recurso.where("descripcion || identificador LIKE ?", cadena).to_a
    recs=@recs.map {|r| r.identificador}
    @usuarios=Usuario.where("nombre || apellidos LIKE ?",cadena).to_a
    codigos_u=@usuarios.map { |t| t.id}
    @tramos=Peticion.where("diasemana || horaini || horafin LIKE ?",cadena).to_a
    codigos_t=@tramos.map { |t| t.solicitudrecurso_id}
    @solicitudrecursos=Solicitudrecurso.where("fechareserva ||  fechasol LIKE ? or usuario_id in (?) or id in (?) or tipo in (?)",cadena,codigos_u,codigos_t,recs).to_a
    @cuenta=@solicitudrecursos.size
    respond_to {|format| format.js }
  end

  def buscar
    dia=params[:fecha].to_date
    if dia.wday!=0 and dia>=Date.today # no comprueba si el dia es posterior a hoy o no es domingo
     @recs=Recurso.where('descripcion = ? and disponible = ?',params[:tipo_descripcion],"t").to_a
     @ids=@recs.map {|r| r.identificador}
     session[:fechares]=params[:fecha]
     dia=formato_europeo(params[:fecha])
     #alreves=params[:fecha].to_s.split('-')
     #dia=alreves[2]+"-"+alreves[1]+"-"+alreves[0]
     @reservas = Solicitudrecurso.where('tipo in (?) and fechareserva = ?', @ids,dia).to_a
    else
     @festivo=1
    end
  end
end
