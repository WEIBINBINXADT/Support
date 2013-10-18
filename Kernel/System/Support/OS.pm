# --
# Kernel/System/Support/OS.pm - all required system information
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Support::OS;
## nofilter(TidyAll::Plugin::OTRS::Perl::LayoutObject)

use strict;
use warnings;

use Kernel::System::Environment;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Object (qw(MainObject ConfigObject LogObject EncodeObject DBObject LayoutObject)) {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    # create additional objects
    $Self->{LanguageObject}    = $Self->{LayoutObject}->{LanguageObject};
    $Self->{EnvironmentObject} = Kernel::System::Environment->new( %{$Self} );

    return $Self;
}

sub AdminChecksGet {
    my ( $Self, %Param ) = @_;

    # get names of available checks from sysconfig
    my $Checks = $Self->{ConfigObject}->Get('Support::OS');

    # find out which checks should are enabled in sysconfig
    my @EnabledCheckFunctions;
    if ( $Checks && ref $Checks eq 'HASH' ) {

        # get all enabled check function names
        @EnabledCheckFunctions = sort grep { $Checks->{$_} } keys %{$Checks};
    }

    # to store the result
    my @DataArray;

    FUNCTIONNAME:
    for my $FunctionName (@EnabledCheckFunctions) {

        # prepend an underscore
        $FunctionName = '_' . $FunctionName;

        # run function and get check data
        my $Check = $Self->$FunctionName();

        next FUNCTIONNAME if !$Check;

        # attach check data if valid
        push @DataArray, $Check;
    }

    return \@DataArray;
}

sub _DistributionCheck {
    my ( $Self, %Param ) = @_;

    my %OSInfo = $Self->{EnvironmentObject}->OSInfoGet();

    # if OSname starts with Unknown, test was not successful
    my $Result = $OSInfo{OSName} =~ /\A Unknown /xms ? 'Failed' : 'OK';

    my $ReturnHash = {
        Name        => $Self->{LanguageObject}->Get('Distribution'),
        Description => $Self->{LanguageObject}->Get('Shows the used distribution.'),
        Comment     => $OSInfo{OSName},
        Check       => 'OK',
    };

    return $ReturnHash;
}

sub _KernelInfoCheck {
    my ( $Self, %Param ) = @_;

    my $ReturnHash = {};

    # If used OS is a linux system
    if ( $^O =~ /(linux|unix|netbsd|freebsd|darwin)/i ) {
        my $TmpLine = "";
        my $KernelInfo;
        if ( open( $KernelInfo, "-|", "uname -a" ) ) {    ## no critic
            while (<$KernelInfo>) {
                $TmpLine .= $_;
            }
            close($KernelInfo);
            if ($TmpLine) {
                $TmpLine =~ s/\s+$//g;
                $TmpLine =~ s/^\s+//g;
                $ReturnHash = {
                    Name        => $Self->{LanguageObject}->Get('Kernel Version'),
                    Description => $Self->{LanguageObject}->Get('Shows the used Kernel version.'),
                    Comment     => "\"$TmpLine\" " . $Self->{LanguageObject}->Get('is used.'),
                    Check       => 'OK',
                };
            }
        }
        else {
            $ReturnHash = {
                Name        => $Self->{LanguageObject}->Get('Kernel Version'),
                Description => $Self->{LanguageObject}->Get('Shows the used Kernel version.'),
                Comment     => $Self->{LanguageObject}->Get("Can\'t execute uname -a..."),
                Check       => 'Critical',
            };
        }
    }
    elsif ( $^O =~ /win32/i ) {
        return;
    }
    return $ReturnHash;
}

sub _PerlCheck {
    my ( $Self, %Param ) = @_;

    my $ReturnHash = {};

    # check verison string
    my $Version = sprintf "%vd", $^V;
    my $OS      = sprintf "$^O", $^V;
    my $Build   = '';

    # ActivePerl detection
    if ( $^O =~ /win32/i ) {
        $Self->{MainObject}->Require('Win32');

        # Win32::BuildNumber() is only available on ActivePerl, NOT on Strawberry.
        no strict 'refs';    ## no critic
        if ( defined &Win32::BuildNumber ) {
            $Build = ' (ActiveState build ' . Win32::BuildNumber() . ')';
        }
        else {
            $Build = ' (StrawberryPerl)';
        }
        use strict;
    }

    if ( $Version =~ /(\d+)\.(\d+)\.(\d+)/i ) {
        if ( $1 <= 5 && $2 <= 8 && $3 <= 7 ) {
            $ReturnHash = {
                Name        => $Self->{LanguageObject}->Get('PerlCheck'),
                Description => $Self->{LanguageObject}->Get('Check Perl version.'),
                Comment =>
                    $Self->{LanguageObject}->Get('Your Perl') . " $Version$Build ($OS)" .
                    $Self->{LanguageObject}
                    ->Get('is too old, you should upgrade to Perl 5.8.8 or higher.'),
                Check => 'Failed',
            };

        }
        else {
            $ReturnHash = {
                Name        => $Self->{LanguageObject}->Get('PerlCheck'),
                Description => $Self->{LanguageObject}->Get('Check Perl version.'),
                Comment => "Perl $Version$Build ($OS) " . $Self->{LanguageObject}->Get('is used.'),
                Check   => 'OK',
            };
        }
    }
    else {
        $ReturnHash = {
            Name        => $Self->{LanguageObject}->Get('PerlCheck'),
            Description => $Self->{LanguageObject}->Get('Check Perl version.'),
            Comment     => $Self->{LanguageObject}->Get('Unable to parse version string')
                . " ($Version$Build / $OS).",
            Check => 'Critical',
        };
    }

    return $ReturnHash;
}

sub _PerlModulesCheck {
    my ( $Self, %Param ) = @_;

    my $ReturnHash = {};
    my $Home       = $Self->{ConfigObject}->Get('Home');
    my $TmpSumString;

    my $Output;
    ## no critic
    open( my $FH, "-|", "perl $Home/bin/otrs.CheckModules.pl nocolors --all" );
    ## use critic

    while (<$FH>) {
        $Output .= $_;
    }
    close($FH);

    if (
        $Output =~ m{Not \s installed! \s \(Required}smx
        || $Output =~ m{failed!}smx
        )
    {
        $ReturnHash = {
            Name        => $Self->{LanguageObject}->Get('PerlModulesCheck'),
            Description => $Self->{LanguageObject}->Get('Check Perl Modules installed.'),
            Comment =>
                $Self->{LanguageObject}->Get(
                'There is an error in your installed perl modules configuration. Please contact your administrator.'
                )
            ,
            Check         => 'Failed',
            BlockStyle    => 'TextArea',
            ContentString => $Output,
        };

    }
    else {
        $ReturnHash = {
            Name        => $Self->{LanguageObject}->Get('PerlModulesCheck'),
            Description => $Self->{LanguageObject}->Get('Check Perl Modules installed.'),
            Comment     => $Self->{LanguageObject}
                ->Get('All Perl modules needed are currently installed.'),
            Check         => 'OK',
            BlockStyle    => 'TextArea',
            ContentString => $Output,
        };
    }

    return $ReturnHash;
}

sub _MemorySwapCheck {
    my ( $Self, %Param ) = @_;
    my $ReturnHash = {};

    my $MemInfoFile;
    my $MemTotal;
    my $MemFree;
    my $SwapTotal;
    my $SwapFree;

    # If used OS is a linux system
    if ( $^O =~ /(linux|unix|netbsd|freebsd|darwin)/i ) {
        if ( open( $MemInfoFile, '<', "/proc/meminfo" ) ) {    ## no critic
            while (<$MemInfoFile>) {
                my $TmpLine = $_;
                if ( $TmpLine =~ /MemTotal/ ) {
                    $TmpLine =~ s/^.*?(\d+).*$/$1/;
                    $MemTotal = int($TmpLine);
                }
                elsif ( $TmpLine =~ /MemFree/ ) {
                    $TmpLine =~ s/^.*?(\d+).*$/$1/;
                    $MemFree = int($TmpLine);
                }
                elsif ( $TmpLine =~ /SwapTotal/ ) {
                    $TmpLine =~ s/^.*?(\d+).*$/$1/;
                    $SwapTotal = int($TmpLine);
                }
                elsif ( $TmpLine =~ /SwapFree/ ) {
                    $TmpLine =~ s/^.*?(\d+).*$/$1/;
                    $SwapFree = int($TmpLine);
                }
            }
            close($MemInfoFile);

            # build return hash
            my $Description
                = $Self->{LanguageObject}->Get('The Host System has') . ": \n"
                . int( $MemTotal / 1024 ) . ' '
                . $Self->{LanguageObject}->Get('MB Memory total') . " \n"
                . int( $MemFree / 1024 ) . ' '
                . $Self->{LanguageObject}->Get('MB Memory free') . " \n"
                . int( $SwapTotal / 1024 ) . ' '
                . $Self->{LanguageObject}->Get('MB Swap total') . " \n"
                . int( $SwapFree / 1024 ) . ' '
                . $Self->{LanguageObject}->Get('MB Swap free');

            if ( !$SwapTotal ) {
                $ReturnHash = {
                    Name        => $Self->{LanguageObject}->Get('Memory Swap Check'),
                    Description => $Self->{LanguageObject}->Get(
                        'A Memory Check. We try to find out if '
                            . 'SwapFree : SwapTotal < 60 % '
                            . 'or if more than 200 MB Swap is used.'
                    ),
                    Comment => $Self->{LanguageObject}->Get('No Swap enabled!'),
                    Check   => 'Critical',
                };
            }
            elsif (
                ( ($SwapFree) / ($SwapTotal) < 60 )
                || ( ($SwapTotal) - ($SwapFree) > 20000 )
                )
            {
                $ReturnHash = {
                    Name        => $Self->{LanguageObject}->Get('Memory Swap Check'),
                    Description => $Self->{LanguageObject}->Get(
                        'A Memory Check. We try to find out if '
                            . 'SwapFree : SwapTotal < 60 % '
                            . 'or if more than 200 MB Swap is used.'
                    ),
                    Comment => "$Description",
                    Check   => 'OK',
                };
            }
            else {
                $ReturnHash = {
                    Name        => $Self->{LanguageObject}->Get('Memory Swap Check'),
                    Description => $Self->{LanguageObject}->Get(
                        'A Memory Check. We try to find out if '
                            . 'SwapFree : SwapTotal < 60 % '
                            . 'or if more than 200 MB Swap is used.'
                    ),
                    Comment => "$Description",
                    Check   => 'Failed',
                };
            }
        }
    }
    elsif ( $^O =~ /win32/i ) {
        return;
    }

    return $ReturnHash;
}

sub _CPULoadCheck {
    my ( $Self, %Param ) = @_;

    my $ReturnHash = {};

    # check needed stuff
    for (qw()) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }
    my @SplitArray;

    # If used OS is a linux system
    if ( $^O =~ /(linux|unix|netbsd|freebsd|darwin)/i ) {

        # linux systems
        if ( -e "/proc/loadavg" ) {
            my $LoadFile;
            open( $LoadFile, '<', "/proc/loadavg" );    ## no critic
            while (<$LoadFile>) {
                @SplitArray = split( " ", $_ );
            }
            close($LoadFile);
        }

        # mac os
        elsif ( $^O =~ /darwin/i ) {
            if ( open( my $In, "-|", "sysctl vm.loadavg" ) ) {    ## no critic
                while (<$In>) {
                    if ( my ($Loads) = $_ =~ /vm\.loadavg: \s* \{ \s*  (.*) \s* \}/smx ) {
                        @SplitArray = split ' ', $Loads;
                    }
                }
                close $In;
            }
        }

        if (@SplitArray) {

            # build return hash
            my $Description
                = $Self->{LanguageObject}->Get('The Host System has a load') . ": \n"
                . $SplitArray[0] . ' '
                . $Self->{LanguageObject}->Get('in the last 1 minute') . " \n"
                . $SplitArray[1] . ' '
                . $Self->{LanguageObject}->Get('in the last 5 minutes') . " \n"
                . $SplitArray[2] . ' '
                . $Self->{LanguageObject}->Get('in the last 15 minutes');

            if ( $SplitArray[2] < '1.00' ) {
                $ReturnHash = {
                    Name        => $Self->{LanguageObject}->Get('CPU Load'),
                    Description => $Self->{LanguageObject}->Get(
                        'A CPU load check. We try to find out if '
                            . 'the system load in the last 15 minutes > 1.'
                    ),
                    Comment => "$Description",
                    Check   => 'OK',
                };
            }
            else {
                $ReturnHash = {
                    Name        => $Self->{LanguageObject}->Get('CPU Load'),
                    Description => $Self->{LanguageObject}->Get(
                        'A CPU load check. We try to find out if '
                            . 'the system load in the last 15 minutes < 1.'
                    ),
                    Comment => "$Description",
                    Check   => 'Failed',
                };
            }
        }
    }
    elsif ( $^O =~ /win32/i ) {
        return;
    }
    return $ReturnHash;
}

sub _DiskUsageCheck {
    my ( $Self, %Param ) = @_;

    my $Data    = {};
    my $Check   = 'OK';
    my $Message = '';

    # If used OS is a linux system
    if ( $^O =~ /(linux|unix|netbsd|freebsd|darwin)/i ) {
        my $Commandline = "df -lx tmpfs -x iso9660 -x udf -x squashfs";

        # current MacOS and FreeBSD does not support the -x flag for df
        if ( $^O =~ /(darwin|freebsd)/i ) {
            $Commandline = "df -l";
        }

        my $In;
        if ( open( $In, "-|", "$Commandline" ) ) {    ## no critic
            while (<$In>) {
                if ( $_ =~ /^(.+?)\s.*\s(\d\d\d|\d\d|\d)%.+?$/ ) {
                    if ( $2 > 90 ) {
                        $Check = 'Failed';
                    }
                    if ( $Check ne 'Failed' && $2 > 85 ) {
                        $Check = 'Critical';
                    }
                    if ($Message) {
                        $Message .= ",";
                    }
                    $Message .= "$1\[$2%\]";
                }
            }
            close($In);
            if ( $Check eq 'Failed' ) {
                $Message = $Self->{LanguageObject}->Get('Disk is full') . " ($Message).";
            }
            else {
                $Message = $Self->{LanguageObject}->Get('Disk usage') . " ($Message).";
            }
        }
        $Data = {
            Name        => $Self->{LanguageObject}->Get('Disk Usage'),
            Description => $Self->{LanguageObject}->Get('Check disk usage.'),
            Comment     => $Message,
            Check       => $Check,
        };
        return $Data;
    }
}

1;
