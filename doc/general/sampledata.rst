..
   ****************************************************************************
    pgvroom Manual
    Copyright(c) pgvroom Contributors

    This documentation is licensed under a Creative Commons Attribution-Share
    Alike 3.0 License: https://creativecommons.org/licenses/by-sa/3.0/
   ****************************************************************************

Sample Data
===============================================================================

The documentation provides very simple example queries based on a small sample network.
To be able to execute the sample queries, run the following SQL commands to create a table with a small network data set.


VROOM Data
-------------------------------------------------------------------------------

Jobs
...............................................................................

.. literalinclude:: ../../tools/testers/vroomdata.sql
   :start-after: -- JOBS TABLE start
   :end-before: -- JOBS TABLE end

Jobs Time Windows
...............................................................................

.. literalinclude:: ../../tools/testers/vroomdata.sql
   :start-after: -- JOBS TIME WINDOWS TABLE start
   :end-before: -- JOBS TIME WINDOWS TABLE end

Shipments
...............................................................................

.. literalinclude:: ../../tools/testers/vroomdata.sql
   :start-after: -- SHIPMENTS TABLE start
   :end-before: -- SHIPMENTS TABLE end

Shipments Time Windows
...............................................................................

.. literalinclude:: ../../tools/testers/vroomdata.sql
   :start-after: -- SHIPMENTS TIME WINDOWS TABLE start
   :end-before: -- SHIPMENTS TIME WINDOWS TABLE end

Vehicles
...............................................................................

.. literalinclude:: ../../tools/testers/vroomdata.sql
   :start-after: -- VEHICLES TABLE start
   :end-before: -- VEHICLES TABLE end

Breaks
...............................................................................

.. literalinclude:: ../../tools/testers/vroomdata.sql
   :start-after: -- BREAKS TABLE start
   :end-before: -- BREAKS TABLE end

Breaks Time Windows
...............................................................................

.. literalinclude:: ../../tools/testers/vroomdata.sql
   :start-after: -- BREAKS TIME WINDOWS TABLE start
   :end-before: -- BREAKS TIME WINDOWS TABLE end

Matrix
...............................................................................

.. literalinclude:: ../../tools/testers/vroomdata.sql
   :start-after: -- MATRIX TABLE start
   :end-before: -- MATRIX TABLE end

Modified VROOM Data
-------------------------------------------------------------------------------

The tables created using the above VROOM Data are modified for the VROOM functions
with timestamps/interval, as:

.. literalinclude:: ../../docqueries/vroom/vroom.pg
   :start-after: -- q0
   :end-before: -- q1
