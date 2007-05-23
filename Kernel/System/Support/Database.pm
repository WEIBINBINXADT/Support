# --
# Kernel/System/Support/Database.pm - all required system informations
# Copyright (C) 2001-2007 OTRS GmbH, http://otrs.org/
# --
# $Id: Database.pm,v 1.2 2007-05-23 17:23:14 sr Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
# --

package Kernel::System::Support::Database;

use strict;

use vars qw(@ISA $VERSION);
$VERSION = '$Revision: 1.2 $';
$VERSION =~ s/^\$.*:\W(.*)\W.+?$/$1/;

=head1 NAME

Kernel::System::Support::Database - global system informations

=head1 SYNOPSIS

All required system informations to a running OTRS host.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create Database info object

    use Kernel::Config;
    use Kernel::System::Log;
    my $ConfigObject = Kernel::Config->new();
    my $LogObject = Kernel::System::Log->new(
        ConfigObject => $ConfigObject,
    );

    $SystemInfoObject = Kernel::System::Support::Database->new(
        ConfigObject => $ConfigObject,
        LogObject => $LogObject,
    );

=cut

sub new {
    my $Type = shift;
    my %Param = @_;
    # allocate new hash for object
    my $Self = {};
    bless ($Self, $Type);
    # check needed objects
    foreach (qw(ConfigObject LogObject MainObject)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    return $Self;
}

=item SupportConfigArrayGet()

return an array reference with required config information.

    $ArrayRef = $Support->SupportConfigArrayGet();

    my $ConfigArray = [
        {
            Key => 'TicketDump',
            Name => 'Dump Tickets',
            Description => 'Please tell me how many latest Tickets we shut dump?',
            Input => {
                Type => 'Select',
                Data => {
                    All => 'All',
                    0 => '0',
                    10 => 'Last 10',
                    100 => 'Last 100',
                    1000 => 'Last 1000',
                },
            },
        },
        {
            Key => 'ApacheHome',
            Name => 'Apache Home Directory',
            Description => 'Please tell me the path to the Apache home directory (/etc/apache2)',
            Input => {
                Type => 'Text',
                Size => 40,
            },
        },
    ];

=cut

sub SupportConfigArrayGet {
    my $Self = shift;
    my %Param = @_;
    # check needed stuff
    foreach (qw()) {
        if (!$Param{$_}) {
            $Self->{LogObject}->Log(Priority => 'error', Message => "Need $_!");
            return;
        }
    }

    # ------------------------------------------------------------ #
    # Get information about all databases
    # ------------------------------------------------------------ #

    # create config array
    my $ConfigArray = [
        {
            Key => 'TicketDump',
            Name => 'Dump Tickets',
            Description => 'Please tell me how many latest Tickets we shut dump?',
            Input => {
                Type => 'Select',
                Data => {
                    All => 'All',
                    0 => '0',
                    10 => 'Last 10',
                    100 => 'Last 100',
                    1000 => 'Last 1000',
                },
            },
        },
    ];

    # ------------------------------------------------------------ #
    # Get information about used database
    # ------------------------------------------------------------ #

    # try to find out which ticket database is configured
    my $DatabaseType = $Self->{ConfigObject}->Get('DatabaseDSN');
    $DatabaseType =~ s/^.*?:(.*?):.*$/$1/;

    # try to get availible modules and the directory name
    my $DirName = $Self->{ConfigObject}->Get('Home')."/Kernel/System/Support/Database";
    # read all availible modules in @List
    my @List = glob($DirName."/*.pm");
    foreach my $File (@List) {
        # remove .pm
        $File =~ s/^.*\/(.+?)\.pm$/$1/;
        if ($DatabaseType eq $File) {
            my $GenericModule = "Kernel::System::Support::Database::$File";
            # load module $GenericModule and check if loadable
            if ($Self->{MainObject}->Require($GenericModule)){
                # create new object
                my $SupportObject = $GenericModule->new(%{$Self});
                if ($SupportObject) {
                    my $ArrayRef = $SupportObject->SupportConfigArrayGet();
                    if ($ArrayRef && ref($ArrayRef) eq 'ARRAY') {
                        push (@{$ConfigArray}, @{$ArrayRef});
                    }
                }
            }
        }
    }
    # return config array
    return $ConfigArray;
}

=item SupportInfoGet()

returns a array reference with support information.

$DatabaseArray => [
            {
                Key => 'Plattform',
                Name => 'Plattform',
                Comment => 'Linux',
                Description => 'Please add more memory.',
                Check => 'OK',
            },
            {
                Key => 'Version',
                Name => 'Version',
                Comment => 'openSUSE 10.2',
                Description => 'Please add more memory.',
                Check => 'OK',
            },
        ];

=cut

sub SupportInfoGet {
    my $Self = shift;
    my %Param = @_;
    my $DataArray = [];
    # check needed stuff
    foreach (qw(ModuleInputHash)) {
        if (!$Param{$_}) {
            $Self->{LogObject}->Log(Priority => 'error', Message => "Need $_!");
            return;
        }
    }
    if (ref($Param{ModuleInputHash}) ne 'HASH') {
        $Self->{LogObject}->Log(Priority => 'error', Message => "ModuleInputHash must be a hash reference!");
        return;
    }

    # ------------------------------------------------------------ #
    # Get information about all databases
    # ------------------------------------------------------------ #

    # please add for each new check a part like this
#    my $OneCheck = $Self->Check(
#        Type => $Param{ModuleInputHash}->{Type} || '',
#    );
#    push (@{$DataArray}, $OneCheck);

    # ------------------------------------------------------------ #
    # Get information about used database
    # ------------------------------------------------------------ #

    # try to find out which ticket database is configured
    my $DatabaseType = $Self->{ConfigObject}->Get('DatabaseDSN');
    $DatabaseType =~ s/^.*?:(.*?):.*$/$1/;

    # try to get availible modules and the directory name
    my $DirName = $Self->{ConfigObject}->Get('Home')."/Kernel/System/Support/Database";
    # read all availible modules in @List
    my @List = glob($DirName."/*.pm");
    foreach my $File (@List) {
        # remove .pm
        $File =~ s/^.*\/(.+?)\.pm$/$1/;
        if ($DatabaseType =~ /ODBC/i) {
            $DatabaseType = $Self->{ConfigObject}->Get('Database::Type');
        }
        if ($DatabaseType eq $File) {
            my $GenericModule = "Kernel::System::Support::Database::$File";
            # load module $GenericModule and check if loadable
            if ($Self->{MainObject}->Require($GenericModule)){
                # create new object
                my $SupportObject = $GenericModule->new(%{$Self});
                if ($SupportObject) {
                    my $ArrayRef = $SupportObject->SupportInfoGet();
                    if ($ArrayRef && ref($ArrayRef) eq 'ARRAY') {
                        push (@{$DataArray}, @{$ArrayRef});
                    }
                }
            }
        }
    }

    return $DataArray;
}

=item AdminChecksGet()

returns a array reference with AdminChecks information.

$DatabaseArray => [
            {
                Key => 'Plattform',
                Name => 'Plattform',
                Comment => 'Linux',
                Description => 'Please add more memory.',
                Check => 'OK',
            },
            {
                Key => 'Version',
                Name => 'Version',
                Comment => 'openSUSE 10.2',
                Description => 'Please add more memory.',
                Check => 'OK',
            },
        ];

=cut

sub AdminChecksGet {
    my $Self = shift;
    my %Param = @_;
    my $DataArray = [];
    # check needed stuff
    foreach (qw()) {
        if (!$Param{$_}) {
            $Self->{LogObject}->Log(Priority => 'error', Message => "Need $_!");
            return;
        }
    }

    # ------------------------------------------------------------ #
    # Get information about all databases
    # ------------------------------------------------------------ #

    # please add for each new check a part like this
#    my $OneCheck = $Self->Check();
#    push (@{$DataArray}, $OneCheck);

    # ------------------------------------------------------------ #
    # Get information about used database
    # ------------------------------------------------------------ #

    # try to find out which ticket database is configured
    my $DatabaseType = $Self->{ConfigObject}->Get('DatabaseDSN');
    $DatabaseType =~ s/^.*?:(.*?):.*$/$1/;
    # try to get availible modules and the directory name
    my $DirName = $Self->{ConfigObject}->Get('Home')."/Kernel/System/Support/Database";
    # read all availible modules in @List
    my @List = glob($DirName."/*.pm");
    foreach my $File (@List) {
        # remove .pm
        $File =~ s/^.*\/(.+?)\.pm$/$1/;
        if ($DatabaseType =~ /^$File/i) {
            my $GenericModule = "Kernel::System::Support::Database::$File";
            # load module $GenericModule and check if loadable
            if ($Self->{MainObject}->Require($GenericModule)){
                # create new object
                my $SupportObject = $GenericModule->new(%{$Self});
                if ($SupportObject) {
                    my $ArrayRef = $SupportObject->AdminChecksGet();
                    if ($ArrayRef && ref($ArrayRef) eq 'ARRAY') {
                        push (@{$DataArray}, @{$ArrayRef});
                    }
                }
            }
        }

    }

    return $DataArray;
}

=item Check()

returns a hash reference with Check information.

$CheckHash =>
            {
                Key => 'Plattform',
                Name => 'Plattform',
                Comment => 'Linux',
                Description => 'Please add more memory.',
                Check => 'OK',
            };

# check if config value availible
if ($Param{Type}) {
    print STDERR "TYPE: " . $Param{Type};
}

=cut

sub Check {
    my $Self = shift;
    my %Param = @_;
    my $ReturnHash = {};
    # check needed stuff
    foreach (qw()) {
        if (!$Param{$_}) {
            $Self->{LogObject}->Log(Priority => 'error', Message => "Need $_!");
            return;
        }
    }

    # If used OS is a linux system
    if ($^O =~ /linux/ || /unix/ || /netbsd/ || /freebsd/ || /Darwin/) {

    }
    elsif ($^O =~ /win/i) {# TODO / Ausgabe unter Windows noch pruefen

    }
    return $ReturnHash;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (http://otrs.org/).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see http://www.gnu.org/licenses/gpl.txt.

=cut

=head1 VERSION

$Revision: 1.2 $ $Date: 2007-05-23 17:23:14 $

=cut