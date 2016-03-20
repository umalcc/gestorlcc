class AddTemporalToAsignacion < ActiveRecord::Migration
  def change
    add_column :asignacions, :temporal, :boolean, :default => false
  end
end
