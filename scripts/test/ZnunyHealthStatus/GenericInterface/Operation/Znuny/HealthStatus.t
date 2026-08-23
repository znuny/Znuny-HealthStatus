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
            Sessions => {
                SessionsAgent                  => 0,
                SessionsAgentUnique            => 0,
                SessionsAgentUniqueActive      => 0,
                SessionsAgentUniqueInactive    => 0,
                SessionsAgentUniqueOnline      => 0,
                SessionsAgentUniqueAway        => 0,
                SessionsCustomer               => 0,
                SessionsCustomerUnique         => 0,
                SessionsCustomerUniqueActive   => 0,
                SessionsCustomerUniqueInactive => 0,
                SessionsCustomerUniqueOnline   => 0,
                SessionsCustomerUniqueAway     => 0,
                SessionsTotal                  => 0,

            },
            UnprocessedEmails => {
                Count  => 0,
                Health => 'OK',
            }
        },
        Success => 1
    },
);

# A user with both an active and a stale (idle-expired, but not yet purged) session
# must be counted as active only, not as active AND inactive at the same time.
my $AuthSessionObject = $Kernel::OM->Get('Kernel::System::AuthSession');

$HelperObject->FixedTimeSet();

$ConfigObject->Set(
    Key   => 'SessionMaxIdleTime',
    Value => 60,
);

my $StaleSessionID = $AuthSessionObject->CreateSessionID(
    UserID          => 90210,
    UserLogin       => 'HealthStatusTestAgent',
    UserType        => 'User',
    UserLastRequest => $Kernel::OM->Create('Kernel::System::DateTime')->ToEpoch(),
);

$Self->True(
    $StaleSessionID,
    'CreateSessionID() - stale agent session',
);

$HelperObject->FixedTimeAddSeconds(90);

my $ActiveSessionID = $AuthSessionObject->CreateSessionID(
    UserID          => 90210,
    UserLogin       => 'HealthStatusTestAgent',
    UserType        => 'User',
    UserLastRequest => $Kernel::OM->Create('Kernel::System::DateTime')->ToEpoch(),
);

$Self->True(
    $ActiveSessionID,
    'CreateSessionID() - active agent session',
);

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
            Sessions => {
                SessionsAgent                  => 1,
                SessionsAgentUnique            => 1,
                SessionsAgentUniqueActive      => 1,
                SessionsAgentUniqueInactive    => 0,
                SessionsAgentUniqueOnline      => 1,
                SessionsAgentUniqueAway        => 0,
                SessionsCustomer               => 0,
                SessionsCustomerUnique         => 0,
                SessionsCustomerUniqueActive   => 0,
                SessionsCustomerUniqueInactive => 0,
                SessionsCustomerUniqueOnline   => 0,
                SessionsCustomerUniqueAway     => 0,
                SessionsTotal                  => 1,
            },
            UnprocessedEmails => {
                Count  => 0,
                Health => 'OK',
            }
        },
        Success => 1
    },
);

# A session created via GenericInterface (e.g. a webservice login) is excluded from
# SessionsAgent/SessionsAgentUnique (Kernel::System::AuthSession::GetActiveSessions), but must still
# be counted in SessionsAgentUniqueActive, since the "who is online" dashboard widget
# (Kernel::Output::HTML::Dashboard::UserOnline) counts it too.
my $GenericInterfaceSessionID = $AuthSessionObject->CreateSessionID(
    UserID          => 90211,
    UserLogin       => 'HealthStatusTestAPIAgent',
    UserType        => 'User',
    UserLastRequest => $Kernel::OM->Create('Kernel::System::DateTime')->ToEpoch(),
    SessionSource   => 'GenericInterface',
);

$Self->True(
    $GenericInterfaceSessionID,
    'CreateSessionID() - active GenericInterface agent session',
);

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
            Sessions => {
                SessionsAgent                  => 1,
                SessionsAgentUnique            => 1,
                SessionsAgentUniqueActive      => 2,
                SessionsAgentUniqueInactive    => 0,
                SessionsAgentUniqueOnline      => 2,
                SessionsAgentUniqueAway        => 0,
                SessionsCustomer               => 0,
                SessionsCustomerUnique         => 0,
                SessionsCustomerUniqueActive   => 0,
                SessionsCustomerUniqueInactive => 0,
                SessionsCustomerUniqueOnline   => 0,
                SessionsCustomerUniqueAway     => 0,
                SessionsTotal                  => 1,
            },
            UnprocessedEmails => {
                Count  => 0,
                Health => 'OK',
            }
        },
        Success => 1
    },
);

# Two sessions for the very same agent (same UserID) but with differently-cased login strings
# (e.g. a normal browser login plus a GenericInterface login typed with different case) must still
# count as a single unique active agent - deduplication has to happen on UserID, not UserLogin.
my $DifferentCaseSessionID = $AuthSessionObject->CreateSessionID(
    UserID          => 90210,
    UserLogin       => 'HEALTHSTATUSTESTAGENT',
    UserType        => 'User',
    UserLastRequest => $Kernel::OM->Create('Kernel::System::DateTime')->ToEpoch(),
    SessionSource   => 'GenericInterface',
);

$Self->True(
    $DifferentCaseSessionID,
    'CreateSessionID() - active session for the same agent with a differently-cased login',
);

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
            Sessions => {
                SessionsAgent                  => 1,
                SessionsAgentUnique            => 1,
                SessionsAgentUniqueActive      => 2,
                SessionsAgentUniqueInactive    => 0,
                SessionsAgentUniqueOnline      => 2,
                SessionsAgentUniqueAway        => 0,
                SessionsCustomer               => 0,
                SessionsCustomerUnique         => 0,
                SessionsCustomerUniqueActive   => 0,
                SessionsCustomerUniqueInactive => 0,
                SessionsCustomerUniqueOnline   => 0,
                SessionsCustomerUniqueAway     => 0,
                SessionsTotal                  => 1,
            },
            UnprocessedEmails => {
                Count  => 0,
                Health => 'OK',
            }
        },
        Success => 1
    },
);

$AuthSessionObject->RemoveSessionID( SessionID => $StaleSessionID );
$AuthSessionObject->RemoveSessionID( SessionID => $ActiveSessionID );
$AuthSessionObject->RemoveSessionID( SessionID => $GenericInterfaceSessionID );
$AuthSessionObject->RemoveSessionID( SessionID => $DifferentCaseSessionID );

# A session that is still within the idle time (and therefore counted as active) but whose last
# request is older than the much shorter online threshold must be reported as "Away", mirroring the
# dashboard's grey (Away) vs. green (Active) per-row status icon.
$ConfigObject->Set(
    Key   => 'SessionMaxIdleTime',
    Value => 3600,
);
$ConfigObject->Set(
    Key   => 'SessionAgentOnlineThreshold',
    Value => 1,
);

my $AwaySessionID = $AuthSessionObject->CreateSessionID(
    UserID          => 90212,
    UserLogin       => 'HealthStatusTestAwayAgent',
    UserType        => 'User',
    UserLastRequest => $Kernel::OM->Create('Kernel::System::DateTime')->ToEpoch(),
);

$Self->True(
    $AwaySessionID,
    'CreateSessionID() - away agent session',
);

$HelperObject->FixedTimeAddSeconds(150);

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
            Sessions => {
                SessionsAgent                  => 1,
                SessionsAgentUnique            => 1,
                SessionsAgentUniqueActive      => 1,
                SessionsAgentUniqueInactive    => 0,
                SessionsAgentUniqueOnline      => 0,
                SessionsAgentUniqueAway        => 1,
                SessionsCustomer               => 0,
                SessionsCustomerUnique         => 0,
                SessionsCustomerUniqueActive   => 0,
                SessionsCustomerUniqueInactive => 0,
                SessionsCustomerUniqueOnline   => 0,
                SessionsCustomerUniqueAway     => 0,
                SessionsTotal                  => 1,
            },
            UnprocessedEmails => {
                Count  => 0,
                Health => 'OK',
            }
        },
        Success => 1
    },
);

$AuthSessionObject->RemoveSessionID( SessionID => $AwaySessionID );

$HelperObject->FixedTimeUnset();

1;
