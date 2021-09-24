
import json

#---------------------------------------------------------[Class]--------------------------------------------------------

# ###################################################################################
# Class:  MyClass
class MyClass(object):
  """
  Class:  MyClass
  Description: This is a python class object for the MyClass
               This class will wrap JSON.
  Parameters: object: JSON object
  Example usage:
    from myclass import MyClass \n
    my_class = MyClass(MyJSON)  \n
  
  """
    
  def __init__(self, myjson):
    """
    Function: __init__
    Description: This is the MyClass iniitializaion \n
    Parameters: self: MyClass class 
                myjson: My JSON object
    Return: None
    """
    # print('myjson: Doing json.loads({0})'.format(myjson))
    self.__dict__ = json.loads(myjson)


# To use in Python code:
# Imports:
# import jsaon
# from classes.myclass import MyClass
#
  # Important Note: 
  # For a JSON File:
  # Must use json.dumps() around the genfunc.GetJsonFromFile() to keep double quotes
  # to be able to load it into the MyClass object class.
#  MyJSON = json.dumps(genfunc.GetJsonFromFile(MyLogger, jsonfileone))
#  
  # For A JSON Object:
#  MyJSON = json.dumps(MyJSONObject)
#  
  # Load My Class
#  MyLogger.info('Loading JSON into MyClass Object Class.')
#  my_class = myClass(MyJSON)
#  
  # Reference Values:
#  my_class.FieldOne
#  
  # For dict [List]:
#  for mylistfields in my_class.myfields:
#    MyLogger.info('My Class List Field 1: {0}'.format(mylistfields['field1']))
#    MyLogger.info('My Class List Field 2: {0}'.format(mylistfields['field2']))
#    MyLogger.info('My Class List Field 3: {0}'.format(mylistfields['field3']))
