class AddDefaultForComentarios < ActiveRecord::Migration
  def change
  	 change_column :solicitudlabs, :comentarios, :string, :default => ''
  	 change_column :solicitudlabexas, :comentarios, :string, :default => ''
  end
end
