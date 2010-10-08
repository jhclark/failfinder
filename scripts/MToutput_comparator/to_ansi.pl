#!/usr/bin/perl

use strict;
use warnings;

use Term::ANSIColor;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my $color_tst1 = "yellow";
my $color_tst2 = "cyan";
my $color_tstboth = "green";
# there is a bug in ANSICOLOR that swaps on_cyan and on_yellow, swap back
my $oncolor_tst1 = "$color_tst2";
my $oncolor_tst2 = "$color_tst1";
my @COLORS = ("black on_$oncolor_tst1", "black on_$oncolor_tst2", "black on_$color_tstboth");

my $reset = color("reset");

print $reset;
while (<>) {
    chomp;
    next if /^\#/;
    my ( $info, $src, $ref, $tst1, $tst2 ) = split ( /\t/, $_ );
    print colored("$info", "white on_black")."$reset\n";
    print colored("SRC: $src", "black on_white")."$reset\n";
    print colored("REF: ", "green").print_sentence($ref)." \n";
    print colored("TST1: ", $color_tst1).print_sentence($tst1)." \n";
    print colored("TST2: ", $color_tst2).print_sentence($tst2)." \n";
    print "\n";
}

sub print_sentence {
    
    my $sentence = shift;
    my $output;

    # separate brackets
    $sentence =~ s/(\[\[\[|\]\]\]|\{\{\{|\}\}\})/\t$1\t/g;
    $sentence =~ s/\t+/\t/g;
    $sentence =~ s/^\t*(.+)\t*$/$1/;

    my @chunks = split ( /\t/, $sentence );
    my $in_square = 0;
    my $in_curly = 0;
    my $state = 0;
    
    foreach my $chunk (@chunks) {
        if ( $chunk eq '[[[') {
            $in_square = 1;
        }
        elsif ( $chunk eq ']]]' ) {
            $in_square = 0;
        }
        elsif ( $chunk eq '{{{') {
            $in_curly = 1;
        }
        elsif ( $chunk eq '}}}' ) {
            $in_curly = 0;
        }
        else {
            my $new_state = $in_square * 2 + $in_curly;
            if ( $new_state != $state ) {
                $output .= $reset if $state != 0;
                $output .= color($COLORS[$new_state - 1]) if $new_state != 0;
            }
            $state = $new_state;
            $output .= $chunk;
        }
    }
    $output .= $reset;
    return $output;
}
