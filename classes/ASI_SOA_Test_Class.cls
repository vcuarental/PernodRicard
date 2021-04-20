/*
 *********************************************************************************
 * Name: ASI_SOA_Test_Class
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-09-17       Wilken Lee              Created
 */
 @isTest
public class ASI_SOA_Test_Class {
    static testmethod void test_ASI_SOA_ExceptionAlert_Webservice(){
        
        ASI_HK_CRM_Web_Service_Setting__c setting = new ASI_HK_CRM_Web_Service_Setting__c();
        setting.ASI_HK_CRM_Key__c = 'ASI_SOA_JP_CRM_SO_Creation';
        setting.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Web_Service_Setting__cASI_SOA_Exception_Alert_Setting');
        insert setting;
        
        /*StaticResourceCalloutMock mock = new StaticResourceCalloutMock();  
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);*/
        Test.startTest();
        
        ASI_SOA_ExceptionAlert_Webservice.sendAlert('ASI_SOA_JP_CRM_SO_Creation','Error message');
        
        /*String email = UserInfo.getUserName();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ASI_SOA_ExceptionAlert_Webservice/';  
        req.httpMethod = 'POST';
        String request = '{"settingName":"ASI_SOA_JP_CRM_SO_Creation","errMsg":"Error message"}';
        req.requestBody = Blob.valueOf(request);
        RestContext.request = req;
        RestContext.response = res;     */   
        
        Test.stopTest();
    }
}