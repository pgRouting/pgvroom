
SET(LOCAL_FILES
    vro_vroom.rst
    vro_vroomJobs.rst
    vro_vroomShipments.rst
    vro_vroomPlain.rst
    vro_vroomJobsPlain.rst
    vro_vroomShipmentsPlain.rst
    )

foreach (f ${LOCAL_FILES})
    configure_file(${f} "${PGR_DOCUMENTATION_SOURCE_DIR}/${f}")
    list(APPEND LOCAL_DOC_FILES  ${PGR_DOCUMENTATION_SOURCE_DIR}/${f})
endforeach()

set(PROJECT_DOC_FILES ${PROJECT_DOC_FILES} ${LOCAL_DOC_FILES} PARENT_SCOPE)
set(PROJECT_IMG_FILES ${PROJECT_IMG_FILES} PARENT_SCOPE)
