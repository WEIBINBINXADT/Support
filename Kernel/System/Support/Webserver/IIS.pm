# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Support::Webserver::IIS;
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
    my $Checks = $Self->{ConfigObject}->Get('Support::Webserver::IIS');

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

sub _PerlExCheck {
    my ( $Self, %Param ) = @_;

    my $Data = {};

    my $Check   = '';
    my $Message = '';
    if ( $ENV{'GATEWAY_INTERFACE'} && $ENV{'GATEWAY_INTERFACE'} =~ /^CGI-PerlEx/i ) {
        $Check   = 'OK';
        $Message = $Self->{LanguageObject}->Get('PerlEx is in use') . " ($ENV{'GATEWAY_INTERFACE'}).";
    }
    else {
        $Check   = 'Failed';
        $Message = $Self->{LanguageObject}->Get('You should use PerlEx to increase your performance.');
    }
    $Data = {
        Name        => 'PerlEx',
        Description => $Self->{LanguageObject}->Get('Check if PerlEx is used.'),
        Comment     => $Message,
        Check       => $Check,
    };
    return $Data;
}

sub _IISVersionCheck {
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
        $Message = $Self->{LanguageObject}->Get('Could not determine IIS version.');
    }
    $Data = {
        Name        => $Self->{LanguageObject}->Get('IIS Version'),
        Description => $Self->{LanguageObject}->Get('Display web server version.'),
        Comment     => $Message,
        Check       => $Check,
    };
    return $Data;
}

sub _IISEnvironmentCheck {
    my ( $Self, %Param ) = @_;

    my %Environment = %ENV;

    for my $NotNeededString (
        qw( HTTP_REFERER         HTTP_CACHE_CONTROL   HTTP_COOKIE    HTTP_USER_AGENT
        HTTP_ACCEPT_LANGUAGE HTTP_ACCEPT_ENCODING HTTP_ACCEPT
        QUERY_STRING         REQUEST_METHOD       REQUEST_URI    SCRIPT_NAME
        ALLUSERSPROFILE      APPDATA              LOCALAPPDATA   COMMONPROGRAMFILES
        PROGRAMDATA          PROGRAMFILES         PSMODULEPATH   PUBLIC
        SYSTEMDRIVE          SYSTEMROOT           TEMP           WINDIR
        USERPROFILE )
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

1;
