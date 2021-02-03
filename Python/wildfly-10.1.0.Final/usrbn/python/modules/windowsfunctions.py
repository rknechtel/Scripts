
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
            'win32serviceutil',
            'wmi',
           ]

for module in _modules:
  try:
    locals()[module] = __import__(module, {}, {}, [])
  except ImportError:
    print("Error importing %s." % module)


# ---------------------------------------------------------[Initialisations]--------------------------------------------------------



# ---------------------------------------------------------[Functions]----------------------------------------------------

# ###################################################################################
# Function: svcStatus_local
# Description: Will get the status of a Windows Service on a local system
# Parameters: Service - Name of Windows Service
#             Machine - System Windows Service is on
#
def svcStatus_local(service,, machine_name):
  return win32serviceutil.QueryServiceStatus(svc_name, machine)[1]  # scvType, svcState, svcControls, err, svcErr, svcCP, svcWH

# ###################################################################################
# Function: svcStatus_remote
# Description: Will get the status of a Windows Service on a remote system
# Parameters: Service - Name of Windows Service
#             Machine - System Windows Service is on
#
def svcStatus_remote(service,, machine_name):
  return win32serviceutil.QueryServiceStatus(svc_name, machine=machine_name)[1]  # scvType, svcState, svcControls, err, svcErr, svcCP, svcWH


# ###################################################################################
# Function: windows_service_manager_local
# Description: Funcation for Managing Windows Services on a local system
# Parameters: Action - Action to take on Service
#             Machine_Name - Windows System to perform Windows Service Action on
#                            for local systems Machine_Name = None
#             Service - Windows Service to take action on
#
def windows_service_manager_local(action, machine_name=None, service):
  try:
    if action == 'stop':
        status = win32serviceutil.StopService(service, machine_name)
        while status == STOPPING:
          time.sleep(1)
          status = svcStatus(service, machine_name)
        return status
    elif action == 'start':
      svc_arg = None
      if not svc_arg is None:
        if type(svc_arg) in StringTypes:
          # win32service expects a list of string arguments
          svc_arg = [ svc_arg]
      win32serviceutil.StartService(service, svc_arg, Nomachine_name)
      status = svcStatus_local(service, machine_name)
      while status == STARTING:
        time.sleep(1)
        status = svcStatus_local(service, machine_name)
      return status
    # Removing support for Restart - use Stop/Start
    #elif action == 'restart':
    #    win32serviceutil.RestartService(service, machine_name)
    elif action == 'status':
      status = svcStatus_local(service, machine_name)
      return status

  except Exception as e:
    DeployLogger.error("windows_service_manager_local failed trying to " + action + " service " + service + " on system local")
    DeployLogger.error("Exception Information= ", sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])
    config.HasError = True
    raise Exception(e)

  return

# ###################################################################################
# Function: windows_service_manager_remote
# Description: Funcation for Managing Windows Services from a remote system
# Parameters: Action - Action to take on Service
#             Machine - Windows System to perform Windows Service Action on
#             Service - Windows Service to take action on
#
def windows_service_manager_remote(action, machine_name, service):
  # if you want to start service on a remote machine then use the following code :
  # win32serviceutil.StartService(service_name, machine=machine_name)
  try:
    if action == 'stop':
        status = win32serviceutil.StopService(service, , machine=machine_name)
        while status == STOPPING:
          time.sleep(1)
          status = svcStatus_remote(service, machine_name)
        return status
    elif action == 'start':
        win32serviceutil.StartService(service, , machine=machine_name)
      svc_arg = None
      if not svc_arg is None:
        if type(svc_arg) in StringTypes:
          # win32service expects a list of string arguments
          svc_arg = [ svc_arg]
      win32serviceutil.StartService(service, svc_arg, machine_name)
      status = svcStatus_remote(service, machine_name)
      while status == STARTING:
        time.sleep(1)
        status = svcStatus_remote(service, machine_name)
      return status
    # Removing support for Restart - use Stop/Start
    #elif action == 'restart':
    #    win32serviceutil.RestartService(service, , machine=machine_name)
    elif action == 'status':
        if win32serviceutil.QueryServiceStatus(service, , machine=machine_name)[1] == 4:
            print '%s is happy' % service
        else:
            print '%s is being a PITA' % service

  except Exception as e:
    DeployLogger.error("windows_service_manager_remote failed trying to " + action + " service " + service + " on system " + machine_name)
    DeployLogger.error("Exception Information= ", sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])
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
