class EstadisticasController < ApplicationController

before_action :login_requerido
before_action :admin?

def periodo_lectivo

end
def estadisticas_lectivo
  if params[:periodo][:nombre_per]=="todos"
    periodo="%"
    @todos=true
  else
    periodo=params[:periodo][:nombre_per]
    @todos=false
  end

  @registros=Historicoasig.find_by_sql("select historicoasigs.* from historicoasigs where periodo like '#{periodo}'  order by periodo,nombre_tit,nombre_asig")

   respond_to do |format|
      format.js
    end

end

def periodo_examenes
 
end

def estadisticas_examenes
  
  @registros=Historicoasigexa.where(:periodo =>params[:periodo][:nombre_per])

  respond_to do |format|
	  format.js
  end

end

def borrar_historico_lectivo
  registros=Historicoasig.all
  @total=0
  registros.each{|r| r.destroy
                     @total+=1}

  respond_to do |format|
    format.js
  end
end

def borrar_historico_examenes
  registros=Historicoasigexa.all
  @total=0
  registros.each{|r| r.destroy
                     @total+=1}

  respond_to do |format|
    format.js
  end
end

end


