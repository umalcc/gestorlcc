class SolicitarController < ApplicationController

before_filter :login_requerido


  def anadir
    @peticion=Solicitud.new
    session[:codigo_tramo]-=1
    @peticion.id=session[:codigo_tramo]
    @peticion.diasemana=params[:diasemana_nombre].to_s
    flash[:notice]=nil
  
    if Horario.find_by_fin(params[:horafin_fin].to_s).id>=Horario.find_by_comienzo(params[:horaini_comienzo].to_s).id
       @peticion.horaini=params[:horaini_comienzo].to_s
       @peticion.horafin=params[:horafin_fin].to_s
      
       if (session[:tramos_horarios].anadir_solicitud(@peticion)==false)
          flash[:notice]="Ese tramo ya ha sido elegido con anterioridad"
       end
       @actual=@peticion.id
      
    else
       flash[:notice]="Hora de fin anterior a la de inicio"
      
       
       respond_to {|format| format.js }

    end
    
  
    
  end


  def eliminar
    session[:tramos_horarios].borrar_solicitud(params[:num])
    @actual=(params[:num])
    if session[:borrar].nil?
      session[:borrar]=params[:num]
    else
      session[:borrar]<<params[:num]
    end
    respond_to {|format| format.js }
  end

end
