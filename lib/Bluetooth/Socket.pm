package Bluetooth::Socket;

use 5.008005;
use strict;
use warnings;

use Socket qw(:all);
use Carp;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT = qw(AF_BLUETOOTH PF_BLUETOOTH BTPROTO_RFCOMM BTPROTO_L2CAP BTPROTO_HCI BTPROTO_SCO BTPROTO_BNEP BTPROTO_CMTP BTPROTO_HIDP BTPROTO_AVDTP SOL_HCI SOL_L2CAP SOL_SCO SOL_RFCOMM BT_CONNECTED BT_OPEN BT_BOUND BT_LISTEN BT_CONNECT2 BT_DISCONN BT_CLOSED SOCK_STREAM SOCK_RAW);

our %EXPORT_TAGS = ( 
		     'all' => \@EXPORT,
		     'rfcomm' => [ qw() ]  
		     );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Bluetooth::Socket', $VERSION);

use constant AF_BLUETOOTH=>31;
use constant PF_BLUETOOTH=>AF_BLUETOOTH;

use constant BTPROTO_L2CAP=>0;
use constant BTPROTO_HCI=>1;
use constant BTPROTO_SCO=>2;
use constant BTPROTO_RFCOMM=>3;
use constant BTPROTO_BNEP=>4;
use constant BTPROTO_CMTP=>5;
use constant BTPROTO_HIDP=>6;
use constant BTPROTO_AVDTP=>7;

use constant SOL_HCI=>0;
use constant SOL_L2CAP=>6;
use constant SOL_SCO=>17;
use constant SOL_RFCOMM=>18;

use constant BT_CONNECTED=>1; # Equal to TCP_ESTABLISHED to make net code happy
use constant BT_OPEN=>2;
use constant BT_BOUND=>3;
use constant BT_LISTEN=>4;
use constant BT_CONNECT=>5;
use constant BT_CONNECT2=>6;
use constant BT_CONFIG=>7;
use constant BT_DISCONN=>8;
use constant BT_CLOSED=>9;

#PROTO, ADDRESS, CHANNEL
###########################
sub new {
    my $self = bless {},(ref($_[0])||$_[0]);
    my $sock = undef;

    if (@_ >= 4) {
	if ($_[1] == BTPROTO_RFCOMM) {
	
	    if (($sock = $self->socket(AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM)) <= 0) {
		croak("socket() error");
	    }
	    
	    if ($self->check_address($_[2])) {
		
		if ($self->bind($sock, "00:00:00:00:00:00")) {
		    
		    if (($_[3]>1 || $_[3]<30)) {
			
			if (($self->connect($sock, $_[2], $_[3]) < 0)) {
			    croak("Socket Closed");
			}
			
		    } else {
			croak("Wrong Channel");
		    }
		    
		} else {
		    croak("Wrong Address ( XX:XX:XX:XX:XX:XX )");
		}
	    }
	    
	} else {
	    croak("Wrong Type");
	}
    }

    $self->{_btsock} = $sock;
    return $self;
}

sub socket {
    shift;
    my ($domain, $type, $proto) = @_;
    return Bluetooth::Socket::i_socket($domain, $type, $proto);
}

sub bind {
    my ($self, $socket, $address) = @_;
#$address is unused now...
    return Bluetooth::Socket::i_bind($socket, $address);
}

sub connect {
    my ($self, $socket, $address, $chan) = @_;
    return Bluetooth::Socket::i_connect($socket, $address, $chan);
}

sub disconnect { 
    my $self = shift;
    return $self->btclose($self->{_btsock});
}

sub btclose {
    shift;
    my $sock = shift;
    return Bluetooth::Socket::i_close($sock); 
}

sub btwrite {
    my ($self, $data) = @_;
    if (exists $self->{_btsock}) {
	my $len = 0;
	do {use bytes; $len = length($data)};
	return Bluetooth::Socket::i_write($self->{_btsock}, $data, $len, 0);
    } else {
	croak("No Socket defined");
    }
}

sub get_socket {
    my $self = shift;
    ((exists $self->{_btsock}) ? $self->{_btsock} : undef);
}

sub check_address {
    shift;
    my $address = shift;
    ($address =~ m/^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$/) ? 1 : 0;
}

1;
__END__

=head1 NAME

Bluetooth::Socket - Perl extension for Bluetooth library 

=head1 SYNOPSIS

  use Bluetooth::Socket;

my ($btobj, $btsock);

#example 00:0E:6D:5F:91:31

my $address = $ARGV[0];

$btsock = Bluetooth::Socket->new(BTPROTO_RFCOMM, $address, 10);

$btsock->btwrite("NEMUX");

$btsock->disconnect();

exit 0;

## Bluetooth Channel Scanner could be something like this i suppose 

my $address = $ARGV[0];

$btobj = new Bluetooth::Socket;

if ($btobj->check_address($address)) {

    for ($chan = 1; $chan <= 30; $chan++) {

        if ($btsock = $btobj->socket(AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM) > 0) {

            $btobj->bind($btsock, "00:00:00:00:00:00");

            if (($btobj->connect($btsock, $address, $chan)) < 0) {
                print $chan . " Closed\n";
            } else {
                print $chan . " Open\n";
            }

            $btobj->btclose($btsock);

        } else {
            print "Unable to crate bluetooth socket for channel $chan\n";
        }
    }
}

exit 0;

=head1 DESCRIPTION

TODO

=head2 EXPORT

TODO

=head1 SEE ALSO

::TODO::

USE IT FOR TEST ONLY! 

Contact me if you intend to contribute to the development or for info about it.

::TODO::

=head1 AUTHOR

Marco Romano, E<lt>nemux@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Marco Romano

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.


=cut
