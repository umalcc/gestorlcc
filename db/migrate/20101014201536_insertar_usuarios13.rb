# encoding: UTF-8
class InsertarUsuarios13 < ActiveRecord::Migration
  def self.up
    usuario=Usuario.new(:identificador=>"av",
                      :password=>  "aac1259dfa2c6c5ead508f34e52bb990",
                      :password_confirmation=>  "aac1259dfa2c6c5ead508f34e52bb990",
                      :nombre=>"Antonio",
                      :apellidos=>"Vallecillo Moreno",
                      :email=>"av@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.48",
                      :telefono=>"2794" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"fvn",
                      :password=> "61f02c0a093c1c270fec39aa14a3140e",
                      :password_confirmation=>"61f02c0a093c1c270fec39aa14a3140e",
                      :nombre=>"Francisco J.",
                      :apellidos=>"Veredas Navarro",
                      :email=>"fvn@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.42",
                      :telefono=>"7155" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"fjv",
                      :password=>  "859db440eae56c09f831880637885e04",
                      :password_confirmation=>  "859db440eae56c09f831880637885e04",
                      :nombre=>"Francisco J.",
                      :apellidos=>"Vico Vela",
                      :email=>"fjv@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.31",
                      :telefono=>"7234" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"villalba",
                      :password=>  "b1f208fa4a64cb910dfe005decf6c7db",
                      :password_confirmation=>  "b1f208fa4a64cb910dfe005decf6c7db",
                      :nombre=>"Francisco",
                      :apellidos=>"Villalba Sánchez",
                      :email=>"villalba@ctima.uma.es",
                      :admin=>"false",
                      :despacho=>"3.3.12",
                      :telefono=>"2716" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"villa",
                      :password=>  "ed3f29fee9e28e36f7cdc8115e0642e9",
                      :password_confirmation=>  "ed3f29fee9e28e36f7cdc8115e0642e9",
                      :nombre=>"Francisco R.",
                      :apellidos=>"Villatoro Machuca",
                      :email=>"villa@ctima.uma.es",
                      :admin=>"false",
                      :despacho=>"2.130.D",
                      :telefono=>"52388" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"jlvivas",
                      :password=> "fd1ffd808258fc23b6a98d3df218dd7f",
                      :password_confirmation=> "fd1ffd808258fc23b6a98d3df218dd7f",
                      :nombre=>"José Luis",
                      :apellidos=>"Vivas Frontana",
                      :email=>"jlvivas@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.3.12",
                      :telefono=>"3374" )
    usuario.save!
    usuario=Usuario.new(:identificador=>"mariemma",
                      :password=> "1ecfc3ec0dd83251e99c4c4e6ea74d63",
                      :password_confirmation=> "1ecfc3ec0dd83251e99c4c4e6ea74d63",
                      :nombre=>"Mariemma",
                      :apellidos=>"Yagüe del Valle",
                      :email=>"mariemma@lcc.uma.es",
                      :admin=>"false",
                      :despacho=>"3.2.39",
                      :telefono=>"7154" )
    usuario.save!

  end

  def self.down
  end
end
