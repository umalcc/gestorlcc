# encoding: UTF-8
class InsertarUsuarios11 < ActiveRecord::Migration
  def self.up
    usuario=Usuario.new(:identificador=>"ramos",
                      :password=> "db3b992995b36a9d2ac616ea2867b14a",
                      :password_confirmation=> "db3b992995b36a9d2ac616ea2867b14a",
                      :nombre=>"Gonzalo",
                      :apellidos=>"Ramos Jiménez",
                      :email=>"ramos@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.2",
                      :telefono=>"2725" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"jirs",
                      :password=> "6f12a29cbb16d59c8dd9d6b04af92982",
                      :password_confirmation=>"6f12a29cbb16d59c8dd9d6b04af92982",
                      :nombre=>"Juan Ignacio",
                      :apellidos=>"Ramos Sobrados",
                      :email=>"jirs@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"I-320-D",
                      :telefono=>"1402" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"mrc",
                      :password=>  "1cb9596773d55a2aa7cf5eddc6fbd633",
                      :password_confirmation=>  "1cb9596773d55a2aa7cf5eddc6fbd633",
                      :nombre=>"Manuel",
                      :apellidos=>"Roldán Castro",
                      :email=>"mrc@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.3",
                      :telefono=>"2819" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"mmar",
                      :password=>"07a075cf5dc4c62b231ac6fccf3364e4",
                      :password_confirmation=>"07a075cf5dc4c62b231ac6fccf3364e4",
                      :nombre=>"Mª del Mar",
                      :apellidos=>"Roldán García",
                      :email=>"mmar@ctima.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.33",
                      :telefono=>"7163" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"rossi",
                      :password=> "2bf65275cb7f5dc95febd7d46cd7d0af",
                      :password_confirmation=> "2bf65275cb7f5dc95febd7d46cd7d0af",
                      :nombre=>"Carlos",
                      :apellidos=>"Rossi Jiménez",
                      :email=>"rossi@ctima.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.30",
                      :telefono=>"3308" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"tolo",
                      :password=>  "315cd00686e4dd9cf34461d958d6469a",
                      :password_confirmation=> "315cd00686e4dd9cf34461d958d6469a",
                      :nombre=>"Bartolomé",
                      :apellidos=>"Rubio Muñoz",
                      :email=>"tolo@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.45",
                      :telefono=>"2753" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"blas",
                      :password=>  "8307c9ea2a958ad9969c49060328c067",
                      :password_confirmation=> "8307c9ea2a958ad9969c49060328c067",
                      :nombre=>"Blas Carlos",
                      :apellidos=>"Ruiz Jiménez",
                      :email=>"blas@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.8",
                      :telefono=>"2795" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"amparo",
                      :password=>  "9e515968f859f259fbed85f45a56bc2c",
                      :password_confirmation=> "9e515968f859f259fbed85f45a56bc2c",
                      :nombre=>"Amparo",
                      :apellidos=>"Ruiz Sepúlveda",
                      :email=>"amparo@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.20",
                      :telefono=>"7145" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"rusman",
                      :password=> "a93071945e2762ef5ea29770214fdf1b",
                      :password_confirmation=> "a93071945e2762ef5ea29770214fdf1b",
                      :nombre=>"Francisco",
                      :apellidos=>"Rus Mansilla",
                      :email=>"rusman@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.51",
                      :telefono=>"3317" )
    usuario.save!
  end

  def self.down
  end
end
