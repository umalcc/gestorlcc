class RecursosController < ApplicationController
  # GET /recursos
  # GET /recursos.xml
before_filter :login_requerido, :admin?

  def index
    @recursos = Recurso.order("descripcion").to_a 
    @cuenta=@recursos.size

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @recursos }
    end
  end


  # GET /recursos/new
  # GET /recursos/new.xml
  def new
    @recurso = Recurso.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @recurso }
    end
  end

  # GET /recursos/1/edit
  def edit
    @recurso = Recurso.find(params[:id])
  end

  # POST /recursos
  # POST /recursos.xml
  def create
    @recurso = Recurso.new(recurso_params)

    respond_to do |format|
      if @recurso.save
      #  flash[:notice] = 'El recurso fue creado con &eacute;xito.'
        @recursos = Recurso.order("descripcion").to_a 
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @recurso, :status => :created, :location => @recurso }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @recurso.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /recursos/1
  # PUT /recursos/1.xml
  def update
    @recurso = Recurso.find(params[:id])

    respond_to do |format|
      if @recurso.update(recurso_params)
        #flash[:notice] = 'El recurso fue actualizado con &eacute;xito.'
        @recursos = Recurso.order("descripcion").to_a 
        format.html { redirect_to :action => "index" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @recurso.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /recursos/1
  # DELETE /recursos/1.xml
  def destroy
    @recurso = Recurso.find(params[:id])
    @recurso.destroy

    respond_to do |format|
      format.html { redirect_to(recursos_url) }
      format.xml  { head :ok }
    end
  end

  def listar
    cadena=(params[:query].nil?)? "%" : "%#{params[:query]}%"
    @recursos=Recurso.where("descripcion||identificador||caracteristicas LIKE ?",cadena).to_a
    @cuenta=@recursos.size
    logger.debug "RECURSO"
    respond_to do |format|
      format.js
    end
  end

private
def recurso_params
  params.require(:recurso).permit(:identificador, :descripcion, :caracteristicas, :disponible, :aviso)
end


end
