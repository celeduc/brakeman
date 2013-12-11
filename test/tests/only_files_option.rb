abort "Please run using test/test.rb" unless defined? BrakemanTester

Rails32OnlyFiles = BrakemanTester.run_scan "rails3.2", "Rails 3.2", { :only_files => ["app/views/users/"], :skip_files => ["app/views/users/sanitized.html.erb"] }

class OnlyFilesOptionTests < Test::Unit::TestCase
  include BrakemanTester::FindWarning
  include BrakemanTester::CheckExpected

  def expected
    @expected ||= {
      :controller => 0,
      :model => 0,
      :template => 1,
      :generic => 4 }


    if RUBY_PLATFORM == 'java'
      @expected[:generic] += 1
    end

    @expected
  end

  def report
    Rails32OnlyFiles
  end

  def test_escaped_params_to_json
    assert_no_warning :type => :template,
      :warning_type => "Cross Site Scripting",
      :line => 21,
      :message => /^Unescaped\ parameter\ value/,
      :confidence => 0,
      :file => /show\.html\.erb/
  end

  def test_cross_site_scripting_slim_partial_param
    assert_warning :type => :template,
      :warning_type => "Cross Site Scripting",
      :line => 6,
      :message => /^Unescaped\ parameter\ value/,
      :confidence => 0,
      :file => /_slimmer\.html\.slim/
  end

  # This is the template that is skipped, should be no warning
  def test_xss_sanitize_css_CVE_2013_1855
    assert_no_warning :type => :template,
      :warning_type => "Cross Site Scripting",
      :line => 2,
      :message => /^Rails\ 3\.2\.9\.rc2\ has\ a\ vulnerability\ in\ s/,
      :confidence => 0,
      :file => /sanitized\.html\.erb/
  end

  def test_i18n_xss_CVE_2013_4491
    assert_warning :type => :warning,
      :warning_code => 63,
      :fingerprint => "de0e11056b9f9af7b8570d5354185cd7e17a18cc61d627555fe4adfff00fb447",
      :warning_type => "Cross Site Scripting",
      :message => /^Rails\ 3\.2\.9\.rc2\ has\ an\ XSS\ vulnerability/,
      :confidence => 1,
      :relative_path => "Gemfile"
  end

  def test_denial_of_service_CVE_2013_6414
    assert_warning :type => :warning,
      :warning_code => 64,
      :fingerprint => "a7b00f08e4a18c09388ad017876e3f57d18040ead2816a2091f3301b6f0e5a00",
      :warning_type => "Denial of Service",
      :line => nil,
      :message => /^Rails\ 3\.2\.9\.rc2\ has\ a\ denial\ of\ service\ /,
      :confidence => 1,
      :relative_path => "Gemfile",
      :user_input => nil
  end

end
