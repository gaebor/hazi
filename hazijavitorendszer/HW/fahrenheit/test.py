def _eval(_input, _output, _expected, _exception, _expected_exception):
  return abs(_expected - _output) < 0.001 and _exception is None
