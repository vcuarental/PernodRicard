public without sharing class ASI_HK_CRM_SalesOrderExtraItemRequest implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public static final Set<String> ValidHoldCode = new Set<String> {
        'H1'
        , 'H2' 
        , 'H3'
        , 'H4'   
        , 'H5' 
        , 'H6'
        , 'H7'
        , 'H8' 
        , 'M0'
    };
    
    @TestVisible private static final String STATUS_CHECKING_EXTRA_ITEMS = 'Checking Extra Items';
    private static final Integer SCOPE = 10;
    public static final Integer MINUTES_TO_RETRY = 1;
    private static final String STATUS_FINISH = 'Hold Code Received';
    private static final Set<String> HOLD_CODE_DO_NOTHING = new Set<String> {
        'M0'
    };
    private static final String PATTERN_DO_NOTHING = '__DO_NOTHING__';
    private static final Set<String> QUERY_FIELDS = new Set<String> {
        'ASI_HK_CRM_Credit_Hold_Reason__c'
        , 'ASI_HK_CRM_SYS_Instant_Approve_Status__c'
        , 'ASI_HK_CRM_SYS_DocumentCompany__c'
        , 'ASI_HK_CRM_Business_Unit__c'
        , 'ASI_HK_CRM_Code__c'
        , 'ASI_HK_CRM_Customer_DA__r.Name'
        , 'ASI_HK_CRM_JDE_Order_Type_Code__c'
        , '(SELECT Id FROM ASI_HK_CRM_Sales_Order_Request_Items__r)'
        , 'ASI_HK_CRM_SO_External_ID__c' 
        , 'Name'
        , 'ASI_HK_CRM_Account_PA__r.Name'
        , 'ASI_HK_CRM_Customer_DA__r.name'
        , 'ASI_HK_CRM_Invalid_Hold_Code__c'
        , 'Name'
        , 'ownerId'
        , 'owner.email'
        , 'owner.Name'
        , 'ASI_HK_CRM_Has_Cancelled_Line_Item__c'
        , 'Id'

    };
    private static final String RT_DEVNAME_SKU_DEFAULT = ASI_HK_CRM_SKUGenerator.RT_Default;
    //Edited by 20140603 Fixed SQL Query Limit
    public static Map<Id, ASI_MFM_SKU_Code__c> skuPackSizeMap ;    
    
    private ASI_HK_CRM_SalesOrderManager.SalesOrderManagerHttpPort soPort;
    private Map<Integer, ASI_MFM_SKU_Code__c> skuShortIdToSKUMap;
    
    public static void processImmediately() {
                
        Integer countWaitingExtraItem = [SELECT COUNT() FROM AsyncApexJob WHERE apexClass.Name = 'ASI_HK_CRM_SalesOrderExtraItemRequest' and Status != 'Completed' and Status != 'Aborted' and Status != 'Failed'];
        System.debug('CountExtra1'+countWaitingExtraItem);
        if (countWaitingExtraItem > 0) {            
        } 
        else{ 
            database.executeBatch(new ASI_HK_CRM_SalesOrderExtraItemRequest(), SCOPE);
        }
        //database.executeBatch(new ASI_HK_CRM_SalesOrderExtraItemRequest(), SCOPE);
    }   
    
    private static void scheduleRequest() {
         
        Integer countWaitingExtraItem = [SELECT COUNT() FROM AsyncApexJob WHERE apexClass.Name = 'ASI_HK_CRM_SalesOrderExtraItemRequest' and Status != 'Completed' and Status != 'Aborted' and Status != 'Failed'];
        System.debug('CountExtra2'+countWaitingExtraItem);
        if (countWaitingExtraItem > 0) {            
        }  
        else{
            //ASI_HK_CRM_Batch_Schedule__c bd = ASI_HK_CRM_Batch_Schedule__c.getOrgDefaults();
            //System.abortJob(bd.ASI_HK_CRM_scheduled_id__c);           
            //bd.ASI_HK_CRM_scheduled_id__c = System.scheduleBatch(new ASI_HK_CRM_SalesOrderExtraItemRequest(), 'ASI_HK_CRM_SalesOrderExtraItemRequest', MINUTES_TO_RETRY, SCOPE);
            //update bd;
            System.scheduleBatch(new ASI_HK_CRM_SalesOrderExtraItemRequest(), 'ASI_HK_CRM_SalesOrderExtraItemRequest', MINUTES_TO_RETRY, SCOPE);
        }
        //System.scheduleBatch(new ASI_HK_CRM_SalesOrderExtraItemRequest(), 'ASI_HK_CRM_SalesOrderExtraItemRequest', MINUTES_TO_RETRY, SCOPE);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('datb3'+dateTime.now());
        return Database.getQueryLocator(ASI_HK_CRM_CommonUtils.genQueryString(QUERY_FIELDS, 'ASI_HK_CRM_Sales_Order__c', 'ASI_HK_CRM_Order_Status_Name__c = :STATUS_CHECKING_EXTRA_ITEMS AND ASI_HK_CRM_Is_Web_Service_Failed__c != TRUE AND ASI_HK_CRM_Invalid_Hold_Code__c != TRUE AND ASI_HK_CRM_Actual_Approve_User__c=\'' + UserInfo.getUserId() + '\''));
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> sObjList) {
        System.debug('datb4'+dateTime.now() + 'SO size' + sObjList.size());
        if (sObjList != null && sObjList.size() > 0) {
            System.debug('datb5'+dateTime.now());
            //Edited by 20140603 Fixed SQL Query Limit
            final String RTDEVNAME_SKU_DEFAULT = 'ASI_HK_CRM_SKU'; 
            skuPackSizeMap =  new Map<Id, ASI_MFM_SKU_Code__c>([select id,ASI_HK_CRM_Packaging_Size__c,ASI_HK_CRM_External_Short_ID__c from ASI_MFM_SKU_Code__c WHERE RecordType.DeveloperName = :RTDEVNAME_SKU_DEFAULT]);
            
            List<ASI_HK_CRM_Sales_Order__c> soList = (List<ASI_HK_CRM_Sales_Order__c>)sObjList;
            System.debug('datb6'+dateTime.now());
            initSalesOrderPortIfNeeded();
            initSkuMap();
            System.debug('datb7'+dateTime.now());
            List<ASI_HK_CRM_Sales_Order__c> updateSOList = new List<ASI_HK_CRM_Sales_Order__c>();
            List<ASI_HK_CRM_Sales_Order_Item__c> deleteSODetailList = new List<ASI_HK_CRM_Sales_Order_Item__c>();
            List<ASI_HK_CRM_Sales_Order_Item__c> insertSODetailList = new List<ASI_HK_CRM_Sales_Order_Item__c>();
            List<Approval.ProcessSubmitRequest> approvalReqList = new List<Approval.ProcessSubmitRequest>();
            List<ASI_HK_CRM_WebService_Debug_Log__c> insertLogList = new List<ASI_HK_CRM_WebService_Debug_Log__c>();
            //** id set of the batch sales order
            Set<ID> soIDSET = new set<ID>();
            for (ASI_HK_CRM_Sales_Order__c so : soList) {
                
                ASI_HK_CRM_WebService_Debug_Log__c log = new ASI_HK_CRM_WebService_Debug_Log__c();
                log.ASI_HK_CRM_WebServiceName__c = 'ASI_HK_CRM_SalesOrderExtraItemRequest';
                log.ASI_HK_CRM_Submitter__c = so.ownerId;
                log.Name = so.Name;
                log.ASI_HK_CRM_Before_call_webservice__c = DateTime.now();
                try {
                    //validateHoldCode(so);
                    // Call webservice to get extra sales order items                    
                    ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesHeader showSalesHeader = checkForExtraItems(so);
                    log.ASI_HK_CRM_Success__c = true;
                    log.ASI_HK_CRM_After_call_web_service__c = DateTime.now();
                    insertLogList.add(log);
                    if (showSalesHeader != null) { // if successful
                        System.debug('datb10'+dateTime.now());
                        updateSOList.add(so);       //Abel change positon
                        System.debug('datb11'+dateTime.now());
                        if (so.ASI_HK_CRM_Sales_Order_Request_Items__r != null) {
                            System.debug('datb12'+dateTime.now());
                            deleteSODetailList.addAll(so.ASI_HK_CRM_Sales_Order_Request_Items__r);
                        }
                        // Convert the webservice response to sales order details
                        List<ASI_HK_CRM_Sales_Order_Item__c> soDetails = convertShowSalesHeaderToSODetails(so, showSalesHeader);
                        System.debug('datb13'+dateTime.now());
                        //Comment should delete afterward
                        for (ASI_HK_CRM_Sales_Order_Item__c lb : soDetails){
                            System.debug('datb14'+dateTime.now());
                            ASI_MFM_SKU_Code__c tempSku = skuPackSizeMap.get(lb.ASI_HK_CRM_SKU__c);
                            Decimal tempPackSize = tempSku != null ? tempSku.ASI_HK_CRM_Packaging_Size__c : null;
                            if (lb.ASI_HK_CRM_Price__c != null && tempPackSize != null && tempPackSize > 0)
                                System.debug('datb15'+dateTime.now());
                                lb.ASI_HK_CRM_Price__c = lb.ASI_HK_CRM_Price__c/tempPackSize;
                            
                        }
                         
                        if (soDetails != null && soDetails.size() > 0)
                            System.debug('datb16'+dateTime.now());
                            insertSODetailList.addAll(soDetails);
                            System.debug('datb17'+dateTime.now());
                        // Check if approval process is needed
                        String changeStatusWithoutApproval = statusIfBypassApproval(so);
                        if (changeStatusWithoutApproval == null) { // Need approval process
                            System.debug('datb18'+dateTime.now());
                            Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
                            approvalReq.setObjectId(so.Id);
                            approvalReqList.add(approvalReq);
                        } else if (changeStatusWithoutApproval != PATTERN_DO_NOTHING) { // Need to directly update the status
                            System.debug('datb19'+dateTime.now());
                            so.ASI_HK_CRM_Order_Status_Name__c = changeStatusWithoutApproval;
                        } 
                        //** get so id set 
                        if (so.ASI_HK_CRM_Order_Status_Name__c == 'Hold Code Received')
                            soIDSET.add(so.id);
                        //** Finish getting so id set
                    }
                } catch (Exception e) { 
                    log.ASI_HK_CRM_Success__c = false;
                    log.ASI_HK_CRM_After_call_web_service__c = DateTime.now();
                    log.ASI_HK_CRM_WebService_Error_Message__c = e.getMessage();
                    insertLogList.add(log);
                    System.debug(e);
                    so.ASI_HK_CRM_Is_Web_Service_Failed__c = true;
                    so.ASI_HK_CRM_WebService3_isFailed__c = true;
                    so.ASI_HK_CRM_WebService3_Error_Message__c = e.getMessage();
                    so.ASI_HK_CRM_Order_Status_Name__c = 'Web Service Error';
                    updateSOList.add(so);
                    //ASI_HK_CRM_SalesOrderRequestSubmit.sendAlertEmail(so, e.getMessage(),'Get extraItem Failure, Order have been created in JDE');
                     
                }
            }
            System.Savepoint sp = database.setSavepoint();
            try {
                System.debug('afg1');
                //for (ASI_HK_CRM_Sales_Order_Item__c lb : insertSODetailList){
                //    System.debug('afg3'+lb.ASI_HK_CRM_Price__c);
                //    System.debug('afg4'+lb.ASI_HK_CRM_Quantity__c);
                //}
                insert insertlogList;
                delete deleteSODetailList;
                insert insertSODetailList;
                update updateSOList;
                
                /*for(ASI_HK_CRM_Sales_Order__c updateSO : updateSOList){
                    if(updateSO.ASI_HK_CRM_Has_Cancelled_Line_Item__c){
                        sendHasUnavailableEmail(updateSO);
                    }
                }*/
                // Above code already implemented in an after trigger, no need to send again
                //Edited by Introv 20131119
                //for (Approval.ProcessSubmitRequest approvalReq : approvalReqList)
                //    Approval.process(approvalReq);
                
                //Start Checking any approval process is submitted
                Map<String, Id> submittedIds = new Map<String, Id>();
                
                for (ProcessInstance pa : 
                    [Select Id, TargetObjectId, Status from ProcessInstance where TargetObjectId in :updateSOList ])
                    {
                        System.debug('afg2' + pa.Status);
                        if (pa.Status == 'Started')
                        {
                            System.debug('afg3');
                            submittedIds.put(pa.TargetObjectId, pa.Id);
                        }
                        if (pa.Status == 'Pending')
                        {
                            System.debug('afg4');
                            submittedIds.put(pa.TargetObjectId, pa.Id);
                        }
                    }
                for (Approval.ProcessSubmitRequest approvalReq : approvalReqList)
                {
                    if ( !submittedIds.containsKey(approvalReq.objectId ))
                         Approval.process(approvalReq);
                }
                //End Checking any approval process is submitted
                
            //** Implementation by Conrad : set next approver 
            //if (soIDSET.size() > 0)
                ASI_HK_CRM_SalesOrderNextApprover.updateApprover2(soIdSet);
            //** End of implementation
                
            } catch (Exception e) {
                System.debug('has123');
                database.rollback(sp);
                System.debug(e);
                if(e.getMessage().contains('Cannot submit object already in process')){           
                    return;      
                }
                else if(e.getMessage().contains('ENTITY_IS_DELETED, entity is deleted')){
                    return;
                }//20140704 Steve Added catch applicable process error
                else if (e.getMessage().contains('NO_APPLICABLE_PROCESS')){
                    return;
                }
                else{
                    throw e;
                }   
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        Integer countWaitingSO = [SELECT COUNT() FROM ASI_HK_CRM_Sales_Order__c WHERE ASI_HK_CRM_Order_Status_Name__c = :STATUS_CHECKING_EXTRA_ITEMS AND ASI_HK_CRM_Is_Web_Service_Failed__c != TRUE AND ASI_HK_CRM_Actual_Approve_User__c=:UserInfo.getUserId()];
        if (countWaitingSO > 0) {
            try{
                scheduleRequest();
            }  catch (Exception e) {
                 if(e.getMessage().contains('is already scheduled for execution')){           
                    return;      
                }
            }
        } 
    }
    
    private ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesHeader checkForExtraItems(ASI_HK_CRM_Sales_Order__c so) {
        ASI_HK_CRM_SalesOrderManagerTypes.GetSalesHeader reqInput = new ASI_HK_CRM_SalesOrderManagerTypes.GetSalesHeader();
        reqInput.company = so.ASI_HK_CRM_SYS_DocumentCompany__c;
        reqInput.businessUnit = so.ASI_HK_CRM_Business_Unit__c;
        ASI_HK_CRM_SalesOrderManagerTypes.SalesOrderKey soKey = new ASI_HK_CRM_SalesOrderManagerTypes.SalesOrderKey();
        reqInput.salesOrderKey = soKey;
        soKey.documentNumber = Integer.valueOf(so.ASI_HK_CRM_Code__c);
        soKey.documentCompany = reqInput.company;
        soKey.documentTypeCode = so.ASI_HK_CRM_JDE_Order_Type_Code__c;
        
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesOrder reqResult = soPort.getSalesOrder(reqInput);
        if (reqResult != null && reqResult.header != null && reqResult.header.size() > 0) {
            so.ASI_HK_CRM_Order_Status_Name__c = STATUS_FINISH;
            System.debug('clkHEADER ' + reqResult.header[0]);
            return reqResult.header[0];
        }
        return null;
    }
    
    private List<ASI_HK_CRM_Sales_Order_Item__c> convertShowSalesHeaderToSODetails(ASI_HK_CRM_Sales_Order__c so, ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesHeader showSalesHeader) {
        List<ASI_HK_CRM_Sales_Order_Item__c> soDetails = new List<ASI_HK_CRM_Sales_Order_Item__c>();
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetail[] showSalesDetailList = showSalesHeader.detail;
        if (showSalesDetailList != null) {
            for (ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetail showSalesDetail : showSalesDetailList) {
                if ('999' != showSalesDetail.statusCodeNext) {
                    // product & product.item
                    ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailProduct product = showSalesDetail.product;
                    ASI_HK_CRM_SalesOrderManagerTypes.ShowDetailItem item = product != null ? product.item : null;
                    // UserReservedData
                    ASI_HK_CRM_SalesOrderManagerTypes.UserReservedData urd = showSalesDetail.UserReservedData;
                    // lineBilling & lineBilling.linePricing
                    ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailLineBilling lineBilling = showSalesDetail.lineBilling;
                    ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailLinePricing linePricing = lineBilling != null ? lineBilling.linePricing : null;
                    if (item == null || linePricing == null) {
                        throw new SalesOrderExtraItemException('Invalid Sales Order detail from web service');
                    }
                    // sku
                    ASI_MFM_SKU_Code__c sku = this.skuShortIdToSKUMap.get(item.itemId);
                    if (sku == null) {
                        throw new SalesOrderExtraItemException(String.format('Unknown SKU Short ID: {0}', new String[] {String.valueOf(item.itemId)}));
                    } 
                    // Create Salesforce Sales Order
                    ASI_HK_CRM_Sales_Order_Item__c soDetail = new ASI_HK_CRM_Sales_Order_Item__c();
                    soDetail.ASI_HK_CRM_Sales_Order__c = so.Id;
                    soDetail.ASI_HK_CRM_SKU__c = sku.Id;
                    soDetail.ASI_HK_CRM_Doc_Line_Num__c = showSalesDetail.documentLineNumber;
                    soDetail.ASI_HK_CRM_Quantity__c = showSalesDetail.quantityOrdered;
                    soDetail.ASI_HK_CRM_UOM__c = showSalesDetail.unitOfMeasureCodeTransaction;
                    soDetail.ASI_HK_CRM_Price__c = linePricing.priceUnitDomestic;
                    soDetail.ASI_HK_CRM_Original_Price__c = urd.userReservedAmount;
                    soDetail.ASI_HK_CRM_Free_Issue__c = urd.userReservedReference;
                    soDetails.add(soDetail);
                } 
                else { 
                    // product & product.item
                    ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailProduct product = showSalesDetail.product;
                    ASI_HK_CRM_SalesOrderManagerTypes.ShowDetailItem item = product != null ? product.item : null;
                    // UserReservedData
                    ASI_HK_CRM_SalesOrderManagerTypes.UserReservedData urd = showSalesDetail.UserReservedData;
                    // lineBilling & lineBilling.linePricing
                    ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailLineBilling lineBilling = showSalesDetail.lineBilling;
                    ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailLinePricing linePricing = lineBilling != null ? lineBilling.linePricing : null;
                    if (item == null || linePricing == null) {
                        throw new SalesOrderExtraItemException('Invalid Sales Order detail from web service');
                    }
                    // sku
                    ASI_MFM_SKU_Code__c sku = this.skuShortIdToSKUMap.get(item.itemId);
                    if (sku == null) {
                        throw new SalesOrderExtraItemException(String.format('Unknown SKU Short ID: {0}', new String[] {String.valueOf(item.itemId)}));
                    }
                    // Create Salesforce Sales Order
                    ASI_HK_CRM_Sales_Order_Item__c soDetail = new ASI_HK_CRM_Sales_Order_Item__c();
                    soDetail.ASI_HK_CRM_Sales_Order__c = so.Id;
                    soDetail.ASI_HK_CRM_SKU__c = sku.Id;
                    soDetail.ASI_HK_CRM_Doc_Line_Num__c = showSalesDetail.documentLineNumber;
                    soDetail.ASI_HK_CRM_Cancel_Qty__c = showSalesDetail.quantityCanceled;
                    //soDetail.ASI_HK_CRM_Quantity__c = showSalesDetail.quantityOrdered;
                    soDetail.ASI_HK_CRM_UOM__c = showSalesDetail.unitOfMeasureCodeTransaction;
                    soDetail.ASI_HK_CRM_Price__c = linePricing.priceUnitDomestic;
                    soDetail.ASI_HK_CRM_Original_Price__c = urd.userReservedAmount;
                    soDetail.ASI_HK_CRM_Free_Issue__c = urd.userReservedReference;
                    soDetails.add(soDetail);
                    so.ASI_HK_CRM_Has_Cancelled_Line_Item__c = true;
                }
            }
        }
        return soDetails;
    }
    
    private String statusIfBypassApproval(ASI_HK_CRM_Sales_Order__c so) {
        if (!String.isBlank(so.ASI_HK_CRM_Credit_Hold_Reason__c) && HOLD_CODE_DO_NOTHING.contains(so.ASI_HK_CRM_Credit_Hold_Reason__c)) {
            return PATTERN_DO_NOTHING;
        } else if (!String.isBlank(so.ASI_HK_CRM_SYS_Instant_Approve_Status__c)) {
            return so.ASI_HK_CRM_SYS_Instant_Approve_Status__c;
        }
        return null;
    }
    
    private void initSalesOrderPortIfNeeded() {
        if (soPort == null) {
            List<ASI_HK_CRM_Web_Service_Setting__c> wsSettings = [
                SELECT Id, ASI_HK_CRM_Base_URL__c, ASI_HK_CRM_Username__c, ASI_HK_CRM_Password__c
                FROM ASI_HK_CRM_Web_Service_Setting__c
                WHERE ASI_HK_CRM_Key__c = 'ASI_HK_CRM_SalesOrderSubmit'
            ];
            if (wsSettings.size() == 1) {
                ASI_HK_CRM_Web_Service_Setting__c wsSetting = wsSettings[0];
                soPort = new ASI_HK_CRM_SalesOrderManager.SalesOrderManagerHttpPort(
                    wsSetting.ASI_HK_CRM_Base_URL__c
                    , wsSetting.ASI_HK_CRM_Username__c
                    , wsSetting.ASI_HK_CRM_Password__c
                );
                soPort.timeout_x = 120000;
            } else if (wsSettings.size() == 0) {
                throw new SalesOrderExtraItemException('ASI HK CRM web service setting not found');
            } else {
                throw new SalesOrderExtraItemException('Duplicate ASI HK CRM web service settings');
            }
        }
    }
    
    private void initSkuMap() {
        if (skuShortIdToSKUMap == null) {
            skuShortIdToSKUMap = new Map<Integer, ASI_MFM_SKU_Code__c>();
            List<ASI_MFM_SKU_Code__c> skuList = [SELECT Id, ASI_HK_CRM_External_Short_ID__c FROM ASI_MFM_SKU_Code__c WHERE RecordType.DeveloperName = :RT_DEVNAME_SKU_DEFAULT];
            for (ASI_MFM_SKU_Code__c sku : skuList) {
                if (sku.ASI_HK_CRM_External_Short_ID__c != null)
                    skuShortIdToSKUMap.put(sku.ASI_HK_CRM_External_Short_ID__c.intValue(), sku);
            }
        }
    }
/*    
    private void validateHoldCode(ASI_HK_CRM_Sales_Order__c so){
        if(validHoldCode.contains(so.ASI_HK_CRM_Credit_Hold_Reason__c){
            return;
        }
        else{
            
        }
    }
*/    
    public class SalesOrderExtraItemException extends Exception {
        
    }
    
    public void sendHasUnavailableEmail(ASI_HK_CRM_Sales_Order__c so){
        System.debug('aku1'+so.Name); 
        System.debug('aku2'+so.owner.Name);
        System.debug('aku3'+so.Id);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        EmailTemplate et = [select id, subject, Body, developerName from EmailTemplate where developerName = 'ASI_HK_CRM_SO_Has_Unavailable_Item'];
        //String[] toAddresses = new String[]{'cpantua@laputatech.com'};
        //String[] toAddresses = new String[]{'aku@laputatech.com','vkoh@laputatech.com','kxie@laputatech.com'};
        //String[] toAddresses = getRecipientFromCustomSet();
        //String[] toAddresses = new String[]{'vkoh@laputatech.com'};       
        String[] toAddresses = new String[]{'aku@laputatech.com'};  
        //String[] toAddresses = new String[]{};
        if (so.ownerId != null) { 
            if(so.owner.email != null){ 
                System.debug('aku4'+so.owner.email);
                toAddresses.add(so.owner.email);
            }
        }       
        System.debug('address mailing3:'+toAddresses);
        mail.setToAddresses(toAddresses);
        //Mailing Subject
        String mailingSubject = et.subject;
        mailingSubject = mailingSubject.replace('soNumber', so.Name);
        
        //Mailing Message
        String mailingBody = et.body;
        mailingBody = mailingBody.replace('{soOwner}', so.owner.Name);
        mailingBody = mailingBody.replace('{soURL}', URL.getSalesforceBaseUrl().toExternalForm() + '/' + so.Id);
        mailingBody = mailingBody.replace('{customerDA}', so.ASI_HK_CRM_Customer_DA__r.Name);
        
        mail.setSubject(mailingSubject);              
        mail.setPlainTextBody(mailingBody);
        mail.setEmailPriority('High');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});        
    }    
}