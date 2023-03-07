# Funktionalität

Dieses Paket stellt einen Webservice zum Monitoring bereit. Der Webservice liefert Informationen über den Status der Daemon-Tasks und über die E-Mail-Kommunikation.

Folgende Informationen sind enthalten:

1. der Daemon-Status
2. Anzahl der E-Mails in der Mail-Queue von Znuny, die auf den Versand warten
3. regelmäßig ausgeführte Tasks des Daemons
4. regelmäßig ausgeführte Generic-Agents
5. aktuell ausgeführte Daemon-Tasks
6. anstehenede Daemon-Tasks
7. Informationen zum Kommunikationsprotokoll und den E-Mail-Accounts

Der zum Aufruf benötigte API-Key wird automatisch erzeugt und kann in der System-Konfiguration `Znuny::HealthStatus::API::Key` nachträglich geändert werden.
Für das Kommunikationsprotokoll kann der optionale Parameter `LogHours` genutzt werden. Damit wird angegeben, wie weit die historischen Daten ausgewertet werden.


Beispiel-Abfrage:

```bash
$ URL="https://HOST/otrs/nph-genericinterface.pl/Webservice/HealthStatus/HealthStatusGet"
$ curl -H 'Content-type: text/json' -X POST -d '{"APIKey": "jhgfdsaewrtzui1234567"}' "$URL"
$ curl "${URL}?APIKey=jhgfdsaewrtzui1234567"
```

::: warning  :::
Wir empfehlen die Nutzung per POST-Request, da ansonsten der API-Key in den Logdateien des Webservers und ggf. auch Proxyservern gespeichert wird.
:::::::::::


Eine exemplarische Antwort ist:

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
