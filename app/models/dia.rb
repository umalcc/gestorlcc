class Dia < ActiveRecord::Base

  has_many :asignacion;

   DIASEM=['Domingo','Lunes','Martes','Miercoles','Jueves','Viernes','Sabado']
# restricciones sobre los datos
validates_presence_of :num, :nombre,
                      :message => ': no puede estar en blanco'

validates_numericality_of :num, :only_integer => true,
                          :greater_than_or_equal_to => 0,
                          :message => ": debe ser un número entero"
end
