class Peticionlab < ActiveRecord::Base
belongs_to :solicitudlab
has_one :asignacion

end
