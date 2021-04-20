global class ASI_FOC_CN_Invoke_SOA {
    public static void routineAfterUpdateSOA(list<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap) {        
        for (ASI_FOC_Free_Goods_Request__c req:trigger_new){
            system.debug('Req Name: ' + req.Name + ' New Status: ' + req.ASI_FOC_Request_Status__c + ' Old Status: ' + trigger_oldMap.get(req.Id).ASI_FOC_Request_Status__c + ' JDE SO#: ' + req.ASI_FOC_JDE_Order_Number__c);
            if (req.ASI_FOC_Request_Status__c == 'Approved by Logistic' && trigger_oldMap.get(req.Id).ASI_FOC_Request_Status__c == 'Submitted' && req.ASI_FOC_JDE_Order_Number__c == null){
                    ASI_SOA_Setting__c customSetting = ASI_SOA_Setting__c.getValues('ASI_FOC_CN_EnableSOAInterface');

                if (customSetting != null && customSetting.ASI_SOA_Enable__c == true)
                    ASI_FOC_CN_Invoke_SOA.invokeChinaFOCSOA(req.Id);
            }
        }
	}
    
    @future(callout=true)   
    public static void invokeChinaFOCSOA(Id reqId){
        try {
            ASI_FOC_CN_SOA_FOCIntegrationProcess.FOCIntegrationProcess_pt soaProcess = new ASI_FOC_CN_SOA_FOCIntegrationProcess.FOCIntegrationProcess_pt();

            String result = soaProcess.process(reqId);
            system.debug('Result');

            ASI_HK_CRM_WebService_Debug_Log__c log = new ASI_HK_CRM_WebService_Debug_Log__c();
            log.Name = 'CN FOC Interface - Normal';
            log.ASI_HK_CRM_Before_call_webservice__c = System.now();
            log.ASI_HK_CRM_After_call_web_service__c = System.now();
            log.ASI_HK_CRM_Submitter__c = UserInfo.getUserId();
            log.ASI_HK_CRM_WebService_Error_Message__c = result;
            log.ASI_HK_CRM_WebServiceName__c = 'CN FOC Interface By Oracle SOA ' + reqId;
            
            insert log;
        }
        catch(exception e) {
            ASI_HK_CRM_WebService_Debug_Log__c log = new ASI_HK_CRM_WebService_Debug_Log__c(Name = 'CN FOC Interface - Error', ASI_HK_CRM_Before_call_webservice__c = System.now(), ASI_HK_CRM_After_call_web_service__c = System.now(), ASI_HK_CRM_Submitter__c = UserInfo.getUserId(), ASI_HK_CRM_WebService_Error_Message__c = e.getMessage(), ASI_HK_CRM_WebServiceName__c = 'CN FOC Interface Error By Oracle SOA ' + reqId);
            insert log;         
        }
    }
}