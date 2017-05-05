# Survey

Takes in a question and answers file and outputs the information, providing summaries and averages where applicable.

Persists survey data to disk across restart allowing for easily reloading previous surveys.

## Getting Started
Getting started is pretty simple

`git clone https://github.com/harrisonl/survey`

`cd survey && mix deps.get`

`mix escript.build`

This application utlises the following languages/packages:

* Elixir 1.4+
* CSV
* RexTable

## Usage

To analyse the results of a question and sample file, you simply pass them the CLI application 
using the `-q` or `--questions` flag for the questions file and `-a` or `--answers` flag for the answers file.

E.g To run the sample data:

`./survey -q ./test/questions_sample.csv, -a ./test/answers_sample.csv`

To load a previously ran survey simply pass the `--survey` or `-s` switch along with the survey's unique key

`./survey --survey sdj345dg82ndf3f=`

## Testing

To test the application run:

`mix test`

In the root directory.

*Note: There is a random issue where sometimes when runnning the above command a few specs will fail. This is due to a race condition with all specs running, but have yet to be able to figure it out*

## Overview

I decided to build this out in Elixir/Erlang due to the concurrent nature of the language and fault tolerance provided by
the OTP module.

This application is currently seperated into 6 main modules.

1. **CLI** -> Parses the arguments and transforms the files through the different modules
2. **Parser** -> Takes in two csv files and parsers them into a consumable data structure
3. **Analyser** -> Takes this parsed data and analyses it, returning a results struct which can be easily displayed
4. **ResultsViewer** -> Takes in a results struct and outputs the information in tables
5. **State** -> Tracks the current state of the application. Currently has limited functionality but was put into the application in order
cater for complex menu systems/options etc. if the application was to be extended
6. **Cache** -> Used to store previously processed surveys to save the user having to reprocess them.

## Discussion

### Module Seperation
The reason for seperating the application into these modules is due to ensuring there is a seperation of responsibility. 

Each of these modules performs one task in the transformation process, parsing -> analysing -> displaying. This makes the application more modular and extensible in the future if the need arised.

### Supervision
As this is an elixir OTP application, by default the application is supervised, meaning that if one of the worker servers die, it is promptly restarted. This provides a level of fault tolerance that you can't get in other languages (well this simply).

### ETS
Currently the use of ETS is a bit overkill and actually increases the VM start up time. However but considering the exstensibility of the application, it would be quite useful.

E.g. If we were to implement a menu system where users can navigate between processing new files, viewing previous surveys etc. it would be perfect as all the survey data would be kept in memory and easily accessed. It also reduces the overhead of having to have a full database to store the data.

## Extending

### Workers
If the application were to be extended to process multiple files at once, you could simply replace the `Parser` module with a worker system (see image below) and the overall functionality of the application wouldn't change. This would allow concurrent processing of multiple files at the same time, improving the speed as well as the user experience.

If this application was going to be used to process larger/multiple files at once, the below image shows how I would replace the `Parser` and `Analyse` modules with a worker queue system. 

![Worker Diagram](//i.imgur.com/0tQ0n1b.jpg)

In the above diagram circles represent supervisors and squares gen-servers with lines representing the supervision tree. 

In this example, the overarching supervisor ensures each sub-supervision tree stays up and running. Moving down a line, we have a supervisor in charge of each *pool* of workers. 

This supervises a parser_server and a parser_worker_supervisor. The parser_server is in charge of keeping track of the workers that are available (checked in) and the data to be processed. 

When a new file or piece of data is passed to the server, it checkouts a worker who performs a given process on the data. Once that worker is completed, it checks it's selfback in and the cycle continues.

This approach would allow for fault tolerance, meaning that if invalid or corrupt data was to be sent to the system, **which is quite common when dealing with CSV's**, the whole application wouldn't crash, rather just that one worker, which would then be promptly restarted by the **parser_supervisor_worker**. 

The benefit of having the extra **parser_worker_supervisor** below the **parser_supervisor** is that in case of multiple worker failures/restarts the whole pool won't be brought down, meaning we would lose all queue data from the **parser_server**, only the **parser_worker_supervisor** which will then be safely restarted by the **parser_supervisor**.

### ETS
Like I said above, the cache is a bit of overkill. However if the application was to become distributed, it would become very handy.

E.g. If another node was connected (e.g. across the otherside of the country), then you could have on it connect pull across all the data from hive of already existing nodes, meaning that it would have access to all the surveys which have been loaded onto any node in the network. This would however introduce other complications such as ensuring data consistency, and node failure.

## Contributing

To contribute to the project:

1. Fork the project
2. Make Changes
3. Create a Pull Request
