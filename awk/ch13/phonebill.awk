BEGIN {	
	pence_per_unit  = 4.40
	pence_per_unit *= 1.15

	c ["L/c"] = 330 ;  c ["L/s"] = 85.0;  c ["L/p"] = 60.0;
	c ["a/c"] =  96 ;  c ["a/s"] = 34.3;  c ["a/p"] = 25.7;
	c ["b1/c"]= 60.0;  c ["b1/s"]= 30.0;  c ["b1/p"]= 22.5;
	c ["b/c"] = 45.0;  c ["b/s"] = 24.0;  c ["b/p"] = 18.0;
	c ["m/c"] = 12.0;  c ["m/s"] = 8.00;  c ["m/p"] = 8.00;
	c ["A/c"] = 9.00;  c ["A/s"] = 7.20;  c ["A/p"] = 0   ;
	c ["A2/c"]= 7.60;  c ["A2/s"]= 6.20;  c ["A2/p"]= 0   ;
	c ["B/c"] = 6.65;  c ["B/s"] = 5.45;  c ["B/p"] = 0   ;
	c ["C/c"] = 5.15;  c ["C/s"] = 4.35;  c ["C/p"] = 3.95;
	c ["D/c"] = 3.55;  c ["D/s"] = 2.90;  c ["D/p"] = 0   ;
	c ["E/c"] = 3.80;  c ["E/s"] = 3.05;  c ["E/p"] = 0   ;
	c ["F/c"] = 2.65;  c ["F/s"] = 2.25;  c ["F/p"] = 0   ;
	c ["G/c"] = 2.15;  c ["G/s"] = 2.15;  c ["G/p"] = 2.15;
}

{
	spu = c [ $2 ]			
	if ( spu == "" || spu == 0 ) {
	    summary [ $4 ] = summary [ $4 ] "\n\t" \
			    sprintf ( "%4s  %4s  %7s   ? units",\
	                          $1, $2, $3 ) \
			    " - Bad/Unknown Chargeband"
	} else {
	    n = split ( $3, t, ":" )  
	    seconds = 0
	    for ( i = 1; i <= n; i++ )
		seconds = seconds*60 + t[i]
	    u = seconds / spu
	    if ( int( u ) == u )   # round up to next whole unit
		u = int( u )
	    else
		u = int( u ) + 1
	    units [ $4 ] += u   # store info to output at end
	    summary [ $4 ] = summary [ $4 ] "\n\t" \
			    sprintf ( "%4s  %4s  %7s %3d units",\
	                         $1, $2, $3, u )
	}
}

END {
	for ( i in units ) {		# for each person
	    printf ( "Summary for %s:", i ) # newline at start
                                            # of summary
	    print summary [ i ]			# print summary details
	    # calc cost
	    total = int ( units[i] * pence_per_unit + 0.5 )
	    printf ( \
		"Total: %d units @ %.2f pence per unit = $%d.%02d\n\n", \
			    units [i], pence_per_unit, total/100, \
                                               total%100 )
	}
}

