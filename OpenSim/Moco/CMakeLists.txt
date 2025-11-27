# Define the library name.
set(OSIM_LIB_NAME osimMoco)

# Moco has many sources and conditional compilation, so an explicit list is
# clearer than file(GLOB).
set(MOCO_SOURCES
        osimMoco.h
        osimMocoDLL.h
        About.h
        About.cpp
        RegisterTypes_osimMoco.h
        RegisterTypes_osimMoco.cpp
        MocoUtilities.h
        MocoUtilities.cpp
        MocoStudy.h
        MocoStudy.cpp
        MocoBounds.h
        MocoBounds.cpp
        MocoVariableInfo.h
        MocoVariableInfo.cpp
        MocoProblem.h
        MocoProblem.cpp
        MocoProblemInfo.h
        MocoProblemRep.h
        MocoProblemRep.cpp
        MocoGoal/MocoGoal.h
        MocoGoal/MocoGoal.cpp
        MocoGoal/MocoMarkerFinalGoal.h
        MocoGoal/MocoMarkerFinalGoal.cpp
        MocoGoal/MocoMarkerTrackingGoal.h
        MocoGoal/MocoMarkerTrackingGoal.cpp
        MocoWeightSet.h
        MocoGoal/MocoStateTrackingGoal.h
        MocoGoal/MocoStateTrackingGoal.cpp
        MocoGoal/MocoSumSquaredStateGoal.h
        MocoGoal/MocoSumSquaredStateGoal.cpp
        MocoGoal/MocoContactTrackingGoal.cpp
        MocoGoal/MocoContactTrackingGoal.h
        MocoGoal/MocoContactImpulseTrackingGoal.cpp
        MocoGoal/MocoContactImpulseTrackingGoal.h
        MocoGoal/MocoControlGoal.h
        MocoGoal/MocoControlGoal.cpp
        MocoGoal/MocoControlTrackingGoal.h
        MocoGoal/MocoControlTrackingGoal.cpp
        MocoGoal/MocoExpressionBasedParameterGoal.h
        MocoGoal/MocoExpressionBasedParameterGoal.cpp
        MocoGoal/MocoJointReactionGoal.h
        MocoGoal/MocoJointReactionGoal.cpp
        MocoGoal/MocoOrientationTrackingGoal.h
        MocoGoal/MocoOrientationTrackingGoal.cpp
        MocoGoal/MocoOutputGoal.h
        MocoGoal/MocoOutputGoal.cpp
        MocoGoal/MocoTranslationTrackingGoal.h
        MocoGoal/MocoTranslationTrackingGoal.cpp
        MocoGoal/MocoAngularVelocityTrackingGoal.h
        MocoGoal/MocoAngularVelocityTrackingGoal.cpp
        MocoGoal/MocoAccelerationTrackingGoal.h
        MocoGoal/MocoAccelerationTrackingGoal.cpp
        MocoGoal/MocoInitialActivationGoal.cpp
        MocoGoal/MocoInitialActivationGoal.h
        MocoGoal/MocoInitialVelocityEquilibriumDGFGoal.h
        MocoGoal/MocoInitialVelocityEquilibriumDGFGoal.cpp
        MocoGoal/MocoInitialForceEquilibriumDGFGoal.h
        MocoGoal/MocoInitialForceEquilibriumDGFGoal.cpp
        MocoGoal/MocoPeriodicityGoal.h
        MocoGoal/MocoPeriodicityGoal.cpp
        MocoGoal/MocoStepTimeAsymmetryGoal.h
        MocoGoal/MocoStepTimeAsymmetryGoal.cpp
        MocoGoal/MocoStepLengthAsymmetryGoal.h
        MocoGoal/MocoStepLengthAsymmetryGoal.cpp
        MocoGoal/MocoGeneralizedForceTrackingGoal.h
        MocoGoal/MocoGeneralizedForceTrackingGoal.cpp
        MocoSolver.h
        MocoSolver.cpp
        MocoDirectCollocationSolver.h
        MocoDirectCollocationSolver.cpp
        MocoTrajectory.h
        MocoTrajectory.cpp
        MocoParameter.h
        MocoParameter.cpp
        MocoConstraint.h
        MocoConstraint.cpp
        MocoControlBoundConstraint.cpp
        MocoControlBoundConstraint.h
        MocoFrameDistanceConstraint.h
        MocoFrameDistanceConstraint.cpp
        MocoOutputConstraint.h
        MocoOutputConstraint.cpp
        Components/StationPlaneContactForce.h
        Components/StationPlaneContactForce.cpp
        Components/DiscreteForces.h
        Components/DiscreteForces.cpp
        Components/AccelerationMotion.h
        Components/AccelerationMotion.cpp
        Components/ControlDistributor.h
        Components/ControlDistributor.cpp
        Components/ActuatorInputController.h
        Components/ActuatorInputController.cpp
        MocoCasADiSolver/MocoCasADiSolver.h
        MocoCasADiSolver/MocoCasADiSolver.cpp
        MocoInverse.cpp
        MocoInverse.h
        MocoTrack.h
        MocoTrack.cpp
        ModelOperatorsDGF.h
        MocoTool.h
        MocoTool.cpp
        MocoConstraintInfo.h
        MocoConstraintInfo.cpp
        MocoStudyFactory.h
        MocoStudyFactory.cpp
        MocoScaleFactor.h
        MocoScaleFactor.cpp
        MocoOutputBoundConstraint.cpp
        MocoOutputBoundConstraint.h
        MocoStateBoundConstraint.cpp
        MocoStateBoundConstraint.h
)
set(MOCO_HEADERS)
foreach(source_file ${MOCO_SOURCES})
    if(source_file MATCHES ".*\\.h$")
        list(APPEND MOCO_HEADERS ${source_file})
    endif()
endforeach()

if(OPENSIM_WITH_CASADI)
    list(APPEND MOCO_SOURCES
            MocoCasADiSolver/CasOCProblem.h
            MocoCasADiSolver/CasOCProblem.cpp
            MocoCasADiSolver/CasOCSolver.h
            MocoCasADiSolver/CasOCSolver.cpp
            MocoCasADiSolver/CasOCFunction.h
            MocoCasADiSolver/CasOCFunction.cpp
            MocoCasADiSolver/CasOCTranscription.h
            MocoCasADiSolver/CasOCTranscription.cpp
            MocoCasADiSolver/CasOCTrapezoidal.h
            MocoCasADiSolver/CasOCTrapezoidal.cpp
            MocoCasADiSolver/CasOCHermiteSimpson.h
            MocoCasADiSolver/CasOCHermiteSimpson.cpp
            MocoCasADiSolver/CasOCLegendreGauss.h
            MocoCasADiSolver/CasOCLegendreGauss.cpp
            MocoCasADiSolver/CasOCLegendreGaussRadau.h
            MocoCasADiSolver/CasOCLegendreGaussRadau.cpp
            MocoCasADiSolver/CasOCIterate.h
            MocoCasADiSolver/MocoCasOCProblem.h
            MocoCasADiSolver/MocoCasOCProblem.cpp
    )
endif()

# Create the library target.
add_library(${OSIM_LIB_NAME} SHARED ${MOCO_SOURCES})

# Set the include directories for this library.
target_include_directories(${OSIM_LIB_NAME}
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include/OpenSim/Moco>
)

# Link against dependent libraries.
target_link_libraries(${OSIM_LIB_NAME} PUBLIC osimTools)
if(OPENSIM_WITH_CASADI)
    target_link_libraries(${OSIM_LIB_NAME} PRIVATE casadi::casadi)
endif()

# Set properties for Windows DLL export/import and IDE folders.
string(TOUPPER "Moco" KIT_UPPER)
set_target_properties(${OSIM_LIB_NAME} PROPERTIES
    DEFINE_SYMBOL OSIM${KIT_UPPER}_EXPORTS
    FOLDER "Libraries"
)

# Set compile definitions.
target_compile_definitions(${OSIM_LIB_NAME} PRIVATE SWIG_PYTHON)
if(OPENSIM_WITH_CASADI)
    target_compile_definitions(${OSIM_LIB_NAME} PUBLIC OPENSIM_WITH_CASADI)
endif()

# --- Installation Rules ---

# Install the library target files.
install(TARGETS ${OSIM_LIB_NAME}
    EXPORT OpenSimTargets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${OPENSIM_INSTALL_ARCHIVEDIR}
)

# Install the header files.
# We must install headers into subdirectories (e.g., Moco/Goal).
foreach(header_file ${MOCO_HEADERS})
    get_filename_component(header_path ${header_file} DIRECTORY)
    install(FILES ${header_file}
            DESTINATION "include/OpenSim/Moco/${header_path}")
endforeach()

# Add the testing subdirectory.
if(BUILD_TESTING)
    add_subdirectory(Test)
endif()
