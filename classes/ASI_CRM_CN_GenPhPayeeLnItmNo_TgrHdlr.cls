/* Filename:    ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr.cls
 * Author:      Michael Yip (Introv Limited)
 * Purpose:     Generate invoice number for payee line 
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2014-06-26   michael.yip@introv.com      Created
 * 2014-09-05   michael.yip@introv.com      Invoice Number: Region Code + YY + MM + Sequence Number + Running Number for Cash Payee.
 * 
 */
public without sharing class ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr extends ASI_HK_CRM_TriggerAbstract {
  
  private Map<String, ASI_CRM_CN_AutoNumberAssignment> autoNumberAssignmentMap = new Map<String, ASI_CRM_CN_AutoNumberAssignment>();
  
  public ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr() {
    super('ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr');
  }
  
  public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
    List<ASI_CRM_CN_PH_Payee_Line_Item__c> pymntPayeeLnItmsAll = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
    List<ASI_CRM_AccountsAdditionalField__c> LRegionCodeCustomerAll = new List<ASI_CRM_AccountsAdditionalField__c>();
    List<ASI_CRM_AccountsAdditionalField__c> Lcustomers = new List<ASI_CRM_AccountsAdditionalField__c>();
    Set<String> SPaymentID = new Set<String>();
    Set<String> SOutletWS = new Set<String>();
    Set<String> SCustomerID = new Set<String>(); 

    Set<Id> refreshSet = new Set<Id>();
    for(sObject obj: sObjList){
       ASI_TH_CRM_PaymentRequest__c newPaymentRequest = (ASI_TH_CRM_PaymentRequest__c)obj;
       SPaymentID.add(newPaymentRequest.Id);
       SOutletWS.add(newPaymentRequest.ASI_CRM_CN_OutletWS__c);

       /* 
            2020-01-21 Bowen 
            因为在wholesaler Promotion的page页面中，当update end date，refresh payment request line item的时候，出现了大批量payment request line item的数据进行insert，
            根据trigger机制，会自动按200一批次进行insert，而payment request line item中有update payment request的方法，
            导致该方法多次进入，而所有的sql都会执行一次，一旦达到8次重复触发，就会导致事务报错：SOQL limit 101。
            故增加一个filed，如果是refresh的时候，就不执行下面的方法
        */
        if(newPaymentRequest.ASI_CRM_CN_IsRefresh__c && (newPaymentRequest.ASI_CRM_CN_Promotion_Type__c == 'Wholesaler Promotion' || newPaymentRequest.ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion' 
            ||newPaymentRequest.ASI_CRM_CN_Promotion_Type__c == 'Consumer Promotion'))
        {
            system.debug('----newPaymentRequest.ASI_CRM_CN_IsRefresh__c==='+newPaymentRequest.ASI_CRM_CN_IsRefresh__c);
            refreshSet.add(newPaymentRequest.Id);
        }
    }
    // 2020-01-21 Bowen 当获取到的set的大小与trigger.new的大小一致，即所有的payment request的数据都是refresh过来的，可以不执行下面的方法。
    if(refreshSet.size() == sObjList.size()) return;

    if(isBypassByCurrentUser())return;
    
    pymntPayeeLnItmsAll = [SELECT Id,ASI_CRM_CN_Type__c,ASI_CRM_CN_Payee_Name_T1__c,ASI_CRM_CN_Invoice_Number__c, ASI_CRM_CN_Payment_Request__c FROM ASI_CRM_CN_PH_Payee_Line_Item__c WHERE ASI_CRM_CN_Payment_Request__c IN :SPaymentID];
    LRegionCodeCustomerAll = [SELECT id, ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN :SOutletWS];
    
    for(ASI_CRM_CN_PH_Payee_Line_Item__c payee : pymntPayeeLnItmsAll ){
        SCustomerID.add(payee.ASI_CRM_CN_Payee_Name_T1__c);
    }
    
    Lcustomers = [SELECT Id,ASI_CRM_CN_CRM_Code__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN :SCustomerID];
    
    for(sObject obj: sObjList){
        ASI_TH_CRM_PaymentRequest__c newPaymentRequest = (ASI_TH_CRM_PaymentRequest__c)obj;
        Boolean hasCash = false;
        
        ASI_TH_CRM_PaymentRequest__c oldPaymentRequest = null;
        if (oldMap != null && oldMap.get(newPaymentRequest.id) != null){
            oldPaymentRequest = (ASI_TH_CRM_PaymentRequest__c )oldMap.get(newPaymentRequest.id);
        }
        
        if(oldPaymentRequest.ASI_TH_CRM_GL_Date__c == null && newPaymentRequest.ASI_TH_CRM_GL_Date__c != oldPaymentRequest.ASI_TH_CRM_GL_Date__c){
           List<ASI_CRM_CN_PH_Payee_Line_Item__c> pymntPayeeLnItms = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
           for(ASI_CRM_CN_PH_Payee_Line_Item__c payee : pymntPayeeLnItmsAll){
               if(payee.ASI_CRM_CN_Payment_Request__c == newPaymentRequest.Id)
                   pymntPayeeLnItms.add(payee);
               //Updated by William Yang(Introv) to fix missing Invoice Number for Cash line items #155
               if(payee.ASI_CRM_CN_Type__c == 'Cash')
                    hasCash = true;
           }
           //List<ASI_CRM_CN_PH_Payee_Line_Item__c> pymntPayeeLnItms = [SELECT Id,ASI_CRM_CN_Type__c,ASI_CRM_CN_Payee_Name_T1__c,ASI_CRM_CN_Invoice_Number__c FROM ASI_CRM_CN_PH_Payee_Line_Item__c WHERE ASI_CRM_CN_Payment_Request__c = :newPaymentRequest.Id];
           
           ASI_CRM_AccountsAdditionalField__c regionCodeCustomer;
           for(ASI_CRM_AccountsAdditionalField__c  regCodeCust : LRegionCodeCustomerAll){
               if(regCodeCust.id == newPaymentRequest.ASI_CRM_CN_OutletWS__c){
                  regionCodeCustomer =  regCodeCust; 
                  break;
               }
           }
           //ASI_CRM_AccountsAdditionalField__c regionCodeCustomer = [SELECT ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id = :newPaymentRequest.ASI_CRM_CN_OutletWS__c];
           String regionCode = regionCodeCustomer.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c;
           
           
           
           Map<String,String> customerKeyMap = new Map<String,String>();
           
           for(ASI_CRM_CN_PH_Payee_Line_Item__c paymentPayeeLineItem : pymntPayeeLnItms){
               customerKeyMap.put(paymentPayeeLineItem.ASI_CRM_CN_Payee_Name_T1__c,paymentPayeeLineItem.ASI_CRM_CN_Payee_Name_T1__c);
           }
           
           List<ASI_CRM_AccountsAdditionalField__c> customers = new List<ASI_CRM_AccountsAdditionalField__c>();
           for(ASI_CRM_AccountsAdditionalField__c cus : Lcustomers ){
               if(customerKeyMap.containsKey(cus.id))
                   customers.add(cus);
           }
           //List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT Id,ASI_CRM_CN_CRM_Code__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN :customerKeyMap.keySet()];
           
           String yearMonth = String.valueOf(newPaymentRequest.ASI_TH_CRM_GL_Date__c.year()).substring(2,4) + (newPaymentRequest.ASI_TH_CRM_GL_Date__c.month()>9?String.valueOf(newPaymentRequest.ASI_TH_CRM_GL_Date__c.month()):'0'+ String.valueOf(newPaymentRequest.ASI_TH_CRM_GL_Date__c.month()));
           String fiscalYear  = String.valueOf(newPaymentRequest.ASI_TH_CRM_GL_Date__c.month()>6?newPaymentRequest.ASI_TH_CRM_GL_Date__c.year():newPaymentRequest.ASI_TH_CRM_GL_Date__c.year()-1);
           Map<String, ASI_CRM_CN_AutoNumberAssignment> autoNumberAssignmentMap = new Map<String, ASI_CRM_CN_AutoNumberAssignment>();
                   
           Integer splitNo = 1;
           //Updated by William Yang(Introv) to fix missing Invoice Number for Cash line items #155
           String sequenceNumber = '';
           if(hasCash)
                sequenceNumber = retrieveAutoNumberByKey(regionCode + fiscalYear);
           for(ASI_CRM_CN_PH_Payee_Line_Item__c paymentPayeeLineItem : pymntPayeeLnItms){
               if(paymentPayeeLineItem.ASI_CRM_CN_Type__c != null && (paymentPayeeLineItem.ASI_CRM_CN_Invoice_Number__c == null || paymentPayeeLineItem.ASI_CRM_CN_Invoice_Number__c == '')){
                    if(paymentPayeeLineItem.ASI_CRM_CN_Type__c == 'Cash'){
                        paymentPayeeLineItem.ASI_CRM_CN_Invoice_Number__c = regionCode + yearMonth + sequenceNumber + (splitNo>=10?String.valueOf(splitNo):'0'+String.valueOf(splitNo));
                        //paymentPayeeLineItem.ASI_CRM_CN_Invoice_Number__c = regionCode + yearMonth + retrieveAutoNumberByKey(regionCode + fiscalYear) + (splitNo>=10?String.valueOf(splitNo):'0'+String.valueOf(splitNo));
                        splitNo = splitNo + 1;
                    }else if (paymentPayeeLineItem.ASI_CRM_CN_Type__c == 'Discount' || paymentPayeeLineItem.ASI_CRM_CN_Type__c == 'Others'){
                        ASI_CRM_AccountsAdditionalField__c customer = null;
                        for(ASI_CRM_AccountsAdditionalField__c customerTmp : customers){
                            if(customerTmp.Id == paymentPayeeLineItem.ASI_CRM_CN_Payee_Name_T1__c){
                                customer = customerTmp;
                                break;
                           }
                        }
                        
                        paymentPayeeLineItem.ASI_CRM_CN_Invoice_Number__c = customer.ASI_CRM_CN_CRM_Code__c + yearMonth + retrieveAutoNumberByKey(customer.ASI_CRM_CN_CRM_Code__c + fiscalYear);
                    }              
               }
           }
           
           update pymntPayeeLnItms;
           updateAutoNumber();
        }
    }
  }
  
  private String retrieveAutoNumberByKey(String key){
        String sequenceNo = '0000';
        
        ASI_CRM_CN_AutoNumberAssignment autoNumAssign = autoNumberAssignmentMap.get(key);
        if (autoNumAssign == null){
            autoNumAssign = new ASI_CRM_CN_AutoNumberAssignment(key);
        }
        sequenceNo = String.valueOf(autoNumAssign.nextAutoNum()).leftPad(4).replace(' ', '0');                      
        autoNumberAssignmentMap.put(key, autoNumAssign);

        return sequenceNo;
  }
  
  private void updateAutoNumber(){  
        for (ASI_CRM_CN_AutoNumberAssignment autoNumAssign : autoNumberAssignmentMap.Values()){
              autoNumAssign.writeToDB();
        }
  }

}