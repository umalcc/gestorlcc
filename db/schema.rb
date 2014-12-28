# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141222001600) do

  create_table "asignaciondefs", force: true do |t|
    t.integer  "solicitudlab_id"
    t.integer  "peticionlab_id"
    t.integer  "laboratorio_id"
    t.string   "horaini",         limit: 255
    t.string   "horafin",         limit: 255
    t.integer  "dia_id"
    t.string   "mov_dia",         limit: 255
    t.string   "mov_hora",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "generica"
  end

  create_table "asignacionexas", force: true do |t|
    t.integer  "solicitudlab_id"
    t.integer  "peticionlab_id"
    t.integer  "laboratorio_id"
    t.string   "horaini",         limit: 255
    t.string   "horafin",         limit: 255
    t.integer  "dia_id"
    t.string   "mov_dia",         limit: 255
    t.string   "mov_hora",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "asignacionlabexadefs", force: true do |t|
    t.integer  "solicitudlabexa_id"
    t.integer  "laboratorio_id"
    t.date     "dia"
    t.string   "horaini",            limit: 255
    t.string   "horafin",            limit: 255
    t.string   "mov_dia",            limit: 255
    t.string   "mov_hora",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "asignacionlabexas", force: true do |t|
    t.integer  "solicitudlabexa_id"
    t.integer  "laboratorio_id"
    t.date     "dia"
    t.string   "horaini",            limit: 255
    t.string   "horafin",            limit: 255
    t.string   "mov_dia",            limit: 255
    t.string   "mov_hora",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "asignacions", force: true do |t|
    t.integer  "solicitudlab_id"
    t.integer  "peticionlab_id"
    t.integer  "laboratorio_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "horaini",         limit: 255
    t.string   "horafin",         limit: 255
    t.integer  "dia_id"
    t.string   "mov_dia",         limit: 255
    t.string   "mov_hora",        limit: 255
    t.boolean  "generica"
  end

  create_table "asignaturas", force: true do |t|
    t.string   "codigo_asig",     limit: 255
    t.string   "nombre_asig",     limit: 255
    t.string   "area_depto",      limit: 255
    t.string   "caracter",        limit: 255
    t.float    "coeficiente_exp"
    t.integer  "curso"
    t.integer  "cuatrimestre"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abrevia_asig",    limit: 255
    t.integer  "titulacion_id"
  end

  create_table "dias", force: true do |t|
    t.integer  "num"
    t.string   "nombre",     limit: 255
    t.boolean  "en_uso"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "historicoasigexas", force: true do |t|
    t.date     "fecha_archivo"
    t.string   "periodo",       limit: 255
    t.string   "nombre_usu",    limit: 255
    t.string   "apellidos_usu", limit: 255
    t.string   "nombre_asig",   limit: 255
    t.string   "nombre_tit",    limit: 255
    t.string   "curso",         limit: 255
    t.string   "nombre_lab",    limit: 255
    t.integer  "puestos"
    t.string   "horaini",       limit: 255
    t.string   "horafin",       limit: 255
    t.date     "dia"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "historicoasigs", force: true do |t|
    t.date     "fecha_archivo"
    t.string   "periodo",       limit: 255
    t.string   "nombre_usu",    limit: 255
    t.string   "apellidos_usu", limit: 255
    t.string   "nombre_asig",   limit: 255
    t.string   "nombre_tit",    limit: 255
    t.string   "curso",         limit: 255
    t.string   "nombre_lab",    limit: 255
    t.integer  "puestos"
    t.string   "horaini",       limit: 255
    t.string   "horafin",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "diasem",        limit: 255
  end

  create_table "horarios", force: true do |t|
    t.integer  "num"
    t.string   "comienzo",   limit: 255
    t.string   "fin",        limit: 255
    t.boolean  "en_uso"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "horasexas", force: true do |t|
    t.integer  "num"
    t.string   "comienzo",   limit: 255
    t.string   "fin",        limit: 255
    t.boolean  "en_uso"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "laboratorios", force: true do |t|
    t.string   "nombre_lab",  limit: 255
    t.integer  "puestos"
    t.string   "ssoo",        limit: 255
    t.string   "descr_HW",    limit: 255
    t.string   "descr_SW",    limit: 255
    t.string   "comentarios", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "aviso"
    t.boolean  "especial"
  end

  create_table "periodos", force: true do |t|
    t.string   "nombre",     limit: 255
    t.date     "inicio"
    t.date     "fin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "iniciosol"
    t.date     "finsol"
    t.string   "tipo",       limit: 255
    t.boolean  "activo"
    t.boolean  "admision"
  end

  create_table "peticionlabs", force: true do |t|
    t.text     "diasemana"
    t.text     "horaini"
    t.text     "horafin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "solicitudlab_id"
  end

  create_table "peticions", force: true do |t|
    t.integer  "solicitudrecurso_id"
    t.string   "diasemana",           limit: 255
    t.string   "horaini",             limit: 255
    t.string   "horafin",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recursos", force: true do |t|
    t.string   "descripcion",     limit: 255
    t.string   "identificador",   limit: 255
    t.string   "caracteristicas", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disponible"
    t.text     "aviso"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "solicitudlabexas", force: true do |t|
    t.date     "fechasol"
    t.integer  "usuario_id"
    t.integer  "asignatura_id"
    t.date     "fecha"
    t.text     "curso"
    t.integer  "npuestos"
    t.text     "comentarios"
    t.text     "preferencias"
    t.text     "horaini"
    t.text     "horafin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tipo",          limit: 255
    t.string   "asignado",      limit: 255
  end

  create_table "solicitudlabs", force: true do |t|
    t.date     "fechaini"
    t.date     "fechafin"
    t.date     "fechasol"
    t.integer  "usuario_id"
    t.integer  "asignatura_id"
    t.text     "curso"
    t.integer  "npuestos"
    t.text     "comentarios"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "preferencias"
    t.string   "tipo",          limit: 255
    t.string   "asignado",      limit: 255
  end

  create_table "solicitudrecursos", force: true do |t|
    t.date     "fechareserva"
    t.date     "fechasol"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "usuario",      limit: 255
    t.string   "tipo",         limit: 255
    t.string   "motivos",      limit: 255
    t.integer  "usuario_id"
    t.string   "horaini",      limit: 255
    t.string   "horafin",      limit: 255
  end

  create_table "titulacions", force: true do |t|
    t.integer  "codigo"
    t.string   "nombre",     limit: 255
    t.string   "abrevia",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "usuarios", force: true do |t|
    t.string   "identificador", limit: 255
    t.string   "password",      limit: 255
    t.string   "nombre",        limit: 255
    t.string   "apellidos",     limit: 255
    t.string   "email",         limit: 255
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "despacho",      limit: 255
    t.integer  "telefono"
    t.integer  "usuario_id"
  end

end
