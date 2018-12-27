# Jobs

Jobs plays important role in application workflows. They are created by:

| Creator          | Description                                                      |
| ---------------- | ---------------------------------------------------------------- |
| user             | by user through `UI API`                                         |
| billing monitor  | by billing monitor                                               |
| ethereum monitor | by ethereum monitor                                              |
| job              | by another job                                                   |
| session server   | by session server triggered by adapter, on service status change |

## Names

Jobs names are defined in data model and mapped to [job types](https://github.com/Privatix/dappctrl/blob/master/data/jobs.go)

`Job type` is all jobs with same name.

## Job type configuration

Each `job type` may have its custom configuration taken from `privatix core config`.

<details><summary>Job type configurable parameters</summary>

`TryLimit` - Maximum retry count

`TryPeriod` - Delay between retries

`FirstStartDelay` - Delay on first start

`Duplicated` - Allow duplicate of job type per object

</details>

<details><summary>Job type configuration example</summary>

```JSON
"clientPreChannelCreate": {
    "TryLimit": 3,
    "TryPeriod": 60000,
    "FirstStartDelay": 25000,
    "Duplicated": true
}
```

</details>

## Job structure

```Go
    type Job struct {
    ID          string    `reform:"id,pk"`
    Type        string    `reform:"type"`
    Status      string    `reform:"status"`
    RelatedType string    `reform:"related_type"`
    RelatedID   string    `reform:"related_id"`
    CreatedAt   time.Time `reform:"created_at"`
    NotBefore   time.Time `reform:"not_before"`
    CreatedBy   string    `reform:"created_by"`
    TryCount    uint8     `reform:"try_count"`
    Data        []byte    `reform:"data"`
```

where

`ID` - uuid

`Type` - job type

`Status` - `Job status`

`RelatedType` - related [object type](https://github.com/Privatix/dappctrl/blob/master/data/jobs.go)

`RelatedID` - database id of related object

`CreatedAt` - time when job was created. Organize sequence

`NotBefore` - delaying start of job

`CreatedBy` - who produced this job

`TryCount` - number of times was job executed

`Data` - additional data that can be processed during job execution

Each job is related to some object using `RelatedType` and `RelatedID`. It may also have some data that is stored in `Data`.

Jobs can be scheduled to start at specific time using `NotBefore`. They can be retried several times when `TryCount` didn't reached `TryLimit` of `job type configuration`.

## Job queue

Job queue is implemented using database table. Its configuration is done in `core config`.

<details><summary>Job queue configuration</summary>

```Go
type Config struct {
    CollectJobs   uint // Number of jobs to process for collect-iteration.
    CollectPeriod uint // Collect-iteration period, in milliseconds.
    WorkerBufLen  uint // Worker buffer length.
    Workers       uint // Number of workers, 0 means number of CPUs.

    TypeConfig                       // Default type configuration.
    Types      map[string]TypeConfig // Type-specific overrides.
}
```

</details>

Function `queue.Add()` will check, if desired job can be created, create it or return an error.

`Job queue workers` - are threads, that periodically scans job queue, retrieves jobs that should be processed and executes them. Workers can run in parallel, can retrieve error codes from underlying functions. Number of workers are defined in `dappctrl.config.json`. Jobs that relates to same object are processed by single worker, preventing race.

`Job queue` gets jobs from database table `jobs`. Jobs related to single object (e.g. particular offering) processed sequentially, but jobs for different objects (e.g. two different offerings) maybe processed in parallel. Sequence is defined using sorting by `CreatedAt` field.

## Job status

| Status    | Description                                                                              |
| --------- | ---------------------------------------------------------------------------------------- |
| Active    | Processing or to be processed                                                            |
| Failed    | Permanently failed. Retry threshold is reached.                                          |
| Cancelled | Will be excluded from processing. If still running, result will be ignored (don't care). |
| Done      | Successfully finished.                                                                   |

<details><summary>Job workflow schema</summary>

![image with schema](http://privatix.io)

</details>

## Job handlers

When job executed its [job handler](https://github.com/Privatix/dappctrl/blob/master/proc/handlers/job.go) is invoked.

---

### Agent jobs

---

`AgentAfterChannelCreate` - registers client and creates `AgentPreEndpointMsgCreate` job.

<details><summary>Created by:</summary>

- Ethereum monitor events `LogChannelCreated` or `LogOfferingPopedUp`

</details>

`AgentAfterChannelTopUp` - updates deposit of a channel in Agents database.

<details><summary>Created by:</summary>

- Ethereum monitor event `LogChannelToppedUp`

</details>

`AgentAfterUncooperativeCloseRequest` - sets channel's status to challenge period.

<details><summary>Created by:</summary>

- Ethereum monitor event `LogChannelCloseRequested`

</details>

`AgentAfterUncooperativeClose` - marks channel closed uncooperatively.

<details><summary>Created by:</summary>

- Ethereum monitor event `LogUnCooperativeChannelClose`

</details>

`AgentAfterCooperativeClose` - marks channel as closed cooperatively.

<details><summary>Created by:</summary>

- Ethereum monitor event `LogUnCooperativeChannelClose`

</details>

`AgentPreServiceSuspend` - marks service as suspended.

<details><summary>Created by:</summary>

- UI API method `changeChannelStatus`
- Agent billing monitor `VerifyBillingLags()`

</details>

`AgentPreServiceUnsuspend` - marks service as active.

<details><summary>Created by:</summary>

- UI API method `changeChannelStatus`
- Agent billing monitor `VerifySuspendedChannelsAndTryToUnsuspend()`

</details>

`AgentPreServiceTerminate` - terminates the service.

<details><summary>Created by:</summary>

- UI API method `changeChannelStatus`
- Agent billing monitor `VerifyUnitsBasedChannels()`
- Agent billing monitor `VerifyChannelsForInactivity()`
- Agent billing monitor `VerifySuspendedChannelsAndTryToTerminate()`

</details>

`AgentPreEndpointMsgCreate` - prepares endpoint message to be sent to client.

<details><summary>Created by:</summary>

- Job `AgentAfterChannelCreate`

</details>

`AgentPreOfferingMsgBCPublish` - publishes offering to blockchain.

<details><summary>Created by:</summary>

- UI API method `ChangeOfferingStatus`

</details>

`AgentAfterOfferingMsgBCPublish` - updates offering status and account balance.

<details><summary>Created by:</summary>

- Ethereum monitor event `LogOfferingCreated`

</details>

`AgentPreOfferingPopUp` - pop ups an offering.

<details><summary>Created by:</summary>

- UI API method `ChangeOfferingStatus`

</details>

`AgentAfterOfferingPopUp` - updates the block number when the offering was popped up.

<details><summary>Created by:</summary>

- Ethereum monitor event `LogOfferingPopedUp`

</details>

`AgentPreOfferingDelete` - calls PSC remove an offering.

<details><summary>Created by:</summary>

- UI API method `ChangeOfferingStatus`

</details>

`AgentAfterOfferingDelete` - set offering status to 'remove'

<details><summary>Created by:</summary>

- Ethereum monitor event `LogOfferingDeleted`

</details>

---

### Client jobs

---

`ClientAfterOfferingDelete` - sets offer status to `remove`

<details><summary>Created by:</summary>

- Ethereum monitor event `LogOfferingDeleted`

</details>

`ClientAfterOfferingPopUp` - updates offering in DB or retrieves from Agent and stores in DB.

<details><summary>Created by:</summary>

- Ethereum monitor event `LogOfferingPopedUp`

</details>

`ClientPreChannelCreate` - triggers a channel creation.

<details><summary>Created by:</summary>

- UI API method `acceptOffering`

</details>

`ClientAfterChannelCreate` - activates channel and triggers access message retrieval

<details><summary>Created by:</summary>

- Ethereum monitor event `LogChannelCreated`

</details>

`ClientEndpointCreate` - decodes endpoint message, saves it in the DB and triggers product configuration.

<details><summary>Created by:</summary>

- Job `ClientAfterChannelCreate`

</details>

`ClientAfterUncooperativeClose` - changes channel status to closed uncooperatively.

<details><summary>Created by:</summary>

- Ethereum monitor event `LogUnCooperativeChannelClose`

</details>

`ClientAfterCooperativeClose` - changes channel status to closed cooperatively and launches termination of service.

<details><summary>Created by:</summary>

- Ethereum monitor event `LogCooperativeChannelClose`

</details>

`ClientPreUncooperativeClose` - terminates service.

<details><summary>Created by:</summary>

- Job `ClientAfterUncooperativeCloseRequest`

</details>

`ClientPreChannelTopUp` - checks client balance and creates transaction to increase channel deposit.

<details><summary>Created by:</summary>

- UI API method `TopUpChannel`

</details>

`ClientAfterChannelTopUp` - updates deposit of a channel in local DB.

<details><summary>Created by:</summary>

- Ethereum monitor event `LogChannelToppedUp`

</details>

`ClientPreUncooperativeCloseRequest` - requests uncooperative close of channel. Challenge period started.

<details><summary>Created by:</summary>

- UI API method `changeChannelStatus`

</details>

`ClientAfterUncooperativeCloseRequest` - waits for channel to close uncooperatively, starts the service termination process.

<details><summary>Created by:</summary>

- Ethereum monitor event `LogUnCooperativeChannelClose`

</details>

`ClientPreServiceTerminate` - terminates service.

<details><summary>Created by:</summary>

- Job `ClientAfterCooperativeClose`
- Client billing `postPayload()`
- Client billing `processChannel()`
- UI API method `ChangeChannelStatus`

</details>

`ClientPreServiceSuspend` - suspends service.

<details><summary>Created by:</summary>

- UI API method `ChangeChannelStatus`

</details>

`ClientPreServiceUnsuspend` - activates service.

<details><summary>Created by:</summary>

- UI API method `ChangeChannelStatus`

</details>

`ClientAfterOfferingMsgBCPublish` - creates offering.

<details><summary>Created by:</summary>

- Ethereum monitor event `LogOfferingCreated`

</details>

`ClientCompleteServiceTransition` - complete service state transition. Service status changes.

<details><summary>Created by:</summary>

- Session server (adapter)

</details>

---

### Common jobs

---

`PreAccountAddBalanceApprove` - approve balance if amount exists.

<details><summary>Created by:</summary>

- UI API method `transferTokens`

</details>

`PreAccountAddBalance` - adds balance to PSC.

<details><summary>Created by:</summary>

- Ethereum monitor PTC event `Approval`

</details>

`AfterAccountAddBalance` - updates PSC and PTC balance of an account.

<details><summary>Created by:</summary>

- Ethereum monitor PTC event `Transfer`

</details>

`PreAccountReturnBalance` - returns from PSC to PTC.

<details><summary>Created by:</summary>

- UI API method `transferTokens`

</details>

`AfterAccountReturnBalance` - updates PSC and PTC balance of an account.

<details><summary>Created by:</summary>

- Ethereum monitor PTC event `Transfer`

</details>

`AccountUpdateBalances` - updates PTC, PSC and ETH account balance values.

<details><summary>Created by:</summary>

- Job AgentAfterUncooperativeClose
- Job AgentAfterCooperativeClose
- Job AgentAfterOfferingMsgBCPublish
- Job AgentAfterOfferingDelete
- Job ClientAfterUncooperativeClose
- Job ClientAfterCooperativeClose
- Job ClientAfterChannelCreate
- Job afterChannelTopUp
- UI API ImportAccountFromHex
- UI API ImportAccountFromJSON
- UI API UpdateBalance

</details>

`DecrementCurrentSupply` - finds offering and decrements its current supply for Client.

<details><summary>Created by:</summary>

- Ethereum monitor event `LogChannelCreated`

</details>

`IncrementCurrentSupply` - finds offering and increments its current supply for Client.
