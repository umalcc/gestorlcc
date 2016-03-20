class TitulacionsController < ApplicationController
  # GET /titulacions
  # GET /titulacions.xml

before_action :login_requerido, :admin?

  def index
    @titulacions = Titulacion.order("abrevia").to_a

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @titulacions }
    end
  end

  # GET /titulacions/1
  # GET /titulacions/1.xml
  #def show
  #  @titulacion = Titulacion.find(params[:id])

  #  respond_to do |format|
  #    format.html # show.html.erb
  #    format.xml  { render :xml => @titulacion }
  #  end
  #end

  # GET /titulacions/new
  # GET /titulacions/new.xml
  def new
    @titulacion = Titulacion.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @titulacion }
    end
  end

  # GET /titulacions/1/edit
  def edit
    @titulacion = Titulacion.find(params[:id])
  end

  # POST /titulacions
  # POST /titulacions.xml
  def create
    @titulacion = Titulacion.new(titulacion_params)

    respond_to do |format|
      if @titulacion.save
       # flash.now[:notice] = 'Titulacion was successfully created.'
        @titulacions = Titulacion.all.order("abrevia")
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @titulacion, :status => :created, :location => @titulacion }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @titulacion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /titulacions/1
  # PUT /titulacions/1.xml
  def update
    @titulacion = Titulacion.find(params[:id])

    respond_to do |format|
      if @titulacion.update(titulacion_params)
     #   flash.now[:notice] = 'Titulacion was successfully updated.'
        @titulacions = Titulacion.order("abrevia").to_a
        format.html { redirect_to :action => "index"  }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @titulacion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /titulacions/1
  # DELETE /titulacions/1.xml
  def destroy
    @titulacion = Titulacion.find(params[:id])
    @titulacion.destroy

    respond_to do |format|
      format.html { redirect_to(titulacions_url) }
      format.xml  { head :ok }
    end
  end

private

def titulacion_params
 params.require(:titulacion).permit(:codigo,:nombre,:abrevia)
end

end
