public without sharing class ASI_MFM_POReceipt_TriggerClass {
    public static void routineAfterUpdate(list<ASI_MFM_PO_Receipt__c> trigger_new, map<id, ASI_MFM_PO_Receipt__c> trigger_oldMap) {        
        Map<string, id> MRecTypeID = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Receipt__c');
        Set<id> TRRecTypeID = new Set<id>();
        for(String key : MRecTypeID.keySet()){
            if(key.contains('TR_PO_Receipt')){
                TRRecTypeID.add(MRecTypeID.get(key));
            }
        }
        Set<id> TRPoReceiptID = new Set<id>();
         for (ASI_MFM_PO_Receipt__c p:trigger_new){
            //Updated by Wilken on 20150306, only send email when status change from Draft to Final
            if(TRRecTypeID.contains(p.recordtypeid) && p.ASI_MFM_Status__c == 'Final' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Draft'){
                 TRPoReceiptID.add(p.id);
            }
         }
        Set<id> SPORecItemID = new Set<id>();
        Set<id> SPOID = new Set<id>();
        List<ASI_MFM_PO_Receipt_Item__c > porList = [select id, recordtypeid,ASI_MFM_PO_Line_Item__c, ASI_MFM_PO_Receipt__r.recordtypeid,ASI_MFM_PO__c from ASI_MFM_PO_Receipt_Item__c  where ASI_MFM_PO_Receipt__r.id in:TRPoReceiptID];
        Map<id, ASI_MFM_PO_Receipt_Item__c> MPOReceiptItem = new Map<id,ASI_MFM_PO_Receipt_Item__c>();
        for(ASI_MFM_PO_Receipt_Item__c PORecItem : porList ){     
            //Modified by Wilken on 20140429, PO Receipt used by India and Gulf MFM
            if(TRRecTypeID.contains(PORecItem.ASI_MFM_PO_Receipt__r.recordtypeid)){
                SPORecItemID.add(PORecItem.ASI_MFM_PO_Line_Item__c);
                MPOReceiptItem.put(PORecItem.ASI_MFM_PO_Line_Item__c,PORecItem);
                if (PORecItem.ASI_MFM_PO__c != null && !SPOID.contains(PORecItem.ASI_MFM_PO__c))
                    SPOID.add(PORecItem.ASI_MFM_PO__c);
            }
        }
           if(SPORecItemID != null && SPORecItemID.size()>0){
            // Attach PO Receipt to PO directly for displaying in related list on PO page
            List<ASI_MFM_PO_Line_Item__c> LPOItem = [Select id, ASI_MFM_PO__c, name, ASI_MFM_Amount__c, 
                ASI_MFM_Paid_Amount__c, ASI_MFM_CN_Receipt_Amount__c, ASI_MFM_CN_PrePaid_Amount__c,ASI_MFM_CN_Paid_Amount__c, ASI_MFM_Pay_Acc__c, ASI_MFM_BU_Code__r.ASI_MFM_Location__c 
                from ASI_MFM_PO_Line_Item__c where id IN :SPORecItemID];
            //List<ASI_MFM_PO_Receipt_Item__c> LPOReceiptItemUpdate = new List<ASI_MFM_PO_Receipt_Item__c>();
            
            //Send Email
            try{
                if (LPOItem.size() > 0){
                    
                    List <String> ToAddresses = new List <String>();                       
                    if (LPOItem[0].ASI_MFM_Pay_Acc__c != null && LPOItem[0].ASI_MFM_Pay_Acc__c == 'p'){
                        if (LPOItem[0].ASI_MFM_BU_Code__r.ASI_MFM_Location__c != null && LPOItem[0].ASI_MFM_BU_Code__r.ASI_MFM_Location__c == 'India'){
                            //Pay, India
                            for (ASI_MFM_Finance_Email__c Setting : ASI_MFM_Finance_Email__c.getAll().values()) {
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_India_Finance_Email_1__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_India_Finance_Email_1__c);
                                }
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_India_Finance_Email_2__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_India_Finance_Email_2__c );
                                }
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_India_Finance_Email_3__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_India_Finance_Email_3__c );
                                }
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_India_Finance_Email_4__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_India_Finance_Email_4__c );
                                }
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_India_Finance_Email_5__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_India_Finance_Email_5__c );
                                }
                            }
                        }
                        else {
                            //Pay, non-India
                            for (ASI_MFM_Finance_Email__c Setting : ASI_MFM_Finance_Email__c.getAll().values()) {
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_Finance_Email_1__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_Finance_Email_1__c);
                                }
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_Finance_Email_2__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_Finance_Email_2__c );
                                }
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_Finance_Email_3__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_Finance_Email_3__c );
                                }
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_Finance_Email_4__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_Finance_Email_4__c );
                                }
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_Finance_Email_5__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_Finance_Email_5__c );
                                }
                            }
                        }
                    }
                    else{
                        if (LPOItem[0].ASI_MFM_BU_Code__r.ASI_MFM_Location__c != null && LPOItem[0].ASI_MFM_BU_Code__r.ASI_MFM_Location__c == 'India'){
                            //Accrual, India
                            for (ASI_MFM_Finance_Email__c Setting : ASI_MFM_Finance_Email__c.getAll().values()) {
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_India_Acc_Finance_Email_1__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_India_Acc_Finance_Email_1__c );
                                }
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_India_Acc_Finance_Email_2__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_India_Acc_Finance_Email_2__c );
                                }
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_India_Acc_Finance_Email_3__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_India_Acc_Finance_Email_3__c);
                                }
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_India_Acc_Finance_Email_4__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_India_Acc_Finance_Email_4__c  );
                                }
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_India_Acc_Finance_Email_5__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_India_Acc_Finance_Email_5__c );
                                }
                            }
                        }
                        else {
                            //Accrual, non-India
                            for (ASI_MFM_Finance_Email__c Setting : ASI_MFM_Finance_Email__c.getAll().values()) {                        
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_Acc_Finance_Email_1__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_Acc_Finance_Email_1__c );
                                }
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_Acc_Finance_Email_2__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_Acc_Finance_Email_2__c );
                                }
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_Acc_Finance_Email_3__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_Acc_Finance_Email_3__c);
                                }
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_Acc_Finance_Email_4__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_Acc_Finance_Email_4__c  );
                                }
                                if(Setting.name == 'ATR' && Setting.ASI_MFM_Acc_Finance_Email_5__c != null){
                                   ToAddresses.add(Setting.ASI_MFM_Acc_Finance_Email_5__c );
                                }
                            }
                        }
                    }
                    String subject = 'PO Receipt Notification Email';
                    
                    String body = 'Please refer to the PO Receipt.'  + '\n';
                    
                    string URLLink;
                    for (id idS:SPOID )
                    {
                        URLLink = URL.getSalesforceBaseUrl().toExternalForm()   + '/' + idS ;
                        body += '<a href=\"'+URLLink+'\">'+URLLink+'</a>' + '\n' ;
                    }
                    ID userid = UserInfo.getUserId();
                    Id templateId; 
                    String templateApiName = 'ASI_MFM_TR_POReceipt_to_Finance_EmailTpt';
                    try {
                        templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;}
                    catch (Exception e) {
                        //throw new UtilException ('[U-03] Unable to locate EmailTemplate using name: ' + templateApiName + ' refer to Setup | Communications Templates ' + templateApiName);
                    }
                    
                    
                    User currentUser = [SELECT Id, Email FROM User WHERE Id =:userid];
                    // Define the email 
                    for(id rid : TRPoReceiptID){ 
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                    email.setTargetObjectId(currentUser.id );
                    email.setToAddresses( ToAddresses );
                    //email.setSubject( subject );
                    //email.setHtmlBody(body);
                    //email.setPlainTextBody( body );
                    email.setWhatId(rid );
                    email.setSaveAsActivity(false); 
                    email.setBccSender(false);
                    email.setUseSignature(false);
    
                    email.setTemplateId(templateId);
    
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
                    }
                }
            }
            catch (Exception e)
            {
              //result = 'Error occured. Please contact system administrator!';
              
            }

            
            // calculate receipt amount from YTD entered 
        }            
        for (ASI_MFM_PO_Receipt__c p:trigger_new){
            //Auto create Payment Request
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_GF')){
                Set<ID> poLineIDSet = new Set<ID>();
                Map<ID,Double> receiptAmountMap = new Map<ID,Double>();
                List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
                
                System.debug('PO Receipt routineAfterUpdate Status: ' + p.ASI_MFM_Status__c);
                
                if (p.ASI_MFM_Status__c == 'Final' && (trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Draft' || trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted')){
                    List<ASI_MFM_PO_Receipt_Item__c> pItems = [select ASI_MFM_Amount__c, ASI_MFM_PO_Line_Item__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Distributor_Amount__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_PO_Type__c, 
            ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c, ASI_MFM_Status__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c 
              from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO_Receipt__c = :p.id];
                    
                    Integer needPaymentCount = 0;
                    
                    for (ASI_MFM_PO_Receipt_Item__c pItem:pItems){
                        //Auto create dummy Payment after Event FOC PO Receipt is approved
                        if (pItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_PO_Type__c == 'Event FOC'){
                            needPaymentCount++;
                        }
                        
                        pItem.ASI_MFM_Status__c = 'Final';
                        poLineIDSet.add(pItem.ASI_MFM_PO_Line_Item__c);
                        receiptAmountMap.put(pItem.ASI_MFM_PO_Line_Item__c, pItem.ASI_MFM_Amount__c);
                    }
                    
                    update pItems;
                    
                    poLineList = [select ASI_MFM_Original_Receipt_Amount__c, ASI_MFM_Outstanding_Receipt_Balance__c from ASI_MFM_PO_Line_Item__c where id in :poLineIDSet];
                    
                    for (ASI_MFM_PO_Line_Item__c poLine:poLineList){
                        if (receiptAmountMap.get(poLine.ID) != null){
                            poLine.ASI_MFM_Original_Receipt_Amount__c = receiptAmountMap.get(poLine.ID);
                            poLine.ASI_MFM_Outstanding_Receipt_Balance__c = receiptAmountMap.get(poLine.ID);
                        }
                        //Update Receipt Date on PO Line for reporting
                        poLine.ASI_MFM_Receipt_Date__c = System.Date.today();
                    }
                    
                    update poLineList;
                    
                    if (needPaymentCount > 0){
                        User u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];

                        list<asi_mfm_role_prefix_relationship__c> px_list = new list<asi_mfm_role_prefix_relationship__c>();
                        ID paymentPrefix;
            
            //Wilken 20170308: Match each receipted PO Prefix TR Record Type to assign correct Payment Prefix
                        for (asi_mfm_role_prefix_relationship__c px:[select asi_mfm_prefix__c, ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c from asi_mfm_role_prefix_relationship__c
                             where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false and asi_mfm_prefix__r.asi_mfm_module__c = 'Payment' and asi_mfm_role_name__c = :u.userRole.developerName 
                                and asi_mfm_prefix__r.asi_mfm_country_name__c = 'GF']) {
                             px_list.add(px);    
                         }

                        /*if (px_list.size() == 1) {
                            paymentPrefix = px_list[0].asi_mfm_prefix__c;
                        }*/
            
            List<ASI_MFM_Payment__c> paymentList = new List<ASI_MFM_Payment__c>();
            Map<id,ASI_MFM_Payment__c> recItemIDPaymentMap = new Map<id,ASI_MFM_Payment__c>();
                        
                        List<ASI_MFM_Payment_Line_Item__c> payItemsList = new List<ASI_MFM_Payment_Line_Item__c>();
                        Integer counter = 1;
                        for (ASI_MFM_PO_Receipt_Item__c pItem:pItems){
                            if (pItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_PO_Type__c == 'Event FOC'){
                DateTime d = datetime.now();
                String invNum = 'SYS_' + d.format('yyyyMMdd hh:mm:ss') + '_' + String.valueOf(counter);
                
                //Wilken 20170308: Match Receipted PO Prefix TR Record Type to assign Payment Prefix
                for (ASI_MFM_Role_Prefix_Relationship__c r:px_list){
                  if (r.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c == pItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c)
                    paymentPrefix = r.ASI_MFM_Prefix__c;
                }
                
                ASI_MFM_Payment__c pay = new ASI_MFM_Payment__c(OwnerID = p.OwnerID, ASI_MFM_Status__c = 'Final', ASI_MFM_Payment_Date__c = date.today(), ASI_MFM_Currency__c = pItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c, 
                  recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment_Read_Only'), ASI_MFM_Prefix__c = paymentPrefix, ASI_MFM_Supplier_Name__c = pItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,
                  ASI_MFM_G_L_Date__c = date.today(), ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = invNum);
                
                paymentList.add(pay);
                
                recItemIDPaymentMap.put(pItem.id,pay);
                
                counter++;
                            }
                        }
            
            insert paymentList;
            
                        for (ASI_MFM_PO_Receipt_Item__c pItem:pItems){
                            if (pItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_PO_Type__c == 'Event FOC'){
                ASI_MFM_Payment_Line_Item__c payItem = new ASI_MFM_Payment_Line_Item__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_GF_Payment_Line_Item'), 
                                    ASI_MFM_Payment_Amount__c = pItem.ASI_MFM_Amount__c, ASI_MFM_Payment_Amount_Distributor__c = pItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_Distributor_Amount__c, ASI_MFM_Payment__c = recItemIDPaymentMap.get(pItem.id).id, ASI_MFM_PO_Line_Item__c = pItem.ASI_MFM_PO_Line_Item__c);
                  
                                payItemsList.add(payItem);
                            }
                        }            
            insert payItemsList;
                    }                    
                }
            }
        }
    }
    
    public static void routineBeforeUpdate(list<ASI_MFM_PO_Receipt__c> trigger_new, map<id, ASI_MFM_PO_Receipt__c> trigger_oldMap) {
        for (ASI_MFM_PO_Receipt__c p:trigger_new){
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_GF')){
                Boolean hasVAPPO = false;
                Set<String> currencySet = new Set<String>();
                
                List<ASI_MFM_PO_Receipt_Item__c> pItems = [select ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_PO_Type__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO_Receipt__c = :p.id];
                for (ASI_MFM_PO_Receipt_Item__c pItem:pItems){
                    if (pItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_PO_Type__c == 'VAP Brand Owner'){
                        hasVAPPO = true;
                    }
                    
                    //currencySet.add(pItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c);
                }
                
                /*if (currencySet.size() > 1)
                    p.addError('Please receipt PO of same currency only');*/
                
                System.debug('hasVAPPO: ' + hasVAPPO);
                if (hasVAPPO == true){
                    p.ASI_MFM_Has_VAP_PO__c = true;
                } 
                else {
                    p.ASI_MFM_Has_VAP_PO__c = false;                    
                }                
            }
        }
    }
    

    public static void routineBeforeDelete(list<ASI_MFM_PO_Receipt__c> trigger_old) {
        // Not allowed to delete if the PO Receipt is Final
       set<id> setLineId =new set<id>();
        set<id> po_set = new set<id>();
        for (ASI_MFM_PO_Receipt__c p:trigger_old) { 
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_GF') && p.ASI_MFM_Status__c == 'Final'){
                p.addError('Not allowed to delete because the PO Receipt is in \'Final\' status');
            }
            if (p.RecordTypeId != null && Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_JP')){
                setLineId.add(p.id);
            }
        }
        
        if(setLineId!=null){
            delete [select id from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO_Receipt__c in : setLineId];
        }
        
    }
    
}