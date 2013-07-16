use strict;
use warnings;

package Pod::Name;

use Pod::Escapes ();
use Unicode::Normalize ();

use Carp 'croak';

sub parse_from_file
{
    my ($class, $file, $out) = @_;

    open my $in, '<', $file
        or croak "can't open $file: $!";

    my $name = $class->extract_name($in);
    print { $out } "$name\n" if $name;
    return
}

sub extract_name
{
    my ($class, $in) = @_;
    my $encoding;

    binmode($in, ':crlf');

    while (<$in>) {
        next unless index($_, '=') == 0;
        #print STDERR "Entering POD...\n";
        do {{
            #print STDERR;
            /^=cut\s*$/ && last;
            /^=encoding\s+(\S+)/ && do {
                # FIXME stricter encoding regexp
                croak 'multiple =encoding' if $encoding;
                $encoding = $1;
                #print STDERR "Encoding: [$encoding]\n";
                binmode($in, ":encoding($encoding)");
                next;
            };
            /^=head1\s+NAME\s*$/ && do {
                #print STDERR "Entering NAME section...\n";

                # Skip empty lines
                while (<$in>) {
                    croak 'empty NAME section' if index($_, '=') == 0;
                    last unless /^$/;
                }
                chomp;
                my $name = $_;
                while (<$in>) {
                    last if /^$/;
                    chomp;
                    $name .= " $_";
                }
                $name =~ s!E<([^>]+)>! Pod::Escapes::e2char($1) !gse;
                $name = Unicode::Normalize::NFC($name);
                return $name;
            };
        }} while (<$in>);
        #print STDERR "Leaving POD...\n";
    }

    return
}

sub is_pageable { '' }

sub write_with_binmode { '' }

sub output_extension { 'txt' }

1;
__END__

=encoding utf-8

=head1 NAME

Pod::Name - Extract the NE<65>ME section of a POD document

=head1 SYNOPSIS

Get the title of the L<perlfunc> POD:

    $ perldoc -MPod::Name -T perlfunc

Get the title of all the .pm files in the current directory:

    $ perl -MPod::Name -E 'Pod::Name->parse_from_file($_, \*STDOUT) for <*.pm>'

=head1 DESCRIPTION

A simple L<POD|perlpod> formatter class that just extracts the content of
the C<NAME> section as text. L<POD Escapes|Pod::Escapes> and encoding of the
document are properly expanded contrary to most naive implementations of that
function.

The API is designed to be used also with L<perldoc> to ease writing of
one-liners.

=head1 METHODS

=head2 C<Pod::Name-E<gt>extract_name(*FHIN)>

C<*FHIN> is a read file handle of a document containing a POD document.

To extract from a POD document stored in a string, you can open a filehandle on
a reference to that string:

    my $name = do {
        open my $fh, '<', \$string;
        Pod::Name->extract_name($fh)
    };

=head2 C<Pod::Name-E<gt>parse_from_file($FILE, *FHOUT)>

This is the method used by L<perldoc> with C<-M>. This follows
the C<Pod::Perldoc> formatter (C<Pod::Perldoc::To*> classes) contract.

=over 4

=item *

C<$FILE> is a file path of a POD document.

=item *

C<*FHOUT> is the output file handle.

=back

=head1 AUTHOR

Olivier Mengué, L<mailto:dolmen@cpan.org>.

=head1 COPYRIGHT & LICENSE

Copyright E<copy> 2013 Olivier Mengué.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl 5 itself.

=cut

# vim:set et sw=4 sts=4:
