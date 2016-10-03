# --
# Kernel/System/Support/OTRS.pm - all required otrs information
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Support::OTRS;
## nofilter(TidyAll::Plugin::OTRS::Perl::LayoutObject)

use strict;
use warnings;

use Kernel::System::Support;
use Kernel::System::User;
use Kernel::System::Ticket;
use Kernel::System::Package;
use Kernel::System::Auth;

use vars qw(@ISA $VERSION);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for (qw(ConfigObject LogObject MainObject TimeObject EncodeObject DBObject LayoutObject)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    # create additional objects
    $Self->{UserObject}         = Kernel::System::User->new( %{$Self} );
    $Self->{CustomerUserObject} = Kernel::System::CustomerUser->new( %{$Self} );
    $Self->{TicketObject}       = Kernel::System::Ticket->new( %{$Self} );
    $Self->{PackageObject}      = Kernel::System::Package->new( %{$Self} );
    $Self->{GroupObject}        = Kernel::System::Group->new( %{$Self} );
    $Self->{AuthObject}         = Kernel::System::Auth->new( %{$Self} );
    $Self->{LanguageObject}     = $Self->{LayoutObject}->{LanguageObject};

    return $Self;
}

sub AdminChecksGet {
    my ( $Self, %Param ) = @_;

    # get names of available checks from sysconfig
    my $Checks = $Self->{ConfigObject}->Get('Support::OTRS');

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

# check if error log entries are available
sub _LogCheck {
    my ( $Self, %Param ) = @_;

    my $Data = {};

    # Ticket::IndexModule check
    my $Check   = 'OK';
    my $Message = '';
    my $Error   = '';

    my @Lines = split( /\n/, $Self->{LogObject}->GetLog() );
    for (@Lines) {
        my @Row = split( /;;/, $_ );
        if ( $Row[3] ) {
            if ( $Row[1] =~ /error/i ) {
                $Check = 'Failed';
                if ($Message) {
                    $Message = $Self->{LanguageObject}->Get('You have more error log entries: ');
                }
                else {
                    $Message = $Self->{LanguageObject}->Get('There is one error log entry: ');
                }
                if ($Error) {
                    $Error .= ', ';
                }
                $Error .= $Row[3];
            }
        }
    }

    $Data = {
        Name        => $Self->{LanguageObject}->Get('LogCheck'),
        Description => $Self->{LanguageObject}->Get('Check log for error log entries.'),
        Comment     => $Message . $Error,
        Check       => $Check,
    };

    return $Data;
}

sub _TicketIndexModuleCheck {
    my ( $Self, %Param ) = @_;

    my $Data = {};

    # Ticket::IndexModule check
    my $Check   = 'Failed';
    my $Message = '';
    my $Module  = $Self->{ConfigObject}->Get('Ticket::IndexModule');
    $Self->{DBObject}->Prepare( SQL => 'SELECT count(*) from ticket' );
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        if ( $Row[0] > 80000 ) {
            if ( $Module =~ /RuntimeDB/ ) {
                $Check   = 'Failed';
                $Message = "$Row[0] "
                    . $Self->{LanguageObject}->Get(
                    'tickets in your system. You should use the StaticDB backend. See admin manual (Performance Tuning) for more information.'
                    );
            }
            else {
                $Check   = 'OK';
                $Message = "";
            }
        }
        elsif ( $Row[0] > 60000 ) {
            if ( $Module =~ /RuntimeDB/ ) {
                $Check   = 'Critical';
                $Message = "$Row[0] "
                    . $Self->{LanguageObject}->Get(
                    'tickets in your system. You should use the StaticDB backend. See admin manual (Performance Tuning) for more information.'
                    );
            }
            else {
                $Check   = 'OK';
                $Message = "";
            }
        }
        else {
            $Check   = 'OK';
            $Message = $Self->{LanguageObject}->Get('You are using')
                . " \"$Module\", " . $Self->{LanguageObject}->Get("that's fine for")
                . " $Row[0] " . $Self->{LanguageObject}->Get('tickets in your system.');
        }
    }
    $Data = {
        Name        => 'Ticket::IndexModule',
        Description => $Self->{LanguageObject}->Get('Check Ticket::IndexModule setting.'),
        Comment     => $Message,
        Check       => $Check,
    };
    return $Data;
}

sub _TicketStaticDBOrphanedRecords {
    my ( $Self, %Param ) = @_;

    my $Data = {};

    # Ticket::IndexModule check for records in StaticDB when using different backend
    my $Check   = 'Failed';
    my $Message = '';
    my $Module  = $Self->{ConfigObject}->Get('Ticket::IndexModule');

    if ( $Module !~ /StaticDB/ ) {

        $Self->{DBObject}->Prepare( SQL => 'SELECT count(*) from ticket_lock_index' );
        while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
            if ( $Row[0] ) {
                $Check   = 'Failed';
                $Message = "$Row[0] "
                    . $Self->{LanguageObject}->Get('tickets in StaticDB lock_index but you are using the')
                    . " $Module "
                    . $Self->{LanguageObject}->Get(
                    "index. Please run otrs/bin/otrs.CleanTicketIndex.pl to clean the StaticDB index."
                    );
            }
        }

        $Self->{DBObject}->Prepare( SQL => 'SELECT count(*) from ticket_index' );
        while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
            if ( $Row[0] ) {
                $Check   = 'Failed';
                $Message = "$Row[0] "
                    . $Self->{LanguageObject}->Get('tickets in StaticDB index but you are using the')
                    . " $Module "
                    . $Self->{LanguageObject}->Get(
                    "index. Please run otrs/bin/otrs.CleanTicketIndex.pl to clean the StaticDB index."
                    );
            }
        }
    }
    else {
        $Message = $Self->{LanguageObject}->Get('You are using')
            . " $Module. "
            . $Self->{LanguageObject}->Get('Skipping test.');
        $Check = 'OK';
    }
    if ( $Message eq '' ) {
        $Message = $Self->{LanguageObject}->Get('No orphaned records found.');
        $Check   = 'OK';
    }

    $Data = {
        Name        => $Self->{LanguageObject}->Get('TicketStaticDBOrphanedRecords'),
        Description => $Self->{LanguageObject}->Get('Check orphaned StaticDB records.'),
        Comment     => $Message,
        Check       => $Check,
    };
    return $Data;
}

sub _TicketFulltextIndexModuleCheck {
    my ( $Self, %Param ) = @_;

    my $Data = {};

    # Ticket::IndexModule check
    my $Check   = 'Failed';
    my $Message = '';
    my $Module  = $Self->{ConfigObject}->Get('Ticket::SearchIndexModule');
    $Self->{DBObject}->Prepare( SQL => 'SELECT count(*) from article' );
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        if ( $Row[0] > 100000 ) {
            if ( $Module =~ /RuntimeDB/ ) {
                $Check   = 'Failed';
                $Message = "$Row[0] "
                    . $Self->{LanguageObject}->Get(
                    'articles in your system. You should use the StaticDB backend for OTRS 2.3 and higher. See admin manual (Performance Tuning) for more information.'
                    );
            }
            else {
                $Check   = 'OK';
                $Message = "";
            }
        }
        elsif ( $Row[0] > 50000 ) {
            if ( $Module =~ /RuntimeDB/ ) {
                $Check   = 'Critical';
                $Message = "$Row[0] "
                    . $Self->{LanguageObject}->Get(
                    'articles in your system. You should use the StaticDB backend for OTRS 2.3 and higher. See admin manual (Performance Tuning) for more information.'
                    );
            }
            else {
                $Check   = 'OK';
                $Message = "";
            }
        }
        else {
            $Check   = 'OK';
            $Message = $Self->{LanguageObject}->Get('You are using') . " \"$Module\", "
                . $Self->{LanguageObject}->Get("that's fine for")
                . " $Row[0] " . $Self->{LanguageObject}->Get('articles in your system.');
        }
    }
    $Data = {
        Name        => 'Ticket::SearchIndexModule',
        Description => $Self->{LanguageObject}->Get('Check Ticket::SearchIndexModule setting.'),
        Comment     => $Message,
        Check       => $Check,
    };
    return $Data;
}

# OpenTicketCheck check
sub _OpenTicketCheck {
    my ( $Self, %Param ) = @_;

    my $Data = {};

    my $Check     = 'Failed';
    my $Message   = '';
    my @TicketIDs = $Self->{TicketObject}->TicketSearch(
        Result     => 'ARRAY',
        StateType  => 'Open',
        UserID     => 1,
        Permission => 'ro',
        Limit      => 89999,
    );
    if ( $#TicketIDs > 89990 ) {
        $Check   = 'Failed';
        $Message = $Self->{LanguageObject}->Get(
            'You should not have more than 8000 open tickets in your system. You currently have over 89999! In case you want to improve your performance, close not needed open tickets.'
        );

    }
    elsif ( $#TicketIDs > 10000 ) {
        $Check   = 'Failed';
        $Message = $Self->{LanguageObject}
            ->Get('You should not have over 8000 open tickets in your system. You currently have ')
            . $#TicketIDs . '. '
            . $Self->{LanguageObject}
            ->Get('In case you want to improve your performance, close not needed open tickets.');

    }
    elsif ( $#TicketIDs > 8000 ) {
        $Check   = 'Critical';
        $Message = $Self->{LanguageObject}->Get(
            'You should not have more than 8000 open tickets in your system. You currently have '
            )
            . $#TicketIDs
            . $Self->{LanguageObject}
            ->Get('. In case you want to improve your performance, close not needed open tickets.');

    }
    else {
        $Check   = 'OK';
        $Message = $Self->{LanguageObject}->Get('You have ')
            . $#TicketIDs
            . $Self->{LanguageObject}->Get(' open tickets in your system.');
    }
    $Data = {
        Name        => $Self->{LanguageObject}->Get('OpenTicketCheck'),
        Description => $Self->{LanguageObject}->Get('Check open tickets in your system.'),
        Comment     => $Message,
        Check       => $Check,
    };
    return $Data;
}

# Check if the configured FQDN is valid.
sub _FQDNConfigCheck {
    my ( $Self, %Param ) = @_;
    my $Data = {
        Name        => $Self->{LanguageObject}->Get('FQDNConfigCheck'),
        Description => $Self->{LanguageObject}->Get('Check if the configured FQDN is valid.'),
        Check       => 'Failed',
        Comment     => '',
    };

    # Get the configured FQDN
    my $FQDN = $Self->{ConfigObject}->Get('FQDN');

    # Do we have set our FQDN?
    if ( $FQDN eq 'yourhost.example.com' ) {
        $Data->{Check}   = 'Failed';
        $Data->{Comment} = $Self->{LanguageObject}->Get(
            'Please configure your FQDN inside the SysConfig module. (currently the default setting'
            )
            . " '$FQDN' " . $Self->{LanguageObject}->Get('is enabled).');
    }

    # FQDN syntax check.
    elsif ( $FQDN !~ /^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$/ ) {
        $Data->{Check}   = 'Failed';
        $Data->{Comment} = $Self->{LanguageObject}->Get('Invalid FQDN') . " '$FQDN'.";
    }

    # Nothing to complain. :-(
    else {
        $Data->{Check}   = 'OK';
        $Data->{Comment} = "FQDN '$FQDN' " . $Self->{LanguageObject}->Get('looks good.');
    }
    return $Data;
}

# Check if the SystemID contains only digits.
sub _SystemIDConfigCheck {
    my ( $Self, %Param ) = @_;

    my $Data = {
        Name => $Self->{LanguageObject}->Get('SystemIDConfigCheck'),
        Description =>
            $Self->{LanguageObject}->Get('Check if the configured SystemID contains only digits.'),
        Check   => 'Failed',
        Comment => '',
    };

    # Get the configured SystemID
    my $SystemID = $Self->{ConfigObject}->Get('SystemID');

    # Does the SystemID contain non-digits?
    if ( $SystemID =~ /^\d+$/ ) {
        $Data->{Check}   = 'OK';
        $Data->{Comment} = $Self->{LanguageObject}->Get('Your SystemID setting is') . " $SystemID.";
    }
    else {
        $Data->{Comment} = $Self->{LanguageObject}->Get('The SystemID') . " '$SystemID' "
            . $Self->{LanguageObject}->Get('must consist of digits exclusively.');
    }
    return $Data;
}

# Check if Ticket::Frontend::ResponseFormat is valid
sub _ConfigCheckTicketFrontendResponseFormat {
    my ( $Self, %Param ) = @_;

    my $Data = {
        Name        => $Self->{LanguageObject}->Get('ResponseFormatCheck'),
        Description => $Self->{LanguageObject}->Get('Check if Ticket::Frontend::ResponseFormat contains no $Data{""}.'),
        Check       => 'Failed',
        Comment     => '',
    };

    # Get the config
    my $Config = $Self->{ConfigObject}->Get('Ticket::Frontend::ResponseFormat');

    # Does the SystemID contain non-digits?
    if ( $Config !~ /\$Data{"/ ) {
        $Data->{Check}   = 'OK';
        $Data->{Comment} = "\$Data{\"\"} " . $Self->{LanguageObject}->Get('was not found.');
    }
    else {
        $Data->{Comment} = $Self->{LanguageObject}->Get('Config option Ticket::Frontend::ResponseFormat cointains')
            . " \$Data{\"\"}, \$QData{\"\"} "
            . $Self->{LanguageObject}->Get('should be used instand (see default setting).');
    }
    return $Data;
}

sub _FileSystemCheck {
    my ( $Self, %Param ) = @_;

    my $Message = '';
    my $Data    = {
        Name        => $Self->{LanguageObject}->Get('FileSystemCheck'),
        Description => $Self->{LanguageObject}->Get('Check if file system is writable.'),
        Check       => 'Failed',
        Comment     => $Self->{LanguageObject}->Get('The file system is writable.'),
    };

    my $Home = $Self->{ConfigObject}->Get('Home');

    # check Home
    if ( !-e $Home ) {
        $Data->{Check}   = 'Failed';
        $Data->{Comment} = $Self->{LanguageObject}->Get('No such home directory') . ": $Home!",
            return $Data;
    }
    for (
        qw(/bin/ /Kernel/ /Kernel/System/ /Kernel/Output/ /Kernel/Output/HTML/ /Kernel/Modules/)
        )
    {
        my $File = "$Home/$_/check_permissons.$$";
        if ( open( my $FILE, '>', "$File" ) ) {    ## no critic
            print $FILE "test";
            close($FILE);
            unlink $File;
        }
        else {
            $Message .= "$File($!);";
        }
    }

    if ($Message) {
        $Data->{Comment} = $Self->{LanguageObject}->Get("Can't write file") . ": $Message",
            return $Data;
    }

    $Data->{Check} = 'OK';

    return $Data;
}

sub _PackageDeployCheck {
    my ( $Self, %Param ) = @_;

    my $Data = {
        Name        => $Self->{LanguageObject}->Get('PackageDeployCheck'),
        Description => $Self->{LanguageObject}->Get('Check deployment of all packages.'),
        Check       => 'OK',
        Comment     => $Self->{LanguageObject}->Get('All packages are correctly installed.'),
    };

    my $Message = '';
    for my $Package ( $Self->{PackageObject}->RepositoryList() ) {
        my $DeployCheck = $Self->{PackageObject}->DeployCheck(
            Name    => $Package->{Name}->{Content},
            Version => $Package->{Version}->{Content},
        );
        if ( !$DeployCheck ) {
            $Message .= $Package->{Name}->{Content} . ' ' . $Package->{Version}->{Content} . '; ';
        }
    }

    if ($Message) {
        $Data->{Check}   = 'Critical';
        $Data->{Comment} = $Self->{LanguageObject}->Get('Packages not correctly installed') . ": $Message.",
    }

    return $Data;
}

sub _InvalidUserLockedTicketSearch {
    my ( $Self, %Param ) = @_;

    # set the default message
    my $Data = {
        Name        => $Self->{LanguageObject}->Get('InvalidUserLockedTicketSearch'),
        Description => $Self->{LanguageObject}->Get('Search for invalid user with locked tickets.'),
        Check       => 'OK',
        Comment     => $Self->{LanguageObject}->Get('There are no invalid users with locked tickets.'),
    };

    # get all users (because there is no function to get all invalid users)
    my %UserList = $Self->{UserObject}->UserList(
        Type  => 'Long',
        Valid => 0
    );

    # create the list of invalid users
    my @InvalidUser = ();
    for my $UserID ( sort keys %UserList ) {
        my %User = $Self->{UserObject}->GetUserData(
            UserID => $UserID,
            Cached => 1,
        );
        if ( $User{ValidID} == 2 ) {
            push @InvalidUser, $UserID;
        }
    }

    return $Data if !@InvalidUser;

    my @TicketIDs = $Self->{TicketObject}->TicketSearch(
        Result   => 'ARRAY',
        LockIDs  => [2],
        OwnerIDs => \@InvalidUser,
        UserID   => 1,
    );

    return $Data if !@TicketIDs;

    my %LockedTicketUser = ();
    for my $TicketID (@TicketIDs) {
        my %Ticket = $Self->{TicketObject}->TicketGet(
            TicketID => $TicketID,
            UserID   => 1,
        );
        $LockedTicketUser{ $Ticket{OwnerID} } = $UserList{ $Ticket{OwnerID} };
    }

    my $UserString = join ', ', values %LockedTicketUser;
    $Data->{Comment} = $Self->{LanguageObject}->Get('These invalid users have locked tickets') . ": $UserString";
    $Data->{Check}   = 'Critical';

    return $Data;
}

sub _DefaultUserCheck {
    my ( $Self, %Param ) = @_;

    # set the default message
    my $Data = {
        Name        => $Self->{LanguageObject}->Get('DefaultUserCheck'),
        Description => $Self->{LanguageObject}->Get('Check if root@localhost account has the default password.'),
        Check       => 'OK',
        Comment     => $Self->{LanguageObject}->Get('There is no active root@localhost with default password.'),
    };

    # retrieve list of valid users
    my %UserList = $Self->{UserObject}->UserList(
        Type  => 'Short',
        Valid => '1',
    );

    my $SuperUserID;
    USER:
    for my $UserID ( sort keys %UserList ) {
        if ( $UserList{$UserID} eq 'root@localhost' ) {
            $SuperUserID = 1;
            last USER;
        }
    }
    return $Data if !$SuperUserID;

    # see if there is a default password attached
    my $DefaultPass = $Self->{AuthObject}->Auth(
        User => 'root@localhost',
        Pw   => 'root',
    );
    return $Data if !$DefaultPass;

    $Data->{Comment} = $Self->{LanguageObject}->Get("Change the password or invalidate the account 'root\@localhost'.");
    $Data->{Check}   = 'Critical';

    return $Data;
}

sub _DefaultSOAPUserCheck {
    my ( $Self, %Param ) = @_;

    my $Data = {
        Name        => $Self->{LanguageObject}->Get('SOAPCheck'),
        Description => $Self->{LanguageObject}->Get('Check default SOAP credentials.'),
        Comment     => $Self->{LanguageObject}->Get('You have not enabled SOAP or have set your own password.'),
        Check       => 'OK',
    };

    my $SOAPUser     = $Self->{ConfigObject}->Get('SOAP::User')     || '';
    my $SOAPPassword = $Self->{ConfigObject}->Get('SOAP::Password') || '';

    if ( $SOAPUser eq 'some_user' ) {
        if ( $SOAPPassword eq 'some_pass' || $SOAPPassword eq '' ) {
            $Data->{Check} = 'Critical';
            $Data->{Comment}
                = $Self->{LanguageObject}->Get('Please set a strong password for SOAP::Password in SysConfig.');
        }
    }

    return $Data;
}

# General System Overview
sub _GeneralSystemOverview {
    my ( $Self, %Param ) = @_;

    my $Data      = {};
    my $TableInfo = '';
    my $Counter   = 0;

    my $Check = 'OK';

    $TableInfo
        .= $Self->{LanguageObject}->Get('Product') . '='
        . $Self->{ConfigObject}->Get('Product')
        .
        ' ' . $Self->{ConfigObject}->Get('Version') . ';';

    my %Search = (
        1 => {
            TableName   => 'ticket',
            Description => $Self->{LanguageObject}->Get('Tickets'),
        },
        2 => {
            TableName   => 'article',
            Description => $Self->{LanguageObject}->Get('Articles'),
        },
        3 => {
            TableName   => 'users',
            Description => $Self->{LanguageObject}->Get('Agents'),
        },
        4 => {
            TableName   => 'roles',
            Description => $Self->{LanguageObject}->Get('Roles'),
        },
        5 => {
            TableName   => 'groups',
            Description => $Self->{LanguageObject}->Get('Groups'),
        },
    );

    for my $Key ( sort keys %Search ) {

        $Self->{DBObject}->Prepare( SQL => 'SELECT count(*) from ' . $Search{$Key}->{TableName} );

        while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
            $Search{$Key}->{Result} = $Row[0];
        }

        $TableInfo .= "$Search{$Key}->{Description}=$Search{$Key}->{Result};";
    }

    # only calculate average if we actually have tickets
    if ( $Search{1}->{Result} && $Search{2}->{Result} ) {
        my $AvgArticlesTicket = $Search{2}->{Result} / $Search{1}->{Result};
        $AvgArticlesTicket = sprintf( "%.2f", $AvgArticlesTicket );
        $TableInfo
            .= $Self->{LanguageObject}->Get('Articles per ticket (avg)') . "=$AvgArticlesTicket;";
    }

    #  tickets per month (avg)
    my $MonthInSeconds = 2626560;    # 60 * 60 * 24 * 30.4;
    my $TicketWindowTime;            # in months
    $Self->{DBObject}->Prepare(
        SQL => "select max(create_time_unix), min(create_time_unix) " .
            "from ticket where id > 1 ",
    );
    my $TicketCreateTimeMax;
    my $TicketCreateTimeMin;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {

        # months on seconds
        $TicketCreateTimeMax = $Row[0] || 0;
        $TicketCreateTimeMin = $Row[1] || 0;
    }
    $TicketWindowTime = ( $TicketCreateTimeMax - $TicketCreateTimeMin ) || 1;
    $TicketWindowTime = $TicketWindowTime / $MonthInSeconds;
    $TicketWindowTime = 1
        if $TicketWindowTime < 1;
    my $AverageTicketsMonth = $Search{1}->{Result} / $TicketWindowTime;
    $AverageTicketsMonth = sprintf( "%.2f", $AverageTicketsMonth );
    $TicketWindowTime    = sprintf( "%.2f", $TicketWindowTime );
    $TableInfo .= $Self->{LanguageObject}->Get('Months between first and last ticket')
        . "=$TicketWindowTime;";
    $TableInfo
        .= $Self->{LanguageObject}->Get('Tickets per month (avg)') . "=$AverageTicketsMonth;";

    #  attachments
    my $StorageModule = $Self->{ConfigObject}->Get('Ticket::StorageModule') || '';

    if ( $StorageModule eq 'Kernel::System::Ticket::ArticleStorageDB' ) {
        my $HowManyAttachments;
        my $AverageAttachmentSize = 0;
        my $AvgAttachmentTicket   = 0;
        $Self->{DBObject}->Prepare(
            SQL => "select id, content_size from article_attachment " .
                "where content_type not like('text/html%')",
        );
        while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
            $HowManyAttachments++;
            $AverageAttachmentSize = $AverageAttachmentSize + $Row[1];
        }

        if ($HowManyAttachments) {
            $AverageAttachmentSize = $AverageAttachmentSize / $HowManyAttachments;
            $AverageAttachmentSize = int( $AverageAttachmentSize / 1024 );
            $AverageAttachmentSize = sprintf( "%.2f", $AverageAttachmentSize );
            $AvgAttachmentTicket   = $HowManyAttachments / $Search{1}->{Result};
            $AvgAttachmentTicket   = sprintf( "%.2f", $AvgAttachmentTicket );
        }

        $TableInfo .= $Self->{LanguageObject}->Get('Attachments per ticket (avg)')
            . "=$AvgAttachmentTicket;";
        $TableInfo .= $Self->{LanguageObject}->Get('Attachment size (avg)')
            . "=$AverageAttachmentSize KB;";
    }

    # customers
    $Self->{DBObject}->Prepare(
        SQL => "select COUNT(DISTINCT(customer_user_id)) " .
            "from ticket",
    );
    my $Customers;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {

        # months on seconds
        $Customers = $Row[0] || 0;
    }
    $TableInfo
        .= $Self->{LanguageObject}->Get('Customers with at least one ticket') . "=$Customers;";

    # operating system
    $TableInfo .= $Self->{LanguageObject}->Get('Operating system') . "=$^O;";

    # install path
    $TableInfo .= $Self->{LanguageObject}->Get('Install directory') . '='
        . $Self->{ConfigObject}->Get('Home');

    $Data = {
        Name        => $Self->{LanguageObject}->Get('GeneralSystemOverview'),
        Description => $Self->{LanguageObject}->Get('Display a general system overview'),
        Comment     => $Self->{LanguageObject}->Get('General information about your system.'),
        Check       => $Check,
        BlockStyle  => 'TableDataSimple',
        TableInfo   => $TableInfo,
    };

    return $Data;
}

1;
