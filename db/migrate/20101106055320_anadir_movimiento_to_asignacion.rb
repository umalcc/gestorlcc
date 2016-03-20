class AnadirMovimientoToAsignacion < ActiveRecord::Migration
  def self.up
    add_column :asignacions, :movimientos, :string
  end

  def self.down
    remove_column :asignacions, :movimientos
  end
end
