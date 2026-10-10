To get your system up and running, you will need to set up some scheduled tasks in Lucee.
Set up the following scheduled tasks:

For subscription renewals; the following file EVERY 2 HOURS:
https://yourdomain.com/frontend/core/scheduletasks/subscriptions.cfm?pass=xxxx

For the dynamic tasks (e.g. modules) EVERY 2 MINUTES:
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=01&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=02&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=03&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=04&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=05&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=06&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=07&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=08&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=09&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=10&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=11&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=12&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=13&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=14&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=15&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=16&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=17&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=18&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=19&pass=xxxx
https://yourdomain.com/frontend/core/scheduletasks/tasks.cfm?task=20&pass=xxxx

xxxx = password from config.cfm

How a shard run (tasks.cfm?task=NN) protects itself:

- Each run claims its row in the table "schedulecontrol" with a unique run token (lease).
  While the lease is held, further calls for the same shard log a warning and exit.
- The lease expires after variables.scheduleLeaseMinutes (config.cfm, default 60). Only then
  may a new run take the shard over. A takeover is logged and sent by email, because it means
  the previous run was killed or is still running as a zombie (Lucee cannot reliably stop a
  request that exceeded the request timeout). Set the lease longer than your longest
  legitimate shard run.
- Before a task file is included, its row in scheduler_NN is claimed by advancing dtmNextRun.
  A zombie and the run that replaced it therefore never execute the same row twice.
- Only the owner of the run token releases the shard. A run that lost its lease logs this
  and leaves the flag to the newer run.
- A task that runs longer than its own interval is logged as a warning (type "scheduletask").
  Those tasks are the reason for overrunning shards and must be fixed in the module.
