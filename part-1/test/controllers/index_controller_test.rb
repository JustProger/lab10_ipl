# frozen_string_literal: true

require 'test_helper'

class IndexControllerTest < ActionDispatch::IntegrationTest
  test 'should get output' do
    get index_output_url
    assert_response :success
  end
end
