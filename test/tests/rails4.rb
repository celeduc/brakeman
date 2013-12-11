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
      :template => 1,
      :generic => 6
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

  def test_denial_of_service_CVE_2013_6414
    assert_warning :type => :warning,
      :warning_code => 64,
      :fingerprint => "a7b00f08e4a18c09388ad017876e3f57d18040ead2816a2091f3301b6f0e5a00",
      :warning_type => "Denial of Service",
      :message => /^Rails\ 4\.0\.0\.beta1\ has\ a\ denial\ of\ servic/,
      :confidence => 1,
      :relative_path => "Gemfile"
  end

  def test_number_to_currency_CVE_2013_6415
    assert_warning :type => :template,
      :warning_code => 66,
      :fingerprint => "0fb96b5f4b3a4dcdc677d126f492441e2f7b46880563a977b1246b30d3c117a0",
      :warning_type => "Cross Site Scripting",
      :line => 9,
      :message => /^Currency\ value\ in\ number_to_currency\ is\ /,
      :confidence => 0,
      :relative_path => "app/views/users/index.html.erb",
      :user_input => s(:call, s(:call, nil, :params), :[], s(:lit, :currency))
  end

  def test_simple_format_xss_CVE_2013_6416
    assert_warning :type => :warning,
      :warning_code => 67,
      :fingerprint => "e950ee1043d7f66b7f6ce99c2bf0876bd3ce8cb12818b52565b905cdb6004bad",
      :warning_type => "Cross Site Scripting",
      :line => nil,
      :message => /^Rails\ 4\.0\.0\.beta1\ has\ a\ vulnerability\ in/,
      :confidence => 1,
      :relative_path => "Gemfile",
      :user_input => nil
  end

  def test_sql_injection_CVE_2013_6417
    assert_warning :type => :warning,
      :warning_code => 69,
      :fingerprint => "e1b66f4311771d714a13be519693c540d7e917511a758827d9b2a0a7f958e40f",
      :warning_type => "SQL Injection",
      :line => nil,
      :message => /^Rails\ 4\.0\.0\.beta1 contains\ a\ SQL\ injection\ vul/,
      :confidence => 0,
      :relative_path => "Gemfile",
      :user_input => nil
  end
end
