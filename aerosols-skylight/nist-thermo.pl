#!/usr/bin/perl
# read molecular information from G98 frequency output
# OR from a command-line delimited file and then
# compute thermodynamic functions using RRHO model
#
# Karl Irikura, National Institute of Standards and Technology (karl.irikura@nist.gov)
# published on web 8/29/2002
# v1.1:
#	compute scaled ZPE;
#	warn if explicit vibrational ladders do not start with zero;
#	works with Gaussian03 output files
#	posted on web 8/26/2003
# physical constants updated 11/09/2004
# check for missing mass and print error message 3/21/2007
# abbreviated and sorted XVIB listing 3/16/2010
# v1.2:
# allow degeneracies in XVIB listing 6/7/2010
# check for consistency between number of frequencies and number of atoms 1/19/2011
# allow arbitrary (>= 1 cm-1) temperature increment 3/21/13
# 
$pi = 3.1415926535;
$avogad = 6.0221415E23;
$R = 8.314472;		# J/(mol K)
$h = 6.6260693E-34;	# J s
$k = 1.3806505E-23;	# J/K
$c = 2.99792458E08;	# m/s (exact)
$p = 1.0e5;			# Pa (standard pressure; change to 101325. for 1 atm)
$cmkj = $h * $avogad * $c / 10;		# convert from cm^-1 to kJ/mol
$Jkcal = 0.23900573613766726;
#
@specialt = ( 298.15 );	# list of irregular temperatures to include in output table
if ( $#ARGV < 0 ) {
	printf( "Usage:  perl thermo.pl [g98freq.out|datafile.dat] <freq scale factor> <temperature>\n" );
	exit;
}
open( FILE, $ARGV[0] ) or die "Failure reading file $ARGV[0]\n";
#printf( "opening %s for input\n\n", $ARGV[0] );
#
$scale = 1.0;
$symno = 1;
$tstep = 50;
#
# arguments can be scale factor (in range 0.5-1.5) or temperature
for ( $i = 1; $i <= $#ARGV; $i++ ) {
	$tt = $ARGV[ $i ];
	if ( abs( $tt - 1.0 ) <= 0.5 ) {
		# vibrational scaling factor -- don't allow too far from 1.0
		$scale = $tt;
	} elsif ( $tt >= 10. ) {
		# a temperature -- don't allow them too ridiculously low
		push( @specialt, $tt );
	}
	if ( $tt =~ /^-s(\d+\.\d+)/ ) {
		# allow wild scaling factor if preceded by -s, e.g. -s0.05
		$scale = $1;
	}
	if ( $tt =~ /^-dt(\d+\.?\d*)/ ) {
		# user-specified temperature increment, e.g. -dt50
		$tstep = $1;
	}
}
if ( $tstep < 1.0 ) {
	# don't allow step to be too small
	$tstep = 100;
}
$atom = $linear = 0;
$g98 = $datfile = 0;	# type of input data file
#printf( "Scaling vibrational frequencies by %.4f\n", $scale );
#printf( "** Non-standard pressure: %.1f Pa **\n", $p ) if ( $p != 1.0e5 );
$ifreq = $ielec = $ixvib = 0;
$zpe = $xzpe = $electronicenergy = 0.0;
$nneg = 0;
while ( <FILE> ) {
  #
  # this block is for G98 frequency output file
  #
  if ( /Molecular mass:/ ) {
    @line = split();
	$mass = $line[2];
	$g98 = 1;	# flag for g98 input file
  }
  if ( /ROTATIONAL CONSTANT/i ) {
    @line = split();
	$rot[0] = $line[3];
	$rot[1] = $line[4];
	$rot[2] = $line[5];
  }
  if ( /Full point group/ ) {
    @line = split();
	$group = $line[3];
	if ( $group =~ /\*/ ) {
		# molecule is linear 
		$linear = 1;
	}
	if ( $group eq "KH" ) {
		# molecule is an atom
		$atom = 1;
	}
  }
  if ( /Frequencies/ ) {
    @line = split();
	for ( $i = 2; $i < 5; $i++ ) {
		$tt = $line[$i];
		if ( $tt > 0.0 ) {
			$freq[$ifreq++] = $tt;
		} else {
			#printf "\tDiscarding vibrational frequency of %.1f\n", $tt;
			$nneg++;
		}
	}
  }
  if ( /Charge/ && /Multiplicity/ ) {
	# electronic degeneracy
	$energy[0] = 0.0;
	$degen[0] = ( split() )[5];
	$ielec = 1;
  }
  if ( /ROTATIONAL SYMMETRY NUMBER/i ) {
    @line = split();
	$symno = $line[3];
  }
  if ( /NAtoms=\s+(\d+)\s+/ ) {
	$natoms = $1;
  }
  #
  # this block is for keyword file
  #
  if ( /^MASS/i ) {
	@line = split();
	$mass = $line[1];
	$datfile = 1;	# flag for keyword input file
  }
  if ( /^GHZ/i ) {
	# rotational constant(s) in GHz
	@line = split();
	if ( $#line < 3 ) {
		$linear = 1;
		$rot[0] = $line[1];
		if ( $rot[0] == 0 ) {
			# molecule is an atom
			$linear = 0;
			$atom = 1;
		}
	}
	else {
		for ( $i = 0; $i < 3; $i++ ) {
			$rot[$i] = $line[$i + 1];
		}
	}
  }
  if ( /^VIB/i ) {
	@line = split();
	for ( $i = 1; $i <= $#line; $i++ ) {
		$freq[$ifreq++] = $line[$i];
	}
  }
  if ( /^XVIB/i ) {
  	# explicit vibrational energy levels (e.g., from anharmonic calc.)
	# note: must include the zero!
	( $i, @{$xvib[$ixvib]} ) = split();	# ignore i
	#xvib_print( $ixvib );
	$ixvib++;
  }
  if ( /^AVIB/i ) {
  	# anharmonic oscillator: E(v) = v[w - (v+1)x]
	# two or three fields:	w, x, and wavenumber limit
	@line = split();
	push( @w, $line[1] );
	push( @x, $line[2] );
	push( @lim, $line[3] );
  }
  if ( /^ELEC/i ) {
	# electronic level info:  degeneracy, then energy in cm^-1
	$degen[$ielec] = 1;
	$energy[$ielec] = 0.0;
	@line = split();
	$degen[$ielec] = $line[1];
	$energy[$ielec] = $line[2];
	if ( /kj/i ) {
		# input in kJ/mol; convert to cm^-1
		$energy[$ielec] /= $cmkj;
	}
	$ielec++;
  }
  if ( /^SYMNO/i ) {
	# symmetry number
	@line = split();
	$symno = $line[1];
  }
  if (/SCF Done/ ) {
    @line = split();
    $elenergy = $line[4];
  }
}
#printf( "Molecular mass = %.3f u\n", $mass );
if ( defined $mass and $mass > 0 ) {
	#print "External symmetry number = $symno\n";
	if ( $linear ) {
		$rot[0] = $rot[2] unless ( $rot[0] > 0 );	# use last if first is zero
		#printf( "Rotational constant (GHz) = %.5f\n", $rot[0] );
		$#rot = 0;	# truncate any useless elements
		$nfreq = 3 * $natoms - 5;
	} elsif ( $atom ) {
		#print "Molecule is an atom.\n";
		$nfreq = 0;
	} else {
		#printf( "Rotational constants (GHz) = %.5f %.5f %.5f\n", $rot[0], $rot[1], $rot[2] );
		$nfreq = 3 * $natoms - 6;
	}
	if ( $ifreq > 0 ) {
		#print "Harmonic vibrational frequencies (cm^-1):\n";
		if ( not $datfile and $ifreq + $nneg != $nfreq ) {
			printf "*** Error: number of frequencies (%d) is not that expected (%d) for %d atoms ***\n", $ifreq+$nneg, $nfreq, $natoms;
			print "This occurs in a Gaussian job combining 'opt=calcall' with 'freq'.\n";
			if ( $ifreq+$nneg == 2 * $nfreq ) {
				# it's probably the case described; offer to truncate the list
				print "Do you want to truncate the list of frequencies in the middle? ";
				chomp( $reply = <STDIN> );
				if ( $reply =~ /^[yY]/ ) {
					$ifreq /= 2;
					$nneg /= 2;
					$#freq = $nfreq - 1;
				}
			}
			if ( $ifreq+$nneg == 2 * $nfreq ) {
				print "Please check your input file and try again.\n";
				exit(1);
			}
		}
		#print "\tunscaled\tscaled\n";
	} else {
		#print "Harmonic vibrational frequencies (cm^-1):  none\n";
	}
	for ( $i = 0; $i < $ifreq; $i++ ) {
		$tt = $freq[$i];
		$freq[$i] *= $scale;
		#printf( "%3d\t%6.1f\t\t%6.1f\n", $i + 1, $tt, $freq[$i] );
		$zpe += $freq[$i] / 2;	# scaled harmonic contribution to vibrational zero-point energy
	}
} else {
	print "\n*** The mass must be greater than zero ***\n";
	print "Be sure not to request terse output (\"#T\" on the Gaussian command line).\n";
}

unless ( $datfile ) {
	$reply = "yes";
	#if ( -e "thermo.dat" ) {
	#	print "\n***Overwrite file 'thermo.dat'? ";
	#	chomp( $reply = <STDIN> );
	#}
	if ( $reply =~ /^y/i ) {
		open( DAT, ">thermo.dat" ) or warn "Unable to open 'thermo.dat' for output!\n";
		printf DAT "MASS\t%.6f\n", $mass;
		printf DAT "GHZ" . ( "\t%.6f" x @rot ) . "\n", @rot;
		if ( $ifreq > 0 ) {
			print DAT "VIB\t";
			for ( $i = 0; $i < $ifreq; $i++ ) {
				printf DAT "%.1f ", $freq[$i];	# these are scaled frequencies
			}
			print DAT "\n";
		}
		printf DAT "SYMNO\t%d\n", $symno;
		if ( $ielec > 0 ) {
			for ( $i = 0; $i < $ielec; $i++ ) {
				printf DAT "ELEC\t%d\t%.1f\n", $degen[$i], $energy[$i];
			}
		}
		close( DAT );
	}
}

# If the mass == 0, create the .dat file and then quit.
unless( defined $mass and $mass > 0 ) {
	print "Edit the file 'thermo.dat' to include the correct molecular mass\n";
	print "and check the symmetry number.  ";
	print "Then run 'perl thermo.pl thermo.dat'.\n";
	exit(1);
}

if ( $ixvib > 0 ) {
	print "Explicit vibrational ladders (cm^-1):\n";
	for ( $i = 0; $i < $ixvib; $i++ ) {
		# sort explicit levels by increasing energy
		@{ $xvib[$i] } = sort sort_xvib @{ $xvib[$i] };
		#xvib_print( $i );
		# don't print too many levels
		printf( "%3d ", $i+1 );
		for ( $j = 0; $j < 13 and $j <= $#{$xvib[$i]}; $j++ ) {
			printf( " %.1f", xvib_val( $xvib[$i]->[$j] ) );
		}
		if ( $#{ $xvib[$i] } > 12 ) {
			printf "\n\t(%d levels up to %.1f)\n", xvib_count( $i ), xvib_val( $xvib[$i]->[-1] );
		} else {
			print "\n";
		}
		$zpe += xvib_val( $xvib[$i][0] );	# usually will be zero
		$xzpe += xvib_val( $xvib[$i][0] );	# keep track of the explicit ZPE
	}
}
if ( $#w > -1 ) {
	print "Anharmonic oscillators (cm^-1):\n";
	for ( $i = 0; $i <= $#w; $i++ ) {
		$lim[$i] = 10000 if ( $lim[$i] <= 0 );	# no limit requested
		$vmax = $w[$i] / ( 2 * $x[$i] ) - 1;		# v at turnover point
		$t = $vmax * ( $w[$i] - ( $vmax + 1 ) * $x[$i] );
		# don't exceed turnover point and don't go negative
		$lim[$i] = $t if ( $t < $lim[$i] and $t > $w[$i] );
		printf( "%3d\tw = %.1f\tx = %.3f\tlimit = %.1f\n", $i+1, $w[$i], $x[$i], $lim[$i] );
		$zpe += $w[$i] / 2 - $x[$i] / 4;	# anharmonic ZPE
	}
}
if ( $ielec > 0 ) {
	#print "Electronic states:\n";
	#printf( "\tdegen\tcm^-1\tkJ/mol\n" );
	#for ( $i = 0; $i < $ielec; $i++ ) {
	#	printf( "%3d\t%2d\t%.1f\t%.2f\n", $i+1, $degen[$i], $energy[$i], $energy[$i]*$cmkj );
	#}
}
#printf( "\n" );

########## begin calculations ###########
#printf "Vibrational zero-point energy = %.1f cm^-1 ", $zpe;
$zpe *= $cmkj;		# convert from cm^-1 to kJ/mol
#printf "= %.2f kJ/mol.\n", $zpe;
if ( $xzpe > 0 ) {
	#printf "(includes %.1f cm^-1 = ", $xzpe;
	$xzpe *= $h * $avogad * $c / 10;	# convert from cm^-1 to kJ/mol
	#printf "%.2f kJ/mol from explicit vibrational levels)\n";
	#print "***WARNING: explicit vibrational ladders should generally start at zero***\n";
} 

# array indices: 0 = translation, 1 = rotation, 2 = vibration, 3 = electronic
for ( $i = 0; $i < 4; $i++ ) {
	$s[$i] = $cp[$i] = $ddh[$i] = 0.0;
}
# translational contributions
# convert mass from u to kg
$mass /= $avogad * 1000.0;
$s[0] = $R * ( 1.5 * log( 2 * $pi * $mass / $h / $h ) - log( $p ) + 2.5 );
$cp[0] = 2.5 * $R;
$ddh[0] = 2.5 * $R;
# rotational contributions
for ( $i = 0; $i < 3; $i++ ) {
	# convert from GHz to s^-1
	$rot[$i] *= 1.0e09;
}
if ( $rot[0] > 0.0 ) {
	# don't try to include rotations for atoms
	if ( $linear == 1 ) {
		# linear molecule
		$s[1] = $R * ( log( $k / ( $symno * $h * $rot[0] ) ) + 1.0 );
		$cp[1] = $R;
		$ddh[1] = $R;
	}
	else {
		# non-linear molecule
		$s[1] = log( $rot[0] ) + log( $rot[1] ) + log( $rot[2] ) - log( $pi );
		$s[1] *= -0.5;
		$s[1] += 1.5 - log( $symno );
		$s[1] *= $R;
		$cp[1] = 1.5 * $R;
		$ddh[1] = 1.5 * $R;
	}
}
$convert = 100.0 * $c * $h / $k;	# conversion factor from cm^-1 to K
foreach ( @freq ) { $_ *= $convert; }	# convert harmonic frequencies
foreach ( @energy ) { $_ *= $convert; }	# convert electronic energies
# convert explicit vibrational ladders
for ( $i = 0; $i < $ixvib; $i++ ) {
	foreach $a ( @{ $xvib[$i] } ) {
		if ( $a =~ /\(\d+\)/ ) {
			# degeneracy given
			#print "$a:\t\t";
			$xv = xvib_val( $a ) * $convert;
			$xg = xvib_degen( $a );
			$a = sprintf( "%.1f(%d)", $xv, $xg );
			#print "$xv\t$xg\t$a\n";
		} else {
			$a *= $convert;
		}
	}
	#xvib_print( $i );
}
# convert anharmonic frequencies
for ( $i = 0; $i <= $#w; $i++ ) {
	$w[$i] *= $convert;
	$x[$i] *= $convert;
	$lim[$i] *= $convert;
}
# loop over temperatures and print totals
#printf( "\nT (K)\tS (J/mol.K)\tCp (J/mol.K)\tddH (kJ/mol)\n" );
$tmax = 1000;
#@tlist = @specialt;
@tlist = ( 216.65, 273.15, 298.15 );
#for ( $t = 100; $t <= $tmax; $t += $tstep ) {
#	push( @tlist, $t );
#}
#@tlist = sort { $a <=> $b } @tlist;
$enthalpy[3] = $entropy[3] = $gibbs[3] = 0.0;
$tcount = 0;
$string = "";
foreach $t ( @tlist ) {
  $stot = 0.0;
  $ddhtot = 0.0;
	# translational contribution
	$stot = $s[0] + $R * 2.5 * log( $k * $t );
	#printf( "Strans = %.2f\t", $stot );
	if ( $linear == 1 ) {
		$tt = $s[1] + $R * log ( $t );
		$stot += $tt;
	}
	elsif ( $rot[0] > 0.0 ) {
		$tt = log( $k * $t ) - log( $h );
		$tt *= 1.5 * $R;
		$tt += $s[1];
		$stot += $tt;
	}
	#printf( "Srot = %.2f\t", $tt );
	#
	# all energies have been converted to Kelvin units to simplify the arithemetic below
	# 
	# harmonic vibrational contributions
	$s[2] = $cp[2] = $ddh[2] = 0.0;
	for ( $i = 0; $i < $ifreq; $i++ ) {
		next if ( $freq[$i] <= 0 );	# skip "negative" and zero frequencies
		$tt = $freq[$i] / $t;
		$ttt = exp( - $tt );
		$s[2] -= log( 1.0 - $ttt );
		$s[2] += $tt * $ttt / ( 1.0 - $ttt );
		$cp[2] += $tt * $tt * $ttt / ( 1.0 - $ttt ) / ( 1.0 - $ttt );
		$ddh[2] += $tt * $ttt / ( 1.0 - $ttt );
	}
	#printf( "Svib = %.2f\t", $s[2] * $R );
	# electronic level contributions
	$s[3] = $cp[3] = $ddh[3] = 0.0;
	if ( $ielec > 0 ) {
		$s1 = $s2 = $s3 = 0.0;
		for ( $i = 0; $i < $ielec; $i++ ) {
			$tt = $energy[$i] / $t;
			$ttt = exp( -$tt );
			$s0 = $degen[$i] * $ttt;
			$s1 += $s0;
			$s0 *= $tt;
			$s2 += $s0;
			$s0 *= $tt;
			$s3 += $s0;
		}
		$s[3] = log( $s1 ) + $s2 / $s1;
		##printf( "Selec = %.2f\t", $s[3] * $R );
		$cp[3] = $s3 / $s1 - $s2 * $s2 / ( $s1 * $s1 );
		$ddh[3] = $s2 / $s1;
	}
	# explicit vibrational ladders
	$s[4] = $cp[4] = $ddh[4] = 0.0;
	for ( $j = 0; $j < $ixvib; $j++ ) {
		$s1 = $s2 = $s3 = $d2 = 0.0;
		$nlevel = xvib_count( $j );
		for ( $i = 0; $i < $#{ $xvib[$j] }; $i++ ) {
			$tt = xvib_val( $xvib[$j]->[$i] ) / $t;
			$s0 = exp( -$tt );
			$s0 *= xvib_degen( $xvib[$j]->[$i] );
			$s1 += $s0;	# s1 is the partition function:  Q
			$s0 *= $tt;
			$s2 += $s0;	# s2 is weighted by (e/T):  T(dQ/dT)
			$s0 *= $tt;
			$s3 += $s0;	# s3 is weighted by (e/T)**2:  part of T**2(d2Q/dT2)
		}
		$d2 = $s3 - 2 * $s2;	# d2 is T**2(d2Q/dT2)
		# s1 is Q; s2 is T(dQ/dT); d2 is T**2(d2Q/dT2)
		$s[4] += log( $s1 ) + $s2 / $s1;
		$cp[4] += 2 * $s2 / $s1 + $d2 / $s1 - $s2 * $s2 / ( $s1 * $s1 );
		$ddh[4] += $s2 / $s1;
	}
	# 1-dimensional anharmonic vibrations
	$s[5] = $cp[5] = $ddh[5] = 0.0;
	for ( $i = 0; $i <= $#w; $i++ ) {
		$e = $s1 = $s2 = $s3 = 0.0;
		for ( $v = 1; $e <= $lim[$i]; $v++ ) {
			$tt = $e / $t;
			$s0 = exp( -$tt );
			$s1 += $s0;
			$s0 *= $tt;
			$s2 += $s0;
			$s0 *= $tt;
			$s3 += $s0;
			$e = $v * ( $w[$i] - ( $v + 1 ) * $x[$i] );
		}
		$s[5] += log( $s1 ) + $s2 / $s1;
		$cp[5] += $s3 / $s1 - $s2 * $s2 / ( $s1 * $s1 );
		$ddh[5] += $s2 / $s1;
	}
	$stot += $R * ( $s[2] + $s[3] + $s[4] + $s[5] );
	$cptot = $cp[0] + $cp[1] + $R * ( $cp[2] + $cp[3] + $cp[4] + $cp[5] );
	$ddhtot = $ddh[0] * $t;
	$ddhtot += $ddh[1] * $t;
	$ddhtot += $R * $t * ( $ddh[2] + $ddh[3] + $ddh[4] + $ddh[5] );
	$ddhtot /= 1000.0;
  $string = $string . sprintf( "%.3f\t", $ddhtot*$Jkcal );
  $string = $string . sprintf( "%.3f\t", $stot*$Jkcal );
  $string = $string . sprintf( "%.3f\t",  $zpe*$Jkcal + $ddhtot * $Jkcal - 0.001 * $t * $stot * $Jkcal );
}
printf( "%.10f\t\t\t\t\t\t\t%.3f\t%s\n", $elenergy, $zpe*$Jkcal, $string );
#$Jtokcal = 0.23900573613766726;
#printf( "\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n",\
#        $zpe*$Jkcal,\
#        $enthalpy[0], $entropy[0], $gibbs[0],\
#        $enthalpy[1], $entropy[1], $gibbs[1],\
#        $enthalpy[2], $entropy[2], $gibbs[2] );
#if ( $reply eq "yes" ) {
#	print "\nInput data (including scaled vibrational frequencies) written to\n";
#	print "file 'thermo.dat'.\n";
#}
# If appropriate, print warning about undetected spatial degeneracy
if ( $degen[0] > 1 and ( $linear or $rot[0] == 0.0 or $symno > 2 ) ) {
	# electronic degeneracy AND
	#  linear molecule, atom, or possible non-Abelian point group
	print "\n**WARNING**\nThis program does not detect electronic spatial degeneracies.\n";
	print "If they apply to this molecule, save and edit 'thermo.dat' and then run:\n";
	print "\tperl thermo.pl thermo.dat\n";
}

sub sort_xvib {
	# sort by frequency, discarding any parenthetical degeneracies
	return ( xvib_val( $a ) <=> xvib_val( $b ) );
}

sub xvib_degen {
	# return just the degeneracy part 
	my( $a ) = @_;
	if ( $a =~ /\((\d+)\)/ ) {
		return $1;
	} else {
		return 1;
	}
}

sub xvib_val {
	# return just the frequency part (discard any parenthetical degeneracy)
	my( $a ) = @_;
	$a =~ s/\(\d+\)//;
	return $a;
}

sub xvib_count {
	# one arg: the XVIB manifold to count (including degen. levels)
	my( $i ) = @_;
	my( $n ) = 0;
	foreach ( @{$xvib[$i]} ) {
			#printf "\t%s\t%.1f\t%d\n", $_, xvib_val( $_ ), xvib_degen( $_ );
		$n += xvib_degen( $_ );
	}
	return $n;
}

sub xvib_print {
	# for debugging 
	# one arg: XVIB manifold index
	my( $ix ) = @_;
	foreach ( @{$xvib[$ix]} ) {
		#next unless ( xvib_degen( $_ ) > 1 );
		printf "\t%s\t%.1f\t%d\n", $_, xvib_val( $_ ), xvib_degen( $_ );
	}
}

