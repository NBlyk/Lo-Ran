function loran_assert_throws(action)
%LORAN_ASSERT_THROWS Shared malformed-input assertion for code-only unit tests.
failed = false;
try, action(); catch, failed = true; end
assert(failed,'LoRan:ExpectedFailure','Malformed input was unexpectedly accepted.');
end
