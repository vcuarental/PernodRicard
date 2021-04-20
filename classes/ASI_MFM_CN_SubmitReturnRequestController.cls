public without sharing class ASI_MFM_CN_SubmitReturnRequestController {

    Private Static Final Id G_HEADER_RO_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_POSM_RO');
    Private Static Final Id G_LINE_RO_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request_Item__cASI_MFM_CN_POSM_Request_Item_RO');
    
    public ASI_MFM_POSM_Return_Request__c rq = new ASI_MFM_POSM_Return_Request__c();

    public boolean succeed {get; private set;}
    public boolean need_confirm {get; private set;}
    public boolean confirmed {get; private set;}
    
    public ASI_MFM_CN_SubmitReturnRequestController(apexpages.standardController sc) {
        rq = (ASI_MFM_POSM_Return_Request__c)sc.getRecord();
        need_confirm = false;
        confirmed = false;
    }

    public pageReference confirm() {
        confirmed = true;
        return submitRequest();
    }

    public pageReference goBack() {
        return new pageReference('/' + rq.id);
    }

    public pageReference submitRequest() {
        succeed = false;

        if (rq.ASI_MFM_Request_Status__c != 'Open') {
            apexpages.addMessage(new apexpages.Message(apexpages.severity.warning, 'The approval request has already been ' + rq.ASI_MFM_Request_Status__c.toLowerCase()));
            return null;
        }
 
        if (rq.ASI_MFM_Request_Status__c != 'Completed' && rq.ASI_MFM_Request_Status__c != 'Final' && rq.ASI_MFM_Request_Status__c != 'Rejected' && rq.ASI_MFM_Request_Status__c != 'Cancelled') {
            //get all items
            List<ASI_MFM_POSM_Return_Request_Item__c> ltItems = new List<ASI_MFM_POSM_Return_Request_Item__c>([
                SELECT id, ASI_MFM_Approval_Status__c, ASI_MFM_Item_Owner__c, ASI_MFM_Request_Order__c 
                FROM ASI_MFM_POSM_Return_Request_Item__c 
                WHERE ASI_MFM_Request_Order__c = :rq.id
            ]);
            
            //check having items for approval
            Set<Id> setItemApproval = new Set<Id>();
            Set<Id> setItemAutoApproval = new Set<Id>();
            for (ASI_MFM_POSM_Return_Request_Item__c oItem : ltItems) {
                if (oItem.ASI_MFM_Item_Owner__c != NULL) {
                    if ((oItem.ASI_MFM_Approval_Status__c != 'Approved') || (oItem.ASI_MFM_Approval_Status__c != 'In Progress')) {
                        setItemApproval.add(oItem.Id);
                    }
                } else {
                    setItemAutoApproval.add(oItem.Id);
                }
            }
            
            if (setItemApproval.size() == 0) {
                
                //header approval
                Approval.ProcessSubmitRequest oHApp = new Approval.ProcessSubmitRequest();
                oHApp.setObjectId(rq.id);
                try {
                    Approval.ProcessResult oHResult = Approval.process(oHApp);  
                    if (!oHResult.isSuccess()) {
                        return null;
                    }
                }
                catch (exception ex) {
                    if (!Test.isRunningTest()) {
                        apexpages.addMessages(ex);
                        return null;
                    }
                }
                
            } else {
                
                //line approval
                List<Approval.ProcessSubmitRequest> ltItemApp = new List<Approval.ProcessSubmitRequest>();
                for(ID oTmpItemID : setItemApproval){
                    Approval.ProcessSubmitRequest oTmpApp = new Approval.ProcessSubmitRequest();
                    oTmpApp.setObjectId(oTmpItemID);
                    ltItemApp.add(oTmpApp);
                }
                
                try {
                    List<Approval.ProcessResult> ltItemResult = Approval.process(ltItemApp);  
                    for(Approval.ProcessResult oIResult : ltItemResult){
                        if (!oIResult.isSuccess()) {
                            return null;
                        }
                    }
                }catch (exception ex) {
                    if (!Test.isRunningTest()) {
                        apexpages.addMessages(ex);
                        return null;
                    }
                }
                
                //change header status
                rq.ASI_MFM_Request_Status__c = 'In Progress';
                rq.RecordTypeId = G_HEADER_RO_RECORD_TYPE_ID;
                update rq;
            }
            
            // auto line approval
            if (setItemAutoApproval.size() > 0) {
                List<ASI_MFM_POSM_Return_Request_Item__c> ltAutoItem = new List<ASI_MFM_POSM_Return_Request_Item__c>();
                for(ID oTmpItemID : setItemAutoApproval){
                    ltAutoItem.add(new ASI_MFM_POSM_Return_Request_Item__c(
                        id = oTmpItemID
                        , ASI_MFM_Approval_Status__c = 'Approved'
                        , RecordTypeId = G_LINE_RO_RECORD_TYPE_ID
                    ));
                }
                update ltAutoItem;
            }

            apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'The approval request was submitted successfully'));

            succeed = true;
            return null;
			
        }
        else {
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'No request items are found'));
            succeed = false;
            return null;                
        } 

    }

}