#!/bin/bash -ex

echo "source testdummy"
source testdummy

echo "test describe function"
describe "test" | grep -E -q '^test$'
[ $? -eq 0 ]

echo "test cmd function"
cmd "not_a_command"
[ $__dummy_cmd_rc -eq 127 ]
cmd "echo banana"
[ $__dummy_cmd_rc -eq 0 ]
test -f $__dummy_cmd_out
grep -E -q '^banana$' $__dummy_cmd_out
cmd "test -f /etc/no_such_banana" || [ $__dummy_cmd_rc -eq 1 ]

echo "test assert_rc function"
__dummy_cmd_rc=1 assert_rc 1 && [ $? -eq 0 ]
__dummy_cmd_rc=1 assert_rc 0 || [ $? -eq 1 ]
__dummy_cmd_rc=255 assert_rc 0 || [ $? -eq 1 ]

echo "test assert_rc_not function"
__dummy_cmd_rc=1 assert_rc_not 0 && [ $? -eq 0 ]
__dummy_cmd_rc=1 assert_rc_not 1 || [ $? -eq 1 ]
__dummy_cmd_rc=255 assert_rc_not 1 || [ $? -eq 1 ]

echo test assert_content function
echo "banana one" > .testout
__dummy_cmd_out=.testout assert_content "banana"
__dummy_cmd_out=.testout assert_content "one"
__dummy_cmd_out=.testout assert_content "two" && false || true
rm .testout

echo test assert_content_not function
echo "banana one" > .testout
__dummy_cmd_out=.testout assert_content_not "test"
__dummy_cmd_out=.testout assert_content_not "bananas"
__dummy_cmd_out=.testout assert_content_not "banana" && false || true
rm .testout

echo "test assert_regex function"
echo "banana one" > .testout
__dummy_cmd_out=.testout assert_regex "banana"
__dummy_cmd_out=.testout assert_regex "^banana one\$"
__dummy_cmd_out=.testout assert_regex "^banana\$" && false || true
rm .testout

echo "test assert_regex_not function"
echo "banana one" > .testout
__dummy_cmd_out=.testout assert_regex_not "test"
__dummy_cmd_out=.testout assert_regex_not "^banana\$"
__dummy_cmd_out=.testout assert_regex_not "^banana one\$" && false || true
rm .testout

echo "test usage function"
__dummy_usage | grep -q 'usage: '

echo "test version function"
__dummy_version=0.0.0 __dummy_version | grep -q "version 0.0.0"

echo "test print_status pass"
__dummy_green='' __dummy_clear='' __dummy_print_status blah PASS | grep -E -q '^  blah\s+\[PASS\]$'

echo "test_print_status_fail"
__dummy_debug=0 __dummy_red='' __dummy_clear='' __dummy_print_status blah FAIL | grep -E -q '^  blah\s+\[FAIL\]$'
