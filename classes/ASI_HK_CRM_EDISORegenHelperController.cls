/**********************************************************************************
* Name : ASI_HK_CRM_EDISORegenHelperController

* Revision History:
* 1. 2018-07-12	Kelvin Chan		[KC 1.0] Update Trigger Processed flag to fire the trigger code
* 1. 2018-10-30	Wilken Lee		[WL 2.0] Generate CRM SO when user click button
**********************************************************************************/
public with sharing class ASI_HK_CRM_EDISORegenHelperController {
    public ASI_HK_CRM_EDISORegenHelperController(){
    }
    
    public PageReference submitHelper(){
        String ediSOId = apexpages.currentpage().getparameters().get('id');
        String type = apexpages.currentpage().getparameters().get('type');
        
        if (type == 'retrieveSKUPrice'){
            retrieveSKUPriceHelper();
        }
        else {
            System.debug('ASI_HK_CRM_EDISORegenHelperController | submitHelper | ediSOId: ' + ediSOId);
            
            ASI_CRM_EDI_SO_Header__c edisoList = [SELECT Id, ASI_HK_Generated_SO__c, ASI_HK_Generated_SO__r.Name, ASI_CRM_ETL_Complete__c, ASI_CRM_Trigger_Processed__c, ASI_HK_CRM_EDI_Invoice__c
                                                	FROM ASI_CRM_EDI_SO_Header__c
                                                	WHERE Id =: ediSOId LIMIT 1];
            
            if(!edisoList.ASI_CRM_ETL_Complete__c || !edisoList.ASI_CRM_Trigger_Processed__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot regenerate SO of this EDI SO as ETL is not completed yet or it is yet to be processed by the trigger yet.'));
                return null;
            }
            
            if(edisoList.ASI_HK_Generated_SO__c != NULL){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There is already a CRM Sales Order ' + edisoList.ASI_HK_Generated_SO__r.Name + ' for this EDI order.'));
                return null;
            }
            
            if(edisoList.ASI_HK_CRM_EDI_Invoice__c != NULL){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot regenerate SO of this EDI SO as the EDI Invoice of this EDI SO has been generated already.'));
                return null;
            }
            
            edisoList.ASI_CRM_Trigger_Processed__c = FALSE;
    		edisoList.ASI_CRM_CRM_SO_Completed__c = TRUE; //[WL 2.0]
            
            try {
                update edisoList;  
            }
            catch (Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                return null;
            }
        }

        PageReference pageRef = new PageReference('/'+ediSOId);
        return pageRef;
    }

    public void retrieveSKUPriceHelper(){
        String ediSOId = apexpages.currentpage().getparameters().get('id');
        
        System.debug('ASI_HK_CRM_EDISORegenHelperController | retrieveSKUPriceHelper | ediSOId: ' + ediSOId);
        
        ASI_CRM_EDI_SO_Header__c edisoList = [SELECT Id, ASI_HK_Generated_SO__c, ASI_CRM_ETL_Complete__c, ASI_CRM_Trigger_Processed__c, ASI_HK_CRM_EDI_Invoice__c,
                                                ASI_CRM_Has_Error__c, ASI_CRM_SO_Generation_Error__c 
                                                FROM ASI_CRM_EDI_SO_Header__c
                                                WHERE Id =: ediSOId LIMIT 1];
        
        if(!edisoList.ASI_CRM_ETL_Complete__c){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot regenerate SO of this EDI SO as ETL is not completed yet'));
        }

        if(edisoList.ASI_HK_Generated_SO__c != NULL){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot regenerate SO of this EDI SO as the SO already exist.'));
        }
        
        if(edisoList.ASI_HK_CRM_EDI_Invoice__c != NULL){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot regenerate SO of this EDI SO as the EDI Invoice of this EDI SO has been generated already.'));
        }
        
        edisoList.ASI_CRM_Trigger_Processed__c = FALSE;
        edisoList.ASI_CRM_SO_Generation_Error__c = null;
        edisoList.ASI_CRM_Has_Error__c = false;
        
        try {
            update edisoList;  
        }
        catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }        
    }
}