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
	if !self.fecha.nil?
		p=Periodo.where('tipo= ? and admision = ?',"Examenes","t").first
		if !p.nil?
			errors.add("fecha: ", "La fecha elegida no se encuentra dentro del periodo: " + p.inicio.strftime("%d/%m/%Y")+" - "+ p.fin.strftime("%d/%m/%Y")) unless p.inicio<=self.fecha and p.fin>=self.fecha
			end
			end
		end 

end
