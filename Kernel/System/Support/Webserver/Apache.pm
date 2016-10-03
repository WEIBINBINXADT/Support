# --
# Kernel/System/Support/Webserver/Apache.pm - all required system information
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Support::Webserver::Apache;
## nofilter(TidyAll::Plugin::OTRS::Perl::LayoutObject)

use strict;
use warnings;

use vars qw(@ISA $VERSION);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for (qw(ConfigObject LogObject LayoutObject)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    # create additional objects
    $Self->{LanguageObject} = $Self->{LayoutObject}->{LanguageObject};

    return $Self;
}

sub AdminChecksGet {
    my ( $Self, %Param ) = @_;

    # get names of available checks from sysconfig
    my $Checks = $Self->{ConfigObject}->Get('Support::Webserver::Apache');

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

sub _ApacheVersionCheck {
    my ( $Self, %Param ) = @_;

    my $Data    = {};
    my $Check   = '';
    my $Message = '';
    if ( $ENV{SERVER_SOFTWARE} ) {
        $Check   = 'OK';
        $Message = $Self->{LanguageObject}->Get('You are running') . " $ENV{SERVER_SOFTWARE}.";
    }
    else {
        $Check   = 'Failed';
        $Message = $Self->{LanguageObject}->Get('Could not determine Apache version.');
    }
    $Data = {
        Name        => $Self->{LanguageObject}->Get('Apache Version'),
        Description => $Self->{LanguageObject}->Get('Display web server version.'),
        Comment     => $Message,
        Check       => $Check,
    };
    return $Data;
}

sub _ApacheModDeflateCheck {
    my ( $Self, %Param ) = @_;

    my $Check   = 'Failed';
    my $Message = $Self->{LanguageObject}->Get("You should enable mod_deflate.");

    if ( $ENV{MOD_PERL} ) {
        if ( Apache2::Module::loaded('mod_deflate.c') ) {
            $Check   = 'OK';
            $Message = $Self->{LanguageObject}->Get("mod_deflate is enabled.");
        }
    }
    else {

        # just skip if not running mod_perl2
        return;
    }
    my $Data = {
        Name        => 'Mod_deflate',
        Description => $Self->{LanguageObject}->Get('Check if the system uses mod_deflate.'),
        Comment     => $Message,
        Check       => $Check,
    };
    return $Data;
}

sub _ApacheModHeadersCheck {
    my ( $Self, %Param ) = @_;

    my $Check   = 'Failed';
    my $Message = $Self->{LanguageObject}->Get("You should enable mod_headers.");

    if ( $ENV{MOD_PERL} ) {
        if ( Apache2::Module::loaded('mod_headers.c') ) {
            $Check   = 'OK';
            $Message = $Self->{LanguageObject}->Get("mod_headers is enabled.");
        }
    }
    else {

        # just skip if not running mod_perl2
        return;
    }
    my $Data = {
        Name        => 'Mod_headers',
        Description => $Self->{LanguageObject}->Get('Check if the system uses mod_headers.'),
        Comment     => $Message,
        Check       => $Check,
    };
    return $Data;
}

sub _ApacheEnvironmentCheck {
    my ( $Self, %Param ) = @_;

    my %Environment = %ENV;

    for my $NotNeededString (
        qw( HTTP_REFERER         HTTP_CACHE_CONTROL   HTTP_COOKIE    HTTP_USER_AGENT
        HTTP_ACCEPT_LANGUAGE HTTP_ACCEPT_ENCODING HTTP_ACCEPT
        QUERY_STRING         REQUEST_METHOD       REQUEST_URI    SCRIPT_NAME )
        )
    {
        delete $Environment{$NotNeededString};
    }

    my $Data = {
        Name        => $Self->{LanguageObject}->Get('Server Environment'),
        Description => $Self->{LanguageObject}->Get('Display environment variables'),
        Comment     => $Self->{LanguageObject}->Get('General information about your system.'),
        Check       => 'OK',
        BlockStyle  => 'TableDataSimple',
        TableInfo   => \%Environment,
    };
    return $Data;
}

sub _ApacheDBICheck {
    my ( $Self, %Param ) = @_;

    my $Data = {};

    # check if Apache::DBI is loaded
    my $ApacheDBI = 0;
    my $Check     = '';
    my $Message   = '';
    if ( $ENV{MOD_PERL} ) {
        for my $Module ( sort keys %INC ) {
            $Module =~ s/\//::/g;
            $Module =~ s/\.pm$//g;
            if ( $Module eq 'Apache::DBI' || $Module eq 'Apache2::DBI' ) {
                $ApacheDBI = $Module;
            }
        }
        if ( !$ApacheDBI ) {
            $Check   = 'Critical';
            $Message = $Self->{LanguageObject}->Get(
                'Apache::DBI should be used to get a better performance (pre-establish database connections).'
            );
        }
        else {
            $Check   = 'OK';
            $Message = $ApacheDBI;
        }
    }
    else {

        # Just skip this test if we' re not running mod_perl.
        return;
    }
    $Data = {
        Name        => 'Apache::DBI',
        Description => $Self->{LanguageObject}->Get('Check if the system uses Apache::DBI.'),
        Comment     => $Message,
        Check       => $Check,
    };
    return $Data;
}

sub _ApacheReloadCheck {
    my ( $Self, %Param ) = @_;

    my $Data = {};

    # reload check
    my $Check   = 'Failed';
    my $Message = '';
    if ( $ENV{MOD_PERL} ) {
        eval "require mod_perl";    ## no critic
        if ( defined $mod_perl::VERSION ) {    ## no critic
            if ( $mod_perl::VERSION >= 1.99 ) {    ## no critic

                # check if Apache::Reload is loaded
                my $ApacheReload = 0;
                for my $Module ( sort keys %INC ) {
                    $Module =~ s/\//::/g;
                    $Module =~ s/\.pm$//g;
                    if ( $Module eq 'Apache::Reload' || $Module eq 'Apache2::Reload' ) {
                        $ApacheReload = $Module;
                    }
                }
                if ( !$ApacheReload ) {
                    $Check   = 'Info';
                    $Message = $Self->{LanguageObject}->Get(
                        'Apache::Reload or Apache2::Reload should be used as PerlModule and PerlInitHandler to prevent web server restarts when installing and upgrading modules.'
                    );
                }
                else {
                    $Check   = 'OK';
                    $Message = $ApacheReload;
                }
            }
        }
    }
    else {

        # Just skip this test if we' re not running mod_perl.
        return;
    }
    $Data = {
        Name        => 'Apache::Reload',
        Description => $Self->{LanguageObject}->Get('Check if the system uses Apache::Reload/Apache2::Reload.'),
        Comment     => $Message,
        Check       => $Check,
    };
    return $Data;
}

sub _CGIAcceleratorCheck {
    my ( $Self, %Param ) = @_;

    my $Data = {};

    my $Check   = 'Failed';
    my $Message = '';
    if ( $ENV{MOD_PERL} ) {

        # check mod_perl version
        if ( $ENV{MOD_PERL} =~ /\/1.99/ ) {
            $Check   = 'Critical';
            $Message = $Self->{LanguageObject}->Get('You use a beta version of mod_perl')
                . " ($ENV{MOD_PERL}), "
                .
                $Self->{LanguageObject}->Get('you should upgrade to a stable version.');
        }
        elsif ( $ENV{MOD_PERL} =~ /\/1/ ) {
            $Check   = 'Critical';
            $Message = $Self->{LanguageObject}->Get('You should update mod_perl to')
                . " 2.x ($ENV{MOD_PERL}).";
        }
        else {
            $Check   = 'OK';
            $Message = $ENV{MOD_PERL};
        }
    }
    elsif ( $ENV{SERVER_SOFTWARE} =~ /fastcgi/i ) {
        $Check   = 'OK';
        $Message = $Self->{LanguageObject}->Get('You are using FastCGI.');
    }
    else {
        $Check   = 'Critical';
        $Message = $Self->{LanguageObject}->Get('You should use FastCGI or mod_perl to increase your performance.');
    }
    $Data = {
        Name        => $Self->{LanguageObject}->Get('CGI Accelerator'),
        Description => $Self->{LanguageObject}->Get('Check for CGI Accelerator.'),
        Comment     => $Message,
        Check       => $Check,
    };
    return $Data;
}

1;
