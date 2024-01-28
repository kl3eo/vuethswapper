#!/usr/bin/perl

use CGI;
use DBI;

use JSON;

my $scriptURL = CGI::url();
my $a = $ENV{'REMOTE_ADDR'};

my $ddositsuko = ddos_check($scriptURL);

my $par = 11;

if ($ddositsuko > $par) {
	exit if ($ddositsuko > $par+1); #important not to apply again
	my $applied = apply_firewall();
	
	if ($applied) {

		print STDERR "$a: DDOS firewall applied!\n";
	}
}

my $server = "127.0.0.1";
my $user = "postgres";
my $passwd = "postgres";
my $dbase = "cp";
my $port = 5432;

my $ret = "ERR";
my $nett = 0;

$query = new CGI;
my $sess = $query->cookie('session');

my $pass = defined($query->param('pass')) ? $query->param('pass') : '';
my $addr = defined($query->param('addr')) ? $query->param('addr') : '';

my $txhash = defined($query->param('txhash')) ? $query->param('txhash') : '';
my $to_acc_id = defined($query->param('acc_id')) ? $query->param('acc_id') : '';

my $rpc_server = defined($query->param('rpc_server')) ? $query->param('rpc_server') : '';

exit unless length($rpc_server);

my $rpc = $rpc_server eq "https://rpc.callisto.network" ? "callisto" : $rpc_server eq "https://wien.room-house.com" ? "expanse" : $rpc_server eq "https://paris.room-house.com" ? "expClassic" : '';

my $cmd = '';

my $doghouse = "shit";
my $denom1 = 1000000000000;
my $denom2 = 1000000000000000000;

$dbconn=DBI->connect("dbi:Pg:dbname=$dbase;port=$port;host=$server",$user, $passwd);

$dbconn->{LongReadLen} = 16384;


if (length($txhash) && $pass eq "lol") {

 my $curr = '';
 my $need_u = 1;
 
 eval {
  local $SIG{ALRM} = sub { my %hash = ('result' => 'ERR'); my $j = encode_json(\%hash); print $j; die "alarm\n" };
  alarm 5;

  if (-f "/tmp/bnum_w$rpc") {
    my $c = `date +%s`;
    my $c1 = `date +%s -r /tmp/bnum_w$rpc`;
    my $d = $c - $c1;
    $need_u = 0 if ($d < 10);
  }
  
  if ($need_u){
    $curr = `node /opt/nvme/web3/bnum.js --server=$rpc_server`;
    $curr =~ s/(\r|\n)//g;
    if ($curr =~ /^\d+$/) {
      system("echo $curr > /tmp/bnum_w$rpc");
    }
  } else {
    $curr = `cat /tmp/bnum_w$rpc`;
    $curr =~ s/(\r|\n)//g;
  }
  
  alarm 0;
 };
  
 if ($curr =~ /^\d+$/) {
  
  my $sel = "select bnum, last_addr, dest from vw_sessions where session = ?";
  my $result = $dbconn->prepare($sel);
  $result->execute($sess);
  my $listresult = $result->fetchall_arrayref;
  my $ntuples = $result->rows();
  my $last_num = ${${$listresult}[0]}[0];
  my $last_addr = ${${$listresult}[0]}[1];
  my $acc_id = ${${$listresult}[0]}[2];
  my $good = ($ntuples == 1 && ($curr == $last_num || $curr == $last_num + 1 || $curr == $last_num + 2 || $curr == $last_num + 3 || $curr == $last_num + 4 || $curr == $last_num + 5) && $last_addr eq $addr) ? 1 : 0;
print STDERR "Here curr is $curr, lastnum is $last_num, ntuples is $ntuples, sess is $sess, dest is $acc_id, good is $good!\n";	  
  if ($good) {
   $txhash =~ /^0x(.+)$/g;
	 my $th = $1;
print STDERR "Here th is $th, server is $rpc_server!\n";	
	 my $good_addr_sum = `node /opt/nvme/web3/get_tx_by_hash.js --th=$th --server=$rpc_server`;
	 $good_addr_sum =~ s/(\r|\n|"|\s)//g;
	 my ($good_addr, $sum) = split('#', $good_addr_sum);
	 my $l = length($good_addr);
print STDERR "Here length is $l, addr is $good_addr, last_addr is $last_addr!\n";
	 if (length($good_addr) == 42 && substr($good_addr,0,2) == '0x' && $last_addr eq $good_addr) {

		$cmd = "update vw_sessions set addr = ?, bnum = ?, sum = ?, last_addr = null where session = ?";
		my $result=$dbconn->prepare($cmd);
        	$result->execute($good_addr, $curr, $sum, $sess);
		
		#my $pi = $sum / $denom2;
		my $pi = $sum; my $repoA = $sum * 0.000000000000000001; #denom2
		
		#now report first part of eth->rhc swap to History
		my $str = "/usr/bin/curl --silent -X POST -H 'Content-Type: application/x-www-form-urlencoded' --data '&mode=i&pass=$doghouse&txs=$txhash&sumA=$repoA&sender=$good_addr' --connect-timeout 5 https://coins.room-house.com/cgi/resenter.pl";
print STDERR "Here curl: $str!\n";
		my $res = `$str`;
		
		my $pi_r = $rpc eq "expClassic" ? $pi * 1 : $pi * 20; my $repoB = $pi_r * 0.000000000000000001; #change ratio
		my $pi_ratio = $pi_r * 0.000001; # denom1/denom2 = 0.000001
		
		#now do sending with @polkadot/api
		$str = "node /opt/nvme/polka/send_sp.js --val=$pi_ratio --to=$acc_id";
print STDERR "Sending with $str!\n";
		
		my $bhash = `node /opt/nvme/polka/send_sp.js --val=$pi_ratio --to=$acc_id`;
		$bhash =~ s/(\r|\n)//g;
print STDERR "Here bhash is: $bhash!\n";
		#now report second part of eth->rhc swap to History, if txr is good
		my $str = length($bhash) ? "/usr/bin/curl --silent -X POST -H 'Content-Type: application/x-www-form-urlencoded' --data '&mode=u&pass=$doghouse&txs=$txhash&txr=$bhash&sumB=$repoB&receiver=$acc_id' --connect-timeout 5 https://coins.room-house.com/cgi/resenter.pl" : '';
print STDERR "Here curl2: $str!\n";
		my $res = `$str`;
		$ret = $bhash;
	 } else {
		$ret = "ERR";
	 }
#now check if metamask with expc setting
	 if ($ret eq "ERR" && $rpc_server eq "https://wien.room-house.com") {
		$rpc_server = "https://paris.room-house.com";
		$good_addr_sum = `node /opt/nvme/web3/get_tx_by_hash.js --th=$th --server=$rpc_server`;
	 	$good_addr_sum =~ s/(\r|\n|"|\s)//g;
	 	my ($good_addr, $sum) = split('#', $good_addr_sum);
	 	my $l = length($good_addr);
		print STDERR "Here length is $l, addr is $good_addr, last_addr is $last_addr!\n";
		if (length($good_addr) == 42 && substr($good_addr,0,2) == '0x' && $last_addr eq $good_addr) {

			$cmd = "update vw_sessions set addr = ?, bnum = ?, sum = ?, last_addr = null where session = ?";
			my $result=$dbconn->prepare($cmd);
        		$result->execute($good_addr, $curr, $sum, $sess);
		
			#my $pi = $sum / $denom2;
			my $pi = $sum; my $repoA = $sum * 0.000000000000000001; #denom2
		
		#now report first part of eth->rhc swap to History
			my $str = "/usr/bin/curl --silent -X POST -H 'Content-Type: application/x-www-form-urlencoded' --data '&mode=i&pass=$doghouse&txs=$txhash&sumA=$repoA&sender=$good_addr' --connect-timeout 5 https://coins.room-house.com/cgi/resenter.pl";
print STDERR "Here curl: $str!\n";
			my $res = `$str`;
		
			my $pi_r = $pi * 1; my $repoB = $pi_r * 0.000000000000000001; #change ratio
			my $pi_ratio = $pi_r * 0.000001; # denom1/denom2 = 0.000001
		
		#now do sending with @polkadot/api
print STDERR "Sending after Metamask with $str!\n";
			my $bhash = `node /opt/nvme/polka/send_sp.js --val=$pi_ratio --to=$acc_id`;
			$bhash =~ s/(\r|\n)//g;
print STDERR "Here bhash is: $bhash!\n";
			#now report second part of eth->rhc swap to History, if txr is good
			my $str = length($bhash) ? "/usr/bin/curl --silent -X POST -H 'Content-Type: application/x-www-form-urlencoded' --data '&mode=u&pass=$doghouse&txs=$txhash&txr=$bhash&sumB=$repoB&receiver=$acc_id' --connect-timeout 5 https://coins.room-house.com/cgi/resenter.pl" : '';
print STDERR "Here curl2: $str!\n";
			my $res = `$str`;
			$ret = $bhash;
			$nett = 1;
		} else {
			$ret = "ERR";
		}
	 }
  } else {
	   $ret = "ERR";
  }
 } else {
	   $ret = "ERR";
 }  

} elsif ($pass eq "lol") {

#check both blockchains are alive
 my $res = ''; my $res1 = '';
 my $need_u = 1; my $need_u1 = 1;
 
 eval {
  local $SIG{ALRM} = sub { my %hash = ('result' => 'ERR'); my $j = encode_json(\%hash); print $j; die "alarm\n" };
  alarm 5;

  if (-f "/tmp/bnum_w$rpc") {
    my $c = `date +%s`;
    my $c1 = `date +%s -r /tmp/bnum_w$rpc`;
    my $d = $c - $c1;
    $need_u = 0 if ($d < 10);
  }
  
  if ($need_u){
    $res = `node /opt/nvme/web3/bnum.js --server=$rpc_server`;
    $res =~ s/(\r|\n)//g;
    if ($res =~ /^\d+$/) {
      system("echo $res > /tmp/bnum_w$rpc");
    }
  } else {
    $res = `cat /tmp/bnum_w$rpc`;
    $res =~ s/(\r|\n)//g;
  }
  
  alarm 0;
 };

 eval {
  local $SIG{ALRM} = sub { my %hash = ('result' => 'ERR'); my $j = encode_json(\%hash); print $j; die "alarm\n" };
  alarm 5;

  if (-f "/tmp/bnum_p") {
    my $c = `date +%s`;
    my $c1 = `date +%s -r /tmp/bnum_p`;
    my $d = $c - $c1;
    $need_u = 0 if ($d < 10);
  }
  
  if ($need_u){
    $res1 = `node /opt/nvme/polka/bnum.js`;
    $res1 =~ s/(\r|\n)//g;
    if ($res1 =~ /^\d+$/) {
      system("echo $res1 > /tmp/bnum_p");
    }
  } else {
    $res1 = `cat /tmp/bnum_p`;
    $res1 =~ s/(\r|\n)//g;
  }
  
  alarm 0;
 };
    
 if ($res =~ /^\d+$/ && $res1 =~ /^\d+$/) {
	   $cmd = "update vw_sessions set bnum  = ?, last_addr = ?, dest = ? where session = ?";
        my $result=$dbconn->prepare($cmd);
        $result->execute($res, $addr, $to_acc_id, $sess);
	
	   $ret = "OK";
 } else {
	   $ret = "ERR";
 }
}

print "Content-type:application/json; charset=UTF-8\r\n\r\n";

my %hash = ('result' => $ret, 'net' => $nett);
$j = encode_json(\%hash);

#print STDERR "j is $j!\n";
print $j; #returning to fetch

$dbconn->disconnect;

exit;

sub ddos_check {

my $url = shift;

my $checklist = "/var/www/html/cp/handlers/checklist";

my $checkstr = $a."_".$url;
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

system("sudo /usr/local/bin/ip_apply $a");
print STDERR "sudo /usr/local/bin/ip_apply $a\n";

return 1;
}

