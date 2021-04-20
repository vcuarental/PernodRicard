public without sharing class ASI_MFM_CN_POSM_ReturnRequest_TriggerCls {

    Static Integer G_CHECK_AFTER_UPDATE = 0;
    Private Static Final Id G_HEADER_RO_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_POSM_RO');
    private static Final Id ORDER_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_POSM_Return_Batch_Approval');
    /*
    //20190916 Howard
    public static void routineAfterUpdate(list<ASI_MFM_POSM_Return_Request__c> trigger_new, map<id, ASI_MFM_POSM_Return_Request__c> trigger_oldMap){
                
        if(afterUpdateCount <= 1 || Test.isRunningTest()){
            afterUpdateCount++;
            Map<Id, Integer> totalRequestWithQuantity = new Map<Id, Integer>();
            
            allRequest = [SELECT id
                          , ASI_MFM_Item_Count__c
                          , ASI_MFM_Total_Cancel_Item__c
                          , ASI_MFM_Total_Request_Item__c 
                          , ASI_MFM_Total_Request_Item_Line__c 
                          , ASI_MFM_Logistic_Approval_Required__c
                          FROM ASI_MFM_POSM_Return_Request__c 
                          WHERE ID IN : trigger_new
                          for update
                         ];
            
            {
                set<id> update_set = new set<id>();
                Map<id,id> updateMap = new Map<id,id>();
                set<id> ri_set = new set<id>();
                for (ASI_MFM_POSM_Return_Request__c r:trigger_new) {
                    ri_set.add(r.id);
                } 
                
                list<ASI_MFM_POSM_Return_Request_Item__c> ri_list = [select ASI_MFM_Approval_Status__c, ASI_MFM_Request_Order__c
                                                                     from ASI_MFM_POSM_Return_Request_Item__c
                                                                     where ASI_MFM_Request_Order__c IN :ri_set]; 
                list<ASI_MFM_POSM_Return_Request_Item__c> update_rilist = new List<ASI_MFM_POSM_Return_Request_Item__c>();
                
                for (ASI_MFM_POSM_Return_Request__c r:trigger_new) {
                    system.debug('record type: ' + r.recordTypeId);
                    if (r.recordTypeId == rt_map.get('ASI_MFM_CN_POSM')){
                        if ((r.ASI_MFM_Request_Status__c == 'Open' || r.ASI_MFM_Request_Status__c =='Submitted')) {
                            if(!update_set.contains(r.id)){
                                update_set.add(r.id);
                                updateMap.put(r.id,rt_map.get('ASI_MFM_CN_POSM_RO'));
                            }
                        }
                    } else if (r.recordTypeId == rt_map.get('ASI_MFM_CN_POSM_RO')){
                        if (r.ASI_MFM_Request_Status__c == 'Rejected by Logistic'||r.ASI_MFM_Request_Status__c == 'Rejected'){
                            if(!update_set.contains(r.id)){
                                update_set.add(r.id);
                                updateMap.put(r.id,rt_map.get('ASI_MFM_CN_POSM'));
                            }
                        }
                    }
                    
                    if (r.recordTypeId == rt_map.get('ASI_MFM_CN_POSM') 
                        || r.recordTypeId == rt_map.get('ASI_MFM_CN_POSM_RO'))
                        {
                            if(ri_list.size()>0){
                                for (ASI_MFM_POSM_Return_Request_Item__c ri:ri_list) {
									if(
                                        (ri.ASI_MFM_ETL_Complete__c && ri.ASI_MFM_Approval_Status__c != 'Rejected' && ri.ASI_MFM_Approval_Status__c != 'Cancelled')
                                        ||
                                        (ri.ASI_MFM_Auto_Complete__c && ri.ASI_MFM_Approval_Status__c != 'Rejected' && ri.ASI_MFM_Approval_Status__c != 'Cancelled')
                                    ){
                                        if(totalRequestWithQuantity.containsKey(ri.ASI_MFM_Request_Order__c)){
                                            totalRequestWithQuantity.put(ri.ASI_MFM_Request_Order__c, totalRequestWithQuantity.get(ri.ASI_MFM_Request_Order__c) + 1);
                                        }else{
                                            totalRequestWithQuantity.put(ri.ASI_MFM_Request_Order__c, 1);
                                        }
                                    }
                                    
                                }    
                            }
                        }
                    if (r.recordTypeId == rt_map.get('ASI_MFM_CN_POSM') 
                        || r.recordTypeId == rt_map.get('ASI_MFM_CN_POSM_RO'))
                    {
                        if (r.ASI_MFM_Approved_By_Logistic__c  
                            && (r.ASI_MFM_Total_Request_Item_Line__c == r.ASI_MFM_Total_Request_Item_Line_AutoComp__c  
                                || (totalRequestWithQuantity.containsKey(r.id) 
                                    && totalRequestWithQuantity.get(r.id) == r.ASI_MFM_Total_Request_Item_Line__c)) 
                            && (r.ASI_MFM_Total_Request_Item_Line_AutoComp__c != trigger_oldMap.get(r.id).ASI_MFM_Total_Request_Item_Line_AutoComp__c  
                                || r.ASI_MFM_Total_Request_Item_Line__c != trigger_oldMap.get(r.id).ASI_MFM_Total_Request_Item_Line__c 
                                ||  r.ASI_MFM_Request_Status__c == 'Approved by Logistic')) 
                        {
                            if (ri_list.size() > 0 && i == 0) 
                            {
                                List<Approval.ProcessSubmitRequest> itm_reqList = new List<Approval.ProcessSubmitRequest>();
                                for (ASI_MFM_POSM_Return_Request_Item__c ri:ri_list) {
                                    if (ri.ASI_MFM_Approval_Status__c == null) {
                                        Approval.ProcessSubmitRequest itm_req = new Approval.ProcessSubmitRequest();
                                        itm_req.setObjectId(ri.id);
                                        itm_reqList.add(itm_req);
                                    }
                                }
                                Approval.process(itm_reqList);
                                i++;
                            }
                        }
                    }
                }
                //if(update_set.size()>0)
                //{
                
            	//}
                if (update_set.size() > 0) {
                    list<ASI_MFM_POSM_Return_Request__c> update_list = new List<ASI_MFM_POSM_Return_Request__c>();
                    for(ASI_MFM_POSM_Return_Request__c obj : allRequest){
                        if(update_set.contains(obj.id)){
                            update_list.add(obj);
                        }
                    }
                    for (ASI_MFM_POSM_Return_Request__c r:update_list) {
                        r.RecordTypeId = updateMap.get(r.id);
                    }
                    update update_list;
                }
                if(update_rilist.size()>0){
                    update update_rilist;
                }
            }
            
            set<id> submitted_set = new set<id>();
            for (ASI_MFM_POSM_Return_Request__c r:trigger_new) {
                if (r.ASI_MFM_Submitted__c && r.ASI_MFM_Item_Count__c > 0 
                    //&& r.ASI_MFM_Approved_By_Logistic__c 
                    && r.ASI_MFM_Total_Approval_Return_Items__c == r.ASI_MFM_Total_Approved_Return_Items__c 
                    && r.ASI_MFM_Request_Status__c != 'Rejected' 
                    //&& r.ASI_MFM_Total_Request_Item_Line__c == r.ASI_MFM_Total_Request_Item_Line_AutoComp__c 
                    && (r.ASI_MFM_Request_Status__c == 'Approved by Logistic' || r.ASI_MFM_Request_Status__c == 'In Progress')&&
                    (r.recordTypeId == rt_map.get('ASI_MFM_CN_POSM') 
                     || r.recordTypeId == rt_map.get('ASI_MFM_CN_POSM_RO'))) 
                {
                    submitted_set.add(r.id);
                }
            }
            if (submitted_set.size() > 0) {
                list<ASI_MFM_POSM_Return_Request__c> submitted_list = new List<ASI_MFM_POSM_Return_Request__c>();
                for(ASI_MFM_POSM_Return_Request__c obj : allRequest){
                    if(submitted_set.contains(obj.id)){
                        submitted_list.add(obj);
                    }
                }
                
                list<id> rid_list = new list<id>();
                for (ASI_MFM_POSM_Return_Request__c r:submitted_list) {
                    if (r.ASI_MFM_Total_Request_Item_Line__c == 0) {
                        if (r.ASI_MFM_Total_Request_Item__c == r.ASI_MFM_Total_Cancel_Item__c) {
                            r.ASI_MFM_Request_Status__c = 'Cancelled';
                        } else {
                            r.ASI_MFM_Request_Status__c = 'Rejected';
                        }
                        r.ASI_MFM_Delivery_Status__c = '';
                        r.ASI_MFM_Approved_By_Logistic__c  = false;
                    }
                    else {
                        r.ASI_MFM_Submitted__c = false;
                        r.ASI_MFM_Approved_By_Logistic__c = false;
                        rid_list.add(r.id);                 
                    }
                }
                system.debug('submir_set:::' + submitted_set.size());
                update submitted_list;
                List<Approval.ProcessSubmitRequest> sub_reqList = new List<Approval.ProcessSubmitRequest>();
                for (id rid:rid_list) {
                    Approval.ProcessSubmitRequest sub_req = new Approval.ProcessSubmitRequest();
                    sub_req.setObjectId(rid);
                    sub_reqList.add(sub_req);
                }
                if(!test.isRunningTest())
                    Approval.process(sub_reqList);
            }
            
            set<id> fin_app_set = new set<id>();
            for (ASI_MFM_POSM_Return_Request__c r:trigger_new) {
                /*if (r.ASI_FOC_Sys_Approved_By_Finance__c && !trigger_oldMap.get(r.id).ASI_FOC_Sys_Approved_By_Finance__c) {
                    fin_app_set.add(r.id);
                }*//*
            }
            if (fin_app_set.size() > 0) {
                //getApprovalComments(fin_app_set);
            }
            
            Set<id> Reject_List = new Set<id>();
            for (ASI_MFM_POSM_Return_Request__c r:trigger_new) {
                
                if (r.ASI_MFM_Rejected_by_System__c && !trigger_oldMap.get(r.id).ASI_MFM_Rejected_by_System__c) {
                    Reject_List.add(r.id);
                }
            }
            
            if (Reject_List.size() > 0 || Test.isRunningTest()){
                List<Id> newWorkItemIds = new List<Id>();
                for (List<ProcessInstance> pis : [Select (Select Id From Workitems) From ProcessInstance p WHERE p.TargetObjectId IN :Reject_List AND p.Status = 'Pending']) {
                    for (ProcessInstance pi : pis) {
                        for (List<ProcessInstanceWorkitem> wis : pi.Workitems) {
                            for (ProcessInstanceWorkitem wi : wis ) {
                                newWorkItemIds.add(wi.id);
                            }
                        }
                    }
                }
                if (newWorkItemIds.size() > 0){
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments('Rejected By System');
                    req2.setAction('Reject'); //This is the action that is approve in your case, you can set it to Reject also
                    req2.setWorkitemId(newWorkItemIds.get(0));
                    Approval.ProcessResult result2 =  Approval.process(req2);
                }
                newWorkItemIds.clear(); 
                
                list<ASI_MFM_POSM_Return_Request_Item__c> ri_list = [select ASI_MFM_Approval_Status__c from ASI_MFM_POSM_Return_Request_Item__c
                                                                     where ASI_MFM_Request_Order__c IN :Reject_List];
                system.debug('ri_list:::' + ri_list);
                for (List<ProcessInstance> pis : [Select (Select Id From Workitems) From ProcessInstance p WHERE p.TargetObjectId IN :ri_list AND p.Status = 'Pending']) {
                    for (ProcessInstance pi : pis) {
                        for (List<ProcessInstanceWorkitem> wis : pi.Workitems) {
                            for (ProcessInstanceWorkitem wi : wis ) {
                                newWorkItemIds.add(wi.id);
                            }
                        }
                    }
                    system.debug('pis:::' + pis);
                }
                List<Approval.ProcessWorkitemRequest> req_list = new List<Approval.ProcessWorkitemRequest>();
                for (id ri_id: newWorkItemIds){
                    Approval.ProcessWorkitemRequest req3 = new Approval.ProcessWorkitemRequest();
                    req3.setComments('Rejected By System');
                    req3.setAction('Reject'); 
                    req3.setWorkitemId(ri_id);
                    req_list.add(req3);
                }
                system.debug('newWorkItemIds:::' + newWorkItemIds);
                system.debug('req_list:::' + req_list);
                if (req_list.size()>0){
                    List<Approval.ProcessResult> resultList = Approval.process(req_list);
                }
                
                List<ASI_MFM_POSM_Return_Request__c> uplist = new List<ASI_MFM_POSM_Return_Request__c>();
                
                for(ASI_MFM_POSM_Return_Request__c obj : allRequest){
                    if(Reject_List.contains(obj.id)){
                        uplist.add(obj);
                    }
                }
                
                for (ASI_MFM_POSM_Return_Request__c r: uplist) {
                    r.ASI_MFM_Request_Status__c = 'Rejected by System';
                    r.RecordTypeId = rt_map.get('ASI_MFM_CN_POSM_RO');
                }
                update uplist;
            }
            
        }
    }
	*/
    public static void routineBeforeInsert(list<ASI_MFM_POSM_Return_Request__c> trigger_new){
        generateNameWRunningNum(trigger_new);
    }
    
    private static void generateNameWRunningNum(list<ASI_MFM_POSM_Return_Request__c> trigger_new){
        //format: PRR-19100001
        string sFormat = 'PRR-{0}{1}';
        
        Set<string> setFiscalYear = new Set<string>();
        Integer iORGFiscalMonth = 7;	//[SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        for(ASI_MFM_POSM_Return_Request__c oRequest : trigger_new) {
            if (oRequest.RecordTypeId != ORDER_APPROVAL_ID) {
                setFiscalYear.add(getFiscalYear(iORGFiscalMonth, oRequest.ASI_MFM_Return_Request_Date__c));
            }
            if (oRequest.RecordTypeId == ORDER_APPROVAL_ID ) {
                oRequest.Name = String.valueOf('PRRA-'+Datetime.now().getTime());
            }            
        }
        Map<Id, ASI_MFM_Prefix__c > mapPrefix = new Map<Id, ASI_MFM_Prefix__c >([
            SELECT ASI_MFM_Fiscal_year__c, Name, ASI_MFM_Next_Number__c 
            FROM ASI_MFM_Prefix__c                                                                      
            WHERE ASI_MFM_Module__c = 'POSM Return'
            	AND RecordTypeId = :Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix')
            	AND ASI_MFM_Fiscal_year__c IN :setFiscalYear
            for update
        ]);
        
        if (mapPrefix.size()>0) {
            for(ASI_MFM_POSM_Return_Request__c oRequest : trigger_new) {
                string sTmpFiscalYear = getFiscalYear(iORGFiscalMonth, oRequest.ASI_MFM_Return_Request_Date__c);
                
                for(Id idPrefix : mapPrefix.keySet()) {
                    ASI_MFM_Prefix__c oPrefix = mapPrefix.get(idPrefix);
                    if (oPrefix.ASI_MFM_Fiscal_year__c == sTmpFiscalYear) {
                        List<string> ltParam = new List<string>();
                        ltParam.add(oPrefix.Name);
                        ltParam.add(string.valueOf(oPrefix.ASI_MFM_Next_Number__c + 10000).substring(1, 5));
                        oRequest.name = string.format(sFormat, ltParam);
                    	oPrefix.ASI_MFM_Next_Number__c++;
                        break;
                    }
                }
            }
            ASI_MFM_Function.updatePrefix(mapPrefix.values());
        }
    }
    
    private static string getFiscalYear(Integer iORGFiscalMonth, Datetime dtRequestDate){
        Date dtORGFiscalYear = Date.newinstance(dtRequestDate.year(), iORGFiscalMonth, 1);   
        String yearA1 = dtRequestDate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1;
        Integer yearA2 = Integer.valueOf(yearA1) +1;
        String Current_Fiscal_year;
        if(dtRequestDate < dtORGFiscalYear){
            Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        }else{
            Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
        }
        return Current_Fiscal_year;
    }
    
	public static void routineBeforeUpsert(list<ASI_MFM_POSM_Return_Request__c> trigger_new, map<id, ASI_MFM_POSM_Return_Request__c> trigger_oldMap){
        assignApprovers(trigger_new);
        assignReturnEmails(trigger_new);
        
	}
    
    public static void routineAfterUpdate(list<ASI_MFM_POSM_Return_Request__c> trigger_new, map<id, ASI_MFM_POSM_Return_Request__c> trigger_oldMap){
                
        if(G_CHECK_AFTER_UPDATE <= 1 || Test.isRunningTest()) {
            G_CHECK_AFTER_UPDATE++;
            
            
            checkAutoApproval(trigger_new, trigger_oldMap);
        }
    }
    
    private static void checkAutoApproval(list<ASI_MFM_POSM_Return_Request__c> trigger_new, map<id, ASI_MFM_POSM_Return_Request__c> trigger_oldMap) {
        //1) header status = In Progress
        //2) valid item count
        
        Map<Id, Integer> mapTotalItem = new Map<Id, Integer>();
        Map<Id, Integer> mapItemInProgress = new Map<Id, Integer>();
        Map<Id, Integer> mapItemCanceled = new Map<Id, Integer>();
        Map<Id, Integer> mapItemRejected = new Map<Id, Integer>();
        
        Set<Id> setHInProgress = new Set<Id>();
        for(ASI_MFM_POSM_Return_Request__c oHeader : trigger_new) {
            // 202009 eidt By LEO JING BLS
            if (oHeader.ASI_MFM_Request_Status__c == 'In Progress' && oHeader.ASI_MFM_POSM_Return_Request_Approval__c == null) {
                setHInProgress.add(oHeader.Id);
                
                mapTotalItem.put(oHeader.Id, 0);
                mapItemInProgress.put(oHeader.Id, 0);
                mapItemCanceled.put(oHeader.Id, 0);
                mapItemRejected.put(oHeader.Id, 0);
            }
        }
        
        List<ASI_MFM_POSM_Return_Request_Item__c> ltItem = [
            SELECT Id, Name, ASI_MFM_Item_Owner__c, ASI_MFM_Approval_Status__c, ASI_MFM_Request_Order__c
            FROM ASI_MFM_POSM_Return_Request_Item__c
            WHERE ASI_MFM_Request_Order__c IN :setHInProgress
        ];
        
        for(ASI_MFM_POSM_Return_Request_Item__c oItem : ltItem) {
            Id idHeader = oItem.ASI_MFM_Request_Order__c;
            
			mapTotalItem.put(idHeader, mapTotalItem.get(idHeader) + 1);
            if (oItem.ASI_MFM_Approval_Status__c == 'In Progress') mapItemInProgress.put(idHeader, mapItemInProgress.get(idHeader) + 1);
            if (oItem.ASI_MFM_Approval_Status__c == 'Canceled') mapItemCanceled.put(idHeader, mapItemCanceled.get(idHeader) + 1);
            if (oItem.ASI_MFM_Approval_Status__c == 'Rejected') mapItemRejected.put(idHeader, mapItemRejected.get(idHeader) + 1);
        }
        
        //header submit approval / auto-reject / auto-cancel
        List<Approval.ProcessSubmitRequest> ltHSubmit = new List<Approval.ProcessSubmitRequest>();
        List<ASI_MFM_POSM_Return_Request__c> ltHUpdate = new List<ASI_MFM_POSM_Return_Request__c>();
        
        for(Id idHInProgress : setHInProgress) {
            Integer iTmpTotalItem = mapTotalItem.get(idHInProgress);
        	Integer iTmpInProgress = mapItemInProgress.get(idHInProgress);
        	Integer iTmpCanceled = mapItemCanceled.get(idHInProgress);
        	Integer iTmpRejected = mapItemRejected.get(idHInProgress);
            
            if ((iTmpTotalItem > 0) && (iTmpInProgress == 0)) {
                if (iTmpRejected == 0) {
                    if (iTmpTotalItem == iTmpCanceled) {
                        ltHUpdate.add(
                            new ASI_MFM_POSM_Return_Request__c(
                                Id = idHInProgress
                                , ASI_MFM_Request_Status__c = 'Canceled'
                                , RecordTypeId = G_HEADER_RO_RECORD_TYPE_ID
                            )
                        );
                    } else {
                        Approval.ProcessSubmitRequest oRequest = new Approval.ProcessSubmitRequest();
                        oRequest.setObjectId(idHInProgress);
                        ltHSubmit.add(oRequest);
                    }
                } else {
                    ltHUpdate.add(
                        new ASI_MFM_POSM_Return_Request__c(
                            Id = idHInProgress
                            , ASI_MFM_Request_Status__c = 'Rejected'
                            , RecordTypeId = G_HEADER_RO_RECORD_TYPE_ID
                        )
                    );
                }
            }
        }
		
        if ((!test.isRunningTest()) && (ltHSubmit.size() > 0)) Approval.process(ltHSubmit);
        if (ltHUpdate.size() > 0) update ltHUpdate;
    }
    
    private static void assignApprovers(list<ASI_MFM_POSM_Return_Request__c> ltHeader) {
        Set<Id> setOwner = new Set<Id>();
        for(ASI_MFM_POSM_Return_Request__c oHeader : ltHeader) {
            setOwner.add(oHeader.OwnerId);
        }
        
        Map<Id, User> mapOwner = new Map<Id, User>([
            SELECT Id, ManagerId
            FROM User
            WHERE Id IN :setOwner
        ]);
        
        for(ASI_MFM_POSM_Return_Request__c oHeader : ltHeader) {
            if ((oHeader.ASI_MFM_Request_Status__c == 'Open')
            	&& (oHeader.OwnerId != NULL)
                && (mapOwner.containsKey(oHeader.OwnerId)))
            {
            	oHeader.ASI_MFM_Approver_1__c = mapOwner.get(oHeader.OwnerId).ManagerId;   
            }
        }
    }
    
    private static void assignReturnEmails(list<ASI_MFM_POSM_Return_Request__c> ltHeader) {
        Set<Id> setWarehouse = new Set<Id>();
        for(ASI_MFM_POSM_Return_Request__c oHeader : ltHeader) {
            setWarehouse.add(oHeader.ASI_MFM_To_Warehouse__c);
        }
        
        Map<Id, ASI_FOC_Warehouse__c> mapWarehouse = new Map<Id, ASI_FOC_Warehouse__c>([
            SELECT Id
            	, ASI_MFM_Return_Request_Email_1__c, ASI_MFM_Return_Request_Email_2__c, ASI_MFM_Return_Request_Email_3__c, ASI_MFM_Return_Request_Email_4__c, ASI_MFM_Return_Request_Email_5__c
                , ASI_MFM_Return_Request_Email_6__c, ASI_MFM_Return_Request_Email_7__c, ASI_MFM_Return_Request_Email_8__c, ASI_MFM_Return_Request_Email_9__c, ASI_MFM_Return_Request_Email_10__c
            FROM ASI_FOC_Warehouse__c
            WHERE Id IN :setWarehouse
        ]);
        
        for(ASI_MFM_POSM_Return_Request__c oHeader : ltHeader) {
            if ((oHeader.ASI_MFM_Request_Status__c == 'Open')
                && (oHeader.ASI_MFM_To_Warehouse__c != NULL)
                && (mapWarehouse.containsKey(oHeader.ASI_MFM_To_Warehouse__c)))
            {
                oHeader.ASI_MFM_Return_Request_Email_1__c = mapWarehouse.get(oHeader.ASI_MFM_To_Warehouse__c).ASI_MFM_Return_Request_Email_1__c;
                oHeader.ASI_MFM_Return_Request_Email_2__c = mapWarehouse.get(oHeader.ASI_MFM_To_Warehouse__c).ASI_MFM_Return_Request_Email_2__c;
                oHeader.ASI_MFM_Return_Request_Email_3__c = mapWarehouse.get(oHeader.ASI_MFM_To_Warehouse__c).ASI_MFM_Return_Request_Email_3__c;
                oHeader.ASI_MFM_Return_Request_Email_4__c = mapWarehouse.get(oHeader.ASI_MFM_To_Warehouse__c).ASI_MFM_Return_Request_Email_4__c;
                oHeader.ASI_MFM_Return_Request_Email_5__c = mapWarehouse.get(oHeader.ASI_MFM_To_Warehouse__c).ASI_MFM_Return_Request_Email_5__c;
                oHeader.ASI_MFM_Return_Request_Email_6__c = mapWarehouse.get(oHeader.ASI_MFM_To_Warehouse__c).ASI_MFM_Return_Request_Email_6__c;
                oHeader.ASI_MFM_Return_Request_Email_7__c = mapWarehouse.get(oHeader.ASI_MFM_To_Warehouse__c).ASI_MFM_Return_Request_Email_7__c;
                oHeader.ASI_MFM_Return_Request_Email_8__c = mapWarehouse.get(oHeader.ASI_MFM_To_Warehouse__c).ASI_MFM_Return_Request_Email_8__c;
                oHeader.ASI_MFM_Return_Request_Email_9__c = mapWarehouse.get(oHeader.ASI_MFM_To_Warehouse__c).ASI_MFM_Return_Request_Email_9__c;
                oHeader.ASI_MFM_Return_Request_Email_10__c = mapWarehouse.get(oHeader.ASI_MFM_To_Warehouse__c).ASI_MFM_Return_Request_Email_10__c;
            }
        }
    }
    //202009 added by LEO Jing BSL
    public static void approvalPass(list<ASI_MFM_POSM_Return_Request__c> trigger_new, map<id, ASI_MFM_POSM_Return_Request__c> trigger_oldMap){

        Set<Id> yes_requestIds = new Set<Id>();
        Set<Id> no_requestIds = new Set<Id>();
        for (ASI_MFM_POSM_Return_Request__c request : trigger_new) {
            ASI_MFM_POSM_Return_Request__c old_request = trigger_oldMap.get(request.Id);
            if (request.ASI_MFM_Request_Status__c == 'Approved' && request.ASI_MFM_Request_Status__c != old_request.ASI_MFM_Request_Status__c) {
                yes_requestIds.add(request.Id);
            }
            if (request.ASI_MFM_Request_Status__c == 'Rejected' && request.ASI_MFM_Request_Status__c != old_request.ASI_MFM_Request_Status__c) {
                no_requestIds.add(request.Id);
            }
        }
        if (yes_requestIds.size() >  0) {
            List<ASI_MFM_POSM_Return_Request__c> yes_requestList = [SELECT Id FROM ASI_MFM_POSM_Return_Request__c WHERE ASI_MFM_POSM_Return_Request_Approval__c IN: yes_requestIds];
            if (yes_requestList.size() > 0) {
                for (ASI_MFM_POSM_Return_Request__c request : yes_requestList ) {
                    request.ASI_MFM_Request_Status__c = 'Approved';
                }
                update yes_requestList;
            } 
        }
        if (no_requestIds.size() >  0) {
            List<ASI_MFM_POSM_Return_Request__c> no_requestList = [SELECT Id FROM ASI_MFM_POSM_Return_Request__c WHERE ASI_MFM_POSM_Return_Request_Approval__c IN: no_requestIds];
            if (no_requestList.size() > 0) {
                for (ASI_MFM_POSM_Return_Request__c request : no_requestList ) {
                    request.ASI_MFM_Request_Status__c = 'Rejected';
                }
                update no_requestList;
            } 
        }
        

    }
                                           
}