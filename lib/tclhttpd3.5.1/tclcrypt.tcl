# tclcrypt.tcl
#
# Unix crypt in pure tcl
# From http://mini.net/tcl/crypt by Michael A. Cleverly (23/Nov/2000)
#
# Used as a fallback for installations without libcrypt.so compiled.
# It's always better to have the compiled C version available, of course
# This package provides two implementations of crypt, and will choose
# the fastest possible depending upon Tcl version

package provide tclcrypt 1.0

proc crypt {password salt} {

    array set IP {
	0 58  1 50  2 42  3 34  4 26  5 18  6 10  7 2
	8 60  9 52 10 44 11 36 12 28 13 20 14 12 15 4
	16 62 17 54 18 46 19 38 20 30 21 22 22 14 23 6
	24 64 25 56 26 48 27 40 28 32 29 24 30 16 31 8
	32 57 33 49 34 41 35 33 36 25 37 17 38  9 39 1
	40 59 41 51 42 43 43 35 44 27 45 19 46 11 47 3
	48 61 49 53 50 45 51 37 52 29 53 21 54 13 55 5
	56 63 57 55 58 47 59 39 60 31 61 23 62 15 63 7}
    
    array set FP {
	0 40  1 8  2 48  3 16  4 56  5 24  6 64  7 32
	8 39  9 7 10 47 11 15 12 55 13 23 14 63 15 31
	16 38 17 6 18 46 19 14 20 54 21 22 22 62 23 30
	24 37 25 5 26 45 27 13 28 53 29 21 30 61 31 29
	32 36 33 4 34 44 35 12 36 52 37 20 38 60 39 28
	40 35 41 3 42 43 43 11 44 51 45 19 46 59 47 27
	48 34 49 2 50 42 51 10 52 50 53 18 54 58 55 26
	56 33 57 1 58 41 59  9 60 49 61 17 62 57 63 25}
    
    array set PC1_C {
	0 57  1 49  2 41  3 33  4 25  5 17  6  9
	7  1  8 58  9 50 10 42 11 34 12 26 13 18
	14 10 15  2 16 59 17 51 18 43 19 35 20 27
	21 19 22 11 23  3 24 60 25 52 26 44 27 36}
    
    array set PC1_D {
	0 63  1 55  2 47  3 39  4 31  5 23  6 15
	7  7  8 62  9 54 10 46 11 38 12 30 13 22
	14 14 15  6 16 61 17 53 18 45 19 37 20 29
	21 21 22 13 23  5 24 28 25 20 26 12 27  4}
    array set shifts {
	0 1 1 1  2 2  3 2  4 2  5 2  6 2  7 2
	8 1 9 2 10 2 11 2 12 2 13 2 14 2 15 1}
    
    array set PC2_C {
	0 14  1 17  2 11  3 24  4  1  5  5
	6  3  7 28  8 15  9  6 10 21 11 10
	12 23 13 19 14 12 15  4 16 26 17  8
	18 16 19  7 20 27 21 20 22 13 23  2}
    
    array set PC2_D {
	0 41  1 52  2 31  3 37  4 47  5 55
	6 30  7 40  8 51  9 45 10 33 11 48
	12 44 13 49 14 39 15 56 16 34 17 53
	18 46 19 42 20 50 21 36 22 29 23 32}
    
    array set e {
	0 32  1  1  2  2  3  3  4  4  5  5
	6  4  7  5  8  6  9  7 10  8 11  9
	12  8 13  9 14 10 15 11 16 12 17 13
	18 12 19 13 20 14 21 15 22 16 23 17
	24 16 25 17 26 18 27 19 28 20 29 21
	30 20 31 21 32 22 33 23 34 24 35 25
	36 24 37 25 38 26 39 27 40 28 41 29
	42 28 43 29 44 30 45 31 46 32 47  1}
    
    array set S {
        0,0  14 0,1   4 0,2  13 0,3   1 0,4   2 0,5  15 0,6  11 0,7   8
        0,8   3 0,9  10 0,10  6 0,11 12 0,12  5 0,13  9 0,14  0 0,15  7
        0,16  0 0,17 15 0,18  7 0,19  4 0,20 14 0,21  2 0,22 13 0,23  1
        0,24 10 0,25  6 0,26 12 0,27 11 0,28  9 0,29  5 0,30  3 0,31  8
        0,32  4 0,33  1 0,34 14 0,35  8 0,36 13 0,37  6 0,38  2 0,39 11
        0,40 15 0,41 12 0,42  9 0,43  7 0,44  3 0,45 10 0,46  5 0,47  0
        0,48 15 0,49 12 0,50  8 0,51  2 0,52  4 0,53  9 0,54  1 0,55  7
        0,56  5 0,57 11 0,58  3 0,59 14 0,60 10 0,61  0 0,62  6 0,63 13
        1,0  15 1,1   1 1,2   8 1,3  14  1,4  6 1,5  11 1,6   3 1,7   4
        1,8   9 1,9   7 1,10  2 1,11 13 1,12 12 1,13  0 1,14  5 1,15 10
        1,16  3 1,17 13 1,18  4 1,19  7 1,20 15 1,21  2 1,22  8 1,23 14
        1,24 12 1,25  0 1,26  1 1,27 10 1,28  6 1,29  9 1,30 11 1,31  5
        1,32  0 1,33 14 1,34  7 1,35 11 1,36 10 1,37  4 1,38 13 1,39  1
        1,40  5 1,41  8 1,42 12 1,43  6 1,44  9 1,45  3 1,46  2 1,47 15
        1,48 13 1,49  8 1,50 10 1,51  1 1,52  3 1,53 15 1,54  4 1,55  2
        1,56 11 1,57  6 1,58  7 1,59 12 1,60  0 1,61  5 1,62 14 1,63  9
	
        2,0  10 2,1   0 2,2   9 2,3  14 2,4   6  2,5  3 2,6  15 2,7   5
        2,8   1 2,9  13 2,10 12 2,11  7 2,12 11 2,13  4 2,14  2 2,15  8
        2,16 13 2,17  7 2,18  0 2,19  9 2,20  3 2,21  4 2,22  6 2,23 10
        2,24  2 2,25  8 2,26  5 2,27 14 2,28 12 2,29 11 2,30 15 2,31  1
        2,32 13 2,33  6 2,34  4 2,35  9 2,36  8 2,37 15 2,38  3 2,39  0
        2,40 11 2,41  1 2,42  2 2,43 12 2,44  5 2,45 10 2,46 14 2,47  7
        2,48  1 2,49 10 2,50 13 2,51  0 2,52  6 2,53  9 2,54  8 2,55  7
        2,56  4 2,57 15 2,58 14 2,59  3 2,60 11 2,61  5 2,62  2 2,63 12
	
        3,0   7 3,1  13 3,2  14 3,3   3  3,4  0  3,5  6 3,6   9 3,7  10
        3,8   1 3,9   2 3,10  8 3,11  5 3,12 11 3,13 12 3,14  4 3,15 15
        3,16 13 3,17  8 3,18 11 3,19  5 3,20  6 3,21 15 3,22  0 3,23  3
        3,24  4 3,25  7 3,26  2 3,27 12 3,28  1 3,29 10 3,30 14 3,31  9
        3,32 10 3,33  6 3,34  9 3,35  0 3,36 12 3,37 11 3,38  7 3,39 13
        3,40 15 3,41  1 3,42  3 3,43 14 3,44  5 3,45  2 3,46  8 3,47  4
        3,48  3 3,49 15 3,50  0 3,51  6 3,52 10 3,53  1 3,54 13 3,55  8
        3,56  9 3,57  4 3,58  5 3,59 11 3,60 12 3,61  7 3,62  2 3,63 14
	
        4,0   2 4,1  12 4,2   4 4,3   1 4,4   7 4,5  10 4,6  11 4,7   6
        4,8   8 4,9   5 4,10  3 4,11 15 4,12 13 4,13  0 4,14 14 4,15  9
        4,16 14 4,17 11 4,18  2 4,19 12 4,20  4 4,21  7 4,22 13 4,23  1
        4,24  5 4,25  0 4,26 15 4,27 10 4,28  3 4,29  9 4,30  8 4,31  6
        4,32  4 4,33  2 4,34  1 4,35 11 4,36 10 4,37 13 4,38  7 4,39  8
        4,40 15 4,41  9 4,42 12 4,43  5 4,44  6 4,45  3 4,46  0 4,47 14
        4,48 11 4,49  8 4,50 12 4,51  7 4,52  1 4,53 14 4,54  2 4,55 13
        4,56  6 4,57 15 4,58  0 4,59  9 4,60 10 4,61  4 4,62  5 4,63  3
	
        5,0  12 5,1   1 5,2  10 5,3  15 5,4   9 5,5   2 5,6   6 5,7   8
        5,8   0 5,9  13 5,10  3 5,11  4 5,12 14 5,13  7 5,14  5 5,15 11
        5,16 10 5,17 15 5,18  4 5,19  2 5,20  7 5,21 12 5,22  9 5,23  5
        5,24  6 5,25  1 5,26 13 5,27 14 5,28  0 5,29 11 5,30  3 5,31  8
        5,32  9 5,33 14 5,34 15 5,35  5 5,36  2 5,37  8 5,38 12 5,39  3
        5,40  7 5,41  0 5,42  4 5,43 10 5,44  1 5,45 13 5,46 11 5,47  6
        5,48  4 5,49  3 5,50  2 5,51 12 5,52  9 5,53  5 5,54 15 5,55 10
        5,56 11 5,57 14 5,58  1 5,59  7 5,60  6 5,61  0 5,62  8 5,63 13
	
        6,0   4 6,1  11 6,2   2 6,3  14 6,4  15 6,5   0 6,6   8 6,7  13
        6,8   3 6,9  12 6,10  9 6,11  7 6,12  5 6,13 10 6,14  6 6,15  1
        6,16 13 6,17  0 6,18 11 6,19  7 6,20  4 6,21  9 6,22  1 6,23 10
        6,24 14 6,25  3 6,26  5 6,27 12 6,28  2 6,29 15 6,30  8 6,31  6
        6,32  1 6,33  4 6,34 11 6,35 13 6,36 12 6,37  3 6,38  7 6,39 14
        6,40 10 6,41 15 6,42  6 6,43  8 6,44  0 6,45  5 6,46  9 6,47  2
        6,48  6 6,49 11 6,50 13 6,51  8 6,52  1 6,53  4 6,54 10 6,55  7
        6,56  9 6,57  5 6,58  0 6,59 15 6,60 14 6,61  2 6,62  3 6,63 12
	
        7,0  13 7,1   2 7,2   8 7,3   4 7,4   6 7,5  15 7,6  11 7,7   1
        7,8  10 7,9   9 7,10  3 7,11 14 7,12  5 7,13  0 7,14 12 7,15  7
        7,16  1 7,17 15 7,18 13 7,19  8 7,20 10 7,21  3 7,22  7 7,23  4
        7,24 12 7,25  5 7,26  6 7,27 11 7,28  0 7,29 14 7,30  9 7,31  2
        7,32  7 7,33 11 7,34  4 7,35  1 7,36  9 7,37 12 7,38 14 7,39  2
        7,40  0 7,41  6 7,42 10 7,43 13 7,44 15 7,45  3 7,46  5 7,47  8
        7,48  2 7,49  1 7,50 14 7,51  7 7,52  4 7,53 10 7,54  8 7,55 13
        7,56 15 7,57 12 7,58  9 7,59  0 7,60  3 7,61  5 7,62  6 7,63 11}
    
    array set P {
	0 16  1  7  2 20  3 21
	4 29  5 12  6 28  7 17
	8  1  9 15 10 23 11 26
	12  5 13 18 14 31 15 10
	16  2 17  8 18 24 19 14
	20 32 21 27 22  3 23  9
	24 19 25 13 26 30 27  6
	28 22 29 11 30  4 31 25}
    
    for {set i 0} {$i < 66} {incr i} {
        set block($i) 0
    }
    
    set pw [split $password ""]
    set pw_pos 0
    for {set i 0} \
	{[scan [lindex $pw $pw_pos] %c c] != -1 && $i < 64} \
	{incr pw_pos} {
	    for {set j 0} {$j < 7} {incr j ; incr i} {
		set block($i) [expr {($c >> (6 - $j)) & 01}]
	    }
	    incr i
	}

    for {set i 0} {$i < 28} {incr i} {
        set C($i) $block([expr {$PC1_C($i) - 1}])
        set D($i) $block([expr {$PC1_D($i) - 1}])
    }

    for {set i 0} {$i < 16} {incr i} {
        for {set k 0} {$k < $shifts($i)} {incr k} {
            set t $C(0)
            for {set j 0} {$j < 27} {incr j} {
                set C($j) $C([expr {$j + 1}])
            }
            set C(27) $t
            set t $D(0)
            for {set j 0} {$j < 27} {incr j} {
                set D($j) $D([expr {$j + 1}])
            }
            set D(27) $t
        }
	
        for {set j 0} {$j < 24} {incr j} {
            set KS($i,$j) $C([expr {$PC2_C($j) - 1}])
            set KS($i,[expr {$j + 24}]) $D([expr {$PC2_D($j) - 28 - 1}])
        }
    }
    
    for {set i 0} {$i < 48} {incr i} {
        set E($i) $e($i)
    }
    
    for {set i 0} {$i < 66} {incr i} {
        set block($i) 0
    }
    
    set salt [split $salt ""]
    set salt_pos 0
    set val_Z 90
    set val_9 57
    set val_period 46
    for {set i 0} {$i < 2} {incr i} {
        scan [lindex $salt $salt_pos] %c c
        incr salt_pos
        set iobuf($i) $c
        if {$c > $val_Z} {
            incr c -6
        }
        if {$c > $val_9} {
            incr c -7
        }
        incr c -$val_period
        for {set j 0} {$j < 6} {incr j} {
            if {[expr {($c >> $j) & 01}]} {
                set temp $E([expr {6 * $i + $j}])
                set E([expr {6 * $i + $j}]) $E([expr {6 * $i + $j + 24}])
                set E([expr {6 * $i + $j + 24}]) $temp
            }
        }
    }
    
    set edflag 0
    for {set h 0} {$h < 25} {incr h} {
        for {set j 0} {$j < 64} {incr j} {
            set L($j) $block([expr {$IP($j) - 1}])
        }
	
        for {set ii 0} {$ii < 16} {incr ii} {
            if {$edflag} {
                set i [expr {15 - $ii}]
            } else {
                set i $ii
            }
	    
            for {set j 0} {$j < 32} {incr j} {
                set tempL($j) $L([expr {$j + 32}])
            }
	    
            for {set j 0} {$j < 48} {incr j} {
                set preS($j) [expr {$L([expr {$E($j) - 1 + 32}]) ^ $KS($i,$j)}]
            }

            for {set j 0} {$j < 8} {incr j} {
	set t [expr {6 * $j}]
	set k $S($j, [expr {
			    ($preS($t) << 5) + 
			    ($preS([expr {$t + 1}]) << 3) + 
			    ($preS([expr {$t + 2}]) << 2) + 
			    ($preS([expr {$t + 3}]) << 1) + 
			    $preS([expr {$t + 4}])       + 
			    ($preS([expr {$t + 5}]) << 4)
			}])

                set t [expr {4 * $j}]
                set f($t) [expr {($k >> 3) & 01}]
                set f([expr {$t + 1}]) [expr {($k >> 2) & 01}]
                set f([expr {$t + 2}]) [expr {($k >> 1) & 01}]
                set f([expr {$t + 3}]) [expr { $k       & 01}]
            }

            for {set j 0} {$j < 32} {incr j} {
                set L([expr {$j + 32}]) [expr {$L($j) ^ $f([expr {$P($j) - 1}])}]
            }

            for {set j 0} {$j < 32} {incr j} {
                set L($j) $tempL($j)
            }
        }

        for {set j 0} {$j < 32} {incr j} {
            set t $L($j)
            set L($j) $L([expr {$j + 32}])
            set L([expr {$j + 32}]) $t
        }

        for {set j 0} {$j < 64} {incr j} {
            set block($j) $L([expr {$FP($j) - 1}])
        }
    }

    for {set i 0} {$i < 11} {incr i} {
        set c 0
        for {set j 0} {$j < 6} {incr j} {
            set c [expr {$c << 1}]
            set c [expr {$c | $block([expr {6 * $i + $j}])}]
        }
        incr c $val_period
        if {$c > $val_9} {
            incr c 7
        }
        if {$c > $val_Z} {
            incr c 6
        }
        set iobuf([expr {$i + 2}]) $c
    }
    
    if {$iobuf(1) == 0} {
        set iobuf(1) $iobuf(0)
    }
    
    set elements [lsort -integer [array names iobuf]]
    set encrypted ""
    
    foreach element $elements {
        append encrypted [format %c $iobuf($element)]
    }
    
    return $encrypted
}

if {[package present Tcl] < 8.4} {
    # we must use the slower non lset version
    return
}

#This version uses the [lset] command introduced in Tcl 8.4.
#It seems to result in a 40-45% improvement in speed over the original version which uses [array]s.

proc crypt {password salt} {
    set IP {58 50 42 34 26 18 10  2 60 52 44 36 28 20 12  4 62 54 46 38 30
	22 14  6 64 56 48 40 32 24 16  8 57 49 41 33 25 17  9  1 59 51
	43 35 27 19 11  3 61 53 45 37 29 21 13  5 63 55 47 39 31 23 15 7}

    set FP {40  8 48 16 56 24 64 32 39  7 47 15 55 23 63 31 38  6 46 14 54
	22 62 30 37  5 45 13 53 21 61 29 36  4 44 12 52 20 60 28 35  3
	43 11 51 19 59 27 34  2 42 10 50 18 58 26 33  1 41  9 49 17 57 25}
    
    set PC1_C {57 49 41 33 25 17  9  1 58 50 42 34 26 18 10  2 59 51 43 35 27
	19 11  3 60 52 44 36}
    
    set PC1_D {63 55 47 39 31 23 15  7 62 54 46 38 30 22 14  6 61 53 45 37 29
	21 13  5 28 20 12  4}
    
    set shifts {1 1 2 2 2 2 2 2 1 2 2 2 2 2 2 1}
    
    set PC2_C {14 17 11 24 1 5 3 28 15 6 21 10 23 19 12 4 26 8 16 7 27 20 13 2}
    
    set PC2_D {41 52 31 37 47 55 30 40 51 45 33 48 44 49 39 56 34 53 46 42 50
	36 29 32}
    
    set e {32  1  2  3  4  5  4  5  6  7  8  9  8  9 10 11 12 13 12 13 14 15
	16 17 16 17 18 19 20 21 20 21 22 23 24 25 24 25 26 27 28 29 28 29
	30 31 32 1}
    
    set S {{14  4 13  1  2 15 11  8  3 10  6 12  5  9  0  7  0 15  7  4 14  2
	13  1 10  6 12 11  9  5  3  8  4  1 14  8 13  6  2 11 15 12  9  7
	3 10  5  0 15 12  8  2  4  9  1  7  5 11  3 14 10  0  6 13}
	
	{15  1  8 14  6 11  3  4  9  7  2 13 12  0  5 10  3 13  4  7 15  2
	    8 14 12  0  1 10  6  9 11  5  0 14  7 11 10  4 13  1  5  8 12  6
	    9  3  2 15 13  8 10  1  3 15  4  2 11  6  7 12  0  5 14 9}
	
	{10  0  9 14  6  3 15  5  1 13 12  7 11  4  2  8 13  7  0  9  3  4
	    6 10  2  8  5 14 12 11 15  1 13  6  4  9  8 15  3  0 11  1  2 12
	    5 10 14  7  1 10 13  0  6  9  8  7  4 15 14  3 11  5  2 12}
	
	{ 7 13 14  3  0  6  9 10  1  2  8  5 11 12  4 15 13  8 11  5  6 15
	    0  3  4  7  2 12  1 10 14  9 10  6  9  0 12 11  7 13 15  1  3 14
	    5  2  8  4  3 15  0  6 10  1 13  8  9  4  5 11 12  7  2 14}
	
	{ 2 12  4  1  7 10 11  6  8  5  3 15 13  0 14  9 14 11  2 12  4  7
	    13  1  5  0 15 10  3  9  8  6  4  2  1 11 10 13  7  8 15  9 12  5
	    6  3  0 14 11  8 12  7  1 14  2 13  6 15  0  9 10  4  5  3}
	
	{12  1 10 15  9  2  6  8  0 13  3  4 14  7  5 11 10 15  4  2  7 12
	    9  5  6  1 13 14  0 11  3  8  9 14 15  5  2  8 12  3  7  0  4 10
	    1 13 11  6  4  3  2 12  9  5 15 10 11 14  1  7  6  0  8 13}
	
	{ 4 11  2 14 15  0  8 13  3 12  9  7  5 10  6  1 13  0 11  7  4  9
	    1 10 14  3  5 12  2 15  8  6  1  4 11 13 12  3  7 14 10 15  6  8
	    0  5  9  2  6 11 13  8  1  4 10  7  9  5  0 15 14  2  3 12}
	
	{13  2  8  4  6 15 11  1 10  9  3 14  5  0 12  7  1 15 13  8 10  3
	    7  4 12  5  6 11  0 14  9  2  7 11  4  1  9 12 14  2  0  6 10 13
	    15  3  5  8  2  1 14  7  4 10  8 13 15 12  9  0  3  5  6 11}}
    
    set P {16  7 20 21 29 12 28 17  1 15 23 26  5 18 31 10  2  8 24 14 32 27
	3  9 19 13 30  6 22 11  4 25}
    
    set block {0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0}
    
    set KS {{0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
	{0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
	{0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
	{0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
	{0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
	{0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
	{0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
	{0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
	{0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
	{0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
	{0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
	{0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
	{0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
	{0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
	{0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
	{0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}}
    
    set iobuf {0 0 0 0 0 0 0 0 0 0 0 0 0}
    set f {0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
    
    set pw [split $password ""]
    set pw_pos 0
    for {set i 0} {[scan [lindex $pw $pw_pos] %c c] != -1 && $i < 64} \
	{incr pw_pos} {
	    
	    for {set j 0} {$j < 7} {incr j ; incr i} {
		lset block $i [expr {($c >> (6 - $j)) & 01}]
	    }
	    incr i
	    
	}
    
    set C [list]
    set D [list]
    for {set i 0} {$i < 28} {incr i} {
	lappend C [lindex $block [expr {[lindex $PC1_C $i] - 1}]]
	lappend D [lindex $block [expr {[lindex $PC1_D $i] - 1}]]
    }
    
    for {set i 0} {$i < 16} {incr i} {
	for {set k 0} {$k < [lindex $shifts $i]} {incr k} {
	    set t [lindex $C 0]
	    for {set j 0} {$j < 27} {incr j} {
		lset C $j [lindex $C [expr {$j + 1}]]
	    }

	    lset C 27 $t
	    set t [lindex $D 0]
	    for {set j 0} {$j < 27} {incr j} {
		lset D $j [lindex $D [expr {$j + 1}]]
	    }
	    lset D 27 $t
	}
	
	for {set j 0} {$j < 24} {incr j} {
	    lset KS $i $j [lindex $C [expr {[lindex $PC2_C $j] - 1}]]
	    lset KS $i [expr {$j + 24}] \
		[lindex $D [expr {[lindex $PC2_D $j] - 28 - 1}]]
	}
    }
    
    set E [list]
    for {set i 0} {$i < 48} {incr i} {
	lappend E [lindex $e $i]
    }
    
    for {set i 0} {$i < 66} {incr i} {
	lset block $i 0
    }
    
    set salt [split $salt ""]
    set salt_pos 0
    set val_Z 90
    set val_9 57
    set val_period 46
    
    for {set i 0} {$i < 2} {incr i} {
	scan [lindex $salt $salt_pos] %c c
	incr salt_pos
	lset iobuf $i $c
	
	if {$c > $val_Z} {
	    incr c -6
	}
	if {$c > $val_9} {
	    incr c -7
	}
	incr c -$val_period
	for {set j 0} {$j < 6} {incr j} {
	    if {[expr {($c >> $j) & 01}]} {
		set temp [lindex $E [expr {6 * $i + $j}]]
		lset E [expr {6 * $i + $j}] \
		    [lindex $E [expr {6 * $i + $j + 24}]]
		lset E [expr {6 * $i + $j + 24}] $temp
	    }
	}
    }
    
    set edflag 0
    for {set h 0} {$h < 25} {incr h} {
	set L [list]
	for {set j 0} {$j < 64} {incr j} {
	    lappend L [lindex $block [expr {[lindex $IP $j] - 1}]]
	}
	
	for {set ii 0} {$ii < 16} {incr ii} {
	    if {$edflag} {
		set i [expr {15 - $ii}]
	    } else {
		set i $ii
	    }
	    
	    set tempL [list]
	    for {set j 0} {$j < 32} {incr j} {
		lappend tempL [lindex $L [expr {$j + 32}]]
	    }
	    
	    set preS [list]
	    for {set j 0} {$j < 48} {incr j} {
		lappend preS \
		    [expr {[lindex $L [expr {[lindex $E $j] - 1 + 32}]] ^ [lindex $KS $i $j]}]
	    }

	    for {set j 0} {$j < 8} {incr j} {
		set t [expr {6 * $j}]
		set k [lindex $S $j [expr {
				([lindex $preS $t] << 5) +
				([lindex $preS [expr {$t + 1}]] << 3) +
				([lindex $preS [expr {$t + 2}]] << 2) +
				([lindex $preS [expr {$t + 3}]] << 1) +
				[lindex $preS [expr {$t + 4}]] +
				([lindex $preS [expr {$t + 5}]] << 4)
			    }]]

		set t [expr {4 * $j}]
		lset f $t              [expr {($k >> 3) & 01}]
		lset f [expr {$t + 1}] [expr {($k >> 2) & 01}]
		lset f [expr {$t + 2}] [expr {($k >> 1) & 01}]
		lset f [expr {$t + 3}] [expr { $k       & 01}]
	    }
	    
	    for {set j 0} {$j < 32} {incr j} {
		lset L [expr {$j + 32}] \
		    [expr {[lindex $L $j] ^ [lindex $f [expr {[lindex $P $j] - 1}]]}]
	    }
	    
	    for {set j 0} {$j < 32} {incr j} {
		lset L $j [lindex $tempL $j]
	    }
	}
	
	for {set j 0} {$j < 32} {incr j} {
	    set t [lindex $L $j]
	    lset L $j [lindex $L [expr {$j + 32}]]
	    lset L [expr {$j + 32}] $t
	}
	
	for {set j 0} {$j < 64} {incr j} {
	    lset block $j [lindex $L [expr {[lindex $FP $j] - 1}]]
	}
    }
    
    for {set i 0} {$i < 11} {incr i} {
	set c 0
	for {set j 0} {$j < 6} {incr j} {
	    set c [expr {$c << 1}]
	    set c [expr {$c | [lindex $block [expr {6 * $i + $j}]]}]
	}
	incr c $val_period
	if {$c > $val_9} {
	    incr c 7
	}
	if {$c > $val_Z} {
	    incr c 6
	}
	lset iobuf [expr {$i + 2}] $c
    }
    
    if {[lindex $iobuf 1] == 0} {
	lset iobuf 1 [lindex $iobuf 0]
    }
    
    set encrypted ""
    foreach element $iobuf {
	append encrypted [format %c $element]
    }
    
    return $encrypted
}
