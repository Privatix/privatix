# Jobs

[Jobs](https://github.com/Privatix/dappctrl/tree/master/job) plays important role in application workflows. They are created by:

| Creator | Description |
| :--- | :--- |
| user | by user through `UI API` |
| billing monitor | by billing monitor |
| ethereum monitor | by ethereum monitor |
| job | by another job |
| session server | by session server triggered by adapter, on service status change |

## Names

Jobs names are defined in data model and mapped to [job types](https://github.com/Privatix/dappctrl/blob/master/data/jobs.go)

`Job type` is all jobs with same name.

## Job type configuration

Each `job type` may have its custom configuration taken from `privatix core config`.

#### Job type configurable parameters

`TryLimit` - Maximum retry count

`TryPeriod` - Delay between retries

`FirstStartDelay` - Delay on first start

`Duplicated` - Allow duplicate of job type per object

#### Job type configuration example

```javascript
"clientPreChannelCreate": {
    "TryLimit": 3,
    "TryPeriod": 60000,
    "FirstStartDelay": 25000,
    "Duplicated": true
}
```

## Job structure

```go
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

#### Job queue configuration

```go
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

`Job queue` gets jobs from database table `jobs`. Jobs related to single object \(e.g. particular offering\) processed sequentially, but jobs for different objects \(e.g. two different offerings\) maybe processed in parallel. Sequence is defined using sorting by `CreatedAt` field.

## Job status

| Status | Description |
| :--- | :--- |
| Active | Processing or to be processed |
| Failed | Permanently failed. Retry threshold is reached. |
| Cancelled | Will be excluded from processing. If still running, result will be ignored \(don't care\). |
| Done | Successfully finished. |

#### Job workflow schema

[view schema](https://drive.google.com/file/d/1uhc6uJ1MYDYvzia4y0Ikwg7LfPyZ88I3/view?usp=sharing)

## Job handlers

When job executed its [job handler](https://github.com/Privatix/dappctrl/blob/master/proc/handlers/job.go) is invoked.

### Agent jobs

#### AgentAfterChannelCreate

`AgentAfterChannelCreate` - registers client and creates `AgentPreEndpointMsgCreate` job.

_Created by:_

* Ethereum monitor events `LogChannelCreated` or `LogOfferingPopedUp`

#### AgentAfterChannelTopUp

`AgentAfterChannelTopUp` - updates deposit of a channel in Agents database.

_Created by:_

* Ethereum monitor event `LogChannelToppedUp`

#### AgentAfterUncooperativeCloseRequest

`AgentAfterUncooperativeCloseRequest` - sets channel's status to challenge period.

_Created by:_

* Ethereum monitor event `LogChannelCloseRequested`

#### AgentAfterUncooperativeClose

`AgentAfterUncooperativeClose` - marks channel closed uncooperatively.

_Created by:_

* Ethereum monitor event `LogUnCooperativeChannelClose`

#### AgentAfterCooperativeClose

`AgentAfterCooperativeClose` - marks channel as closed cooperatively.

_Created by:_

* Ethereum monitor event `LogUnCooperativeChannelClose`

#### AgentPreServiceSuspend

`AgentPreServiceSuspend` - marks service as suspended.

_Created by:_

* UI API method `changeChannelStatus`
* Agent billing monitor `VerifyBillingLags()`

#### AgentPreServiceUnsuspend

`AgentPreServiceUnsuspend` - marks service as active.

_Created by:_

* UI API method `changeChannelStatus`
* Agent billing monitor `VerifySuspendedChannelsAndTryToUnsuspend()`

#### AgentPreServiceTerminate

`AgentPreServiceTerminate` - terminates the service.

_Created by:_

* UI API method `changeChannelStatus`
* Agent billing monitor `VerifyUnitsBasedChannels()`
* Agent billing monitor `VerifyChannelsForInactivity()`
* Agent billing monitor `VerifySuspendedChannelsAndTryToTerminate()`

#### AgentPreEndpointMsgCreate

`AgentPreEndpointMsgCreate` - prepares endpoint message to be sent to client.

_Created by:_

* Job `AgentAfterChannelCreate`

#### AgentPreOfferingMsgBCPublish

`AgentPreOfferingMsgBCPublish` - publishes offering to blockchain.

_Created by:_

* UI API method `ChangeOfferingStatus`

#### AgentAfterOfferingMsgBCPublish

`AgentAfterOfferingMsgBCPublish` - updates offering status and account balance.

_Created by:_

* Ethereum monitor event `LogOfferingCreated`

#### AgentPreOfferingPopUp

`AgentPreOfferingPopUp` - pop ups an offering.

_Created by:_

* UI API method `ChangeOfferingStatus`

#### AgentAfterOfferingPopUp

`AgentAfterOfferingPopUp` - updates the block number when the offering was popped up.

_Created by:_

* Ethereum monitor event `LogOfferingPopedUp`

#### AgentPreOfferingDelete

`AgentPreOfferingDelete` - calls PSC remove an offering.

_Created by:_

* UI API method `ChangeOfferingStatus`

#### AgentAfterOfferingDelete

`AgentAfterOfferingDelete` - set offering status to 'remove'

_Created by:_

* Ethereum monitor event `LogOfferingDeleted`

### Client jobs

#### ClientAfterOfferingDelete

`ClientAfterOfferingDelete` - sets offer status to `remove`

_Created by:_

* Ethereum monitor event `LogOfferingDeleted`

#### ClientAfterOfferingPopUp

`ClientAfterOfferingPopUp` - updates offering in DB or retrieves from Agent and stores in DB.

_Created by:_

* Ethereum monitor event `LogOfferingPopedUp`

#### ClientPreChannelCreate

`ClientPreChannelCreate` - triggers a channel creation.

_Created by:_

* UI API method `acceptOffering`

#### ClientAfterChannelCreate

`ClientAfterChannelCreate` - activates channel and triggers access message retrieval

_Created by:_

* Ethereum monitor event `LogChannelCreated`

#### ClientEndpointCreate

`ClientEndpointCreate` - decodes endpoint message, saves it in the DB and triggers product configuration.

_Created by:_

* Job `ClientAfterChannelCreate`

#### ClientAfterUncooperativeClose

`ClientAfterUncooperativeClose` - changes channel status to closed uncooperatively.

_Created by:_

* Ethereum monitor event `LogUnCooperativeChannelClose`

#### ClientAfterCooperativeClose

`ClientAfterCooperativeClose` - changes channel status to closed cooperatively and launches termination of service.

_Created by:_

* Ethereum monitor event `LogCooperativeChannelClose`

#### ClientPreUncooperativeClose

`ClientPreUncooperativeClose` - terminates service.

_Created by:_

* Job `ClientAfterUncooperativeCloseRequest`

#### ClientPreChannelTopUp

`ClientPreChannelTopUp` - checks client balance and creates transaction to increase channel deposit.

_Created by:_

* UI API method `TopUpChannel`

#### ClientAfterChannelTopUp

`ClientAfterChannelTopUp` - updates deposit of a channel in local DB.

_Created by:_

* Ethereum monitor event `LogChannelToppedUp`

#### ClientPreUncooperativeCloseRequest

`ClientPreUncooperativeCloseRequest` - requests uncooperative close of channel. Challenge period started.

_Created by:_

* UI API method `changeChannelStatus`

#### ClientAfterUncooperativeCloseRequest

`ClientAfterUncooperativeCloseRequest` - waits for channel to close uncooperatively, starts the service termination process.

_Created by:_

* Ethereum monitor event `LogUnCooperativeChannelClose`

#### ClientPreServiceTerminate

`ClientPreServiceTerminate` - terminates service.

_Created by:_

* Job `ClientAfterCooperativeClose`
* Client billing `postPayload()`
* Client billing `processChannel()`
* UI API method `ChangeChannelStatus`

#### ClientPreServiceSuspend

`ClientPreServiceSuspend` - suspends service.

_Created by:_

* UI API method `ChangeChannelStatus`

#### ClientPreServiceUnsuspend

`ClientPreServiceUnsuspend` - activates service.

_Created by:_

* UI API method `ChangeChannelStatus`

#### ClientAfterOfferingMsgBCPublish

`ClientAfterOfferingMsgBCPublish` - creates offering.

_Created by:_

* Ethereum monitor event `LogOfferingCreated`

#### ClientCompleteServiceTransition

`ClientCompleteServiceTransition` - complete service state transition. Service status changes.

_Created by:_

* Session server \(adapter\)

### Common jobs

#### PreAccountAddBalanceApprove

`PreAccountAddBalanceApprove` - approve balance if amount exists.

_Created by:_

* UI API method `transferTokens`

#### PreAccountAddBalance

`PreAccountAddBalance` - adds balance to PSC.

_Created by:_

* Ethereum monitor PTC event `Approval`

#### AfterAccountAddBalance

`AfterAccountAddBalance` - updates PSC and PTC balance of an account.

_Created by:_

* Ethereum monitor PTC event `Transfer`

#### PreAccountReturnBalance

`PreAccountReturnBalance` - returns from PSC to PTC.

_Created by:_

* UI API method `transferTokens`

#### AfterAccountReturnBalance

`AfterAccountReturnBalance` - updates PSC and PTC balance of an account.

_Created by:_

* Ethereum monitor PTC event `Transfer`

#### AccountUpdateBalances

`AccountUpdateBalances` - updates PTC, PSC and ETH account balance values.

_Created by:_

* Job AgentAfterUncooperativeClose
* Job AgentAfterCooperativeClose
* Job AgentAfterOfferingMsgBCPublish
* Job AgentAfterOfferingDelete
* Job ClientAfterUncooperativeClose
* Job ClientAfterCooperativeClose
* Job ClientAfterChannelCreate
* Job afterChannelTopUp
* UI API ImportAccountFromHex
* UI API ImportAccountFromJSON
* UI API UpdateBalance

#### DecrementCurrentSupply

`DecrementCurrentSupply` - finds offering and decrements its current supply for Client.

_Created by:_

* Ethereum monitor event `LogChannelCreated`

#### IncrementCurrentSupply

`IncrementCurrentSupply` - finds offering and increments its current supply for Client.

