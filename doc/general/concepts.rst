..
   ****************************************************************************
    pgvroom Manual
    Copyright(c) pgvroom Contributors

    This documentation is licensed under a Creative Commons Attribution-Share
    Alike 3.0 License: https://creativecommons.org/licenses/by-sa/3.0/
   ****************************************************************************

|

* `Documentation <https://vrp.pgrouting.org/>`__ → `pgvroom v0 <https://vrp.pgrouting.org/v0>`__
* Supported Versions
  `Latest <https://vrp.pgrouting.org/latest/en/concepts.html>`__
  (`v0 <https://vrp.pgrouting.org/v0/en/concepts.html>`__)

Concepts
===============================================================================

.. contents::

VROOM is an open-source optimization engine that aims at providing good solutions
to various real-life vehicle routing problems (VRP) within a small computing time.

VROOM can solve several well-known types of vehicle routing problems (VRP).

- TSP (travelling salesman problem)
- CVRP (capacitated VRP)
- VRPTW (VRP with time windows)
- MDHVRPTW (multi-depot heterogeneous vehicle VRPTW)
- PDPTW (pickup-and-delivery problem with TW)

VROOM can also solve any mix of the above problem types.

.. see_also_start

* `VROOM: Vehicle Routing Open-source Optimization Machine <https://github.com/VROOM-Project/vroom>`__
* `VROOM API Documentation <https://github.com/VROOM-Project/vroom/blob/master/docs/API.md>`__

.. see_also_end


Characteristics
...............................................................................

VROOM models a Vehicle Routing Problem with ``vehicles``, ``jobs`` and ``shipments``.

The **vehicles** denote the resources that pick and/or deliver the jobs and shipments.
They are characterised by:

- Capacity on arbitrary number of metrics
- Skills
- Working hours
- Driver breaks
- Start and end defined on a per-vehicle basis
- Start and end can be different
- Open trip optimization (only start or only end defined)

The **jobs** denote the single-location pickup and/or delivery tasks, and the **shipments**
denote the pickup-and-delivery tasks that should happen within the same route.
They are characterised by:

- Delivery/pickup amounts on arbitrary number of metrics
- Service time windows
- Service duration
- Skills
- Priority

Terminologies
...............................................................................

- **Tasks**: Either jobs or shipments are referred to as tasks.
- **Skills**: Every task and vehicle may have some set of skills. A task can be
  served by only that vehicle which has all the skills of the task.
- **Priority**: Tasks may have some priority assigned, which is useful when all
  tasks cannot be performed due to constraints, so the tasks with low priority
  are left unassigned.
- **Amount (for shipment), Pickup and delivery (for job)**: They denote the
  multidimensional quantities such as number of items, weights, volume, etc.
- **Capacity (for vehicle)**: Every vehicle may have some capacity, denoting the
  multidimensional quantities. A vehicle can serve only those sets of tasks such
  that the total sum of the quantity does not exceed the vehicle capacity, at
  any point of the route.
- **Time Window**: An interval of time during which some activity can be
  performed, such as working hours of the vehicle, break of the vehicle, or
  service start time for a task.
- **Break**: Array of time windows, denoting valid slots for the break start of
  a vehicle.
- **Setup time**: Setup times serve as a mean to describe the time it takes to
  get started for a task at a given location.
  This models a duration that should not be re-applied for other tasks following
  at the same place.
  So the total "action time" for a task is ``setup + service`` upon arriving at
  a new location or ``service`` only if performing a new task at the previous
  vehicle location.
- **Service time**: The additional time to be spent by a vehicle while serving a
  task.
- **Travel time**: The total time the vehicle travels during its route.
- **Waiting time**: The total time the vehicle is idle, i.e. it is neither
  traveling nor servicing any task. It is generally the time spent by a vehicle
  waiting for a task service to open.

Getting Started
...............................................................................

This is a simple guide to walk you through the steps of getting started
with pgvroom. In this guide we will cover:

Inner Queries
-------------------------------------------------------------------------------

Vroom, because of the data types used internally, some maximum values apply.

For ``TIMESTAMP``:

.. literalinclude:: concepts.queries
   :start-after: q1
   :end-before: q2

For ``INTERVAL``:

.. literalinclude:: concepts.queries
   :start-after: q2
   :end-before: q3


Jobs SQL
*******************************************************************************

.. jobs_start

A ``SELECT`` statement that returns the following columns:

| ``id, location_id``
| ``[setup, service, delivery, pickup, skills, priority, data]``

Maximum values apply from vroom

``setup`` and ``service``

- |intervalmax|

``skills``

- :math:`2147483647`

``priority``

- :math:`100`

.. list-table::
   :width: 81
   :widths: auto
   :header-rows: 1

   - - Column
     - Type
     - Default
     - Description
   - - ``id``
     - |ANY-INTEGER|
     -
     - Positive unique identifier of the job.
   - - ``location_id``
     - |ANY-INTEGER|
     -
     - Positive unique identifier of the location of the job.
   - - ``setup``
     - |interval|
     - |interval0|
     - The Job setup duration.

   - - ``service``
     - |interval|
     - |interval0|
     - The Job service duration. Max value:
   - - ``pickup``
     - ``ARRAY[ANY-INTEGER]``
     - ``[]``
     - Array of non-negative integers describing multidimensional quantities for
       pickup such as number of items, weight, volume etc.

       - All jobs must have the same value of :code:`array_length(pickup, 1)`
   - - ``delivery``
     - ``ARRAY[ANY-INTEGER]``
     - ``[]``
     - Array of non-negative integers describing multidimensional quantities for
       delivery such as number of items, weight, volume etc.

       - All jobs must have the same value of :code:`array_length(delivery, 1)`
   - - ``skills``
     - ``ARRAY[ANY-INTEGER]``
     - ``[]``
     - Array of non-negative integers defining mandatory skills.
   - - ``priority``
     - ``INTEGER``
     - :math:`0`
     - Value range: :math:`[0, 100]`
   - - ``data``
     - ``JSONB``
     - ``'{}'::JSONB``
     - Any metadata information of the job.

.. jobs_end

Shipments SQL
*******************************************************************************

.. shipments_start

A ``SELECT`` statement that returns the following columns:

| ``id``
| ``p_location_id, [p_setup, p_service, p_data]``
| ``d_location_id, [d_setup, d_service, d_data]``
| ``[amount, skills, priority]``

Maximum values apply from vroom

``p_setup``, ``p_service``, ``d_setup``, ``d_service``

- |intervalmax|

``skills``

- :math:`2147483647`

``priority``

- :math:`100`

.. list-table::
   :width: 81
   :widths: auto
   :header-rows: 1

   - - Column
     - Type
     - Default
     - Description
   - - ``id``
     - |ANY-INTEGER|
     -
     - Positive unique identifier of the shipment.
   - - ``p_location_id``
     - |ANY-INTEGER|
     -
     - Positive unique identifier of the pickup location.
   - - ``p_setup``
     - |interval|
     - |interval0|
     - The pickup setup duration
   - - ``p_service``
     - |interval|
     - |interval0|
     - The pickup service duration
   - - ``p_data``
     - ``JSONB``
     - ``'{}'::JSONB``
     - Any metadata information of the pickup.
   - - ``d_location_id``
     - |ANY-INTEGER|
     -
     - Positive unique identifier of the pickup location.
   - - ``d_setup``
     - |interval|
     - |interval0|
     - The pickup setup duration
   - - ``d_service``
     - |interval|
     - |interval0|
     - The pickup service duration
   - - ``d_data``
     - ``JSONB``
     - ``'{}'::JSONB``
     - Any metadata information of the delivery.
   - - ``amount``
     - ``ARRAY[ANY-INTEGER]``
     - ``[]``
     - Array of non-negative integers describing multidimensional quantities
       such as number of items, weight, volume etc.

       - All shipments must have the same value of :code:`array_length(amount,
         1)`

   - - ``skills``
     - ``ARRAY[ANY-INTEGER]``
     - ``[]``
     - Array of non-negative integers defining mandatory skills.

       - :math:`values \leq 2147483647`
   - - ``priority``
     - ``INTEGER``
     - :math:`0`
     - Value range: :math:`[0, 100]`

.. shipments_end

Vehicles SQL
*******************************************************************************

.. vroom_vehicles_start

A ``SELECT`` statement that returns the following columns:

| ``id, start_id, end_id``
| ``[capacity, skills, tw_open, tw_close, speed_factor, max_tasks, data]``

Maximum values apply from vroom

``skills``

- :math:`2147483647`

``priority``

- :math:`100`

.. list-table::
   :width: 81
   :widths: 14,20,10,37
   :header-rows: 1

   - - Column
     - Type
     - Default
     - Description
   - - ``id``
     - |ANY-INTEGER|
     -
     - Positive unique identifier of the vehicle.
   - - ``start_id``
     - |ANY-INTEGER|
     -
     - Positive unique identifier of the start location.
   - - ``end_id``
     - |ANY-INTEGER|
     -
     - Positive unique identifier of the end location.
   - - ``capacity``
     - ``ARRAY[ANY-INTEGER]``
     - ``[]``
     - Array of non-negative integers describing multidimensional quantities
       such as number of items, weight, volume etc.

       - All vehicles must have the same value of :code:`array_length(capacity,
         1)`
   - - ``skills``
     - ``ARRAY[ANY-INTEGER]``
     - ``[]``
     - Array of non-negative integers defining mandatory skills.
   - - ``tw_open``
     - |timestamp|
     - |tw_open_default|
     - Time window opening time.

       - :code:`tw_open \leq tw_close`
   - - ``tw_close``
     - |timestamp|
     - |tw_close_default|
     - Time window closing time.

       - :code:`tw_open \leq tw_close`
   - - ``speed_factor``
     - |ANY-NUMERICAL|
     - :math:`1.0`
     - Vehicle travel time multiplier.

       - Max value of speed factor for a vehicle shall not be greater than 5
         times the speed factor of any other vehicle.
   - - ``max_tasks``
     - ``INTEGER``
     - :math:`2147483647`
     - Maximum number of tasks in a route for the vehicle.

       - A job, pickup, or delivery is counted as a single task.
   - - ``data``
     - ``JSONB``
     - ``'{}'::JSONB``
     - Any metadata information of the vehicle.

**Note**:

- At least one of the ``start_id`` or ``end_id`` shall be present.
- If ``end_id`` is omitted, the resulting route will stop at the last visited
  task, whose choice is determined by the optimization process.
- If ``start_id`` is omitted, the resulting route will start at the first
  visited task, whose choice is determined by the optimization process.
- To request a round trip, specify both ``start_id`` and ``end_id`` as the same
  index.
- A vehicle is only allowed to serve a set of tasks if the resulting load at
  each route step is lower than the matching value in capacity for each metric.
  When using multiple components for amounts, it is recommended to put the most
  important/limiting metrics first.
- It is assumed that all delivery-related amounts for jobs are loaded at vehicle
  start, while all pickup-related amounts for jobs are brought back at vehicle
  end.

.. vroom_vehicles_end

Vroom Matrix SQL
*******************************************************************************

.. vroom_matrix_start

A ``SELECT`` statement that returns the following columns:

| ``start_id, end_id, duration``
| ``[ cost]``

.. list-table::
   :width: 81
   :widths: auto
   :header-rows: 1

   - - Column
     - Type
     - Default
     - Description
   - - ``start_id``
     - |ANY-INTEGER|
     -
     - Identifier of the start node.
   - - ``end_id``
     - |ANY-INTEGER|
     -
     - Identifier of the end node.
   - - ``duration``
     - |interval|
     -
     - Time to travel from ``start_id`` to ``end_id``
   - - ``cost``
     - |interval|
     - ``duration``
     - Cost of travel from ``start_id`` to ``end_id``

.. vroom_matrix_end

Breaks SQL
*******************************************************************************

.. breaks_start

A ``SELECT`` statement that returns the following columns:

| ``id, vehicle_id``
| ``[service, data]``

.. list-table::
   :width: 81
   :widths: auto
   :header-rows: 1

   - - Column
     - Type
     - Default
     - Description
   - - ``id``
     - |ANY-INTEGER|
     -
     - Positive unique identifier of the break.  Unique for the same vehicle.
   - - ``vehicle_id``
     - |ANY-INTEGER|
     -
     - Positive unique identifier of the vehicle.
   - - ``service``
     - |interval|
     - |interval0|
     - The break duration
   - - ``data``
     - ``JSONB``
     - ``'{}'::JSONB``
     - Any metadata information of the break.

.. breaks_end


Time Windows SQL
*******************************************************************************

.. rubric:: Shipment Time Windows SQL

.. shipments_time_windows_start

A ``SELECT`` statement that returns the following columns:

| ``id, tw_open, tw_close``
| ``[kind]``

.. list-table::
   :width: 81
   :widths: 14 14 44
   :header-rows: 1

   - - Column
     - Type
     - Description
   - - ``id``
     - |ANY-INTEGER|
     - Positive unique identifier of the: job, pickup/delivery shipment, or
       break.
   - - ``tw_open``
     - |timestamp|
     - Time window opening time.
   - - ``tw_close``
     - |timestamp|
     - Time window closing time.
   - - ``kind``
     - ``CHAR``
     - Value in ['p', 'd'] indicating whether the time window is for:

       - Pickup shipment, or
       - Delivery shipment.

.. shipments_time_windows_end

.. rubric:: General Time Windows SQL

.. general_time_windows_start

A ``SELECT`` statement that returns the following columns:

``id, tw_open, tw_close``

.. list-table::
   :width: 81
   :widths: auto
   :header-rows: 1

   - - Column
     - Type
     - Description
   - - ``id``
     - |ANY-INTEGER|
     - Positive unique identifier of the: job, pickup/delivery shipment, or
       break.
   - - ``tw_open``
     - |timestamp|
     - Time window opening time.
   - - ``tw_close``
     - |timestamp|
     - Time window closing time.

.. general_time_windows_end

.. time_windows_note_start

**Note**:

- All timings are in **seconds** when represented as an ``INTEGER``.
- Every row must satisfy the condition: :code:`tw_open ≤ tw_close`.
- Time windows can be interpreted by the users:

  - **Relative values**, e.g.

    - Let the beginning of the planning horizon :math:`0`.
    - for a 4 hour time window (:math:`4 * 3600 = 14400` seconds) starting from
      the planning horizon

      - ``tw_open`` = :math:`0`
      - ``tw_close`` = :math:`14400`

    - Times reported in output relative to the start of the planning horizon.

  - **Absolute values**,

    - Let the beginning of the planning horizon ``2019-07-30 08:00:00``
    - for a 4 hour time window starting from the planning horizon

      - ``tw_open`` = ``2019-07-30 08:00:00``
      - ``tw_close`` = ``2019-07-30 12:00:00``

    -  Times reported in output can be interpreted as ``TIMESTAMP``.

.. time_windows_note_end


Return columns & values
--------------------------------------------------------------------------------

.. vroom_result_start

Returns set of

.. code-block:: none

    (seq, vehicle_seq, vehicle_id, vehicle_data, step_seq, step_type, task_id,
     task_data, arrival, travel_time, service_time, waiting_time, load)

.. list-table::
   :width: 81
   :widths: auto
   :header-rows: 1

   - - Column
     - Type
     - Description
   - - ``seq``
     - ``BIGINT``
     -  Sequential value starting from **1**.
   - - ``vehicle_seq``
     - ``BIGINT``
     - Sequential value starting from **1** for current vehicles.  The
       :math:`n^{th}` vehicle in the solution.
   - - ``vehicle_id``
     - ``BIGINT``
     - Current vehicle identifier.

       - ``-1``: Vehicle denoting all the unallocated tasks.
       - ``0``: Summary row for the complete problem
   - - ``vehicle_data``
     - ``JSONB``
     - Metadata information of the vehicle.
   - - ``step_seq``
     - ``BIGINT``
     - Sequential value starting from **1** for the stops made by the current
       vehicle. The :math:`m^{th}` stop of the current vehicle.

       - ``0``: Summary row
   - - ``step_type``
     - ``BIGINT``
     - Kind of the step location the vehicle is at:

       - ``0``: Summary row
       - ``1``: Starting location
       - ``2``: Job location
       - ``3``: Pickup location
       - ``4``: Delivery location
       - ``5``: Break location
       - ``6``: Ending location

   - - ``task_id``
     - ``BIGINT``
     - Identifier of the task performed at this step.

       - ``0``: Summary row
       - ``-1``: If the step is starting/ending location.
   - - ``location_id``
     - ``BIGINT``
     - Identifier of the task location.

       - ``0``: Summary row
   - - ``task_data``
     - ``JSONB``
     - Metadata information of the task.
   - - ``arrival``
     - |timestamp|
     - Estimated time of arrival at this step.
   - - ``travel_time``
     - |interval|
     - Travel time from previous ``step_seq`` to current ``step_seq``.

       - ``0``: When ``step_type = 1``
   - - ``setup_time``
     - |interval|
     - Setup time at this step.
   - - ``service_time``
     - |interval|
     - Service time at this step.
   - - ``waiting_time``
     - |interval|
     - Waiting time at this step.
   - - ``departure``
     - |timestamp|
     - Estimated time of departure at this step.

       - :math:`arrival + service\_time + waiting\_time`.
   - - ``load``
     - ``BIGINT``
     - Vehicle load after step completion (with capacity constraints)

**Note**:

- Unallocated tasks are mentioned at the end with :code:`vehicle_id = -1`.
- The last step of every vehicle denotes the summary row, where the columns
  ``travel_time``, ``service_time`` and ``waiting_time`` denote the total time
  for the corresponding vehicle,
- The last row denotes the summary for the complete problem, where the columns
  ``travel_time``, ``service_time`` and ``waiting_time`` denote the total time
  for the complete problem,

.. vroom_result_end


.. rubric:: Indices and tables

* :ref:`genindex`
* :ref:`search`

.. |interval| replace:: :abbr:`ANY-INTERVAL(INTERVAL, SMALLINT, INTEGER, BIGINT)`
.. |interval0| replace:: :abbr:`INTERVAL 0('make_interval(secs => 0), 0)`
.. |intervalmax| replace:: **INTERVAL**: ``make_interval(secs => 4294967295)`` and |br| |ANY-INTEGER|: :math:`4294967295`
.. |timestamp| replace:: :abbr:`ANY-TIMESTAMP(TIMESTAMP, SMALLINT, INTEGER, BIGINT)`
.. |tw_open_default| replace:: :abbr:`TW-OPEN-DEFAULT(to_timestamp(0), 0)`
.. |tw_close_default| replace:: :abbr:`TW-CLOSE-DEFAULT(to_timestamp(4294967295), 4294967295)`
