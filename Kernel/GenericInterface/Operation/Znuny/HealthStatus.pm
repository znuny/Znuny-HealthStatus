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

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::MailQueue',
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

    if ( !IsHashRefWithData( $Param{Data} ) ) {
        return $Self->{DebuggerObject}->Error(
            Summary => 'Got parameter "Data" but it is not a hash ref in operation Znuny::HealthStatus!'
        );
    }

    my $ConfigObject    = $Kernel::OM->Get('Kernel::Config');
    my $MailQueueObject = $Kernel::OM->Get('Kernel::System::MailQueue');

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

    $SummaryData{'MailQueue'}->{'Count'} = $ListCount;

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
