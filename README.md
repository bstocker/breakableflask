# Breakable Flask


A simple vulnerable Flask application.

This can be used to test out and learn exploitation of common web application vulnerabilities. 

Originally written because I wanted a very simple, single file vulnerable app that I could quickly run up to perform exploitation checks against. 

At the moment, the following vulnerabilities are present:
* Python code injection
* Operating System command injection
* Python deserialisation of arbitrary data (pickle)
* XXE injection
* Padding oracle
* Server side template injection
* SQL injection


New vulnerabilities may be added from time to time as I have need of them.

## Installing dependencies

There is a "requirements.txt" file included so you can install the required Python modules, but you can also just check the code or watch errors when starting to work this out. The code has recently been updated for Python3.

You can install the base required modules using pip like so:

    pip install -r requirements.txt


There are a number of other optional modules you can install if you want to connect to some of the alternate database types, which does require that you have an instance of that database type you can connect to. Install dependencies for these additional databases using pip like so:

    pip install -r database-requirements.txt


If you want to use an Oracle database, you will also need to install further additional software, such as the [Oracle Instant Client](https://www.oracle.com/database/technologies/instant-client.html), because Oracle.


## Running breakableflask

Basic execution of the program is like so, this runs the web server at the default location of `http://127.0.0.1:4000`. An in memory instance of sqlite3 will be used to provide SQL injection capabilities.

    ./main.py

If you want to use another databse engine for SQL injection, you need to run an external database server and run the application with options to specify the database type and connection details. The full list of options can be found by running the program with the `--help` option, but as an example, here is how you could connect to a PostgreSQL server:

    ./main.py --database_type=postgres --database_user=postgres --database_password=password --database_host=127.0.0.1 --database_port=5432

On launch breakableflask will attempt to populate the database server with the needed data to provide the needed SQL functionality. 

If you are using an Oracle database, you need to provide the location of the Oracle client libraries (as installed with the Oracle instant Client or full database) using the `oracle_lib_dir` option.

Given that one of the reasons for this programs existence is to provide a test bed that is as easy as possible to run, there are included instructions in `docker_database_setup.md` file that will help you easily start up an instance of the various supported database types in Docker. 

## Running the hardened Docker image

The repository includes a multi-stage [Dockerfile](./Dockerfile). It keeps build tooling out of the runtime image, disables package caches, and runs the application as the unprivileged `appuser` user.

Build and run it with:

    docker build -t breakableflask:local .
    docker run --rm -p 4000:4000 breakableflask:local

The application is available at `http://127.0.0.1:4000`. The image also defines a health check for this endpoint.

## DevSecOps checks

The [DevSecOps workflow](./.github/workflows/devsecops.yml) runs on pushes and pull requests. It:

1. scans `requirements.txt` with Trivy for HIGH and CRITICAL vulnerabilities;
2. scans the Dockerfile configuration;
3. builds the image and scans it for HIGH and CRITICAL vulnerabilities;
4. allows the final deployment stage only when the previous checks pass.

To run equivalent local checks, install Trivy and use:

    trivy fs --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 requirements.txt
    trivy config --severity HIGH,CRITICAL --exit-code 1 Dockerfile
    docker build -t breakableflask:local .
    trivy image --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 breakableflask:local
