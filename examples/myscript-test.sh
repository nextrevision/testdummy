source myscript.sh

describe 'test functions'
test_main_function_with_no_args() {
  cmd '_main'
  assert_rc 1
  assert_content 'ERROR:'
}
test_main_function_args() {
  cmd '_main "hello"'
  assert_rc 0
  assert_content 'hello'
}
test_error_function() {
  cmd '_error "test"'
  assert_rc 1
  assert_regex '^ERROR: test$'
}
test_usage_function() {
  cmd '_usage'
  assert_rc_not 1
  assert_regex '^usage:\s.*'
  assert_content_not 'verbose'
}

describe 'test runtime execution'
test_myscript_with_no_args() {
  cmd './myscript.sh'
  assert_rc 1
  assert_content 'ERROR:'
}
test_myscript_with_args() {
  cmd './myscript.sh "hello"'
  assert_rc 0
  assert_regex '^hello$'
}

describe 'failing functions'
test_myscript_with_args_failure() {
  cmd './myscript.sh'
  assert_rc 1
  assert_content_not 'ERROR:'
}
test_myscript_mode() {
  ! test -x myscript.sh
}
