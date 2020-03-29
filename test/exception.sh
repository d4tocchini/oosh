
#!/usr/local/bin/zsh

# Throw an exception.
# The first argument is a string giving the exception.  Other arguments
# are ignored.
#
# This is designed to be called somewhere inside a "try-block", i.e.
# some code of the form:
#   {
#     # try-block
#   } always {
#     # always-block
#   }
# although as normal with exceptions it might be hidden deep inside
# other code.  Note, however, that it must be code running within the
# current shell; with shells, unlike other languages, it is quite easy
# to miss points at which the shell forks.
#
# If there is nothing to catch an exception, this behaves like any
# other shell error, aborting to the command prompt or abandoning a
# script.
throw() {
  EXCEPTION="$1"
  if (( TRY_BLOCK_ERROR == 0 )); then
    # We are throwing an exception from the middle of an always-block.
    # We can do this by restoring the error status from the try-block.
    # (I am not convinced I ever intended this to work, but it does...)
    (( TRY_BLOCK_ERROR = 1 ))
  fi
  # Raise an error, but don't show an error message.
  # This is a bit of a hack.  (Surprised?)
  { ${*ERROR*} } 2>/dev/null
}

# grrr.... if this is rerun, catch mustn't be an alias when we define
# it as a function...
unalias catch 2>/dev/null
# Catch an exception.  Returns 0 if the exception in question was caught.
# The first argument gives the exception to catch, which may be a
# pattern.
# This must be within an always-block.  A typical set of handlers looks
# like:
#   {
#     # try block; something here throws exceptions
#   } always {
#      if catch MyExcept; then
#         # Handler code goes here.
#         print Handling exception MyExcept
#      elif catch *; then
#         # This is the way to implement a catch-all.
#         print Handling any other exception
#      fi
#   }
# As with other languages, exceptions do not need to be handled
# within an always block and may propagate to a handler further up the
# call chain.
#
# It is possible to throw an exception from within the handler by
# using "throw".
#
# The shell variable $CAUGHT is set to the last exception caught,
# which is useful if the argument to "catch" was a pattern.
catch() {
  if [[ $TRY_BLOCK_ERROR -gt 0 && $EXCEPTION = ${~1} ]]; then
    (( TRY_BLOCK_ERROR = 0 ))
    CAUGHT="$EXCEPTION"
    unset EXCEPTION
    return 0
  fi

  return 1
}
# Never use globbing with "catch".
alias catch="noglob catch"


##
# Test code.  First, a set of functions that may throw exceptions.
##
# Throw an exception handled by name further up.
try_throw_a_wobbly() {
  print Before I threw a wobbly
  throw AWobbly
  print After I threw a wobbly
}

# Throw an exception not handled by name.
try_throw_up() {
  print Before I threw up
  throw up
  print After I threw up
}

# A function that doesn't throw an exception.
try_normal() {
  print This is a well-behaved function.
}

# A function which causes a run-time error without using "throw"
try_error() {
  print About to cause an error...
  : ${*This is bogus syntax*}
}

# A function that causes the handler to rethrow the exception.
try_rethrow() {
  print Calling code should rethrow this...
  throw rethrow
}

# Outer try-block to catch rethrown exceptions.
{
  # Loop over the test functions.
  for func in try_throw_a_wobbly try_throw_up try_normal \
	      try_error try_rethrow; do
    {
      print "** Running function $func **"

      $func
    } always {
      if catch AWobbly; then
	# This exception is caught by name.
	print "always: Caught AWobbly"
      elif catch rethrow; then
	# This exception causes an immediate rethrow (we
	# don't execute the rest of the always block after the throw)
	# This is just an illustration; we could just leave this
	# unhandled here.
	print "always: Rethrowing rethrow..."
	throw rethrow
      elif catch ''; then
	# If there's no exception name, it could be any error.
	print "No exception, probably a shell error."
      elif catch *; then
	# Catch-all.
	print "always: Caught unhandled exception $CAUGHT"
      else
	# No exception.
	print "always: No exception."
      fi

      print "** End of handling for function $func **"
    }
  done
} always {
  if catch *; then
    print "outer handler: caught a $CAUGHT."
  fi
}

print End of test.
# End