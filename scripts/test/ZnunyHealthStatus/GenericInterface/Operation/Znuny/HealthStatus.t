# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

use Kernel::System::VariableCheck qw(:all);

$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);

my $HelperObject             = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $UnitTestWebserviceObject = $Kernel::OM->Get('Kernel::System::UnitTest::Webservice');
my $ZnunyHelperObject        = $Kernel::OM->Get('Kernel::System::ZnunyHelper');
my $ConfigObject             = $Kernel::OM->Get('Kernel::Config');
my $WebserviceObject         = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice');

my $Home           = $ConfigObject->Get('Home');
my $Key            = $ConfigObject->Get('Znuny::HealthStatus::API::Key');
my $WebserviceName = 'HealthStatus';
my $OperationName  = 'HealthStatusGet';

$ZnunyHelperObject->_WebserviceCreateIfNotExists(
    Webservices => {
        $WebserviceName => $Home . '/var/webservices/examples/ZnunyHealthStatus.yml',
    },
);

my $Webservice = $WebserviceObject->WebserviceGet(
    Name => 'HealthStatus',
);

# Test without APIKey
$UnitTestWebserviceObject->Process(
    UnitTestObject => $Self,
    Webservice     => $WebserviceName,
    Operation      => $OperationName,
    Payload        => {
    },
    Response => {
        ErrorMessage => 'Got parameter "Data" but it is not a hash ref in operation Znuny::HealthStatus!',
        Success      => 0,
    },
);

# Test with wrong/unknown APIKey
$UnitTestWebserviceObject->Process(
    UnitTestObject => $Self,
    Webservice     => $WebserviceName,
    Operation      => $OperationName,
    Payload        => {
        APIKey => 'UNKNOWN',
    },
    Response => {
        ErrorMessage => 'Invalid API Key',
        Success      => 0,
    },
);

# Test with valid APIKey
$UnitTestWebserviceObject->Process(
    UnitTestObject => $Self,
    Webservice     => $WebserviceName,
    Operation      => $OperationName,
    Payload        => {
        APIKey => $Key,
    },
    Response => {
        Data => {
            MailQueue => {
                Count => 0,
            },
            Daemon           => 'Not running',
            CommunicationLog => {
                Communications => {
                    AverageProcessingTime => 0,
                    Health                => 'OK',
                    All                   => 0,
                    Successful            => 0,
                    Processing            => 0,
                    Failed                => 0,
                },
                Accounts => '',
            },
        },
        Success => 1
    },
);

1;
