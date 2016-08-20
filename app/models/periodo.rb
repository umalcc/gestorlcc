class Periodo < ActiveRecord::Base

 validates_uniqueness_of :nombre, 
                          :message => ': Ya se encuentra registrado ese valor'
 validates_presence_of :nombre, :inicio, :fin, :tipo,
                        :message => ': No puede estar en blanco'

 validates_presence_of :iniciosol, :finsol,
                       :message => ': No puede estar en blanco si no es de tipo festivo',
                       :if => Proc.new { |u| u.tipo!='Festivo' }

 validate :activo_admision?

 validate :fechas_correctas?

 validate :fechas_solicitudes_correctas?

 validate :unico_activo_lectivo?,
          :if=> Proc.new { |u| u.tipo=='Lectivo' and u.activo and  ((Periodo.where("tipo=? and activo=?","Lectivo","t").to_a.size>0 and u.id==0) or (Periodo.where("tipo=? and activo=?","Lectivo","t").to_a.size>1 and u.id!=0)) }
 validate :unico_activo_examenes?,
          :if=> Proc.new { |u| u.tipo=='Examenes' and u.activo and ((Periodo.where("tipo=? and activo=?","Examenes","t").to_a.size>0 and u.id==0) or (Periodo.where("tipo=? and activo=?","Examenes","t").to_a.size>1 and u.id!=0)) }
 validate :unico_admision_lectivo?,
          :if=> Proc.new { |u| u.tipo=='Lectivo' and u.admision and ((Periodo.where("tipo=? and admision=?","Lectivo","t").to_a.size>0 and u.id==0) or (Periodo.where("tipo=? and admision=?","Lectivo","t").to_a.size>1 and u.id!=0)) }
 validate :unico_admision_examenes?,
          :if=> Proc.new { |u| u.tipo=='Examenes' and u.admision and ((Periodo.where("tipo=? and admision=?","Examenes","t").to_a.size>0 and u.id==0) or (Periodo.where("tipo=? and admision=?","Examenes","t").to_a.size>1 and u.id!=0)) }

 def fechas_correctas?
     errors.add("fechas: ", "La fecha de inicio es posterior a la fecha de fin") unless inicio<=fin
 end

 def fechas_solicitudes_correctas?
  errors.add("fechas: ", "La fecha de inicio de solicitudes es posterior a la fecha de fin de solicitudes") unless tipo =='Festivo' or iniciosol<=finsol
 end

 def unico_activo_lectivo?
     errors.add("asignado: ","ya hay otro periodo lectivo asignado") #if (activo and tipo=="Lectivo" and Proc.new{|u| u.tipo=='Lectivo' and u.activo})
 end

 def unico_activo_examenes?
    errors.add("asignado: ","ya hay otro periodo de examenes asignado") #if (activo and tipo=="Examenes" and Proc.new{|u| u.tipo=='Examenes' and u.activo})
 end

 def unico_admision_lectivo?
     errors.add("admision: ","otro periodo lectivo tiene activa las admisiones") #if (admision and tipo=="Lectivo" and Proc.new{|u| u.tipo=='Lectivo' and u.admision})
 end

 def unico_admision_examenes?
     errors.add("admision: ","otro periodo de examenes tiene activa las admisiones") #if (admision and tipo=="Examenes" and Proc.new{|u| u.tipo=='Examenes' and u.admision})
 end
 
 def activo_admision?
     errors.add("asignado-admision:", "No pueden estar a la vez activados") unless !activo or !admision
 end
 
end
