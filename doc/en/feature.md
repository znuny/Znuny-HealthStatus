# Functionality

This package provides a web service for monitoring. The web service provides information about the status of the daemon tasks and e-mail communication.

The following information is included:

1. the daemon status
2. number of e-mails waiting in the Znuny mail queue
3. regularly executed tasks of the daemon
4. regularly running generic agents
5. currently running daemon tasks
6. pending daemon tasks
7. information on the communication protocol and the e-mail accounts

The API key required for the call is generated automatically and can be changed later in the system configuration `Znuny::HealthStatus::API::Key`.
You can use the optional parameter `LogHours` to change how far back the communication protocol is checked. The default time is one hour.


Example requests:

```bash
$ URL="https://HOST/otrs/nph-genericinterface.pl/Webservice/HealthStatus/HealthStatusGet"
$ curl -H 'Content-type: text/json' -X POST -d '{"APIKey": "jhgfdsaewrtzui1234567"}' "$URL"
$ curl "${URL}?APIKey=jhgfdsaewrtzui1234567"
```

::: warning  :::
We recommend using a POST request to prevent the API key from being stored in web or proxy server log files.
:::::::::::


A response could look like this:

```
{
  "Recurrent cron tasks": {
    "TicketDraftDeleteExpired": {
      "Type": "Cron",
      "LastWorkerRunningTime": "< 1 Second",
      "Name": "TicketDraftDeleteExpired",
      "LastExecutionTime": "2021-11-18 14:55:00",
      "LastWorkerStatus": "Success",
      "NextExecutionTime": "2021-11-18 16:55:00"
    },
    "SpoolMailsReprocess": {
      "LastWorkerStatus": "N/A",
      "LastExecutionTime": "2021-11-18 00:10:00",
      "NextExecutionTime": "2021-11-19 00:10:00",
      "Type": "Cron",
      "Name": "SpoolMailsReprocess",
      "LastWorkerRunningTime": "N/A"
    },
    "SessionDeleteExpired": {
      "LastWorkerStatus": "Success",
      "LastExecutionTime": "2021-11-18 14:55:00",
      "NextExecutionTime": "2021-11-18 16:55:00",
      "Type": "Cron",
      "Name": "SessionDeleteExpired",
      "LastWorkerRunningTime": "< 1 Second"
    },
    "MailQueueSend": {
      "LastExecutionTime": "2021-11-18 15:22:00",
      "LastWorkerStatus": "Success",
      "NextExecutionTime": "2021-11-18 16:08:00",
      "Type": "Cron",
      "LastWorkerRunningTime": "< 1 Second",
      "Name": "MailQueueSend"
    },
    "GenerateDashboardStats": {
      "LastWorkerRunningTime": "< 1 Second",
      "Name": "GenerateDashboardStats",
      "Type": "Cron",
      "NextExecutionTime": "2021-11-18 17:05:00",
      "LastExecutionTime": "2021-11-18 15:05:00",
      "LastWorkerStatus": "Success"
    },
    "TicketPendingCheck": {
      "LastWorkerStatus": "Success",
      "LastExecutionTime": "2021-11-18 14:45:00",
      "NextExecutionTime": "2021-11-18 16:45:00",
      "Type": "Cron",
      "Name": "TicketPendingCheck",
      "LastWorkerRunningTime": "< 1 Second"
    },
    "MailAccountFetch": {
      "LastWorkerRunningTime": "< 1 Second",
      "Name": "MailAccountFetch",
      "Type": "Cron",
      "NextExecutionTime": "2021-11-18 16:10:00",
      "LastExecutionTime": "2021-11-18 15:20:00",
      "LastWorkerStatus": "Success"
    },
    "CommunicationLogDelete": {
      "NextExecutionTime": "2021-11-19 03:00:00",
      "LastExecutionTime": "2021-11-18 03:00:00",
      "LastWorkerStatus": "N/A",
      "LastWorkerRunningTime": "N/A",
      "Name": "CommunicationLogDelete",
      "Type": "Cron"
    },
    "RenewCustomerSMIMECertificates": {
      "Name": "RenewCustomerSMIMECertificates",
      "LastWorkerRunningTime": "N/A",
      "Type": "Cron",
      "NextExecutionTime": "2021-11-19 02:02:00",
      "LastWorkerStatus": "N/A",
      "LastExecutionTime": "2021-11-18 02:02:00"
    }
  },
  "Unhandled Worker Tasks": {
    "Kernel::System::SysConfig-ConfigurationInvalidList()": {
      "Name": "Kernel::System::SysConfig-ConfigurationInvalidList()",
      "Type": "AsynchronousExecutor",
      "CreateTime": "2021-11-18 15:49:09"
    }
  },
  "MailQueue": {
    "Count": 0
  },
  "CommunicationLog": {
    "Accounts": {
      "IMAPS": [
        {
          "AccountID": "1",
          "AccountType": "IMAPS",
          "Status": "Ok",
          "Transport": "Email"
        },
        {
          "AccountID": "2",
          "AccountType": "POP3",
          "Status": "Ok",
          "Transport": "Email"
        }
      ],
      "SMTPTLS": [
        {
          "AccountType": "SMTPTLS",
          "Status": "Ok",
          "Transport": "Email"
        }
      ],
      "STDIN": [
        {
          "AccountType": "STDIN",
          "Status": "Ok",
          "Transport": "Email"
        }
      ]
    },
    "All": 2760,
    "AverageProcessingTime": 0.6,
    "Failed": 0,
    "Health": "OK",
    "Processing": 1,
    "Successful": 2759
  },
}
```
