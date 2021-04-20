public class ASI_MFM_KR_MakePOReceiptController {
    private ASI_MFM_PO__c po;
    public ASI_MFM_KR_MakePOReceiptController(ApexPages.StandardController controller) {
        po = (ASI_MFM_PO__c)controller.getRecord();
    }
    public PageReference redirect() {

        if(po.ASI_MFM_Status__c!='Approved'){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'You can not Create New PO Receipt. Because PO Status is not equal to Approved.'));
            return null;
        }
        
        ASI_MFM_Purchase_Request__c pr =[select id, ownerId from ASI_MFM_Purchase_Request__c where id =: po.ASI_MFM_Purchase_Request__c];
        
        
        /*  [SH] 2019-03-07 Remove the validatiion to check PR Owner
        if(System.UserInfo.getUserId() != pr.ownerId){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'You can not Create New PO Receipt. Only Purchase Request owner can create this PO Receipt. '));
            return null;
        }else{
		*/
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Receipt__c');  
            ASI_MFM_PO_Receipt__c por=new ASI_MFM_PO_Receipt__c(recordTypeId=rt_map.get('ASI_MFM_KR_PO_Receipt'),ASI_MFM_PO__c=po.id);
            insert por;
            return new PageReference('/apex/ASI_MFM_KR_POReceiptManageAllPage?scontrolCaching=1&id='+por.id);
            
        //}
        
          
    }
}