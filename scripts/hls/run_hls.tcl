
set module_name $env(HLS_MODULE_NAME)
set project_name $env(HLS_PROJ_NAME)
set source_dir $env(HLS_SRC_DIR)
set test_bench_dir $env(HLS_TEST_BENCH_DIR)

set source_files [glob -dir $source_dir *]
set test_bench_files [glob -dir $test_bench_dir *]

open_project -reset $project_name
set_top $module_name

foreach f $source_files { add_files "$f" }
foreach t $test_bench_files { add_files -tb "$t" }

#solution
open_solution -reset "solution1"
set_part {xc7vx485tffg1761-2}
create_clock -period 10 -name default
config_rtl -encoding auto -reset control -reset_level low
csim_design -clean
csynth_design

exit

