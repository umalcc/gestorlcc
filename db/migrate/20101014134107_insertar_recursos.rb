# encoding: UTF-8
class InsertarRecursos < ActiveRecord::Migration
  def self.up
    recurso=Recurso.new(:descripcion=>"Portatil Vaio1",
                      :identificador=>"pv-1",
                      :caracteristicas=>"Windows XP SP3, Wireless",
                      :disponible=>"true",
                      :aviso=>"Recoger y entregar en lab. 3.3.8")
    recurso.save!
    recurso=Recurso.new(:descripcion=>"Portatil Vaio2",
                      :identificador=>"pv-2",
                      :caracteristicas=>"Windows XP SP3, Wireless",
                      :disponible=>"true",
                      :aviso=>"Recoger y entregar en lab. 3.3.8")
    recurso.save!
    recurso=Recurso.new(:descripcion=>"Portatil Vaio3",
                      :identificador=>"pv-3",
                      :caracteristicas=>"Windows XP SP3, Wireless",
                      :disponible=>"true",
                      :aviso=>"Recoger y entregar en lab. 3.3.8")
    recurso.save!
    recurso=Recurso.new(:descripcion=>"Cañón de Video",
                      :identificador=>"cv-1",
                      :caracteristicas=>"ultima generación",
                      :disponible=>"true",
                      :aviso=>"Recoger y entregar en Secretaría")
    recurso.save!
    recurso=Recurso.new(:descripcion=>"Aula multimedia 3.3.1",
                      :identificador=>"am-1",
                      :caracteristicas=>"pizarra digital, 2 cañones de vídeo, 2 cámaras, punto de acceso inalámbrico, 16 puestos",
                      :disponible=>"true",
                      :aviso=>"")
    recurso.save!
  end

  def self.down
  end
end

