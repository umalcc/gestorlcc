class AddTemporalToAsignacionlabexadefs < ActiveRecord::Migration
  def change
    add_column :asignacionlabexadefs, :temporal, :boolean, :default => false
  end
end
