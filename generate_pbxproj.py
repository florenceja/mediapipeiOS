import os
import uuid

def gen_uuid():
    return uuid.uuid4().hex[:24].upper()

project_name = "MediaPipeLandmarks"
bundle_id = "com.example.MediaPipeLandmarks"

files = [
    "AppDelegate.swift",
    "SceneDelegate.swift",
    "Info.plist",
    "Controllers/MainViewController.swift",
    "Controllers/FaceDetectionViewController.swift",
    "Controllers/HandGestureViewController.swift",
    "Services/CameraManager.swift",
    "Services/FaceLandmarkerService.swift",
    "Services/GestureRecognizerService.swift",
    "Views/FaceOverlayView.swift",
    "Views/HandOverlayView.swift",
    "Utils/CoordinateTransformer.swift",
    "Models/face_landmarker.task",
    "Models/gesture_recognizer.task"
]

file_refs = {}
build_files = {}

for f in files:
    file_refs[f] = gen_uuid()
    if not f.endswith(".plist"):
        build_files[f] = gen_uuid()

main_group_id = gen_uuid()
app_group_id = gen_uuid()
products_group_id = gen_uuid()
app_ref_id = gen_uuid()

sources_build_phase_id = gen_uuid()
resources_build_phase_id = gen_uuid()
frameworks_build_phase_id = gen_uuid()

target_id = gen_uuid()
project_id = gen_uuid()

build_config_list_proj_id = gen_uuid()
build_config_list_target_id = gen_uuid()
build_config_debug_proj_id = gen_uuid()
build_config_release_proj_id = gen_uuid()
build_config_debug_target_id = gen_uuid()
build_config_release_target_id = gen_uuid()

pbxproj = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 54;
	objects = {{

/* Begin PBXBuildFile section */
"""

for f in files:
    if f in build_files:
        if f.endswith(".swift"):
            pbxproj += f"\t\t{build_files[f]} /* {os.path.basename(f)} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[f]} /* {os.path.basename(f)} */; }};\n"
        elif f.endswith(".task"):
            pbxproj += f"\t\t{build_files[f]} /* {os.path.basename(f)} in Resources */ = {{isa = PBXBuildFile; fileRef = {file_refs[f]} /* {os.path.basename(f)} */; }};\n"

pbxproj += """/* End PBXBuildFile section */

/* Begin PBXFileReference section */
"""

for f in files:
    ext = os.path.splitext(f)[1]
    file_type = "sourcecode.swift" if ext == ".swift" else "text.plist.xml" if ext == ".plist" else "file"
    pbxproj += f"\t\t{file_refs[f]} /* {os.path.basename(f)} */ = {{isa = PBXFileReference; lastKnownFileType = {file_type}; path = {os.path.basename(f)}; sourceTree = \"<group>\"; }};\n"

pbxproj += f"\t\t{app_ref_id} /* {project_name}.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = {project_name}.app; sourceTree = BUILT_PRODUCTS_DIR; }};\n"

pbxproj += """/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
"""
pbxproj += f"\t\t{frameworks_build_phase_id} /* Frameworks */ = {{\n\t\t\tisa = PBXFrameworksBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};\n"
pbxproj += """/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
"""

# Group structure
groups = {
    "Controllers": [],
    "Services": [],
    "Views": [],
    "Utils": [],
    "Models": []
}

for f in files:
    parts = f.split("/")
    if len(parts) > 1:
        groups[parts[0]].append(f)

group_ids = {}
for g in groups:
    group_ids[g] = gen_uuid()

pbxproj += f"\t\t{main_group_id} = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t{app_group_id} /* {project_name} */,\n\t\t\t\t{products_group_id} /* Products */,\n\t\t\t);\n\t\t\tsourceTree = \"<group>\";\n\t\t}};\n"

pbxproj += f"\t\t{products_group_id} /* Products */ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t{app_ref_id} /* {project_name}.app */,\n\t\t\t);\n\t\t\tname = Products;\n\t\t\tsourceTree = \"<group>\";\n\t\t}};\n"

app_children = []
for f in files:
    if "/" not in f:
        app_children.append(f"\t\t\t\t{file_refs[f]} /* {os.path.basename(f)} */,\n")

for g in groups:
    app_children.append(f"\t\t\t\t{group_ids[g]} /* {g} */,\n")

pbxproj += f"\t\t{app_group_id} /* {project_name} */ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n{''.join(app_children)}\t\t\t);\n\t\t\tpath = {project_name};\n\t\t\tsourceTree = \"<group>\";\n\t\t}};\n"

for g in groups:
    children = []
    for f in groups[g]:
        children.append(f"\t\t\t\t{file_refs[f]} /* {os.path.basename(f)} */,\n")
    pbxproj += f"\t\t{group_ids[g]} /* {g} */ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n{''.join(children)}\t\t\t);\n\t\t\tpath = {g};\n\t\t\tsourceTree = \"<group>\";\n\t\t}};\n"

pbxproj += """/* End PBXGroup section */

/* Begin PBXNativeTarget section */
"""
pbxproj += f"\t\t{target_id} /* {project_name} */ = {{\n\t\t\tisa = PBXNativeTarget;\n\t\t\tbuildConfigurationList = {build_config_list_target_id} /* Build configuration list for PBXNativeTarget \"{project_name}\" */;\n\t\t\tbuildPhases = (\n\t\t\t\t{sources_build_phase_id} /* Sources */,\n\t\t\t\t{frameworks_build_phase_id} /* Frameworks */,\n\t\t\t\t{resources_build_phase_id} /* Resources */,\n\t\t\t);\n\t\t\tbuildRules = (\n\t\t\t);\n\t\t\tdependencies = (\n\t\t\t);\n\t\t\tname = {project_name};\n\t\t\tproductName = {project_name};\n\t\t\tproductReference = {app_ref_id} /* {project_name}.app */;\n\t\t\tproductType = \"com.apple.product-type.application\";\n\t\t}};\n"
pbxproj += """/* End PBXNativeTarget section */

/* Begin PBXProject section */
"""
pbxproj += f"\t\t{project_id} /* Project object */ = {{\n\t\t\tisa = PBXProject;\n\t\t\tattributes = {{\n\t\t\t\tLastUpgradeCheck = 1400;\n\t\t\t\tTargetAttributes = {{\n\t\t\t\t\t{target_id} = {{\n\t\t\t\t\t\tCreatedOnToolsVersion = 14.0;\n\t\t\t\t\t}};\n\t\t\t\t}};\n\t\t\t}};\n\t\t\tbuildConfigurationList = {build_config_list_proj_id} /* Build configuration list for PBXProject \"{project_name}\" */;\n\t\t\tcompatibilityVersion = \"Xcode 13.0\";\n\t\t\tdevelopmentRegion = en;\n\t\t\thasScannedForEncodings = 0;\n\t\t\tknownRegions = (\n\t\t\t\ten,\n\t\t\t\tBase,\n\t\t\t);\n\t\t\tmainGroup = {main_group_id};\n\t\t\tproductRefGroup = {products_group_id} /* Products */;\n\t\t\tprojectDirPath = \"\";\n\t\t\tprojectRoot = \"\";\n\t\t\ttargets = (\n\t\t\t\t{target_id} /* {project_name} */,\n\t\t\t);\n\t\t}};\n"
pbxproj += """/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
"""
resources_files = []
for f in files:
    if f in build_files and f.endswith(".task"):
        resources_files.append(f"\t\t\t\t{build_files[f]} /* {os.path.basename(f)} in Resources */,\n")

pbxproj += f"\t\t{resources_build_phase_id} /* Resources */ = {{\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n{''.join(resources_files)}\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};\n"
pbxproj += """/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
"""
sources_files = []
for f in files:
    if f in build_files and f.endswith(".swift"):
        sources_files.append(f"\t\t\t\t{build_files[f]} /* {os.path.basename(f)} in Sources */,\n")

pbxproj += f"\t\t{sources_build_phase_id} /* Sources */ = {{\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n{''.join(sources_files)}\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};\n"
pbxproj += """/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
"""
pbxproj += f"\t\t{build_config_debug_proj_id} /* Debug */ = {{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {{\n\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;\n\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;\n\t\t\t\tCLANG_ENABLE_MODULES = YES;\n\t\t\t\tCOPY_PHASE_STRIP = NO;\n\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;\n\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;\n\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;\n\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;\n\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;\n\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;\n\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (\n\t\t\t\t\t\"DEBUG=1\",\n\t\t\t\t\t\"$(inherited)\",\n\t\t\t\t);\n\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;\n\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;\n\t\t\t\tMTL_FAST_MATH = YES;\n\t\t\t\tONLY_ACTIVE_ARCH = YES;\n\t\t\t\tSDKROOT = iphoneos;\n\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;\n\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = \"-Onone\";\n\t\t\t}};\n\t\t\tname = Debug;\n\t\t}};\n"

pbxproj += f"\t\t{build_config_release_proj_id} /* Release */ = {{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {{\n\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;\n\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;\n\t\t\t\tCLANG_ENABLE_MODULES = YES;\n\t\t\t\tCOPY_PHASE_STRIP = NO;\n\t\t\t\tDEBUG_INFORMATION_FORMAT = \"dwarf-with-dsym\";\n\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;\n\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;\n\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;\n\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;\n\t\t\t\tMTL_FAST_MATH = YES;\n\t\t\t\tSDKROOT = iphoneos;\n\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;\n\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = \"-O\";\n\t\t\t\tVALIDATE_PRODUCT = YES;\n\t\t\t}};\n\t\t\tname = Release;\n\t\t}};\n"

pbxproj += f"\t\t{build_config_debug_target_id} /* Debug */ = {{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {{\n\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;\n\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;\n\t\t\t\tCODE_SIGN_STYLE = Automatic;\n\t\t\t\tCURRENT_PROJECT_VERSION = 1;\n\t\t\t\tGENERATE_INFOPLIST_FILE = NO;\n\t\t\t\tINFOPLIST_FILE = {project_name}/Info.plist;\n\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (\n\t\t\t\t\t\"$(inherited)\",\n\t\t\t\t\t\"@executable_path/Frameworks\",\n\t\t\t\t);\n\t\t\t\tMARKETING_VERSION = 1.0;\n\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = {bundle_id};\n\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";\n\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;\n\t\t\t\tSWIFT_VERSION = 5.0;\n\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";\n\t\t\t}};\n\t\t\tname = Debug;\n\t\t}};\n"

pbxproj += f"\t\t{build_config_release_target_id} /* Release */ = {{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {{\n\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;\n\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;\n\t\t\t\tCODE_SIGN_STYLE = Automatic;\n\t\t\t\tCURRENT_PROJECT_VERSION = 1;\n\t\t\t\tGENERATE_INFOPLIST_FILE = NO;\n\t\t\t\tINFOPLIST_FILE = {project_name}/Info.plist;\n\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (\n\t\t\t\t\t\"$(inherited)\",\n\t\t\t\t\t\"@executable_path/Frameworks\",\n\t\t\t\t);\n\t\t\t\tMARKETING_VERSION = 1.0;\n\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = {bundle_id};\n\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";\n\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;\n\t\t\t\tSWIFT_VERSION = 5.0;\n\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";\n\t\t\t}};\n\t\t\tname = Release;\n\t\t}};\n"
pbxproj += """/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
"""
pbxproj += f"\t\t{build_config_list_proj_id} /* Build configuration list for PBXProject \"{project_name}\" */ = {{\n\t\t\tisa = XCConfigurationList;\n\t\t\tbuildConfigurations = (\n\t\t\t\t{build_config_debug_proj_id} /* Debug */,\n\t\t\t\t{build_config_release_proj_id} /* Release */,\n\t\t\t);\n\t\t\tdefaultConfigurationIsVisible = 0;\n\t\t\tdefaultConfigurationName = Release;\n\t\t}};\n"
pbxproj += f"\t\t{build_config_list_target_id} /* Build configuration list for PBXNativeTarget \"{project_name}\" */ = {{\n\t\t\tisa = XCConfigurationList;\n\t\t\tbuildConfigurations = (\n\t\t\t\t{build_config_debug_target_id} /* Debug */,\n\t\t\t\t{build_config_release_target_id} /* Release */,\n\t\t\t);\n\t\t\tdefaultConfigurationIsVisible = 0;\n\t\t\tdefaultConfigurationName = Release;\n\t\t}};\n"
pbxproj += """/* End XCConfigurationList section */
	};
	rootObject = """ + project_id + """ /* Project object */;
}
"""

with open("D:/study/mediapipe_iOS/MediaPipeLandmarks/MediaPipeLandmarks.xcodeproj/project.pbxproj", "w") as f:
    f.write(pbxproj)
