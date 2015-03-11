class AddDefaultValueToPreferenciasAttribute < ActiveRecord::Migration
  def change
  	change_column :solicitudlabs,    :preferencias, :text, :default => ''
  	change_column :solicitudlabexas, :preferencias, :text, :default => ''
  end
end
