
# ###################################################################################
# Script/module: modules\windowsfunctions.py
# Author: Richard Knechtel
# Date: 02/24/2020
# Description: This is a module of generic functions
#
#
# LICENSE:
# This script is in the public domain, free from copyrights or restrictions.
#
# ###################################################################################
from _overlapped import NULL


# ---------------------------------------------------------[Imports]------------------------------------------------------

_modules = [
            'os',
            'sys',
            'time',
           ]

for module in _modules:
  try:
    locals()[module] = __import__(module, {}, {}, [])
  except ImportError:
    print("Error importing %s." % module)

from types import *
if os.name == 'nt':
  import win32service
  import win32serviceutil
  RUNNING = win32service.SERVICE_RUNNING
  STARTING = win32service.SERVICE_START_PENDING
  STOPPING = win32service.SERVICE_STOP_PENDING
  STOPPED = win32service.SERVICE_STOPPED
else:
  print("This Script is for Windows Only!")
  sys.exit(0)

# Custom Modules:
from modules import winsrvadminconfig as config

# ---------------------------------------------------------[Initialisations]--------------------------------------------------------



# ---------------------------------------------------------[Functions]----------------------------------------------------

# ###################################################################################
# Function: svcStatus_local
# Description: Will get the status of a Windows Service on a local system
# Parameters: Service - Name of Windows Service
#             Machine - System Windows Service is on
#
def svcStatus_local(service_name, machine_name):
  return win32serviceutil.QueryServiceStatus(service_name, machine_name)[1]  # scvType, svcState, svcControls, err, svcErr, svcCP, svcWH

# ###################################################################################
# Function: svcStatus_remote
# Description: Will get the status of a Windows Service on a remote system
# Parameters: Service - Name of Windows Service
#             Machine - System Windows Service is on
#
def svcStatus_remote(service_name, machine_name):
  return win32serviceutil.QueryServiceStatus(service_name, machine=machine_name)[1]  # scvType, svcState, svcControls, err, svcErr, svcCP, svcWH


# ###################################################################################
# Function: windows_service_manager_local
# Description: Funcation for Managing Windows Services on a local system
# Parameters: Action - Action to take on Service
#             Machine_Name - Windows System to perform Windows Service Action on
#                            for local systems Machine_Name = None
#             Service - Windows Service to take action on
#             SvcLogger - Logger Class
#
def windows_service_manager_local(action, machine_name, service_name, svclogger):
  try:
    svclogger.info("In windows_service_manager_local()")
    svclogger.info("Parameters = " + action + " " + machine_name + " " + service_name)
    svclogger.info("Action = " + action)

    if action == 'stop':
        svclogger.info("Initiating Stop Service for Service " + service_name)
        win32serviceutil.StopService(service_name)
        service_status = svcStatus_local(service_name, machine_name)

        svclogger.info("Checking if Service is Stopping.")
        if service_status == STOPPING:
          svclogger.info("Wiat until Service is Stopped.")
          while service_status == STOPPING:
            time.sleep(5)
            svclogger.info("Checking Status of Stopping")
            service_status = svcStatus_local(service_name, machine_name)
        return service_status

    elif action == 'start':
      svclogger.info("Initiating Start Service for Service " + service_name)
      win32serviceutil.StartService(service_name)
      service_status = svcStatus_local(service_name, machine_name)

      svclogger.info("Checking if Service is Starting.")
      if service_status == STARTING:
        svclogger.info("Wiat until Service is Started.")
        while service_status == STARTING:
          time.sleep(5)
          service_status = svcStatus_local(service_name, machine_name)
      return service_status

    # Removing support for Restart - use Stop/Start
    #elif action == 'restart':
    #    win32serviceutil.RestartService(service, machine_name)

    elif action == 'status':
      service_status = svcStatus_local(service_name, machine_name)
      return service_status

  except Exception as e:
    # sys.exc_info() returns a tuple with three values (type, value, traceback)
    e_type, e_value, e_traceback = sys.exc_info()
    svclogger.error("windows_service_manager_local failed trying to " + action + " service " + service_name + " on system local")
    svclogger.error("Error = " + str(e_value))
    svclogger.error("Exception Information:")
    svclogger.error("Exception Type = " + str(e_type))
    svclogger.error("Exception Value = " + str(e_value))
    svclogger.error("Exception Traceback = ", e_traceback)
    config.HasError = True
    raise Exception(e)

  return

# ###################################################################################
# Function: windows_service_manager_remote
# Description: Funcation for Managing Windows Services from a remote system
# Parameters: Action - Action to take on Service
#             Machine - Windows System to perform Windows Service Action on
#             Service - Windows Service to take action on
#             SvcLogger - Logger Class
#
def windows_service_manager_remote(action, machine_name, service_name, svclogger):
  # if you want to start service on a remote machine then use the following code :
  # win32serviceutil.StartService(service_name, machine=machine_name)
  try:
    svclogger.info("In windows_service_manager_remote()")
    svclogger.info("Parameters = " + action + " " + machine_name + " " + service_name)
    svclogger.info("Action = " + action)
    
    if action == 'stop':
        svclogger.info("Initiating Stop Service for Service " + service_name)
        service_status = win32serviceutil.StopService(service_name, machine=machine_name)

        svclogger.info("Checking if Service is Stopping.")
        if service_status == STOPPING:
          svclogger.info("Wiat until Service is Stopped.")
          while service_status == STOPPING:
            time.sleep(5)
            svclogger.info("Checking Status of Stopping")
            service_status = svcStatus_remote(service_name, machine_name)
        return service_status

    elif action == 'start':
      svclogger.info("Initiating Start Service for Service " + service_name)
      win32serviceutil.StartService(service_name, machine=machine_name)

      svclogger.info("Checking if Service is Starting.")
      if service_status == STARTING:
        svclogger.info("Wiat until Service is Started.")
        while service_status == STARTING:
          time.sleep(5)
          service_status = svcStatus_remote(service_name, machine_name)
      return service_status
    # Removing support for Restart - use Stop/Start
    #elif action == 'restart':
    #    win32serviceutil.RestartService(service, , machine=machine_name)
    elif action == 'status':
      service_status = svcStatus_remote(service_name, machine_name)
      return service_status

  except Exception as e:
    # sys.exc_info() returns a tuple with three values (type, value, traceback)
    e_type, e_value, e_traceback = sys.exc_info()
    svclogger.error("windows_service_manager_remote failed trying to " + action + " service " + service_name + " on system local")
    svclogger.error("Error = " + str(e_value))
    svclogger.error("Exception Information:")
    svclogger.error("Exception Type = " + str(e_type))
    svclogger.error("Exception Value = " + str(e_value))
    svclogger.error("Exception Traceback = ", e_traceback)
    config.HasError = True
    raise Exception(e)

  return


# This is a Function template:
# ###################################################################################
# Function:
# Description:
# Parameters:
#
def MyFuncation(Param1, Param2):

  return