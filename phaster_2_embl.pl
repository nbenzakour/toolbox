#!/usr/bin/perl -w T

# Copyright 2017 Nouri BEN ZAKOUR Licensed under the
# Educational Community License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may
# obtain a copy of the License at
#
#      http://www.osedu.org/licenses/ECL-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an "AS IS"
# BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing
# permissions and limitations under the License.



use strict;
use warnings;

# Parsing tabulated PHAST output to put in
# into EMBL format

# NOTE: list file must contain start and end coordinates only
# separated by 2 dots (as provided in output), blast-hits and evalue

my $CDStab = $_;
my $inFile = $_;
my @CDSline = @_;


if (! $ARGV[0])
{
print "What is the PHAST file to parse? ";
chomp ($inFile = <STDIN>);
}

else
{
$inFile = $ARGV[0];
}

my $outFile = "$inFile".".embl";

# Open file  
open(FILE_IN, "$inFile") || die "ERROR - $! : ,$inFile,\n";
# Open file  
open(FILE_OUT, ">$outFile") || die "ERROR - $! : ,$outFile,\n";

# Go through list file line by line
while (my $CDStab = <FILE_IN>)
        {
        $CDStab =~ /^gi/ and next; # filter header line
        $CDStab =~ /^\s*$/ and next; # filter empty lines       
        $CDStab =~ /^#/ and next; # filter out comments
        $CDStab =~ /^CDS_POSITION/ and next; #filter out region comments
        $CDStab =~ /^-------------------------/ and next; # filter out separator line
        $CDStab =~ s/\s\s\s*/\t/g; # replace multiple spaces by a single tab
        # Remove the newline character at the end
        chomp ($CDStab);

        # Split the line in a table according to the space separator 
        @CDSline = split(/\t+/, $CDStab);
        if ($CDSline[1] =~ "attL|attR*") {
                print FILE_OUT "FT   repeat_region   ";
                print FILE_OUT $CDSline[0], "\n";
                print FILE_OUT "FT                   /note=\"",$CDSline[1],"\"\n";}
        else {
                print FILE_OUT "FT   misc_feature    ";
                print FILE_OUT $CDSline[0], "\n";
                print FILE_OUT "FT                   /note=\"",$CDSline[1],"\"\n";
                print FILE_OUT "FT                   /note=\"E-value ",$CDSline[2],"\"\n";
                print FILE_OUT "FT                   /color=7\n";}
        }
# Close file
close FILE_IN;
close FILE_OUT;
