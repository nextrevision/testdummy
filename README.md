testdummy
=========

[![Circle CI](https://circleci.com/gh/nextrevision/testdummy.svg?style=svg)](https://circleci.com/gh/nextrevision/testdummy)

A shell script testing framework

## Installation

    curl --silent -o testdummy https://raw.githubusercontent.com/nextrevision/testdummy/master/testdummy
    chmod +x testdummy

## Usage

    usage: ./testdummy [args] testfile

    -h|--help     Help
    -d|--debug    Enabled debug logging
    -v|--verbose  Enables verbose logging
    --nocolor     Disable color output
    --version     Prints the version and exits

## Examples

Take a look at the example script and testfile in `examples/`. It can be
run with the following command:

    ./testdummy examples/myscript-test.sh
    
Results in the following output:

    test functions
        test main function with no args                    [PASS]
        test main function args                            [PASS]
        test error function                                [PASS]
        test usage function                                [PASS]

    test runtime execution
        test myscript with no args                         [PASS]
        test myscript with args                            [PASS]

    failing functions
        test myscript with args failure                    [FAIL]
        test myscript mode                                 [FAIL]
    -------------------------------------------------------------
    Tests:    8  |  Passed:    6  |  Failed:    2  |  Time:    0s

## Writing Tests

Tests can be stored in any file, so long as that file can be read by the user
executing the script. `testdummy` sources the file and looks for functions with
specific prefixes and then executes them sequentially.

If you are writing tests for a script, the first thing you probably want to do
is source your script like so:

    source myscript.sh

It's probably useful to surround the entry point of your script with a condition
to ensure that when sourcing, it does not behave the same as when executing. For
example:

    # allow for sourcing
    if [[ $(basename ${0//-/}) == "myscript.sh" ]]; then
      main_function_to_call
    fi

Tests can be defined in functions with specific prefixes. Given the following
function in our script `myscript.sh`:

    _usage() {
      echo "usage: $0 [args]"
    }

We could write a test like so:

    test_usage_function() { _usage | grep -E '^usage:\s'; }

All tests should be wrapped inside of a `testdummy` prefixed function to avoid
any issues when first sourcing the testfile.

#### Test Prefixes

`testdummy` reserves and looks for the following prefixes in function names in
order to know just what to execute:

* `test_`
* `do_`
* `it_`

Functions will be passed over (not executed) unless they start with one of these
prefixes.

### Helpers and Matchers

`testdummy` exposes a set of useful builtin functions for testing commands and
functions.

#### `describe "<string>"`

`describe` is a purely organizational helper that is used for grouping sets of
tests in the output.

Given the following test file:

    describe "test cli flags"
    it_responds_to_help_flag() { ... }
    it_responds_to_verbose_flag() { ... }

    describe "test private functions"
    test_usage_function() { ... }

We could expect the following output:

    test cli flags
      it responds to help flag        [PASS]
      it responds to verbose flag     [PASS]

    test private functions
      test usage function             [PASS]

#### `cmd "<command string>"`

`cmd` is executed within a test function and takes a single string argument
that represents the command to execute. `cmd` does not react to failures or
output, but rather stores that information to be tested by other matchers
within the same function.

    test_echo_function() {
      cmd "echo 'this will pass'"
    }
    test_false_function() {
      # will not exit or fail the test
      cmd "/bin/false"
    }

#### `assert_rc <int>`

Asserts that the command executed by the `cmd` function returned the specified
code. If the code does not match, the test function will fail.

Example:

    describe "passing test"
    test_echo_function() {
      cmd "echo 'this will pass'"
      assert_rc 0
    }
    describe "failing test"
    test_false_function() {
      cmd "/bin/false"
      assert_rc 1
    }

#### `assert_rc_not <int>`

Asserts that the command executed by the `cmd` function does not match the
given return code. If the code **does** match, the test function will **fail**.

Example:

    describe "passing test"
    test_echo_function() {
      cmd "echo 'this will pass'"
      assert_rc_not 1
    }
    describe "failing test"
    test_false_function() {
      cmd "/bin/false"
      assert_rc_not 0
    }

#### `assert_content "<string>"`

Asserts that the output of the command executed by the `cmd` function contains
the content of `<string>`. If the output does not, then the test function will
fail.

Example:

    describe "passing test"
    test_echo_function() {
      cmd "echo 'this will pass'"
      assert_content "will pass"
    }
    describe "failing test"
    test_false_function() {
      cmd "echo 'this will fail'"
      assert_content "banana"
    }

#### `assert_content_not "<string>"`

Asserts that the output of the command executed by the `cmd` function does not
contain the content of `<string>`. If the output does, then the test function
will fail.

Example:

    describe "passing test"
    test_echo_function() {
      cmd "echo 'this will pass'"
      assert_content_not "banana"
    }
    describe "failing test"
    test_false_function() {
      cmd "echo 'this will fail'"
      assert_content_not "will fail"
    }

#### `assert_regex "<expression>"`

Asserts that the output of the command executed by the `cmd` function matches
the expression supplied in `<expression>`. If the output does, then the test
function will pass.

Example:

    describe "passing test"
    test_echo_function() {
      cmd "echo 'this will pass'"
      assert_regex '^this will pass$'
    }
    describe "failing test"
    test_false_function() {
      cmd "echo 'this will fail'"
      assert_regex '^will fail$'
    }

#### `assert_regex_not "<expression>"`

Asserts that the output of the command executed by the `cmd` function does not
match the expression supplied in `<expression>`. If the output does, then the
test function will fail.

Example:

    describe "passing test"
    test_echo_function() {
      cmd "echo 'this will pass'"
      assert_regex_not '^will pass$'
    }
    describe "failing test"
    test_false_function() {
      cmd "echo 'this will fail'"
      assert_regex_not '^this will fail$'
    }

#### Custom

Anything is permitted inside of a `testdummy` test function. There are no
requirements around using the builtin matchers or helpers.

Example:

    describe "passing test"
    test_echo_function() {
      echo "this will pass" | grep -q "pass"
      [ $? -eq 0 ]
    }
    describe "failing test"
    test_false_function() {
      echo "this will fail" | grep -q "pass"
      [ $? -eq 0 ]
    }
