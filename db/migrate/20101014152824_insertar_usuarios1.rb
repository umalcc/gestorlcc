# encoding: UTF-8
class InsertarUsuarios1 < ActiveRecord::Migration
  def self.up
    usuario=Usuario.new(:identificador=>"aguayo",
                      :password=>"8c5c7c8419afea86ca782d1208d8fede",
                      :password_confirmation=>"8c5c7c8419afea86ca782d1208d8fede",
                      :nombre=>"Andrés",
                      :apellidos=>"Aguayo Maldonado",
                      :email=>"aguayo@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"E.U. Turismo 24",
                      :telefono=>"3255" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"eat",
                      :password=>"9a97eda6d89f5c9e84560468a0679707",
                      :password_confirmation=>"9a97eda6d89f5c9e84560468a0679707",
                      :nombre=>"Enrique",
                      :apellidos=>"Alba Torres",
                      :email=>"eat@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.12",
                      :telefono=>"2803" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"jfam",
                      :password=> "2fbaee34a06250ec68824268551e0439",
                      :password_confirmation=>"2fbaee34a06250ec68824268551e0439",
                      :nombre=>"José Fº",
                      :apellidos=>"Aldana Montes",
                      :email=>"jfam@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.5",
                      :telefono=>"2813" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"alvarezp",
                      :password=>"396f9ae3c8beea51872581e129e855c9",
                      :password_confirmation=>"396f9ae3c8beea51872581e129e855c9",
                      :nombre=>"José Mª",
                      :apellidos=>"Álvarez Palomo",
                      :email=>"alvarezp@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.7",
                      :telefono=>"2750" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"pinilla",
                      :password=>"7c14fa71f0e3c96fc064c3adafcef766",
                      :password_confirmation=>"7c14fa71f0e3c96fc064c3adafcef766",
                      :nombre=>"Mercedes",
                      :apellidos=>"Amor Pinilla",
                      :email=>"pinilla@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.7",
                      :telefono=>"2796" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"mcarmen",
                      :password=>"773fa67e25c00697dd81a4f4f1625f1d",
                      :password_confirmation=>"773fa67e25c00697dd81a4f4f1625f1d",
                      :nombre=>"Mº  Carmen",
                      :apellidos=>"Aranda Garrido",
                      :email=>"mcarmen@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"2.132D",
                      :telefono=>"52392" )
    usuario.save!

  end

  def self.down
  end
end
