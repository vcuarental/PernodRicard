//This class help to call the WebService if the submit_status = 'Interfaced to JDE'
//Modified 20140422 add handle status = 'Hold Code Received'
//Modified 20151109-add PA/DA list for contract use
//Modified 20151113-Change SUBMIT_COMPLETE_STATUS from "Hold Code Received" to "SA Approved"
//Added 20151223 - Add the submit for approval trigger

/*********************************************************************************
 * Name:ASI_HK_CRM_SalesOrderRequestSubmit
 * Description: 
 * Test Class: ASI_HK_CRM_SalesOrderTriggerTest, ASI_HK_CRM_SalesOrderRequestSubmitTest, ASI_HK_CRM_SalesOrderRequestDtEdTest
 * ASI_HK_CRM_SOApproveWithInputCONTest, ASI_HK_CRM_SalesOrderNextApproverTest, ASI_HK_CRM_SalesOrderRecallTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 07/01/2018       Wilken Lee          	[WL 1.0] Update SubmitSO to use Oracle SOA after HK JDE 920 upgrade
 * 03/07/2018       Wilken Lee          	[WL 2.0] Include M0 for approval process
*********************************************************************************/
public without sharing class ASI_HK_CRM_SalesOrderRequestSubmit extends ASI_HK_CRM_TriggerAbstract {
    
    @TestVisible private static final String SUBMIT_STATUS = 'Interfaced to JDE';
    @TestVisible private static final String SUBMIT_COMPLETE_STATUS = 'Hold Code Received';//Modified 20151113
    @TestVisible private static final String SUBMIT_SAAPPROVED_STATUS = 'SA Approved';
    private static final Integer MAX_NUM_OF_RETRY = 1;
    private static final String PATTERN_DO_NOTHING = '__DO_NOTHING__';
    Private Static Integer i = 0; //20160303, added by Leo, prevent trigger two times
     private static final Set<String> HOLD_CODE_DO_NOTHING = new Set<String> {
        /*[WL 2.0] BEGIN*/
         //'M0'
        /*[WL 2.0] END*/
    };
    public ASI_HK_CRM_SalesOrderRequestSubmit() {
        super('ASI_HK_CRM_SalesOrderRequestSubmit');
        System.debug('glv6');
    } 
    
    @TestVisible
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        //if(i == 0){ //20160303, added by Leo
            //i++; //20160303, added by Leo
        if (tAction == TriggerAction.AFTER_UPDATE && !isBypassByCurrentUser()) {
            System.debug('glv7');
            List<ASI_HK_CRM_Sales_Order__c> soList = [
                SELECT Id, ownerId, owner.email, ASI_HK_CRM_Order_Status_Name__c , ASI_HK_CRM_SYS_PA_Acct_Type__c    //Abel test for credit Account
                    , ASI_HK_CRM_Next_SO_Approver__c,ASI_HK_CRM_Credit_Hold_Reason__c,ASI_HK_CRM_SYS_Instant_Approve_Status__c
                    , ASI_HK_CRM_SYS_Approver_4__c, ASI_HK_CRM_SYS_Approver_5__c // 20151228 Add approver for checking
                    , ASI_HK_CRM_SYS_Approver_6__c, ASI_HK_CRM_SYS_Approver_7__c, ASI_HK_CRM_SYS_Approver_8__c
                    , (SELECT Id FROM ASI_HK_CRM_Sales_Order_Request_Items__r)     
                FROM ASI_HK_CRM_Sales_Order__c
                WHERE Id IN :sObjList
            ];
            System.debug('glv9 soList size'+soList.size());
            List<Approval.ProcessSubmitRequest> approvalReqList = new List<Approval.ProcessSubmitRequest>();
            System.debug('glv8');
            Set<ID> submitSOIdSet = new Set<ID>();
            Set<ID> updateSOIdSet = new Set<ID>();
            for (ASI_HK_CRM_Sales_Order__c so : soList) {
                System.debug('LCheck Old:-'+((ASI_HK_CRM_Sales_Order__c)oldMap.get(so.Id)).ASI_HK_CRM_Order_Status_Name__c);
                System.debug('LCheck New:-'+so.ASI_HK_CRM_Order_Status_Name__c);
                System.debug('LCheck OldA:-'+((ASI_HK_CRM_Sales_Order__c)oldMap.get(so.Id)).ASI_HK_CRM_Next_SO_Approver__c);
                System.debug('LCheck NewA:-'+so.ASI_HK_CRM_Next_SO_Approver__c);
            System.debug('enter for loop ' + so);
                if (SUBMIT_STATUS == so.ASI_HK_CRM_Order_Status_Name__c
                    && ((ASI_HK_CRM_Sales_Order__c)oldMap.get(so.Id)).ASI_HK_CRM_Order_Status_Name__c != so.ASI_HK_CRM_Order_Status_Name__c
                    && ((ASI_HK_CRM_Sales_Order__c)oldMap.get(so.Id)).ASI_HK_CRM_Next_SO_Approver__c == so.ASI_HK_CRM_Next_SO_Approver__c) {
                    Boolean noError = false;
                    try {
                        System.debug('glv1');
                        validateSubmitSO(so);
                        noError = true;
                    } catch (ASI_HK_CRM_CustomException e) {
                        System.debug('glv2');
                        so.addError(e.getMessage());
                        
                    } catch (Exception e) {
                        System.debug('glv3');
                        so.addError(e);
                    }
                    if (noError) {
                        submitSOIdSet.add(so.Id);
                    }
                }
                // Add trigger Complete Hold Code Recieved Part I
                if (SUBMIT_COMPLETE_STATUS == so.ASI_HK_CRM_Order_Status_Name__c){
                  //Mark  && ((ASI_HK_CRM_Sales_Order__c)oldMap.get(so.Id)).ASI_HK_CRM_Order_Status_Name__c != so.ASI_HK_CRM_Order_Status_Name__c) {
                    //Need trigger submit for approval
                      // Check if approval process is needed
                       System.debug('line65');
                        String changeStatusWithoutApproval = statusIfBypassApproval(so);
                        if (changeStatusWithoutApproval == null) { // Need approval process
                            System.debug('datb18'+dateTime.now());
                            Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
                            approvalReq.setObjectId(so.Id);
                            approvalReqList.add(approvalReq);
                            updateSOIdSet.add(so.Id);
                        } else if (changeStatusWithoutApproval != PATTERN_DO_NOTHING) { // Need to directly update the status
                            System.debug('datb19'+dateTime.now());
                        } 
                }
                //End  trigger Complete Hold Code Recieved Part I
                // Add trigger SA Approved Part I
                if (SUBMIT_SAAPPROVED_STATUS == so.ASI_HK_CRM_Order_Status_Name__c
                    && (so.ASI_HK_CRM_SYS_Approver_4__c != Null || so.ASI_HK_CRM_SYS_Approver_5__c != Null || so.ASI_HK_CRM_SYS_Approver_6__c != Null
                        || so.ASI_HK_CRM_SYS_Approver_7__c != Null || so.ASI_HK_CRM_SYS_Approver_8__c != Null)
                    //&& ((ASI_HK_CRM_Sales_Order__c)oldMap.get(so.Id)).ASI_HK_CRM_Order_Status_Name__c != so.ASI_HK_CRM_Order_Status_Name__c
                   ) {
                    //Need trigger submit for approval
                      // Check if approval process is needed
                      System.debug('line86');
                        String changeStatusWithoutApproval = statusIfBypassApproval(so);
                       // changeStatusWithoutApproval = null;
                        if (changeStatusWithoutApproval == null) { // Need approval process
                            System.debug('datb18'+dateTime.now());
                            Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
                            approvalReq.setObjectId(so.Id);
                            approvalReqList.add(approvalReq);
                            updateSOIdSet.add(so.Id);
                        } else if (changeStatusWithoutApproval != PATTERN_DO_NOTHING) { // Need to directly update the status
                            System.debug('datb19'+dateTime.now());
                        } 
                }
            }
            System.debug('LCheck:-'+submitSOIdSet);
            System.debug('LCheck:-'+submitSOIdSet.size());
            Integer soSize = submitSOIdSet.size();
            if (soSize > 0) {
                System.debug('glv10');
                Integer calloutLimit = 10;
                Integer futureLimit = 10;
                List<ID> soIdList = new List<ID>(submitSOIdSet);
                Exception foundException = null;
                Integer soCount;
                for (soCount = 0; soCount < soSize && soCount < calloutLimit / MAX_NUM_OF_RETRY * futureLimit; soCount += calloutLimit) {
                    System.debug('glv11');
                    Set<ID> subsetOfSOId = new Set<ID>();
                    Integer origSOCount = soCount;
                    for (Integer j = 0; j < calloutLimit / MAX_NUM_OF_RETRY && soCount + j < soSize; j++) {
                        subsetOfSOId.add(soIdList[soCount + j]);
                    }
                    try {
                        System.debug('Start Invoke SOA, soID Set: ' + submitSOIdSet);

                        if(i == 0){ //20160303, added by Leo
                            i++; //20160303, added by Leo
							
							/*[WL 1.0] BEGIN*/
							ASI_SOA_Setting__c customSetting = ASI_SOA_Setting__c.getValues('ASI_CRM_HK_SO_EnableSOAInterface');
							system.debug('HK CRM SOA Web Service exist: ' + customSetting != null);
		
							if (customSetting != null){
								ASI_CRM_HK_SOA_InvokeSOA.submitSO(submitSOIdSet);
							}
							else {
								submitSO(submitSOIdSet);
							}							
							/*[WL 1.0] END*/
							
							
                        } //20160303, added by Leo
                        System.debug('glv13');
                    } catch (Exception e) { // TODO: only catch relevant exceptions
                        System.debug('glv14');
                        soCount = origSOCount;
                        foundException = e;
                    }
                }
                if (soCount > 0)
                    System.debug('glv15');
                    //Introv 20140416 Steve Wan Remark:Stop Schedule
                    //ASI_HK_CRM_SalesOrderHoldCodeSchedule.schedule();
                while (soCount < soSize) {
                    System.debug('glv16');
                    if (foundException != null) {
                        System.debug('glv17');
                        newMap.get(soIdList[soCount]).addError(foundException.getMessage());
                    } else {
                        System.debug('glv18');
                        newMap.get(soIdList[soCount]).addError('Web service call limit is exceeded. Please reduce the number of records in single update batch.');
                    }
                    soCount++;
                }
            }
            // Add trigger Complete Hold Code Recieved Part II
            if (approvalReqList.size() > 0){
                 //Start Checking any approval process is submitted
                Map<String, Id> submittedIds = new Map<String, Id>();
                
                for (ProcessInstance pa : 
                    [Select Id, TargetObjectId, Status from ProcessInstance where TargetObjectId in :updateSOIdSet ])
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
                    if ( !submittedIds.containsKey(approvalReq.objectId )){
                        //20150318 Wilken: catch exception if SO does not match approval process entry criteria
                        try {
                            Approval.process(approvalReq);
                        } catch (Exception e) {
                        }
                    }
                }
                //End Checking any approval process is submitted
            }
            // End trigger Complete Hold Code Recieved Part II
            // Modified 20151109 Start Adding the list of PA/DA
            //List<ASI_CRM_HK_Pre_Approval_Form_ConAcc__c> ActList = new List<ASI_CRM_HK_Pre_Approval_Form_ConAcc__c>();
        }
        //}//20160303, added by Leo
    }
    
    private static void validateSubmitSO(ASI_HK_CRM_Sales_Order__c so) {
        if (so.ASI_HK_CRM_Sales_Order_Request_Items__r == null || so.ASI_HK_CRM_Sales_Order_Request_Items__r.size() == 0) {
            System.debug('glv19');
            throw new ASI_HK_CRM_CustomException('No sales order items');
        }
    }
    
    @future(callout=true)
    @TestVisible
    private static void submitSO(Set<ID> soIdSet) {
        if (soIdSet != null) {
            String detailQueryStr = ASI_HK_CRM_CommonUtils.genQueryString(
                ASI_HK_CRM_SalesOrderRequestSubmitHelper.requiredSODetailFields()
                , 'ASI_HK_CRM_Sales_Order_Request_Items__r'
            );
            System.Debug('LCheck1:-'+soIdSet);
            Set<String> soQueryFields = ASI_HK_CRM_SalesOrderRequestSubmitHelper.requiredSOFields();
            soQueryFields.add('(' + detailQueryStr + ')');
            List<ASI_HK_CRM_Sales_Order__c> soList = (List<ASI_HK_CRM_Sales_Order__c>)database.query(ASI_HK_CRM_CommonUtils.genQueryString(
                soQueryFields
                , 'ASI_HK_CRM_Sales_Order__c'
                , 'Id IN :soIdSet'
                , 'FOR UPDATE'
            ));
            System.Debug('LCheck2:-'+soList);
            ASI_HK_CRM_SalesOrderRequestSubmitHelper submitHelper = new ASI_HK_CRM_SalesOrderRequestSubmitHelper();
            List<ASI_HK_CRM_Sales_Order__c> failedSOList = new List<ASI_HK_CRM_Sales_Order__c>();
            List<ASI_HK_CRM_WebService_Debug_Log__c> insertlogList = new List<ASI_HK_CRM_WebService_Debug_Log__c>();
            for (ASI_HK_CRM_Sales_Order__c so : soList) {
                System.Debug('LCheck3:-'+so.Name);
                //Edited By Introv 20131126 : Insert Log for each exception
                Boolean success = false;
                Integer retryCount = 0;
                while (!success && retryCount < MAX_NUM_OF_RETRY) {
                    ASI_HK_CRM_WebService_Debug_Log__c log = new ASI_HK_CRM_WebService_Debug_Log__c();
                    try {
                        System.debug('int12:retryCount'+ retryCount);
                        log.Name = so.Name;
                        log.ASI_HK_CRM_WebServiceName__c = 'ASI_HK_CRM_SalesOrderRequestSubmitHelper';
                        log.ASI_HK_CRM_Before_call_webservice__c = DateTime.now();
                        log.ASI_HK_CRM_Submitter__c = so.ownerId;
                        System.Debug('LCheck4:-GOT IN Here');
                        submitHelper.submitSO(so);
                        System.debug('int13');
                        log.ASI_HK_CRM_Success__c = true;
                        log.ASI_HK_CRM_After_call_web_service__c = DateTime.now();
                        insertlogList.add(log);
                        success = true;                     
                    } catch (CalloutException ce) {
                        //if (ce.getMessage().contains('Read timed out')) {
                            retryCount++;
                            log.ASI_HK_CRM_Success__c = false;
                            log.ASI_HK_CRM_After_call_web_service__c = DateTime.now();
                            log.ASI_HK_CRM_WebService_Error_Message__c = '(Retry Count:' + retryCount + ') ' + ce.getMessage();
                            System.debug('int14'+ log.ASI_HK_CRM_WebService_Error_Message__c);
                            insertlogList.add(log);
                            if (retryCount >= MAX_NUM_OF_RETRY) {
                                System.debug('int15');
                                ASI_HK_CRM_Sales_Order__c tempSO = new ASI_HK_CRM_Sales_Order__c(Id = so.Id);
                                tempSO.ASI_HK_CRM_Is_Web_Service_Failed__c = true;
                                tempSO.ASI_HK_CRM_WebService1_isFailed__c = true;
                                tempSO.ASI_HK_CRM_WebService1_Error_Message__c = ce.getMessage();
                                tempSO.ASI_HK_CRM_Order_Status_Name__c = 'Web Service Error';
                                failedSOList.add(tempSO);
                                //sendAlertEmail(so, ce.getMessage(),'Failing in Process SalesOrder webService, Order could not created in JDE');
                                break;
                            } 
                            
                        //} else { 
                        //  throw ce;
                        //}
                    }
                }
            }
            System.debug('int16');
            insert insertlogList;
            update failedSOList;
            submitHelper.commitChanges();
            System.debug('int17');
            //End 20131126 : Insert Log for each exception
        }
    } 
    
    //Sending alert Email when the WebService is fail
    public static void sendAlertEmail(ASI_HK_CRM_Sales_Order__c so, String errMessage, String errReason){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[]{'aku@laputatech.com','vkoh@laputatech.com','kxie@laputatech.com'};
        String[] toAddresses = getRecipientFromCustomSet();
        System.debug('add2owner'+so.ownerId);
        if (so.ownerId != null) {
            if(so.owner.email != null){
                toAddresses.add(so.owner.email);
            }
        }
        System.debug('address mailing:'+toAddresses);
        mail.setToAddresses(toAddresses);
        //Mailing Subject
        String mailingSubject = 'HKCRM SO Creation Error (' +so.Name + ')\r\n\r\n';
        mail.setSubject(mailingSubject);
        
        //Mailing Message
        String mailingMessage  = 'SalesOrderName: '+ so.Name + '\r\n\r\n';
               mailingMessage  = 'WebService Failing reason: ' + errReason + '\r\n\r\n';
               mailingMessage  += 'Webservice Error Message: ' + errMessage + '\r\n\r\n';
               mailingMessage  += 'Account PA: ' + so.ASI_HK_CRM_Account_PA__r.Name + '\r\n\r\n';   
               mailingMessage  += 'Account DA: ' + so.ASI_HK_CRM_Customer_DA__r.name + '\r\n\r\n';
        mail.setPlainTextBody(mailingMessage);
        mail.setEmailPriority('High');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});  
        
    }
    
    //Sending alert Email when the Invalid Hold Code is received
    @TestVisible
    public static void sendHoldCodeAlertEmail(ASI_HK_CRM_Sales_Order__c so, String holdCode){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[]{'aku@laputatech.com','vkoh@laputatech.com','kxie@laputatech.com'};
        String[] toAddresses = getRecipientFromCustomSet();
        System.debug('addowner2'+so.ownerId);
        if (so.ownerId != null) 
        {   
            System.debug('addowner'+so.ownerId); 
            System.debug('addEmail'+so.owner.email);
            if(so.owner.email != null){
                toAddresses.add(so.owner.email);
            }
        }
        System.debug('address mailing:'+toAddresses); 
        mail.setToAddresses(toAddresses);
        //Mailing Subject
        String mailingSubject = 'HKCRM SO Creation Error (' +so.Name + ')\r\n\r\n';
        mail.setSubject(mailingSubject);
        
        //Mailing Message
        String mailingMessage  = 'SalesOrderName: '+ so.Name + '\r\n\r\n';
               mailingMessage  = 'WebService Failing reason: Invalid Hold Code Received - ' + holdCode + '\r\n\r\n';
               mailingMessage  += 'Account PA: ' + so.ASI_HK_CRM_Account_PA__r.Name + '\r\n\r\n';   
               mailingMessage  += 'Account DA: ' + so.ASI_HK_CRM_Customer_DA__r.name + '\r\n\r\n';
        mail.setPlainTextBody(mailingMessage);
        mail.setEmailPriority('High');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});  
        
    }   
        
    private static String[] getRecipientFromCustomSet(){
        String[] result = new String[]{};
        ASI_HK_CRM_WebServiceErrorAddress__c webCustSet = ASI_HK_CRM_WebServiceErrorAddress__c.getValues('WebServiceAlertEmail');
        String tempStr; 
        
        tempStr = String.valueOf(webCustSet.ASI_HK_CRM_Email_1__c);
        if (tempStr != null){
            result.add(tempStr);
        }
        
        tempStr = String.valueOf(webCustSet.ASI_HK_CRM_Email_2__c);
        if (tempStr != null){
            result.add(tempStr);
        }

        tempStr = String.valueOf(webCustSet.ASI_HK_CRM_Email_3__c);
        if (tempStr != null){
            result.add(tempStr);
        }       

        tempStr = String.valueOf(webCustSet.ASI_HK_CRM_Email_4__c);
        if (tempStr != null){
            result.add(tempStr);
        }       

        tempStr = String.valueOf(webCustSet.ASI_HK_CRM_Email_5__c);
        if (tempStr != null){
            result.add(tempStr);
        }

        tempStr = String.valueOf(webCustSet.ASI_HK_CRM_Email_6__c);
        if (tempStr != null){
            result.add(tempStr);
        }       
        return result;
    
    }
    private String statusIfBypassApproval(ASI_HK_CRM_Sales_Order__c so) {
        if (HOLD_CODE_DO_NOTHING.contains(so.ASI_HK_CRM_Credit_Hold_Reason__c)) {
            return PATTERN_DO_NOTHING;
        } else if (!String.isBlank(so.ASI_HK_CRM_SYS_Instant_Approve_Status__c)) {
            return so.ASI_HK_CRM_SYS_Instant_Approve_Status__c;
        }
        return null;
    }
}