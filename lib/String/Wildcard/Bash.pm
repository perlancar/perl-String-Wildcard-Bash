package String::Wildcard::Bash;

use 5.010001;
use strict;
use warnings;

# VERSION

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       contains_wildcard
               );

# note: order is important here, brace encloses the other
my $re1 =
    qr/
          # non-escaped brace expression, with at least one comma
          (?P<brace>
              (?<!\\)(?:\\\\)*\{
              (?:           \\\\ | \\\{ | \\\} | [^\\\{\}] )*
              (?:, (?:  \\\\ | \\\{ | \\\} | [^\\\{\}] )* )+
              (?<!\\)(?:\\\\)*\}
          )
      |
          # non-escaped brace expression, to catch * and ? inside so it does not
          # go to joker
          (?P<braceno>
              (?<!\\)(?:\\\\)*\{
              (?:           \\\\ | \\\{ | \\\} | [^\\\{\}] )*
              (?<!\\)(?:\\\\)*\}
          )
      |
          (?P<class>
              # non-empty, non-escaped character class
              (?<!\\)(?:\\\\)*\[
              (?:  \\\\ | \\\[ | \\\] | [^\\\[\]] )+
              (?<!\\)(?:\\\\)*\]
          )
      |
          (?P<joker>
              # non-escaped * and ?
              (?<!\\)(?:\\\\)*[*?]
          )
      /ox;

sub contains_wildcard {
    my $str = shift;

    while ($str =~ /$re1/go) {
        my %m = %+;
        return 1 if $m{brace} || $m{class} || $m{joker};
    }
    0;
}

1;
# ABSTRACT: Bash wildcard string routines

=for Pod::Coverage ^(qqquote)$

=head1 SYNOPSIS

    use String::Wildcard::Bash qw(contains_wildcard);

    say 1 if contains_wildcard(""));      # -> 0
    say 1 if contains_wildcard("ab*"));   # -> 1
    say 1 if contains_wildcard("ab\\*")); # -> 0


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


=head1 TODO

Function to parse string and return all the wildcards (with their types,
positions, ...)

Function to strip wildcards from string.

Function to convert to other types of wildcards (and/or to check whether it can
be represented with other types of wildcards).

Function to convert a regex pattern to equivalent wildcard?


=head1 SEE ALSO

L<Regexp::Wildcards> to convert a string with wildcard pattern to equivalent
regexp pattern. Can handle Unix wildcards as well as SQL and DOS/Win32. As of
this writing (v1.05), it does not handle character class (C<[...]>) and
interprets brace expansion differently than bash.

Other C<String::Wildcard::*> modules.

=cut
