class Laboratorio < ActiveRecord::Base

  has_many :asignacion

# numero que suman los laboratorios contiguos 1 y 2, 8 y 9
  DOS_LAB=60
# numero de puestos de laboratorio extras en situacion de examen
  PUESTOS_EXAMEN=[100,150]

  validates_uniqueness_of :nombre_lab,
                          :message => ': Ya se encuentra registrado ese valor'
  validates_presence_of :nombre_lab, :puestos, :ssoo,
                        :message => ': No puede estar en blanco'
end
