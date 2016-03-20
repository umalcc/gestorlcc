class AddTemporalToAsignacionlabexas < ActiveRecord::Migration
  def change
    add_column :asignacionlabexas, :temporal, :boolean, :default => false
  end
end
