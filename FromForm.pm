package Class::DBI::FromForm;

use strict;
use vars qw/$VERSION @EXPORT/;
use base 'Exporter';

$VERSION = 0.03;

@EXPORT = qw/update_from_form create_from_form/;

=head1 NAME

Class::DBI::FromForm - Update Class::DBI data using Data::FormValidator

=head1 SYNOPSIS

  package Film;
  use Class::DBI::FromForm;
  use base 'Class::DBI';

  my $results = Data::FormValidator->check( ... );
  my $film = Film->retrieve('Fahrenheit 911');
  $film->update_from_form($results);

  my $new_film = Film->create_from_form($results);

=head1 DESCRIPTION

Create and update L<Class::DBI> objects from L<Data::FormValidator>.

=head2 METHODS

=head3 create_from_form

Create a new object.

=cut

sub create_from_form {
    my $class = shift;
    die "create_from_form can only be called as a class method" if ref $class;
    __PACKAGE__->_run_create( $class, @_ );
}

=head3 update_from_form

Update object.

=cut

sub update_from_form {
    my $self = shift;
    die "update_from_form cannot be called as a class method" unless ref $self;
    __PACKAGE__->_run_update( $self, @_ );
}

sub _run_create {
    my ( $me, $class, $results ) = @_;
    my $them = bless {}, $class;
    my $cols = {};
    foreach my $col ( $them->columns('All') ) {
        $cols->{$col} = $results->valid($col);
    }
    return $class->create($cols);
}

sub _run_update {
    my ( $me, $them, $results ) = @_;
    foreach my $col ( keys %{ $results->valid } ) {
        if ( $them->can($col) ) {
            next if $col eq $them->primary_column;
            my $val = $results->valid($col);
            $them->$col($val);
        }
    }
    $them->update;
    return 1;
}

=head1 SEE ALSO

L<Class::DBI>, L<Class::DBI::FromCGI>, L<Data::FormValidator>

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
