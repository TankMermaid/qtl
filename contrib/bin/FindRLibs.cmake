# - Find R libraries - much simplified and works with NIX
#
# This module finds if R is installed and determines where the include files
# and libraries are. It also determines what the name of the library is. This
# code sets the following variables:
#
# SET(R_INCLUDE_PATH "c:/Progra~1/R/R-2.9.1/include")
# SET(RBLAS_LIBRARY "c:/Progra~1/R/r-2.9.1/include/ext")
# SET(R_EXECUTABLE "c:/Progra~1/R/r-2.9.1/bin")
#
# R can be queried with:
#
#   R CMD config --cppflags
#   R CMD config --ldflags
#
# Also pkg-config can be used with --cflags libR etc.

IF(WIN32)
  MESSAGE("Trying to find R on Windows")
  SET(R_EXECUTABLE "C:/Program Files/R/R-2.9.1/bin/R.EXE")
ELSE()
  MESSAGE("Trying to find R on Unix")
ENDIF()

FIND_PROGRAM(R_EXECUTABLE R)

IF(R_EXECUTABLE)
  GET_FILENAME_COMPONENT(R_BINPATH ${R_EXECUTABLE} PATH)  
  GET_FILENAME_COMPONENT(R_PATH ${R_BINPATH} PATH)  
  IF (WIN32)
	SET(R_LIBRARY ${R_BINPATH}/R.DLL)
	SET(R_LIKELY_INCLUDE_PATH ${R_PATH}/include)
  ELSE()
	SET(R_LIBRARY ${R_BINPATH}/bin/libR.so)
	SET(R_LIKELY_INCLUDE_PATH ${R_PATH}/lib/R/include)
  ENDIF()
ENDIF(R_EXECUTABLE)

# ---- Find R.h and the Rlib.so shared library
SET(R_POSSIBLE_INCLUDE_PATHS
  /usr/share/R/include
)
FIND_PATH(R_INCLUDE_PATH R.h
  ${R_LIKELY_INCLUDE_PATH}
  ${R_POSSIBLE_INCLUDE_PATHS}
)

INCLUDE_DIRECTORIES(${R_INCLUDE_PATH})

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(RLibs DEFAULT_MSG R_LIBRARY R_INCLUDE_PATH)

GET_FILENAME_COMPONENT(R_LIBRARY_PATH ${R_LIBRARY} PATH)  

IF (WIN32)
  FIND_LIBRARY(RBLAS_LIBRARY NAMES Rblas.dll PATHS 
    ${R_BINPATH}
  )
ELSE()
  FIND_LIBRARY(RBLAS_LIBRARY NAMES libRblas.so PATHS 
    ${R_LIBRARY_PATH}
  )
ELSE()
ENDIF()

MESSAGE("R_EXECUTABLE=${R_EXECUTABLE}")
MESSAGE("R_INCLUDE_PATH=${R_INCLUDE_PATH}")
MESSAGE("R_LIBRARY=${R_LIBRARY}")
MESSAGE("RBLAS_LIBRARY=${RBLAS_LIBRARY}")

if(NOT EXISTS ${R_LIBRARY})
	message(FATAL_ERROR "${R_LIBRARY} was not found (has R been built as shared library libR.so?)")
endif(NOT EXISTS ${R_LIBRARY})

# ---- find the biolib_R Clib module for mapping...
SET(_RLIBNAME ${MAP_projectname}_R)
SET(_RLIBPATH ${MAP_CLIBS_PATH}/${_RLIBNAME})
INCLUDE_DIRECTORIES(${_RLIBPATH}/include)
if(NOT BUILD_LIBS)
  SET(_LIBNAME ${_RLIBNAME}-${MAP_VERSION})
  SET(_LINKLIB lib${_LIBNAME}.so)
  IF(CYGWIN)
    SET(_LINKLIB lib${_LIBNAME}.dll.a)
  ENDIF(CYGWIN)
  IF(APPLE)
    SET(_LINKLIB lib${_LIBNAME}.dylib)
  ENDIF(APPLE)
  message("Looking for ${_LINKLIB} in ${_RLIBPATH}")
  FIND_LIBRARY(R_LIBRARY NAMES ${_LINKLIB} HINTS ${_RLIBPATH}/build ${_RLIBPATH}/src)
  IF(BIOLIB AND NOT BIOLIB_R_LIBRARY)
    FIND_LIBRARY(BIOLIB_R_LIBRARY NAMES ${_LINKLIB} PATHS ${_RLIBPATH}/build ${_RLIBPATH}/src)
  ENDIF()
  message("Found ${BIOLIB_R_LIBRARY}")
endif(NOT BUILD_LIBS)
# UNSET(_LIBNAME)
SET(_LIBNAME 'unknown')

MARK_AS_ADVANCED(
  R_INCLUDE_PATH
  R_EXECUTABLE
  R_LIBRARY
  RBLAS_LIBRARY
  BIOLIB_R_LIBRARY
  )