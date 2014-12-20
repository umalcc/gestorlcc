class AddGenericaToAsignaciondefs < ActiveRecord::Migration
  def change
    add_column :asignaciondefs, :generica, :boolean
  end
end
