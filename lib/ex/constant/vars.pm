package ex::constant::vars;

use 5.006;
use strict;
use warnings;
use Carp;

require Exporter;

our @ISA        = qw(
                      Exporter
                      ex::constant::vars::scalar
                      ex::constant::vars::array
                      ex::constant::vars::hash
                    );
our @EXPORT_OK  = qw( const SCALAR ARRAY HASH );
our $VERSION    = '0.02';

sub const {
  my $type   = shift;
  my @values = splice @_, 1;
  if ( $type eq 'scalar' ) {
    return tie ${$_[0]}, __PACKAGE__ . '::' . $type, @values;
  } elsif ( $type eq 'array' ) {
    return tie @{$_[0]}, __PACKAGE__ . '::' . $type, @values;
  } else {
    return tie %{$_[0]}, __PACKAGE__ . '::' . $type, @values;
  }
}

sub SCALAR (\$$) { 'scalar', @_ }
sub ARRAY  (\@@) { 'array',  @_ }
sub HASH   (\%%) { 'hash',   @_ }

sub import {
  my $self = shift;
  return unless @_;
  if ( @_ == 1 && $_[0] eq 'const' ) {
    $self->export_to_level( 1, $self, @EXPORT_OK );
  } else {
    my %variables = @_;
    my $caller    = caller( 0 );
    while ( my( $var, $val ) = each %variables ) {
      my( $prefix, $name ) = split //, $var, 2;
      croak "'$var' not a valid variable name" unless $prefix =~ /^[\$\@\%]$/;
      if ( $prefix eq '$' ) {
        no strict 'refs';
        *{__PACKAGE__ . "::variables::$name"} = \$val;
        *{"${caller}::$name"} = \${__PACKAGE__ . "::variables::$name"};
        const SCALAR ${"${caller}::$name"}, $val;
      } elsif ( $prefix eq '@' ) {
        no strict 'refs';
        *{__PACKAGE__ . "::variables::$name"} = \@{$val};
        *{"${caller}::$name"} = \@{__PACKAGE__ . "::variables::$name"};
        const ARRAY @{"${caller}::$name"}, @{$val};
      } elsif ( $prefix eq '%' ) {
        no strict 'refs';
        *{__PACKAGE__ . "::variables::$name"} = \%{$val};
        *{"${caller}::$name"} = \%{__PACKAGE__ . "::variables::$name"};
        const HASH %{"${caller}::$name"}, %{$val};
      }
    }
  }
}


package ex::constant::vars::scalar;
use Carp;
$Carp::CarpLevel = 1;
sub TIESCALAR { shift; bless \(my $scalar = shift), __PACKAGE__ }
sub FETCH     { ${$_[0]} }
sub STORE     { croak "Modification of a read-only value attempted" }


package ex::constant::vars::array;
use Carp;
$Carp::CarpLevel = 1;
sub TIEARRAY  { shift; bless $_=\@_, __PACKAGE__ }
sub FETCH     { $_[0]->[$_[1]] }
sub FETCHSIZE { @{$_[0]} }
sub EXISTS    { exists $_[0]->[$_[1]] }
sub STORE     { croak "Modification of a read-only value attempted" }
*CLEAR   = *EXTEND = *POP       = *PUSH   = *SHIFT =
*UNSHIFT = *SPLICE = *STORESIZE = *DELETE = \*STORE;


package ex::constant::vars::hash;
use Carp;
$Carp::CarpLevel = 1;
sub TIEHASH  { bless {@_[1...$#_]}, __PACKAGE__ }
sub FETCH    { $_[0]->{$_[1]} }
sub FIRSTKEY { keys %{$_[0]}; each %{$_[0]} }
sub NEXTKEY  { each %{$_[0]} }
sub EXISTS   { exists $_[0]->{$_[1]} }
sub STORE    { croak "Modification of a read-only value attempted" }
*CLEAR = *DELETE = \*STORE;

1;

__END__

# Below is stub documentation for your module. You better edit it!

=head1 NAME

ex::constant::vars - Perl pragma to create readonly variables

=head1 SYNOPSIS

Using the C<tie()> interface:

  use ex::constant::vars;
  tie my $pi,     'ex::constant::vars', 4 * atan2( 1, 1 );
  tie my @family, 'ex::constant::vars', qw( John Jane );
  tie my %age,    'ex::constant::vars', John => 27,
                                        Jane => 'Back off!';

Using the C<const()> function:

  use ex::constant::vars 'const';
  const SCALAR my $pi,     4 * atan2( 1, 1 );
  const ARRAY  my @family, qw( John Jane );
  const HASH   my %age,    John => 27, Jane => 'Back off!';

Using C<import()> for compile time creation:

  use ex::constant::vars (
    '$pi'     => 4 * atan2( 1, 1 ),
    '@family' => [ qw( John Jane ) ],
    '%age'    => { John => 27, Jane => 'Back off!' },
  );

=head1 DESCRIPTION

This package allows you to create readonly variables.

=head2 Implementation

This package C<tie()>s variables to a class that disables any
attempt to modify the variables data.

=over 4

=item Constant Scalars

You can store a value in the scalar when it's declared as readonly.

C<chomp> and C<chop> are effectivley disabled for a readonly scalar.

=item Constant Arrays

You can store a list in the array when it's declared as readonly.

C<pop>, C<push>, C<shift>, C<splice> and C<unshift> are effictivley
disabled for a readonly array.

=item Constant Hashes

You can store a record set in the hash when it's declared as readonly.

C<delete> is effictivley disabled for a readonly hash.

=back

=head2 The C<const()> function

When the C<const()> function is imported, so is C<SCALAR()>, C<ARRAY()>
and C<HASH()>.  These functions allow C<const()> to know what type of
variable it's dealing with.  C<const()> returns the C<tied()> object of
the variable.

=head1 Caveats

This implementation can be slow, by nature.  C<tie()>ing variables
to a class is going to be slow.  If you need the same functionality,
and much less of a speed hit, take a look at this:
L<http://www.xray.mpe.mpg.de/mailing-lists/perl5-porters/2000-05/msg00777.html>

The fastest method of declaring readonly variables with this pakcage
is to C<tie()> your variables.  After that, using the C<const()>
function.  And lastly, using C<import()> at compile time.

To demonstrate the speed differences:

  use Benchmark; 
  timethese 500000, {
    constvars => sub {
                      tie my $x, 'ex::constant::vars', 'test';
                      my $y = $x;
                     },
    standard  => sub {
                      my $x = 'test';
                      my $y = $x;
                     },
  };

Produces:

 constvars: 24 wallclock secs (22.55 usr +  0.05 sys = 22.60 CPU) @ 22123.89/s (n=500000)
  standard:  2 wallclock secs ( 1.12 usr +  0.00 sys =  1.12 CPU) @ 447761.19/s (n=500000)

=head2 Why did you write this?

I wrote it because I believe that it is I<a> solution.  I also believe
that new ways of implementing this are comming in one form or another.

=head1 AUTHOR

Casey R. Tweten, <F<crt@kiski.net>>

=head1 SEE ALSO

L<perl>, L<perltie>, L<constant>.

=head1 COPYRIGHT

Copyright (c) 1995 Casey R. Tweten. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
