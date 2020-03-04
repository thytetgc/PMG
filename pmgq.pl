#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Std;
use Net::SMTP;
use JSON;

use PMG::RuleDB;
use PMG::Quarantine;

binmode(STDOUT, "encoding(UTF-8)");

my $tmpdir = "/tmp/";
my %options;

sub myhelp{
    print "pmgqd -f <from> -r <rcpt> -u <subject> -a <action>\n";
    print "\taction is mandatory : count/list/remove\n";
    print "\tit needs at least one : sender, rcpt or subject ; you can mix several\n";
    exit(2);
}

sub delete_quarantined_mail {
    my ($id) = @_;

    my ($cid, $rid, $tid) = $id =~ m/^C(\d+)R(\d+)T(\d+)$/;
    $cid = int($cid);
    $rid = int($rid);
    $tid = int($tid);

    my $dbh = PMG::DBTools::open_ruledb();

    my $ref = PMG::DBTools::load_mail_data($dbh, $cid, $rid, $tid);

    PMG::Quarantine::delete_quarantined_mail($dbh, $ref);
}

$options{f} = '';
$options{r} = '';
$options{s} = '';
$options{a} = '';


getopts('f:r:s:a:',\%options);

my $from = $options{f};
my $rcpt = $options{r};
my $subject = $options{s};
my $action = lc($options{a});

# List the spam rcpt since when ?
my $endtime = time(); # now
my $starttime = $endtime - (7 * 24 * 60 * 60) ; # 7 seven days before now !

if($action ne 'count' && $action ne 'list' && $action ne 'remove'){
        myhelp();
}

if($from eq '' && $rcpt eq '' && $subject eq ''){
        myhelp();
}

#print("action = ".$action.", from = ".$from.", rcpt = ".$rcpt.", subject = ".$subject."\n");

my $spamusers = $tmpdir."/spamusers.json";

#print("/usr/bin/pmgsh get /quarantine/spamusers --starttime $starttime --endtime $endtime >".$spamusers." 2>/dev/null\n");
my $users = qx(/usr/bin/pmgsh get /quarantine/spamusers --starttime $starttime --endtime $endtime 2>/dev/null);
my $data = decode_json($users);

#Global counter
my $ecount = 0;

foreach my $u (@$data){
    my $result = 1;
    if ($rcpt ne '') {
        if($u->{'mail'} =~ /^$rcpt$/){
            $result = 1;
        } else {
            $result = 0;
        }
    }
    if($result == 1){
#       print("Mail: ".$u->{'mail'}."\n");

        my $jspam= qx(/usr/bin/pmgsh get /quarantine/spam  --starttime $starttime --endtime $endtime -pmail $u->{'mail'} 2>/dev/null);
        my $emails = decode_json($jspam);
        foreach my $em (@$emails){
            $result = 1;
            if ($from ne '') {
                if($em->{'envelope_sender'} =~ /^$from$/){
                    $result = 1;
                } else {
                    $result = 0;
                }
            }
            if ($result == 1 && $subject ne '') {
                if($em->{'subject'} =~ /$subject/){
                    $result = 1;
                } else {
                    $result = 0;
                }
            }
            if ($result == 1){
                $ecount++;
                if($action eq 'list'){
                        print("ID: ".$em->{'id'}." - From: ".$u->{'mail'}." - Sender: ".$em->{'envelope_sender'}." - Subject: ".$em->{'subject'}."\n");
                } elsif($action eq 'remove'){
                    print("REMOVE => ID: ".$em->{'id'}." - From: ".$u->{'mail'}." - Sender: ".$em->{'envelope_sender'}." - Subject: ".$em->{'subject'}."\n");
                    delete_quarantined_mail($em->{'id'});
                }
            }
        }
    }
}

print("Total of $ecount quarantined mails\n");
