..
   ****************************************************************************
    pgvroom Manual
    Copyright(c) pgvroom Contributors

    This documentation is licensed under a Creative Commons Attribution-Share
    Alike 3.0 License: https://creativecommons.org/licenses/by-sa/3.0/
   ****************************************************************************

|

vro_version
===============================================================================

``vro_version`` — Get the only the version

.. rubric:: Availability

Version 0.0.0

* New **Official** function



Description
-------------------------------------------------------------------------------

Returns pgvroom version information.

.. index::
    single: version

Signatures
-------------------------------------------------------------------------------

.. admonition:: \ \
   :class: signatures

   | pgr_version()
   | RETURNS ``TEXT``

:Example: pgvroom Version for this documentatoin

.. literalinclude:: version.queries
   :start-after: -- q1
   :end-before: -- q2

Result Columns
-------------------------------------------------------------------------------

=========== ===============================
 Type       Description
=========== ===============================
``TEXT``    pgvroom version
=========== ===============================


.. rubric:: See Also

* :doc:`vro_full_version`

.. rubric:: Indices and tables

* :ref:`genindex`
* :ref:`search`
