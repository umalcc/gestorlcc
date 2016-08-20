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
      if !Periodo.where('inicio= ? and fin = ?',self.fechaini,self.fechafin).nil?
         self.tipo="T"
      else
         self.tipo="I"
      end
   end

  end

end
# restricciones del modelo

validate :fechas_correctas?, :fechaini_en_margenes?, :fechafin_en_margenes?
validates_presence_of :fechaini, :fechafin, :asignatura_id,
                       :message => ': No puede estar en blanco'

def fechas_correctas?
     errors.add("fechas: ", "La fecha de inicio es posterior a la fecha de fin") unless fechaini<=fechafin
end

def fechaini_en_margenes?
  p=Periodo.where('tipo= ? and admision = ?',"Lectivo","t").first
  if !p.nil?
    errors.add("fecha ini: ", "La fecha elegida no se encuentra dentro del periodo: " + p.inicio.strftime("%d/%m/%Y")+" - "+ p.fin.strftime("%d/%m/%Y")) unless p.inicio<=self.fechaini and p.fin>=self.fechaini
  end
end 

def fechafin_en_margenes?
  p=Periodo.where('tipo= ? and admision = ?',"Lectivo","t").first
  if !p.nil?
    errors.add("fecha fin: ", "La fecha elegida no se encuentra dentro del periodo: " + p.inicio.strftime("%d/%m/%Y")+" - "+ p.fin.strftime("%d/%m/%Y")) unless p.inicio<=self.fechafin and p.fin>=self.fechafin
  end
end 

end
