public with sharing class ASI_FOC_SubmitRequestController {
    public ASI_FOC_Free_Goods_Request__c rq = new ASI_FOC_Free_Goods_Request__c();
    
    public boolean succeed {get; private set;}
    public boolean need_confirm {get; private set;}
    public boolean confirmed {get; private set;}

    public ASI_FOC_SubmitRequestController(apexpages.standardController sc) {
        rq = (ASI_FOC_Free_Goods_Request__c)sc.getRecord();
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
        system.debug('bdamount::' +rq.ASI_FOC_Budget_Amount__c);
        Map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_FOC_Free_Goods_Request__c'); // Added By Alan Wong (Elufa) 20150616
        if (rq.ASI_FOC_Request_Status__c != 'Open' && rq.ASI_FOC_Request_Status__c != 'Rejected by Logistic') {
            apexpages.addMessage(new apexpages.Message(apexpages.severity.warning, 'The approval request has already been ' + rq.ASI_FOC_Request_Status__c.toLowerCase()));
            succeed = false;
            return null;
        }
        /*else if (rq.ASI_FOC_Approver_1__c == null) {
            apexpages.addMessage(new apexpages.Message(apexpages.severity.warning, 'You are not allowed to submit free goods requests'));
            succeed = false;
            return null;            
        }*/
        else if (rq.ASI_FOC_PO_Remaining_Amount__c < 0) {
            apexpages.addMessage(new apexpages.Message(apexpages.severity.warning, 'Request order over PO remaining amount, now you have 3 options: (1) Shift PO final amount. (2) Reduce quantity. (3) Cancel this request order.'));
            succeed = false;
            return null;            
        }
        else if (rq.ASI_FOC_Budget_Amount__c >= 20000 && !confirmed) {
            if (rq.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request') || rq.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request_Read_Only') || rq.recordTypeId == rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only')){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.warning, 'FG Order Cost >=20,000 RMB required attachment! Please click “Cancel” if you forgot to add, or click “Submit for Approval” if you already done.'));
                succeed = false;
                need_confirm = true;
                return null;  
            }
        }
        
        if (rq.ASI_FOC_Request_Status__c != 'Completed' && rq.ASI_FOC_Request_Status__c != 'Final' && rq.ASI_FOC_Request_Status__c != 'Rejected' && rq.ASI_FOC_Request_Status__c != 'Cancelled') {
            if(rq.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request') || rq.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request_Read_Only') || rq.recordTypeId == rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only')){
                Approval.ProcessSubmitRequest itm_req = new Approval.ProcessSubmitRequest();
                itm_req.setObjectId(rq.id);
                try {
                    Approval.ProcessResult itm_result = Approval.process(itm_req);  
                    if (!itm_result.isSuccess()) {
                        succeed = false;
                        return null;
                    }   
                }
                catch (exception ex) {
                    apexpages.addMessages(ex);
                    succeed = false;
                    return null;
                }
            } else if (rq.recordTypeId == rt_map.get('ASI_FOC_CN_POSM') || rq.recordTypeId == rt_map.get('ASI_FOC_CN_POSM_Read_Only')){
                //20151211 Ben @ Elufa System
                
                Set<ID> lineItemID = new Set<ID>();
                List<ASI_FOC_Request_Item__c> lineItem = new List<ASI_FOC_Request_Item__c>([SELECT id, ASI_FOC_Brand_Director_Approval_Status__c, ASI_FOC_Brand_Director_Approval_Required__c, ASI_FOC_Brand_Approver__c, ASI_FOC_Request_Order__c FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c = : rq.id]);
                
                FOR(ASI_FOC_Request_Item__c obj : lineItem){
                    if(obj.ASI_FOC_Brand_Director_Approval_Status__c != 'In Progress' && obj.ASI_FOC_Brand_Director_Approval_Status__c != 'Approved' && obj.ASI_FOC_Brand_Director_Approval_Required__c && obj.ASI_FOC_Brand_Approver__c != NULL)
                    	lineItemID.add(obj.id);
                }
                List<Approval.ProcessSubmitRequest> lineItm_req = new List<Approval.ProcessSubmitRequest>();
                for(ID objID : lineItemID){
                    Approval.ProcessSubmitRequest tmp = new Approval.ProcessSubmitRequest();
                    tmp.setObjectId(objID);
                    lineItm_req.add(tmp);
                }
                
                try {
                    List<Approval.ProcessResult> lineItm_result = Approval.process(lineItm_req);  
                    for(Approval.ProcessResult obj : lineItm_result){
                        if (!obj.isSuccess()) {
                            return null;
                        }
                    }
                }catch (exception ex) {
                    apexpages.addMessages(ex);
                    return null;
                }
                rq.ASI_FOC_Request_Status__c = 'In Progress';
                rq.RecordTypeId = rt_map.get('ASI_FOC_CN_POSM_Read_Only');
                update rq;
                
                /*rq.ASI_FOC_Request_Status__c = 'Approved by Logistic';
                rq.ASI_FOC_Sys_Approved_By_Logistic__c = true;
                rq.ASI_FOC_Sys_Submitted__c = true;
                rq.RecordTypeId = rt_map.get('ASI_FOC_CN_POSM_Read_Only');
                update rq;*/
                //20151211 End
            }

			//Modified by Wilken on 20131021, if user submit FOC on or after 26th day of the month, need to display a different alert message after submit          
            //Original Apex Code
            //apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'The approval request was submitted successfully'));
            if(rq.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request') || rq.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request_Read_Only') || rq.recordTypeId == rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only')){
                if (System.today().day() > 25){
                    apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'The approval request was submitted successfully. Free goods request has been cut-off in this month, request will be processed and delivered in next month only'));
                }else{
                    apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'The approval request was submitted successfully'));
                }
            }
            else {
                apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'The approval request was submitted successfully'));
            }
			//End modification on 20131021
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