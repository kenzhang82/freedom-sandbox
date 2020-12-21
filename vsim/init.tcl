if { ! [info exists env(TRACE_DELAY)] } {
    if {[info exists env(TRACE)]} {
        puts "Dumping trace"
        if {$env(TRACE)} {
            database -open $env(TRACE_DIR)/$env(PROGRAM) -shm
            if {[info exists env(TRACE_MEMS)]} {
                probe -create -depth all -all -memories $env(TB_NAME)
            } else {
                probe -create -depth all $env(TB_NAME)
            }
            puts "Trace file in $env(TRACE_DIR)/$env(PROGRAM)"
        }
    }
}

set assert_stop_level never

if { [info exists env(TRACE_DELAY)] } {
    puts "TRACE_DELAY env var set, so running until $env(TRACE_DELAY) and then enabling trace..."
    run $env(TRACE_DELAY) -absolute
    puts "Have run to $env(TRACE_DELAY) now dumping trace"
    database -open $env(TRACE_DIR)/$env(PROGRAM) -shm
    if {[info exists env(TRACE_MEMS)]} {
        probe -create -depth all -all -memories $env(TB_NAME)
    } else {
        probe -create -depth all $env(TB_NAME)
    }
    puts "Trace file in $env(TRACE_DIR)/$env(PROGRAM)"
}
run
