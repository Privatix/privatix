# Agent billing

[Agent billing](https://github.com/Privatix/dappctrl/tree/master/agent/bill) runs periodically SQL query for live `channels` and create `jobs` to `suspend`, `unsuspend` or `terminate` services.

Billing responsible for:

1. Service payment
   * Terminate service, if received payment is equal or greater than `max. deposit`.
   * Suspend service, if delta between expected payment for used units and actually received payment is equal or greater than `max. billing unit lag`. It means that client haven't payed in-time.
   * Unsuspend live service, if delta between expected payment for used units and actually received payment is less than `max. billing unit lag`. It means that client has cleared payment, after he was suspended for not paying in-time.
2. Service aging
   * Termination of services, that was suspended longer that `max. suspend time` for corresponding offering. It prevents client from occupying service without using it for indefinite time.
   * Termination of services, that was never used longer that `max. inactive time` for corresponding offering. It prevents client from occupying service without ever using it for indefinite time.

