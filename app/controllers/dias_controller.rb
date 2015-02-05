class DiasController < ApplicationController
  # GET /dias
  # GET /dias.xml

before_action :login_requerido, :admin?

  def index
    @dias = Dia.order("num").to_a

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dias }
    end
  end

  # GET /dias/1
  # GET /dias/1.xml
 # def show
 #   @dia = Dia.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @dia }
#    end
#  end

  # GET /dias/new
  # GET /dias/new.xml
  def new
    @dia = Dia.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dia }
    end
  end

  # GET /dias/1/edit
  def edit
    @dia = Dia.find(params[:id])
  end

  # POST /dias
  # POST /dias.xml
  def create
    @dia = Dia.new(dia_params)

    respond_to do |format|
      if @dia.save
        #flash.now[:notice] = 'Dia was successfully created.'
        @dias = Dia.order( "num").to_a
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @dia, :status => :created, :location => @dia }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dia.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dias/1
  # PUT /dias/1.xml
  def update
    @dia = Dia.find(params[:id])

    respond_to do |format|
      if @dia.update(dia_params)
        #flash.now[:notice] = 'Dia was successfully updated.'
        @dias = Dia.order( "num").to_a
        format.html { redirect_to :action => "index"  }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dia.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dias/1
  # DELETE /dias/1.xml
  def destroy
    @dia = Dia.find(params[:id])
    @dia.destroy

    respond_to do |format|
      format.html { redirect_to(dias_url) }
      format.xml  { head :ok }
    end
  end


  private 

  def dia_params
    params.require(:dia).permit(:num, :nombre, :en_uso)
  end

end
