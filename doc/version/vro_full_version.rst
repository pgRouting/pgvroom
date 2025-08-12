..
   ****************************************************************************
    pgvroom Manual
    Copyright(c) pgvroom Contributors

    This documentation is licensed under a Creative Commons Attribution-Share
    Alike 3.0 License: https://creativecommons.org/licenses/by-sa/3.0/
   ****************************************************************************

|

vro_full_version
===============================================================================

``vro_full_version`` — Get the details of pgvroom version information.

.. rubric:: Availability

Version 0.4.1

* Boost removed from the result columns


Version 0.0.0

* New **official** function


Description
-------------------------------------------------------------------------------

Get the details of pgvroom version information

.. index::
    single: full_version

Signatures
-------------------------------------------------------------------------------

.. admonition:: \ \
   :class: signatures

   | pgr_full_version()
   | RETURNS ``(version, build_type, compile_date, library, system, PostgreSQL, compiler, hash)``

:Example: Get the version installed for this documentation.

.. literalinclude:: full_version.queries
   :start-after: -- q1
   :end-before: -- q2

Result Columns
-------------------------------------------------------------------------------

================  =========== ===============================
Column             Type       Description
================  =========== ===============================
``version``       ``TEXT``    pgvroom version
``build_type``    ``TEXT``    The Build type
``compile_date``  ``TEXT``    Compilation date
``library``       ``TEXT``    Library name and version
``system``        ``TEXT``    Operative system
``postgreSQL``    ``TEXT``    pgsql used
``compiler``      ``TEXT``    Compiler and version
``hash``          ``TEXT``    Git hash of pgvroom build
================  =========== ===============================

.. rubric:: See also

* :doc:`vro_version`

.. rubric:: Indices and tables

* :ref:`genindex`
* :ref:`search`
