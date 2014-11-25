class AsignaturasController < ApplicationController
  # GET /asignaturas
  # GET /asignaturas.xml

#  @@asignaturas=[]

  before_filter :login_requerido 

  before_filter :admin?, :except=> [:combo_por_titulacion, :combo_por_nivel]

  def index
    @asignaturas = Asignatura.order("titulacion_id,curso,cuatrimestre").all
    
    @titulaciones=Titulacion.order("codigo").all
    @cuenta = @asignaturas.size

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @asignaturas }
    end
  end

  def new
    @asignatura = Asignatura.new
    session[:titulacion]=Titulacion.order("id").first.id
    session[:nivel]=Asignatura::CURSO.first
   

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @asignatura }
    end
  end

  # GET /asignaturas/1/edit
  def edit
    @asignatura = Asignatura.find(params[:id])
    @titulaciones=Titulacion.order("codigo").all
    @titulaselec=Titulacion.find(@asignatura.titulacion_id).nombre
    @cursoselec=@asignatura.curso
    @areaselec=@asignatura.area_depto
  end

  # POST /asignaturas
  # POST /asignaturas.xml
  def create

    @asignatura = Asignatura.new
    @asignatura.codigo_asig=params[:asignatura][:codigo_asig]
    @asignatura.nombre_asig=params[:asignatura][:nombre_asig]
    @asignatura.caracter=params[:caracter]
    @asignatura.coeficiente_exp=params[:coeficiente_exp]
    @asignatura.curso=params[:curso]
    @asignatura.area_depto=params[:area]
    if params[:cuatrimestre]=="anual"
      @asignatura.cuatrimestre=0
    else
      @asignatura.cuatrimestre=params[:cuatrimestre]
    end
    @asignatura.abrevia_asig=params[:asignatura][:abrevia_asig]
    @asignatura.titulacion_id = Titulacion.find_by_nombre(params[:titulacion][:nombre]).id
    

    respond_to do |format|
      if @asignatura.save
       # flash[:notice] = 'Asignatura fue creada con &eacute;xito.'
        @asignaturas = Asignatura.order("titulacion_id,curso,cuatrimestre").all
        @cuenta = @asignaturas.size 
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @asignatura, :status => :created, :location => @asignatura }
      else
        format.html { render :action => "new"  }
        format.xml  { render :xml => @asignatura.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /asignaturas/1
  # PUT /asignaturas/1.xml
  def update
    @asignatura = Asignatura.find(params[:id])
    @asignatura.titulacion_id = Titulacion.find_by_nombre(params[:titulacion][:nombre]).id
    @asignatura.caracter=params[:caracter]
    if params[:cuatrimestre]=="anual"
      @asignatura.cuatrimestre=0
    else
      @asignatura.cuatrimestre=params[:cuatrimestre]
    end

    respond_to do |format|
      if @asignatura.update_attributes(params[:asignatura])
      #  flash[:notice] = 'Asignatura fue actualizada con &eacute;xito.'
        @asignaturas = Asignatura.order("titulacion_id,curso,cuatrimestre").all
        @cuenta = @asignaturas.size
        format.html { redirect_to :action => "index" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @asignatura.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /asignaturas/1
  # DELETE /asignaturas/1.xml
  def destroy
    @asignatura = Asignatura.find(params[:id])
    @asignatura.destroy

    respond_to do |format|
      format.html { redirect_to(asignaturas_url) }
      format.xml  { head :ok }
    end
  end

  def combo_por_titulacion

    session[:titulacion]=params[:combo_titulacion]
    @asignaturas=Asignatura.order("nombre_asig").all('titulacion_id = ? and curso = ?', session[:titulacion].to_i,session[:nivel].to_i)
    
    return render(:partial => 'combo_por_titulacion', :layout => false) if request.xhr?
  end

  def combo_por_nivel

    session[:nivel]=params[:combo_nivel]
    @asignaturas=Asignatura.order("nombre_asig").all('titulacion_id = ? and curso = ?', session[:titulacion].to_i,session[:nivel].to_i)
    


    return render(:partial => 'combo_por_titulacion', :layout => false) if request.xhr?
  end

  def listar
   
    logger.debug "EEEEEEEEEEEEEEEEEEEEEEEEEE"
    cadena=(params[:query].nil?)? "%" : "%#{params[:query]}%"
    logger.debug "CADENAAAA"+ cadena
    @titulaciones=Titulacion.where("abrevia LIKE ?",cadena).all
    codigos=@titulaciones.map { |t| t.id}
	logger.debug codigos
    @asignaturas=Asignatura.where("codigo_asig||nombre_asig||caracter||curso||cuatrimestre LIKE ? or titulacion_id in (?)",cadena,codigos).all
     @cuenta=@asignaturas.size
 #render(:partial => 'listar', :layout => false)

    respond_to do |format|
 
	format.js 
    end
  end

end
