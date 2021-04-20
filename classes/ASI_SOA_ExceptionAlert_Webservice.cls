/*
 *********************************************************************************
 * Name: ASI_SOA_ExceptionAlert_Webservice
 * Description: 
 * Related Test Class: ASI_SOA_Test_Class
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-09-05       Wilken Lee              Created
 */
@RestResource(urlMapping='/ASI_SOA_ExceptionAlert_Webservice/*')
global class ASI_SOA_ExceptionAlert_Webservice {

    global ASI_SOA_ExceptionAlert_Webservice(){
        
    }
    
    @HttpPost
    webservice static String sendAlert (String settingName, String errMsg){
        System.debug('Start sendAlert');
        
        List<ASI_HK_CRM_Web_Service_Setting__c> setting = [	SELECT ASI_HK_CRM_Key__c, ASI_SOA_User_1__c, ASI_SOA_User_2__c, ASI_SOA_User_3__c, ASI_SOA_User_4__c, ASI_SOA_Subject__c
															FROM ASI_HK_CRM_Web_Service_Setting__c 
															WHERE ASI_HK_CRM_Key__c = :settingName AND recordTypeId = :Global_RecordTypeCache.getRtId('ASI_HK_CRM_Web_Service_Setting__cASI_SOA_Exception_Alert_Setting')];
        
        if (setting.size() == 1){
            ASI_HK_CRM_WebService_Debug_Log__c log = new ASI_HK_CRM_WebService_Debug_Log__c();
            
            log.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_WebService_Debug_Log__cASI_SOA_Exception_Alert');
            log.ASI_HK_CRM_WebService_Error_Message__c = errMsg;
            log.ASI_SOA_User_1__c = setting.get(0).ASI_SOA_User_1__c;
			log.ASI_SOA_User_2__c = setting.get(0).ASI_SOA_User_2__c;
			log.ASI_SOA_User_3__c = setting.get(0).ASI_SOA_User_3__c;
			log.ASI_SOA_User_4__c = setting.get(0).ASI_SOA_User_3__c;
			log.ASI_SOA_Subject__c = setting.get(0).ASI_SOA_Subject__c;
            
            insert log;
            
            return 'Success';
        }
        else {
            return 'Salesforce Web Service Setting not found for ' + settingName;
        }
    }
}