# encoding: UTF-8
class InsertarUsuarios2 < ActiveRecord::Migration
  def self.up
    usuario=Usuario.new(:identificador=>"bbarros",
                      :password=> "c447390107a885513b98e50b4634fa8a",
                      :password_confirmation=> "c447390107a885513b98e50b4634fa8a",
                      :nombre=>"Beatriz",
                      :apellidos=>"Barros Blanco",
                      :email=>"bbarros@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.35",
                      :telefono=>"3356" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"mavi",
                      :password=>"ca3f390ebc20d9ae642e3472f6715a06",
                      :password_confirmation=>"ca3f390ebc20d9ae642e3472f6715a06",
                      :nombre=>"Mª Victoria",
                      :apellidos=>"Belmonte Martínez",
                      :email=>"mavi@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.36",
                      :telefono=>"2809" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"benitez",
                      :password=> "921fde0433a99a6c5627932ac088e352",
                      :password_confirmation=>"921fde0433a99a6c5627932ac088e352",
                      :nombre=>"Rafaela",
                      :apellidos=>"Benítez Rochel",
                      :email=>"benitez@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.21",
                      :telefono=>"2805" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"vicente",
                      :password=>"71562974cb3965dbc5102a73e6d84dd5",
                      :password_confirmation=>"71562974cb3965dbc5102a73e6d84dd5",
                      :nombre=>"Vicente",
                      :apellidos=>"Benjumea García",
                      :email=>"vicente@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.27",
                      :telefono=>"7146" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"bueno",
                      :password=>"2e30567ce780cb2c965710b8e28f4bf1",
                      :password_confirmation=>"2e30567ce780cb2c965710b8e28f4bf1",
                      :nombre=>"David",
                      :apellidos=>"Bueno Vallejo",
                      :email=>"bueno@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.7",
                      :telefono=>"2796" )
    usuario.save!
  end

  def self.down
  end
end
