require 'test_helper'

class PeriodoTest < ActiveSupport::TestCase
  test "Crear un nuevo periodo" do
    @periodo=Periodo.new
    assert  @periodo.save
  end
end
