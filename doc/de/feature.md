# Funktionalität

Dieses Paket stellt einen Webservice zum Monitoring. Er liefert Informationen über den Status der Daemon Tasks, sowie den Mailqueue Status.

Im Standard sind folgende Module enthalten:

- ArticleSearchIndexRebuild
- CommunicationLogDelete
- ConfigurationDeploymentCleanup
- CoreCacheCleanup
- EscalationCheck
- GenerateDashboardStats
- GeneticInterfaceDebugLogCleanup
- LoaderCacheDelete
- MailAccountFetch
- MailQueueSend
- RenewCustomerSMIMECertificates
- SessionDeleteExpired
- SpoolMailsReprocess
- TicketAcceleratorRebuild
- TicketDraftDeleteExpired
- TicketNumberCounterCleanup
- TicketPendingCheck
- TicketUnlockTimeout
- WebUploadCacheCleanup

Zusätzlich sind auch GenericAgents enthalten die zeitgesteuert ausgeführt werden.

Der zum Aufruf benötigte API-Key wird automatisch erzeugt und kann in der System-Konfiguration nachträglich geändert werden.

Der Name der Einstellung lautet `Znuny::HealthStatus::API::Key`.


Beispiel Abfrage:

```bash
$ URL="https://HOST/otrs/nph-genericinterface.pl/Webservice/HealthStatus/HealthStatusGet"
$ curl -H 'Content-type: text/json' -X POST -d '{"APIKey": "jhgfdsaewrtzui1234567"}' "$URL"
$ curl "${URL}?APIKey=jhgfdsaewrtzui1234567"
```

::: warning  :::
Wir empfehlen die Nutzung per POST-Request, da ansonsten der API-Key in den Logdateien des Webservers und ggf. auch Proxyservern gespeichert wird.
:::::::::::



Ein exemplarische Antwort lautet:

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
    "EscalationCheck": {
      "LastWorkerRunningTime": "1.0 Second(s)",
      "Name": "EscalationCheck",
      "Type": "Cron",
      "NextExecutionTime": "2021-11-18 16:10:00",
      "LastExecutionTime": "2021-11-18 15:20:00",
      "LastWorkerStatus": "Success"
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
    "GeneticInterfaceDebugLogCleanup": {
      "NextExecutionTime": "2021-11-19 03:02:00",
      "LastWorkerStatus": "N/A",
      "LastExecutionTime": "2021-11-18 03:02:00",
      "Name": "GeneticInterfaceDebugLogCleanup",
      "LastWorkerRunningTime": "N/A",
      "Type": "Cron"
    },
    "CoreCacheCleanup": {
      "Name": "CoreCacheCleanup",
      "LastWorkerRunningTime": "N/A",
      "Type": "Cron",
      "NextExecutionTime": "2021-11-21 00:20:00",
      "LastWorkerStatus": "N/A",
      "LastExecutionTime": "2021-11-14 00:20:00"
    },
    "ArticleSearchIndexRebuild": {
      "LastExecutionTime": "2021-11-18 15:22:00",
      "LastWorkerStatus": "Success",
      "NextExecutionTime": "2021-11-18 16:08:00",
      "Type": "Cron",
      "LastWorkerRunningTime": "< 1 Second",
      "Name": "ArticleSearchIndexRebuild"
    },
    "TicketUnlockTimeout": {
      "Name": "TicketUnlockTimeout",
      "LastWorkerRunningTime": "< 1 Second",
      "Type": "Cron",
      "NextExecutionTime": "2021-11-18 16:35:00",
      "LastWorkerStatus": "Success",
      "LastExecutionTime": "2021-11-18 14:35:00"
    },
    "MailQueueSend": {
      "LastExecutionTime": "2021-11-18 15:22:00",
      "LastWorkerStatus": "Success",
      "NextExecutionTime": "2021-11-18 16:08:00",
      "Type": "Cron",
      "LastWorkerRunningTime": "< 1 Second",
      "Name": "MailQueueSend"
    },
    "TicketAcceleratorRebuild": {
      "LastWorkerStatus": "N/A",
      "LastExecutionTime": "2021-11-18 01:01:00",
      "NextExecutionTime": "2021-11-19 01:01:00",
      "Type": "Cron",
      "Name": "TicketAcceleratorRebuild",
      "LastWorkerRunningTime": "N/A"
    },
    "GenerateDashboardStats": {
      "LastWorkerRunningTime": "< 1 Second",
      "Name": "GenerateDashboardStats",
      "Type": "Cron",
      "NextExecutionTime": "2021-11-18 17:05:00",
      "LastExecutionTime": "2021-11-18 15:05:00",
      "LastWorkerStatus": "Success"
    },
    "ConfigurationDeploymentCleanup": {
      "LastWorkerRunningTime": "N/A",
      "Name": "ConfigurationDeploymentCleanup",
      "Type": "Cron",
      "NextExecutionTime": "2021-11-21 00:40:00",
      "LastExecutionTime": "2021-11-14 00:40:00",
      "LastWorkerStatus": "N/A"
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
    "LoaderCacheDelete": {
      "LastWorkerStatus": "N/A",
      "LastExecutionTime": "2021-11-14 00:30:00",
      "NextExecutionTime": "2021-11-21 00:30:00",
      "Type": "Cron",
      "Name": "LoaderCacheDelete",
      "LastWorkerRunningTime": "N/A"
    },
    "WebUploadCacheCleanup": {
      "NextExecutionTime": "2021-11-18 16:46:00",
      "LastExecutionTime": "2021-11-18 14:46:00",
      "LastWorkerStatus": "Success",
      "LastWorkerRunningTime": "< 1 Second",
      "Name": "WebUploadCacheCleanup",
      "Type": "Cron"
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
    },
    "TicketNumberCounterCleanup": {
      "NextExecutionTime": "2021-11-18 16:10:00",
      "LastWorkerStatus": "Success",
      "LastExecutionTime": "2021-11-18 15:20:00",
      "Name": "TicketNumberCounterCleanup",
      "LastWorkerRunningTime": "< 1 Second",
      "Type": "Cron"
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
  }
}
```