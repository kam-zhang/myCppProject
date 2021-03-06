# Copyright (C) 2001, 2003, 2004, 2006, 2008 Free Software Foundation,
# Inc.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.

# Written by Akim Demaille <akim@freefriends.org>.

###############################################################
# The main copy of this file is in Automake's CVS repository. #
# Updates should be sent to automake-patches@gnu.org.         #
###############################################################

package Automake::XFile;

=head1 NAME

Automake::XFile - supply object methods for filehandles with error handling

=head1 SYNOPSIS

    use Automake::XFile;

    $fh = new Automake::XFile;
    $fh->open ("< file");
    # No need to check $FH: we died if open failed.
    print <$fh>;
    $fh->close;
    # No need to check the return value of close: we died if it failed.

    $fh = new Automake::XFile "> file";
    # No need to check $FH: we died if new failed.
    print $fh "bar\n";
    $fh->close;

    $fh = new Automake::XFile "file", "r";
    # No need to check $FH: we died if new failed.
    defined $fh
    print <$fh>;
    undef $fh;   # automatically closes the file and checks for errors.

    $fh = new Automake::XFile "file", O_WRONLY | O_APPEND;
    # No need to check $FH: we died if new failed.
    print $fh "corge\n";

    $pos = $fh->getpos;
    $fh->setpos ($pos);

    undef $fh;   # automatically closes the file and checks for errors.

    autoflush STDOUT 1;

=head1 DESCRIPTION

C<Automake::XFile> inherits from C<IO::File>.  It provides the method
C<name> returning the file name.  It provides dying versions of the
methods C<close>, C<lock> (corresponding to C<flock>), C<new>,
C<open>, C<seek>, and C<truncate>.  It also overrides the C<getline>
and C<getlines> methods to translate C<\r\n> to C<\n>.

=head1 SEE ALSO

L<perlfunc>,
L<perlop/"I/O Operators">,
L<IO::File>
L<IO::Handle>
L<IO::Seekable>

=head1 HISTORY

Derived from IO::File.pm by Akim Demaille E<lt>F<akim@freefriends.org>E<gt>.

=cut

require 5.000;
use strict;
use vars qw($VERSION @EXPORT @EXPORT_OK $AUTOLOAD @ISA);
use Carp;
use Errno;
use IO::File;
use File::Basename;
use Automake::ChannelDefs;
use Automake::Channels qw(msg);
use Automake::FileUtils;

require Exporter;
require DynaLoader;

@ISA = qw(IO::File Exporter DynaLoader);

$VERSION = "1.2";

@EXPORT = @IO::File::EXPORT;

eval {
  # Make all Fcntl O_XXX and LOCK_XXX constants available for importing
  require Fcntl;
  my @O = grep /^(LOCK|O)_/, @Fcntl::EXPORT, @Fcntl::EXPORT_OK;
  Fcntl->import (@O);  # first we import what we want to export
  push (@EXPORT, @O);
};

# Used in croak error messages.
my $me = basename ($0);

################################################
## Constructor
##

sub new
{
  my $type = shift;
  my $class = ref $type || $type || "Automake::XFile";
  my $fh = $class->SUPER::new ();
  if (@_)
    {
      $fh->open (@_);
    }
  $fh;
}

################################################
## Open
##

sub open
{
  my $fh = shift;
  my ($file) = @_;

  # WARNING: Gross hack: $FH is a typeglob: use its hash slot to store
  # the `name' of the file we are opening.  See the example with
  # io_socket_timeout in IO::Socket for more, and read Graham's
  # comment in IO::Handle.
  ${*$fh}{'autom4te_xfile_file'} = "$file";

  if (!$fh->SUPER::open (@_))
    {
      fatal "cannot open $file: $!";
    }

  # In case we're running under MSWindows, don't write with CRLF.
  # (This circumvents a bug in at least Cygwin bash where the shell
  # parsing fails on lines ending with the continuation character '\'
  # and CRLF).
  binmode $fh if $file =~ /^\s*>/;
}

################################################
## Close
##

sub close
{
  my $fh = shift;
  if (!$fh->SUPER::close (@_))
    {
      my $file = $fh->name;
      Automake::FileUtils::handle_exec_errors $file
	unless $!;
      fatal "cannot close $file: $!";
    }
}

################################################
## Getline
##

# Some Win32/perl installations fail to translate \r\n to \n on input
# so we do that here.
sub getline
{
  local $_ = $_[0]->SUPER::getline;
  # Perform a _global_ replacement: $_ may can contains many lines
  # in slurp mode ($/ = undef).
  s/\015\012/\n/gs if defined $_;
  return $_;
}

################################################
## Getlines
##

sub getlines
{
  my @res = ();
  my $line;
  push @res, $line while $line = $_[0]->getline;
  return @res;
}

################################################
## Name
##

sub name
{
  my $fh = shift;
  return ${*$fh}{'autom4te_xfile_file'};
}

################################################
## Lock
##

sub lock
{
  my ($fh, $mode) = @_;
  # Cannot use @_ here.

  # Unless explicitly configured otherwise, Perl implements its `flock' with the
  # first of flock(2), fcntl(2), or lockf(3) that works.  These can fail on
  # NFS-backed files, with ENOLCK (GNU/Linux) or EOPNOTSUPP (FreeBSD); we
  # usually ignore these errors.  If $ENV{MAKEFLAGS} suggests that a parallel
  # invocation of GNU `make' has invoked the tool we serve, report all locking
  # failures and abort.
  #
  # On Unicos, flock(2) and fcntl(2) over NFS hang indefinitely when `lockd' is
  # not running.  NetBSD NFS clients silently grant all locks.  We do not
  # attempt to defend against these dangers.
  if (!flock ($fh, $mode))
    {
      my $make_j = (exists $ENV{'MAKEFLAGS'}
		    && " -$ENV{'MAKEFLAGS'}" =~ / (-[BdeikrRsSw]*j|---?jobs)/);
      my $note = "\nforgo `make -j' or use a file system that supports locks";
      my $file = $fh->name;

      msg ($make_j ? 'fatal' : 'unsupported',
	   "cannot lock $file with mode $mode: $!" . ($make_j ? $note : ""))
	if $make_j || !($!{ENOLCK} || $!{EOPNOTSUPP});
    }
}

################################################
## Seek
##

sub seek
{
  my $fh = shift;
  # Cannot use @_ here.
  if (!seek ($fh, $_[0], $_[1]))
    {
      my $file = $fh->name;
      fatal "$me: cannot rewind $file with @_: $!";
    }
}

################################################
## Truncate
##

sub truncate
{
  my ($fh, $len) = @_;
  if (!truncate ($fh, $len))
    {
      my $file = $fh->name;
      fatal "cannot truncate $file at $len: $!";
    }
}

1;

### Setup "GNU" style for perl-mode and cperl-mode.
## Local Variables:
## perl-indent-level: 2
## perl-continued-statement-offset: 2
## perl-continued-brace-offset: 0
## perl-brace-offset: 0
## perl-brace-imaginary-offset: 0
## perl-label-offset: -2
## cperl-indent-level: 2
## cperl-brace-offset: 0
## cperl-continued-brace-offset: 0
## cperl-label-offset: -2
## cperl-extra-newline-before-brace: t
## cperl-merge-trailing-else: nil
## cperl-continued-statement-offset: 2
## End:
