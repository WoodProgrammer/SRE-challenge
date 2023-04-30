# Issue Two Ideas
Step-1; At the first I check the logs of the backup system which is responsible to handle customer requirements apart from the logs I check the recent 5xx and throwed exceptions from the application.

After that I check the calls and type of exception; If the exceptions or error logs shows app related or dbComponents I will check the app error;

* I can separate exceptions and log messages with these types;
    * DbError Exceptions like locked table, dropped connections .. etc (take a look with DB Team)

    * AppLevel Exceptions (related with payload, size of backup or file .. etc or non handled logics) (take a look with Dev Team)

    * GCRelated or Resource Related Exceptions (take a look with Dev Team)

default :: 

* If the recent release cause this issue I will rollback the latest release.

