/**************************************************************************************************
 * Name: ASI_MFM_CN_POSMReturnRequest_Upload_EXT
 * 
 * Purpose: 
 * Requirement:Bulk upload for chargeback
 * Author: LEO BLS 
 * Create Date: 2020-7-24
 * Modify History:
***************************************************************************************************/
public with sharing class ASI_MFM_CN_POSMReturnRequest_Upload_EXT {
    
    private static Final String POSMSKU_ID = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_POSM_SKU');
    private static Final String ORDER_ID = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_POSM');
    private static Final String ORDER_RO_ID = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_POSM_RO');
    private static Final String ORDER_ITEM_ID = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request_Item__cASI_MFM_CN_POSM_Request_Item');
    private static Final String ORDER_ITEM_RO_ID = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request_Item__cASI_MFM_CN_POSM_Request_Item_RO');
    private static Final Id BATCH_LOG_ID = Global_recordTypeCache.getRtId('ASI_MFM_BatchLog__cASI_MFM_CN_Batch_Log');      
    private static Final Id ORDER_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_POSM_Return_Batch_Approval');
    private static Final Id ITEM_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_MFM_POSM_Return_Request_Item__cASI_MFM_CN_POSM_Return_Request_Item_Batch_Approval');
    private static Final Date DEFAULT_DATE = Date.newInstance(2020, 1, 1);
    
    private static String submitType;
    private static Boolean showBatch;
    Public ASI_MFM_CN_POSMReturnRequest_Upload_EXT(ASI_MFM_CN_POSMCatalog_CTRL controller){}

    // @TestVisible
    // Private Static string getADDomainPrefix() {
    //     string sPrefix = '';
    //     ASI_MFM_CN_Setting__mdt setting = [SELECT id, DeveloperName, ASI_MFM_CN_TextValue__c
    //                                        FROM ASI_MFM_CN_Setting__mdt
    //                                        WHERE DeveloperName LIKE 'ASI_MFM_CN_POSM_ADDomainUser_Prefix'
    //                                        LIMIT 1];
        
    //     if (setting != NULL)
    //         sPrefix = setting.ASI_MFM_CN_TextValue__c;
        
    //     return sPrefix;
    // }


    @RemoteAction
    Public Static Map<String, Object> checkUploadData(String input){
        Map<String, object> inputMap = (Map<String, object>)JSON.deserializeUntyped(input);
        Map<String, object> result = new Map<String, object>();
        
        //Warehouse
        String whCode = (String)inputMap.get('towarehouse');
        for(ASI_FOC_Warehouse__c wh :[SELECT Id, name, ASI_FOC_Warehouse_Code__c
                                      
                                      FROM ASI_FOC_Warehouse__c
                                      WHERE 
                                      (ASI_FOC_Warehouse_Code__c = :whCode OR Name = :whCode) 
                                      // 20200511 ASI CN BLS Added control ASI_MFM_Is_Active__c = true to relate active warehouse
                                      AND ASI_MFM_Is_Active__c = true
                                      LIMIT 1]) 
        {
            result.put('towarehouse', wh);
        }
        

        //vas
        Map<String, String> vasMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResultAVS = ASI_MFM_POSM_Return_Request_Item__c.ASI_MFM_VAS__c.getDescribe();
        List<Schema.PicklistEntry> pleAVS = fieldResultAVS.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleAVS){
            vasMap.put(pickListVal.getValue(),pickListVal.getValue());
            
        }
        //Return Request Time
        String rrtStr = (String)inputMap.get('returnRequestTime');
        Schema.DescribeFieldResult fieldResultRRT = ASI_MFM_POSM_Return_Request__c.ASI_MFM_Return_Request_Time__c.getDescribe();
        List<Schema.PicklistEntry> pleRRT = fieldResultRRT.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleRRT){
            String pickValue = pickListVal.getValue();
            if(pickValue == rrtStr)result.put('returnRequestTime', pickListVal);
        }
        //  

        try {
            Set<String> skuCodeList = new Set<String>();
            Set<String> qtyList  = new Set<String>();
            Set<String> ownerNameList = new Set<String>();
            Set<String> vasList  = new Set<String>();
            
            Map<String, ASI_MFM_SKU_Code__c> skuMap = new Map<String, ASI_MFM_SKU_Code__c>();
            Map<String, User> userMap = new Map<String, User>();

            //modify by BLS 2020-09-23 USER.ADDomainUser__c will be updated remove Domain
            //String adDomain = getADDomainPrefix();
            
            for(Object itemInput :(List<Object>)inputMap.get('items')){
                Map<String,Object> itemInputMap = (Map<String,Object>)itemInput;
                String skuCode = (String)itemInputMap.get('sku');
                String qty  = (String)itemInputMap.get('qty');
                String ownerEmail = (String)itemInputMap.get('owner');
                // String ownerName = '';
                // List<String> nameList = new List<String>();
                // if ((String)itemInputMap.get('owner') != null && (String)itemInputMap.get('owner') != '') {
                //  nameList = ((String)itemInputMap.get('owner')).split(' ');
                //  System.debug(LoggingLevel.INFO, '*** nameList: ' + nameList);
                // }
                // if (nameList.size()>=2) {
                //  ownerName = nameList[1]+' '+nameList[0];
                // }else{
                //  ownerName = (String)itemInputMap.get('owner');
                // }
                String vas = (String)itemInputMap.get('vas');
                if(skuCode != null && skuCode != '')skuCodeList.add(skuCode);
                if(qty  != null && qty  != '')qtyList.add(qty);
                if(ownerEmail != null && ownerEmail != '')ownerNameList.add(ownerEmail);
                if(vas != null && vas != '')vasList.add(vas);
                
            }
            System.debug(LoggingLevel.INFO, '*** ownerNameList: ' + ownerNameList);
            
            //sku
            for(ASI_MFM_SKU_Code__c sku :[SELECT id, name , ASI_MFM_SKU_Code__c, ASI_MFM_Item_Group__c, ASI_MFM_Minimum_Packing_Qty__c
                                          FROM ASI_MFM_SKU_Code__c
                                          WHERE RecordTypeId = :POSMSKU_ID
                                          AND ASI_MFM_SKU_Code__c IN :skuCodeList]) 
            {
                skuMap.put(sku.ASI_MFM_SKU_Code__c, sku);
            }
            
            //user
            for(User u :[SELECT id, name,Email , ADDomainUser__c, ADDomainUserLower__c, username
                         FROM USER 
                         WHERE isActive = true
                         AND Email IN :ownerNameList
                         //AND ADDomainUserLower__c IN :vasList
                        ])
            {
                userMap.put(u.Email, u);
            }
            result.put('adDomain', '');
            result.put('sku',skuCodeList);
            result.put('qty',qtyList);
            result.put('owner',ownerNameList);
            // result.put('vas',vasList);

            result.put('skuMap', skuMap);
            result.put('userMap', userMap);
            result.put('vasMap', vasMap);
        } catch (Exception e) {
            result.put('sku','fail');
            result.put('skuFailMsg', e.getMessage()+'||'+e.getLineNumber());
        }          
        return result;
    }
    private static ASI_MFM_BatchLog__c InsertDebugMsg(string sDateTime, string sMsg) {
        ASI_MFM_BatchLog__c oLog = new ASI_MFM_BatchLog__c(
            RecordTypeId = BATCH_LOG_ID
            , ASI_MFM_Log_Detail__c  = '[' + sDateTime + ']:{' + sMsg + '}'
            , ASI_MFM_LogType__c = 'POSM Upload'
        );
        insert oLog;
        return oLog;
    }
    private static string assignDebugMsg(string sLabel, string sValue) {
        string sTmpValue = '';
        sTmpValue = sLabel + ':' + (sValue==NULL ? 'NULL' : sValue) + ';';
        return sTmpValue;
    }

    //202009 eidt By Leo Jing BLS
    @RemoteAction
    Public static Map<String, Object> submitOrder(String input,String key, Boolean show_Batch, String submit_Type){


        showBatch = show_Batch;
        submitType = submit_Type;
        Map<String, Object> resultMap = new Map<String,Object>();
        Datetime dtTime = Datetime.now();
        string sDatetime = dtTime.format('yyyyMMddhhmmss');
        ASI_MFM_BatchLog__c oLog = InsertDebugMsg(sDatetime, UserInfo.getUserId() + ';'+assignDebugMsg('input',input));
        Savepoint sp = Database.setSavepoint();
        try{    
            Map<String, object> inputMap = (Map<String, object>)JSON.deserializeUntyped(input);
            String returnRequestDate    = (String)inputMap.get('returnRequestDate');
            String returnRequestTime  = (String)inputMap.get('returnRequestTime');
            String formAddress    = (String)inputMap.get('formAddress');
            String toAddress    = (String)inputMap.get('toAddress');
            String recipient         = (String)inputMap.get('recipient'); 
            String towarehouse   = (String)inputMap.get('towarehouse');
            String towarehouseId   = (String)inputMap.get('towarehouseid');
            String recipientContact   = (String)inputMap.get('recipientContact');
            String consignee         = (String)inputMap.get('consignee');
            String consigneeContact         = (String)inputMap.get('consigneeContact');
            String requestDeliveryDate         = (String)inputMap.get('requestDeliveryDate');
            String otherRequest         = (String)inputMap.get('otherRequest');           

            ASI_MFM_POSM_Return_Request__c prRequest = createRequestHeader(returnRequestDate,returnRequestTime,formAddress,toAddress,recipient,towarehouse,
                                                                                towarehouseid,recipientContact,consignee,consigneeContact,requestDeliveryDate,otherRequest);
            prRequest.ASI_MFM_Batch_Import_KEY__c = key;
            insert prRequest;
            resultMap.put('header', prRequest);

            Map<String,String> itemErrorMap = new Map<String,String>();
            for(Integer counter = 0 ; counter < 10 ; counter ++){
                Boolean lockflag = false;
                itemErrorMap = addItemToReturnRequset(prRequest, (List<Object>)inputMap.get('items') , key);               
                for (String errorVal:itemErrorMap.values()) {
                     if ( (errorVal.contains('Record Currently Unavailable') || errorVal.contains('记录当前不可用') ) && counter < 10) {  lockflag = true; }
                }                  
                if (!lockflag) { break; }
            }
            
            if(itemErrorMap.keySet().Size()>0) {
                Database.rollback( sp );
                oLog.ASI_MFM_Operation_Done__c = TRUE;
                oLog.ASI_MFM_Operation_Error_Message__c = JSON.serialize(itemErrorMap);
                update oLog;
                resultMap.put('error', '请查阅订单摘要');
                resultMap.put('itemErrors', itemErrorMap);
                return resultMap;
            }
            
            ASI_MFM_POSM_Return_Request__c prr = [SELECT id, Name FROM ASI_MFM_POSM_Return_Request__c WHERE Id = :prRequest.Id];
            resultMap.put('headerName', prr.Name);
   
        } catch (Exception e) {
            Database.rollback( sp );
            oLog.ASI_MFM_Operation_Done__c = FALSE;
            oLog.ASI_MFM_Operation_Error_Message__c = e.getMessage();
            update oLog;
            resultMap.put('error', e.getMessage()+'||||'+e.getStackTraceString());
        }
        oLog.ASI_MFM_Operation_Done__c = TRUE;
        update oLog;
        return resultMap;
    }
    public static ASI_MFM_POSM_Return_Request__c createRequestHeader(String returnRequestDate, String returnRequestTime, String formAddress, 
                                                                                    String toAddress, String recipient, String towarehouse, String towarehouseid, String recipientContact,
                                                                                    String consignee, String consigneeContact, String requestDeliveryDate, String otherRequest)
    {
       ASI_MFM_POSM_Return_Request__c posmReturnReq = new ASI_MFM_POSM_Return_Request__c(RecordTypeId=ORDER_ID);
        if(returnRequestDate!=null && returnRequestDate!='') posmReturnReq.ASI_MFM_Return_Request_Date__c = Date.valueOf(returnRequestDate);
        if(returnRequestTime!=null && returnRequestTime!='') posmReturnReq.ASI_MFM_Return_Request_Time__c = returnRequestTime;
        if(formAddress!=null && formAddress!='') posmReturnReq.ASI_MFM_Address__c = formAddress;
        if(toAddress!=null && toAddress!='') posmReturnReq.ASI_MFM_To_Address__c = toAddress;
        if(recipient!=null && recipient!='') posmReturnReq.ASI_MFM_Return_Request_Contact__c = recipient;
        if(recipientContact!=null && recipientContact!='') posmReturnReq.ASI_MFM_Recipient_Contact__c = recipientContact;
        if(towarehouseid!=null && towarehouseid!='') posmReturnReq.ASI_MFM_To_Warehouse__c = towarehouseid;    

        if(consignee!=null && consignee!='') posmReturnReq.ASI_MFM_Consignee__c = consignee;    
        if(consigneeContact!=null && consigneeContact!='') posmReturnReq.ASI_MFM_Consignee_Contact__c = consigneeContact;    
        if(requestDeliveryDate!=null && requestDeliveryDate!='') posmReturnReq.ASI_MFM_Request_Delivery_Date__c = Date.valueOf(requestDeliveryDate);    
        if(otherRequest!=null && otherRequest!='') posmReturnReq.ASI_MFM_Other_Request__c = otherRequest;    
        
        return posmReturnReq;
    }

    Public static Map<String, String> addItemToReturnRequset(ASI_MFM_POSM_Return_Request__c request,List<Object> items, String key) {
    
        Map<String,String> errorMap = new Map<String,String>();  
        try {         
            List<ASI_MFM_POSM_Return_Request_Item__c> reqItems = new List<ASI_MFM_POSM_Return_Request_Item__c>();
            for(Object itmObj : items) {
                Map<String,Object> itmMap = (Map<String,Object>)itmObj;
                ASI_MFM_POSM_Return_Request_Item__c reqItem = new ASI_MFM_POSM_Return_Request_Item__c();
                reqItem.ASI_MFM_SKU__c = Id.valueOf((String)itmMap.get('skuId'));
                reqItem.ASI_MFM_QTY_Issued__c = Integer.valueOf((String)itmMap.get('qty'));
                reqItem.ASI_MFM_Owner__c = Id.valueOf((String)itmMap.get('ownerid'));
                reqItem.ASI_MFM_Item_Owner__c = Id.valueOf((String)itmMap.get('ownerid'));
                reqItem.ASI_MFM_VAS__c = (String)itmMap.get('vas');
                reqItem.RecordTypeId = ORDER_ITEM_ID;
                reqItem.ASI_MFM_Request_Order__c = request.Id;
                reqItem.ASI_MFM_Batch_Import_KEY__c = key;                     

                reqItems.add(reqItem);
            }        
            if( reqItems.size() > 0 ) {
                insert reqItems;
                if (showBatch == false) {
                    List<Id> lineItemID = new List<Id>();
                    List<ASI_MFM_POSM_Return_Request_Item__c> noOwnerList = new List<ASI_MFM_POSM_Return_Request_Item__c>();
                    List<ASI_MFM_POSM_Return_Request_Item__c> itemList =[SELECT id, ASI_MFM_Approval_Status__c,ASI_MFM_Item_Owner__c,ASI_MFM_POSM_Return_Reques_Approval_Item__c
                                                        FROM ASI_MFM_POSM_Return_Request_Item__c 
                                                        WHERE ASI_MFM_Request_Order__c = : request.Id ];                            
                    for(ASI_MFM_POSM_Return_Request_Item__c item :itemList) {
                        if(item.ASI_MFM_Approval_Status__c != 'In Progress' && item.ASI_MFM_Approval_Status__c != 'Approved' && item.ASI_MFM_Item_Owner__c != null){
                            lineItemID.add(item.id);
                        }
                        if(item.ASI_MFM_Approval_Status__c != 'In Progress' && item.ASI_MFM_Approval_Status__c != 'Approved' && item.ASI_MFM_Item_Owner__c == null){
                            item.ASI_MFM_Approval_Status__c = 'Approved';
                            item.RecordTypeId = ORDER_ITEM_RO_ID;
                            noOwnerList.add(item);                            
                        }
                    }                
                    if(lineItemID.size()>0){
                        List<Approval.ProcessSubmitRequest> lineItm_req = new List<Approval.ProcessSubmitRequest>();
                        for(ID objID : lineItemID){
                            Approval.ProcessSubmitRequest tmp = new Approval.ProcessSubmitRequest();
                            tmp.setObjectId(objID);
                            lineItm_req.add(tmp);
                        }                    
                        List<Approval.ProcessResult> lineItm_result = Approval.process(lineItm_req);  
                        for(Approval.ProcessResult obj : lineItm_result){
                            if (!obj.isSuccess()) {
                                return null;
                            }
                        }
                    }             
                    
                    
                    request.RecordTypeId = ORDER_RO_ID;
                    // for (ASI_MFM_POSM_Return_Request_Item__c item : reqItems) {
                    //     item.ASI_MFM_Approval_Status__c = 'In Progress';
                    //     item.RecordTypeId = ORDER_ITEM_RO_ID;
                    // }
                    // update reqItems;                
                    request.ASI_MFM_Request_Status__c = 'In Progress';     
                    if(noOwnerList.size()>0) update noOwnerList;           
                    update request;    

                    // if( lineItemID.size( )== 0 ) {
                    //     List<Approval.ProcessSubmitRequest> header_req = new List<Approval.ProcessSubmitRequest>();                    
                    //     Approval.ProcessSubmitRequest tmp_header_req = new Approval.ProcessSubmitRequest();
                    //     tmp_header_req.setObjectId(request.id);
                    //     header_req.add(tmp_header_req);                    
                    //     List<Approval.ProcessResult> header_result = Approval.process(header_req);  
                    //     for(Approval.ProcessResult obj : header_result){
                    //         if (!obj.isSuccess()) {
                    //             return null;
                    //         }
                    //     }
                    // }
                }

            }
        } catch (Exception e) {
            errorMap.put('error',e.getMessage()+'||'+e.getLineNumber());
        }
        return errorMap;
    }
    @RemoteAction
    Public static Map<String, Object> finishProcess(String key, Integer batchCount ,Integer batchSuccessCount, String executeCount){
        Map<String,String> errorMap = new Map<String,String>();  
        try {
            System.debug(LoggingLevel.INFO, '*** key: '+ key);
            System.debug(LoggingLevel.INFO, '*** batchCount: '+ batchCount);
            System.debug(LoggingLevel.INFO, '*** batchSuccessCount: '+ batchSuccessCount);
            System.debug(LoggingLevel.INFO, '*** executeCount: '+ executeCount);
            User u = [select id ,ManagerId from user where id =: userinfo.getUserId()];
            //Create Request Approval Heander
            ASI_MFM_POSM_Return_Request__c approvalRequestHead = new ASI_MFM_POSM_Return_Request__c();                
            approvalRequestHead.RecordTypeId = ORDER_APPROVAL_ID;
            approvalRequestHead.ASI_MFM_Batch_Import_KEY__c = key;
            approvalRequestHead.ASI_MFM_Return_Request_Date__c = DEFAULT_DATE;
            approvalRequestHead.ASI_MFM_Approver_1__c = u.ManagerId;
            approvalRequestHead.ASI_MFM_Batch_Request_Total__c = batchCount;
            approvalRequestHead.ASI_MFM_Batch_Request_Success_Total__c = batchSuccessCount;
            insert approvalRequestHead;
            //Query this batch of Return request
            List<ASI_MFM_POSM_Return_Request__c> reqList = [SELECT Id,ASI_MFM_Batch_Request_Total__c,ASI_MFM_Batch_Request_Success_Total__c,ASI_MFM_POSM_Return_Request_Approval__c,ASI_MFM_Request_Status__c
                                                            FROM ASI_MFM_POSM_Return_Request__c 
                                                            WHERE ASI_MFM_Batch_Import_KEY__c =: key 
                                                            AND (RecordTypeId =: ORDER_ID OR RecordTypeId =: ORDER_RO_ID)];

            for (ASI_MFM_POSM_Return_Request__c req: reqList) {
                req.ASI_MFM_POSM_Return_Request_Approval__c = approvalRequestHead.Id;
            }
            update reqList;

            List<ASI_MFM_POSM_Return_Request_Item__c> reqItems = [SELECT id, ASI_MFM_Approval_Status__c,ASI_MFM_Item_Owner__c,ASI_MFM_POSM_Return_Reques_Approval_Item__c,ASI_MFM_Owner__c
                                                                    FROM ASI_MFM_POSM_Return_Request_Item__c 
                                                                    WHERE ASI_MFM_Batch_Import_KEY__c = : key 
                                                                    AND (RecordTypeId =: ORDER_ITEM_ID OR RecordTypeId =: ORDER_ITEM_RO_ID) ]; 
            //Create Request item Approval Heander
            Set<String> uidSet = new Set<String>();
            List<ASI_MFM_POSM_Return_Request_Item__c> approvalRequestItemHeadList = new List<ASI_MFM_POSM_Return_Request_Item__c>();
            for (ASI_MFM_POSM_Return_Request_Item__c item : reqItems) {
                String uid = item.ASI_MFM_Owner__c;
                if (!uidSet.contains(uid)) {
                    ASI_MFM_POSM_Return_Request_Item__c approvalRequestItemHead = new ASI_MFM_POSM_Return_Request_Item__c();
                    approvalRequestItemHead.ASI_POSM_Return_Request_Approval_Header__c = approvalRequestHead.Id;
                    approvalRequestItemHead.RecordTypeId = ITEM_APPROVAL_ID;
                    approvalRequestItemHead.ASI_MFM_Batch_Import_KEY__c =uid+ approvalRequestHead.ASI_MFM_Batch_Import_KEY__c;
                    approvalRequestItemHead.ASI_MFM_Request_Order__c = approvalRequestHead.Id;
                    approvalRequestItemHead.ASI_MFM_Owner__c = uid;
                    // approvalRequestItemHead.ASI_MFM_Approval_Status__c = 'OPEN';
                    approvalRequestItemHeadList.add(approvalRequestItemHead);
                    uidSet.add(item.ASI_MFM_Owner__c);
                }          
            }
            if(approvalRequestItemHeadList.size() > 0) insert approvalRequestItemHeadList;

            for (ASI_MFM_POSM_Return_Request_Item__c item : reqItems) {              
                for (ASI_MFM_POSM_Return_Request_Item__c  itemHeader: approvalRequestItemHeadList) {
                      if (item.ASI_MFM_Owner__c == itemHeader.ASI_MFM_Owner__c) {
                          item.ASI_MFM_POSM_Return_Reques_Approval_Item__c = itemHeader.Id;
                      }
                      
                }
            }
            update reqItems;

            //Item Batch Approval
            if(approvalRequestItemHeadList.size()>0){
                List<Approval.ProcessSubmitRequest> lineItm_req = new List<Approval.ProcessSubmitRequest>();
                for(ASI_MFM_POSM_Return_Request_Item__c obj : approvalRequestItemHeadList){
                    Approval.ProcessSubmitRequest tmp = new Approval.ProcessSubmitRequest();
                    if (obj.ASI_MFM_Item_Owner__c != null) {
                        tmp.setObjectId(obj.Id);
                        lineItm_req.add(tmp);
                    }
                    
                }                    
                List<Approval.ProcessResult> lineItm_result = Approval.process(lineItm_req);  
                for(Approval.ProcessResult obj : lineItm_result){
                    if (!obj.isSuccess()) {
                        return null;
                    }
                }
            }
            for (ASI_MFM_POSM_Return_Request_Item__c item : reqItems) {
                item.ASI_MFM_Approval_Status__c = 'In Progress';
                item.RecordTypeId = ORDER_ITEM_RO_ID;
                if (item.ASI_MFM_Owner__c == userinfo.getUserId()) {
                    item.ASI_MFM_Approval_Status__c = 'Approved';
                }
            }
            update reqItems;   
            for (ASI_MFM_POSM_Return_Request__c req: reqList) {
                req.ASI_MFM_Request_Status__c = 'In Progress';   
                req.RecordTypeId = ORDER_RO_ID;             
            }
            update reqList;

            //auto approval
            for (ASI_MFM_POSM_Return_Request_Item__c item :approvalRequestItemHeadList) {
                // if (item.ASI_MFM_Owner__c == userInfo.getUserId()) {
                //     Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                //     req.setComments('Create user equals approver');
                //     req.setAction('Approve');
                //     ProcessInstanceWorkitem pItem = [SELECT Id from ProcessInstanceWorkitem 
                //                                     WHERE ProcessInstance.TargetObjectId =: Item.Id];
                //     req.setWorkitemId(pItem.Id);                     
                //     Approval.ProcessResult result = Approval.process(req);
                // } 
                if (item.ASI_MFM_Owner__c == userInfo.getUserId()) {
                     item.ASI_MFM_Approval_Status__c = 'Approved';   
                }                   
            }
            update approvalRequestItemHeadList;
        } catch (Exception e) {
            errorMap.put('error',e.getMessage()+'||'+e.getLineNumber());
        }
        return errorMap;
    }
}