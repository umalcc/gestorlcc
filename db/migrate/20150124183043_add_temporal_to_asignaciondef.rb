class AddTemporalToAsignaciondef < ActiveRecord::Migration
  def change
    add_column :asignaciondefs, :temporal, :boolean, :default => false
  end
end
