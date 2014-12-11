class HorasexasController < ApplicationController
  # GET /horasexas
  # GET /horasexas.xml

before_filter :login_requerido, :admin?

  def index
    @horasexas = Horasexa.order("num").to_a

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @horasexas }
    end
  end

  def new
    @horasexa = Horasexa.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @horasexa }
    end
  end

  # GET /horarios/1/edit
  def edit
    @horasexa = Horasexa.find(params[:id])
  end

  # POST /horarios
  # POST /horarios.xml
  def create
    @horasexa = Horasexa.new(horasexa_params)

    respond_to do |format|
      if @horasexa.save
       
        @horasexas = Horasexa.order("num").to_a
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @horasexa, :status => :created, :location => @horasexa }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @horasexa.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /horarios/1
  # PUT /horarios/1.xml
  def update
    @horasexa = Horasexa.find(params[:id])

    respond_to do |format|
      if @horasexa.update(horasexa_params)
        @horasexas = Horasexa.order("num").to_a
        format.html { redirect_to :action => "index"  }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @horasexa.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /horarios/1
  # DELETE /horarios/1.xml
  def destroy
    @horasexa = Horasexa.find(params[:id])
    @horasexa.destroy

    respond_to do |format|
      format.html { redirect_to(horasexas_url) }
      format.xml  { head :ok }
    end
  end


 private

 def horasexa_params
    params.require(:horasexa).permit(:num, :comienzo, :fin, :en_uso)
 end

end
