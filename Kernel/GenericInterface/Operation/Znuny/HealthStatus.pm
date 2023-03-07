# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::GenericInterface::Operation::Znuny::HealthStatus;

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Cache',
    'Kernel::System::MailQueue',
    'Kernel::System::CommunicationLog::DB',
    'Kernel::System::DateTime',
);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    if ( !$Param{DebuggerObject} ) {
        return {
            Success      => 0,
            ErrorMessage => "Got no DebuggerObject!"
        };
    }

    $Self->{DebuggerObject} = $Param{DebuggerObject};

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ConfigObject             = $Kernel::OM->Get('Kernel::Config');
    my $MailQueueObject          = $Kernel::OM->Get('Kernel::System::MailQueue');
    my $CommunicationLogDBObject = $Kernel::OM->Get('Kernel::System::CommunicationLog::DB');
    my $CacheObject              = $Kernel::OM->Get('Kernel::System::Cache');

    if ( !IsHashRefWithData( $Param{Data} ) ) {
        return $Self->{DebuggerObject}->Error(
            Summary => 'Got parameter "Data" but it is not a hash ref in operation Znuny::HealthStatus!'
        );
    }

    # get daemon modules from SysConfig
    my $DaemonModuleConfig = $ConfigObject->Get('DaemonModules') || {};
    my $Key                = $ConfigObject->Get('Znuny::HealthStatus::API::Key');

    if (
        !$Param{Data}->{APIKey}
        || !$Key
        || $Param{Data}->{APIKey} ne $Key
        )
    {
        return {
            Success      => 0,
            ErrorMessage => "Invalid API Key"
        };
    }

    my @DaemonSummary;

    MODULE:
    for my $Module ( sort keys %{$DaemonModuleConfig} ) {

        # skip not well configured modules
        next MODULE if !$Module;
        next MODULE if !$DaemonModuleConfig->{$Module};
        next MODULE if !IsHashRefWithData( $DaemonModuleConfig->{$Module} );
        next MODULE if !$DaemonModuleConfig->{$Module}->{Module};

        my $DaemonObject;

        # create daemon object
        eval {
            $DaemonObject = $Kernel::OM->Get( $DaemonModuleConfig->{$Module}->{Module} );
        };

        # skip module if object could not be created or does not provide Summary()
        next MODULE if !$DaemonObject;
        next MODULE if !$DaemonObject->can("Summary");

        # execute Summary
        my @Summary;
        eval {
            @Summary = $DaemonObject->Summary();
        };

        # skip if the result is empty or in a wrong format;
        next MODULE if !@Summary;
        next MODULE if !IsHashRefWithData( $Summary[0] );

        for my $SummaryItem (@Summary) {
            push @DaemonSummary, $SummaryItem;
        }
    }

    my %SummaryData;

    # Daemon Tasks (Maint::Daemon::Summary)
    SUMMARY:
    for my $Summary (@DaemonSummary) {
        for my $DataRow ( @{ $Summary->{Data} } ) {
            my $Header = $Summary->{Header};
            chop($Header);

            # Convert 'This is an entry' into 'ThisIsAnEntry'
            $Header = $Self->_CamelCaseString( String => $Header );
            my $Name = $Self->_CamelCaseString( String => $DataRow->{Name} );

            $SummaryData{$Header}->{$Name} = $DataRow;
        }
    }

    # Mail Queue
    my $List      = $MailQueueObject->List();
    my $ListCount = scalar @{$List};

    $SummaryData{MailQueue}->{Count} = $ListCount;

    # Communication Log Information
    my $CommunicationLogHoursToCheck = 1;

    # Override if parameter LogHours exists and it's a positive number
    if ( $Param{Data}->{LogHours} ) {
        my $Hours = $Param{Data}->{LogHours};
        if ( IsNumber($Hours) && $Hours > 0 ) {
            $CommunicationLogHoursToCheck = $Hours;
        }
    }
    my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
    $DateTimeObject->Subtract( Hours => $CommunicationLogHoursToCheck );
    my $StartTime = $DateTimeObject->ToString();

    # Collect different status from communication log
    my $TotalCommunicationCount = 0;
    my @Filters                 = qw( Successful Processing Failed );
    for my $Filter (@Filters) {
        my $Communications = $CommunicationLogDBObject->CommunicationList(
            StartDate => $StartTime,
            OrderBy   => 'Down',
            SortBy    => 'StartTime',
            Status    => $Filter,
        ) // [];

        my $Count = @{$Communications};
        $TotalCommunicationCount += $Count;

        $SummaryData{CommunicationLog}->{Communications}->{$Filter} = $Count;
    }
    $SummaryData{CommunicationLog}->{Communications}->{All} = $TotalCommunicationCount;

    # Communication health as text
    my $CommunicationHealth = 'OK';
    if ( $SummaryData{CommunicationLog}->{Communications}->{Failed} ) {
        $CommunicationHealth = 'Critical';
        if ( $SummaryData{CommunicationLog}->{Communications}->{Successful} ) {
            $CommunicationHealth = 'Warning';
        }
    }
    $SummaryData{CommunicationLog}->{Communications}->{Health} = $CommunicationHealth;

    # Average processing time of the last hour
    my $AverageSeconds = $CommunicationLogDBObject->CommunicationList(
        StartDate => $StartTime,
        Result    => 'AVERAGE',
    );
    $SummaryData{CommunicationLog}->{Communications}->{AverageProcessingTime} = int( $AverageSeconds // 0 );

    # Collect accounts
    my $Connections = $CommunicationLogDBObject->GetConnectionsObjectsAndCommunications(
        ObjectLogStartDate => $StartTime,
    );
    if ( !IsArrayRefWithData($Connections) ) {
        $SummaryData{CommunicationLog}->{Accounts} = '';
    }
    else {
        my %Account;

        for my $Connection ( @{$Connections} ) {
            my $AccountKey = $Connection->{AccountType};
            if ( $Connection->{AccountID} ) {
                $AccountKey .= "::$Connection->{AccountID}";
            }

            if ( !$Account{$AccountKey} ) {
                $Account{$AccountKey} = {
                    AccountID   => $Connection->{AccountID},
                    AccountType => $Connection->{AccountType},
                    Transport   => $Connection->{Transport},
                };
            }

            $Account{$AccountKey}->{ $Connection->{ObjectLogStatus} } //= [];

            push @{ $Account{$AccountKey}->{ $Connection->{ObjectLogStatus} } },
                $Connection->{CommunicationID};
        }

        for my $AccountKey ( sort keys %Account ) {
            my $Health = 'OK';

            if ( $Account{$AccountKey}->{Failed} ) {
                $Health = 'Critical';
                if ( $Account{$AccountKey}->{Successful} ) {
                    $Health = 'Warning';
                }
            }

            $Account{$AccountKey}->{Status} = $Health;
            delete $Account{$AccountKey}->{Successful};
            delete $Account{$AccountKey}->{Processing};
            delete $Account{$AccountKey}->{Failed};
            delete $Account{$AccountKey}->{AccountID} if !$Account{$AccountKey}->{AccountID};

            push @{ $SummaryData{'CommunicationLog'}->{'Accounts'}->{ $Account{$AccountKey}->{AccountType} } },
                $Account{$AccountKey};
        }
    }

    # Check for running daemon
    my $NodeID = $ConfigObject->Get('NodeID') // 1;

    my $Running = $CacheObject->Get(
        Type => 'DaemonRunning',
        Key  => $NodeID,
    );

    $SummaryData{Daemon} = $Running ? 'Running' : 'Not running';

    return {
        Success => 1,
        Data    => \%SummaryData,
    };
}

sub _CamelCaseString {
    my ( $Self, %Param ) = @_;

    return '' if !IsStringWithData( $Param{String} );

    my @Parts = split /\s+/, $Param{String};
    @Parts = map { ucfirst($_) } @Parts;
    my $CamelCaseString = join '', @Parts;

    # If first character is not a letter (a-z), add an underscore as prefix.
    # This ensures valid XML tags in the output.
    if ( $CamelCaseString !~ m{\A[a-z]}i ) {
        $CamelCaseString = '_' . $CamelCaseString;
    }

    return $CamelCaseString;
}

1;
