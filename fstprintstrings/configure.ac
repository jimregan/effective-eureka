AC_INIT([fstprintstrings], [1.0.0], [rws@xoba.com])
AM_INIT_AUTOMAKE([foreign nostdinc -Wall -Werror])

AC_PROG_CXX
AC_DISABLE_STATIC
AC_PROG_LIBTOOL

AC_CONFIG_SRCDIR([fstprintstrings.cc])
AC_CONFIG_FILES([
  Makefile
])

AC_LANG([C++])

AC_CHECK_TYPES([std::tr1::hash<long long unsigned>], [], [],
               [[#include <tr1/unordered_map>]])
AC_CHECK_TYPES([__gnu_cxx::slist<int>], [], [],
               [[#include <ext/slist>]])

AC_CHECK_HEADER([fst/fst.h], [],
 [AC_MSG_ERROR([fst/fst.h header not found])]
)

AC_OUTPUT
