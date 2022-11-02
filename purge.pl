#!/usr/bin/perl

#purge.pl
use Time::localtime;
use strict;

my ($rootpath,$config,$to,$from,$subject,$msgBody,$msgSend);  # declare variable

sub timestamp {
  my $t = localtime;
  return sprintf( "%04d-%02d-%02d_%02d:%02d:%02d",
                  $t->year + 1900, $t->mon + 1, $t->mday,
                  $t->hour, $t->min, $t->sec );
}

sub sendMail {
  my $body = shift;

  if ($body ne "") {
    if ($to ne "" && $msgSend == 1) {
       open(MAIL, "|/usr/sbin/sendmail -t") or warn "WARN :  Could not find '/usr/sbin/sendmail': $!\n";

       # Email Header
       print MAIL "From: $from\n" or warn "WARN :  Could not write: $from:$!";
       print MAIL "To: $to\n" or warn "WARN :  Could not write: $$to:$!";
       print MAIL "Subject: $subject\n\n" or warn "WARN :  Could not write: $subject:$!";

       # Email Body
       print MAIL $body;
       close(MAIL);

       if ($? != 0) {
          print "WARN :  Failed to send mail!\n";
       } else {
          print "Email sent.\n";
       }
    } else {
       print "WARN :  Something wrong on receiver email or no email content!\n";
    }
  }
}

$SIG{__DIE__} = sub { &sendMail(@_); print @_; };

# Load configuration from purge.ini
eval `cat purge.ini` or die "Unable to open $config, ERROR :  $!\n";

print "-" x 35 . "\n";
print timestamp() . " Start Purge.pl\n";
#sleep 40;
print "-" x 35 . "\n";

my %configParamHash;                        # declare hash array

open ( _FH, $config ) or die "Unable to open $config, ERROR :  $!\n";   # read configuration file

while ( <_FH> ) {
    chomp;
    s/#.*//;                # ignore comments
    s/^\s+//;               # trim leading spaces if any
    s/\s+$//;               # trim leading spaces if any

    my $line =  $_;
    $line =~ s/\s+/;/g;

    next unless length;

    my ($key, $value) = split(/;/, $line, 2);
    $configParamHash{$key} = $value;
}
close _FH;

foreach my $path (keys %configParamHash) {
  my $fpath     = "$rootpath/$path";            # full path of the file / folder
  my $value     = $configParamHash{$path};      # value of minute / day
  my $AGE       = 0;                            # age in seconds
  my $now       = time();                       # get current time
  my $TIME;                                     # declare variable

  if (! -d $fpath) {
     print "WARN :  Directory $fpath not found!\n";
     $msgBody .= "WARN :  Directory $fpath not found!\n\n";
     next;
  }

  opendir (DIR, $fpath) or die "Path not found, ERROR :  $!\n";

  if ( $value =~ m/m$/ ) {
     $AGE = 60*substr($value,0, -1);
     $TIME = substr($value,0, -1) . " minutes";

     if ($TIME =~ /^[0-9,.E]+$/ || $TIME < 0) {
        print "WARN : Not a valid minute @ $path\n";
        $msgBody .="WARN : Not a valid minute @ $path\n\n";
        next;
     }
  } elsif ( $value =~ /^[+-]?\d+\z/ ) {
     $AGE = 60*60*24*$value;
     $TIME = "$value days";
  } else {
     print "WARN :  Not a valid timestamp @ $path\n";
     $msgBody .= "WARN :  Not a valid timestamp @ $path\n\n";
     next;
  }

  print timestamp() . " Delete files older than $TIME @ $path\n";

  while (my $file = readdir(DIR)) {
    # Use a regular expression to ignore files beginning with a period
    next if ($file =~ m/^\./);

    my $_file = "$fpath/$file";
    my @stats = stat($_file);

    if ($now-$stats[9] > $AGE) {
#sleep 40;
      next if ( ! -e $_file );
     #sleep 30;
      my $result = `rm -rf "$_file"`;
      if ($? != 0) {
         chomp $result;
         print "WARN : Cannot delete $_file $result\n";
         $msgBody .= "WARN : Cannot delete $_file $result\n\n";
      } else {
         print "$file deleted\n";
      }
    }
  }

  closedir(DIR);
}

sendMail ($msgBody);

print "-" x 35 . "\n";
print timestamp() . " End of Purge.pl\n";
print "-" x 35 . "\n";

exit 0;
