class RenameUsuarioToSolicitudrecursos < ActiveRecord::Migration
  def self.up
    #remove_column :usuarios, :usuario 
    add_column :usuarios, :usuario_id, :integer
  end

  def self.down
    add_column :usuarios, :usuario, :string
    remove_column :usuarios, :usuario_id
  end
end
