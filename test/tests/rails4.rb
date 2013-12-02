abort "Please run using test/test.rb" unless defined? BrakemanTester

Rails4 = BrakemanTester.run_scan "rails4", "Rails 4"

class Rails4Tests < Test::Unit::TestCase
  include BrakemanTester::FindWarning
  include BrakemanTester::CheckExpected
  
  def report
    Rails4
  end

  def expected
    @expected ||= {
      :controller => 0,
      :model => 0,
      :template => 0,
      :generic => 4
    }
  end

  def test_redirects_to_created_model_do_not_warn
    assert_no_warning :type => :warning,
      :warning_code => 18,
      :fingerprint => "fedba22f0fbcd96dcaa0b2628ccedba2c0880870992d05b817697efbb36e134f",
      :warning_type => "Redirect",
      :line => 14,
      :message => /^Possible\ unprotected\ redirect/,
      :confidence => 0,
      :relative_path => "app/controllers/application_controller.rb",
      :user_input => s(:call, s(:const, :User), :create)

    assert_no_warning :type => :warning,
      :warning_code => 18,
      :fingerprint => "1d2d4b0a59ed26a6d591094714dbee81a60a3e686429a44fe2d80f87b94bc555",
      :warning_type => "Redirect",
      :line => 18,
      :message => /^Possible\ unprotected\ redirect/,
      :confidence => 0,
      :relative_path => "app/controllers/application_controller.rb",
      :user_input => s(:call, s(:const, :User), :create!)
  end

  def test_session_secret_token
    assert_warning :type => :generic,
      :warning_type => "Session Setting",
      :fingerprint => "715ad9c0d76f57a6a657192574d528b620176a80fec969e2f63c88eacab0b984",
      :line => 12,
      :message => /^Session\ secret\ should\ not\ be\ included\ in/,
      :confidence => 0,
      :file => /secret_token\.rb/,
      :relative_path => "config/initializers/secret_token.rb"
  end

  def test_json_escaped_by_default_in_rails_4
    assert_no_warning :type => :template,
      :warning_code => 5,
      :fingerprint => "3eedfa40819ce95d1d999ad19464023688a0e8bb881fc3e7683b6c3fffb7e51f",
      :warning_type => "Cross Site Scripting",
      :line => 1,
      :message => /^Unescaped\ model\ attribute\ in\ JSON\ hash/,
      :confidence => 0,
      :relative_path => "app/views/users/index.html.erb"

    assert_no_warning :type => :template,
      :warning_code => 5,
      :fingerprint => "fb0cb7e94e9a4bebd81ef44b336e02f68bf24f2c40e28d4bb5c21641276ea6cf",
      :warning_type => "Cross Site Scripting",
      :line => 3,
      :message => /^Unescaped\ model\ attribute/,
      :confidence => 2,
      :relative_path => "app/views/users/index.html.erb"

    assert_no_warning :type => :template,
      :warning_code => 5,
      :fingerprint => "8ce0a9eacf25be1f862b9074e6ba477d2f0e2ac86955b8510052984570b92d14",
      :warning_type => "Cross Site Scripting",
      :line => 5,
      :message => /^Unescaped\ parameter\ value\ in\ JSON\ hash/,
      :confidence => 0,
      :relative_path => "app/views/users/index.html.erb"

    assert_no_warning :type => :template,
      :warning_code => 2,
      :fingerprint => "b107fcc7742084a766a31332ba5c126f1c1a1cc062884f879dc3204c5f7620c5",
      :warning_type => "Cross Site Scripting",
      :line => 7,
      :message => /^Unescaped\ parameter\ value/,
      :confidence => 0,
      :relative_path => "app/views/users/index.html.erb"
  end

  def test_information_disclosure_local_request_config
    assert_warning :type => :warning,
      :warning_code => 61,
      :fingerprint => "081f5d87a244b41d3cf1d5994cb792d2cec639cd70e4e306ffe1eb8abf0f32f7",
      :warning_type => "Information Disclosure",
      :message => /^Detailed\ exceptions\ are\ enabled\ in\ produ/,
      :confidence => 0,
      :relative_path => "config/environments/production.rb"
  end

  def test_information_disclosure_detailed_exceptions_override
    assert_warning :type => :warning,
      :warning_code => 62,
      :fingerprint => "c1c1c512feca03b77e560939098efabbc2ec9279ef66f75bc63a84f815b54ec2",
      :warning_type => "Information Disclosure",
      :line => 6,
      :message => /^Detailed\ exceptions\ may\ be\ enabled\ in\ 's/,
      :confidence => 0,
      :relative_path => "app/controllers/application_controller.rb"
  end

  def test_redirect_with_instance_variable_from_block
    assert_no_warning :type => :warning,
      :warning_code => 18,
      :fingerprint => "e024f0cf67432409ec4afc80216fb2f6c9929fbbd32c2421e8867cd254f22d04",
      :warning_type => "Redirect",
      :line => 12,
      :message => /^Possible\ unprotected\ redirect/,
      :confidence => 0,
      :relative_path => "app/controllers/friendly_controller.rb"
  end

  def test_mass_assignment_with_permit!
    assert_warning :type => :warning,
      :warning_code => 63,
      :fingerprint => "2f9b87d2a203ac50aa86443a86045c0475e9531c519f62971b8b4a7ae5a183d6",
      :warning_type => "Mass Assignment",
      :line => 17,
      :message => /^Parameters\ should\ be\ whitelisted\ for\ mas/,
      :confidence => 0,
      :relative_path => "app/controllers/friendly_controller.rb"

    assert_no_warning :type => :warning,
      :warning_code => 63,
      :fingerprint => "a10d0b1f2a955ce0f2bd31bec0a017e776ced7336f360304043c5b78e40f8342",
      :warning_type => "Mass Assignment",
      :line => 23,
      :message => /^Parameters\ should\ be\ whitelisted\ for\ mas/,
      :confidence => 0,
      :relative_path => "app/controllers/friendly_controller.rb"

    assert_no_warning :type => :warning,
      :warning_code => 63,
      :fingerprint => "84131663bb524b6d63d00f5aabb1a0ef21152f7f76889c24e6a2ec1c91a90d34",
      :warning_type => "Mass Assignment",
      :line => 29,
      :message => /^Parameters\ should\ be\ whitelisted\ for\ mas/,
      :confidence => 0,
      :relative_path => "app/controllers/friendly_controller.rb"

    assert_no_warning :type => :warning,
      :warning_code => 63,
      :fingerprint => "c33164248f07376a2a5a211f1f4f378d7d0b87772a89d331670abb7331417584",
      :warning_type => "Mass Assignment",
      :line => 35,
      :message => /^Parameters\ should\ be\ whitelisted\ for\ mas/,
      :confidence => 0,
      :relative_path => "app/controllers/friendly_controller.rb"
  end
end
