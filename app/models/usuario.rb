class Usuario < ActiveRecord::Base
has_many :solicitudlabs
has_many :solicitudrecursos

# restricciones sobre los datos
  validates_confirmation_of :password,
                            :message => ': Error al confirmar la contraseña'
  validates_presence_of :password_confirmation,
                     :if => :password_changed?
  validates_presence_of :identificador, :password,  :nombre, :apellidos, :email,
                        :message => 'no puede estar en blanco'
  validates_length_of :password, 
                      :minimum => 6, 
                      :message => 'debe contener al menos 6 caracteres'
  validates_uniqueness_of :identificador,
                          :message => ': Ya se encuentra registrado ese valor'
 # validates_format_of :email,
 #                    :with => %r{.*@.*\..*},
 #                   :message => ': Tiene formato erroneo'
  validates_uniqueness_of :admin,
                         :message => ': No puede haber dos administradores',
                         :if => Proc.new {|u| u.admin }
  
end
