/*********************************************************************************
 * Name:ASI_CRM_SG_SOSubmitForApp_Controller
 * Description: Class to Validate Submit for approval
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/02/2015       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_CRM_SG_SOSubmitForApp_Controller{

    public ASI_TH_CRM_PaymentRequest__c paymentRequest {get;set;}

    public pageReference redirect(){
        Pagereference pageref;
        //try {
        
            List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentRequestLineItemList = ((List<ASI_TH_CRM_PaymentRequestLineItem__c>)queryAll(paymentRequest.id, 'ASI_TH_CRM_PaymentRequestLineItem__c', 'ASI_TH_CRM_Payment_Request__c', ''));
            ASI_CRM_SG_Payment_ValidationHelper validateHelper = new ASI_CRM_SG_Payment_ValidationHelper(true, paymentRequest, paymentRequestLineItemList);
            String validateAmount = validateHelper.validateAmountExceed();
            
            if(validateAmount != '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, validateAmount + ' Click<a href="/' + paymentRequest.Id +'" target="_parent">here</a>to go back to the record.'));
            } else if (paymentRequest.ASI_TH_CRM_Total_Amount__c == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Total Amount must be greater than 0. Click<a href="/' + paymentRequest.Id +'" target="_parent">here</a>to go back to the record.'));
            } else {
                pageRef = new pagereference('/apex/ASI_SubmitApprovalPage?id='+paymentRequest.Id);
                pageRef.setRedirect(true);
            }
            
        /*} catch(exception e) {
            pageRef = null;   
            String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
            return null;
        }*/
        
        return pageref;
    }

    public ASI_CRM_SG_SOSubmitForApp_Controller (ApexPages.StandardController stdController){
        
        ASI_TH_CRM_PaymentRequest__c paymentRequestTemp = (ASI_TH_CRM_PaymentRequest__c)stdController.getRecord();
        this.paymentRequest = ((List<ASI_TH_CRM_PaymentRequest__c>)queryAll(paymentRequestTemp.id, 'ASI_TH_CRM_PaymentRequest__c', 'ID', '')).get(0);
    }
    
    private List<sObject> queryAll(ID filterID, String sObjectName, String filteringField, String extraQuery) {
    
        List<sObject> sObjectList = new List<sObject>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
        Schema.sObjectType sObjType = globalDescription.get(sObjectName);  
        Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
        
        Map<String, Schema.SObjectField> sObjectFieldMap = r1.fields.getMap();
        String theQuery = 'Select ';
        
        for(String fields  : sObjectFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery +=' , recordtype.developername From '+sObjectName+' where '+filteringField+' = \''+ filterID + '\' ' + extraQuery;
                
        sObjectList = Database.query(theQuery);
        
        return sObjectList;
    }

}