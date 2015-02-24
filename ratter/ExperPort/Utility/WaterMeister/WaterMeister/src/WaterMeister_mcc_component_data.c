/*
 * MATLAB Compiler: 4.10 (R2009a)
 * Date: Tue Feb 15 13:30:52 2011
 * Arguments: "-B" "macro_default" "-o" "WaterMeister" "-W" "main" "-d"
 * "C:\ratter\ExperPort\Utility\WaterMeister\WaterMeister\src" "-T" "link:exe"
 * "-v" "C:\ratter\ExperPort\Utility\WaterMeister\WaterMeister.m" "-a"
 * "C:\ratter\ExperPort\Utility\WaterMeister\WM_ratsheet.m" "-a"
 * "C:\ratter\ExperPort\Utility\WaterMeister\calcfontsize.m" "-a"
 * "C:\ratter\ExperPort\Utility\WaterMeister\init_check.m" "-a"
 * "C:\ratter\ExperPort\Utility\WaterMeister\session_button.m" "-a"
 * "C:\ratter\ExperPort\Utility\WaterMeister\timeremstr.m" "-a"
 * "C:\ratter\ExperPort\Utility\WaterMeister\WaterMeister.fig" "-a"
 * "C:\ratter\ExperPort\Utility\WaterMeister\WM_rat_water_list.m" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\bdata.p" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\LIBMYSQL.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\mym.mexw32" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\zlibwapi.dll" "-a"
 * "C:\ratter\ExperPort\MySQLUtility\win64\mym.mexw64" "-a"
 * "C:\ratter\ExperPort\Utility\WaterMeister\print_WM_figure.m" 
 */

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_WaterMeister_session_key[] = {
    '9', 'C', '0', 'D', 'A', '0', '9', '9', 'A', '6', 'D', '4', '0', 'C', 'C',
    'E', '3', '7', '4', '0', '5', '0', 'C', 'A', '5', '1', '8', 'A', 'E', '7',
    '6', '4', 'C', 'E', '9', 'C', '0', '9', '2', 'E', '0', '3', 'D', '3', '5',
    '8', 'B', '7', 'D', 'E', '5', 'C', '4', '2', '0', '0', '0', 'A', '7', '2',
    'D', '7', '3', 'F', '2', 'D', '3', '3', '3', '3', 'E', '5', '3', '8', 'B',
    '2', 'E', 'C', '7', 'F', '3', 'F', '1', 'E', 'C', '1', '7', '8', '1', 'E',
    '0', '0', '3', '3', '5', '1', '0', 'C', 'D', 'B', '8', '0', '8', '1', '4',
    '6', 'F', '5', '1', '5', '1', 'F', 'F', '3', 'C', 'C', '5', '1', 'B', '0',
    '7', '0', 'C', '0', '5', '6', 'D', 'B', '7', '1', '5', 'F', 'E', 'A', 'F',
    'D', 'A', '9', '2', '2', '4', 'D', 'F', '5', 'B', '1', 'E', '9', '7', 'B',
    '3', 'E', '0', '3', '7', '3', 'B', 'D', '1', 'B', 'E', 'C', 'D', '7', '6',
    '5', 'E', '2', '0', '3', 'B', 'E', 'E', 'E', 'A', '8', 'C', '7', '9', 'B',
    'A', '8', '4', 'B', '2', 'A', '8', '7', '1', '0', '3', '2', 'A', 'B', '7',
    '2', '0', '3', 'D', 'B', 'A', '7', 'E', 'C', '8', '0', '8', '8', 'B', '3',
    '1', '8', '1', 'E', '4', 'D', '9', '6', 'E', 'F', 'D', '3', 'D', '5', 'E',
    '4', '5', 'C', 'E', 'C', '1', '5', 'A', 'D', '0', '1', '1', 'E', 'B', '6',
    'B', '1', '9', '6', 'D', '4', 'C', '9', 'C', '8', 'C', '2', 'E', 'E', 'D',
    'B', '\0'};

const unsigned char __MCC_WaterMeister_public_key[] = {
    '3', '0', '8', '1', '9', 'D', '3', '0', '0', 'D', '0', '6', '0', '9', '2',
    'A', '8', '6', '4', '8', '8', '6', 'F', '7', '0', 'D', '0', '1', '0', '1',
    '0', '1', '0', '5', '0', '0', '0', '3', '8', '1', '8', 'B', '0', '0', '3',
    '0', '8', '1', '8', '7', '0', '2', '8', '1', '8', '1', '0', '0', 'C', '4',
    '9', 'C', 'A', 'C', '3', '4', 'E', 'D', '1', '3', 'A', '5', '2', '0', '6',
    '5', '8', 'F', '6', 'F', '8', 'E', '0', '1', '3', '8', 'C', '4', '3', '1',
    '5', 'B', '4', '3', '1', '5', '2', '7', '7', 'E', 'D', '3', 'F', '7', 'D',
    'A', 'E', '5', '3', '0', '9', '9', 'D', 'B', '0', '8', 'E', 'E', '5', '8',
    '9', 'F', '8', '0', '4', 'D', '4', 'B', '9', '8', '1', '3', '2', '6', 'A',
    '5', '2', 'C', 'C', 'E', '4', '3', '8', '2', 'E', '9', 'F', '2', 'B', '4',
    'D', '0', '8', '5', 'E', 'B', '9', '5', '0', 'C', '7', 'A', 'B', '1', '2',
    'E', 'D', 'E', '2', 'D', '4', '1', '2', '9', '7', '8', '2', '0', 'E', '6',
    '3', '7', '7', 'A', '5', 'F', 'E', 'B', '5', '6', '8', '9', 'D', '4', 'E',
    '6', '0', '3', '2', 'F', '6', '0', 'C', '4', '3', '0', '7', '4', 'A', '0',
    '4', 'C', '2', '6', 'A', 'B', '7', '2', 'F', '5', '4', 'B', '5', '1', 'B',
    'B', '4', '6', '0', '5', '7', '8', '7', '8', '5', 'B', '1', '9', '9', '0',
    '1', '4', '3', '1', '4', 'A', '6', '5', 'F', '0', '9', '0', 'B', '6', '1',
    'F', 'C', '2', '0', '1', '6', '9', '4', '5', '3', 'B', '5', '8', 'F', 'C',
    '8', 'B', 'A', '4', '3', 'E', '6', '7', '7', '6', 'E', 'B', '7', 'E', 'C',
    'D', '3', '1', '7', '8', 'B', '5', '6', 'A', 'B', '0', 'F', 'A', '0', '6',
    'D', 'D', '6', '4', '9', '6', '7', 'C', 'B', '1', '4', '9', 'E', '5', '0',
    '2', '0', '1', '1', '1', '\0'};

static const char * MCC_WaterMeister_matlabpath_data[] = 
  { "WaterMeister/", "$TOOLBOXDEPLOYDIR/", "ratter/ExperPort/MySQLUtility/",
    "ratter/ExperPort/MySQLUtility/win64/", "ratter/ExperPort/",
    "ratter/ExperPort/Analysis/", "ratter/ExperPort/FakeRP/",
    "ratter/ExperPort/HandleParam/", "ratter/ExperPort/Utility/",
    "ratter/ExperPort/Utility/WeighAllRats/",
    "ratter/ExperPort/Utility/provisional/", "ratter/Rigscripts/",
    "$TOOLBOXMATLABDIR/general/", "$TOOLBOXMATLABDIR/ops/",
    "$TOOLBOXMATLABDIR/lang/", "$TOOLBOXMATLABDIR/elmat/",
    "$TOOLBOXMATLABDIR/randfun/", "$TOOLBOXMATLABDIR/elfun/",
    "$TOOLBOXMATLABDIR/specfun/", "$TOOLBOXMATLABDIR/matfun/",
    "$TOOLBOXMATLABDIR/datafun/", "$TOOLBOXMATLABDIR/polyfun/",
    "$TOOLBOXMATLABDIR/funfun/", "$TOOLBOXMATLABDIR/sparfun/",
    "$TOOLBOXMATLABDIR/scribe/", "$TOOLBOXMATLABDIR/graph2d/",
    "$TOOLBOXMATLABDIR/graph3d/", "$TOOLBOXMATLABDIR/specgraph/",
    "$TOOLBOXMATLABDIR/graphics/", "$TOOLBOXMATLABDIR/uitools/",
    "$TOOLBOXMATLABDIR/strfun/", "$TOOLBOXMATLABDIR/imagesci/",
    "$TOOLBOXMATLABDIR/iofun/", "$TOOLBOXMATLABDIR/audiovideo/",
    "$TOOLBOXMATLABDIR/timefun/", "$TOOLBOXMATLABDIR/datatypes/",
    "$TOOLBOXMATLABDIR/verctrl/", "$TOOLBOXMATLABDIR/codetools/",
    "$TOOLBOXMATLABDIR/helptools/", "$TOOLBOXMATLABDIR/winfun/",
    "$TOOLBOXMATLABDIR/winfun/net/", "$TOOLBOXMATLABDIR/demos/",
    "$TOOLBOXMATLABDIR/timeseries/", "$TOOLBOXMATLABDIR/hds/",
    "$TOOLBOXMATLABDIR/guide/", "$TOOLBOXMATLABDIR/plottools/",
    "toolbox/local/", "toolbox/shared/controllib/",
    "toolbox/shared/dastudio/", "$TOOLBOXMATLABDIR/datamanager/",
    "toolbox/compiler/", "toolbox/control/control/",
    "toolbox/control/ctrlguis/", "toolbox/control/ctrlobsolete/",
    "toolbox/control/ctrlutil/", "toolbox/shared/slcontrollib/",
    "toolbox/ident/ident/", "toolbox/ident/nlident/",
    "toolbox/ident/idobsolete/", "toolbox/ident/idutils/",
    "toolbox/shared/spcuilib/", "toolbox/instrument/instrument/",
    "toolbox/signal/signal/", "toolbox/signal/sigtools/" };

static const char * MCC_WaterMeister_classpath_data[] = 
  { "java/jar/toolbox/control.jar", "java/jar/toolbox/instrument.jar",
    "java/jar/toolbox/testmeas.jar" };

static const char * MCC_WaterMeister_libpath_data[] = 
  { "bin/win32/" };

static const char * MCC_WaterMeister_app_opts_data[] = 
  { "" };

static const char * MCC_WaterMeister_run_opts_data[] = 
  { "" };

static const char * MCC_WaterMeister_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_WaterMeister_component_data = { 

  /* Public key data */
  __MCC_WaterMeister_public_key,

  /* Component name */
  "WaterMeister",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_WaterMeister_session_key,

  /* Component's MATLAB Path */
  MCC_WaterMeister_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  64,

  /* Component's Java class path */
  MCC_WaterMeister_classpath_data,
  /* Number of directories in the Java class path */
  3,

  /* Component's load library path (for extra shared libraries) */
  MCC_WaterMeister_libpath_data,
  /* Number of directories in the load library path */
  1,

  /* MCR instance-specific runtime options */
  MCC_WaterMeister_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_WaterMeister_run_opts_data,
  /* Number of MCR global runtime options */
  0,
  
  /* Component preferences directory */
  "WaterMeister_C807F988AF8C7A7389D882433A30E23B",

  /* MCR warning status data */
  MCC_WaterMeister_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif


