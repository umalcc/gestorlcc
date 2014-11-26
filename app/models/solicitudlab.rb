# encoding: utf-8

class Solicitudlab < ActiveRecord::Base
has_many :peticionlab
belongs_to :asignatura
belongs_to :usuario
has_many :asignacion


# callbacks

before_save:set_tipo
  
def set_tipo
if self.tipo!='X'  # si es una asignacion directa de admin
   if self.fechaini==self.fechafin
      self.tipo="C"
   else 
      # no funciona para el periodo entero
      if !Periodo.first('inicio= ? and fin = ?',self.fechaini,self.fechafin).nil?
         self.tipo="T"
      else
         self.tipo="I"
      end
   end

  end

end
# restricciones del modelo

validate :fechas_correctas?

validates_presence_of :fechaini, :fechafin, :asignatura_id,
                       :message => ': No puede estar en blanco'

def fechas_correctas?
     errors.add("fechas: ", "La fecha de inicio es posterior a la fecha de fin") unless fechaini<=fechafin
end
end
