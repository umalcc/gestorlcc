# encoding: utf-8

#iso-8859-10
class CorreoTecnicos < ActionMailer::Base
  
  def aperturalectivo(nombre,fechafin)
    buzones= 'a@a.com'
    subject  =  'Apertura del plazo de solicitudes de reservas de laboratorios (periodo lectivo)'
    #@recipients= 'a@a.com'
    from      = 'a@a.com' 
    @sent_on   = Time.now
    
    body["nombre"]=nombre
    body["fechafin"]=fechafin
    @body=body
    mail(:to=>buzones, :subject=>subject, :from=>from)
  end
end
