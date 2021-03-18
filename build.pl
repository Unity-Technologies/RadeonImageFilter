#!/usr/bin/env perl -w
use Cwd qw(getcwd);
use File::Path;

my $pathToLib;
BEGIN { $pathToLib = getcwd . '/3rdparty/Perl/lib' }
use lib $pathToLib;
use File::Copy::Recursive qw(fcopy dircopy);
use Config;
use Archive::Zip;

my $err; # used by CheckFileError

sub CopyHeaders
{
	mkpath('artifacts/include', {error => \ $err} );
	CheckFileError();
	dircopy("include", "artifacts/include") or die("Failed to copy headers.");
}

sub CheckFileError
{
	if (@$err) 
	{
		for my $diag (@$err) 
		{
			my ($file, $message) = %$diag;
			if ($file eq '') 
			{
			  die("general error: $message\n");
			}
			else 
			{
			  die("problem unlinking $file: $message\n");
			}
		}
	}
}


mkpath('artifacts', {error => \ $err} );
CheckFileError();
mkpath('artifacts/lib', {error => \ $err} );
CheckFileError();
mkpath('artifacts/bin', {error => \ $err} );
CheckFileError();
mkpath('builds', {error => \ $err} );
CheckFileError();

CopyHeaders();

if ($Config{osname} eq "darwin")
{
	mkpath('artifacts/lib/macOS', {error => \ $err} );
	CheckFileError();
	
	# TODO add macOS support
}

#if ($Config{osname} eq "linux")
{
	#mkpath('artifacts/lib/linux', {error => \ $err} );
	#CheckFileError();
	
	# .so files	
	fcopy("Ubuntu18/Dynamic/libRadeonImageFilters.so", "artifacts/bin/Linux/libRadeonImageFilters.so") or die "Copy of libRadeonImageFilters.so failed: $!";
	fcopy("Ubuntu18/Dynamic/libRadeonImageFilters.so.1", "artifacts/bin/Linux/libRadeonImageFilters.so.1") or die "Copy of libRadeonImageFilters.so.1 failed: $!";
	fcopy("Ubuntu18/Dynamic/libRadeonImageFilters.so.1.7.0", "artifacts/bin/Linux/libRadeonImageFilters.so.1.7.0") or die "Copy of libRadeonImageFilters.so.1.7.0 failed: $!";
	
	fcopy("Ubuntu18/Dynamic/libRadeonML.so", "artifacts/bin/Linux/libRadeonML.so") or die "Copy of libRadeonML.so failed: $!";
	fcopy("Ubuntu18/Dynamic/libRadeonML.so.0", "artifacts/bin/Linux/libRadeonML.so.0") or die "Copy of libRadeonML.so.0 failed: $!";
	fcopy("Ubuntu18/Dynamic/libRadeonML.so.0.9.11", "artifacts/bin/Linux/libRadeonML.so.0.9.11") or die "Copy of libRadeonML.so.0.9.11 failed: $!";
	
	fcopy("Ubuntu18/Dynamic/libRadeonML_MIOpen.so", "artifacts/bin/Linux/libRadeonML_MIOpen.so") or die "Copy of libRadeonML_MIOpen.so failed: $!";
	fcopy("Ubuntu18/Dynamic/libRadeonML_MIOpen.so.0", "artifacts/bin/Linux/libRadeonML_MIOpen.so.0") or die "Copy of libRadeonML_MIOpen.so.0 failed: $!";
	fcopy("Ubuntu18/Dynamic/libRadeonML_MIOpen.so.0.9.11", "artifacts/bin/Linux/libRadeonML_MIOpen.so.0.9.11") or die "Copy of libRadeonML_MIOpen.so.0.9.11 failed: $!";
	
	fcopy("Ubuntu18/Dynamic/libMIOpen.so", "artifacts/bin/Linux/libMIOpen.so") or die "Copy of libMIOpen.so failed: $!";
	fcopy("Ubuntu18/Dynamic/libMIOpen.so.2", "artifacts/bin/Linux/libMIOpen.so.2") or die "Copy of libMIOpen.so.2 failed: $!";
	fcopy("Ubuntu18/Dynamic/libMIOpen.so.2.0.5", "artifacts/bin/Linux/libMIOpen.so.2.0.5") or die "Copy of libMIOpen.so.2.0.5 failed: $!";
}

if ($Config{osname} eq "MSWin32")
{	
	mkpath('artifacts/bin/Windows/Release', {error => \ $err} );
	CheckFileError();
	
	fcopy("Windows/Dynamic-MT/RadeonImageFilters.lib", "artifacts/lib/Windows/RadeonImageFilters.lib") or die "Copy of RadeonImageFilters.lib failed: $!";
	fcopy("Windows/Dynamic-MT/MIOpen.dll", "artifacts/bin/Windows/Release/MIOpen.dll") or die "Copy of MIOpen.dll failed: $!";
	fcopy("Windows/Dynamic-MT/RadeonImageFilters.dll", "artifacts/bin/Windows/Release/RadeonImageFilters.dll") or die "Copy of RadeonImageFilters.dll failed: $!";
	fcopy("Windows/Dynamic-MT/RadeonML.dll", "artifacts/bin/Windows/Release/RadeonML.dll") or die "Copy of RadeonML.dll failed: $!";
	fcopy("Windows/Dynamic-MT/RadeonML_MIOpen.dll", "artifacts/bin/Windows/Release/RadeonML_MIOpen.dll") or die "Copy of RadeonML_MIOpen.dll failed: $!";
	fcopy("Windows/Dynamic-MT/RadeonML_DirectML.dll", "artifacts/bin/Windows/Release/RadeonML_DirectML.dll") or die "Copy of RadeonML_DirectML.dll failed: $!";
	
	dircopy("models", "artifacts/kernels/models") or die("Failed to copy models.");
		
	# write build version.txt
	my $branch = qx("git symbolic-ref -q HEAD");
	my $revision = qx("git rev-parse HEAD");
	open(BUILD_INFO_FILE, '>', "artifacts/version.txt") or die("Unable to write build information to version.txt");
	print BUILD_INFO_FILE "$branch";
	print BUILD_INFO_FILE "$revision";
	close(BUILD_INFO_FILE);
}
