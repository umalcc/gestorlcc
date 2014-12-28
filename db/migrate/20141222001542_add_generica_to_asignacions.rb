class AddGenericaToAsignacions < ActiveRecord::Migration
  def change
    add_column :asignacions, :generica, :boolean
  end
end
