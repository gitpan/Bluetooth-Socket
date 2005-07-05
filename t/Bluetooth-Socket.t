# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Bluetooth-Socket.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 1;
BEGIN { use_ok('Bluetooth::Socket') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

#my ($btobj, $btsock);

#$btsock = Bluetooth::Socket->new(BTPROTO_RFCOMM, "00:0E:6D:5F:9F:51", 10);
#$btsock->btwrite("NEMUX");
#$btsock->disconnect();

