require 'test_helper'

class HorasexaTest < ActiveSupport::TestCase
  test "Crear un nuevo horario para exámenes" do
    @hora=Horasexa.new
    assert  @hora.save
  end
end
