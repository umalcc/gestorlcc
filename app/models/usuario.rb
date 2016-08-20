class Usuario < ActiveRecord::Base
has_many :solicitudlabs
has_many :solicitudrecursos

# restricciones sobre los datos
  validates_confirmation_of :password,
                            :message => ': error al confirmar la contraseña'
  validates_presence_of :password_confirmation,
                     :if => :password_changed? ,
                     :message => ': debe introducir confirmación antes de guardar'
  validates_presence_of :identificador, :password,  :nombre, :apellidos, :email,
                        :message => ': no puede estar en blanco'
  validates_length_of :password, 
                      :minimum => 6, 
                      :message => ': debe contener al menos 6 caracteres'
  validates_uniqueness_of :identificador,
                          :message => ': ya se encuentra registrado ese valor'
 # validates_format_of :email,
 #                    :with => %r{.*@.*\..*},
 #                   :message => ': Tiene formato erroneo'
  validates_uniqueness_of :admin,
                         :message => ': no puede haber dos administradores',
                         :if => Proc.new {|u| u.admin }
  
end
