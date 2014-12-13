class CreateSolicitudlabs < ActiveRecord::Migration
  def self.up
    create_table :solicitudlabs do |t|
      t.date :fecha_ini
      t.date :fecha_fin
      t.date :fecha_sol
      t.integer :usuario_id
      t.integer :asignatura_id
      t.text :curso
      t.integer :npuestos
      t.text :comentarios

      t.timestamps
    end
  end

  def self.down
    drop_table :solicitudlabs
  end
end
