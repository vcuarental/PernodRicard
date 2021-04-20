/***************************************************************************************************************************
* Name:        ASI_KOR_POSM_Order_Request_TriggerClass
* Description: Trigger class for ASI_KOR_POSM_Order_Request's trigger(s)
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* ??               ??                      Created
* 2018-11-27       Alan Lau                Created in B7
* 2018-12-21       Alan Lau                replace nested loop by Map in setSysApprover()
* 2019-06-03        Wilson Chow             Modified validateActualSpendingAmount() return value, add parameter requestIdAmountMap
*                                           Modified getMapOfRegionNameToTotalActualSpendingAmount() add parameter requestIdAmountMap
****************************************************************************************************************************/
public without sharing class ASI_KOR_POSM_Order_Request_TriggerClass {

    private static boolean updatePOSMProductRun = true;
    private static boolean sendEmailtoSupplierRun = true;
    //Group by Product Owner in trade 
    
    public static void BeforeUpdateMethod(List<ASI_KOR_POSM_Order_Request__c> trigger_new, map<id, ASI_KOR_POSM_Order_Request__c> trigger_oldMap){
        set<id> approved_posm_set = new set<id>();
        for (ASI_KOR_POSM_Order_Request__c POSM : trigger_new){
            if(trigger_oldMap.get(POSM.Id).ASI_KOR_Status__c == 'Submitted' && POSM.ASI_KOR_Status__c == 'Approved'){
                approved_posm_set.add(POSM.Id);
                POSM.ASI_MFM_KR_Email_Sent__c=true;
                POSM.ASI_MFM_KR_EmailSentTime__c= system.now();
            }
            
        }
        
        //POSM to VENDOR  : Email/Detail Line List
        Map<String,List<ASI_KOR_POSM_Order_Detail__c>> DetailsLineMap = new Map<String,List<ASI_KOR_POSM_Order_Detail__c>>();
        
        Map<String,List<ASI_KOR_POSM_Order_Detail__c>> ProductOwnerMap = new Map<String,List<ASI_KOR_POSM_Order_Detail__c>>();
        
        if(approved_posm_set!= NULL &&  approved_posm_set.size()>0){
            for (ASI_KOR_POSM_Order_Detail__c line: [Select id,Name,ASI_CRM_Owner_Email__c,ASI_KOR_POSM_Order_Request__r.ASI_KOR_POSM_TO_Venue__c,ASI_KOR_POSM_Order_Request__r.ASI_KOR_POSM_TO_Venue__r.Name,ASI_MFM_Venue__c,ASI_MFM_Venue__r.Name,ASI_KOR_Item_Name__r.ASI_KOR_Item_Name_Kor__c,ASI_KOR_Remarks__c,ASI_KOR_POSM_Order_Request__r.OwnerId,ASI_KOR_POSM_Order_Request__r.recordTypeId,ASI_KOR_Item_Name__r.ASI_MFM_Product_Owner__r.Email, ASI_KOR_Item_Name__c,ASI_KOR_POSM_Order_Request__r.Owner.Name,ASI_KOR_POSM_Order_Request__r.Name,ASI_KOR_Quantity__c,ASI_KOR_Item_Name__r.Name,ASI_KOR_Item_Name__r.ASI_MFM_Vender_Email_address__c,ASI_KOR_Item_Name__r.ASI_KOR_Item_Code__c,ASI_KOR_Ship_To_Address__c from ASI_KOR_POSM_Order_Detail__c where ASI_KOR_POSM_Order_Request__c in: approved_posm_set and ASI_KOR_Item_Name__c !=null ]){
                if(line.ASI_KOR_Item_Name__r.ASI_MFM_Vender_Email_address__c!=null){
                    string VendorEmail= string.valueOf(line.ASI_KOR_Item_Name__r.ASI_MFM_Vender_Email_address__c);
                    if(!DetailsLineMap.containsKey(VendorEmail)){
                        List<ASI_KOR_POSM_Order_Detail__c> tempList= new List<ASI_KOR_POSM_Order_Detail__c>();
                        tempList.add(line);
                        DetailsLineMap.put(VendorEmail, tempList);
                    }else{
                        DetailsLineMap.get(VendorEmail).add(line); 
                    }
                    
                    
                    if (Test.isRunningTest() || Global_RecordTypeCache.getRt(line.ASI_KOR_POSM_Order_Request__r.recordTypeId).developerName.contains('ASI_KOR_Locked_POSM_Request') || Global_RecordTypeCache.getRt(line.ASI_KOR_POSM_Order_Request__r.recordTypeId).developerName.contains('ASI_KOR_New_POSM_Request')){
                        string ProductOwnerEmail= string.valueOf(line.ASI_KOR_Item_Name__r.ASI_MFM_Product_Owner__r.Email);
                        if(!ProductOwnerMap.containsKey(ProductOwnerEmail)){
                            List<ASI_KOR_POSM_Order_Detail__c> tempList= new List<ASI_KOR_POSM_Order_Detail__c>();
                            tempList.add(line);
                            ProductOwnerMap.put(ProductOwnerEmail, tempList);
                        }else{
                            ProductOwnerMap.get(ProductOwnerEmail).add(line); 
                        }
                    }// end if 
                    
                }
            }//End of for loop
            sendEmailtoSupplierRun = false;
        }
        
        
        if(!ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_KR_SendingEmailtoVendor','KR')){
            Messaging.SingleEmailMessage[] mailList = new Messaging.SingleEmailMessage[]{};
                String BccAddresses='prkmfm@gmail.com'; 
            OrgWideEmailAddress owe = [SELECT ID FROM OrgWideEmailAddress WHERE DisplayName like 'IT Service Desk'];
            
            for(String key:ProductOwnerMap.keySet()){
                List <String> ToAddresses = new List <String>(); 
                ToAddresses.add(key);
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setToAddresses(ToAddresses);
                message.setBccAddresses(new String[] {BccAddresses});//message.setTargetObjectId(ProductOwnerMap.get(key)[0].ASI_KOR_POSM_Order_Request__r.OwnerId);
                message.setOrgWideEmailAddressId(owe.Id);
                message.setUseSignature(false); 
                message.setSaveAsActivity(false); 
                String subject = '아래 Item에 대한 요청이 승인되었습니다.'; 
                String body = '<span style="font-family: Century Gothic;font-size:10px;" > POSM Order number:'  +ProductOwnerMap.get(key)[0].ASI_KOR_POSM_Order_Request__r.Name+ '<br/>Requester Name:'+ProductOwnerMap.get(key)[0].ASI_KOR_POSM_Order_Request__r.owner.Name+'<br/>요청 내역 (Request Details)<br/> </span>'; 
                body+='<table style="font-family: Century Gothic;font-size:10px; border-collapse: collapse; " ><tr style="border: 1px solid black;"><th style="border: 1px solid black;">No</th><th style="border: 1px solid black;"> POSM Order Line No</th><th style="border: 1px solid black;">Venue Name</th><th style="border: 1px solid black;">Item name & Code </th><th style="border: 1px solid black;">Quantity</th><th style="border: 1px solid black;">Remark</th></tr>';
                integer num=1;
                Set<String> Owneremail=new Set<String>();
                
                for(ASI_KOR_POSM_Order_Detail__c items:ProductOwnerMap.get(key)){ 
                    Owneremail.add(items.ASI_CRM_Owner_Email__c);
                    //ASI_CRM_Owner_Email__c
                    body+='<tr  style="border: 1px solid black;" ><td style="border: 1px solid black;" >'+string.valueOf(num)+'</td><td style="border: 1px solid black;" >'+items.Name+' </td><td style="border: 1px solid black;" >';
                    if(Global_RecordTypeCache.getRt(items.ASI_KOR_POSM_Order_Request__r.recordTypeId).developerName.contains('ASI_KOR_New_High_Value_POSM_Request') || Global_RecordTypeCache.getRt(items.ASI_KOR_POSM_Order_Request__r.recordTypeId).developerName.contains('ASI_KOR_Locked_High_Value_POSM_Request') ){
                        if(items.ASI_MFM_Venue__c!=null){
                            body+=items.ASI_MFM_Venue__r.Name;
                        }
                    }else{
                        if(items.ASI_KOR_POSM_Order_Request__r.ASI_KOR_POSM_TO_Venue__c!=null){
                            body+=items.ASI_KOR_POSM_Order_Request__r.ASI_KOR_POSM_TO_Venue__r.Name;
                        } 
                    }
                    
                    body+='</td><td style="border: 1px solid black;" >'+items.ASI_KOR_Item_Name__r.Name;
                    
                    if(items.ASI_KOR_Item_Name__r.ASI_KOR_Item_Code__c!=null){
                        body+='('+items.ASI_KOR_Item_Name__r.ASI_KOR_Item_Code__c+')';
                    }
                    
                    body+='</td><td style="border: 1px solid black;" >'+items.ASI_KOR_Quantity__c+'</td><td style="border: 1px solid black;" >';
                     if(items.ASI_KOR_Remarks__c!=null){
                        body+=items.ASI_KOR_Remarks__c;
                    }
                   
                    body+='</td></tr>';
                    num++;
                }
                body+='</table>';
                List<String> ccemaillist=new List<String>();
                ccemaillist.addAll(Owneremail);
                
                message.setCcAddresses(ccemaillist);
                message.setSubject(subject);
                message.setHtmlBody(body);///message.setBccSender(false); 
                mailList.add(message);
                
            }
            
            for(String key:DetailsLineMap.keySet()){
                List <String> ToAddresses = new List <String>(); 
                ToAddresses.add(key);
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setToAddresses(ToAddresses);
                message.setBccAddresses(new String[] {BccAddresses});//message.setTargetObjectId(DetailsLineMap.get(key)[0].ASI_KOR_POSM_Order_Request__r.OwnerId);
                message.setOrgWideEmailAddressId(owe.Id);
                message.setUseSignature(false); 
                message.setSaveAsActivity(false); 
                String subject = '아래 Item에 대한 요청이 승인되었습니다.'; 
                String body = '<span style="font-family: Century Gothic;font-size:10px;" > POSM Order number:'  +DetailsLineMap.get(key)[0].ASI_KOR_POSM_Order_Request__r.Name+ '<br/>Requester Name:'+DetailsLineMap.get(key)[0].ASI_KOR_POSM_Order_Request__r.owner.Name+'<br/>요청 내역 (Request Details)<br/> </span>'; 
                body+='<table style="font-family: Century Gothic;font-size:10px; border-collapse: collapse; " ><tr style="border: 1px solid black;"><th style="border: 1px solid black;">No</th><th style="border: 1px solid black;"> POSM Order Line No</th><th style="border: 1px solid black;">Venue Name</th><th style="border: 1px solid black;">Item name & Code </th><th style="border: 1px solid black;">Quantity</th><th style="border: 1px solid black;">Remark</th>';
                
                if(Global_RecordTypeCache.getRt(DetailsLineMap.get(key)[0].ASI_KOR_POSM_Order_Request__r.recordTypeId).developerName.contains('ASI_KOR_New_High_Value_POSM_Request') || Global_RecordTypeCache.getRt(DetailsLineMap.get(key)[0].ASI_KOR_POSM_Order_Request__r.recordTypeId).developerName.contains('ASI_KOR_Locked_High_Value_POSM_Request') ){
                    body+='<th style="border: 1px solid black;">Ship To</th>';
                }
                body+='</tr>';
                integer num=1;
                for(ASI_KOR_POSM_Order_Detail__c items:DetailsLineMap.get(key)){ 
                    body+='<tr  style="border: 1px solid black;" ><td style="border: 1px solid black;" >'+string.valueOf(num)+'</td><td style="border: 1px solid black;" >'+items.Name+' </td><td style="border: 1px solid black;" >';
                   
                    if(Global_RecordTypeCache.getRt(items.ASI_KOR_POSM_Order_Request__r.recordTypeId).developerName.contains('ASI_KOR_New_High_Value_POSM_Request') || Global_RecordTypeCache.getRt(items.ASI_KOR_POSM_Order_Request__r.recordTypeId).developerName.contains('ASI_KOR_Locked_High_Value_POSM_Request') ){
                        if(items.ASI_MFM_Venue__c!=null){
                            body+=items.ASI_MFM_Venue__r.Name;
                        }
                    }else{
                        if(items.ASI_KOR_POSM_Order_Request__r.ASI_KOR_POSM_TO_Venue__c!=null){
                            body+=items.ASI_KOR_POSM_Order_Request__r.ASI_KOR_POSM_TO_Venue__r.Name;
                        } 
                    }
                    
                    body+='</td><td style="border: 1px solid black;" >'+items.ASI_KOR_Item_Name__r.Name;
                    
                    if(items.ASI_KOR_Item_Name__r.ASI_KOR_Item_Code__c!=null){
                        body+='('+items.ASI_KOR_Item_Name__r.ASI_KOR_Item_Code__c+')';
                    }
                    
                    body+='</td><td style="border: 1px solid black;" >'+items.ASI_KOR_Quantity__c+'</td><td style="border: 1px solid black;" >';
                     if(items.ASI_KOR_Remarks__c!=null){
                        body+=items.ASI_KOR_Remarks__c;
                    }
                    
                    if(Global_RecordTypeCache.getRt(items.ASI_KOR_POSM_Order_Request__r.recordTypeId).developerName.contains('ASI_KOR_New_High_Value_POSM_Request') || Global_RecordTypeCache.getRt(items.ASI_KOR_POSM_Order_Request__r.recordTypeId).developerName.contains('ASI_KOR_Locked_High_Value_POSM_Request') ){
                        body+='</td><td style="border: 1px solid black;" >';                        
                        if(items.ASI_KOR_Ship_To_Address__c!=null){
                            body+=items.ASI_KOR_Ship_To_Address__c;
                        }
                    }
                    
                   
                    body+='</td></tr>';
                    num++;
                }
                body+='</table>';
                message.setSubject(subject);
                message.setHtmlBody(body);///message.setBccSender(false); 
                mailList.add(message);
                
            }
            Messaging.sendEmail(mailList);
            
        }
        
        
        
    } // end of BeforeUpdateMethod
    
    
    public static void routineAfterUpdate(list<ASI_KOR_POSM_Order_Request__c> trigger_new, map<Id, ASI_KOR_POSM_Order_Request__c> trigger_oldMap) {
        //Elufa PRA Support 2 Feb 2017  :  PRK MFM Phase 2    (Avaliable Qty & Already Used fields must be updated accordingly once the request is finally approved.)  Only for High Value POSM 
        set<id> approved_posm_set = new set<id>();
        Map<id, decimal> itemUsedQty = new Map<id, decimal> ();
        
        for (ASI_KOR_POSM_Order_Request__c POSM : trigger_new){
            if(trigger_oldMap.get(POSM.Id).ASI_KOR_Status__c == 'Submitted' && POSM.ASI_KOR_Status__c == 'Approved'){
                approved_posm_set.add(POSM.Id);
            }
            
        }
        
        if(approved_posm_set!= NULL &&  approved_posm_set.size()>0){
            for (ASI_KOR_POSM_Order_Detail__c line: [Select id,ASI_KOR_POSM_Order_Request__r.recordTypeId, ASI_KOR_Item_Name__c,ASI_KOR_POSM_Order_Request__r.Owner.Name,ASI_KOR_POSM_Order_Request__r.Name,ASI_KOR_Quantity__c,ASI_KOR_Item_Name__r.Name,ASI_KOR_Item_Name__r.ASI_MFM_Vender_Email_address__c,ASI_KOR_Item_Name__r.ASI_KOR_Item_Code__c,ASI_KOR_Ship_To_Address__c from ASI_KOR_POSM_Order_Detail__c where ASI_KOR_POSM_Order_Request__c in: approved_posm_set and ASI_KOR_Item_Name__c !=null ]){
                if(Global_RecordTypeCache.getRt(line.ASI_KOR_POSM_Order_Request__r.recordTypeId).developerName.contains('ASI_KOR_New_High_Value_POSM_Request') || Global_RecordTypeCache.getRt(line.ASI_KOR_POSM_Order_Request__r.recordTypeId).developerName.contains('ASI_KOR_Locked_High_Value_POSM_Request')){
                    if(!itemUsedQty.containsKey(line.ASI_KOR_Item_Name__c)){
                        itemUsedQty.put(line.ASI_KOR_Item_Name__c,line.ASI_KOR_Quantity__c);
                    }else{
                        decimal qty = itemUsedQty.get(line.ASI_KOR_Item_Name__c);
                        qty += (line.ASI_KOR_Quantity__c!=null?line.ASI_KOR_Quantity__c:0);
                        itemUsedQty.put(line.ASI_KOR_Item_Name__c, qty) ;
                    }
                }
                
            }//End of for loop
            sendEmailtoSupplierRun = false;
        }
        
        
        if(itemUsedQty!=null && itemUsedQty.size()>0){ // update POSM Product
            Map<Id, ASI_KOR_POSM_Product__c> updateProductList = new  Map<Id, ASI_KOR_POSM_Product__c> ();
            
            for(ASI_KOR_POSM_Product__c posmProduct: [Select id, ASI_MFM_Available_Qty__c, ASI_MFM_Already_Used__c from ASI_KOR_POSM_Product__c where RecordType.developerName='ASI_KOR_POSM_Product' and Id in: itemUsedQty.keySet() for update]){
                posmProduct.ASI_MFM_Available_Qty__c =  (posmProduct.ASI_MFM_Available_Qty__c !=null? posmProduct.ASI_MFM_Available_Qty__c:0) - itemUsedQty.get(posmProduct.Id);
                posmProduct.ASI_MFM_Already_Used__c = (posmProduct.ASI_MFM_Already_Used__c!=null? posmProduct.ASI_MFM_Already_Used__c:0) + itemUsedQty.get(posmProduct.Id);
                updateProductList.put(posmProduct.Id, posmProduct);
            }
            
            
            if(updatePOSMProductRun && updateProductList!=null){
                updatePOSMProductRun = false;
                update updateProductList.values();
            }
        }
    }
    
    
    
    
    public static void BeforeUpsertMethod(List<ASI_KOR_POSM_Order_Request__c> triggerNew, map<id, ASI_KOR_POSM_Order_Request__c> trigger_oldMap){
        set<id> posm_set = new set<id>();
        set<id> OwnerPOSMSet = new set<id>();
        for (ASI_KOR_POSM_Order_Request__c p:triggerNew) {
            posm_set.add(p.id); 
            if(trigger_oldMap==null){
                OwnerPOSMSet.add(p.OwnerId); 
            }else{
                if(trigger_oldMap.get(p.id).OwnerId != p.OwnerId){
                    OwnerPOSMSet.add(p.OwnerId); 
                }
            }
            
        }  
        Map<Id,set<Id>> ProductOwnerMap= New Map<Id,set<Id>> ();
        if (posm_set.size() > 0) {  
            Map<ID, User> mapUser= new Map<ID, User>();
            list<ASI_KOR_POSM_Order_Detail__c> POSM_list = [select Id,Name,ASI_KOR_POSM_Order_Request__c,ASI_KOR_Item_Name__r.ASI_MFM_Product_Owner__c   from ASI_KOR_POSM_Order_Detail__c where ASI_KOR_POSM_Order_Request__c in :posm_set for update];
            for(ASI_KOR_POSM_Order_Detail__c POSMLine:POSM_list){
                if(POSMLine.ASI_KOR_Item_Name__r.ASI_MFM_Product_Owner__c!=null){
                    if(!ProductOwnerMap.containsKey(POSMLine.ASI_KOR_POSM_Order_Request__c)){//New One 
                        set<Id> ProductOwnerIDSet =new set<Id>();
                        ProductOwnerIDSet.add(POSMLine.ASI_KOR_Item_Name__r.ASI_MFM_Product_Owner__c);
                        ProductOwnerMap.put(POSMLine.ASI_KOR_POSM_Order_Request__c,ProductOwnerIDSet);
                    }else{
                        ProductOwnerMap.get(POSMLine.ASI_KOR_POSM_Order_Request__c).add(POSMLine.ASI_KOR_Item_Name__r.ASI_MFM_Product_Owner__c);
                    }
                    //ProductOwnerIDSet.add(POSMLine.ASI_KOR_Item_Name__r.ASI_MFM_Product_Owner__c);
                }
            }//End of for Loop
            
            
            if(OwnerPOSMSet.size()>0){
                mapUser = new Map<ID,User>([SELECT ID, Name, ManagerID  FROM User WHERE id in : OwnerPOSMSet ]); //get all Korea User
                
            }
            for (ASI_KOR_POSM_Order_Request__c p:triggerNew) {
                setApproverToNull(p);
                if(mapUser.containsKey(p.OwnerId)){
                    p.ASI_MFM_Line_Manager__c=mapUser.get(p.OwnerId).ManagerID;
                }
                if(ProductOwnerMap.containsKey(p.Id)){
                    integer approver_count = 0;//  system.debug('Approver Id:  '+ProductOwnerMap.get(p.Id));
                    for(id owid:ProductOwnerMap.get(p.Id)){
                        if (approver_count == 0 && p.ASI_MFM_Line_Manager__c!=owid ) {
                            p.ASI_MFM_Approver_1__c = owid;
                        }else if (approver_count == 1 && p.ASI_MFM_Line_Manager__c!=owid ) {                                 
                            p.ASI_MFM_Approver_2__c =owid;
                        }else if (approver_count == 2 && p.ASI_MFM_Line_Manager__c!=owid ) {                                 
                            p.ASI_MFM_Approver_3__c =owid;
                        }else if (approver_count == 3 && p.ASI_MFM_Line_Manager__c!=owid ) {                                 
                            p.ASI_MFM_Approver_4__c =owid;
                        }else if (approver_count == 4 && p.ASI_MFM_Line_Manager__c!=owid ) {                                 
                            p.ASI_MFM_Approver_5__c =owid;
                        }else if (approver_count == 5 && p.ASI_MFM_Line_Manager__c!=owid ) {                                 
                            p.ASI_MFM_Approver_6__c = owid;
                        }else if (approver_count == 6 && p.ASI_MFM_Line_Manager__c!=owid ) {                                 
                            p.ASI_MFM_Approver_7__c = owid;
                        }else if (approver_count == 7 && p.ASI_MFM_Line_Manager__c!=owid ) {                                 
                            p.ASI_MFM_Approver_8__c = owid;
                        }else if (approver_count == 8 && p.ASI_MFM_Line_Manager__c!=owid ) {                                 
                            p.ASI_MFM_Approver_9__c = owid;
                        }else if (approver_count == 9 && p.ASI_MFM_Line_Manager__c!=owid ) {                                 
                            p.ASI_MFM_Approver_10__c =owid;
                        }else if (approver_count == 10 && p.ASI_MFM_Line_Manager__c!=owid ) {                                 
                            p.ASI_MFM_Approver_11__c =owid;
                        }      
                        
                        if(p.ASI_MFM_Line_Manager__c!=owid ){
                            approver_count++;
                        }
                        
                    }
                }
            } 
        }
        
    }// END OF BeforeUpsertMethod 
    
    
    
    public static void setApproverToNull(ASI_KOR_POSM_Order_Request__c posm)
    {
        String sysApprover;
        
        for(integer i = 1 ; i <=11 ; i++)
        {
            sysApprover = 'ASI_MFM_Approver_' + i + '__c';
            posm.put(sysApprover,null);
        }//end for
    }//end method: setApproverToNull

    private static List<String> barStylingRecordTypeIdList = new List<String>{
            Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Request__cASI_KOR_Bar_Styling_POSM_Request'),
            Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Request__cASI_KOR_Locked_Bar_Styling_Item_Request'),
            Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Request__cASI_KOR_Finalized_Bar_Styling_Item_Request')
    };
    private final static Map<String, ASI_KOR_Branches__c> BRANCH_CUSTOM_SETTING = ASI_KOR_Branches__c.getAll();
    private final static Map<String, ASI_KOR_Regions__c> REGION_CUSTOM_SETTING = ASI_KOR_Regions__c.getAll();
    private final static String BAR_STYLING_PERMISSION_SET_NAME = 'ASI_CRM_KR_BMKT_Power_User';

    public static void setDefaultContractPeriod(List<ASI_KOR_POSM_Order_Request__c> triggerNew) {

        for (ASI_KOR_POSM_Order_Request__c posmOrderRequest : triggerNew) {
            if (posmOrderRequest.ASI_KOR_Request_Target_Date__c != null && posmOrderRequest.ASI_KOR_Contract_Period__c == null) {
                Date requestTargetDate = posmOrderRequest.ASI_KOR_Request_Target_Date__c;
                Date contractPeriodDate = requestTargetDate.addMonths(6);

                posmOrderRequest.ASI_KOR_Contract_Period__c = String.valueOf(contractPeriodDate.year()) + String.valueOf(contractPeriodDate.month()).leftPad(2, '0');
            }
        }

    }

    public static void setAverageVolume(List<ASI_KOR_POSM_Order_Request__c> triggerNew) {
        final Integer numberOfMonths = 6;
        Date leastVenueDepletionDate = Date.today().toStartOfMonth().addMonths(-(numberOfMonths));
        Map<Id, Id> mapOfVenueToSubBrand = getMapOfVenueToSubBrand(triggerNew);
        List<String> itemGroupIdList = getItemGroupIdList(mapOfVenueToSubBrand.values());
        List<ASI_KOR_Venue_Depletion_Detail__c> venueDepletionDetailList = getVenueDepletionDetailList(mapOfVenueToSubBrand.keySet(), itemGroupIdList);

        for (ASI_KOR_POSM_Order_Request__c posmOrderRequest : triggerNew) {
            Decimal volume = 0;
            for (ASI_KOR_Venue_Depletion_Detail__c venueDepletionDetail : venueDepletionDetailList) {

                if (posmOrderRequest.ASI_KOR_POSM_TO_Venue__c == venueDepletionDetail.ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c
                        && posmOrderRequest.ASI_KOR_Sub_brand__c == venueDepletionDetail.ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__c) {
                    Date venueDepletionDate = Date.newInstance(
                            Integer.valueOf(venueDepletionDetail.ASI_KOR_Venue_Depletion__r.ASI_KOR_Year__c),
                            ASI_KOR_CommonUtils.getMonthNumber(venueDepletionDetail.ASI_KOR_Venue_Depletion__r.ASI_KOR_Month__c),
                            1
                    );

                    if (venueDepletionDate >= leastVenueDepletionDate
                            && venueDepletionDate != Date.today().toStartOfMonth()) {
                        volume += getQuantityInBottleOrActualCase(posmOrderRequest.ASI_KOR_UOM__c, venueDepletionDetail);
                    }
                }

            }
            posmOrderRequest.ASI_KOR_Average_Volume__c = (volume != 0 ? (volume / numberOfMonths) : 0);
        }
    }

    public static String validateActualSpendingAmount(
            List<ASI_KOR_POSM_Order_Request__c> triggerNew,
            Map<Id, Decimal> requestIdAmountMap)
    { //TODO: refactor this

        final String keyFieldForMapOfBranchCodeToRegionCode = 'ASI_KOR_Branch_Code__c';
        final String valueFieldForMapOfBranchCodeToRegionCode = 'ASI_KOR_Region_Code__c';

        Map<String, String> mapOfBranchCodeToRegionCode = ASI_KOR_CommonUtils.getMapFromCustomSetting(BRANCH_CUSTOM_SETTING, keyFieldForMapOfBranchCodeToRegionCode, valueFieldForMapOfBranchCodeToRegionCode);

        Map<String, Decimal> mapOfRegionNameToTotalActualSpendingAmount = new Map<String, Decimal>();
        mapOfRegionNameToTotalActualSpendingAmount =
                getMapOfRegionNameToTotalActualSpendingAmount(
                        mapOfRegionNameToTotalActualSpendingAmount, triggerNew, mapOfBranchCodeToRegionCode, requestIdAmountMap);
        system.debug('mapOfRegionNameToTotalActualSpendingAmount:' + mapOfRegionNameToTotalActualSpendingAmount);

        List<String> triggerNewIdList = ASI_KOR_CommonUtils.getStringFieldList(triggerNew, 'Id');
        List<String> fiscalYearList = ASI_KOR_CommonUtils.getStringFieldList(triggerNew, 'ASI_KOR_Fiscal_Year__c');
        List<String> subBrandIdList = ASI_KOR_CommonUtils.getStringFieldList(triggerNew, 'ASI_KOR_Sub_brand__c');
        List<ASI_KOR_Sub_Brand__c> subBrandList = [SELECT Id, ASI_KOR_Brand__c FROM ASI_KOR_Sub_Brand__c WHERE Id IN :subBrandIdList];
        List<String> brandIdList = ASI_KOR_CommonUtils.getStringFieldList(subBrandList, 'ASI_KOR_Brand__c');

        List<ASI_KOR_POSM_Order_Request__c> restOfThePOSMHeaderList = [
                SELECT ASI_KOR_Actual_Spending_Amount__c,
                        ASI_MFM_Sales_Branch__c,
                        ASI_KOR_Fiscal_Year__c,
                        ASI_KOR_Sub_brand__r.ASI_KOR_Brand__c
                FROM ASI_KOR_POSM_Order_Request__c
                WHERE Id NOT IN :triggerNewIdList
                AND RecordTypeId IN :barStylingRecordTypeIdList
                AND ASI_KOR_Fiscal_Year__c IN :fiscalYearList
                AND ASI_KOR_Sub_brand__r.ASI_KOR_Brand__c IN :brandIdList
        ];

        mapOfRegionNameToTotalActualSpendingAmount =
                getMapOfRegionNameToTotalActualSpendingAmount(
                        mapOfRegionNameToTotalActualSpendingAmount, restOfThePOSMHeaderList, mapOfBranchCodeToRegionCode, null);
        system.debug('mapOfRegionNameToTotalActualSpendingAmount:' + mapOfRegionNameToTotalActualSpendingAmount);

        List<String> regionNameList = new List<String>();
        for (String key : mapOfRegionNameToTotalActualSpendingAmount.keySet()) {
            if (regionNameList.indexOf(key.substring(0, key.indexOf('_'))) < 0) {
                regionNameList.add(key.substring(0, key.indexOf('_')));
            }

        }

        Map<String, Decimal> mapOfRegionNameToTotalBudgetAmount = getMapOfRegionNameToTotalBudgetAmount(regionNameList, brandIdList);

        for (String key : mapOfRegionNameToTotalBudgetAmount.keySet()) {
            System.debug(mapOfRegionNameToTotalBudgetAmount);
            System.debug(mapOfRegionNameToTotalActualSpendingAmount);
            if (mapOfRegionNameToTotalActualSpendingAmount.containsKey(key)
                    && mapOfRegionNameToTotalActualSpendingAmount.get(key) > mapOfRegionNameToTotalBudgetAmount.get(key)) {
//                triggerNew[0].addError('Total Actual Spending Amount cannot be greater than Total Budget Amount.');
                // 20190603
                return 'Total Actual Spending Amount cannot be greater than Total Budget Amount.';
            }
        }

        return null;
    }

    public static void grantRecordAccessToNewApprover(List<ASI_KOR_POSM_Order_Request__c> triggerNew) {
        List<ASI_KOR_POSM_Order_Request__Share> posmOrderRequestShareList = new List<ASI_KOR_POSM_Order_Request__Share>();
        List<String> permissionSetAssigneeList = new List<String>();

        for (ASI_KOR_POSM_Order_Request__c posmHeader : triggerNew) {
            if (String.isNotBlank(posmHeader.ASI_KOR_SYS_Approver_1__c)) {
                ASI_KOR_POSM_Order_Request__Share posmOrderRequestShare = new ASI_KOR_POSM_Order_Request__Share();

                posmOrderRequestShare.ParentId = posmHeader.Id;
                posmOrderRequestShare.UserOrGroupId = posmHeader.ASI_KOR_SYS_Approver_1__c;
                posmOrderRequestShare.AccessLevel = 'Edit';

                posmOrderRequestShareList.add(posmOrderRequestShare);

                permissionSetAssigneeList.add(posmHeader.ASI_KOR_SYS_Approver_1__c);
            }
        }

        Database.SaveResult[] recordShareSaveResultList = Database.insert(posmOrderRequestShareList, false);

    }

    public static void removeRecordAccessFromOldApprover(List<ASI_KOR_POSM_Order_Request__c> triggerOld) {
        List<ASI_KOR_POSM_Order_Request__Share> posmOrderRequestShareRemoveList = new List<ASI_KOR_POSM_Order_Request__Share>();
        Map<String, ASI_KOR_POSM_Order_Request__Share> mapOfParentIdUserOrGroupIdToPOSMShare = getMapOfParentIdUserOrGroupIdToPOSMShare(triggerOld);

        for (ASI_KOR_POSM_Order_Request__c posmHeader : triggerOld) {
            String key = '' + posmHeader.Id + '_' + posmHeader.ASI_KOR_SYS_Approver_1__c;
            if (mapOfParentIdUserOrGroupIdToPOSMShare.containsKey(key)) {
                posmOrderRequestShareRemoveList.add(mapOfParentIdUserOrGroupIdToPOSMShare.get(key));
            }
        }

        Database.DeleteResult[] removeRecordShareSaveResultList = Database.delete(posmOrderRequestShareRemoveList, false);

    }

    public static void sumActualSpendingAmountForBudget(List<ASI_KOR_POSM_Order_Request__c> triggerNew) {
        List<String> fiscalYearList = ASI_KOR_CommonUtils.getStringFieldList(triggerNew, 'ASI_KOR_Fiscal_Year__c');
        List<String> subBrandIdList = ASI_KOR_CommonUtils.getStringFieldList(triggerNew, 'ASI_KOR_Sub_brand__c');
        List<ASI_KOR_POSM_Order_Request__c> posmHeaderList = [
                SELECT Id,
                        ASI_MFM_Sales_Branch__c,
                        ASI_KOR_Fiscal_Year__c,
                        ASI_KOR_Actual_Spending_Amount__c,
                        ASI_KOR_Sub_brand__r.ASI_KOR_Brand__c
                FROM ASI_KOR_POSM_Order_Request__c
                WHERE RecordTypeId IN :barStylingRecordTypeIdList
                AND ASI_KOR_Fiscal_Year__c IN :fiscalYearList
                AND ASI_KOR_Sub_brand__c IN :subBrandIdList
        ];
        Map<String, Decimal> mapOfBranchCodeFiscalYearToTotalActualSpendingAmount = getMapOfBranchCodeFiscalYearToTotalActualSpendingAmount(posmHeaderList);

        List<ASI_KOR_Budget__c> budgetList = getBudgetList(triggerNew);

        for (ASI_KOR_Budget__c budget : budgetList) {
            if (String.isNotBlank(budget.ASI_KOR_Branch_Code__c) && String.isNotBlank(budget.ASI_KOR_Fiscal_Year__c) && String.isNotBlank(budget.ASI_KOR_Brand__c)) {
                String branchCodeFiscalYearOfBudget = budget.ASI_KOR_Branch_Code__c + budget.ASI_KOR_Fiscal_Year__c + budget.ASI_KOR_Brand__c;

                if (mapOfBranchCodeFiscalYearToTotalActualSpendingAmount.containsKey(branchCodeFiscalYearOfBudget)) {
                    budget.ASI_KOR_Actual_Spending_Amount__c = mapOfBranchCodeFiscalYearToTotalActualSpendingAmount.get(branchCodeFiscalYearOfBudget);
                }
            }
        }

        update budgetList;
    }

    public static void setSysApprover(List<ASI_KOR_POSM_Order_Request__c> triggerNew) {
        List<String> subBrandList = ASI_KOR_CommonUtils.getStringFieldList(triggerNew, 'ASI_KOR_Sub_brand__c');
        Map<String, ASI_MFM_Fix_Approval_Route__c> mapOfSubBrandToFixApprovalRoute = getMapOfSubBrandToFixApprovalRoute(subBrandList);

        for (ASI_KOR_POSM_Order_Request__c posmHeader : triggerNew) {
            String key = posmHeader.ASI_KOR_Sub_brand__c;
            if (mapOfSubBrandToFixApprovalRoute.containsKey(key)) {
                posmHeader.ASI_KOR_SYS_Approver_1__c = mapOfSubBrandToFixApprovalRoute.get(key).ASI_MFM_Corporate_Approver_1__c;
            }
        }
    }

    private static Map<String, ASI_KOR_POSM_Order_Request__Share> getMapOfParentIdUserOrGroupIdToPOSMShare(List<ASI_KOR_POSM_Order_Request__c> triggerOld) {
        List<ASI_KOR_POSM_Order_Request__Share> posmOrderRequestShareList = getPosmOrderRequestShareList(triggerOld);
        Map<String, ASI_KOR_POSM_Order_Request__Share> mapOfParentIdUserOrGroupIdToPOSMShare = new Map<String, ASI_KOR_POSM_Order_Request__Share>();
        for (ASI_KOR_POSM_Order_Request__Share posmOrderRequestShare : posmOrderRequestShareList) {
            String key = '' + posmOrderRequestShare.ParentId + '_' + posmOrderRequestShare.UserOrGroupId;
            if (!mapOfParentIdUserOrGroupIdToPOSMShare.containsKey(key)) {
                mapOfParentIdUserOrGroupIdToPOSMShare.put(key, posmOrderRequestShare);
            }
        }
        return mapOfParentIdUserOrGroupIdToPOSMShare;
    }

    private static List<ASI_KOR_POSM_Order_Request__Share> getPosmOrderRequestShareList(List<ASI_KOR_POSM_Order_Request__c> triggerOld) {
        List<String> posmHeaderIdList = ASI_KOR_CommonUtils.getStringFieldList(triggerOld, 'Id');
        List<String> oldApproverIdList = ASI_KOR_CommonUtils.getStringFieldList(triggerOld, 'ASI_KOR_SYS_Approver_1__c');
        List<ASI_KOR_POSM_Order_Request__Share> posmOrderRequestShareList = [
                SELECT Id,
                        ParentId,
                        UserOrGroupId,
                        AccessLevel
                FROM ASI_KOR_POSM_Order_Request__Share
                WHERE ParentId IN :posmHeaderIdList
                AND UserOrGroupId IN :oldApproverIdList
                AND AccessLevel = 'Edit'
        ];
        return posmOrderRequestShareList;
    }

    private static Map<String, Decimal> getMapOfRegionNameToTotalBudgetAmount(List<String> regionNameList, List<String> brandIdList) {
        Map<String, Decimal> mapOfRegionNameToTotalBudgetAmount = new Map<String, Decimal>();
        List<ASI_KOR_Budget__c> budgetList = [
                SELECT ASI_KOR_Region__c,
                        ASI_KOR_Brand__c,
                        ASI_KOR_Fiscal_Year__c,
                        ASI_KOR_Budget_Amount__c
                FROM ASI_KOR_Budget__c
                WHERE ASI_KOR_Region__c IN :regionNameList
                AND RecordTypeId = :Global_RecordTypeCache.getRtId('ASI_KOR_Budget__cASI_KOR_Bar_Styling')
                AND ASI_KOR_Brand__c IN :brandIdList
        ];

        for (ASI_KOR_Budget__c budget : budgetList) {
            String key = budget.ASI_KOR_Region__c + '_' + budget.ASI_KOR_Brand__c + '_' + budget.ASI_KOR_Fiscal_Year__c;
            if (mapOfRegionNameToTotalBudgetAmount.containsKey(key) && budget.ASI_KOR_Budget_Amount__c != null) {
                mapOfRegionNameToTotalBudgetAmount.put(key, mapOfRegionNameToTotalBudgetAmount.get(key) + budget.ASI_KOR_Budget_Amount__c);
            } else {
                mapOfRegionNameToTotalBudgetAmount.put(key, budget.ASI_KOR_Budget_Amount__c);
            }
        }
        return mapOfRegionNameToTotalBudgetAmount;
    }

    private static Map<String, Decimal> getMapOfRegionNameToTotalActualSpendingAmount(
            Map<String, Decimal> mapOfRegionNameToTotalActualSpendingAmount,
            List<ASI_KOR_POSM_Order_Request__c> posmHeaderList,
            Map<String, String> mapOfBranchCodeToRegionCode,
            Map<Id, Decimal> requestIdAmountMap)
    {
        final String keyFieldForMapOfRegionCodeToRegionName = 'ASI_KOR_Region_Code__c';
        final String valueFieldForMapOfRegionCodeToRegionName = 'Name';

        Map<String, String> mapOfRegionCodeToRegionName = ASI_KOR_CommonUtils.getMapFromCustomSetting(REGION_CUSTOM_SETTING, keyFieldForMapOfRegionCodeToRegionName, valueFieldForMapOfRegionCodeToRegionName);

        List<String> subBrandIdList = ASI_KOR_CommonUtils.getStringFieldList(posmHeaderList, 'ASI_KOR_Sub_brand__c');
        Map<Id, ASI_KOR_Sub_Brand__c> subBrandMap = new Map<Id, ASI_KOR_Sub_Brand__c>([SELECT Id, ASI_KOR_Brand__c FROM ASI_KOR_Sub_Brand__c WHERE Id IN :subBrandIdList]);

        for (ASI_KOR_POSM_Order_Request__c posmHeader : posmHeaderList) {
            String branchCode = posmHeader.ASI_MFM_Sales_Branch__c.substring(0, posmHeader.ASI_MFM_Sales_Branch__c.indexOf('-'));

            if (mapOfBranchCodeToRegionCode.keySet().contains(branchCode) && posmHeader.ASI_KOR_Actual_Spending_Amount__c != null) {
                String regionName = mapOfRegionCodeToRegionName.get(mapOfBranchCodeToRegionCode.get(branchCode));
                String key = regionName + '_' + subBrandMap.get(posmHeader.ASI_KOR_Sub_brand__c).ASI_KOR_Brand__c + '_' + posmHeader.ASI_KOR_Fiscal_Year__c;

                //===20190603======
                Decimal amount = posmHeader.ASI_KOR_Actual_Spending_Amount__c;
                if(requestIdAmountMap != null && requestIdAmountMap.size() > 0
                        && requestIdAmountMap.containsKey(posmHeader.Id)) {
                    amount = requestIdAmountMap.get(posmHeader.Id);
                }
                //==================

                if (mapOfRegionNameToTotalActualSpendingAmount.containsKey(key)) {
                    mapOfRegionNameToTotalActualSpendingAmount.put(key, mapOfRegionNameToTotalActualSpendingAmount.get(key) + amount);
                } else {
                    mapOfRegionNameToTotalActualSpendingAmount.put(key, amount);
                }
            }
        }
        return mapOfRegionNameToTotalActualSpendingAmount;
    }

    private static Map<String, Decimal> getMapOfBranchCodeFiscalYearToTotalActualSpendingAmount(List<ASI_KOR_POSM_Order_Request__c> triggerNew) {
        Map<String, Decimal> mapOfBranchCodeFiscalYearToTotalActualSpendingAmount = new Map<String, Decimal>();
        for (ASI_KOR_POSM_Order_Request__c posmHeader : triggerNew) {
            String branchCodeFiscalYearOfPOSMHeader = posmHeader.ASI_MFM_Sales_Branch__c.substring(0, posmHeader.ASI_MFM_Sales_Branch__c.indexOf('-')) + posmHeader.ASI_KOR_Fiscal_Year__c + posmHeader.ASI_KOR_Sub_brand__r.ASI_KOR_Brand__c;

            if (mapOfBranchCodeFiscalYearToTotalActualSpendingAmount.containsKey(branchCodeFiscalYearOfPOSMHeader) && posmHeader.ASI_KOR_Actual_Spending_Amount__c != null) {
                mapOfBranchCodeFiscalYearToTotalActualSpendingAmount.put(branchCodeFiscalYearOfPOSMHeader, mapOfBranchCodeFiscalYearToTotalActualSpendingAmount.get(branchCodeFiscalYearOfPOSMHeader) + posmHeader.ASI_KOR_Actual_Spending_Amount__c);
            } else {
                mapOfBranchCodeFiscalYearToTotalActualSpendingAmount.put(branchCodeFiscalYearOfPOSMHeader, posmHeader.ASI_KOR_Actual_Spending_Amount__c);
            }
        }
        return mapOfBranchCodeFiscalYearToTotalActualSpendingAmount;
    }

    private static List<ASI_KOR_Budget__c> getBudgetList(List<ASI_KOR_POSM_Order_Request__c> triggerNew) {

        List<String> fiscalYearList = ASI_KOR_CommonUtils.getStringFieldList(triggerNew, 'ASI_KOR_Fiscal_Year__c');
        List<String> brandIdList = getBrandIdList(triggerNew);
        List<String> branchCodeList = getBranchCodeList(triggerNew);

        List<ASI_KOR_Budget__c> budgetList = [
                SELECT Id,
                        ASI_KOR_Branch_Code__c,
                        ASI_KOR_Fiscal_Year__c,
                        ASI_KOR_Brand__c,
                        ASI_KOR_Actual_Spending_Amount__c
                FROM ASI_KOR_Budget__c
                WHERE ASI_KOR_Branch_Code__c IN :branchCodeList
                AND ASI_KOR_Fiscal_Year__c IN :fiscalYearList
                AND ASI_KOR_Brand__c IN :brandIdList
        ];
        return budgetList;
    }

    private static List<String> getBrandIdList(List<ASI_KOR_POSM_Order_Request__c> triggerNew) {
        List<String> brandIdList = new List<String>();
        List<String> posmHeaderIdList = ASI_KOR_CommonUtils.getStringFieldList(triggerNew, 'Id');
        List<ASI_KOR_POSM_Order_Request__c> posmHeaderList = [SELECT Id, ASI_KOR_Sub_brand__r.ASI_KOR_Brand__c FROM ASI_KOR_POSM_Order_Request__c WHERE Id IN :posmHeaderIdList];
        for (ASI_KOR_POSM_Order_Request__c posmHeader : posmHeaderList) {
            if (String.isNotBlank(posmHeader.ASI_KOR_Sub_brand__r.ASI_KOR_Brand__c) && !brandIdList.contains(posmHeader.ASI_KOR_Sub_brand__r.ASI_KOR_Brand__c)) {
                brandIdList.add(posmHeader.ASI_KOR_Sub_brand__r.ASI_KOR_Brand__c);
            }
        }
        return brandIdList;
    }

    private static List<String> getBranchCodeList(List<ASI_KOR_POSM_Order_Request__c> triggerNew) {
        List<String> branchCodeList = new List<String>();
        List<String> salesBranchList = ASI_KOR_CommonUtils.getStringFieldList(triggerNew, 'ASI_MFM_Sales_Branch__c');
        for (String salesBranch : salesBranchList) {
            branchCodeList.add(salesBranch.substring(0, salesBranch.indexOf('-')));
        }
        return branchCodeList;
    }

    private static Decimal getQuantityInBottleOrActualCase(String uom, ASI_KOR_Venue_Depletion_Detail__c venueDepletionDetail) {
        Decimal quantity = 0;

        if ('Actual Case' == uom && venueDepletionDetail.ASI_KOR_Venue_Depl_Info_Depletion_Case__c != null) {
            quantity = venueDepletionDetail.ASI_KOR_Venue_Depl_Info_Depletion_Case__c;
        } else if ('Bottle' == uom && venueDepletionDetail.ASI_KOR_Venue_Depl_Info_Depletion_Volume__c != null) {
            quantity = venueDepletionDetail.ASI_KOR_Venue_Depl_Info_Depletion_Volume__c;
        }

        return quantity;
    }

    private static List<String> getItemGroupIdList(List<Id> subBrandIdList) {
        List<ASI_KOR_Item_Group__c> itemGroupList = [
                SELECT Id
                FROM ASI_KOR_Item_Group__c
                WHERE ASI_KOR_Sub_Brand__c IN :subBrandIdList
        ];

        return ASI_KOR_CommonUtils.getStringFieldList(itemGroupList, 'Id');
    }

    private static List<ASI_KOR_Venue_Depletion_Detail__c> getVenueDepletionDetailList(Set<Id> venueIdList, List<String> itemGroupIdList) {
        List<ASI_KOR_Venue_Depletion_Detail__c> depletionDetailList = [
                SELECT Id,
                        ASI_KOR_Item_Group_Code__c,
                        ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__c,
                        ASI_KOR_Venue_Depletion__r.ASI_KOR_Year__c,
                        ASI_KOR_Venue_Depletion__r.ASI_KOR_Month__c,
                        ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c,
                        ASI_KOR_Venue_Depl_Info_Depletion_Case__c,
                        ASI_KOR_Venue_Depl_Info_Depletion_Volume__c
                FROM ASI_KOR_Venue_Depletion_Detail__c
                WHERE ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c IN :venueIdList
                AND ASI_KOR_Item_Group_Code__c IN :itemGroupIdList
                AND ASI_KOR_Venue_Depletion__r.ASI_KOR_Year__c != NULL
                AND ASI_KOR_Venue_Depletion__r.ASI_KOR_Month__c != NULL
        ];

        return depletionDetailList;
    }

    private static Map<Id, Id> getMapOfVenueToSubBrand(List<ASI_KOR_POSM_Order_Request__c> triggerNew) {
        Map<Id, Id> mapOfVenueToSubBrand = new Map<Id, Id>();

        for (ASI_KOR_POSM_Order_Request__c posmOrderRequest : triggerNew) {
            mapOfVenueToSubBrand.put(posmOrderRequest.ASI_KOR_POSM_TO_Venue__c, posmOrderRequest.ASI_KOR_Sub_brand__c);
        }

        return mapOfVenueToSubBrand;
    }

    private static Map<String, ASI_MFM_Fix_Approval_Route__c> getMapOfSubBrandToFixApprovalRoute(List<String> subBrandList) {
        Map<String, ASI_MFM_Fix_Approval_Route__c> mapOfSubBrandToFixApprovalRoute = new Map<String, ASI_MFM_Fix_Approval_Route__c>();

        List<ASI_MFM_Fix_Approval_Route__c> fixApprovalRouteList = [
                SELECT ASI_MFM_Corporate_Approver_1__c,
                        ASI_KOR_Sub_brand__c
                FROM ASI_MFM_Fix_Approval_Route__c
                WHERE ASI_MFM_Module__c = 'Bar-Styling'
                AND ASI_KOR_Sub_brand__c IN :subBrandList
        ];

        for (ASI_MFM_Fix_Approval_Route__c fixApprovalRoute : fixApprovalRouteList) {
            if(!mapOfSubBrandToFixApprovalRoute.containsKey(fixApprovalRoute.ASI_KOR_Sub_brand__c)) {
                mapOfSubBrandToFixApprovalRoute.put(fixApprovalRoute.ASI_KOR_Sub_brand__c, fixApprovalRoute);
            }
        }

        return mapOfSubBrandToFixApprovalRoute;
    }

}