# Jobs

[Jobs](https://github.com/Privatix/dappctrl/tree/master/job) plays important role in application workflows. They are created by:

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

**Job type configurable parameters**

`TryLimit` - Maximum retry count

`TryPeriod` - Delay between retries

`FirstStartDelay` - Delay on first start

`Duplicated` - Allow duplicate of job type per object


**Job type configuration example**

```JSON
"clientPreChannelCreate": {
    "TryLimit": 3,
    "TryPeriod": 60000,
    "FirstStartDelay": 25000,
    "Duplicated": true
}
```


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

**Job queue configuration**

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

**Job workflow schema**

![image with schema](http://privatix.io)


## Job handlers

When job executed its [job handler](https://github.com/Privatix/dappctrl/blob/master/proc/handlers/job.go) is invoked.

---

### Agent jobs

---

`AgentAfterChannelCreate` - registers client and creates `AgentPreEndpointMsgCreate` job.

**Created by:**

- Ethereum monitor events `LogChannelCreated` or `LogOfferingPopedUp`


`AgentAfterChannelTopUp` - updates deposit of a channel in Agents database.

**Created by:**

- Ethereum monitor event `LogChannelToppedUp`


`AgentAfterUncooperativeCloseRequest` - sets channel's status to challenge period.

**Created by:**

- Ethereum monitor event `LogChannelCloseRequested`


`AgentAfterUncooperativeClose` - marks channel closed uncooperatively.

**Created by:**

- Ethereum monitor event `LogUnCooperativeChannelClose`


`AgentAfterCooperativeClose` - marks channel as closed cooperatively.

**Created by:**

- Ethereum monitor event `LogUnCooperativeChannelClose`


`AgentPreServiceSuspend` - marks service as suspended.

**Created by:**

- UI API method `changeChannelStatus`
- Agent billing monitor `VerifyBillingLags()`


`AgentPreServiceUnsuspend` - marks service as active.

**Created by:**

- UI API method `changeChannelStatus`
- Agent billing monitor `VerifySuspendedChannelsAndTryToUnsuspend()`


`AgentPreServiceTerminate` - terminates the service.

**Created by:**

- UI API method `changeChannelStatus`
- Agent billing monitor `VerifyUnitsBasedChannels()`
- Agent billing monitor `VerifyChannelsForInactivity()`
- Agent billing monitor `VerifySuspendedChannelsAndTryToTerminate()`


`AgentPreEndpointMsgCreate` - prepares endpoint message to be sent to client.

**Created by:**

- Job `AgentAfterChannelCreate`


`AgentPreOfferingMsgBCPublish` - publishes offering to blockchain.

**Created by:**

- UI API method `ChangeOfferingStatus`


`AgentAfterOfferingMsgBCPublish` - updates offering status and account balance.

**Created by:**

- Ethereum monitor event `LogOfferingCreated`


`AgentPreOfferingPopUp` - pop ups an offering.

**Created by:**

- UI API method `ChangeOfferingStatus`


`AgentAfterOfferingPopUp` - updates the block number when the offering was popped up.

**Created by:**

- Ethereum monitor event `LogOfferingPopedUp`


`AgentPreOfferingDelete` - calls PSC remove an offering.

**Created by:**

- UI API method `ChangeOfferingStatus`


`AgentAfterOfferingDelete` - set offering status to 'remove'

**Created by:**

- Ethereum monitor event `LogOfferingDeleted`


---

### Client jobs

---

`ClientAfterOfferingDelete` - sets offer status to `remove`

**Created by:**

- Ethereum monitor event `LogOfferingDeleted`


`ClientAfterOfferingPopUp` - updates offering in DB or retrieves from Agent and stores in DB.

**Created by:**

- Ethereum monitor event `LogOfferingPopedUp`


`ClientPreChannelCreate` - triggers a channel creation.

**Created by:**

- UI API method `acceptOffering`


`ClientAfterChannelCreate` - activates channel and triggers access message retrieval

**Created by:**

- Ethereum monitor event `LogChannelCreated`


`ClientEndpointCreate` - decodes endpoint message, saves it in the DB and triggers product configuration.

**Created by:**

- Job `ClientAfterChannelCreate`


`ClientAfterUncooperativeClose` - changes channel status to closed uncooperatively.

**Created by:**

- Ethereum monitor event `LogUnCooperativeChannelClose`


`ClientAfterCooperativeClose` - changes channel status to closed cooperatively and launches termination of service.

**Created by:**

- Ethereum monitor event `LogCooperativeChannelClose`


`ClientPreUncooperativeClose` - terminates service.

**Created by:**

- Job `ClientAfterUncooperativeCloseRequest`


`ClientPreChannelTopUp` - checks client balance and creates transaction to increase channel deposit.

**Created by:**

- UI API method `TopUpChannel`


`ClientAfterChannelTopUp` - updates deposit of a channel in local DB.

**Created by:**

- Ethereum monitor event `LogChannelToppedUp`


`ClientPreUncooperativeCloseRequest` - requests uncooperative close of channel. Challenge period started.

**Created by:**

- UI API method `changeChannelStatus`


`ClientAfterUncooperativeCloseRequest` - waits for channel to close uncooperatively, starts the service termination process.

**Created by:**

- Ethereum monitor event `LogUnCooperativeChannelClose`


`ClientPreServiceTerminate` - terminates service.

**Created by:**

- Job `ClientAfterCooperativeClose`
- Client billing `postPayload()`
- Client billing `processChannel()`
- UI API method `ChangeChannelStatus`


`ClientPreServiceSuspend` - suspends service.

**Created by:**

- UI API method `ChangeChannelStatus`


`ClientPreServiceUnsuspend` - activates service.

**Created by:**

- UI API method `ChangeChannelStatus`


`ClientAfterOfferingMsgBCPublish` - creates offering.

**Created by:**

- Ethereum monitor event `LogOfferingCreated`


`ClientCompleteServiceTransition` - complete service state transition. Service status changes.

**Created by:**

- Session server (adapter)


---

### Common jobs

---

`PreAccountAddBalanceApprove` - approve balance if amount exists.

**Created by:**

- UI API method `transferTokens`


`PreAccountAddBalance` - adds balance to PSC.

**Created by:**

- Ethereum monitor PTC event `Approval`


`AfterAccountAddBalance` - updates PSC and PTC balance of an account.

**Created by:**

- Ethereum monitor PTC event `Transfer`


`PreAccountReturnBalance` - returns from PSC to PTC.

**Created by:**

- UI API method `transferTokens`


`AfterAccountReturnBalance` - updates PSC and PTC balance of an account.

**Created by:**

- Ethereum monitor PTC event `Transfer`


`AccountUpdateBalances` - updates PTC, PSC and ETH account balance values.

**Created by:**

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


`DecrementCurrentSupply` - finds offering and decrements its current supply for Client.

**Created by:**

- Ethereum monitor event `LogChannelCreated`


`IncrementCurrentSupply` - finds offering and increments its current supply for Client.
