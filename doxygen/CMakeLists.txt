
option(BUILD_DOXY "Set ON|OFF (default=ON) to build Developers Documentation" ON)

if (BUILD_DOXY)
  message(STATUS "Developers documentation.")
  find_package(Doxygen ${DOXYGEN_MINIMUM_VERSION})

  if(Doxygen_FOUND)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile @ONLY)

    doxygen_add_docs(
      doxy
      ALL
      COMMENT "Generating API documentation with Doxygen" VERBATIM
      CONFIG_FILE ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile
    )

    message(".....OK")
  endif()

endif()
