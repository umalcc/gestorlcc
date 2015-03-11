class Recurso < ActiveRecord::Base

HORAS=["8:00","10:00","12:00","14:00","16:00","18:00","20:00","22:00"]
NUMHORAS=6

  validates_uniqueness_of :identificador,
                          :message => ': Ya se encuentra registrado ese valor'

  validates_presence_of :identificador,  :descripcion, :caracteristicas,
                        :message => 'no puede estar en blanco'
end
