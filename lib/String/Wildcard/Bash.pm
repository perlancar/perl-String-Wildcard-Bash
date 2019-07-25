package String::Wildcard::Bash;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       $RE_WILDCARD_BASH
                       contains_wildcard
                       convert_wildcard_to_sql
               );

# note: order is important here, brace encloses the other
our $RE_WILDCARD_BASH =
    qr(
          # non-escaped brace expression, with at least one comma
          (?P<bash_brace>
              (?<!\\)(?P<bash_brace_slashes>\\\\)*\{
              (?:           \\\\ | \\\{ | \\\} | [^\\\{\}] )*
              (?:, (?:  \\\\ | \\\{ | \\\} | [^\\\{\}] )* )+
              (?<!\\)(?:\\\\)*\}
          )
      |
          # non-escaped brace expression, to catch * or ? or [...] inside so
          # they don't go to below pattern, because bash doesn't consider them
          # wildcards, e.g. '/{et?,us*}' expands to '/etc /usr', but '/{et?}'
          # doesn't expand at all to /etc.
          (?P<literal_braceSingleElement>
              (?<!\\)(?:\\\\)*\{
              (?:           \\\\ | \\\{ | \\\} | [^\\\{\}] )*
              (?<!\\)(?:\\\\)*\}
          )
      |
          (?P<bash_class>
              # non-empty, non-escaped character class
              (?<!\\)(?:\\\\)*\[
              (?:  \\\\ | \\\[ | \\\] | [^\\\[\]] )+
              (?<!\\)(?:\\\\)*\]
          )
      |
          (?P<bash_joker>
              # non-escaped * and ?
              (?<!\\)(?:\\\\)*[*?]
          )
      |
          (?P<sql_joker>
              # non-escaped % and ?
              (?<!\\)(?:\\\\)*[%_]
          )
      |
          (?P<literal>
              [^\\\[\]\{\}*?%_]+
          |
              .+?
          )
      )ox;

sub contains_wildcard {
    my $str = shift;

    while ($str =~ /$RE_WILDCARD_BASH/go) {
        my %m = %+;
        return 1 if $m{bash_brace} || $m{bash_class} || $m{bash_joker};
    }
    0;
}

sub convert_wildcard_to_sql {
    my $str = shift;

    $str =~ s/$RE_WILDCARD_BASH/
        if ($+{bash_joker}) {
            if ($+{bash_joker} eq '*') {
                "%";
            } else {
                "_";
            }
        } elsif ($+{sql_joker}) {
            "\\$+{sql_joker}";
        } else {
            $&;
        }
    /eg;

    $str;
}

1;
# ABSTRACT: Bash wildcard string routines

=for Pod::Coverage ^(qqquote)$

=head1 SYNOPSIS

    use String::Wildcard::Bash qw(
        $RE_WILDCARD_BASH
        contains_wildcard
        convert_wildcard_to_sql
    );

    say 1 if contains_wildcard(""));      # -> 0
    say 1 if contains_wildcard("ab*"));   # -> 1
    say 1 if contains_wildcard("ab\\*")); # -> 0

    say convert_wildcard_to_sql("foo*");  # -> "foo%"


=head1 DESCRIPTION


=head1 FUNCTIONS

=head2 contains_wildcard($str) => bool

Return true if C<$str> contains wildcard pattern. Wildcard patterns include C<*>
(meaning zero or more characters), C<?> (exactly one character), C<[...]>
(character class), C<{...,}> (brace expansion). Can handle escaped/backslash
(e.g. C<foo\*> does not contain wildcard, it's C<foo> followed by a literal
asterisk C<*>).

Aside from wildcard, bash does other types of expansions/substitutions too, but
these are not considered wildcard. These include tilde expansion (e.g. C<~>
becomes C</home/alice>), parameter and variable expansion (e.g. C<$0> and
C<$HOME>), arithmetic expression (e.g. C<$[1+2]>), history (C<!>), and so on.

Although this module has 'Bash' in its name, this set of wildcards should be
applicable to other Unix shells. Haven't checked completely though.

=head2 convert_wildcard_to_sql($str) => str

Convert bash wildcard to SQL. This includes:

=over

=item * converting unescaped C<*> to C<%>

=item * converting unescaped C<?> to C<_>

=item * escaping unescaped C<%>

=item * escaping unescaped C<_>

=back

Unsupported constructs currently will be passed as-is.


=head1 SEE ALSO

L<Regexp::Wildcards> to convert a string with wildcard pattern to equivalent
regexp pattern. Can handle Unix wildcards as well as SQL and DOS/Win32. As of
this writing (v1.05), it does not handle character class (C<[...]>) and
interprets brace expansion differently than bash.

Other C<String::Wildcard::*> modules.

=cut
