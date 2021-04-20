public without sharing class ASI_MFM_CN_PO_GiftMaterial_SubmitCtrl {
    public ASI_MFM_CN_PO_GiftMaterial_SubmitCtrl(){
        
    }
    
    public PageReference submit(){
        string poid = apexpages.currentpage().getparameters().get('id');
        if(poid!=null && poid!=''){
   			ASI_MFM_PO__c POupdate = [select Id, Name, ASI_MFM_Status__c, RecordTypeId, ASI_MFM_CN_Return_Flag__c, ASI_MFM_PO_Final_Date__c, ASI_MFM_PO_Original_Amount__c, ASI_MFM_PO_Amount__c 
                                      from ASI_MFM_PO__c 
                                      where Id =: poid 
                                      Limit 1];
            RecordType RecordType_PO = [Select Name, Id 
                                        from RecordType 
                                        Where DeveloperName ='ASI_MFM_CN_PO_Read_Only' 
                                        And SObjectType = 'ASI_MFM_PO__c'];
            POupdate.ASI_MFM_Status__c = 'Final';
            POupdate.RecordTypeId= RecordType_PO.Id;
            POupdate.ASI_MFM_CN_Return_Flag__c = false;
            POupdate.ASI_MFM_PO_Final_Date__c = Date.today();
            POupdate.ASI_MFM_PO_Original_Amount__c = POupdate.ASI_MFM_PO_Amount__c;                       
            try {
                update POupdate;

            } catch(DmlException e) {
                System.debug(e.getMessage());
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Record failed to submit for approval.'+e.getMessage());
                
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        
        PageReference pageRef = new PageReference('/'+poid);
        system.debug('pageRef:'+pageRef);
        return pageRef;
    }
}