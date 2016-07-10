class AddDefaultForMovDia < ActiveRecord::Migration
  def change
  	 change_column :asignacions, :mov_dia, :string, :default => ''
  	 change_column :asignaciondefs, :mov_dia, :string, :default => ''
  	 change_column :asignacionexas, :mov_dia, :string, :default => ''
  	 change_column :asignacionlabexas, :mov_dia, :string, :default => ''
  	 change_column :asignacionlabexadefs, :mov_dia, :string, :default => ''
  end
end
