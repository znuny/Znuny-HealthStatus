# --
# Copyright (C) 2012-2022 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package var::packagesetup::ZnunyHealthStatus;     ## no critic

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Main',
    'Kernel::System::SysConfig',
    'Kernel::System::ZnunyHelper',
);

use Kernel::System::VariableCheck qw(:all);

=head1 NAME

ZnunyHealthStatus.pm - code to execute during package installation

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
        SubDir => 'Znuny4OTRSAssetDesk', # optional
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
    my $Success = $ZnunyHelperObject->_WebserviceDelete(
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

        $ZnunyHelperObject->_RebuildConfig()
    }

    # disable redefine warnings in this scope
    {
        no warnings 'redefine'; ## no critic

        sub Kernel::Modules::AdminPackageManager::_MessageGet {    ## no critic
            my ( $Self, %Param ) = @_;

            my $Title       = '';
            my $Description = '';
            my $Use         = 0;

            my $Language = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->{UserLanguage}
                || $Kernel::OM->Get('Kernel::Config')->Get('DefaultLanguage');

            if ( $Param{Info} ) {
                TAG:
                for my $Tag ( @{ $Param{Info} } ) {
                    if ( $Param{Type} ) {
                        next TAG if $Tag->{Type} !~ /^$Param{Type}/i;
                    }
                    $Use = 1;
                    if ( $Tag->{Format} && $Tag->{Format} =~ /plain/i ) {
                        $Tag->{Content} = '<pre class="contentbody">' . $Tag->{Content} . '</pre>';
                    }
                    if ( !$Description && $Tag->{Lang} eq 'en' ) {
                        $Description = $Tag->{Content};
                        $Title       = $Tag->{Title};
                    }

                    if ( $Tag->{Lang} eq $Language ) {
                        $Description = $Tag->{Content};
                        $Title       = $Tag->{Title};
                    }
                }
                if ( !$Description && $Use ) {
                    for my $Tag ( @{ $Param{Info} } ) {
                        if ( !$Description ) {
                            $Description = $Tag->{Content};
                            $Title       = $Tag->{Title};
                        }
                    }
                }
            }
            return if !$Description && !$Title;

# ---
# Znuny-HealthStatus
# ---
            if ( $Title eq 'Znuny Health Status' ) {

                $Kernel::OM->ObjectsDiscard(
                    Objects => ['Kernel::Config'],
                );

                $Kernel::OM->Get('Kernel::Output::HTML::Layout')->{FilterElementPost}
                    = $Kernel::OM->Get('Kernel::Config')->Get('Frontend::Output::FilterElementPost');

                my $APIKey = $Kernel::OM->Get('Kernel::Config')->Get('Znuny::HealthStatus::API::Key');

                if ($APIKey) {
                    my %URLConfigs = (
                        HttpType    => '',
                        FQDN        => '',
                        ScriptAlias => '',
                    );

                    for my $ConfigName ( sort keys %URLConfigs ) {
                        $URLConfigs{$ConfigName} = $Kernel::OM->Get('Kernel::Config')->Get($ConfigName);
                    }

                    my $URLStub
                        = '<OTRS_CONFIG_HttpType>://<OTRS_CONFIG_FQDN>/<OTRS_CONFIG_ScriptAlias>nph-genericinterface.pl/Webservice/HealthStatus/HealthStatusGet?APIKey=';
                    $URLStub =~ s{<OTRS_CONFIG_([^>]+)>}{$URLConfigs{ $1 }}gxms;

                    # manipulate Message content
                    $Description =~ s{(<b \s id=\"OTRSURL\">)[^<]+(</b>)}{$1$URLStub$APIKey$2}xmsi;
                }
            }

# ---
            return (
                Description => $Description,
                Title       => $Title,
            );
        }
    }

    return 1;
}

1;
