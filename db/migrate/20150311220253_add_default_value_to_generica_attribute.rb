class AddDefaultValueToGenericaAttribute < ActiveRecord::Migration
  def change
  	change_column :asignacions,    :generica, :boolean, :default => false
  	change_column :asignaciondefs, :generica, :boolean, :default => false
  end
end
