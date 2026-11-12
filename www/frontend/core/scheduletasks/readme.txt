To get your system up and running, you will need to set up some scheduled tasks in Lucee.
Set up the following scheduled tasks:

For subscription renewals; the following file EVERY 2 HOURS:
https://yourdomain.com/frontend/core/scheduletasks/subscriptions.cfm?pass=xxxx

The subscription task also checks up to 100 default Payrexx cards per run. It refreshes
card expiry data through Payrexx at most once per day per card and sends reminders about one month
and one week before expiry to customers with recurring bookings. Existing reminder
records prevent repeats for the same card, expiry month and reminder stage.

For the dynamic tasks (e.g. modules) EVERY 2 MINUTES, one per worker:
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

You do not need all 20. variables.scheduleWorkers in config.cfm sets how many workers take
jobs (default 20); calls with a higher task number exit at once.


How the jobs are organised

- Every scheduletask of a module gets one job per customer in the table "scheduler_jobs"
  (unique per scheduletask and customer).
- Which jobs exist follows the bookings (modules.cfc::syncCustomerScheduler): a customer gets
  the tasks of a module that is booked as "free", or whose booking (or the booking of a plan
  that includes the module) runs today - the same rule as the access to the module. A
  canceled module keeps its tasks until its end date. Booking, canceling and the sysadmin
  actions reconcile the customer at once; subscriptions.cfm reconciles all customers on
  every run and repairs whatever is missing or left over.
- The workers share all jobs. Each run takes the next due job, runs it and takes the next
  one, until no job is due. A slow job only holds its own worker.


How a worker run (tasks.cfm?task=NN) protects itself:

- Each run claims its row in the table "schedulecontrol" with a unique run token (lease).
  While the lease is held, further calls for the same worker log a warning and exit.
- The lease expires after variables.scheduleLeaseMinutes (config.cfm, default 60). Only then
  may a new run take the worker over. A takeover is logged and sent by email, because it means
  the previous run was killed or is still running as a zombie (Lucee cannot reliably stop a
  request that exceeded the request timeout). Set the lease longer than your longest job.
  A run stops taking new jobs after half of the lease.
- A job is claimed with SELECT ... FOR UPDATE SKIP LOCKED: two workers never get the same
  job and never wait for each other. The claim moves the next run forward and locks the job
  until the lease expires, so a job that is still running is not started a second time.
- Only the owner of the run token releases the worker. A run that lost its lease logs this
  and leaves the flag to the newer run.
- A task that runs longer than its own interval is logged as a warning (type "scheduletask").
  Those tasks hold a worker for too long and must be fixed in the module.


Upgrading from the shard tables

Migration V23 copies jobs from scheduler_01 .. scheduler_20 to scheduler_jobs; V33 removes
those old tables. When upgrading directly from a version before V23, stop requests to
the old application and its Lucee workers before applying the migrations. Deploy the code
that uses scheduler_jobs before resuming requests and workers.
Reinitialize the application once (?reinit=1 as sysadmin). The Lucee task URLs stay the
same. The next run of subscriptions.cfm reconciles all customers; to run it immediately,
call subscriptions.cfm?pass=xxxx.
