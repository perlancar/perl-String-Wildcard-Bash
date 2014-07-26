#!perl -T

use 5.010;
use strict;
use warnings;

use String::Wildcard::Bash qw(contains_wildcard);
use Test::More 0.98;

subtest contains_wildcard => sub {
    subtest "none" => sub {
        ok(!contains_wildcard(""));
        ok(!contains_wildcard("abc"));
    };

    subtest "*" => sub {
        ok( contains_wildcard("ab*"));
        ok(!contains_wildcard("ab\\*"));
        ok( contains_wildcard("ab\\\\*"));
    };

    subtest "?" => sub {
        ok( contains_wildcard("ab?"));
        ok(!contains_wildcard("ab\\?"));
        ok( contains_wildcard("ab\\\\?"));
    };

    subtest "character class" => sub {
        ok( contains_wildcard("ab[cd]"));
        ok(!contains_wildcard("ab[cd"));
        ok(!contains_wildcard("ab\\[cd]"));
        ok( contains_wildcard("ab\\\\[cd]"));
        ok(!contains_wildcard("ab[cd\\]"));
        ok( contains_wildcard("ab[cd\\\\]"));
    };

    subtest "brace expansion" => sub {
        ok(!contains_wildcard("{}"));   # need at least a comma
        ok(!contains_wildcard("{a}"));  # ditto
        ok(!contains_wildcard("{a*}")); # ditto
        ok( contains_wildcard("{,}"));
        ok( contains_wildcard("{a,}"));
        ok( contains_wildcard("{a*,}"));
        ok( contains_wildcard("{a*,b}"));
        ok( contains_wildcard("{a*,b[a]}"));
        ok(!contains_wildcard("\\{a,b}"));
        ok( contains_wildcard("\\{a*,b}")); # because of * is not inside brace
        ok( contains_wildcard("\\\\{a*,b}"));
        ok(!contains_wildcard("{a,b\\}"));
        ok( contains_wildcard("{a*,b\\}")); # because of * is not inside brace
        ok( contains_wildcard("{a*,b\\\\}"));
    };

    subtest "other non-wildcard" => sub {
        ok(!contains_wildcard("~/a"));
        ok(!contains_wildcard("\$a"));
    };
};

DONE_TESTING:
done_testing();
