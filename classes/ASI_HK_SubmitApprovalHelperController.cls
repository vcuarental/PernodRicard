/**********************************************************************************
 * Name : ASI_HK_SubmitApprovalHelperController
 
 * Revision History:
 * 1. 2018-04-30	Wilken Lee		[WL 1.0] Add Try Catch handling when update SO
 * 2. 2018-07-25	Kelvin CHan		[KC 2.0] Add checking if stock release is required
 **********************************************************************************/
public with sharing class ASI_HK_SubmitApprovalHelperController {
    public ASI_HK_SubmitApprovalHelperController(){
    }
    
    public PageReference submitHelper(){
        string id = apexpages.currentpage().getparameters().get('id');
        //System.debug('Test');
        // Modified 201512 Ray
        ASI_HK_CRM_Sales_Order__c soList = [SELECT Id, ASI_HK_CRM_Order_Status_Name__c ,ASI_CRM_HK_has_rejected__c
                                            FROM ASI_HK_CRM_Sales_Order__c
                                            WHERE Id =: id LIMIT 1];
        
        List<ASI_HK_CRM_Sales_Order_Item__c> solList = [SELECT Id FROM ASI_HK_CRM_Sales_Order_Item__c WHERE ASI_HK_CRM_Sales_Order__c = :Id AND ASI_HK_CRM_Stock_Reserve_Status__c = 'Open'];
                                            
        if(soList.ASI_CRM_HK_has_rejected__c==true){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot submit a rejected SO.'));
            return null;
        }
        
        if(soList.ASI_HK_CRM_Order_Status_Name__c !='Draft'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot submit a non-Draft SO.'));
            return null;
        }
        
        if(solList.size() == 0){
            soList.ASI_HK_CRM_Order_Status_Name__c = 'Interfaced to JDE';
            System.debug('ASI_HK_SubmitApprovalHelperController | Interfaced to JDE | SO Id : ' + solist.Id);
        } else{
            soList.ASI_HK_CRM_Order_Status_Name__c = 'Interfaced to Stock Reserve';
            System.debug('ASI_HK_SubmitApprovalHelperController | Interfaced to Stock Reserve | SO Id : ' + solist.Id);
        }
            
        //System.debug('Interfaced to JDE     '+soList.ASI_HK_CRM_Order_Status_Name__c );
		
		/*[WL 1.0] BEGIN*/
		try {
			update soList;  
		}
		catch (Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
			return null;
		}
		/*[WL 1.0] END*/
        
        PageReference pageRef = new PageReference('/'+id);
        return pageRef;
    }
}