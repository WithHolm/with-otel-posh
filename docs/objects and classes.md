# objects and classes

## severity
below are the all the log levels supported by the OTEL standard.
Because otel has sop many levels, i have 
| Name   | Value | Description      |
| ------ | ----- | ---------------- |
| trace  | 1     |                  |
| trace2 | 2     | 'system' level.  |
| trace3 | 3     | 'trace' level.   |
| trace4 | 4     |                  |
| debug  | 5     | 'debug' level    |
| debug2 | 6     |                  |
| debug3 | 7     | 'verbose' level  |
| debug4 | 8     |                  |
| info   | 9     | 'info' level     |
| info2  | 10    | 'success' level  |
| info3  | 11    |                  |
| info4  | 12    |                  |
| warn   | 13    | 'warning' level  |
| warn2  | 14    |                  |
| warn3  | 15    |                  |
| warn4  | 16    |                  |
| error  | 17    | 'error' level    |
| error2 | 18    |                  |
| error3 | 19    |                  |
| error4 | 20    |                  |
| fatal  | 21    | 'fatal' level    |
| fatal2 | 22    |                  |
| fatal3 | 23    |                  |
| fatal4 | 24    | 'throwing' level |

## EventItem

| Name           | Type        | Description                              |
| -------------- | ----------- | ---------------------------------------- |
| Type           | `string`    | the string `log`                         |
| Timestamp      | `datetime`  | when the log was created                 |
| Attributes     | `hashtable` | attributes appended to the log objects   |
| Resource       | `string`    | name of the "thing" that is being logged |
| SeverityText   | `string`    | the [severity](#severity) text           |
| SeverityNumber | `int`       | the [severity](#severity) number         |
| Body           | `string`    | the actual log message                   |

## EventItem.Attributes

in the standard this property is defined as "up to the implementation". we have defined it as such:

| Name              | Type     | Description|
| ----------------- | -------- | -------|
| CreationType      | `string` | `callstack` or `custom` - generally what kind of scope is tied. callstack uses the callstack, custom uses the custom span TODO: this may be removed, as it may be uneccecary info |
| Source            | `string` | command that this log was created from|
| LineNumber        | `int`    | line number of the source|
| CustomResource    | `bool`   | This will be removed|
| optionSkipConsole | `bool`   | should the log skip the console?|


## Span
Span is the actual command or script that is being executed. it is the smallest unit of "scope" that can be tracked. this can both be a command, script 

| Name | Type  | Description|
| --| ---| ----|
| name            | `string`          | the name of the span|
| arguments       | `string`          | the arguments of the span|
| file            | `string`          | the file of the span     |
| id              | `string`          | the id of the span. guid value of command, arguments and historyid |
| parent          | `string`          | the parent id of the span|
| historyId       | `string`          | the history id of the span|
| startUtc        | `datetime`        | the start time of the span|
| endUtc          | `datetime`        | the end time of the span.|
| events          | `List[EventItem]` | the events of the span    |
| options         | `hashtable`       | the options of the span. ignore logs, output to console, etc|
| scopeAttributes | `hashtable`       | the scope attributes of the span|

## Trace
Trace defines the main context of a series of spans. for this implementation it is the command that first got called. every command that is called after this will have the same trace id.

| Name | Type | Description |
| ---- | ---- | ----------- |
| options | `hashtable` | the options of the trace|
| name | `string` | the name of the trace|
| arguments | `string` | the arguments of the trace|
| historyId | `string` | the history id of the trace|
| createdTime | `datetime` | the created time of the trace|
| spans | `hashtable` | the spans of the trace|
| id | `string` | the id of the trace.|
