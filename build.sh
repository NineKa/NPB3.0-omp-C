CC?=gcc
WASI_SDK?=/opt/wasi-sdk-12.0
PROBLEM_SIZE=W

CFLAGS=-O3
WASI_CFLAGS=-O0

DEST=$(pwd)/bin

ROOT=$(pwd)

function compile {
  ${WASI_SDK}/bin/clang $WASI_CFLAGS                             \
                        -I../common                              \
                        ../common/c_print_results.c              \
                        ../common/c_randdp.c                     \
                        ../common/c_timers.c                     \
                        ../common/wtime.c                        \
                        $@                                       \
                        -lm
}

function compile_is {
  ${WASI_SDK}/bin/clang $WASI_CFLAGS                             \
                        -I../common                              \
                        ../common/c_print_results.c              \
                        ../common/c_timers.c                     \
                        ../common/wtime.c                        \
                        $@                                       \
                        -lm
}

function process {
  cd $ROOT && make $1 CLASS=$PROBLEM_SIZE
  local TARGET=${1^^}
  if [[ $1 = "is" ]]
  then
    echo "here"
    cd $ROOT/$TARGET && ../sys/setparams $TARGET $PROBLEM_SIZE && \
    compile_is $1.c -o ../bin/$TARGET.$PROBLEM_SIZE.wasm
  else
    cd $ROOT/$TARGET && ../sys/setparams $TARGET $PROBLEM_SIZE && \
    compile $1.c -o ../bin/$TARGET.$PROBLEM_SIZE.wasm
  fi
}

mkdir -p $DEST

cat << EOT >> $ROOT/config/make.def
#---------------------------------------------------------------------------
#
#                SITE- AND/OR PLATFORM-SPECIFIC DEFINITIONS. 
#
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# Items in this file will need to be changed for each platform.
# (Note these definitions are inconsistent with NPB2.1.)
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# Parallel Fortran:
#
# For CG, EP, FT, MG, LU, SP and BT, which are in Fortran, the following must 
# be defined:
#
# F77        - Fortran compiler
# FFLAGS     - Fortran compilation arguments
# F_INC      - any -I arguments required for compiling Fortran 
# FLINK      - Fortran linker
# FLINKFLAGS - Fortran linker arguments
# F_LIB      - any -L and -l arguments required for linking Fortran 
# 
# compilations are done with $$(F77) $$(F_INC) $$(FFLAGS) or
#                            $$(F77) $$(FFLAGS)
# linking is done with       $$(FLINK) $$(F_LIB) $$(FLINKFLAGS)
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# This is the fortran compiler used for MPI programs
#---------------------------------------------------------------------------
F77 = f77
# This links MPI fortran programs; usually the same as $${F77}
FLINK	= f77

#---------------------------------------------------------------------------
# These macros are passed to the linker 
#---------------------------------------------------------------------------
F_LIB  =

#---------------------------------------------------------------------------
# These macros are passed to the compiler 
#---------------------------------------------------------------------------
F_INC =

#---------------------------------------------------------------------------
# Global *compile time* flags for Fortran programs
#---------------------------------------------------------------------------
FFLAGS	= -O3 
# FFLAGS = -g

#---------------------------------------------------------------------------
# Global *link time* flags. Flags for increasing maximum executable 
# size usually go here. 
#---------------------------------------------------------------------------
FLINKFLAGS =


#---------------------------------------------------------------------------
# Parallel C:
#
# For IS, which is in C, the following must be defined:
#
# CC         - C compiler 
# CFLAGS     - C compilation arguments
# C_INC      - any -I arguments required for compiling C 
# CLINK      - C linker
# CLINKFLAGS - C linker flags
# C_LIB      - any -L and -l arguments required for linking C 
#
# compilations are done with $$(CC) $$(C_INC) $$(CFLAGS) or
#                            $$(CC) $$(CFLAGS)
# linking is done with       $$(CLINK) $$(C_LIB) $$(CLINKFLAGS)
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# This is the C compiler used for OpenMP programs
#---------------------------------------------------------------------------
CC = $CC
# This links C programs; usually the same as $${CC}
CLINK	= $CC -lm

#---------------------------------------------------------------------------
# These macros are passed to the linker 
#---------------------------------------------------------------------------
C_LIB  =

#---------------------------------------------------------------------------
# These macros are passed to the compiler 
#---------------------------------------------------------------------------
C_INC = -I../common

#---------------------------------------------------------------------------
# Global *compile time* flags for C programs
#---------------------------------------------------------------------------
CFLAGS	= $CFLAGS
# CFLAGS = -g

#---------------------------------------------------------------------------
# Global *link time* flags. Flags for increasing maximum executable 
# size usually go here. 
#---------------------------------------------------------------------------
CLINKFLAGS =


#---------------------------------------------------------------------------
# Utilities C:
#
# This is the C compiler used to compile C utilities.  Flags required by 
# this compiler go here also; typically there are few flags required; hence 
# there are no separate macros provided for such flags.
#---------------------------------------------------------------------------
UCC	= $CC $CFLAGS


#---------------------------------------------------------------------------
# Destination of executables, relative to subdirs of the main directory. . 
#---------------------------------------------------------------------------
BINDIR	= $DEST


#---------------------------------------------------------------------------
# The variable RAND controls which random number generator 
# is used. It is described in detail in Doc/README.install. 
# Use "randi8" unless there is a reason to use another one. 
# Other allowed values are "randi8_safe", "randdp" and "randdpvec"
#---------------------------------------------------------------------------
# RAND   = randi8
# The following is highly reliable but may be slow:
RAND   = randdp


#---------------------------------------------------------------------------
# The variable WTIME is the name of the wtime source code module in the
# NPB2.x/common directory.  
# For most machines,       use wtime.c
# For SGI power challenge: use wtime_sgi64.c
#---------------------------------------------------------------------------
WTIME  = wtime.c


#---------------------------------------------------------------------------
# Enable if either Cray or IBM: 
# (no such flag for most machines: see common/wtime.h)
# This is used by the C compiler to pass the machine name to common/wtime.h,
# where the C/Fortran binding interface format is determined
#---------------------------------------------------------------------------
# MACHINE	=	-DCRAY
# MACHINE	=	-DIBM
EOT

process ft
process mg 
process sp
process lu
process bt
process is
process ep
process cg