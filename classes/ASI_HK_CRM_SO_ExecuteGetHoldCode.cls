public without sharing class ASI_HK_CRM_SO_ExecuteGetHoldCode {

    @TestVisible private static final String STATUS_WAIT_CREDIT_HOLD = 'Waiting for Hold Code';
    private static final String STATUS_FINISH = 'Checking Extra Items';

    public ASI_HK_CRM_SO_ExecuteGetHoldCode(ApexPages.StandardController stdController) {    
        
    } 
    
    public PageReference executeBatchHoldCode(){
        Integer countNextStepSO = [SELECT COUNT() FROM ASI_HK_CRM_Sales_Order__c WHERE ASI_HK_CRM_Order_Status_Name__c = :STATUS_FINISH AND ASI_HK_CRM_Is_Web_Service_Failed__c != TRUE];
        String soId = ApexPages.CurrentPage().getParameters().get('id');
        ASI_HK_CRM_WebServiceRepeatControl__c webControl = ASI_HK_CRM_WebServiceRepeatControl__c.getInstance('ASI_HK_CRM_WSRepeatControlDataSet');
        
        if (countNextStepSO > 0) {
            System.debug('mmg20');
            ASI_HK_CRM_SalesOrderExtraItemRequest.processImmediately();
        } 
        
        if(webControl.ASI_HK_CRM_isRepeatWebService__c){
            ASI_HK_CRM_SalesOrderHoldCodeSchedule.schedule();
        }
        else{
            Integer countWaitingSO = [SELECT COUNT() FROM ASI_HK_CRM_Sales_Order__c WHERE ASI_HK_CRM_Order_Status_Name__c = :STATUS_WAIT_CREDIT_HOLD AND ASI_HK_CRM_Is_Web_Service_Failed__c != TRUE];
            if (countWaitingSO > 0) ASI_HK_CRM_SalesOrderHoldCodeSchedule.schedule();
        }
        
        PageReference redirectPage = null;
        redirectPage = new PageReference('/' + soId); 
        return redirectPage;
    }
}