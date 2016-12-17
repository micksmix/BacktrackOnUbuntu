#!/usr/bin/perl
#
##
# Written by Mick Grove
# https://micksmix.wordpress.com
#
#  [v0.1]       11/20/2009
##
#
# BSD Licensed
#
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions are
#       met:
#
#       * Redistributions of source code must retain the above copyright
#         notice, this list of conditions and the following disclaimer.
#       * Redistributions in binary form must reproduce the above
#         copyright notice, this list of conditions and the following disclaimer
#         in the documentation and/or other materials provided with the
#         distribution.
#       * Neither the name of the  nor the names of its
#         contributors may be used to endorse or promote products derived from
#         this software without specific prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#       "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#       LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#       A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#       OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#       SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#       LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#       DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#       THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#       OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
use strict;
use warnings;
use Tie::File;
 
my $dir     = "/usr/local/share/applications";
my $section = "Desktop Entry";
my $in_section;
my @files;
 
opendir(BIN, $dir) or die "Can't open $dir: $!";
while (defined(my $file = readdir BIN))
{
    next if $file =~ /^\.\.?$/;    # skip . and ..
    if ($file =~ m/.*\.desktop$/i)
    {
        push(@files, $file);
    }
}
closedir(BIN);
 
foreach my $curfile (@files)
{
    open( FH, "<", "$dir/$curfile" ) or die "$!";
    chomp( my @fileparts =  );
 
    my $termval = TerminalStatus(\@fileparts);
    next if $termval eq 0;    # skip if this is not a terminal application
 
    #lets see if this is actually a BT program
    my $btprogram = IsBTProgram(\@fileparts);
    next if $btprogram == 0;    # skip if this is not a BT application
 
    my $ExecKey     = "Exec";
    my $TerminalKey = "Terminal";
    my @tiedfile;
 
    #open this file for editing
    tie @tiedfile, 'Tie::File', "$dir/$curfile" or die "$!";
 
    #read file line by line here
    # updating "Exec" line
    foreach my $fline (@tiedfile)
    {
        next if $fline =~ /^#/;       # skip comments
        next if $fline =~ /^\s*$/;    # skip empty lines
 
        if ($fline =~ /^\[$section\]$/)
        {
            $in_section = 1;
            next;
        }
 
        if ($fline =~ /^\[/)
        {
            $in_section = 0;
            next;
        }
 
        my $oldline;
        my $updatedline;
        if ($in_section and $fline =~ /^$ExecKey\s*=\s*(.*)$/)
        {
 
            # this means we have the "Exec key"
            $oldline = $1;
            next if $oldline =~ m/^.*xterm -e.*;bash.*$/i;    #skip
            $oldline =~ s/"/\\"/img;
            $updatedline = "Exec=xterm -e \"$oldline;bash\"";
            $fline       = $updatedline;
 
            print "New exec: " . $fline . "\n";
            next;
        }
        elsif ($in_section and $fline =~ /^$TerminalKey\s*=\s*(.*)$/)
        {
 
            # this means we have the "Terminal key"
            # we will set it to "0" to turn it off --- we are launching
            #   xterm ourselves, if we set to 1, we'll get an extra
            #   terminal opened
            #
            $oldline     = $1;
            $updatedline = "Terminal=0";
            $fline       = $updatedline;
            next;
        }
 
    }
    untie @tiedfile;
}
 
print "\n\nAll menu entries have been updated\n";
 
###
### Subroutines ###
###
sub TerminalStatus
{
    my @lines       = @{$_[0]};
    my $TerminalKey = "Terminal";
    my $ExecKey     = "Exec";
    my $termkeyval  = 0;            #default = 0 FALSE, 1= TRUE
    my $i           = 0;
    my $execkeyval = 0;  #default = 0 = this exec line probably wasn't set by us
 
    foreach my $fline (@lines)
    {
        next if $fline =~ /^#/;       # skip comments
        next if $fline =~ /^\s*$/;    # skip empty lines
 
        if ($fline =~ /^\[$section\]$/)
        {
            $in_section = 1;
            next;
        }
 
        if ($fline =~ /^\[/)
        {
            $in_section = 0;
            next;
        }
 
        if ($in_section and $fline =~ /^$TerminalKey\s*=\s*(.*)$/)
        {
 
            # this means we have the "terminal key"
            $termkeyval = $1;
            next;    #last;
        }
 
        if ($in_section and $fline =~ /^$ExecKey\s*=\s*(.*)$/)
        {
 
            # this means we have the "exec key"
            $execkeyval = $1;
            if ($execkeyval =~ m/^.*xterm -e.*;bash.*$/i)
            {
                $execkeyval = 1;    # this script likely set this value before
            }
            next;                   #last;
        }
    }
 
    if ($execkeyval eq 1)
    {
        # force this to true, because this can be updated by this script,
        #   b/c we appear to have modified this entry before.
        $termkeyval = 1;
    }
    return $termkeyval;
}
 
sub IsBTProgram
{
    my @lines    = @{$_[0]};
    my $key      = "Categories";
    my $isbtprog = 0;              #default = FALSE = 0
    my $i        = 0;
    foreach my $fline (@lines) {
        next if $fline =~ /^#/;       # skip comments
        next if $fline =~ /^\s*$/;    # skip empty lines
 
        if ($fline =~ /^\[$section\]$/) {
            $in_section = 1;
            next;
        }
 
        if ($fline =~ /^\[/) {
            $in_section = 0;
            next;
        }
        if ($in_section and $fline =~ /^$key\s*=\s*(.*)$/)
        {
 
            # this means we have the "terminal key"
            if ($1 =~ m/.*BT-.*/i)
            {
                $isbtprog = 1;
            }
            last;
        }
    }
    return $isbtprog;
}
