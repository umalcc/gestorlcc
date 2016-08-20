class Horasexa < ActiveRecord::Base

# restricciones sobre los datos
validates_presence_of :num, :comienzo, :fin,
                        :message => ': no puede estar en blanco'

validates_format_of :comienzo, :fin,
                     :with => %r{[1-9]?[0-9]\:[0-9][0-9]},
                     :message => ': el formato debe ser hh:mm'
                     
validates_numericality_of :num, :only_integer => true,
                          :greater_than_or_equal_to => 0,
                          :message => ": debe ser un número entero"
end
