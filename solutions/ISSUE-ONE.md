# Issue One Ideas

Step - 1 ; To identify the high latency problem, I have to identify the requests and I will check these stuff;

I will divide the problem in couple of layers shown at below.

## Request Level
* Type of request (media, website-assests, regular http calls .. etc)

## HAProxy Level
The proxy is responsible to handle request at the first level.That's why we have to identify where we are facing this request latency.Let's check this 

Example - 1;

The 60% of the request time spending on app level that's why I have to check App part at first !

---> (REQUEST) ----> HAProxy 20% -----> App 60% ----> Database 20%

Example - 2;
HAProxy smells rat!!
---> (REQUEST) ----> HAProxy 60% -----> App 20% ----> Database 20%

In this section we will discuss the details on HAProxy side.This is a thirdparty tool not developed by our internal sources that's why I have to use all the metrics what I have.

At the first I check the HAProxy metrics by the spread constraits because location of the proxy is one of the key point before routing the request.After I aggregated these metrics I check the tracing data of the HAProxy and CPU Memory spikes .If the load is occuring on specific pods of HAProxy I directly call the infra team to discuss  about routing components of the HAPRoxy.

But the problem spread in all the HAProxy pods and CPU/Memory usage is fine I directly check the HAProxy calls/subcalls and I would like fine waiting syscall or OS level problems beyond of it.

I have experience with bpfrace to identify which syscall cause this wait time .

Based on this information I will check the common issues from the community and possible tuning methods of the HAProxy.

Like eventlistener increment, configuration file adjustmnet, logI/O buffers .. etc

------------------------------------------------------------------------
## Application Server Level

After I define the type of request I will check the subcalls beyond of the request from APM or distributed tracing tool that we have.If distributed trace show the load on HTTP or network I dig into the application behaviour.

To understand the app behaviour I check the stack trace, tcpMetrics, httpLevel Metrics, syscalls and Profiling results. Profiling results will be the first point that I touch if the profiling result shows high wait time memory and CPU (with a function) I dig into the syscalls and identify the network problems. Sometimes , the network problem do not directly shows itself in metrics that's why you have to check the tcpdump results and other tracing results.

## Data Layer Level
If the app facing a problem with the data layer like database, cache or queue system I will check the query types and call the developer members to analyse the queries and database logs.

## Infra Level
* The DC zone that we are facing on. Because the problem might be related with infra level components that's why I will call the Infra team member and start to check all the requests from any firewall, router, switch configurations.


# Conclusion and Answers of the Questions
These are the things that I will check at first.Let's continue with the questions;

## How would you determine if the load is legitimate or if there's a DDoS attack?

The number of request and the type of request can help us to identify whether it is DDOS attack or not especially on HTTP Level.

We can develop a rule based script because the regular type of request like ;

* Certain type of Ip address
* Certain type of domain address, and PATH
* And detect a spike average usage.

## How would you mitigate the load?
According to the application behavouir as I mention at above these topics can applied;
* Increase the number of replica or resource (Horizontal or Vertical Scale ) The axis of the scaling can be change due to the problem.If the app has facing issue with a single huge query I scale up the app stack vertically or tune the entire system.But the count of the request cause this issue I will adjust the number of process, or tune the system around the count of process.
* According to the network stack issues I check the proxy resource and tune option for example in Nginx I can increase number available process and try to increase utilization.

## Suggest several actions to better cope with high traffic.
If I touch a high traffic system, I check linux kernel parameters like reuse_sock_option, somax_conn, MTU values (it should be compatible with the router infront of the system of type of the frame that we using.).

According to the transfered contents like media, stream ... etc  of the websites I also suggest other tuning methods in WordPress and Nginx side.

Notice: In WordPress stack I also would like to trace plugin activity especially on database side.Because it can cause lots of performance problems. In the Saas systems like that, plugin tracing is has huge importance.

## What automated remediation could be configured?
I would like to develop scripts, tools to gather information like that;
* Network Dump (like DNS resolution time, retransmission values ... etc)
* Wordpress dump 
* Application GC dump
* Memory Usage
* Kubernetes CNI diagnostic

If we have an option to run these kind of scripts properly, we can spend less time jumping into the issue.