"""

   Script: wsadminlibextras.py
   Description: This is a library of extra methods for use with wsadminlib.py
   Author: Richard Knechtel
   Date: 11/10/2014
   License: Public Domain
   
"""
def createMQCF ( serverName, cfName, jndiName, type, qmgrName, qmgrHostname, qmgrPortNumber, qmgrSvrconnChannel, wmqTransportType, description ):
    """ This method encapsulates the actions needed to create a MQ Connection Factory.

    Parameters:
        serverName - Name of the Server
        cfName - Name of JMS Activation Specification in String format.
        jndiName - JNDI Name of the JMS Activation Specification
        type - The Type of the Destination (Queue, Topic etc...)
        qmgrName - The Name of the Queue Manager
        qmgrHostname - The Hostname of the Queue Manager
        qmgrPortNumber - The Queue Managers Port Number
        qmgrSvrconnChannel - The Queue Manager Server Connection Channel
        wmqTransportType - Websphere MQ Transportation Type
        description - Description of the Activation Spec
    Returns:
        New MQ Connection Factory ID
    """
    m = "createMQCF: "
    #--------------------------------------------------------------
    # set up locals
    #--------------------------------------------------------------
    cellname = AdminControl.getCell()
    nodeName = AdminControl.getNode()
    serverId = AdminConfig.getid('/Cell:%s/Node:%s/Server:%s' % (cellName, nodeName, serverName))

    #---------------------------------------------------------
    # Create a MQConnectionFactory
    #---------------------------------------------------------
    params = ["-name "+cfName+" -jndiName '"+jndiName+"' -type "+type+" -qmgrName "+qmgrName+" -qmgrHostname "+qmgrHostname+" -qmgrPortNumber "+qmgrPortNumber+" -qmgrSvrconnChannel "+qmgrSvrconnChannel+" -wmqTransportType "+wmqTransportType+" -description '"+description+"'"]
    mqCFId = AdminTask.createWMQConnectionFactory(serverId, params)
	
    sop (m, "Returned from createMQCF()")
    return mqCFId
	
#endDef

def deleteMQCF(nodeName, raName, cfName):
    """ This method encapsulates the actions needed to remove a J2C connection factory.

    Parameters:
        nodeName - Name of the node in String format
        raName - Name of resource adapter to associate connection factory with in String format
        cfName - Name of the connection factory to be created in String format
    Returns:
        No return value
    """
    m = "deleteMQCF: "
    #--------------------------------------------------------------
    # set up locals
    #--------------------------------------------------------------
    cell = AdminControl.getCell()
    ra = AdminConfig.getid('/Cell:%s/Node:%s/J2CResourceAdapter:%s/' % (cell,nodeName,raName))

    #---------------------------------------------------------
    # Get the ID of MQConnectionFactory using the provided name
    #---------------------------------------------------------
    for cfItem in _splitlines(AdminConfig.list("MQConnectionFactory", ra)):
        if (cfName == AdminConfig.showAttribute(cfItem, "name")):
            AdminConfig.remove(cfItem)
            break
        #endIf
    #endFor
    sop (m, "Returned from deleteMQCF()")
#endDef

def customizeMQCF(nodeName, raName, cfName, propName, propValue):
    """ This method encapsulates the actions needed to modify a MQ connection factory.

    Parameters:
        nodeName - Name of the node in String format
        raName - Name of resource adapter to associate connection factory with in String format
        cfName - Name of the connection factory to be created in String format
        propName - Name of the connection factory property to be set in String format
        propValue - Value of the connection factory property to be set in String format
    Returns:
        No return value
    """
    m = "customizeMQCF: "
    #--------------------------------------------------------------
    # set up locals
    #--------------------------------------------------------------
    cell = AdminControl.getCell()
    ra = AdminConfig.getid('/Cell:%s/Node:%s/J2CResourceAdapter:%s/' % (cell,nodeName,raName))

    #---------------------------------------------------------
    # Get the ID of MQConnectionFactory using the provided name
    #---------------------------------------------------------
    for cfItem in _splitlines(AdminConfig.list("MQConnectionFactory", ra)):
        if (cfName == AdminConfig.showAttribute(cfItem, "name")):
            cf = cfItem
            break
        #endIf
    #endFor

    #---------------------------------------------------------
    # Customize the MQConnectionFactory
    #---------------------------------------------------------
    propset = AdminConfig.list("J2EEResourcePropertySet", cf )
    for psItem in _splitlines(AdminConfig.list("J2EEResourceProperty", propset)):
        if (propName == AdminConfig.showAttribute(psItem, "name")):
            AdminConfig.modify(psItem, [["value", propValue]])
            break
        #endIf
    #endFor
    sop (m, "Returned from customizeMQCF()")
#endDef


def createMQJMSTopic(nodeName, serverName, jmsTName, jmsTJNDI, jmsTDesc):
    """ This method encapsulates the actions needed to create a MQ JMS Topic.

    Parameters:
		nodeName - Name of the Node
		serverName - Name of the Server
        jmsTName - Name of topic in String format
        jmsTJNDI - JNDI Identifier of topic in String format
        jmsTDesc - Description of topic in String format
    Returns:
        New Topic ID
    """
    m = "createMQJMSTopic: "
    #--------------------------------------------------------------------
    # Create MQ JMS topic
    #--------------------------------------------------------------------
	
    #--------------------------------------------------------------
    # set up locals
    #--------------------------------------------------------------
    cell = AdminControl.getCell()
    serverId = AdminConfig.getid('/Cell:%s/Node:%s/Server:%s' % (cellName, nodeName,serverName))
	
    for topic in _splitlines(AdminTask.listWMQTopics(serverId)):
        if(AdminConfig.showAttribute(topic, "name") == jmsTName):
            # Topic already exists - removing it
            print "removing topic= "+topic
            remove(topic)
            print "removed topic"
            sop(m, "The %s MQ JMS topic already exists." % jmsTName)
        #endIf
    #endFor

    params = ["-name "+jmsTName+" -jndiName "+jmsTJNDI+" -topicName "+jmsTName+" -description "+jmsTDesc]
    newTopicId = AdminTask.createWMQTopic(serverId, params)
    sop (m, "Returned from createMQJMSTopic()")
    return newTopicId
	
#endDef

def deleteMQJMSTopic(nodeName, serverName, tName):
    """ This method encapsulates the actions needed to delete a MQ JMS Topic.

    Parameters:
        nodeName - Name of the Node
        serverName - Name of the Server
        raName - Name of resource adapter to associate connection factory with in String format	
        tName - Name of JMS Topic in String format.
    Returns:
        No return value
    """
    m = "deleteMQJMSTopic: "
    #--------------------------------------------------------------
    # set up locals
    #--------------------------------------------------------------
    cell = AdminControl.getCell()
    #ra = AdminConfig.getid('/Cell:%s/Node:%s/Server:%s/J2CResourceAdapter:%s/' % (cell,nodeName,serverName,raName))
    serverId = AdminConfig.getid('/Cell:%s/Node:%s/Server:%s' % (cellName, nodeName, serverName))
	
    #--------------------------------------------------------------------
    # Search for topic based on scope and delete
    #--------------------------------------------------------------------
    for topic in _splitlines(AdminTask.listWMQTopics(serverId)):
        name = AdminConfig.showAttribute(topic, "name")
        if (name == tName):
            AdminTask.deleteWMQTopic(topic)
            sop(m, "Deleted MQ JMS Topic %s" % tName)
            return
        #endIf
    #endFor
    sop (m, "Returned from deleteMQJMSTopic()")
#endDef

def createMQJMSQueue(nodeName, serverName, jmsQName, jmsQJNDI, baseQueueManagerName):
    """ This method encapsulates the actions needed to create a MQ JMS Queue for messages.

    Parameters:
        nodeName - Name of the Node
        serverName - Name of the Server
        jmsQName - Name to use for queue in String format.
        jmsQJNDI - JNDI Identifier to use for queue in String format.
        baseQueueManagerName - The Queue Manager Name.
    Returns:
        New MQ JMS Queue ID
    """
    m = "createMQJMSQueue: "
	
    #--------------------------------------------------------------
    # set up locals
    #--------------------------------------------------------------
    cellName = AdminControl.getCell()
    mqProvId = AdminConfig.getid('/Node:%s/Server:%s/JMSProvider:WebSphere MQ JMS Provider/' % (nodeName, serverName))
    mqqDest=AdminConfig.getid('/Cell:%s/Node:%s/Server:%s/JMSProvider:WebSphere MQ JMS Provider/MQQueue:%s/' % (cellName, nodeName, serverName, jmsQName))
    serverId = AdminConfig.getid('/Cell:%s/Node:%s/Server:%s' % (cellName, nodeName,serverName))
	
    #--------------------------------------------------------------------
    # Create MQ JMS Queue
    #--------------------------------------------------------------------
    print "Checking if MQ JMS Queue already exists."
    if len(mqqDest) == 0 :
        print "MQ JMS queue "+jmsQName+" does not exist."
    else :
        # MQ JMS queue already exists - remove it first	
        sop(m, "The %s MQ JMS queue already exists." % jmsQName)		
        print "MQ JMS queue "+jmsQName+" found - removing before create."
        remove(mqqDest) #AdminConfig.remove
        print "MQ JMS queue "+jmsQName+" removed."

    mqQueueId = AdminTask.createWMQQueue(serverId, ["-name "+jmsQName+" -jndiName '"+jmsQJNDI+"' -queueName "+jmsQName+" -qmgr "+baseQueueManagerName])

    sop (m, "Returned from createMQJMSQueue()")
    return mqQueueId
#endDef


def deleteMQJMSQueue(nodeName, serverName, raName, tName):
    """ This method encapsulates the actions needed to delete a MQ JMS Queue.

    Parameters:
        nodeName - Name of the Node
        serverName - Name of the Server
        raName - Name of resource adapter to associate connection factory with in String format	
        tName - Name of JMS queue in String format.
    Returns:
        No return value
    """
    m = "deleteMQJMSQueue: "
    #--------------------------------------------------------------
    # set up locals
    #--------------------------------------------------------------
    cell = AdminControl.getCell()
    ra = AdminConfig.getid('/Cell:%s/Node:%s/Server:%s/J2CResourceAdapter:%s/' % (cell,nodeName,serverName,raName))
	
    #--------------------------------------------------------------------
    # Search for MQJMSQueue based on scope and delete
    #--------------------------------------------------------------------
    for queue in _splitlines(AdminTask.listWMQQueues(ra)):
        name = AdminConfig.showAttribute(queue, "name")
        if (name == tName):
            AdminTask.deleteWMQQueue(queue)
            sop(m, "Deleted MQ JMS Queue %s" % tName)
            return
        #endIf
    #endFor
    sop (m, "Returned from deleteMQJMSQueue()")
#endDef


def createMQJMSActivationSpecification ( serverName, asName, jndiName, destinationJndiName, destinationType, qmgrName, qmgrHostname, qmgrPortNumber, qmgrSvrconnChannel, msgRetention, wmqTransportType, description, advancedProperties ):
    """ 
    This method encapsulates the actions needed to create a MQ JMS Activation Specification.

    Parameters:
        serverName - Name of the Server
        asName - Name of JMS Activation Specification in String format.
        jndiName - JNDI Name of the JMS Activation Specification
        destinationJndiName - The JNDI Name of the Destination
        destinationType - The Type of the Destination (Queue, Topic etc...)
        qmgrName - The Name of the Queue Manager
        qmgrHostname - The Hostname of the Queue Manager
        qmgrPortNumber - The Queue Managers Port Number
        qmgrSvrconnChannel - The Queue Manager Server Connection Channel
        msgRetention - Message Retention (YES or NO)
        wmqTransportType - Websphere MQ Transportation Type
        description - Description of the Activation Spec
        advancedProperties - Any Advanced Property settings needed (or set to defaults)

    Returns:
        New MQ JMS Activation Specification ID
    """
    m = "createMQJMSActivationSpecification: "
    #--------------------------------------------------------------
    # set up locals
    #--------------------------------------------------------------
    cellname = AdminControl.getCell()
    nodeName = AdminControl.getNode()

    #See if the Activation Specification already exists - if so remove it before adding it
    serverId = AdminConfig.getid('/Cell:%s/Node:%s/Server:%s' % (cellName, nodeName,serverName))

    print "Checking if Activation Specification already exists."
    for asId in AdminConfig.list('J2CActivationSpec', serverId).splitlines():
        if(AdminConfig.showAttribute(asId, 'name') == asName):
            # Activation Specification already exists - remove it first
            print "Activation Specification "+asName+" found - removing before create."
            remove(asId)
            print "Activation Specification "+asName+" removed."
            break

    if (len(advancedProperties) == 0):
        # No Advanced Properties sent in - use defaults
        advancedProperties = "-ccsid 819 -rescanInterval 5000 -msgRetention YES -maxPoolSize 10 -startTimeout 10000 -poolTimeout 300000 -stopEndpointIfDeliveryFails true -failureDeliveryCount 0 -compressHeaders NONE -compressPayload NONE -failIfQuiescing true"
    
    params = ["-name "+asName+" -jndiName '"+jndiName+"' -destinationJndiName '"+destinationJndiName+"' -destinationType "+destinationType+" -description '"+description+"' -qmgrName "+qmgrName+" -qmgrHostname "+qmgrHostname+" -qmgrPortNumber "+qmgrPortNumber+" -qmgrSvrconnChannel "+qmgrSvrconnChannel+" -msgRetention "+msgRetention+" -wmqTransportType "+wmqTransportType+" "+advancedProperties]
    newAsId = AdminTask.createWMQActivationSpec(serverId, params)

    sop (m, "Returned from createMQJMSActivationSpecification()")
    return newAsId
#endDef

def createDataSourceWithPropertySet ( serverName, jdbcProvider, datasourceName, authAliasName, mappingConfigAlias, authMechanismPreference, datasourceHelperClassname, datasourceDescription, datasourceJNDIName, providerType,  logMissingTransactionContext, diagnoseConnectionUsage, propertySet, statementCacheSize, cmpDatasource ):
    """
	Creates a DataSource under the given JDBCProvider; removes existing objects with the same jndiName
		
	Parameters:
        serverName - Name of the Server
        jdbcProvider - JDBC Provider
		datasourceName - Name of the Data Source
		authAliasName - The login ID to use
		mappingConfigAlias - Used for setting up Auth Alias mapping.
        authMechanismPreference - The Auth Mechanism Preference
		datasourceHelperClassname - The Datasource Helper Classname
		datasourceDescription - the Datasource Description
		datasourceJNDIName - The Datasource JNDI Name
        providerType - The JDBC Provider Type
        logMissingTransactionContext -
        diagnoseConnectionUsage - 
		propertySet - A J2EEResourcePropertySet
		statementCacheSize - The Cache Size for Statements
        cmpDatasource - (true/false) - datasource will support Container Managed Persistence (CMP)
    Returns:
        No return value
	"""
    m = "createDataSourceWithPropertySet: "
	
    #--------------------------------------------------------------
    # set up locals
    #--------------------------------------------------------------
    #cellname = AdminControl.getCell()
    nodeName = AdminControl.getNode()
	
    mapping = []
    mapping.append( [ 'authDataAlias', authAliasName ] )
    mapping.append( [ 'mappingConfigAlias', mappingConfigAlias ] )

    datasourceId = AdminConfig.getid('/DataSource:'+datasourceName)
    if (datasourceId != ''):
        remove(datasourceId)

    if (datasourceHelperClassname != '' and logMissingTransactionContext != '' and diagnoseConnectionUsage != ''):
        datasourceId = AdminJDBC.createDataSource(nodeName, serverName, jdbcProvider, datasourceName, [['authDataAlias', authAliasName], ['authMechanismPreference', authMechanismPreference], ['datasourceHelperClassname', datasourceHelperClassname], ['description', datasourceDescription], ['diagnoseConnectionUsage', 'true'], ['jndiName', datasourceJNDIName], ['logMissingTransactionContext', 'false'], ['xaRecoveryAuthAlias', authAliasName], ['manageCachedHandles', 'false'], ['mapping', mapping], ['providerType', providerType], ['logMissingTransactionContext', logMissingTransactionContext], ['diagnoseConnectionUsage', diagnoseConnectionUsage], ['statementCacheSize', statementCacheSize], propertySet])
    else:
        datasourceId = AdminJDBC.createDataSource(nodeName, serverName, jdbcProvider, datasourceName, [['authDataAlias', authAliasName], ['authMechanismPreference', authMechanismPreference], ['datasourceHelperClassname', datasourceHelperClassname], ['description', datasourceDescription], ['diagnoseConnectionUsage', 'true'], ['jndiName', datasourceJNDIName], ['logMissingTransactionContext', 'false'], ['xaRecoveryAuthAlias', authAliasName], ['manageCachedHandles', 'false'], ['mapping', mapping], ['providerType', providerType], ['statementCacheSize', statementCacheSize], propertySet])

    # Create CMP Connection Factory if this datasource will support Container Managed Persistence
    sop (m, "checking if cmpDatasource == 'true'")
    if (cmpDatasource == 'true'):
        sop(m, "calling createCMPConnectorFactory")
        scope = "server"
        clusterName = ""
        cmpcfId = createCMPConnectorFactory ( scope, clusterName, nodeName, serverName, datasourceName, authAliasName, datasourceId )        
        sop(m, "returned from calling createCMPConnectorFactory")
		
    sop (m, "Returned from createDataSourceWithPropertySet()")
    return datasourceId
#endDef

def createObjectCacheWithRemove(scopeobjectid, name, jndiname, serverName):
    """
    Description:
	    Create a dynacache object cache instance - remove it if it already exists.

	Parameters:
        scopeobjectid - The scope object ID should be the object ID of the config object at the desired scope of the new cache instance.
        name - Name of the Object Cache
        jndiName = JNDI Name of the Object Cache

    Info:
        The scope object ID should be the object ID of the config object at the desired scope of the new cache instance.  
        For example, for cell scope, pass the Cell object; for node scope, the Node object; for cluster scope, the Cluster object, etc. etc.

        Name & jndiname seem to be arbitrary strings.  Name must be unique, or at least not the same as another object cache in the
        same scope, not sure which.

    Returns the new object cache instance's config id.
    """
    m = "createObjectCacheWithRemove: "

    cellName = AdminControl.getCell()
    nodeName = AdminControl.getNode()	
	
	# Get Cache Provider ID
    cacheprovider = _getCacheProviderAtScope(scopeobjectid)
    if None == cacheprovider:
        raise Exception("COULD NOT FIND CacheProvider at the same scope as %s" % scopeobjectid)
		
	# Get Cache Provider Name
    end_index = cacheprovider.find("(") + len("(")
    cacheprovidername = cacheprovider[0:(end_index - 1)].strip()
	
	# Check if Object Cache Instance already exists - if so remove it to re-create it
    objectCacheInstanceId = AdminConfig.getid('/Cell:%s/Node:%s/Server:%s/CacheProvider:%s/ObjectCacheInstance:%s' % (cellName, nodeName, serverName, cacheprovidername, name))
    if (objectCacheInstanceId != ''):
        remove(objectCacheInstanceId)	

    ocID = AdminTask.createObjectCacheInstance(cacheprovider, ["-name", name,"-jndiName", jndiname])
    sop (m, "Returned from createObjectCacheWithRemove()")
    return ocID
#endDef
	
def createJdbcProviderExtraAttr ( parent, name, classpath, nativepath, implementationClassName, description, isolatedClassLoader, xa, providerType=None ):
    """Creates a JDBCProvider in the specified parent scope; removes existing objects with the same name"""
    attrs = []
    attrs.append( [ 'name', name ] )
    attrs.append( [ 'classpath', classpath ] )
    attrs.append( [ 'nativepath', nativepath ] )
    attrs.append( [ 'implementationClassName', implementationClassName ] )
    attrs.append( [ 'description', description ] )
    attrs.append( [ 'isolatedClassLoader', isolatedClassLoader ] )
    attrs.append( [ 'xa', xa ] )
    if providerType:
        attrs.append( [ 'providerType', providerType ] )
    return removeAndCreate('JDBCProvider', parent, attrs, ['name'])

#endDef

def setServerDefaultSDK ( nodeName, serverName, jdkName ):
    """
    Sets the default Java SDk on the Server
	
    Parameters:
        nodeName - Name of the Node
        serverName - Name of the Server
        jdkName - Name of the Java JDK to set as default
                  jdkName are like: "1.6_64" OR "1.7_64" OR "1.7.1_64"
    Returns:
        No return value
    """
    #sdks = AdminTask.getAvailableSDKsOnNode('[-nodeName '+nodeName+']')
    AdminTask.setServerSDK('[-nodeName '+nodeName+' -serverName '+serverName+' -sdkName '+jdkName+']')
	
#endDef

def setJvmCustomProperty( jvmId, customProperty ):
    """
    Sets a Custom Property on the Java SDk on the Server
	
    Parameters:
        jvmId - Internal ID of the JVM
        customProperty - Fully Qualified Custom Property to set
    Returns:
        New Custom Property ID
    """
    newCustPropId = AdminConfig.create('Property', jvmId, customProperty)
    return newCustPropId
#endDef

def whatFilesChanged():
    """
     Reports the configuration files that will be changed as a result of any Websphere changes
     The changes will take effect when you call saveAndSync() or AdminConfig.save()
	"""
    print "The following congfiguration files have changes pending:"
    print AdminConfig.queryChanges()
    return
#endDef