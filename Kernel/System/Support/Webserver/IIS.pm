# --
# Kernel/System/Support/Webserver/IIS.pm - all required system information
# Copyright (C) 2001-2012 OTRS AG, http://otrs.org/
# --
# $Id: IIS.pm,v 1.10 2012-09-05 04:29:56 cg Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Support::Webserver::IIS;

use strict;
use warnings;

use vars qw(@ISA $VERSION);
$VERSION = qw($Revision: 1.10 $) [1];

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

    # check if Apache::DBI is loaded
    my $Check   = '';
    my $Message = '';
    if ( $ENV{'GATEWAY_INTERFACE'} && $ENV{'GATEWAY_INTERFACE'} =~ /^CGI-PerlEx/i ) {
        $Check = 'OK';
        $Message
            = $Self->{LanguageObject}->Get('PerlEx is in use') . " ($ENV{'GATEWAY_INTERFACE'}).";
    }
    else {
        $Check = 'Failed';
        $Message
            = $Self->{LanguageObject}->Get('You should use PerlEx to increase your performance.');
    }
    $Data = {
        Name        => 'PerlEx',
        Description => $Self->{LanguageObject}->Get('Check if PerlEx is used.'),
        Comment     => $Message,
        Check       => $Check,
    };
    return $Data;
}

1;
