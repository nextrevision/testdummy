describe "test public functions"
it_describe_function() {
  describe "test" | grep -E -q '^test$'
  describe "test" &> /dev/null
  [ $? -eq 0 ]
}
it_cmd_function() {
  cmd "not_a_command"
  [ $__dummy_cmd_rc -eq 127 ]
  cmd "echo banana"
  [ $__dummy_cmd_rc -eq 0 ]
  test -f $__dummy_cmd_out
  grep -E -q '^banana$' $__dummy_cmd_out
  cmd "test -f /etc/no_such_banana"
  [ $__dummy_cmd_rc -eq 1 ]
}
it_assertrc_function() {
  __dummy_cmd_rc=1 assert_rc 1 && [ $? -eq 0 ]
  __dummy_cmd_rc=1 assert_rc 0 || [ $? -eq 1 ]
  __dummy_cmd_rc=255 assert_rc 0 && [ $? -eq 255 ]
  __dummy_cmd_rc=1 __dummy_verbose=1 assert_rc 0 \
    | grep "expecting return code '0'"
  __dummy_cmd_rc=1 __dummy_verbose=1 assert_rc 0 \
    | grep "got return code '1'"
  __dummy_cmd_rc=1 __dummy_verbose=1 assert_rc 0 \
    | grep "got return code '255'" && false || true
}
it_assertcontent_function() {
  echo "banana one" > .testout
  __dummy_cmd_out=.testout assert_content "banana"
  __dummy_cmd_out=.testout assert_content "one"
  __dummy_cmd_out=.testout assert_content "two" && false || true
  rm .testout
}
it_assertregex_function() {
  echo "banana one" > .testout
  __dummy_cmd_out=.testout assert_regex "banana"
  __dummy_cmd_out=.testout assert_regex "^banana one\$"
  __dummy_cmd_out=.testout assert_regex "^banana\$" && false || true
  rm .testout
}

describe "test private functions"
it_usage_function() {
  __dummy_usage | grep -q 'usage: '
}
it_version_function() {
  __dummy_version=0.0.0 __dummy_version | grep -q "version 0.0.0"
}
it_error_function() {
  cmd "__dummy_red='' __dummy_clear='' __dummy_error 'test'"
  assert_rc 1
  assert_content "ERROR: test"
}
it_printstatus_pass_function() {
  cmd "__dummy_green='' __dummy_clear='' __dummy_print_status test PASS"
  assert_rc 0
  assert_regex '^  test\s+\[PASS\]$'
}
it_printstatus_fail_function() {
  cmd "__dummy_debug=0 __dummy_red='' __dummy_clear='' __dummy_print_status test FAIL"
  assert_rc 0
  assert_regex '^  test\s+\[FAIL\]$'
}
it_printstatus_fail_debug_function() {
  echo "test banana" > .testout
  cmd "__dummy_debug=1 __dummy_debug_out=.testout __dummy_red='' __dummy_clear='' __dummy_print_status test FAIL"
  assert_rc 0
  assert_regex '^  test\s+\[FAIL\]$'
  assert_regex '^    test banana$'
  rm .testout
}
it_printsummary_function() {
  cmd "__dummy_tests=2 __dummy_failed_tests=1 __dummy_print_summary"
  assert_rc 0
  assert_content "Tests:    2"
  assert_content "Passed:    1"
  assert_content "Failed:    1"
  assert_content "Time:    "
}
it_runtest_function() {
  cmd "__dummy_debug_out=.testout __dummy_run_test 'echo banana'"
  assert_rc 0
  assert_content "  echo"
  ! test -f .testout
}
it_runtest_fail_function() {
  cmd "__dummy_debug_out=.testout __dummy_run_test 'banana'"
  assert_rc 0
  assert_content "  banana"
  ! test -f .testout
}

describe "test application flags"
it_responds_to_help_flag() {
  cmd "./testdummy -h"
  assert_rc 0
  assert_content "usage: "
  cmd "./testdummy --help"
  assert_rc 0
  assert_content "usage: "
}
