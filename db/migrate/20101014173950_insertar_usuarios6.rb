# encoding: UTF-8
class InsertarUsuarios6 < ActiveRecord::Migration
  def self.up
    usuario=Usuario.new(:identificador=>"jgg",
                      :password=>  "dee9b77e4e0398d64abbc97a14d0978a",
                      :password_confirmation=>  "dee9b77e4e0398d64abbc97a14d0978a",
                      :nombre=>"José",
                      :apellidos=>"Galindo Gómez",
                      :email=>"jgg@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"2.142.D/3.3.12",
                      :telefono=>"52386  2714" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"gallardo",
                      :password=>  "83e88a006f25b3c243da8cca31b10ad5",
                      :password_confirmation=>  "83e88a006f25b3c243da8cca31b10ad5",
                      :nombre=>"Mª del Mar",
                      :apellidos=>"Gallardo Melgarejo",
                      :email=>"gallardo@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.11",
                      :telefono=>"2797" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"pepeg",
                      :password=>"5b3962051ecdc01b1a8d71d2a2280577",
                      :password_confirmation=>"5b3962051ecdc01b1a8d71d2a2280577",
                      :nombre=>"José Enrique",
                      :apellidos=>"Gallardo Ruiz",
                      :email=>"pepeg@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.50",
                      :telefono=>"3305" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"galvez",
                      :password=>"1aa60940328c6b4d436ca21e43eeec6e",
                      :password_confirmation=>"1aa60940328c6b4d436ca21e43eeec6e",
                      :nombre=>"Sergio",
                      :apellidos=>"Gálvez Rojas",
                      :email=>"galvez@ctima.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.28",
                      :telefono=>"3312" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"magb",
                      :password=>"28dd2beaa247af26cad4083acc3e6590",
                      :password_confirmation=>"28dd2beaa247af26cad4083acc3e6590",
                      :nombre=>"Mª Ángeles",
                      :apellidos=>"García Bernal",
                      :email=>"magb@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.3.12",
                      :telefono=>"7233" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"cmgl",
                      :password=>"b437444edcd5377eed82638adf44b5ba",
                      :password_confirmation=>"b437444edcd5377eed82638adf44b5ba",
                      :nombre=>"Carmen Mª",
                      :apellidos=>"García López",
                      :email=>"cmgl@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"2.131.D",
                      :telefono=>"52389" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"jgr",
                      :password=>"2829a0eb6cbfaf2228f40d743ae727de",
                      :password_confirmation=>"2829a0eb6cbfaf2228f40d743ae727de",
                      :nombre=>"Julio",
                      :apellidos=>"Garralón Ruiz",
                      :email=>"jgr@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.51",
                      :telefono=>"3316" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"dgarrido",
                      :password=> "66c094513627d5c932b8e372f0fa2acf",
                      :password_confirmation=> "66c094513627d5c932b8e372f0fa2acf",
                      :nombre=>"Daniel",
                      :apellidos=>"Garrido Márquez",
                      :email=>"dgarrido@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.1",
                      :telefono=>"1401" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"ivan",
                      :password=>"2c42e5cf1cdbafea04ed267018ef1511",
                      :password_confirmation=>"2c42e5cf1cdbafea04ed267018ef1511",
                      :nombre=>"Iván",
                      :apellidos=>"Gómez Gallego",
                      :email=>"ivan@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"E.U. Turismo  28",
                      :telefono=>"6621" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"cesar",
                      :password=>"6f597c1ddab467f7bf5498aad1b41899",
                      :password_confirmation=>"6f597c1ddab467f7bf5498aad1b41899",
                      :nombre=>"A. Cesar",
                      :apellidos=>"Gómez Lora",
                      :email=>"cesar@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"2.2.33",
                      :telefono=>"7151" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"janto",
                      :password=>"07171e775159f083827b82a0318659aa",
                      :password_confirmation=>"07171e775159f083827b82a0318659aa",
                      :nombre=>"José Antonio",
                      :apellidos=>"Gómez Ruiz",
                      :email=>"janto@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"2.143.D",
                      :telefono=>"52391" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"rosa",
                      :password=> "84109ae4b4178430b8174b1dfef9162b",
                      :password_confirmation=> "84109ae4b4178430b8174b1dfef9162b",
                      :nombre=>"Rosa Mª",
                      :apellidos=>"Guerequeta García",
                      :email=>"rosa@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"2.2.26",
                      :telefono=>"2808" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"guevara",
                      :password=> "a14c147048df7f5f4bc4c32762d32457",
                      :password_confirmation=> "a14c147048df7f5f4bc4c32762d32457",
                      :nombre=>"Antonio",
                      :apellidos=>"Guevara Plaza",
                      :email=>"guevara@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"E.U. Turismo 26",
                      :telefono=>"3254" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"pacog",
                      :password=>  "50d903647daee396291f300170751925",
                      :password_confirmation=>  "50d903647daee396291f300170751925",
                      :nombre=>"Francisco",
                      :apellidos=>"Gutiérrez López",
                      :email=>"pacog@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.46",
                      :telefono=>"3314" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"guzman",
                      :password=> "1a9293c661b533d7f975d69380df11fb",
                      :password_confirmation=> "1a9293c661b533d7f975d69380df11fb",
                      :nombre=>"Eduardo",
                      :apellidos=>"Guzmán De Los Riscos",
                      :email=>"guzman@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.27",
                      :telefono=>"7146" )
    usuario.save!
  end

  def self.down
  end
end
