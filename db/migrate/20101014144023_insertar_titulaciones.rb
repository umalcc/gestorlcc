# encoding: UTF-8
class InsertarTitulaciones < ActiveRecord::Migration
  def self.up
    titulacion=Titulacion.new(:codigo=>"9999",
                      :nombre=>"Situaciones Diversas",
                      :abrevia=>"SD")
    titulacion.save!
    titulacion=Titulacion.new(:codigo=>"5063",
                      :nombre=>"Máster en Ingeniería del Software e Inteligencia Artificial",
                      :abrevia=>"DOC-ISIA")
    titulacion.save!
    titulacion=Titulacion.new(:codigo=>"5062",
                      :nombre=>"Máster en Telemática y Redes de Telecomunicación",
                      :abrevia=>"DOC-MTRT")
    titulacion.save!
    titulacion=Titulacion.new(:codigo=>"5102",
                      :nombre=>"Grado Ingeniería Informática",
                      :abrevia=>"GINGINF")
    titulacion.save!
    titulacion=Titulacion.new(:codigo=>"5103",
                      :nombre=>"Grado Ingeniería del Software",
                      :abrevia=>"GINGSOFT")
    titulacion.save!
    titulacion=Titulacion.new(:codigo=>"5104",
                      :nombre=>"Grado Ingeniería de Computadores",
                      :abrevia=>"GINGCOMP")
    titulacion.save!
    titulacion=Titulacion.new(:codigo=>"5107",
                      :nombre=>"Grado Ingeniería Sistemas de Telecomunicación",
                      :abrevia=>"GINGTEL(ST)")
    titulacion.save!
    titulacion=Titulacion.new(:codigo=>"5108",
                      :nombre=>"Grado Ingeniería Sistemas Electrónicos",
                      :abrevia=>"GINGTEL(SE)")
    titulacion.save!
    titulacion=Titulacion.new(:codigo=>"5109",
                      :nombre=>"Grado Ingeniería Sonido e Imagen",
                      :abrevia=>"GINGTEL(SI)")
    titulacion.save!
    titulacion=Titulacion.new(:codigo=>"5111",
                      :nombre=>"Grado Ingeniería Tecnologías de Telecomunicación",
                      :abrevia=>"GINGTEL(TT)")
    titulacion.save!
    titulacion=Titulacion.new(:codigo=>"5110",
                      :nombre=>"Grado Ingeniería Telemática",
                      :abrevia=>"GINGTEL(TELM)")
    titulacion.save!
    titulacion=Titulacion.new(:codigo=>"109",
                      :nombre=>"Ingeniería Informática",
                      :abrevia=>"IINF")
    titulacion.save!
    titulacion=Titulacion.new(:codigo=>"13",
                      :nombre=>"Ingeniería de Telecomunicaciones",
                      :abrevia=>"ITEL")
    titulacion.save!
    titulacion=Titulacion.new(:codigo=>"110",
                      :nombre=>"Ingeniería Técnica de Informática de Gestión",
                      :abrevia=>"ITINFGES")
    titulacion.save!
    titulacion=Titulacion.new(:codigo=>"111",
                      :nombre=>"Ingeniería Técnica de Informática de Sistemas",
                      :abrevia=>"ITINFSIS")
    titulacion.save!
titulacion=Titulacion.new(:codigo=>"62",
                      :nombre=>"Ingeniería Técnica de Telecomunición Sistemas Electronicos",
                      :abrevia=>"ITTELSE")
    titulacion.save!
titulacion=Titulacion.new(:codigo=>"64",
                      :nombre=>"Ingeniería Técnica de Telecomunición Sonido e Imagen",
                      :abrevia=>"ITTELSI")
    titulacion.save!
titulacion=Titulacion.new(:codigo=>"63",
                      :nombre=>"Ingeniería Técnica de Sistemas de Telecomunicación",
                      :abrevia=>"ITTELST")
    titulacion.save!

  end

  def self.down
  end
end
