global class ASI_CRM_HK_SOA_InvokeSOA {	
    public static void submitSO(Set<Id> soIdSet) {        
		ASI_SOA_Setting__c customSetting = ASI_SOA_Setting__c.getValues('ASI_CRM_HK_SO_Interface_URL');
		system.debug('HK CRM SOA Web Service exist: ' + customSetting != null);
		
		if (customSetting != null && customSetting.ASI_SOA_Enable__c == true){
			system.debug('HK CRM SOA Web Service is enabled.');
			
			for (Id soId:soIdSet){
				system.debug('Start Invoke SOA for SO: ' + soId);
                ASI_CRM_HK_SOA_InvokeSOA.invokeHKCRMSalesOrderSOA(soId);            
			}
		}                     
	}
    
    @future(callout=true)   
    public static void invokeHKCRMSalesOrderSOA(String reqId){
		try {
            ASI_CRM_HK_SOA_SOIntegration.HK_CRM_SOIntegration_pt soaProcess = new ASI_CRM_HK_SOA_SOIntegration.HK_CRM_SOIntegration_pt();

            String result = soaProcess.process(reqId);
            system.debug('Result');

            ASI_HK_CRM_WebService_Debug_Log__c log = new ASI_HK_CRM_WebService_Debug_Log__c();
            log.Name = 'HK CRM SO Interface - Normal';
            log.ASI_HK_CRM_Before_call_webservice__c = System.now();
            log.ASI_HK_CRM_After_call_web_service__c = System.now();
            log.ASI_HK_CRM_Submitter__c = UserInfo.getUserId();
            log.ASI_HK_CRM_WebService_Error_Message__c = result;
            log.ASI_HK_CRM_WebServiceName__c = 'HK CRM SO Interface By Oracle SOA ' + reqId;
            
            insert log;
        }
        catch(exception e) {
            ASI_HK_CRM_WebService_Debug_Log__c log = new ASI_HK_CRM_WebService_Debug_Log__c(Name = 'HK CRM SO Interface - Error', ASI_HK_CRM_Before_call_webservice__c = System.now(), ASI_HK_CRM_After_call_web_service__c = System.now(), ASI_HK_CRM_Submitter__c = UserInfo.getUserId(), ASI_HK_CRM_WebService_Error_Message__c = e.getMessage(), ASI_HK_CRM_WebServiceName__c = 'HK CRM SO Interface Error By Oracle SOA ' + reqId);            
			insert log;         
        }
    }
	
	public static void checkAR(Integer accountNumber,String accountId,String salesOrderId,String userNameAndDateStr) {        
		ASI_SOA_Setting__c customSetting = ASI_SOA_Setting__c.getValues('ASI_CRM_HK_AR_Check_URL');
		system.debug('HK CRM SOA Web Service exist: ' + customSetting != null);
		
		if (customSetting != null && customSetting.ASI_SOA_Enable__c == true){
				system.debug('HK CRM SOA Web Service is enabled.');		
				system.debug('Start Invoke SOA for AR Check: ' + salesOrderId + ' Account Num: ' + accountNumber);
				
                ASI_CRM_HK_SOA_InvokeSOA.invokeHKCRMARCheckSOA(accountNumber, accountId, salesOrderId, userNameAndDateStr);            			
		}                     
	}
	
	@future(callout=true)   
    public static void invokeHKCRMARCheckSOA(Integer accountNumber,String accountId,String salesOrderId,String userNameAndDateStr){
		try {
            ASI_CRM_HK_SOA_ARCheck.HK_CRM_ARCheck_pt soaProcess = new ASI_CRM_HK_SOA_ARCheck.HK_CRM_ARCheck_pt();

			system.debug('URL: ' + soaProcess.endpoint_x);
			
            String result = soaProcess.process(accountNumber, accountId, salesOrderId, userNameAndDateStr);
            system.debug('Result');

            ASI_HK_CRM_WebService_Debug_Log__c log = new ASI_HK_CRM_WebService_Debug_Log__c();
            log.Name = 'HK CRM AR Checking - Normal';
            log.ASI_HK_CRM_Before_call_webservice__c = System.now();
            log.ASI_HK_CRM_After_call_web_service__c = System.now();
            log.ASI_HK_CRM_Submitter__c = UserInfo.getUserId();
            log.ASI_HK_CRM_WebService_Error_Message__c = result;
            log.ASI_HK_CRM_WebServiceName__c = 'HK CRM AR Checking By Oracle SOA ' + accountNumber + ' ' +  accountId + ' ' + salesOrderId + ' ' + userNameAndDateStr;
            
            insert log;
        }
        catch(exception e) {
            ASI_HK_CRM_WebService_Debug_Log__c log = new ASI_HK_CRM_WebService_Debug_Log__c(Name = 'HK CRM SO Interface - Error', ASI_HK_CRM_Before_call_webservice__c = System.now(), ASI_HK_CRM_After_call_web_service__c = System.now(), ASI_HK_CRM_Submitter__c = UserInfo.getUserId(), ASI_HK_CRM_WebService_Error_Message__c = e.getMessage(), ASI_HK_CRM_WebServiceName__c = 'HK CRM AR Checking Error By Oracle SOA ' + accountNumber + ' ' +  accountId + ' ' + salesOrderId + ' ' + userNameAndDateStr);
            insert log;         
        }
    }
}