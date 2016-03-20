class AddGrupoToLaboratorio < ActiveRecord::Migration
  def change
    add_column :laboratorios, :grupo, :string
  end
end
