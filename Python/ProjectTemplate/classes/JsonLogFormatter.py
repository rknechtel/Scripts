class JsonLogFormatter:

  """
  Class:  JsonLogFormatter
  Description: This is a python class for creating JSON Logs
  Ref: https://www.proud2becloud.com/python-logging-best-practices-and-how-to-integrate-with-kibana-dashboard-through-aws-kinesis-data-firehose-and-amazon-elasticsearch-service/
  
  Example usage:
    from JsonLogFormatter import JsonLogFormatter \n
    jsonlogformatter = JsonLogFormatter()  \n
  
    handler = logging.StreamHandler()
    handler.formatter = JsonFormatter()
  
  """
 
   def format(self, record):
    """
    Function: format
    Description: This will do the JSON log formatting \n
    Parameters: self: JsonLogFormatter class
    Return: JSON Lolg entry
    """
       formatted_record = dict()

       for key in ['created', 'levelname', 'pathname', 'msg']:
           formatted_record[key] = getattr(record, key)

       return json.dumps(formatted_record, indent=4)