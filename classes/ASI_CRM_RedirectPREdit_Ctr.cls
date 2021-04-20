/*
    - This Controller controls the Page Traffic of the Contract Standard Edit Action.
*/

public class ASI_CRM_RedirectPREdit_Ctr {
    private ASI_TH_CRM_PaymentRequest__c pr{get;set;}
    private String recordTypeId{get;set;}
    private String recordId{get;set;}
    private String recordTypeName{get;set;}
    public PageReference redirectPage {get;set;}
    
    public ASI_CRM_RedirectPREdit_Ctr (ApexPages.StandardController controller) {
        
        recordTypeId = ((ASI_TH_CRM_PaymentRequest__c)controller.getRecord()).RecordTypeId;
        recordId = ((ASI_TH_CRM_PaymentRequest__c)controller.getRecord()).Id;
        recordTypeName = 'null';
        for(RecordType rt:[select id,DeveloperName from RecordType where id = :recordTypeId limit 1])
             recordTypeName = rt.DeveloperName;
    }
    public PageReference redirect(){
        //if RecordTypeName = 'ASI_TH_CRM_Payment_Request', redirect to its default edit page. if 'ASI_CRM_CN_Payment_Request', redirect to page 'ASI_CRM_CN_EditPayment_Header_Page'

        if(recordTypeName == 'ASI_TH_CRM_Payment_Request' || recordTypeName == 'ASI_CRM_MY_Payment_Request')
        {
            Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_PaymentRequest__c.sObjectType.getDescribe();
            redirectPage =  new PageReference('/'+recordId+'/e?retURL=%2F'+ recordId +'&nooverride=1');
        }
        else if(recordTypeName == 'ASI_CRM_CN_Payment_Request') 
        {            
            ASI_TH_CRM_PaymentRequest__c PaymentRequest =[select Id,Name,ASI_CRM_CN_Promotion_Type__c from ASI_TH_CRM_PaymentRequest__c where id=:recordId];
              if(PaymentRequest.ASI_CRM_CN_Promotion_Type__c!=null &&  PaymentRequest.ASI_CRM_CN_Promotion_Type__c=='Heavy Contract On'){
                   if(PaymentRequest.Name.length()>3){
                    if(PaymentRequest.Name.substring(PaymentRequest.Name.length()-3, PaymentRequest.Name.length()) == '000'){redirectPage =  new PageReference('/apex/ASI_CRM_CN_EditPayment_Header_Page?RecordType='+recordTypeId + '&id=' + recordId); }
                    else{
                        redirectPage =  new PageReference('/apex/ASI_CRM_CN_EditHeavyPayment_Header_Page?id='+ recordId); 
                    }
                }
              }else{
                   redirectPage =  new PageReference('/apex/ASI_CRM_CN_EditPayment_Header_Page?RecordType='+recordTypeId + '&id=' + recordId);
              }
              
            //redirectPage =  new PageReference('/apex/ASI_CRM_CN_EditPayment_Header_Page?RecordType='+recordTypeId + '&id=' + recordId);
        }
		else if(recordTypeName == 'ASI_CRM_PH_Payment_Request') 
        {									  
            redirectPage =  new PageReference('/'+recordId+'/e?retURL=%2F'+ recordId +'&nooverride=1');																															 
        }
        else if(recordTypeName.contains('ASI_CRM_SG')){Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_PaymentRequest__c.sObjectType.getDescribe(); redirectPage = new PageReference('/'+recordId+'/e?retURL=%2F'+ recordId +'&nooverride=1');}
        
        return redirectPage;
    }

}