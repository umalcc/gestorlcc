class AsignaturasController < ApplicationController
  

  before_action :login_requerido 
  before_action :admin?, :except=> [:combo_por_titulacion, :combo_por_nivel]


  def index
    @asignaturas = Asignatura.order("titulacion_id,curso,cuatrimestre").to_a
    
    @titulaciones=Titulacion.order("codigo").to_a
    @cuenta = @asignaturas.size

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @asignaturas }
    end
  end

  def new
    @asignatura = Asignatura.new
    session[:titulacion]=Titulacion.order("nombre").first.id
    session[:nivel]=Asignatura::CURSO.first
    getViewModel

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @asignatura }
    end
  end

  # GET /asignaturas/1/edit
  def edit
    @asignatura = Asignatura.find(params[:id])
    getViewModel
  end

  def saveModel(params)
    @asignatura.codigo_asig=params[:asignatura][:codigo_asig]
    @asignatura.nombre_asig=params[:asignatura][:nombre_asig]
    @asignatura.caracter=params[:caracter]
    @asignatura.coeficiente_exp=params[:coeficiente_exp]
    @asignatura.curso=params[:curso]
    @asignatura.area_depto=params[:area]
    @asignatura.cuatrimestre=params[:cuatrimestre]
    @asignatura.abrevia_asig=params[:asignatura][:abrevia_asig]
    @asignatura.titulacion = Titulacion.find(params[:asignatura][:titulacion])
  end
  # POST /asignaturas
  # POST /asignaturas.xml
  def create

    @asignatura = Asignatura.new
    saveModel(params)
    getViewModel
 
    respond_to do |format|
      if @asignatura.save
       # flash.now[:notice] = 'Asignatura fue creada con &eacute;xito.'
        @asignaturas = Asignatura.order("titulacion_id,curso,cuatrimestre").to_a
        @cuenta = @asignaturas.size 
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @asignatura, :status => :created, :location => @asignatura }
      else
        getViewModel
        format.html { render :action => "new"  }
        format.xml  { render :xml => @asignatura.errors, :status => :unprocessable_entity }
      end
    end
  end

  def getViewModel
    @titulaciones=Titulacion.order("codigo").to_a
  end

  # PUT /asignaturas/1
  # PUT /asignaturas/1.xml
  def update
    @asignatura = Asignatura.find(params[:id])
    saveModel(params)
    getViewModel

    respond_to do |format|
      if @asignatura.save
      #  flash.now[:notice] = 'Asignatura fue actualizada con &eacute;xito.'
        @asignaturas = Asignatura.order("titulacion_id,curso,cuatrimestre").to_a
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

    session[:titulacion]=params[:titulacion]
    logger.debug "nivel" + params[:combo_nivel].to_s
    if(params[:combo_nivel]!=nil)
      session[:combo_nivel]=params[:combo_nivel]
    end
    logger.debug "session nivel " + session[:combo_nivel].to_s
    @asignaturas=Asignatura.order("nombre_asig").where('titulacion_id = ? and curso = ?', session[:titulacion].to_i,params[:combo_nivel]).to_a

    respond_to do |format|
      format.js
    end
  end

  def combo_por_nivel

    session[:nivel]=params[:combo_nivel]
    if(params[:titulacion]!=nil)
      session[:titulacion]=params[:titulacion]
    end
    @asignaturas=Asignatura.order("nombre_asig").where('titulacion_id = ? and curso = ?', session[:titulacion].to_i,session[:nivel].to_i).to_a
    
    respond_to do |format|
      format.js
    end
  end

  def listar
   
    cadena=(params[:query].nil?)? "%" : "%#{params[:query]}%"
    @titulaciones=Titulacion.where("abrevia LIKE ?",cadena).to_a
    codigos=@titulaciones.map { |t| t.id}
    @asignaturas=Asignatura.where("codigo_asig||nombre_asig||caracter||curso||cuatrimestre LIKE ? or titulacion_id in (?)",cadena,codigos).to_a
     @cuenta=@asignaturas.size
 #render(:partial => 'listar', :layout => false)

    respond_to do |format|
	    format.js 
    end
  end


  private 

  def asignatura_params
    params.require(:asignatura).permit(:codigo_asig, :nombre_asig, :area, :caracter, :coeficiente_exp, :curso, :cuatrimestre, :abrevia_asig, :titulacion)
  end

end
