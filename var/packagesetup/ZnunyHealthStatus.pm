# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
package var::packagesetup::ZnunyHealthStatus;    ## no critic

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Main',
    'Kernel::System::SysConfig',
    'Kernel::System::ZnunyHelper',
);

use Kernel::System::VariableCheck qw(:all);

=head1 NAME

var::packagesetup::ZnunyHealthStatus - code to execute during package installation

=head1 SYNOPSIS

All code to execute during package installation

=head1 PUBLIC INTERFACE

=head2 new()

create an object

    my $CodeObject = $Kernel::OM->Get('var::packagesetup::ZnunyHealthStatus');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    my $ZnunyHelperObject = $Kernel::OM->Get('Kernel::System::ZnunyHelper');
    $ZnunyHelperObject->_RebuildConfig();

    return $Self;
}

=head2 CodeInstall()

run the code install part

    my $Result = $CodeObject->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

    $Self->_SetupWebserviceCreate();
    $Self->_SetupApiKey();

    return 1;
}

=head2 CodeReinstall()

run the code reinstall part

    my $Result = $CodeObject->CodeReinstall();

=cut

sub CodeReinstall {
    my ( $Self, %Param ) = @_;

    $Self->_SetupWebserviceCreate();

    return 1;
}

=head2 CodeUpgrade()

run the code upgrade part

    my $Result = $CodeObject->CodeUpgrade();

=cut

sub CodeUpgrade {
    my ( $Self, %Param ) = @_;

    $Self->_SetupWebserviceCreate();

    return 1;
}

=head2 CodeUninstall()

run the code uninstall part

    my $Result = $CodeObject->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

    $Self->_SetUpWebserviceDelete();

    return 1;
}

=head2 _SetupWebserviceCreate()

creates or updates web services

    # installs all .yml files in $OTRS/scripts/webservices/
    # name of the file will be the name of the web service

    my $Success = $ZnunyHelperObject->_WebserviceCreate(
        SubDir => 'ZnunyAssetDesk', # optional
    );

    OR:

    my $Success = $ZnunyHelperObject->_WebserviceCreate(
        Webservices => {
            'New Webservice 1234' => '/path/to/Webservice.yml',
            ...
        }
    );

=cut

sub _SetupWebserviceCreate {
    my ( $Self, %Param ) = @_;

    my $ConfigObject      = $Kernel::OM->Get('Kernel::Config');
    my $ZnunyHelperObject = $Kernel::OM->Get('Kernel::System::ZnunyHelper');

    my $Home = $ConfigObject->Get('Home');

    my $Success = $ZnunyHelperObject->_WebserviceCreate(
        Webservices => {
            HealthStatus => $Home . '/var/webservices/examples/ZnunyHealthStatus.yml',
        },
    );
    return $Success;
}

=head2 _SetupWebserviceDelete()

delete the installed web service

    my $Success = $Self->_SetUpWebserviceDelete();

=cut

sub _SetUpWebserviceDelete {
    my ( $Self, %Param ) = @_;

    my $ZnunyHelperObject = $Kernel::OM->Get('Kernel::System::ZnunyHelper');
    my $Success           = $ZnunyHelperObject->_WebserviceDelete(
        Webservices => {
            'HealthStatus' => 1,
        }
    );
    return $Success;
}

=head2 _SetupApiKey()

Create an API Key for later use in the web service request

    my $Success = $Self->_SetupApiKey();

=cut

sub _SetupApiKey {
    my ( $Self, %Param ) = @_;

    my $ConfigObject      = $Kernel::OM->Get('Kernel::Config');
    my $MainObject        = $Kernel::OM->Get('Kernel::System::Main');
    my $SysConfigObject   = $Kernel::OM->Get('Kernel::System::SysConfig');
    my $ZnunyHelperObject = $Kernel::OM->Get('Kernel::System::ZnunyHelper');

    if ( !$ConfigObject->Get('Znuny::HealthStatus::API::Key') ) {
        my $APIKey = $MainObject->GenerateRandomString(
            Length => 40,
        );

        $SysConfigObject->SettingsSet(
            UserID   => 1,
            Settings => [
                {
                    Name           => 'Znuny::HealthStatus::API::Key',
                    EffectiveValue => $APIKey,
                    IsValid        => 1,
                },
            ],
        );

        $ZnunyHelperObject->_RebuildConfig();
    }

    return 1;
}

1;
