# encoding: UTF-8
class CrearAsignaturas3 < ActiveRecord::Migration
  def self.up
    asignatura=Asignatura.new(:codigo_asig=>"51683",
                              :nombre_asig=>"Análisis y Diseño de Algoritmos",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>1,
                              :abrevia_asig=>"Anal. Dis. Alg.",
                              :titulacion_id=>6)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51684",
                              :nombre_asig=>"Bases de Datos",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>1,
                              :abrevia_asig=>"BBDD",
                              :titulacion_id=>6)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51686",
                              :nombre_asig=>"Estructura de Datos",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>1,
                              :abrevia_asig=>"Estruc. Datos",
                              :titulacion_id=>6)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51688",
                              :nombre_asig=>"Introducción a la Ingeniería del Software",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Intr. Ing. Soft",
                              :titulacion_id=>6)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51689",
                              :nombre_asig=>"Programación de Sistemas y Concurrencia",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Prog. Sist. Conc.",
                              :titulacion_id=>6)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51690",
                              :nombre_asig=>"Redes y Sistemas Distribuidos",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Redes y Sist. Dist.",
                              :titulacion_id=>6)
    asignatura.save!

    asignatura=Asignatura.new(:codigo_asig=>"51148",
                              :nombre_asig=>"Análisis y Diseño de Algoritmos",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>1,
                              :abrevia_asig=>"Anal. Dis. Alg.",
                              :titulacion_id=>5)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51149",
                              :nombre_asig=>"Bases de Datos",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>1,
                              :abrevia_asig=>"BBDD",
                              :titulacion_id=>5)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51151",
                              :nombre_asig=>"Estructura de Datos",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>1,
                              :abrevia_asig=>"Estruc. Datos",
                              :titulacion_id=>5)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51153",
                              :nombre_asig=>"Introducción a la Ingeniería del Software",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Intr. Ing. Soft",
                              :titulacion_id=>5)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51154",
                              :nombre_asig=>"Programación de Sistemas y Concurrencia",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Prog. Sist. Conc.",
                              :titulacion_id=>5)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51155",
                              :nombre_asig=>"Redes y Sistemas Distribuidos",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Redes y Sist. Dist.",
                              :titulacion_id=>5)
    asignatura.save!

    asignatura=Asignatura.new(:codigo_asig=>"50994",
                              :nombre_asig=>"Análisis y Diseño de Algoritmos",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>1,
                              :abrevia_asig=>"Anal. Dis. Alg.",
                              :titulacion_id=>4)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"50995",
                              :nombre_asig=>"Bases de Datos",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>1,
                              :abrevia_asig=>"BBDD",
                              :titulacion_id=>4)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"50997",
                              :nombre_asig=>"Estructura de Datos",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>1,
                              :abrevia_asig=>"Estruc. Datos",
                              :titulacion_id=>4)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"50999",
                              :nombre_asig=>"Introducción a la Ingeniería del Software",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Intr. Ing. Soft",
                              :titulacion_id=>4)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51000",
                              :nombre_asig=>"Programación de Sistemas y Concurrencia",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Prog. Sist. Conc.",
                              :titulacion_id=>4)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51001",
                              :nombre_asig=>"Redes y Sistemas Distribuidos",
                              :area_depto=>"LSI",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Redes y Sist. Dist.",
                              :titulacion_id=>4)
    asignatura.save!

    asignatura=Asignatura.new(:codigo_asig=>"52404",
                              :nombre_asig=>"Fundamentos de Software de Comunicaciones",
                              :area_depto=>"IT",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Fund. Soft. Com.",
                              :titulacion_id=>10)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"52355",
                              :nombre_asig=>"Fundamentos de Software de Comunicaciones",
                              :area_depto=>"IT",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Fund. Soft. Com.",
                              :titulacion_id=>7)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"52211",
                              :nombre_asig=>"Fundamentos de Software de Comunicaciones",
                              :area_depto=>"IT",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Fund. Soft. Com.",
                              :titulacion_id=>8)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"52113",
                              :nombre_asig=>"Fundamentos de Software de Comunicaciones",
                              :area_depto=>"IT",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Fund. Soft. Com.",
                              :titulacion_id=>9)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"52162",
                              :nombre_asig=>"Fundamentos de Software de Comunicaciones",
                              :area_depto=>"IT",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Fund. Soft. Com.",
                              :titulacion_id=>11)
    asignatura.save!

    asignatura=Asignatura.new(:codigo_asig=>"50998",
                              :nombre_asig=>"Teoría de Autómatas y Lenguajes Formales",
                              :area_depto=>"CCIA",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>1,
                              :abrevia_asig=>"T. Aut. Leng. Form.",
                              :titulacion_id=>4)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51002",
                              :nombre_asig=>"Sistemas Inteligentes",
                              :area_depto=>"CCIA",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Sist. Int.",
                              :titulacion_id=>4)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51152",
                              :nombre_asig=>"Teoría de Autómatas y Lenguajes Formales",
                              :area_depto=>"CCIA",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>1,
                              :abrevia_asig=>"T. Aut. Leng. Form.",
                              :titulacion_id=>5)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51156",
                              :nombre_asig=>"Sistemas Inteligentes",
                              :area_depto=>"CCIA",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Sist. Int.",
                              :titulacion_id=>5)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51687",
                              :nombre_asig=>"Teoría de Autómatas y Lenguajes Formales",
                              :area_depto=>"CCIA",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>1,
                              :abrevia_asig=>"T. Aut. Leng. Form.",
                              :titulacion_id=>6)
    asignatura.save!
    asignatura=Asignatura.new(:codigo_asig=>"51691",
                              :nombre_asig=>"Sistemas Inteligentes",
                              :area_depto=>"CCIA",
                              :caracter=>"OB",
                              :coeficiente_exp=>1,
                              :curso=>2,
                              :cuatrimestre=>2,
                              :abrevia_asig=>"Sist. Int.",
                              :titulacion_id=>6)
    asignatura.save!

  end

  def self.down
  end
end
