# Reachability

``` swift
public class Reachability
```

## Nested Types

  - [Reachability.NetworkStatus](Reachability_NetworkStatus)
  - [Reachability.Connection](Reachability_Connection)

## Nested Type Aliases

## NetworkReachable

``` swift
Typealias(context: Optional("Reachability"), attributes: [], modifiers: [public], keyword: "typealias", name: "NetworkReachable", initializedType: Optional("(Reachability) -> ()"), genericParameters: [], genericRequirements: [])
```

## NetworkUnreachable

``` swift
Typealias(context: Optional("Reachability"), attributes: [], modifiers: [public], keyword: "typealias", name: "NetworkUnreachable", initializedType: Optional("(Reachability) -> ()"), genericParameters: [], genericRequirements: [])
```

## Initializers

## init(reachabilityRef:queueQoS:targetQueue:)

``` swift
required public init(reachabilityRef: SCNetworkReachability, queueQoS: DispatchQoS = .default, targetQueue: DispatchQueue? = nil)
```

## init?(hostname:queueQoS:targetQueue:)

``` swift
public convenience init?(hostname: String, queueQoS: DispatchQoS = .default, targetQueue: DispatchQueue? = nil)
```

## init?(queueQoS:targetQueue:)

``` swift
public convenience init?(queueQoS: DispatchQoS = .default, targetQueue: DispatchQueue? = nil)
```

## Properties

## whenReachable

``` swift
var whenReachable: NetworkReachable?
```

## whenUnreachable

``` swift
var whenUnreachable: NetworkUnreachable?
```

## reachableOnWWAN

``` swift
let reachableOnWWAN: Bool = true
```

## allowsCellularConnection

Set to `false` to force Reachability.connection to .none when on cellular connection (default value `true`)

``` swift
var allowsCellularConnection: Bool
```

## notificationCenter

``` swift
var notificationCenter: NotificationCenter = NotificationCenter.default
```

## currentReachabilityString

``` swift
var currentReachabilityString: String
```

## currentReachabilityStatus

``` swift
var currentReachabilityStatus: Connection
```

## connection

``` swift
var connection: Connection
```

## isReachable

``` swift
var isReachable: Bool
```

## isReachableViaWWAN

``` swift
var isReachableViaWWAN: Bool
```

## isReachableViaWiFi

``` swift
var isReachableViaWiFi: Bool
```

## description

``` swift
var description: String
```

## Methods

## startNotifier()

``` swift
func startNotifier() throws
```

## stopNotifier()

``` swift
func stopNotifier()
```
