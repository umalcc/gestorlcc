class SessionsController < ApplicationController

require 'net/ldap'

# por defecto, el path de session invita a crear una nueva sesion

  def index
    render :action=> 'new'
  end

  def create
    session[:mensaje]='LDAP activado'
    ###### prueba ldap
    ldap = Net::LDAP.new
    ldap.host = '150.214.108.158'
    ldap.port = 389
    @usuario_actual=Usuario.find_by_identificador(params[:login])

    usuario=params[:login]
    ldap.auth "uid=#{usuario},ou=People,dc=lcc,dc=uma,dc=es",params[:password]
   
    if ldap.bind
      #if !@usuario_actual.sesion
      session[:user_id]=@usuario_actual.id

      #@usuario_actual.sesion=true
      #@usuario_actual.save
      if @usuario_actual.admin
      # si el usuario es administrador
      # File.open('/tmp/adminreservas.txt', 'w+') {|f| f.puts(Date.today.to_s) } # da problema de denegacion
         redirect_to new_inicio_path
      else
        if @usuario_actual.identificador=="anonimo"
           redirect_to '/anonimo/new'
        else
       # si el usuario es particular
         redirect_to new_userinicio_path
        end
     end
    #else # ya existe una sesion para ese usuario
    # flash.now[:notice]='El usuario tiene <br> otra sesion abierta'
    # redirect_to new_session_path
    #end
   else
 #    # si el usuario no es conocido
     flash.now[:notice]='Identificador o <br> password erroneo'.html_safe
      render :action => 'new'
    end
  end
 # al salir de una session, se borra el id del usuario actual
# y se redirije a la creaciÃ³n de una nueva sesion

  def destroy
    session[:user_id]=@usuario_actual=nil
    redirect_to new_session_path
  end

end

