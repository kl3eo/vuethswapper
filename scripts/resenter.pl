#!/usr/bin/perl

use CGI;
use DBI;

use JSON;

my $addr = $ENV{'REMOTE_ADDR'};

my $scriptURL = CGI::url();

my $ddositsuko = ddos_check($scriptURL);

my $par = 11;

if ($ddositsuko > $par) {
	exit if ($ddositsuko > $par+1); #important not to apply again
	my $applied = apply_firewall();
	
	if ($applied) {

		print STDERR "$addr: DDOS firewall applied!\n";
	}
}

my $server = "127.0.0.1";
my $user = "postgres";
my $passwd = "postgres";
my $dbase = "cp";
my $port = 5432;

my $ret = "ERR";

$query = new CGI;

my $pass = defined($query->param('pass')) ? $query->param('pass') : '';
my $tx_s = defined($query->param('txs')) ? $query->param('txs') : '';
my $tx_r = defined($query->param('txr')) ? $query->param('txr') : '';
my $sender = defined($query->param('sender')) ? $query->param('sender') : '';
my $receiver = defined($query->param('receiver')) ? $query->param('receiver') : '';
my $sumA = defined($query->param('sumA')) ? $query->param('sumA') : 0;
my $sumB = defined($query->param('sumB')) ? $query->param('sumB') : 0;
my $mode = defined($query->param('mode')) ? $query->param('mode') : 'i';

$dbconn=DBI->connect("dbi:Pg:dbname=$dbase;port=$port;host=$server",$user, $passwd);

$dbconn->{LongReadLen} = 16384;

print "Content-type:application/json; charset=UTF-8\r\n\r\n";

#CREATE TABLE swaps (id serial, tx_sender text, tx_receiver text, sumA numeric, sumB numeric, sender text, receiver text, dtmA timestamp, dtmB timestamp, ip text);
if ($pass eq "lol") {
  if ($mode eq 'i') {
        my $cmd = "insert into swaps (tx_sender, sender, sumA, ip, dtmA) values (?, ?, ?, ?, current_timestamp)";
	my $result=$dbconn->prepare($cmd);
	$result->execute($tx_s, $sender, $sumA, $addr);

        $ret = "OK";
  } elsif ($mode eq 'u') {
        my $cmd = "update swaps set receiver  = ?, sumB = ?, tx_receiver = ?, dtmB = current_timestamp where tx_sender = ?";
	my $result=$dbconn->prepare($cmd);
	$result->execute($receiver, $sumB, $tx_r, $tx_s);

        $ret = "OK";
  }
}

my %hash = ('result' => $ret);
$j = encode_json(\%hash);
print $j; #returning to fetch

$dbconn->disconnect;

exit

sub ddos_check {

my $url = shift;

my $checklist = "/var/www/html/cp/handlers/checklist";

my $checkstr = $addr."_".$url;
open (IN,$checklist);
my $counter = 0;
while (!eof(IN)) {
	my $q = readline (*IN); $q =~ s/\n//g;
	$counter++ if ($q eq $checkstr);
}
   
close (IN);

return $counter;
}

sub apply_firewall {

system("sudo /usr/local/bin/ip_apply $addr");
print STDERR "sudo /usr/local/bin/ip_apply $addr\n";

return 1;
}
