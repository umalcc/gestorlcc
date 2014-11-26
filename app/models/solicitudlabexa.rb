class Solicitudlabexa < ActiveRecord::Base
  belongs_to :asignatura
  belongs_to :usuario

validates_presence_of :fecha, :asignatura_id,
                       :message => ': No puede estar en blanco'

validate :fecha_en_margenes?

validate :horas_correctas?

def horas_correctas?
    errors.add("horas: ", "Las horas elegidas se encuentran cruzadas") unless Horasexa.find_by_comienzo(self.horaini).id<=Horasexa.find_by_fin(self.horafin).id
end

def fecha_en_margenes?
  p=Periodo.first(:conditions=>['tipo= ? and admision = ?',"Examenes","t"])
  if !p.nil?
    errors.add("fecha: ", "La fecha elegida no se encuentra dentro del periodo") unless p.inicio<=self.fecha and p.fin>=self.fecha
  end
end 

end
