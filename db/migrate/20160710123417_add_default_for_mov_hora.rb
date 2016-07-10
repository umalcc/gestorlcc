class AddDefaultForMovHora < ActiveRecord::Migration
  def change
  	 change_column :asignacions, :mov_hora, :string, :default => ''
  	 change_column :asignaciondefs, :mov_hora, :string, :default => ''
  	 change_column :asignacionexas, :mov_hora, :string, :default => ''
  	 change_column :asignacionlabexas, :mov_hora, :string, :default => ''
  	 change_column :asignacionlabexadefs, :mov_hora, :string, :default => ''
  end
end
