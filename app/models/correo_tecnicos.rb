# encoding: utf-8

#iso-8859-10
class CorreoTecnicos < ActionMailer::Base
  default :from => "a@a.com"
  def aperturalectivo(nombre,fechafin)
    subject  =  'Apertura del plazo de solicitudes de reservas de laboratorios (periodo lectivo)'
    @recipients= 'a@a.com'
    @sent_on   = Time.now
    
    @nombre=nombre
    @fechafin=fechafin
    @body=body
    mail(:to=>recipients, :subject=>subject)
  end


   def aperturaexamen(nombre,fechafin)
    @subject  =  'Apertura del plazo de solicitudes de reservas de laboratorios (examenes)'
    @recipients ='a@a.com'  
    @sent_on =   Time.now
    
    @nombre=nombre
    @fechafin=fechafin
    mail(:to=>@recipients, :subject=>subject)
  end



  def cierrelectivo(nombre)
    @subject  =  'Cierre del plazo de solicitudes de reservas de laboratorios (periodo lectivo)'
    @recipients='a@a.com' 
    @sent_on  =  Time.now
    
    @nombre=nombre
    mail(:to=> @recipients, :subject=>@subject)
  end

  def cierreexamen(nombre)
    @subject   = 'Cierre del plazo de solicitudes de reservas de laboratorios (examenes)'
    @recipients ='a@a.com'
    @sent_on    =Time.now
    
    @nombre=nombre
    mail(:to=>@recipients, :subject=>@subject)
  end

  def adjudicalectivo(nombre)
    @subject =  'Apertura de consultas de adjudicaciones de laboratorios (periodo lectivo)'
    @recipients='a@a.com'
    @sent_on   = Time.now
    
    @nombre=nombre
    mail(:to=>@recipients, :subject=>@subject)
  end

  def adjudicaexamen(nombre)
    @subject =   'Apertura de consultas de adjudicaciones de laboratorios (examenes)'
    @recipients='a@a.com'
    @sent_on  =  Time.now
    
    @nombre=nombre
    mail(:to=>@recipients, :subject=>@subject)
  end

  def cierreadjudicalectivo(nombre)
    @subject =   'Clausura de consultas de adjudicaciones de laboratorios (periodo lectivo)'
    @recipients= 'a@a.com'
    sent_on   = Time.now
    
    @nombre=nombre
   mail(:to=>@recipients, :subject=>@subject)
  end

  def cierreadjudicaexamen(nombre)
    @subject =   'Clausura de consultas de adjudicaciones de laboratorios (examenes)'
    @recipients='a@a.com'
    @sent_on  =  Time.now
    
    @nombre=nombre
    mail(:to=>@recipients, :subject=>@subject)
  end

  def emitesolicitudlectivo(solicitudlab,fechaini,fechafin,tramos,emisor,tipo)
    @subject =   tipo+'solicitud de laboratorio (periodo lectivo)'
    @recipients= 'a@a.com'
    @sent_on  = Time.now
    
    @fecha=solicitudlab.fechasol
    @usuario=solicitudlab.usuario.nombre+' '+solicitudlab.usuario.apellidos
    @asignatura=solicitudlab.asignatura.nombre_asig
    @titulacion=solicitudlab.asignatura.titulacion.nombre
    @curso=solicitudlab.curso
    @npuestos=solicitudlab.npuestos
    @fechaini=fechaini
    @fechafin=fechafin
    @tramos=tramos
    @preferencias=solicitudlab.preferencias
    @comentarios=solicitudlab.comentarios
    @emisor=emisor
    @tipo=tipo
    mail(:to=>@recipients, :subject=>@subject)
  end
 
  def emitesolicitudexamen(solicitudlabexa,fecha,emisor,tipo)
    @subject =   tipo+'solicitud de laboratorio (examenes)'
    @recipients = 'a@a.com'
    @sent_on  =  Time.now
    
    @usuario=solicitudlabexa.usuario.nombre+' '+solicitudlabexa.usuario.apellidos
    @asignatura=solicitudlabexa.asignatura.nombre_asig
    @titulacion=solicitudlabexa.asignatura.titulacion.nombre
    @curso=solicitudlabexa.curso
    @npuestos=solicitudlabexa.npuestos
    @fecha=fecha
    @horaini=solicitudlabexa.horaini
    @horafin=solicitudlabexa.horafin
    @preferencias=solicitudlabexa.preferencias
    @comentarios=solicitudlabexa.comentarios
    @emisor=emisor
    @tipo=tipo

    mail(:to=>@recipients, :subject=>@subject)
  end
end
