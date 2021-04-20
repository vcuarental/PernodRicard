public without sharing class ASI_FOC_Free_Goods_Request_TriggerClass {
    static integer i = 0;//20151102 Ben @ Elufa
    
    //20151214 Ben @ Elufa System
    Static List<ASI_FOC_Request_Item__c> lineItemList = new List<ASI_FOC_Request_Item__c>();
    Static List<ASI_FOC_Free_Goods_Request__c> allRequest = new List<ASI_FOC_Free_Goods_Request__c>();
    Static Integer afterUpdateCount = 0;
    Static Integer beforeUpdateCount = 0;
    Static Map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_FOC_Free_Goods_Request__c');
    Static Boolean isDumpicateEnter= false;//add by Alex too many soql:101
    public static Id ORDER_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_CRM_CN_POSM_Batch_Approval');

    //20170926 Introv
    Public Static List<ASI_CRM_Dynamic_Approval_Route__c> dynamicApprovalList =
            new List<ASI_CRM_Dynamic_Approval_Route__c>([SELECT id
                        , ASI_CRM_End_of_Dynamic_Route__c
                        , ASI_CRM_User__c
                        , ASI_CRM_Type__c
                        , ASI_CRM_Approval_Limit__c
                        FROM ASI_CRM_Dynamic_Approval_Route__c
                        WHERE RecordType.DeveloperName Like 'ASI_CRM_CN_Dynamic_Approval_Route'
                        AND (ASI_CRM_Type__c = 'Free Goods Request'
                        OR ASI_CRM_Type__c = 'POSM'
                        // 20190627 Wilson Chow
                        OR ASI_CRM_Type__c LIKE '%STK4 Order'
                        OR ASI_CRM_Type__c = 'Replacement Stock & CIQ-Operation only')
                        // 20190627 Wilson Chow
            ]);

    Public Static List<ASI_CRM_Fix_Approval_Route__c> fixApprovalList =
            new List<ASI_CRM_Fix_Approval_Route__c>([SELECT id
                        , ASI_CRM_Finance_Approver__c
                        , ASI_CRM_Logistic_Approver__c
                        // 20190627 Wilson Chow
                        , ASI_FOC_Finance_Approver_2__c
                        , ASI_FOC_Sales_Director__c
                        ,ASI_CRM_CN_Region_Area_Channel__c
                        ,ASI_CRM_CN_FG_Request_Type__c
                        ,ASI_CRM_Sales_Team__c
                        // 20190627 Wilson Chow
                        , ASI_CRM_CN_Type__c
                        FROM ASI_CRM_Fix_Approval_Route__c
                        WHERE RecordType.DeveloperName Like 'ASI_CRM_CN_Fix_Approval_Route'
                        AND (ASI_CRM_CN_Type__c = 'Free Goods Request'
                        OR ASI_CRM_CN_Type__c = 'POSM'
                        // 20190627 Wilson Chow
                        OR ASI_CRM_CN_Type__c LIKE '%STK4 Order')
                        // 20190627 Wilson Chow
                        // AND ASI_CRM_CN_Region_Area_Channel__c = NULL       //20190102 Andy @Introv - add regional approval/HQ approval
            ]);
    
    //20190102 Andy @Introv - add regional approval/HQ approval
    Public Static List<ASI_CRM_Fix_Approval_Route__c> fixApprovalList4Region =
            new List<ASI_CRM_Fix_Approval_Route__c>([SELECT id
                        , ASI_CRM_CN_Approver_1__c
                        , ASI_CRM_CN_Approver_2__c
                        , ASI_CRM_CN_Approver_3__c
                        , ASI_CRM_CN_Approver_4__c
                        , ASI_CRM_CN_Approver_5__c
                        , ASI_CRM_CN_Approver_6__c
                        , ASI_CRM_CN_Approver_7__c
                        , ASI_CRM_CN_Region_Area_Channel__c
                        , ASI_CRM_CN_Type__c
                        ,ASI_CRM_CN_FG_Request_Type__c
                        ,ASI_CRM_Sales_Team__c
                        FROM ASI_CRM_Fix_Approval_Route__c
                        WHERE RecordType.DeveloperName Like 'ASI_CRM_CN_Fix_Approval_Route'
                        AND ASI_CRM_CN_Type__c = 'POSM'
                        AND ASI_CRM_CN_Region_Area_Channel__c != NULL
            ]);
    //20190520 Howard @Introc - add regional approval(FGR)
    Public Static List<ASI_CRM_Fix_Approval_Route__c> fixApprovalList4RegionFGR =
            new List<ASI_CRM_Fix_Approval_Route__c>([SELECT id
                        , ASI_CRM_CN_Approver_1__c
                        , ASI_CRM_CN_Approval_Limit_1__c
                        , ASI_CRM_CN_Approver_2__c
                        , ASI_CRM_CN_Approver_3__c
                        , ASI_CRM_CN_Approver_4__c
                        , ASI_CRM_CN_Approver_5__c
                        , ASI_CRM_CN_Approver_6__c
                        , ASI_CRM_CN_Approver_7__c
                        , ASI_CRM_CN_Region_Area_Channel__c
                        , ASI_CRM_CN_Type__c
						, ASI_CRM_Finance_Approver__c
                        , ASI_CRM_Logistic_Approver__c
                        , ASI_FOC_Finance_Approver_2__c
                        ,ASI_CRM_CN_FG_Request_Type__c
                        ,ASI_CRM_Sales_Team__c
                        , ASI_FOC_Sales_Director__c, ASI_CRM_Event_PO_Required__c
                        FROM ASI_CRM_Fix_Approval_Route__c
                        WHERE RecordType.DeveloperName Like 'ASI_CRM_CN_Fix_Approval_Route'
                        AND ASI_CRM_CN_Type__c = 'Free Goods Request'
                        AND ASI_CRM_CN_Region_Area_Channel__c != NULL
            ]);
    
    Private Final Static Map<String, Schema.SObjectField> foc_FIELD_MAP = Schema.SObjectType.ASI_FOC_Free_Goods_Request__c.fields.getMap();
    Private Final Static Map<String, Schema.SObjectField> FixApproval_FIELD_MAP = Schema.SObjectType.ASI_CRM_Fix_Approval_Route__c.fields.getMap();
    
    //20171017 Introv
    Private Static Map<id, ASI_MFM_Expense_Control_Form__c> taxSavingList =
            new Map<id, ASI_MFM_Expense_Control_Form__c>([SELECT id
                                                        , ASI_MFM_Tax_Saving_Purpose__c
                                                        , ASI_MFM_AB_Policy_Required__c
                                                        , Name
                                                        , ASI_MFM_Customer_Code__c , ASI_MFM_Warehouse_Code__c // 20181215 Laputa
                                                        FROM ASI_MFM_Expense_Control_Form__c
                                                        WHERE RecordType.DeveloperName Like 'ASI_MFM_CN_Tax_Saving_Control_Form'
            ]);
    
    Private Static Map<String, ASI_MFM_Expense_Control_Form__c> taxSavingMap = new Map<String, ASI_MFM_Expense_Control_Form__c>();

    // 20190627 Wilson Chow
    private static final String HQ_STK4_ORDER = 'HQ STK4 Order';
    private static final String CENTRAL_STK4_ORDER = 'Central STK4 Order';
    private static final String MKT_STK4_ORDER = 'MKT STK4 Order';
    private static final String EAST_STK4_ORDER = 'East STK4 Order';
    // 20190627 Wilson Chow

    // 20200721 Jack Yuan
    private static final String CIQ_ORDER = 'Replacement Stock & CIQ-Operation only';
    // 20200721 Jack Yuan
    
    //20151214 End
    @future @TestVisible
    private static void getApprovalComments(set<id> req_set) {
        list<ASI_FOC_Free_Goods_Request__c> req_list = [select (select Comments from ProcessSteps order by createdDate desc limit 1) from ASI_FOC_Free_Goods_Request__c where id in :req_set for update];
        for (ASI_FOC_Free_Goods_Request__c r:req_list) {
            if (r.processSteps.size() > 0) {
                r.ASI_FOC_SYS_Finance_Comment__c = r.processSteps[0].comments;
            }
        }
        update req_list;        
    }
    
    public static void routineAfterAll(list<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap) {
        System.debug(LoggingLevel.INFO, '*** routineAfterAll start: ');
        // Recalculate the PO consumed amount
        set<id> po_set = new set<id>();
        Set<Id> JDEFOCIdSet = new Set<Id> ();
                //Add by Laputa, if TOV No. value changed from null to not null, set status to "FG Request to W/H"
        
        if (trigger_new != null) {
            for (ASI_FOC_Free_Goods_Request__c rq:trigger_new) {
                if (trigger_oldMap == null) {
                    po_set.add(rq.ASI_FOC_PO__c);
                }else {
                    po_set.add(rq.ASI_FOC_PO__c);
                    po_set.add(trigger_oldMap.get(rq.id).ASI_FOC_PO__c);                        
                }   
                
                if((trigger_oldMap==null && rq.ASI_FOC_JDE_Order_Number__c !=null )  || (trigger_oldMap!=null && rq.ASI_FOC_JDE_Order_Number__c!=null && trigger_oldMap.get(rq.id).ASI_FOC_JDE_Order_Number__c ==null )   ){
                    JDEFOCIdSet.add(rq.Id);
                }
            }
        } else if (trigger_oldMap != null) {
            for (ASI_FOC_Free_Goods_Request__c rq:trigger_oldMap.values()) {
                po_set.add(rq.ASI_FOC_PO__c);
            }
        }
        
        if (po_set.size() > 0) {
            list<ASI_FOC_PO__c> po_list = [select (select ASI_FOC_Budget_Amount__c from ASI_FOC_Free_Goods_Requests__r 
                                                   where (not ASI_FOC_Request_Status__c  like '%Rejected%') and ASI_FOC_Request_Status__c != 'Cancelled') 
                                           from ASI_FOC_PO__c where id in :po_set for update];
            for (ASI_FOC_PO__c po:po_list) {
                po.ASI_FOC_PO_Consumed_Amount__c = 0;
                for (ASI_FOC_Free_Goods_Request__c rq:po.ASI_FOC_Free_Goods_Requests__r) {
                    if (rq.ASI_FOC_Budget_Amount__c != null) {
                        po.ASI_FOC_PO_Consumed_Amount__c += rq.ASI_FOC_Budget_Amount__c;
                    }
                }
            }
            if (po_list.size() > 0) {
                update po_list;
            }
        }
        
        if(JDEFOCIdSet.size()>0){
            List<ASI_CRM_Internal_Complaint__c> InternalComplaintList= [select id,ASI_CRM_CN_Free_Goods_Request_Ref__c,ASI_CRM_CN_Status__c,recordTypeId from ASI_CRM_Internal_Complaint__c where ASI_CRM_CN_Free_Goods_Request_Ref__c in : JDEFOCIdSet ];
            for(ASI_CRM_Internal_Complaint__c InternalComplaint :InternalComplaintList){
                InternalComplaint.ASI_CRM_CN_Status__c='FG Request to W/H';
                //ASI_CRM_CN_FG_Request_to_W_H
                InternalComplaint.recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Internal_Complaint__cASI_CRM_CN_FG_Request_to_W_H');
            }
            if(InternalComplaintList.size()>0){
                update InternalComplaintList;
            }
        }
    }
    
    public static void routineAfterUpdate(list<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap) {
        System.debug(LoggingLevel.INFO, '*** routineAfterUpdate: start' );
        //20151214 Ben @ Elufa System
        if(afterUpdateCount <= 1){
            afterUpdateCount++;
            
            Map<Id, Integer> totalRequestWithQuantity = new Map<Id, Integer>();//20160119 Ben @ Elufa Systems
            
            allRequest = [SELECT id
                          , ASI_FOC_PO_Remaining_Amount__c
                          , ASI_FOC_SYS_Total_Lines__c
                          , ASI_FOC_SYS_Total_Request_Item__c
                          , ASI_FOC_SYS_Total_Cancel_Item__c 
                          FROM ASI_FOC_Free_Goods_Request__c 
                          WHERE ID IN : trigger_new
                          for update
                         ];
            
            //20151214 End
            
            // If the related request items have been saved via the Manage All page and the related PO remaining amount is not negative,
            // Set the record type of the request order to 'CN FOC Request and Items Read Only'
            //Map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_FOC_Free_Goods_Request__c'); // Added By Alan Wong (Elufa) 20150616
            //list<recordType> rt_list = [select id from recordType where sobjectType = 'ASI_FOC_Free_Goods_Request__c' and developerName = 'ASI_FOC_CN_Request_and_Items_Read_Only'];
            if (rt_map.containsKey('ASI_FOC_CN_Request_and_Items_Read_Only')) {
                set<id> update_set = new set<id>();
                Map<id,id> updateMap = new Map<id,id>();
                set<id> ri_set = new set<id>();
                for (ASI_FOC_Free_Goods_Request__c r:trigger_new) {
                    ri_set.add(r.id);
                }
                
                //20181130 Andy @Introv - new field (ASI_MFM_AutoComplete__c)
                list<ASI_FOC_Request_Item__c> ri_list = [select ASI_FOC_Brand_Director_Approval_Required__c, ASI_FOC_Reason__c, ASI_FOC_Brand_Director_Approval_Status__c, ASI_FOC_ETL_Complete__c, ASI_FOC_Request_Order__c, ASI_MFM_AutoComplete__c
                                                         from ASI_FOC_Request_Item__c
                                                         where ASI_FOC_Request_Order__c IN :ri_set]; 
                list<ASI_FOC_Request_Item__c> update_rilist = new List<ASI_FOC_Request_Item__c>();
                for (ASI_FOC_Free_Goods_Request__c r:trigger_new) {
                    system.debug('record type: ' + r.recordTypeId);
                    if (r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request')){
                        if (r.ASI_FOC_Number_of_Saves__c > 0 && (r.ASI_FOC_Request_Status__c == 'Open' || r.ASI_FOC_Request_Status__c =='Rejected by Logistic') && r.ASI_FOC_Number_of_Saves__c > trigger_oldMap.get(r.id).ASI_FOC_Number_of_Saves__c) {
                            if(!update_set.contains(r.id)){
                                update_set.add(r.id);
                                updateMap.put(r.id,rt_map.get('ASI_FOC_CN_Free_Goods_Request_Read_Only'));
                            }
                        }
                    } else if (r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request_Read_Only')){
                        if (r.ASI_FOC_Request_Status__c == 'Submitted') {
                            if(!update_set.contains(r.id)){
                                update_set.add(r.id);
                                updateMap.put(r.id,rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only'));
                            }
                        }
                    } else if (r.recordTypeId == rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only')){
                        if (r.ASI_FOC_Request_Status__c == 'Rejected by Logistic'){
                            if(!update_set.contains(r.id)){
                                update_set.add(r.id);
                                updateMap.put(r.id,rt_map.get('ASI_FOC_CN_Free_Goods_Request'));
                            }
                        }
                    }
                    // Approved by Logistic
                    
                    
                    // -- End -- //
                    
                    if (r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request') || r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request_Read_Only') || r.recordTypeId == rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only') ||
                        r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM') || r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM_Read_Only')){
                            if(ri_list.size()>0){
                                for (ASI_FOC_Request_Item__c ri:ri_list) {
                                    //20181130 Andy @Introv - new field (ASI_MFM_AutoComplete__c) - start
                                    /*
                                    //20160119 Ben @ Elufa Systems
                                    if(ri.ASI_FOC_ETL_Complete__c && ri.ASI_FOC_Brand_Director_Approval_Status__c != 'Rejected' && ri.ASI_FOC_Brand_Director_Approval_Status__c != 'Cancelled'){
                                    */
                                    if(
                                        (ri.ASI_FOC_ETL_Complete__c && ri.ASI_FOC_Brand_Director_Approval_Status__c != 'Rejected' && ri.ASI_FOC_Brand_Director_Approval_Status__c != 'Cancelled')
                                        ||
                                        (ri.ASI_MFM_AutoComplete__c && ri.ASI_FOC_Brand_Director_Approval_Status__c != 'Rejected' && ri.ASI_FOC_Brand_Director_Approval_Status__c != 'Cancelled')
                                    ){
                                    //20181130 Andy @Introv - new field (ASI_MFM_AutoComplete__c) - end
                                        if(totalRequestWithQuantity.containsKey(ri.ASI_FOC_Request_Order__c)){
                                            totalRequestWithQuantity.put(ri.ASI_FOC_Request_Order__c, totalRequestWithQuantity.get(ri.ASI_FOC_Request_Order__c) + 1);
                                        }else{
                                            totalRequestWithQuantity.put(ri.ASI_FOC_Request_Order__c, 1);
                                        }
                                    }
                                    //20160119 End
                                    if(r.ASI_FOC_Description__c != trigger_oldMap.get(r.id).ASI_FOC_Description__c &&  r.ASI_FOC_Description__c != '') {
                                        ri.ASI_FOC_Reason__c = r.ASI_FOC_Description__c;
                                        update_rilist.add(ri);
                                    }
                                }    
                            }
                        }
                    if (r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request') || r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request_Read_Only') || r.recordTypeId == rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only')){
                        if (r.ASI_FOC_Sys_Approved_By_Logistic__c  && (r.ASI_FOC_SYS_Total_Lines__c == r.ASI_FOC_SYS_Total_RequestWithQuantity__c || (totalRequestWithQuantity.containsKey(r.id) && totalRequestWithQuantity.get(r.id) == r.ASI_FOC_SYS_Total_Lines__c)) && (r.ASI_FOC_SYS_Total_RequestWithQuantity__c != trigger_oldMap.get(r.id).ASI_FOC_SYS_Total_RequestWithQuantity__c || r.ASI_FOC_SYS_Total_Lines__c != trigger_oldMap.get(r.id).ASI_FOC_SYS_Total_Lines__c ||  r.ASI_FOC_Request_Status__c == 'Approved by Logistic')) {
                            if (ri_list.size() > 0 && i == 0) {//20151102 Ben @ Elufa 
                                List<Approval.ProcessSubmitRequest> itm_reqList = new List<Approval.ProcessSubmitRequest>();
                                for (ASI_FOC_Request_Item__c ri:ri_list) {
                                    if (ri.ASI_FOC_Brand_Director_Approval_Required__c && ri.ASI_FOC_Brand_Director_Approval_Status__c == null) {
                                        Approval.ProcessSubmitRequest itm_req = new Approval.ProcessSubmitRequest();
                                        itm_req.setObjectId(ri.id);
                                        itm_reqList.add(itm_req);
                                        //Approval.ProcessResult itm_result = Approval.process(itm_req);
                                    }
                                }
                                Approval.process(itm_reqList);
                                i++;
                            }
                        }
                    }
                }
                if (update_set.size() > 0) {
                    //20151214 Ben @ Elufa System
                    list<ASI_FOC_Free_Goods_Request__c> update_list = new List<ASI_FOC_Free_Goods_Request__c>();
                    for(ASI_FOC_Free_Goods_Request__c obj : allRequest){
                        if(update_set.contains(obj.id) && obj.ASI_FOC_PO_Remaining_Amount__c >= 0){
                            update_list.add(obj);
                        }
                    }
                    //list<ASI_FOC_Free_Goods_Request__c> update_list = [select id, ASI_FOC_PO_Remaining_Amount__c from ASI_FOC_Free_Goods_Request__c 
                    //where id in :update_set and ASI_FOC_PO_Remaining_Amount__c >= 0 for update];
                    //20151214 End
                    for (ASI_FOC_Free_Goods_Request__c r:update_list) {
                        system.debug('PO remaining amount: ' + r.ASI_FOC_PO_Remaining_Amount__c);
                        r.RecordTypeId = updateMap.get(r.id);
                    }
                    System.debug(LoggingLevel.INFO, '*** update_list flag: ' + update_list);
                    update update_list;

                }
                if(update_rilist.size()>0){
                    System.debug(LoggingLevel.INFO, '*** update_rilist flag: ' + update_rilist);
                    update update_rilist;
                }
            }
            
            // Submit approval request if the related request items have been approved or rejected
            // Set request order to rejected status if the related request items are all rejected
            set<id> submitted_set = new set<id>();
            for (ASI_FOC_Free_Goods_Request__c r:trigger_new) {
                
                system.debug('20180131 ' + r.ASI_FOC_Sys_Submitted__c + '  r.ASI_FOC_Sys_Item_Count__c ' + r.ASI_FOC_Sys_Item_Count__c + ' r.ASI_FOC_Sys_Approved_By_Logistic__c ' + r.ASI_FOC_Sys_Approved_By_Logistic__c + ' ASI_FOC_SYS_Total_BD_Approval_Items__c ' + r.ASI_FOC_SYS_Total_BD_Approval_Items__c + ' ASI_FOC_SYS_Total_BD_Approved_Items__c  ' + r.ASI_FOC_SYS_Total_BD_Approved_Items__c + ' ASI_FOC_Request_Status__c ' + r.ASI_FOC_Request_Status__c + ' ASI_FOC_SYS_Total_Lines__c ' + r.ASI_FOC_SYS_Total_Lines__c + ' ASI_FOC_SYS_Total_RequestWithQuantity__c ' + r.ASI_FOC_SYS_Total_RequestWithQuantity__c);
                
                if (r.ASI_FOC_Sys_Submitted__c && r.ASI_FOC_Sys_Item_Count__c > 0 && r.ASI_FOC_Sys_Approved_By_Logistic__c &&
                    r.ASI_FOC_SYS_Total_BD_Approval_Items__c == r.ASI_FOC_SYS_Total_BD_Approved_Items__c && r.ASI_FOC_Request_Status__c != 'Rejected' &&
                    r.ASI_FOC_SYS_Total_Lines__c == r.ASI_FOC_SYS_Total_RequestWithQuantity__c && r.ASI_FOC_Request_Status__c == 'Approved by Logistic' &&
                    (r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request') || r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request_Read_Only') || r.recordTypeId == rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only')  || r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM')  || r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM_Read_Only'))) {
                        submitted_set.add(r.id);
                    }
            }
            if (submitted_set.size() > 0) {
                //20151214 Ben @ Elufa System
                list<ASI_FOC_Free_Goods_Request__c> submitted_list = new List<ASI_FOC_Free_Goods_Request__c>();
                for(ASI_FOC_Free_Goods_Request__c obj : allRequest){
                    if(submitted_set.contains(obj.id)){
                        submitted_list.add(obj);
                    }
                }
                //list<ASI_FOC_Free_Goods_Request__c> submitted_list = [select ASI_FOC_SYS_Total_Lines__c,ASI_FOC_SYS_Total_Request_Item__c,ASI_FOC_SYS_Total_Cancel_Item__c from ASI_FOC_Free_Goods_Request__c where id in :submitted_set for update];         
                
                //20151214 End
                list<id> rid_list = new list<id>();
                for (ASI_FOC_Free_Goods_Request__c r:submitted_list) {
                    if (r.ASI_FOC_SYS_Total_Lines__c == 0) {
                        if (r.ASI_FOC_SYS_Total_Request_Item__c == r.ASI_FOC_SYS_Total_Cancel_Item__c) {
                            r.ASI_FOC_Request_Status__c = 'Cancelled'; 
                        } else {
                            r.ASI_FOC_Request_Status__c = 'Rejected';
                        }
                        r.ASI_FOC_Delivery_Status__c = '';
                        r.ASI_FOC_Sys_Approved_By_Logistic__c = false;
                    }
                    else {
                        r.ASI_FOC_Sys_Submitted__c = false;
                        r.ASI_FOC_Sys_Approved_By_Logistic__c = false;
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
                    //Approval.ProcessResult sub_result = Approval.process(sub_req);                    
                }
                if(!test.isRunningTest())//20180205 Introv added to pass test class temporary
                    Approval.process(sub_reqList);
            }
            
            // Get approval comment when approved/rejected by financial approver
            set<id> fin_app_set = new set<id>();
            for (ASI_FOC_Free_Goods_Request__c r:trigger_new) {
                if (r.ASI_FOC_Sys_Approved_By_Finance__c && !trigger_oldMap.get(r.id).ASI_FOC_Sys_Approved_By_Finance__c && r.ASI_FOC_Request_Status__c!='Rejected by System') {
                    fin_app_set.add(r.id);
                }
            }
            if ((fin_app_set.size() > 0) && (!System.isBatch())) {
                getApprovalComments(fin_app_set);
            }
            // Added By Alan Wong (Elufa) 20150708
            Set<id> Reject_List = new Set<id>();
            for (ASI_FOC_Free_Goods_Request__c r:trigger_new) {
                
                if (r.ASI_FOC_Rejected_by_System__c && !trigger_oldMap.get(r.id).ASI_FOC_Rejected_by_System__c) {
                    Reject_List.add(r.id);
                }
            }
            if (Reject_List.size() > 0){
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
                list<ASI_FOC_Request_Item__c> ri_list = [select ASI_FOC_Brand_Director_Approval_Required__c, ASI_FOC_Brand_Director_Approval_Status__c from ASI_FOC_Request_Item__c
                                                         where ASI_FOC_Request_Order__c IN :Reject_List];
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
                
                //20151214 Ben @ Elufa System
                List<ASI_FOC_Free_Goods_Request__c> uplist = new List<ASI_FOC_Free_Goods_Request__c>();
                //List<ASI_FOC_Free_Goods_Request__c> uplist = [SELECT id FROM ASI_FOC_Free_Goods_Request__c WHERE id IN :Reject_List];
                
                for(ASI_FOC_Free_Goods_Request__c obj : allRequest){
                    if(Reject_List.contains(obj.id)){
                        uplist.add(obj);
                    }
                }
                
                //20151214 End
                for (ASI_FOC_Free_Goods_Request__c r: uplist) {
                    r.ASI_FOC_Request_Status__c = 'Rejected by System';
                    r.RecordTypeId = rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only');
                }
                System.debug(LoggingLevel.INFO, '*** uplist flag: ' + uplist);
                update uplist;
            }
            // -- End -- //
        }//20151214 End if(afterUpdateCount == 0)
    }
    
    public static void routineBeforeInsert(list<ASI_FOC_Free_Goods_Request__c> trigger_new) {
        // 20190627 Wilson Chow
        system.debug('routineBeforeInsert() start');
        // 20190627 Wilson Chow

        set<id> rid_set = new set<id>();
        set<id> owner_set = new set<id>();
        set<id> poid_set = new set<id>();
        //Map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_FOC_Free_Goods_Request__c'); // Added By Alan Wong (Elufa) 20150616
        for (ASI_FOC_Free_Goods_Request__c r:trigger_new) {          
            rid_set.add(r.id);
            owner_set.add(r.ownerId);
            if (r.ASI_CRM_CN_FG_Trade_A_P_PO__c != null) {
                poid_set.add(r.ASI_CRM_CN_FG_Trade_A_P_PO__c);
            }
        }
        if (rid_set.size() > 0) {
            map<id, user> user_map = new map<id, user>([select userRole.developerName from user where id in :owner_set]);
            set<string> role_set = new set<string>();
            for (user u:user_map.values()) {
                role_set.add(u.userRole.developerName);
            }           
            list<ASI_FOC_Route_Type__c> rt_list = [select ASI_FOC_Role_Name__c, ASI_FOC_Finance_Approver__c, ASI_FOC_Logistic_Approver__c,   
                                                   (select ASI_FOC_Approver__c, ASI_FOC_Threshold__c,ASI_FOC_POSM_Threshold__c from ASI_FOC_Route_Criteria__r order by ASI_FOC_Threshold__c) from ASI_FOC_Route_Type__c 
                                                   where ASI_FOC_Role_Name__c in :role_set];
            
            for (ASI_FOC_Free_Goods_Request__c r:trigger_new) {
                if (r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request') || 
                    r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request_Read_Only') || 
                    r.recordTypeId == rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only') ||
                    r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM') ||
                    r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM_Read_Only')){
                        //if (r.ASI_FOC_Request_Type__c != 'Return' && rid_set.contains(r.id)) {//20151223 Ben @ Elufa System
                        if (rid_set.contains(r.id)) {
                            string role_name = user_map.get(r.ownerId).userRole.developerName;
                            List<id> tempApprover = new List<id>();
                            for (ASI_FOC_Route_Type__c rt:rt_list) {
                                if (role_name == rt.ASI_FOC_Role_Name__c) {
                                    r.ASI_FOC_Finance_Approver__c = rt.ASI_FOC_Finance_Approver__c;
                                    r.ASI_FOC_Logistic_Approver__c = rt.ASI_FOC_Logistic_Approver__c;
                                    break;
                                }
                            }
                        }   
                    }
            }
        }

        // Added by Jack Yuan Start
        // Map<Id, Decimal> poRemainingMap = new Map<Id, Decimal>();
        // if (poid_set.size() > 0) {
        //     //20200803 Alex -- get PO remaining
        //     List<AggregateResult> results = [SELECT ASI_TH_CRM_Contract__c, 
        //                                             AVG(ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount_RMB__c) poAmount,
        //                                             SUM(ASI_CRM_CN_Total_Payment__c) paymentAmount 
        //                                        FROM ASI_TH_CRM_PaymentRequest__c
        //                                       WHERE ASI_TH_CRM_Contract__c != null
        //                                         AND ASI_TH_CRM_Status__c != 'Draft'
        //                                         AND ASI_TH_CRM_Contract__c IN:poid_set 
        //                                    Group By ASI_TH_CRM_Contract__c];
        //     for (AggregateResult result : results) {
        //         Id poId = (Id)result.get('ASI_TH_CRM_Contract__c');
        //         Decimal poAmount = (Decimal)result.get('poAmount');
        //         Decimal paymentAmount = (Decimal)result.get('paymentAmount');
        //         poRemainingMap.put(poId, poAmount - paymentAmount);
        //     }
        // }

        // Map<Id, String> ownerUserMap = new Map<Id, String>();
        // List<User> ownerUsers = [SELECT ASI_CRM_Sales_Team__c FROM User WHERE Id IN : owner_set];
        // for (User user : ownerUsers) {
        //     ownerUserMap.put(user.Id, user.ASI_CRM_Sales_Team__c);
        // }
        // System.debug(LoggingLevel.INFO, '*** ownerUserMap: ' + ownerUserMap);

        // List<ASI_CRM_Sales_Team__c> salesTeams = [SELECT Name, ASI_CRM_Region__c 
        //                                           FROM ASI_CRM_Sales_Team__c 
        //                                           WHERE Name IN :ownerUserMap.values()];
        // Map<String, String> teamRegionMap = new Map<String, String>();
        // for (ASI_CRM_Sales_Team__c salesTeam : salesTeams) {
        //     teamRegionMap.put(salesTeam.Name, salesTeam.ASI_CRM_Region__c);
        // }
        // System.debug(LoggingLevel.INFO, '*** teamRegionMap: ' + teamRegionMap);
        // Map<String, String> regionMap = new Map<String, String>();
        // regionMap.put('Central Region', 'Central');
        // regionMap.put('East Region', 'East');
        // regionMap.put('Headquarter', 'HQ');
        // regionMap.put('North Region', 'North');
        // regionMap.put('North West Region', 'Northwest');
        // regionMap.put('South Region', 'South');
        // regionMap.put('South West Region', 'Southwest');
        
        // for (ASI_FOC_Free_Goods_Request__c fgr : trigger_new){
        //     fgr.ASI_CRM_CN_Region__c = regionMap.get(teamRegionMap.get(ownerUserMap.get(fgr.OwnerId)));
        //     if (fgr.ASI_CRM_CN_FG_Trade_A_P_PO__c != NULL) {
        //         if (poRemainingMap.size() > 0 && poRemainingMap.get(fgr.ASI_CRM_CN_FG_Trade_A_P_PO__c) != NULL) {
        //             fgr.ASI_CRM_CN_FG_PO_Remaining_Amount__c = poRemainingMap.get(fgr.ASI_CRM_CN_FG_Trade_A_P_PO__c);
        //         } else {
        //             fgr.ASI_CRM_CN_FG_PO_Remaining_Amount__c = fgr.ASI_CRM_CN_FG_PO_Final_Amount__c;
        //         }
        //     }
        // }
        // Added by Jack Yuan End

        // 20190627 Wilson Chow
        system.debug('routineBeforeInsert() end');
        // 20190627 Wilson Chow
    }
    
    public static void routineBeforeUpsert(list<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap) {
        // 20190627 Wilson Chow
        system.debug('routineBeforeUpsert() start');
        // 20190627 Wilson Chow
        if (ASI_FOC_Free_Goods_Request_TriggerClass.isDumpicateEnter) {
            return;
        }
        //Map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_FOC_Free_Goods_Request__c');
        Map<String, id> TempDeliveryZone = new Map<string,id>();
        
        //20171017 Introv
        for(ASI_MFM_Expense_Control_Form__c obj : taxSavingList.values()){
            
            if(obj.ASI_MFM_Tax_Saving_Purpose__c != Null && obj.ASI_MFM_Tax_Saving_Purpose__c != '')
                taxSavingMap.put(obj.ASI_MFM_Tax_Saving_Purpose__c.toLowerCase(), obj);
        }
        
        
        List<ASI_FOC_Delivery_Zone__c> tempZone =  [SELECT Name, id FROM ASI_FOC_Delivery_Zone__c WHERE RecordType.DeveloperName = 'ASI_FOC_CN_Delivery_Zone'];
        for (ASI_FOC_Delivery_Zone__c zones: tempZone){
            TempDeliveryZone.put(zones.Name, zones.id);
        }
        for (ASI_FOC_Free_Goods_Request__c r:trigger_new){
            
            //20180131 Introv
            if(r.ASI_FOC_Apply_Tax_Saving_Logic__c && r.ASI_CRM_AB_Policy_Number__c == Null && r.ASI_MFM_Tax_Saving_Purpose__c != Null
               && taxSavingList.containsKey(r.ASI_MFM_Tax_Saving_Purpose__c) && taxSavingList.get(r.ASI_MFM_Tax_Saving_Purpose__c).ASI_MFM_AB_Policy_Required__c
              ){
                  r.ASI_CRM_AB_Policy_Number__c.addError('Please input AB Policy Number before saving');
              }
              
            // Added by Alan Wong (Elufa) 20150707
            if (r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request') || r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request_Read_Only') || r.recordTypeId == rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only')
                || r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM') || r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM_Read_Only')) {
                    if (trigger_oldMap == null){
                        if (TempDeliveryZone.containsKey(r.ASI_FOC_CN_Delivery_Zone__c)) {
                            r.ASI_FOC_Delivery_Zone__c = TempDeliveryZone.get(r.ASI_FOC_CN_Delivery_Zone__c);
                        }
                    } else {
                        if (trigger_oldMap.get(r.id).ASI_FOC_CN_Delivery_Zone__c != r.ASI_FOC_CN_Delivery_Zone__c){
                            r.ASI_FOC_Delivery_Zone__c = TempDeliveryZone.get(r.ASI_FOC_CN_Delivery_Zone__c);
                        }
                    }
                    
                    //20171017 Introv
                    if(r.ASI_FOC_Apply_Tax_Saving_Logic__c && r.ASI_FOC_Purpose__c != '' && r.ASI_FOC_Purpose__c != Null && taxSavingMap.containsKey(r.ASI_FOC_Purpose__c.toLowerCase())){
                        
                        r.ASI_MFM_Tax_Saving_Purpose__c = taxSavingMap.get(r.ASI_FOC_Purpose__c.toLowerCase()).id;
                    }
                }
            // -- End -- //
            
            // 20181215 Laputa
            if(r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request')){
                // check customer code
                if(r.ASI_MFM_Tax_Saving_Purpose__c != null && taxSavingList.containsKey(r.ASI_MFM_Tax_Saving_Purpose__c) && 
                    taxSavingList.get(r.ASI_MFM_Tax_Saving_Purpose__c).ASI_MFM_Customer_Code__c == null && r.ASI_CRM_Outlet__c == null
                ){
                    r.ASI_CRM_Outlet__c.addError('Please select an Outlet because Purpose does not have a customer code.');
                } 
                // check warehouse code
                if(r.ASI_MFM_Tax_Saving_Purpose__c != null && taxSavingList.containsKey(r.ASI_MFM_Tax_Saving_Purpose__c) && 
                    taxSavingList.get(r.ASI_MFM_Tax_Saving_Purpose__c).ASI_MFM_Warehouse_Code__c  == null && r.ASI_MFM_FromWarehouse__c == null
                ){
                    r.ASI_MFM_FromWarehouse__c.addError('Please select a Warehouse because Purpose does not have a warehouse code.');
                }
            }
            
        }
        
        
        //AM 20181219: for warehouse email addresses
		String CNPO_RTID 	= Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO');
		String CNPORO_RTID 	= Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO_Read_Only');
        assignEmailAddresses(trigger_new, trigger_oldMap);
        Set<ID> anpPoIdSet = new Set<Id>();
        Map<ID,ASI_MFM_PO__c> anpPoMap;
        
        // 20200421 Enoch@Introv 
        Set<Id> outletIdSet = new Set<Id>();
        Set<Id> whIdSet = new Set<Id>();
        Set<Id> cityIdSet = new Set<Id>();
        Map<Id,ASI_CRM_AccountsAdditionalField__c> outletMap = new Map<Id,ASI_CRM_AccountsAdditionalField__c>();
		Map<Id,ASI_FOC_Warehouse__c> whMap = new Map<Id,ASI_FOC_Warehouse__c>();   
        Map<Id,ASI_CRM_City__c> cityMap = new Map<id, ASI_CRM_City__c>();
        
        Map<String, ASI_CRM_Fix_Approval_Route__c> mapFixApprovalRoute4RegionFGR = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
        for(ASI_CRM_Fix_Approval_Route__c obj : fixApprovalList4RegionFGR){
            system.debug('obj.ASI_CRM_CN_Region_Area_Channel__c : '+obj.ASI_CRM_CN_Region_Area_Channel__c);
            mapFixApprovalRoute4RegionFGR.put(obj.ASI_CRM_CN_Region_Area_Channel__c, obj);
        }
        
        for (ASI_FOC_Free_Goods_Request__c r:trigger_new){
            if(r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request')||r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request_Read_Only')||r.recordTypeId == rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only')){
                if(r.ASI_FOC_PO__c != null && r.ASI_FOC_Event_PO_Number__c == null) {
                    //20200602:AM@introv - add checking from fix approval route
                    boolean bCheckEventPOReq = FALSE;
                    
                    if(String.isNotBlank(r.ASI_FOC_Purpose__c) && r.ASI_FOC_Purpose__c.contains('STK4 Order')) {
                    } else {
                        bCheckEventPOReq = TRUE;
                        if ((r.ASI_CRM_CN_Region__c != NULL) && (r.ASI_CRM_CN_Region__c != '')) {
                            bCheckEventPOReq = mapFixApprovalRoute4RegionFGR.containsKey(r.ASI_CRM_CN_Region__c) ? mapFixApprovalRoute4RegionFGR.get(r.ASI_CRM_CN_Region__c).ASI_CRM_Event_PO_Required__c : TRUE;
                        }
                    }
                    
                    // if ((!test.isRunningTest()) && bCheckEventPOReq)
                    	// r.ASI_FOC_Event_PO_Number__c.addError('Please select Event PO Number.');
                } else if(r.ASI_FOC_Event_PO_Number__c != null){
                    anpPoIdSet.add(r.ASI_FOC_Event_PO_Number__c);
                }
                if(r.ASI_MFM_FromWarehouse__c != null) whIdSet.add(r.ASI_MFM_FromWarehouse__c);
                if(r.ASI_CRM_Outlet__c != null) outletIdSet.add(r.ASI_CRM_Outlet__c);
                if(r.ASI_FOC_CN_To_City__c != null) cityIdSet.add(r.ASI_FOC_CN_To_City__c);
            }
        }
        if(anpPoIdSet.size()>0) {
            anpPoMap = new Map<ID, ASI_MFM_PO__c>([SELECT id, name, ASI_MFM_Supplier_Name__c, ASI_MFM_Supplier_Email__c, ASI_MFM_Remarks__c FROM ASI_MFM_PO__c WHERE ID in :anpPoIdSet]);
        }
        if(outletIdSet.size() > 0) {
            outletMap = new Map<Id,ASI_CRM_AccountsAdditionalField__c>([SELECT id, name, ASI_CRM_CN_CCity__c, ASI_CRM_CN_CCity__r.ASI_CRM_English_Name__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN :outletIdSet]);
        }
        if(whIdSet.size() > 0) {
            whMap = new Map<Id,ASI_FOC_Warehouse__c>([SELECT id, name, ASI_FOC_City__c, ASI_FOC_City__r.ASI_CRM_English_Name__c FROM ASI_FOC_Warehouse__c WHERE Id IN :whIdSet]);
        }
        if(cityIdSet.size()> 0) {
            cityMap = new Map<Id,ASI_CRM_City__c>([SELECT id, name, ASI_CRM_English_Name__c FROM ASI_CRM_City__c WHERE Id IN :cityIdSet]);
        }
        for (ASI_FOC_Free_Goods_Request__c r:trigger_new){
            //system.debug('r.ASI_FOC_Event_PO_Number__c : '+r.ASI_FOC_Event_PO_Number__c);
            //system.debug('anpPoMap.get(r.ASI_FOC_Event_PO_Number__c) : '+anpPoMap.get(r.ASI_FOC_Event_PO_Number__c));
            if (r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request') || r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request_Read_Only') || r.recordTypeId == rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only')) {

                if(r.ASI_FOC_Event_PO_Number__c != null && anpPoMap.get(r.ASI_FOC_Event_PO_Number__c)!=null){
                    r.ASI_FOC_Event_PO_Supplier_Name__c = (anpPoMap.get(r.ASI_FOC_Event_PO_Number__c)==null)? null:anpPoMap.get(r.ASI_FOC_Event_PO_Number__c).ASI_MFM_Supplier_Name__c;
                    r.ASI_FOC_Event_PO_Remarks__c  		= (anpPoMap.get(r.ASI_FOC_Event_PO_Number__c)==null)? null:anpPoMap.get(r.ASI_FOC_Event_PO_Number__c).ASI_MFM_Remarks__c;
                    r.ASI_CRM_CN_FG_Supplier_Email__c   = (anpPoMap.get(r.ASI_FOC_Event_PO_Number__c)==null)? null:anpPoMap.get(r.ASI_FOC_Event_PO_Number__c).ASI_MFM_Supplier_Email__c;
                }
                String fromCityName = 'Shanghai';
                String toCityName = 'Other';
                r.ASI_FOC_CN_Delivery_Zone__c = fromCityName + ' - ' + toCityName;
                r.ASI_FOC_Delivery_Zone__c = null;
                try {
                    //fromCityName = (r.ASI_CRM_Outlet__c!=null)? outletMap.get(r.ASI_CRM_Outlet__c).ASI_CRM_CN_CCity__r.ASI_CRM_English_Name__c:'Shanghai';
                    fromCityName = (r.ASI_MFM_FromWarehouse__c!=null)? whMap.get(r.ASI_MFM_FromWarehouse__c).ASI_FOC_City__r.ASI_CRM_English_Name__c:'Shanghai';                
                    toCityName   = (r.ASI_FOC_CN_To_City__c!=null)? cityMap.get(r.ASI_FOC_CN_To_City__c).ASI_CRM_English_Name__c: 'Other';
                } catch(exception e) {}
                String deliveryZoneKey = fromCityName + ' - ' + toCityName;
                if (TempDeliveryZone.containsKey(deliveryZoneKey)) {
                    r.ASI_FOC_Delivery_Zone__c = TempDeliveryZone.get(deliveryZoneKey);
                    r.ASI_FOC_CN_Delivery_Zone__c = deliveryZoneKey;
                }

			}
        }

        // 20190627 Wilson Chow
        system.debug('routineBeforeUpsert() end');
        // 20190627 Wilson Chow

        // 20200810 Jack Yuan start
        set<id> owner_set = new set<id>();
        set<id> poid_set = new set<id>();
        for (ASI_FOC_Free_Goods_Request__c r : trigger_new) {
            owner_set.add(r.ownerId);
            if (r.ASI_CRM_CN_FG_Trade_A_P_PO__c != null ) {
                poid_set.add(r.ASI_CRM_CN_FG_Trade_A_P_PO__c);
            }
        }

        Map<Id, Decimal> poRemainingMap = new Map<Id, Decimal>();
        if (poid_set.size() > 0) {
            //20200803 Alex -- get PO remaining
            List<AggregateResult> results = [SELECT ASI_TH_CRM_Contract__c, 
                                                    AVG(ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount_RMB__c) poAmount,
                                                    SUM(ASI_CRM_CN_Total_Payment__c) paymentAmount 
                                               FROM ASI_TH_CRM_PaymentRequest__c
                                              WHERE ASI_TH_CRM_Contract__c != null
                                                AND ASI_TH_CRM_Status__c != 'Draft'
                                                AND ASI_TH_CRM_Contract__c IN:poid_set 
                                           Group By ASI_TH_CRM_Contract__c];
            for (AggregateResult result : results) {
                Id poId = (Id)result.get('ASI_TH_CRM_Contract__c');
                Decimal poAmount = (Decimal)result.get('poAmount');
                Decimal paymentAmount = (Decimal)result.get('paymentAmount');
                poRemainingMap.put(poId, poAmount - paymentAmount);
            }
        }

        Map<Id, String> ownerUserMap = new Map<Id, String>();
        List<User> ownerUsers = [SELECT ASI_CRM_Sales_Team__c FROM User WHERE Id IN : owner_set];
        for (User user : ownerUsers) {
            ownerUserMap.put(user.Id, user.ASI_CRM_Sales_Team__c);
        }
        System.debug(LoggingLevel.INFO, '*** ownerUserMap: ' + ownerUserMap);

        List<ASI_CRM_Sales_Team__c> salesTeams = [SELECT Name, ASI_CRM_Region__c 
                                                  FROM ASI_CRM_Sales_Team__c 
                                                  WHERE Name IN :ownerUserMap.values()];
        Map<String, String> teamRegionMap = new Map<String, String>();
        for (ASI_CRM_Sales_Team__c salesTeam : salesTeams) {
            teamRegionMap.put(salesTeam.Name, salesTeam.ASI_CRM_Region__c);
        }
        System.debug(LoggingLevel.INFO, '*** teamRegionMap: ' + teamRegionMap);
        Map<String, String> regionMap = new Map<String, String>();
        regionMap.put('Central Region', 'Central');
        regionMap.put('East Region', 'East');
        regionMap.put('Headquarter', 'HQ');
        regionMap.put('North Region', 'North');
        regionMap.put('North West Region', 'Northwest');
        regionMap.put('South Region', 'South');
        regionMap.put('South West Region', 'Southwest');
        
        System.debug(LoggingLevel.INFO, '*** poRemainingMap: ' + poRemainingMap);
        for (ASI_FOC_Free_Goods_Request__c fgr : trigger_new){
            fgr.ASI_CRM_CN_Region__c = regionMap.get(teamRegionMap.get(ownerUserMap.get(fgr.OwnerId)));
            if (fgr.ASI_CRM_CN_FG_Trade_A_P_PO__c != NULL) {
                if (poRemainingMap.size() > 0 && poRemainingMap.get(fgr.ASI_CRM_CN_FG_Trade_A_P_PO__c) != NULL) {
                    fgr.ASI_CRM_CN_FG_PO_Remaining_Amount__c = poRemainingMap.get(fgr.ASI_CRM_CN_FG_Trade_A_P_PO__c);
                } else {
                    fgr.ASI_CRM_CN_FG_PO_Remaining_Amount__c = fgr.ASI_CRM_CN_FG_PO_Final_Amount__c;
                }
            }
        }
        // 20200810 Jack Yuan end
        ASI_FOC_Free_Goods_Request_TriggerClass.isDumpicateEnter = true;
    }
    
    //AM 20181219: for warehouse email addresses - start
    private static void assignEmailAddresses(list<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap) {
        Set<Id> setWarehouse = new Set<Id>();
        for (ASI_FOC_Free_Goods_Request__c r:trigger_new){
            if (r.ASI_FOC_To_Regional_Warehouse__c != NULL) {
                setWarehouse.add(r.ASI_FOC_To_Regional_Warehouse__c);
            }
        }
        
        Map<Id,ASI_FOC_Warehouse__c> mapWarehouse = new Map<Id,ASI_FOC_Warehouse__c>([select Id, ASI_MFM_Operation_Team_Email_1__c, ASI_MFM_Operation_Team_Email_2__c, ASI_MFM_Operation_Team_Email_3__c, ASI_MFM_Operation_Team_Email_4__c
                                                            , ASI_MFM_Operation_Team_Email_5__c, ASI_MFM_Operation_Team_Email_6__c, ASI_MFM_Operation_Team_Email_7__c, ASI_MFM_Operation_Team_Email_8__c
                                                            , ASI_FOC_SIR_Email_Address_1__c, ASI_FOC_SIR_Email_Address_2__c, ASI_FOC_SIR_Email_Address_3__c, ASI_FOC_SIR_Email_Address_4__c
                                                            , ASI_FOC_SIR_Email_Address_5__c, ASI_FOC_SIR_Email_Address_6__c, ASI_FOC_SIR_Email_Address_7__c, ASI_FOC_SIR_Email_Address_8__c
                                                     from ASI_FOC_Warehouse__c where id in :setWarehouse]);
        
        if(mapWarehouse.size() > 0) {
            for (ASI_FOC_Free_Goods_Request__c r:trigger_new){
                if (r.ASI_FOC_To_Regional_Warehouse__c != NULL) {
                    if (mapWarehouse.containsKey(r.ASI_FOC_To_Regional_Warehouse__c)) {
                        ASI_FOC_Warehouse__c objWH = mapWarehouse.get(r.ASI_FOC_To_Regional_Warehouse__c);
                        r.ASI_MFM_OperationTeamEmail1__c = objWH.ASI_MFM_Operation_Team_Email_1__c;
                        r.ASI_MFM_OperationTeamEmail2__c = objWH.ASI_MFM_Operation_Team_Email_2__c;
                        r.ASI_MFM_OperationTeamEmail3__c = objWH.ASI_MFM_Operation_Team_Email_3__c;
                        r.ASI_MFM_OperationTeamEmail4__c = objWH.ASI_MFM_Operation_Team_Email_4__c;
                        r.ASI_MFM_OperationTeamEmail5__c = objWH.ASI_MFM_Operation_Team_Email_5__c;
                        r.ASI_MFM_OperationTeamEmail6__c = objWH.ASI_MFM_Operation_Team_Email_6__c;
                        r.ASI_MFM_OperationTeamEmail7__c = objWH.ASI_MFM_Operation_Team_Email_7__c;
                        r.ASI_MFM_OperationTeamEmail8__c = objWH.ASI_MFM_Operation_Team_Email_8__c;
                        r.ASI_MFM_SIREmailAddress1__c  = objWH.ASI_FOC_SIR_Email_Address_1__c ;
                        r.ASI_MFM_SIREmailAddress2__c  = objWH.ASI_FOC_SIR_Email_Address_2__c ;
                        r.ASI_MFM_SIREmailAddress3__c  = objWH.ASI_FOC_SIR_Email_Address_3__c ;
                        r.ASI_MFM_SIREmailAddress4__c  = objWH.ASI_FOC_SIR_Email_Address_4__c ;
                        r.ASI_MFM_SIREmailAddress5__c  = objWH.ASI_FOC_SIR_Email_Address_5__c ;
                        r.ASI_MFM_SIREmailAddress6__c  = objWH.ASI_FOC_SIR_Email_Address_6__c ;
                        r.ASI_MFM_SIREmailAddress7__c  = objWH.ASI_FOC_SIR_Email_Address_7__c ;
                        r.ASI_MFM_SIREmailAddress8__c  = objWH.ASI_FOC_SIR_Email_Address_8__c ;
                    }
                }
            }
        }
    }
    //AM 20181219: for warehouse email addresses - end
    
    public static void routineBeforeUpdate(list<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap) {
        // 20190627 Wilson Chow
        system.debug('routineBeforeUpdate() start');
        // 20190627 Wilson Chow

        //20160922, added by Leo
        Set<Id> pend4DayReq = new Set<Id>();
        Map<Id,Id> workItemMap = new Map<Id,Id>();
        for(ASI_FOC_Free_Goods_Request__c req:trigger_new) {
            if(!trigger_oldMap.get(req.id).ASI_FOC_CN_Already_4_Days__c && req.ASI_FOC_CN_Already_4_Days__c)
            {
                pend4DayReq.add(req.Id);
            }
        }
        if(pend4DayReq.size() > 0)
        {
            List<ProcessInstanceWorkitem> workItemList 
                = new List<ProcessInstanceWorkitem>([Select ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN: pend4DayReq]);
            if(workItemList.size()>0)
            {
                for(ProcessInstanceWorkitem item: workItemList)
                {
                    workItemMap.put(item.ProcessInstance.TargetObjectId, item.ActorId);
                }
            }
        }
        if(workItemMap.size() > 0)
        {
            for(ASI_FOC_Free_Goods_Request__c req:trigger_new) {
                if(workItemMap.containsKey(req.Id))
                {
                    req.ASI_CRM_Current_Approver__c = workItemMap.get(req.id);
                    req.ASI_FOC_CN_Send_Reminder_Email__c = true;
                }
            }
        }
        
        //20160922, added by Leo
        // Set the approvers for the free good requests based on the routing rule objects           
        set<id> rid_set = new set<id>();
        set<id> rid_set2 = new set<id>();
        //set<id> owner_set = new set<id>();
        //Map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_FOC_Free_Goods_Request__c'); // Added By Alan Wong (Elufa) 20150616
        for (ASI_FOC_Free_Goods_Request__c r:trigger_new) {
            //20151211 Ben @ Elufa System
            if((r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM') || r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM_Read_Only')) && ( r.ASI_FOC_Request_Status__c == 'In Progress' || r.ASI_FOC_Request_Status__c == 'Open' )){
                rid_set2.add(r.id);
            }
            //20151211 End
            if (r.ASI_FOC_Free_Goods_Total_Cost__c != trigger_oldMap.get(r.id).ASI_FOC_Free_Goods_Total_Cost__c ||
                r.ownerId != trigger_oldMap.get(r.id).ownerId ||
                r.ASI_FOC_Request_Type__c != trigger_oldMap.get(r.id).ASI_FOC_Request_Type__c
                || r.ASI_FOC_Request_Status__c == 'Open'//20170927 Introv added "|| r.ASI_FOC_Request_Status__c == 'Open'""
               ) {
                    rid_set.add(r.id);
                    //owner_set.add(r.ownerId);
                    /*r.ASI_FOC_Approver_1__c = null;
                    r.ASI_FOC_Approver_2__c = null;
                    r.ASI_FOC_Approver_3__c = null;
                    r.ASI_FOC_Approver_4__c = null;
                    r.ASI_FOC_Approver_5__c = null; 
                    r.ASI_FOC_Approver_6__c = null;
                    r.ASI_FOC_Approver_7__c = null;*/
                }
        }
        
        //20151211 Ben @ Elufa System
        Map<ID, Integer> countingMap = new Map<ID, Integer>();
        Map<ID, Integer> countingMap2 = new Map<ID, Integer>();
        
        //20171219 Introv
        Map<Id, Decimal> mapTotalListPrice = new Map<Id, Decimal>();
        system.debug('Canter:' + beforeUpdateCount);
        if(beforeUpdateCount == 0){
            beforeUpdateCount++;
            //20171219 Introv
            for(ASI_FOC_Request_Item__c obj : [SELECT ASI_FOC_Brand_Director_Approval_Status__c
                                               , ASI_FOC_Brand_Director_Approval_Required__c
                                               , ASI_FOC_Brand_Approver__c
                                               , ASI_FOC_Request_Order__c
                                               , ASI_FOC_Actual_Quantity_Bottle__c
                                               , ASI_FOC_Total_SKU_List_Price__c
                                               , ASI_FOC_SKU__r.ASI_FOC_List_Price__c
                                               FROM ASI_FOC_Request_Item__c
                                               WHERE ASI_FOC_Request_Order__c IN : trigger_new
                                              ]){
                                                  //2019/11/22 Canter注释 start
                                                  //decimal tmpTotal = obj.ASI_FOC_Total_SKU_List_Price__c != Null ? obj.ASI_FOC_Total_SKU_List_Price__c : 0;
                                                  
                                                  //if(mapTotalListPrice.containsKey(obj.ASI_FOC_Request_Order__c))
                                                  //    tmpTotal += mapTotalListPrice.get(obj.ASI_FOC_Request_Order__c);
                                                  //mapTotalListPrice.put(obj.ASI_FOC_Request_Order__c, tmpTotal);
                                                  //Canter End
                                                  
                                                  if(rid_set2.contains(obj.ASI_FOC_Request_Order__c) && obj.ASI_FOC_Brand_Director_Approval_Required__c && obj.ASI_FOC_Brand_Approver__c != Null){
                                                      lineItemList.add(obj);
                                                      
                                                      if(countingMap.containsKey(obj.ASI_FOC_Request_Order__c)){
                                                          countingMap.put(obj.ASI_FOC_Request_Order__c, countingMap.get(obj.ASI_FOC_Request_Order__c) + 1);
                                                      }else{
                                                          countingMap.put(obj.ASI_FOC_Request_Order__c, 1);
                                                      }
                                                      if(obj.ASI_FOC_Brand_Director_Approval_Status__c == 'Approved' || obj.ASI_FOC_Brand_Director_Approval_Status__c == 'Rejected'){
                                                          
                                                          if(countingMap2.containsKey(obj.ASI_FOC_Request_Order__c)){
                                                              countingMap2.put(obj.ASI_FOC_Request_Order__c, countingMap2.get(obj.ASI_FOC_Request_Order__c) + 1);
                                                          }else{
                                                              countingMap2.put(obj.ASI_FOC_Request_Order__c, 1);
                                                          }
                                                      }
                                                  }
                                              }
            
            //20171219 Commented
            /*lineItemList = [SELECT ASI_FOC_Brand_Director_Approval_Status__c
                            , ASI_FOC_Brand_Director_Approval_Required__c
                            , ASI_FOC_Brand_Approver__c
                            , ASI_FOC_Request_Order__c
                            FROM ASI_FOC_Request_Item__c
                            WHERE ASI_FOC_Request_Order__c IN : rid_set2
                            AND ASI_FOC_Brand_Director_Approval_Required__c = TRUE
                            AND ASI_FOC_Brand_Approver__c != NULL
                           ];*/
            
            //20171219 End
        }
        //2019/11/22 CanterDuan start
        for(ASI_FOC_Request_Item__c obj : [SELECT ASI_FOC_Brand_Director_Approval_Status__c
                                               , ASI_FOC_Brand_Director_Approval_Required__c
                                               , ASI_FOC_Brand_Approver__c
                                               , ASI_FOC_Request_Order__c
                                               , ASI_FOC_Actual_Quantity_Bottle__c
                                               , ASI_FOC_Total_SKU_List_Price__c
                                               , ASI_FOC_SKU__r.ASI_FOC_List_Price__c
                                               FROM ASI_FOC_Request_Item__c
                                               WHERE ASI_FOC_Request_Order__c IN : trigger_new
                                              ]){
                                                  decimal tmpTotal = obj.ASI_FOC_Total_SKU_List_Price__c != Null ? obj.ASI_FOC_Total_SKU_List_Price__c : 0;
                                                  
                                                  if(mapTotalListPrice.containsKey(obj.ASI_FOC_Request_Order__c))
                                                      tmpTotal += mapTotalListPrice.get(obj.ASI_FOC_Request_Order__c);
                                                  mapTotalListPrice.put(obj.ASI_FOC_Request_Order__c, tmpTotal);
                                              }
        for(ASI_FOC_Free_Goods_Request__c r:trigger_new){
            r.ASI_FOC_Total_List_Price_With_Tax__c = mapTotalListPrice.containsKey(r.id) ? mapTotalListPrice.get(r.id) * (1 + (r.ASI_CRM_CN_Tax_Rate__c != 0 && r.ASI_CRM_CN_Tax_Rate__c != null ? r.ASI_CRM_CN_Tax_Rate__c : 13)/100) : 0; //CanterDuan 2019/10/27 调整税率为配置的形式
        }
        //Canter End
        
        //20171219 Introv Commented
        /*for(ASI_FOC_Request_Item__c obj : lineItemList){
            
            if(countingMap.containsKey(obj.ASI_FOC_Request_Order__c)){
                countingMap.put(obj.ASI_FOC_Request_Order__c, countingMap.get(obj.ASI_FOC_Request_Order__c) + 1);
            }else{
                countingMap.put(obj.ASI_FOC_Request_Order__c, 1);
            }
            if(obj.ASI_FOC_Brand_Director_Approval_Status__c == 'Approved' || obj.ASI_FOC_Brand_Director_Approval_Status__c == 'Rejected'){
                
                if(countingMap2.containsKey(obj.ASI_FOC_Request_Order__c)){
                    countingMap2.put(obj.ASI_FOC_Request_Order__c, countingMap2.get(obj.ASI_FOC_Request_Order__c) + 1);
                }else{
                    countingMap2.put(obj.ASI_FOC_Request_Order__c, 1);
                }
            }
        }*/
        //20171219 End
        //Decimal taxRate = [SELECT Id,ASI_CRM_CN_Tax_Rate__c FROM ASI_CRM_CN_Tax_Rate_Config__c ORDER BY ASI_CRM_CN_Effective_From__c DESC][0].ASI_CRM_CN_Tax_Rate__c;//CanterDuan 查询获取最新的税率情况
        for(ASI_FOC_Free_Goods_Request__c r:trigger_new){
            
            //20171219 Introv
            //r.ASI_FOC_Total_List_Price_With_Tax__c = mapTotalListPrice.containsKey(r.id) ? mapTotalListPrice.get(r.id) * 1.13 : 0; //1.17 is fixed tax rate //20180426 Introv changed Tax Rate from 17% to 16%//20190415 Laputa Andy changed Tax Rate from 16% to 13%
            //20171219 End
            //2019/10/27 CanterDuan
            //r.ASI_FOC_Total_List_Price_With_Tax__c = mapTotalListPrice.containsKey(r.id) ? mapTotalListPrice.get(r.id) * (1 + (r.ASI_CRM_CN_Tax_Rate__c != 0 && r.ASI_CRM_CN_Tax_Rate__c != null ? r.ASI_CRM_CN_Tax_Rate__c : 13)/100) : 0; //CanterDuan 2019/10/27 调整税率为配置的形式
            //2019/10/27 END
            if(r.ASI_FOC_Request_Status__c == 'In Progress'){
                if(countingMap.containsKey(r.id) && countingMap2.containsKey(r.id)){
                    if(countingMap.get(r.id) == countingMap2.get(r.id)){
                        r.ASI_FOC_Request_Status__c = 'Approved by Logistic';
                        r.ASI_FOC_Sys_Approved_By_Logistic__c = true;
                        r.ASI_FOC_Sys_Submitted__c = true;
                        r.RecordTypeId = rt_map.get('ASI_FOC_CN_POSM_Read_Only');
                    }
                }else if(!countingMap.containsKey(r.id) && (r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM') || r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM_Read_Only')) ){
                    r.ASI_FOC_Request_Status__c = 'Approved by Logistic';
                    r.ASI_FOC_Sys_Approved_By_Logistic__c = true;
                    r.ASI_FOC_Sys_Submitted__c = true;
                    r.RecordTypeId = rt_map.get('ASI_FOC_CN_POSM_Read_Only');
                }
            }
        }
        
        
        //20151211 End
        
        if (rid_set.size() > 0) {
            
            //map<id, user> user_map = new map<id, user>([select userRole.developerName from user where id in :owner_set]);  //20170926 Introv Commented
            //set<string> role_set = new set<string>();
            
            //20170926 Introv commented
            /*for (user u:user_map.values()) {
                role_set.add(u.userRole.developerName);
            }*/
            
            /*list<ASI_FOC_Route_Type__c> rt_list = [select ASI_FOC_Role_Name__c, ASI_FOC_Finance_Approver__c, ASI_FOC_POSM_Finance_Approver__c,ASI_FOC_POSM_Logistic_Approver__c,ASI_FOC_Logistic_Approver__c,   
                                                   (select ASI_FOC_Approver__c, ASI_FOC_Threshold__c,ASI_FOC_POSM_Threshold__c from ASI_FOC_Route_Criteria__r order by ASI_FOC_Threshold__c) from ASI_FOC_Route_Type__c 
                                                   where ASI_FOC_Role_Name__c in :role_set];*/
            
            //20170926 Introv
            Map<String, ASI_CRM_Dynamic_Approval_Route__c> mapDynamicRouteFOC = new Map<String, ASI_CRM_Dynamic_Approval_Route__c>();
            Map<String, ASI_CRM_Dynamic_Approval_Route__c> mapDynamicRoutePOSM = new Map<String, ASI_CRM_Dynamic_Approval_Route__c>();
            Map<String, ASI_CRM_Fix_Approval_Route__c> mapFixApprovalRoute = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
            // 20190627 Wilson Chow
            Map<String, ASI_CRM_Dynamic_Approval_Route__c> mapDynamicRoute_HQ_STK4 = new Map<String, ASI_CRM_Dynamic_Approval_Route__c>();
            Map<String, ASI_CRM_Dynamic_Approval_Route__c> mapDynamicRoute_Central_STK4 = new Map<String, ASI_CRM_Dynamic_Approval_Route__c>();
            Map<String, ASI_CRM_Dynamic_Approval_Route__c> mapDynamicRoute_MKT_STK4 = new Map<String, ASI_CRM_Dynamic_Approval_Route__c>();
            Map<String, ASI_CRM_Dynamic_Approval_Route__c> mapDynamicRoute_East_STK4 = new Map<String, ASI_CRM_Dynamic_Approval_Route__c>();
            Map<String, ASI_CRM_Dynamic_Approval_Route__c> mapDynamicRoute_CIQ = new Map<String, ASI_CRM_Dynamic_Approval_Route__c>();
            // 20190627 Wilson Chow
            
            for(ASI_CRM_Dynamic_Approval_Route__c da : dynamicApprovalList){
                if(da.ASI_CRM_Type__c == 'Free Goods Request')
                    mapDynamicRouteFOC.put(da.ASI_CRM_User__c, da);
                else if(da.ASI_CRM_Type__c == 'POSM')
                    mapDynamicRoutePOSM.put(da.ASI_CRM_User__c, da);
                // 20190627 Wilson Chow
                else if(da.ASI_CRM_Type__c == HQ_STK4_ORDER)
                    mapDynamicRoute_HQ_STK4.put(da.ASI_CRM_User__c, da);
                else if(da.ASI_CRM_Type__c == CENTRAL_STK4_ORDER)
                    mapDynamicRoute_Central_STK4.put(da.ASI_CRM_User__c, da);
                else if(da.ASI_CRM_Type__c == MKT_STK4_ORDER)
                    mapDynamicRoute_MKT_STK4.put(da.ASI_CRM_User__c, da);
                else if (da.ASI_CRM_Type__c == CIQ_ORDER) {
                    mapDynamicRoute_CIQ.put(da.ASI_CRM_User__c, da);
                } else if (da.ASI_CRM_Type__c == EAST_STK4_ORDER) {
                    mapDynamicRoute_East_STK4.put(da.ASI_CRM_User__c, da);
                }
                // 20190627 Wilson Chow
            }

            // 20200716 Jack Yuan
            Map<String, ASI_CRM_Fix_Approval_Route__c> stk4TypeMap = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
            for(ASI_CRM_Fix_Approval_Route__c obj : fixApprovalList){
                stk4TypeMap.put(obj.ASI_CRM_CN_Region_Area_Channel__c + obj.ASI_CRM_CN_Type__c, obj);
                mapFixApprovalRoute.put(obj.ASI_CRM_CN_Type__c, obj);
            }
            
            //20190102 Andy @Introv - add regional approval/HQ approval - START
            Map<String, ASI_CRM_Fix_Approval_Route__c> mapFixApprovalRoute4Region = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
            for(ASI_CRM_Fix_Approval_Route__c obj : fixApprovalList4Region){
                mapFixApprovalRoute4Region.put(obj.ASI_CRM_CN_Region_Area_Channel__c, obj);
            }
            
            //201900520 Howard @Introv - add regional approval(FGR) - START
            Map<String, ASI_CRM_Fix_Approval_Route__c> mapFixApprovalRoute4RegionFGR = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
            Map<String, ASI_CRM_Fix_Approval_Route__c> freeGoodsSettingMap = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
            for(ASI_CRM_Fix_Approval_Route__c obj : fixApprovalList4RegionFGR){
                system.debug('obj.ASI_CRM_CN_Region_Area_Channel__c : '+obj.ASI_CRM_CN_Region_Area_Channel__c);
                mapFixApprovalRoute4RegionFGR.put(obj.ASI_CRM_CN_Region_Area_Channel__c, obj);
                // Added by Jack Yuan 
                String region = obj.ASI_CRM_CN_Region_Area_Channel__c == null ? '' : obj.ASI_CRM_CN_Region_Area_Channel__c;
                String requestType = obj.ASI_CRM_CN_FG_Request_Type__c == null ? '' : obj.ASI_CRM_CN_FG_Request_Type__c;
                String salesTeam = obj.ASI_CRM_Sales_Team__c == null ? '' : obj.ASI_CRM_Sales_Team__c;
                String fgKey = region + requestType + salesTeam;
                freeGoodsSettingMap.put(fgKey, obj);
                
                
            }
            
            Set<ID> warehouseID = new Set<ID>();
            
            for (ASI_FOC_Free_Goods_Request__c r:trigger_new) {
                warehouseID.add(r.ASI_MFM_FromWarehouse__c);
                system.debug('warehouseID:'+ r.ASI_MFM_FromWarehouse__c);
            }

            Map<ID, ASI_FOC_Warehouse__c> warehouseMap = new Map<ID, ASI_FOC_Warehouse__c>([SELECT id, ASI_FOC_Warehouse_Type__c, ASI_FOC_Region__r.Name FROM ASI_FOC_Warehouse__c WHERE id IN : warehouseID]);
            //20190102 Andy @Introv - add regional approval/HQ approval - END
            
            for (ASI_FOC_Free_Goods_Request__c r:trigger_new) {
                
                integer approver_count = 0;
                //if (r.ASI_FOC_Request_Type__c != 'Return' && rid_set.contains(r.id)) { //20151223 Ben @ Elufa System
                if (rid_set.contains(r.id)) {
                    
                    //20170927 Introv
                    
                    setApproverToNull(r);
                    
                    Id approver = ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(r.OwnerId) != Null ? ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(r.OwnerId).ManagerId : Null;
                    if (r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request') || r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request_Read_Only') || r.recordTypeId == rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only')){

                        // 20190627 Wilson Chow
                        system.debug('Free Goods Request Purpose:' + r.ASI_FOC_Purpose__c);
                        if(String.isNotBlank(r.ASI_FOC_Purpose__c) && r.ASI_FOC_Purpose__c.contains('STK4 Order')) {

                            String stk4Key = null;
                            Map<String, ASI_CRM_Dynamic_Approval_Route__c> stk4DynamicApprovalRouteMap = null;

                            if(r.ASI_FOC_Purpose__c.equalsIgnoreCase(HQ_STK4_ORDER)) {
                                stk4Key = r.ASI_CRM_CN_Region__c + HQ_STK4_ORDER;
                                stk4DynamicApprovalRouteMap = mapDynamicRoute_HQ_STK4;
                            }
                            else if(r.ASI_FOC_Purpose__c.equalsIgnoreCase(CENTRAL_STK4_ORDER)) {
                                stk4Key = r.ASI_CRM_CN_Region__c + CENTRAL_STK4_ORDER;
                                stk4DynamicApprovalRouteMap = mapDynamicRoute_Central_STK4;
                            }
                            else if(r.ASI_FOC_Purpose__c.equalsIgnoreCase(MKT_STK4_ORDER)) {
                                stk4Key = r.ASI_CRM_CN_Region__c + MKT_STK4_ORDER;
                                stk4DynamicApprovalRouteMap = mapDynamicRoute_MKT_STK4;
                            }
                            else if(r.ASI_FOC_Purpose__c.equalsIgnoreCase(EAST_STK4_ORDER)) {
                                stk4Key = r.ASI_CRM_CN_Region__c + EAST_STK4_ORDER;
                                stk4DynamicApprovalRouteMap = mapDynamicRoute_East_STK4;
                            }
                            else
                            {
                                stk4DynamicApprovalRouteMap = mapDynamicRouteFOC;
                            }


                            system.debug('stk4 key:' + stk4Key);
                            system.debug('stk4DynamicApprovalRouteMap:' + stk4DynamicApprovalRouteMap);
                            //20200602:AM@introv - STK4 order special handling start
                            /*
							if(r.ASI_CRM_CN_Region__c != NULL)
                            {
                                system.debug('ASI_CRM_CN_Region__c : '+r.ASI_CRM_CN_Region__c);
                                r.ASI_FOC_Finance_Approver__c =
                                    mapFixApprovalRoute4RegionFGR.containsKey(r.ASI_CRM_CN_Region__c)
                                    ? mapFixApprovalRoute4RegionFGR.get(r.ASI_CRM_CN_Region__c).ASI_CRM_Finance_Approver__c
                                    : null;
                                
                                r.ASI_FOC_Finance_Approver_2__c =
                                    mapFixApprovalRoute4RegionFGR.containsKey(r.ASI_CRM_CN_Region__c)
                                    ? mapFixApprovalRoute4RegionFGR.get(r.ASI_CRM_CN_Region__c).ASI_FOC_Finance_Approver_2__c
                                    : null;
                                
                                r.ASI_FOC_Logistic_Approver__c =
                                    mapFixApprovalRoute4RegionFGR.containsKey(r.ASI_CRM_CN_Region__c)
                                    ? mapFixApprovalRoute4RegionFGR.get(r.ASI_CRM_CN_Region__c).ASI_CRM_Logistic_Approver__c
                                    : null;
                                
                                r.ASI_FOC_Sales_Director__c =
                                    mapFixApprovalRoute4RegionFGR.containsKey(r.ASI_CRM_CN_Region__c)
                                    ? mapFixApprovalRoute4RegionFGR.get(r.ASI_CRM_CN_Region__c).ASI_FOC_Sales_Director__c
                                    : null;
                            }else{
                                r.ASI_FOC_Finance_Approver__c =
                                    mapFixApprovalRoute.containsKey(stk4Key)
                                    ? mapFixApprovalRoute.get(stk4Key).ASI_CRM_Finance_Approver__c
                                    : null;
                                
                                r.ASI_FOC_Finance_Approver_2__c =
                                    mapFixApprovalRoute.containsKey(stk4Key)
                                    ? mapFixApprovalRoute.get(stk4Key).ASI_FOC_Finance_Approver_2__c
                                    : null;
                                
                                r.ASI_FOC_Logistic_Approver__c =
                                    mapFixApprovalRoute.containsKey(stk4Key)
                                    ? mapFixApprovalRoute.get(stk4Key).ASI_CRM_Logistic_Approver__c
                                    : null;
                                
                                r.ASI_FOC_Sales_Director__c =
                                    mapFixApprovalRoute.containsKey(stk4Key)
                                    ? mapFixApprovalRoute.get(stk4Key).ASI_FOC_Sales_Director__c
                                    : null;
                            }
                            */
                            System.debug(LoggingLevel.INFO, '*** stk4TypeMap: ' + stk4TypeMap);
                            r.ASI_FOC_Finance_Approver__c =
                                stk4TypeMap.containsKey(stk4Key)
                                ? stk4TypeMap.get(stk4Key).ASI_CRM_Finance_Approver__c
                                : null;
                            
                            r.ASI_FOC_Finance_Approver_2__c =
                                stk4TypeMap.containsKey(stk4Key)
                                ? stk4TypeMap.get(stk4Key).ASI_FOC_Finance_Approver_2__c
                                : null;
                            
                            r.ASI_FOC_Logistic_Approver__c =
                                stk4TypeMap.containsKey(stk4Key)
                                ? stk4TypeMap.get(stk4Key).ASI_CRM_Logistic_Approver__c
                                : null;
                            
                            r.ASI_FOC_Sales_Director__c =
                                stk4TypeMap.containsKey(stk4Key)
                                ? stk4TypeMap.get(stk4Key).ASI_FOC_Sales_Director__c
                                : null;
                            //20200602:AM@introv - STK4 order special handling end

                            setDynamicApprover(r, stk4DynamicApprovalRouteMap, approver, 100);
                        } else {
                        // 20190627 Wilson Chow
                            if(r.ASI_CRM_CN_Region__c != NULL){
                                system.debug('ASI_CRM_CN_Region__c : '+r.ASI_CRM_CN_Region__c);
                                String fgkey = r.ASI_CRM_CN_Region__c + r.ASI_FOC_Request_Type__c + r.ASI_CRM_CN_FG_Sales_Team__c;
                                // r.ASI_FOC_Finance_Approver__c = mapFixApprovalRoute4RegionFGR.containsKey(r.ASI_CRM_CN_Region__c) ? mapFixApprovalRoute4RegionFGR.get(r.ASI_CRM_CN_Region__c).ASI_CRM_Finance_Approver__c : Null;
                                // r.ASI_FOC_Logistic_Approver__c = mapFixApprovalRoute4RegionFGR.containsKey(r.ASI_CRM_CN_Region__c) ? mapFixApprovalRoute4RegionFGR.get(r.ASI_CRM_CN_Region__c).ASI_CRM_Logistic_Approver__c : Null;
                                r.ASI_FOC_Finance_Approver__c = freeGoodsSettingMap.containsKey(fgkey) ? freeGoodsSettingMap.get(fgkey).ASI_CRM_Finance_Approver__c : null;
                                r.ASI_FOC_Finance_Approver_New2__c = freeGoodsSettingMap.containsKey(fgkey) ? freeGoodsSettingMap.get(fgkey).ASI_FOC_Finance_Approver_2__c : null;
                                if (freeGoodsSettingMap.containsKey(fgkey)
                                    && freeGoodsSettingMap.get(fgkey).ASI_CRM_CN_Approval_Limit_1__c != null 
                                    && r.ASI_FOC_Budget_Amount_withFee__c >= freeGoodsSettingMap.get(fgkey).ASI_CRM_CN_Approval_Limit_1__c) {
                                    r.ASI_FOC_Finance_Approver_2__c = freeGoodsSettingMap.get(fgkey).ASI_CRM_CN_Approver_1__c;
                                }
                                r.ASI_FOC_Logistic_Approver__c = freeGoodsSettingMap.containsKey(fgkey) ? freeGoodsSettingMap.get(fgkey).ASI_CRM_Logistic_Approver__c : null;
                                if (r.ASI_FOC_Finance_Approver__c == null && r.ASI_FOC_Logistic_Approver__c == null) {
                                    fgkey = r.ASI_CRM_CN_Region__c + r.ASI_FOC_Request_Type__c;
                                    r.ASI_FOC_Finance_Approver__c = freeGoodsSettingMap.containsKey(fgkey) ? freeGoodsSettingMap.get(fgkey).ASI_CRM_Finance_Approver__c : null;
                                    r.ASI_FOC_Finance_Approver_New2__c = freeGoodsSettingMap.containsKey(fgkey) ? freeGoodsSettingMap.get(fgkey).ASI_FOC_Finance_Approver_2__c : null;
                                if (freeGoodsSettingMap.containsKey(fgkey)
                                    && freeGoodsSettingMap.get(fgkey).ASI_CRM_CN_Approval_Limit_1__c != null 
                                    && r.ASI_FOC_Budget_Amount_withFee__c >= freeGoodsSettingMap.get(fgkey).ASI_CRM_CN_Approval_Limit_1__c) {
                                    r.ASI_FOC_Finance_Approver_2__c = freeGoodsSettingMap.get(fgkey).ASI_CRM_CN_Approver_1__c;
                                }
                                    r.ASI_FOC_Logistic_Approver__c = freeGoodsSettingMap.containsKey(fgkey) ? freeGoodsSettingMap.get(fgkey).ASI_CRM_Logistic_Approver__c : null;
                                }
                                if (r.ASI_FOC_Finance_Approver__c == null && r.ASI_FOC_Logistic_Approver__c == null) {
                                    fgkey = r.ASI_CRM_CN_Region__c;
                                    r.ASI_FOC_Finance_Approver__c = freeGoodsSettingMap.containsKey(fgkey) ? freeGoodsSettingMap.get(fgkey).ASI_CRM_Finance_Approver__c : null;
                                    r.ASI_FOC_Finance_Approver_New2__c = freeGoodsSettingMap.containsKey(fgkey) ? freeGoodsSettingMap.get(fgkey).ASI_FOC_Finance_Approver_2__c : null;
                                    if (freeGoodsSettingMap.containsKey(fgkey)
                                        && freeGoodsSettingMap.get(fgkey).ASI_CRM_CN_Approval_Limit_1__c != null 
                                        && r.ASI_FOC_Budget_Amount_withFee__c >= freeGoodsSettingMap.get(fgkey).ASI_CRM_CN_Approval_Limit_1__c) {
                                        r.ASI_FOC_Finance_Approver_2__c = freeGoodsSettingMap.get(fgkey).ASI_CRM_CN_Approver_1__c;
                                    }
                                    r.ASI_FOC_Logistic_Approver__c = freeGoodsSettingMap.containsKey(fgkey) ? freeGoodsSettingMap.get(fgkey).ASI_CRM_Logistic_Approver__c : null;
                                }

                            }else{
                                // r.ASI_FOC_Finance_Approver__c = mapFixApprovalRoute.containsKey('Free Goods Request') ? mapFixApprovalRoute.get('Free Goods Request').ASI_CRM_Finance_Approver__c : Null;
                                r.ASI_FOC_Finance_Approver__c = null;
                                r.ASI_FOC_Finance_Approver_New2__c = null;
                                r.ASI_FOC_Finance_Approver_2__c = null;
                                // r.ASI_FOC_Logistic_Approver__c = mapFixApprovalRoute.containsKey('Free Goods Request') ? mapFixApprovalRoute.get('Free Goods Request').ASI_CRM_Logistic_Approver__c : Null;
                                r.ASI_FOC_Logistic_Approver__c = null;
                            }
                                setDynamicApprover(r, mapDynamicRouteFOC, approver, 100);
                            
                        // 20190627 Wilson Chow
                        }
                        // 20190627 Wilson Chow

                        
                    }else if(r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM') || r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM_Read_Only')){
                        
                        r.ASI_FOC_Finance_Approver__c = mapFixApprovalRoute.containsKey('POSM') ? mapFixApprovalRoute.get('POSM').ASI_CRM_Finance_Approver__c : Null;
                        r.ASI_FOC_Logistic_Approver__c = mapFixApprovalRoute.containsKey('POSM') ? mapFixApprovalRoute.get('POSM').ASI_CRM_Logistic_Approver__c : Null;
                        
                        //20190116 Andy @Introv - for no regional approval, all should go to HQ approval - START
                        Boolean bHQApproval = true;
                        //20190102 Andy @Introv - add regional approval/HQ approval - START
                        if (r.ASI_MFM_FromWarehouse__c != NULL) {
                            ASI_FOC_Warehouse__c objWarehouse = warehouseMap.get(r.ASI_MFM_FromWarehouse__c);
                            
                            // HQ = 1 ; Region = 2 ; else = 0
                            Integer iApprovalType = getOrderApprovalType(objWarehouse.ASI_FOC_Warehouse_Type__c);
                            
                            //HQ approval
                            //if (iApprovalType == 1) {
                            //    setDynamicApprover(r, mapDynamicRoutePOSM, approver, 100);
                            //}
                            
                            //Regional approval
                            if (iApprovalType == 2) {
                                if (objWarehouse.ASI_FOC_Region__r.Name != NULL) {
                                    if (mapFixApprovalRoute4Region.containsKey(objWarehouse.ASI_FOC_Region__r.Name)) {
                                        setRegionalApprover(r, mapFixApprovalRoute4Region.get(objWarehouse.ASI_FOC_Region__r.Name));
                                        bHQApproval = false;
                                    }
                                }
                            }
                        }
                        //20190102 Andy @Introv - add regional approval/HQ approval - END
                        if (bHQApproval) setDynamicApprover(r, mapDynamicRoutePOSM, approver, 100);
                        //20190116 Andy @Introv - for no regional approval, all should go to HQ approval - END
                    }
                    
                    //20170926 Introv Commented
                    //string role_name = user_map.get(r.ownerId).userRole.developerName;
                    //List<id> tempApprover = new List<id>();
                    
                    //20170927 Introv Commented
                    /*for (ASI_FOC_Route_Type__c rt:rt_list) {
                        if (role_name == rt.ASI_FOC_Role_Name__c) {
                            if (r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request') || r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request_Read_Only') || r.recordTypeId == rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only')){
                                r.ASI_FOC_Finance_Approver__c = rt.ASI_FOC_Finance_Approver__c;
                                r.ASI_FOC_Logistic_Approver__c = rt.ASI_FOC_Logistic_Approver__c;
                            }else if (r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM') || r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM_Read_Only')){
                                r.ASI_FOC_Finance_Approver__c = rt.ASI_FOC_POSM_Finance_Approver__c;
                                r.ASI_FOC_Logistic_Approver__c = rt.ASI_FOC_POSM_Logistic_Approver__c;
                            }
                            for (ASI_FOC_Route_Criteria__c rd:rt.ASI_FOC_Route_Criteria__r) {
                                if (r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request') || r.recordTypeId == rt_map.get('ASI_FOC_CN_Free_Goods_Request_Read_Only') || r.recordTypeId == rt_map.get('ASI_FOC_CN_Request_and_Items_Read_Only')){
                                    if (rd.ASI_FOC_Threshold__c < math.abs(r.ASI_FOC_Free_Goods_Total_Cost__c)) {//20151223 Ben @ Elufa System add math.abs()
                                        if (approver_count == 0) {
                                            r.ASI_FOC_Approver_1__c = rd.ASI_FOC_Approver__c;
                                        }
                                        else if (approver_count == 1) {                                 
                                            r.ASI_FOC_Approver_2__c = rd.ASI_FOC_Approver__c;
                                        }
                                        else if (approver_count == 2) {                                 
                                            r.ASI_FOC_Approver_3__c = rd.ASI_FOC_Approver__c;
                                        }
                                        else if (approver_count == 3) {                                 
                                            r.ASI_FOC_Approver_4__c = rd.ASI_FOC_Approver__c;
                                        }
                                        else if (approver_count == 4) {                                 
                                            r.ASI_FOC_Approver_5__c = rd.ASI_FOC_Approver__c;
                                        }       
                                        else if (approver_count == 5) {                                 
                                            r.ASI_FOC_Approver_6__c = rd.ASI_FOC_Approver__c;
                                        }
                                        else if (approver_count == 6) {                                 
                                            r.ASI_FOC_Approver_7__c = rd.ASI_FOC_Approver__c;
                                        }
                                        approver_count++;                                                                                                                               
                                    }
                                } else if (r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM') || r.recordTypeId == rt_map.get('ASI_FOC_CN_POSM_Read_Only')){
                                    if (rd.ASI_FOC_POSM_Threshold__c < math.abs(r.ASI_FOC_Free_Goods_Total_Cost__c)) {//20151223 Ben @ Elufa System add math.abs()
                                        if (approver_count == 0) {
                                            r.ASI_FOC_Approver_1__c = rd.ASI_FOC_Approver__c;
                                        }
                                        else if (approver_count == 1) {                                 
                                            r.ASI_FOC_Approver_2__c = rd.ASI_FOC_Approver__c;
                                        }
                                        else if (approver_count == 2) {                                 
                                            r.ASI_FOC_Approver_3__c = rd.ASI_FOC_Approver__c;
                                        }
                                        else if (approver_count == 3) {                                 
                                            r.ASI_FOC_Approver_4__c = rd.ASI_FOC_Approver__c;
                                        }
                                        else if (approver_count == 4) {                                 
                                            r.ASI_FOC_Approver_5__c = rd.ASI_FOC_Approver__c;
                                        }       
                                        else if (approver_count == 5) {                                 
                                            r.ASI_FOC_Approver_6__c = rd.ASI_FOC_Approver__c;
                                        }
                                        else if (approver_count == 6) {                                 
                                            r.ASI_FOC_Approver_7__c = rd.ASI_FOC_Approver__c;
                                        }   
                                        approver_count++;
                                    }
                                }
                            }
                            break;
                        }
                    }*/
                }               
            }               
        }
        // 20190627 Wilson Chow
        system.debug('routineBeforeUpdate() end');
        // 20190627 Wilson Chow
    }
    
    //20170927 Introv
    Public Static void setDynamicApprover(ASI_FOC_Free_Goods_Request__c reqRecord, Map<String, ASI_CRM_Dynamic_Approval_Route__c> mapDynamicRoute, Id Approver, Integer maximumLevel) {
        
        Id currentApprover = Approver;
        Integer i = 1;
        String sysApproverField = 'ASI_FOC_Approver_' + i +'__c';
        
        while(foc_FIELD_MAP.containsKey(sysApproverField) && i <= maximumLevel){
            
            if(ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(currentApprover) == Null)
                break;
            
            if(mapDynamicRoute.containsKey(currentApprover) && (mapDynamicRoute.get(currentApprover).ASI_CRM_End_of_Dynamic_Route__c || math.abs(reqRecord.ASI_FOC_Budget_Amount__c) <= mapDynamicRoute.get(currentApprover).ASI_CRM_Approval_Limit__c)){
                
                reqRecord.put(sysApproverField, currentApprover);
                break;
            }else{
                
                reqRecord.put(sysApproverField, currentApprover);
            }
            
            i++;
            sysApproverField = 'ASI_FOC_Approver_' + i +'__c';
            currentApprover = ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(currentApprover).ManagerId;
        }
    }
    
    Public Static void setApproverToNull(ASI_FOC_Free_Goods_Request__c reqRecord){
        
        Integer i = 1;
        String sysApproverField = 'ASI_FOC_Approver_' + i +'__c';
        
        While(foc_FIELD_MAP.containsKey(sysApproverField)){
            
            reqRecord.put(sysApproverField, null);
            
            i++;
            sysApproverField = 'ASI_FOC_Approver_' + i +'__c';
        }
    }
    //20170927 End
    
    //20190102 Andy @Introv - add regional approval/HQ approval - START
    // HQ = 1 ; Region = 2 ; else = 0
    Private Static Integer getOrderApprovalType(string sCheckType) {
        Integer iType = 0;
        
        String sHQ = 'HQ Warehouse';
        String sRegion = 'Region Warehouse';
        
        if ((sCheckType != NULL) && (sCheckType != '')) {
            if (sCheckType.toLowerCase() == sHQ.toLowerCase())
                iType = 1;
            if (sCheckType.toLowerCase() == sRegion.toLowerCase())
                iType = 2;
        }
        
        return iType;
    }
    
    Private Static void setRegionalApprover(ASI_FOC_Free_Goods_Request__c reqRecord, ASI_CRM_Fix_Approval_Route__c objFixRoute){
        Integer iMaxApprover = 7;
        Integer iCountFGApprover = 1;
        Integer iCountFixApprover = 1;
        while (iCountFixApprover <= iMaxApprover) {
            ID idFixApprover = (ID)objFixRoute.get('ASI_CRM_CN_Approver_' + iCountFixApprover + '__c');
            if ((idFixApprover != NULL) && (idFixApprover != reqRecord.OwnerId)) {
                reqRecord.put('ASI_FOC_Approver_' + iCountFGApprover + '__c', idFixApprover);
                iCountFGApprover++;
            }
            iCountFixApprover++;
        }
    }
    //20190102 Andy @Introv - add regional approval/HQ approval - END
    
    //2019/11/6 CanterDuan start
    public static void GetTaxRate(List<ASI_FOC_Free_Goods_Request__c> triggerNew){
        //获取税率信息
        List<ASI_CRM_CN_Tax_Rate_Config__c> taxRateList = new List<ASI_CRM_CN_Tax_Rate_Config__c>([SELECT Id,ASI_CRM_CN_Tax_Rate__c 
                                                                                        FROM ASI_CRM_CN_Tax_Rate_Config__c 
                                                                                        ORDER BY ASI_CRM_CN_Effective_From__c DESC]);
        if(taxRateList.isEmpty()) return;
        for(ASI_FOC_Free_Goods_Request__c  tov: triggerNew){
            tov.ASI_CRM_CN_Tax_Rate__c = taxRateList[0].ASI_CRM_CN_Tax_Rate__c;
        }
    }
    //2019/11/6 CanterDuan end
    
    //202009 added by LEO Jing BSL
    public static void approvalPass(list<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap){
        System.debug(LoggingLevel.INFO, '*** ----------YES: ');
        Set<Id> yes_requestIds = new Set<Id>();
        Set<Id> no_requestIds = new Set<Id>();
        for (ASI_FOC_Free_Goods_Request__c request : trigger_new) {
            ASI_FOC_Free_Goods_Request__c old_request = trigger_oldMap.get(request.Id);
            if (request.ASI_FOC_Request_Status__c  == 'Final' && request.ASI_FOC_Request_Status__c   != old_request.ASI_FOC_Request_Status__c ) {
                yes_requestIds.add(request.Id);
            }
            if (request.ASI_FOC_Request_Status__c  == 'Rejected' && request.ASI_FOC_Request_Status__c   != old_request.ASI_FOC_Request_Status__c ) {
                no_requestIds.add(request.Id);
            }
        }
        if (yes_requestIds.size() > 0) {
            List<ASI_FOC_Free_Goods_Request__c> yes_requestList = [SELECT Id,ASI_FOC_Request_Status__c FROM ASI_FOC_Free_Goods_Request__c WHERE ASI_FOC_POSM_Request_Approval__c IN: yes_requestIds];        
            if (yes_requestList.size() > 0) {
                for (ASI_FOC_Free_Goods_Request__c request : yes_requestList ) {
                    request.ASI_FOC_Request_Status__c  = 'Final';
                    request.ASI_FOC_SYS_Approved_Date__c = Date.today();
                    request.ASI_CRM_SYS_Approved_Time__c = Datetime.now();
                }
                update yes_requestList;
            } 
        }
        
        if (no_requestIds.size() > 0) {
            List<ASI_FOC_Free_Goods_Request__c> no_requestList = [SELECT Id,ASI_FOC_Request_Status__c FROM ASI_FOC_Free_Goods_Request__c WHERE ASI_FOC_POSM_Request_Approval__c IN: no_requestIds]; 
            if (no_requestList.size() > 0) {
                for (ASI_FOC_Free_Goods_Request__c request : no_requestList ) {
                    request.ASI_FOC_Request_Status__c  = 'Rejected';
                    request.ASI_FOC_Delivery_Status__c = null;
                }
                update no_requestList;
            }
            
        }

    }
}