class InsertarAdmin < ActiveRecord::Migration
  def self.up
    usuario = Usuario.new(:identificador=>'admin',
                             :password=>"c391a460b995e1adb8a62a99c532f1f9",
                             :password_confirmation=>"c391a460b995e1adb8a62a99c532f1f9",
                             :nombre=>'Merche',
                             :apellidos=>'Tosina',
                             :email=>'merche@lcc.uma.es',
                             :admin=>'true',
                             :despacho=>'1.1.1',
                             :telefono=>111111)

    usuario.save!
  end

  def self.down
  end
end
