//20150106 - Change from "Interfaced to JDE" to "SA Approved"
public without sharing class ASI_HK_CRM_SalesOrderValidator extends ASI_HK_CRM_TriggerAbstract {
//Set the time between CutOffTimeGMT2 do nothing
     
    private static final Set<String> RTDEVNAME_SET_SO = ASI_HK_CRM_SalesOrderGenerator.allRecordTypeDevNames();
    private Time myUrgentDeliveryCutoffTimeGMT_1 = urgentDeliveryCutoffTimeGMT_1();   //The cutOffTime1
    private Time myUrgentDeliveryCutoffTimeGMT_2 = urgentDeliveryCutoffTimeGMT_2();   //The cutOffTime2
    private Datetime requestCutoffDT_1;
    private Datetime requestCutoffDT_2;
    
    // validateNumOfUrgentOrder
    private Integer numOfMaxUrgentOrder;
    private Integer curUrgentCount;
    private Map<Date, Integer> dateToUrgentCount;
    private Set<ID> relevantUrgentIds;
    private DateTime requestTime; //Abel The urgent order time
    
    // validateSSCApprove
    private static final String STATUS_SSC_APPROVE = 'SSC Finance updated';
    private static final Set<String> CREDIT_CODE_NO_NEED_SSC = new Set<String>{
        'H0'
        , 'M0'
    };
    
    // validateSMDApprove
    private static final String STATUS_SMD_APPROVE = 'HS Approved';
    
    public ASI_HK_CRM_SalesOrderValidator() {
        super('ASI_HK_CRM_SalesOrderValidator');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if ((tAction == TriggerAction.BEFORE_INSERT || tAction == TriggerAction.BEFORE_UPDATE || tAction == TriggerAction.AFTER_UNDELETE)
            && !isBypassByCurrentUser()) {
            List<ASI_HK_CRM_Sales_Order__c> soList = (List<ASI_HK_CRM_Sales_Order__c>)sObjList;
            Map<ID, ASI_HK_CRM_Sales_Order__c> oldSOMap = (Map<ID, ASI_HK_CRM_Sales_Order__c>)oldMap;
           
            initForValidateNumOfUrgentOrder(tAction, soList, oldSOMap);
            for (ASI_HK_CRM_Sales_Order__c so : soList) {
                try {
                    
                    Boolean boolValue = so.ASI_HK_CRM_Order_Date__c > so.ASI_HK_CRM_Delivery_Date__c;
                    ASI_HK_CRM_Sales_Order__c oldSO = tAction == TriggerAction.BEFORE_UPDATE ? (ASI_HK_CRM_Sales_Order__c)oldMap.get(so.Id) : null;
                    DateTime currentTime = Datetime.now();
                    //currentTime = currentTime.addHours(8);   //Change by Abel
                    if(currentTime.time() < myUrgentDeliveryCutoffTimeGMT_1 || currentTime.time() > myUrgentDeliveryCutoffTimeGMT_2 && so.ASI_HK_CRM_Order_Status_Name__c == 'Draft'){
                        
                        if (oldSO != null){
                            if((oldSO.ASI_HK_CRM_Order_Date__c != so.ASI_HK_CRM_Order_Date__c  || oldSo.ASI_HK_CRM_Urgent_Order_Confirmed__c != so.ASI_HK_CRM_Urgent_Order_Confirmed__c || oldSo.ASI_HK_CRM_Delivery_Date__c != so.ASI_HK_CRM_Delivery_Date__c) 
                               && so.ASI_HK_CRM_Urgent_Order_Confirmed__c == 'Yes')
                            {
                                validateNumOfUrgentOrder(tAction, so, oldSO);
                            }                           
                        }
                    }
               
                    validateSMDApprove(tAction, so, oldSO);
                    validateUrgentNotCheck(tAction, so, oldSO);
                    /*
                    if(oldSO != null){
                        if(so.ASI_HK_CRM_Payment_Method__c != oldSO.ASI_HK_CRM_Payment_Method__c ){
                            so.ASI_HK_CRM_Changetime_for_Payment_Method__c = currentTime; 
                            so.ASI_HK_CRM_Old_Payment_Method__c = oldSO.ASI_HK_CRM_Payment_Method__c;
                            if(so.ASI_HK_CRM_Reason_PaymentMethodChange__c == null || so.ASI_HK_CRM_Reason_PaymentMethodChange__c.isWhitespace()) {
                                so.ASI_HK_CRM_Reason_PaymentMethodChange__c.addError('once user change "Payment Method", should input "Reason for Payment Method Change"'); // prevent update
                            }
                        }
                        if(so.ASI_CRM_Delivery_Address__c != oldSO.ASI_CRM_Delivery_Address__c)
                        {
                            so.ASI_HK_CRM_Change_time_for_Address__c = currentTime;
                        }
                    }
                    */
                } catch (SalesOrderValidationException sove) {
                    so.addError(sove.getMessage());
                }
            }
        }
    }
    
    private void initForValidateNumOfUrgentOrder(TriggerAction tAction, List<ASI_HK_CRM_Sales_Order__c> soList, Map<ID, ASI_HK_CRM_Sales_Order__c> oldSOMap) {
        dateToUrgentCount = new Map<Date, Integer>();
        Set<Date> relevantDateSet = new Set<Date>();
        relevantUrgentIds = new Set<ID>();
        for (ASI_HK_CRM_Sales_Order__c so : soList) {
            ASI_HK_CRM_Sales_Order__c oldSO = oldSOMap != null ? (ASI_HK_CRM_Sales_Order__c)oldSOMap.get(so.Id) : null;
            if ((tAction != TriggerAction.AFTER_UNDELETE || (tAction != TriggerAction.BEFORE_INSERT && isChangedForUrgentOrder(so, oldSO))) && so.ASI_HK_CRM_Urgent_Order_Confirmed__c == 'Yes') {
                relevantUrgentIds.add(so.Id);
            }
            if (so.ASI_HK_CRM_Urgent_Order__c == true && so.ASI_HK_CRM_Delivery_Date__c != null && so.ASI_HK_CRM_Urgent_Order_Confirmed__c == 'Yes') {
                relevantDateSet.add(so.ASI_HK_CRM_Delivery_Date__c);
                dateToUrgentCount.put(so.ASI_HK_CRM_Delivery_Date__c, 0);
                     
            }
        }
        if (relevantDateSet.size() > 0) {
            List<ASI_HK_CRM_Sales_Order__c> relevantUrgentOrders = [SELECT Id, ASI_HK_CRM_Delivery_Date__c,ASI_HK_CRM_SYS_Request_Datetime__c FROM ASI_HK_CRM_Sales_Order__c WHERE ASI_HK_CRM_Urgent_Order__c = TRUE AND ASI_HK_CRM_Urgent_Order_Confirmed__c = 'YES' AND ASI_HK_CRM_Delivery_Date__c IN :relevantDateSet AND ID NOT IN :relevantUrgentIds];
            for (ASI_HK_CRM_Sales_Order__c so : relevantUrgentOrders) {
                requestTime = so.ASI_HK_CRM_SYS_Request_Datetime__c;
                Integer urgentCount = dateToUrgentCount.get(so.ASI_HK_CRM_Delivery_Date__c);         
                urgentCount++;
                dateToUrgentCount.put(so.ASI_HK_CRM_Delivery_Date__c, urgentCount);
                
            }
        }
        
        ASI_HK_CRM_ThresholdValues__c thresholdValueSetting = ASI_HK_CRM_ThresholdValues__c.getOrgDefaults();
        if (thresholdValueSetting != null) {
            numOfMaxUrgentOrder = thresholdValueSetting.ASI_HK_CRM_SO_Max_Num_of_Urgent_Order__c != null
                ? thresholdValueSetting.ASI_HK_CRM_SO_Max_Num_of_Urgent_Order__c.intValue()
                : -1;
        } else {
            numOfMaxUrgentOrder = -1;
        }
    }
    private void validateNumOfUrgentOrder(TriggerAction tAction, ASI_HK_CRM_Sales_Order__c so, ASI_HK_CRM_Sales_Order__c oldSO) {
        if (numOfMaxUrgentOrder >= 0) {
            System.debug('vaf1');
            if (so.ASI_HK_CRM_Urgent_Order__c == true && so.ASI_HK_CRM_Delivery_Date__c != null && so.ASI_HK_CRM_Urgent_Order_Confirmed__c == 'Yes'
                && (tAction != TriggerAction.BEFORE_UPDATE || relevantUrgentIds.contains(so.Id))) {
                
                Integer curUrgentCount = dateToUrgentCount.get(so.ASI_HK_CRM_Delivery_Date__c);
                curUrgentCount++;
                dateToUrgentCount.put(so.ASI_HK_CRM_Delivery_Date__c, curUrgentCount);

                if (curUrgentCount > numOfMaxUrgentOrder)
                    throw new SalesOrderValidationException(String.format('The maximum number of urgent orders is exceeded on {0} (Max. {1})', new String[] {so.ASI_HK_CRM_Delivery_Date__c.format(), String.valueOf(numOfMaxUrgentOrder)}));
            }
        }
    }
    private Boolean isChangedForUrgentOrder(ASI_HK_CRM_Sales_Order__c so, ASI_HK_CRM_Sales_Order__c oldSO) {
        return (oldSO == null || so.ASI_HK_CRM_Delivery_Date__c != oldSO.ASI_HK_CRM_Delivery_Date__c || so.ASI_HK_CRM_Urgent_Order__c != oldSO.ASI_HK_CRM_Urgent_Order__c);
    }

    private void validateSMDApprove(TriggerAction tAction, ASI_HK_CRM_Sales_Order__c so, ASI_HK_CRM_Sales_Order__c oldSO) {
        if (STATUS_SMD_APPROVE == so.ASI_HK_CRM_Order_Status_Name__c
            && String.isBlank(so.ASI_HK_CRM_Comment_SSM_HS__c)
            && (so.ASI_HK_CRM_Credit_Hold_Reason__c=='H4' || so.ASI_HK_CRM_Credit_Hold_Reason__c=='H7')
            ) {
            so.addError(String.format('Please fill in {0} before approve', new String[] {
                SObjectType.ASI_HK_CRM_Sales_Order__c.fields.ASI_HK_CRM_Comment_SSM_HS__c.getLabel()
            }));
        }
    }
    
    private void validateUrgentNotCheck(TriggerAction tAction, ASI_HK_CRM_Sales_Order__c so, ASI_HK_CRM_Sales_Order__c oldSO) {
        // 20150106 - Change from "Interfaced to JDE" to "SA Approved"
        if ('SA Approved' == so.ASI_HK_CRM_Order_Status_Name__c && 
            so.ASI_HK_CRM_Urgent_Order_Confirmed__c != 'Yes' && so.ASI_HK_CRM_Urgent_Order__c == true){
            so.addError('This is an urgent order, please confirm by using the \"Confirm Urgent Order\" button before approving');
        }   
    }
    
    private Time strToTime(String timeStr) {
        try {
            if (timeStr != null && timeStr.trim() != '') {
                List<String> timeElements = timeStr.trim().split(':', 0);
                Integer numOfTimeEle = timeElements.size();
                if (numOfTimeEle > 3 || numOfTimeEle <= 0) throw new ASI_HK_CRM_CustomException();
                for (String timeEle : timeElements) {
                    if (!timeEle.trim().isNumeric())
                        throw new ASI_HK_CRM_CustomException();
                }
                Integer hour = 0, minute = 0, second = 0, millisecond = 0;
                if (numOfTimeEle >= 1) hour = Integer.valueOf(timeElements[0].trim());
                if (numOfTimeEle >= 2) minute = Integer.valueOf(timeElements[1].trim());
                if (numOfTimeEle == 3) second = Integer.valueOf(timeElements[2].trim());
                return Time.newInstance(hour, minute, second, millisecond);
            }
        } catch (Exception e) {
            System.debug(String.format('Invalid time string ({0}) in custom setting', new String[] {timeStr}));
        }
        return null;
    }
    
   private Time urgentDeliveryCutoffTimeGMT_1() {
     if (myUrgentDeliveryCutoffTimeGMT_1 == null) {
       ASI_HK_CRM_ThresholdValues__c thresholdValueSetting = ASI_HK_CRM_ThresholdValues__c.getOrgDefaults();
       if (thresholdValueSetting != null) {
         myUrgentDeliveryCutoffTimeGMT_1 = strToTime(thresholdValueSetting.ASI_HK_CRM_SO_Urgent_Cutoff_Time_1__c);
       }
     } 
     return myUrgentDeliveryCutoffTimeGMT_1;
   }   

   private Time urgentDeliveryCutoffTimeGMT_2() {
     if (myUrgentDeliveryCutoffTimeGMT_2 == null) {
       ASI_HK_CRM_ThresholdValues__c thresholdValueSetting = ASI_HK_CRM_ThresholdValues__c.getOrgDefaults();
       if (thresholdValueSetting != null) {
         myUrgentDeliveryCutoffTimeGMT_2 = strToTime(thresholdValueSetting.ASI_HK_CRM_SO_Urgent_Cutoff_Time_2__c);
       }
     } 
     return myUrgentDeliveryCutoffTimeGMT_2;
   }   

    
   public class SalesOrderValidationException extends Exception {
        
   }

}