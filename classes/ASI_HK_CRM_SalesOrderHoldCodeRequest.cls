public without sharing class ASI_HK_CRM_SalesOrderHoldCodeRequest implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    private static final String THIS_CLASS_NAME = 'ASI_HK_CRM_SalesOrderHoldCodeRequest'; 
    private static final String CRON_TRIGGER_NAME = 'ASI_HK_CRM_SalesOrderHoldCodeRequestCron';
    @TestVisible private static final String STATUS_WAIT_CREDIT_HOLD = 'Waiting for Hold Code';
    private static final String STATUS_FINISH = 'Checking Extra Items';
    private static final String STATUS_COMPLETE = 'Hold Code Received'; 
    private static final Integer BATCH_SCOPE = 10;
     
    private ASI_HK_CRM_SalesOrderHoldCodeWS.CRMSOManagerHttpPort creditHoldPort; 
    
    public static void executeBatch() {
        database.executeBatch(new ASI_HK_CRM_SalesOrderHoldCodeRequest(), BATCH_SCOPE);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('mmg1');
        //return Database.getQueryLocator('SELECT Id, ASI_HK_CRM_SYS_DocumentCompany__c FROM ASI_HK_CRM_Sales_Order__c, ASI_HK_CRM_Credit_Hold_Reason__c, ASI_HK_CRM_SYS_Instant_Approve_Status__c WHERE ASI_HK_CRM_Order_Status_Name__c = :STATUS_WAIT_CREDIT_HOLD AND ASI_HK_CRM_Is_Web_Service_Failed__c != TRUE');
        return Database.getQueryLocator('SELECT Id, Name, ownerId, ASI_HK_CRM_SO_External_ID__c, ASI_HK_CRM_SYS_DocumentCompany__c , ASI_HK_CRM_Credit_Hold_Reason__c, ASI_HK_CRM_SYS_Instant_Approve_Status__c FROM ASI_HK_CRM_Sales_Order__c WHERE ASI_HK_CRM_Order_Status_Name__c = :STATUS_WAIT_CREDIT_HOLD AND ASI_HK_CRM_Is_Web_Service_Failed__c != TRUE AND ASI_HK_CRM_Actual_Approve_User__c=\'' + UserInfo.getUserId() + '\'');
    }
     
    public void execute(Database.BatchableContext BC, List<sObject> sObjList){
        System.debug('mmg3');
        System.debug('mmg3,1size'+sObjList.size());
        if (sObjList != null && sObjList.size() > 0) {
            System.debug('mmg4');
            List<ASI_HK_CRM_Sales_Order__c> soList = (List<ASI_HK_CRM_Sales_Order__c>)sObjList;
            System.debug('mmg5');
            if (creditHoldPort == null) {
                System.debug('mmg6');
                List<ASI_HK_CRM_Web_Service_Setting__c> wsSettings = [
                    SELECT Id, ASI_HK_CRM_Base_URL__c, ASI_HK_CRM_Username__c, ASI_HK_CRM_Password__c
                    FROM ASI_HK_CRM_Web_Service_Setting__c
                    WHERE ASI_HK_CRM_Key__c = 'ASI_HK_CRM_SalesOrderSubmit'
                ];
                System.debug('mmg7');
                if (wsSettings.size() == 1) {
                    System.debug('mmg8');
                    ASI_HK_CRM_Web_Service_Setting__c wsSetting = wsSettings[0];
                    creditHoldPort = new ASI_HK_CRM_SalesOrderHoldCodeWS.CRMSOManagerHttpPort(
                        wsSetting.ASI_HK_CRM_Base_URL__c
                        , wsSetting.ASI_HK_CRM_Username__c
                        , wsSetting.ASI_HK_CRM_Password__c
                    );
                    creditHoldPort.timeout_x = 120000;
                    //creditHoldPort.timeout_x = 5000;
                    System.debug('mmg9');
                } else if (wsSettings.size() == 0) { throw new SalesOrderHoldCodeException('ASI HK CRM master web service setting not found');
                } else {throw new SalesOrderHoldCodeException('Duplicate ASI HK CRM master web service settings');}
            }
            if (creditHoldPort != null) {
                List<ASI_HK_CRM_WebService_Debug_Log__c> insertLogList = new List<ASI_HK_CRM_WebService_Debug_Log__c>();
                System.debug('mmg12');
                List<ASI_HK_CRM_Sales_Order__c> updateSOList = new List<ASI_HK_CRM_Sales_Order__c>();
                System.debug('mmg13');
                List<Approval.ProcessSubmitRequest> approvalReqList = new List<Approval.ProcessSubmitRequest>();
                System.debug('mmg14'); 
                for (ASI_HK_CRM_Sales_Order__c so : soList) {
                    ASI_HK_CRM_WebService_Debug_Log__c log = new ASI_HK_CRM_WebService_Debug_Log__c();
                    log.ASI_HK_CRM_WebServiceName__c = 'ASI_HK_CRM_SalesOrderHoldCodeRequest';
                    log.ASI_HK_CRM_Submitter__c = so.ownerId;
                    log.Name = so.Name;
                    log.ASI_HK_CRM_Before_call_webservice__c = DateTime.now();
                    try {
                        if (processSO(so)) {
                            log.ASI_HK_CRM_Success__c = true;
                            log.ASI_HK_CRM_After_call_web_service__c = DateTime.now();
                            System.debug('mmg15');
                            updateSOList.add(so);
                            insertlogList.add(log);
                        }
                    } catch (Exception e) {
                        log.ASI_HK_CRM_Success__c = false;
                        log.ASI_HK_CRM_After_call_web_service__c = DateTime.now();
                        log.ASI_HK_CRM_WebService_Error_Message__c = e.getMessage();
                        System.debug('mmg16');
                        System.debug(LoggingLevel.ERROR, e);
                        so.ASI_HK_CRM_Is_Web_Service_Failed__c = true;
                        so.ASI_HK_CRM_WebService2_isFailed__c = true;
                        so.ASI_HK_CRM_WebService2_Error_Message__c = e.getMessage();
                        so.ASI_HK_CRM_Order_Status_Name__c = 'Web Service Error';
                        updateSOList.add(so);
                        insertlogList.add(log);
                        //Edit by Introv 20131129 to avoid send alert email error
                        //ASI_HK_CRM_SalesOrderRequestSubmit.sendAlertEmail(so, e.getMessage(),'GetHoldCode Failure, Order have been created in JDE'); 
                    }
                }
                update updateSOList;
                insert insertlogList;
            }
            

        }
    }  
    
    public void finish(Database.BatchableContext BC) {
        System.debug('mmg18');

        ASI_HK_CRM_WebServiceRepeatControl__c webControl = ASI_HK_CRM_WebServiceRepeatControl__c.getInstance('ASI_HK_CRM_WSRepeatControlDataSet');
        
                  
        Integer countNextStepSO = [SELECT COUNT() FROM ASI_HK_CRM_Sales_Order__c WHERE ASI_HK_CRM_Order_Status_Name__c = :STATUS_FINISH AND ASI_HK_CRM_Is_Web_Service_Failed__c != TRUE AND ASI_HK_CRM_Actual_Approve_User__c=:UserInfo.getUserId()];
        if (countNextStepSO > 0) ASI_HK_CRM_SalesOrderExtraItemRequest.processImmediately();
        
        if(webControl.ASI_HK_CRM_isRepeatWebService__c){
            ASI_HK_CRM_SalesOrderHoldCodeSchedule.schedule();
        }
        else{
            Integer countWaitingSO = [SELECT COUNT() FROM ASI_HK_CRM_Sales_Order__c WHERE ASI_HK_CRM_Order_Status_Name__c = :STATUS_WAIT_CREDIT_HOLD AND ASI_HK_CRM_Is_Web_Service_Failed__c != TRUE];
            if (countWaitingSO > 0) {
                System.debug('mmg19');
                ASI_HK_CRM_SalesOrderHoldCodeSchedule.schedule();
            }
        }
        
        
    }
    
    private Boolean processSO(ASI_HK_CRM_Sales_Order__c so) {
        //ASI_HK_CRM_SalesOrderHoldCodeWSTypes.N56HOLD_Output holdCodeResult = creditHoldPort.GetHoldCode(null, null, null, null, ((String)so.Id).substring(0, 15));
        ASI_HK_CRM_SalesOrderHoldCodeWSTypes.N56HOLD_Output holdCodeResult = creditHoldPort.GetHoldCode(null, null, null, null, ((String)so.ASI_HK_CRM_SO_External_ID__c));
        System.debug('mmg25'+(String)so.ASI_HK_CRM_SO_External_ID__c);
        if (holdCodeResult != null 
            && !String.isBlank(holdCodeResult.orderCompanyOrderNumber)) {
                System.debug('hold code pass by webService: '+ holdCodeResult.holdOrdersCode);
                System.debug('SO number:' + so.Name);
                System.debug('The return value of hold code'+holdCodeResult.holdOrdersCode);
            //if (!String.isBlank(so.ASI_HK_CRM_SYS_DocumentCompany__c) && so.ASI_HK_CRM_SYS_DocumentCompany__c.trim() == holdCodeResult.orderCompanyOrderNumber.trim()) {
                if(holdCodeResult.holdOrdersCode != 'xx'){
                    so.ASI_HK_CRM_Credit_Hold_Reason__c = holdCodeResult.holdOrdersCode; 
                    //so.ASI_HK_CRM_Credit_Hold_Reason__c = 'H5'; //Hard code for testing, please revert back to the line above when finish testing
                    so.ASI_HK_CRM_Order_Type__c = holdCodeResult.orderType; 
                    so.ASI_HK_CRM_Order_Status_Name__c = STATUS_FINISH;
                //  so.ASI_HK_CRM_Order_Status_Name__c = STATUS_COMPLETE;  
                    return true;
                }
        }
        System.debug('mmg33 fail'); 
        return false;
    }
    
    public class SalesOrderHoldCodeException extends Exception {
        
    }
    
}