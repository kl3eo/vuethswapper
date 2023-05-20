#!/usr/bin/perl

use CGI;
use DBI;

use JSON;

my $addr = $ENV{'REMOTE_ADDR'};

my $server = "127.0.0.1";
my $user = "postgres";
my $passwd = "postgres";
my $dbase = "cp";
my $port = 5432;

$query = new CGI;

my $pass = defined($query->param('pass')) ? $query->param('pass') : '';

$dbconn=DBI->connect("dbi:Pg:dbname=$dbase;port=$port;host=$server",$user, $passwd);

$dbconn->{LongReadLen} = 16384;

print "Content-type:application/json; charset=UTF-8\r\n\r\n";

my $c = "SELECT ROW_TO_JSON(a) FROM (SELECT * FROM swaps order by id desc limit 100) a";

my $r=$dbconn->prepare($c);
$r->execute;

my $ls = $r->fetchall_arrayref; 
my $nt = $r->rows();

	print '[';	
	for (my $j = 0; $j < $nt; $j++) {
		print ${${$ls}[$j]}[0];
		print ',' unless ($j == $nt-1);
	}
	print ']';

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
