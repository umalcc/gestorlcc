class RenameColumnVuelta < ActiveRecord::Migration
  def self.down
     rename_column :asignaturas, :codigo_tit, :titulacion_id
  end

  def self.up
     rename_column :asignaturas, :titulacion_id, :codigo_tit
  end
end
