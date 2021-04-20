/*********************************************************************************
 * Name:        ASI_CRM_MY_PaymentRequest_TriggerClass --> ASI_CRM_MY_PaymentRequest_TriggerCls
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-12-31       Introv: Daniel WONG     Created
 * 2015-01-22       Introv: Twinkle LI      Outlet/WS Parent Child Validation // Outlet should be the same as Contract Outlet or its child outlet
 * 2018-02-22       Introv                  Updated summary info, e.g. total paid A&P cash
*********************************************************************************/

public with sharing class ASI_CRM_MY_PaymentRequest_TriggerCls{
    public static String className = 'ASI_CRM_MY_PaymentRequest_TriggerCls';
    public static Set<Id> setContract = new Set<Id>();
    public static List<ASI_TH_CRM_Contract__c> lstContract = new List<ASI_TH_CRM_Contract__c>();

    public static void routineBeforeInsert(list<ASI_TH_CRM_PaymentRequest__c> trigger_new){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)) {
            // Declaration
            id idRT_MY_PR = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_MY_Payment_Request');
            map<id, String> mapCustLegalName = new map<id, String>();
            ASI_CRM_MY_Settings__c mySetting = ASI_CRM_MY_Settings__c.getInstance();
            decimal decGST = 0;
            set<id> setCustomerID = new set<id>();
            set<id> setContractId = new set<id>();
            list<ASI_CRM_AccountsAdditionalField__c> listCustomer = new list<ASI_CRM_AccountsAdditionalField__c>();
            map<Id, ASI_CRM_AccountsAdditionalField__c> mapCustomer = new map<Id, ASI_CRM_AccountsAdditionalField__c>();
            List<ASI_TH_CRM_Contract__c> listContract = new List<ASI_TH_CRM_Contract__c>();
            map<Id, ASI_TH_CRM_Contract__c> mapContract = new map<Id, ASI_TH_CRM_Contract__c>();
            // Declaration - End        
            
            ASI_CRM_MY_RunningNumber_TriggerClass autoNumAssign = null;
           
            if(mySetting!=null && mySetting.ASI_CRM_MY_GST_Rate__c!=null){
                decGST = mySetting.ASI_CRM_MY_GST_Rate__c;
            }
            
            for (ASI_TH_CRM_PaymentRequest__c i : trigger_new){
                setCustomerID.add(i.ASI_CRM_CN_OutletWS__c);
                setContractId.add(i.ASI_TH_CRM_Contract__c);
            }        
            
            listContract = [SELECT id, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_Contract_Entitled_AP_Cash__c, ASI_CRM_Total_Paid_A_P_Cash__c FROM ASI_TH_CRM_Contract__c WHERE Id IN:setContractId];
            listCustomer = [SELECT id, ASI_CRM_CN_Legal_Name__c, ASI_CRM_SG_Tax_Expl_Code__c, ASI_CRM_CN_Parent_Outlet__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN:setCustomerID];
            
            for (ASI_CRM_AccountsAdditionalField__c i : listCustomer) {
                mapCustLegalName.put(i.id, i.ASI_CRM_CN_Legal_Name__c);
                mapCustomer.put(i.id, i);
            }
            for(ASI_TH_CRM_Contract__c con : listContract){
                mapContract.put(con.id, con);
            }
            
            
            for(ASI_TH_CRM_PaymentRequest__c i : trigger_new){           
                if(i.recordTypeId == idRT_MY_PR){
                    if(autoNumAssign == NULL){
                        autoNumAssign = new ASI_CRM_MY_RunningNumber_TriggerClass('Payment Request'); // to Match the Module in Running Number
                    }
                    if (autoNumAssign != null) {
                        i.Name = autoNumAssign.nextAutoNumStr();
                        autoNumAssign.writeToDB();
                    }
                    
                    // Auto set the name according to the outlet
                    if (mapCustLegalName.get(i.ASI_CRM_CN_OutletWS__c) != null) {
                        i.ASI_CRM_PayTo__c = mapCustLegalName.get(i.ASI_CRM_CN_OutletWS__c);
                    }
                    

                    /** To auto fill GST rate from custom setting
                    if (i.ASI_CRM_GST__c == true) {
                        i.ASI_CRM_GST_Rate__c = decGST;
                    }**/
                    //To auto apply GST based on customer ASI_CRM_SG_Tax_Expl_Code__c (V=have tax; E= Not to apply)
                    if(String.isEmpty(mapCustomer.get(i.ASI_CRM_CN_OutletWS__c).ASI_CRM_SG_Tax_Expl_Code__c) || mapCustomer.get(i.ASI_CRM_CN_OutletWS__c).ASI_CRM_SG_Tax_Expl_Code__c =='V' ){
                        i.ASI_CRM_GST__c =true;
                        i.ASI_CRM_GST_Rate__c = decGST;
                    }else{
                        i.ASI_CRM_GST__c =false;
                        i.ASI_CRM_GST_Rate__c = 0;   
                    }
                    
                    // To fill the PV Raise Date
                    if (i.ASI_CRM_PVRaiseDate__c == null) {
                        i.ASI_CRM_PVRaiseDate__c = Date.today();
                    }
                    
                    if(i.ASI_CRM_CN_OutletWS__c == null || 
                       (mapContract.get(i.ASI_TH_CRM_Contract__c) != null && mapCustomer.get(i.ASI_CRM_CN_OutletWS__c) != null &&
                        i.ASI_CRM_CN_OutletWS__c != mapContract.get(i.ASI_TH_CRM_Contract__c).ASI_CRM_CN_Outlet_WS__c && 
                        mapCustomer.get(i.ASI_CRM_CN_OutletWS__c).ASI_CRM_CN_Parent_Outlet__c != mapContract.get(i.ASI_TH_CRM_Contract__c).ASI_CRM_CN_Outlet_WS__c)){
                        i.addError('Outlet/WS or parent of Outlet/WS must be Outlet/WS of Contract.');
                    }
                    
                    if(i.ASI_CRM_A_P_Type__c== true && mapContract.get(i.ASI_TH_CRM_Contract__c)!=null){
                        Decimal totalEntitleCash = mapContract.get(i.ASI_TH_CRM_Contract__c).ASI_CRM_Contract_Entitled_AP_Cash__c !=null ?  mapContract.get(i.ASI_TH_CRM_Contract__c).ASI_CRM_Contract_Entitled_AP_Cash__c  :0;
                        Decimal totalPaidCash = mapContract.get(i.ASI_TH_CRM_Contract__c).ASI_CRM_Total_Paid_A_P_Cash__c !=null ?  mapContract.get(i.ASI_TH_CRM_Contract__c).ASI_CRM_Total_Paid_A_P_Cash__c  :0;
                        Decimal currentCash = i.ASI_TH_CRM_Total_Amount__c != null ? i.ASI_TH_CRM_Total_Amount__c : 0;
                        
                        if((totalPaidCash+currentCash)>totalEntitleCash){
                            i.ASI_CRM_MY_Exceed_AP_Entitled_Amt__c =true;
                            i.ASI_CRM_System_Remark__c ='Please note that current Cash Value (A&P) + Paid Cash Value (A&P) exceeds Total Entitled A&P Cash Values (by '+(totalPaidCash+currentCash-totalEntitleCash) +'). ';
                        }else{
                            i.ASI_CRM_MY_Exceed_AP_Entitled_Amt__c =false;
                            i.ASI_CRM_System_Remark__c ='';
                        }
                    }

                }
            }
        }
    }
    
    public static void routineBeforeUpdate(list<ASI_TH_CRM_PaymentRequest__c> trigger_new, map<id, ASI_TH_CRM_PaymentRequest__c> trigger_oldMap) {
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)) {
            // Declaration
            id idRT_MY_PR = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_MY_Payment_Request');
            id idRT_MY_PR_RO = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_MY_Payment_Request_Read_Only');
            set<id> setCustomerID = new set<id>();
            set<id> setContractId = new set<id>();
            list<ASI_CRM_AccountsAdditionalField__c> listCustomer = new list<ASI_CRM_AccountsAdditionalField__c>();
            map<Id, ASI_CRM_AccountsAdditionalField__c> mapCustomer = new map<Id, ASI_CRM_AccountsAdditionalField__c>();
            List<ASI_TH_CRM_Contract__c> listContract = new List<ASI_TH_CRM_Contract__c>();
            map<Id, ASI_TH_CRM_Contract__c> mapContract = new map<Id, ASI_TH_CRM_Contract__c>();
            // Declaration - End
            
            for (ASI_TH_CRM_PaymentRequest__c i : trigger_new){
                setCustomerID.add(i.ASI_CRM_CN_OutletWS__c);
                setContractId.add(i.ASI_TH_CRM_Contract__c);
            }        
            
            listContract = [SELECT id, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_Contract_Entitled_AP_Cash__c, ASI_CRM_Total_Paid_A_P_Cash__c FROM ASI_TH_CRM_Contract__c WHERE Id IN:setContractId];
            listCustomer = [SELECT id, ASI_CRM_CN_Legal_Name__c, ASI_CRM_CN_Parent_Outlet__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN:setCustomerID];
            
            for(ASI_CRM_AccountsAdditionalField__c cust : listCustomer){
                mapCustomer.put(cust.id, cust);
            }
            for(ASI_TH_CRM_Contract__c con : listContract){
                mapContract.put(con.id, con);
            }
            
            for (ASI_TH_CRM_PaymentRequest__c objPR : trigger_new) {
                
                if (objPR.ASI_TH_CRM_Status__c  != 'Draft') {
                    objPR.recordTypeId = idRT_MY_PR_RO;
                }
                else{
                    objPR.recordTypeId = idRT_MY_PR;
                }
                
                if (objPR.ASI_TH_CRM_Status__c  == 'Cancelled') {
                    objPR.ASI_CRM_SG_Invoice_No__c = '';
                    objPR.ASI_CRM_Sync_to_JDE__c  = false;
                    objPR.ASI_CRM_JDEPVNum__c  = '';
                }
                
                // Disallow to change the GST checkbox after creation
                if (objPR.recordTypeId == idRT_MY_PR) {
                    if (trigger_oldMap.get(objPR.Id) != NULL && objPR.ASI_CRM_GST__c != trigger_oldMap.get(objPR.Id).ASI_CRM_GST__c) {
                        objPR.addError('Cannot change "GST" after creation');
                    }
                }
                
                if(objPR.ASI_CRM_CN_OutletWS__c == null ||
                   (mapContract.get(objPR.ASI_TH_CRM_Contract__c) != null && mapCustomer.get(objPR.ASI_CRM_CN_OutletWS__c) != null &&
                    objPR.ASI_CRM_CN_OutletWS__c != mapContract.get(objPR.ASI_TH_CRM_Contract__c).ASI_CRM_CN_Outlet_WS__c && 
                    mapCustomer.get(objPR.ASI_CRM_CN_OutletWS__c).ASI_CRM_CN_Parent_Outlet__c != mapContract.get(objPR.ASI_TH_CRM_Contract__c).ASI_CRM_CN_Outlet_WS__c)){
                    objPR.addError('Outlet should be the same as Contract Outlet or its child outlet.');
                }

                if(objPR.ASI_CRM_A_P_Type__c== true && mapContract.get(objPR.ASI_TH_CRM_Contract__c)!=null && (objPR.ASI_TH_CRM_Status__c!='Approved' ||(objPR.ASI_TH_CRM_Status__c=='Approved' && trigger_oldMap.get(objPR.Id).ASI_TH_CRM_Status__c!='Approved'))){
                    Decimal totalEntitleCash = mapContract.get(objPR.ASI_TH_CRM_Contract__c).ASI_CRM_Contract_Entitled_AP_Cash__c !=null ?  mapContract.get(objPR.ASI_TH_CRM_Contract__c).ASI_CRM_Contract_Entitled_AP_Cash__c  :0;
                    Decimal totalPaidCash = mapContract.get(objPR.ASI_TH_CRM_Contract__c).ASI_CRM_Total_Paid_A_P_Cash__c !=null ?  mapContract.get(objPR.ASI_TH_CRM_Contract__c).ASI_CRM_Total_Paid_A_P_Cash__c  :0;
                    Decimal currentCash = objPR.ASI_TH_CRM_Total_Amount__c != null ? objPR.ASI_TH_CRM_Total_Amount__c : 0;
                    
                    if((totalPaidCash+currentCash)>totalEntitleCash){
                        objPR.ASI_CRM_MY_Exceed_AP_Entitled_Amt__c =true;
                        objPR.ASI_CRM_System_Remark__c ='Please note that current Cash Value (A&P) + Paid Cash Value (A&P) exceeds Total Entitled A&P Cash Values (by '+(totalPaidCash+currentCash-totalEntitleCash) +'). ';
                    }else{
                        objPR.ASI_CRM_MY_Exceed_AP_Entitled_Amt__c =false;
                        objPR.ASI_CRM_System_Remark__c ='';
                    }
                }
            }
        }
    }

    public static void routineBeforeUpsert(list<ASI_TH_CRM_PaymentRequest__c> trigger_new){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){
            // Declaration
            List<ASI_TH_CRM_PaymentRequest__c> lstPR = new List<ASI_TH_CRM_PaymentRequest__c>();
            //Set<Id> setContract = new Set<Id>();
            //List<ASI_TH_CRM_Contract__c> lstContract = new List<ASI_TH_CRM_Contract__c>();
            //Map<Id, Decimal> mapContractPayment = new Map<Id, Decimal>();
            // Declaration - End
            
            for(ASI_TH_CRM_PaymentRequest__c i : trigger_new){
                if(i.ASI_TH_CRM_RequestBy__c == NULL)
                    lstPR.add(i);
                if(i.ASI_TH_CRM_Contract__c != NULL && i.ASI_CRM_Contract_Status__c == 'Final')
                    setContract.add(i.ASI_TH_CRM_Contract__c);
            }

            for(ASI_TH_CRM_PaymentRequest__c i : lstPR){
                i.ASI_TH_CRM_RequestBy__c = UserInfo.getUserId();
            }            
            
            /**if(setContract.size() > 0)
                lstContract = [SELECT id, ASI_CRM_CN_Outlet_WS__c FROM ASI_TH_CRM_Contract__c WHERE Id IN :setContract];
            
            for(AggregateResult i : [
                SELECT SUM(ASI_CRM_TotalPayment__c), ASI_TH_CRM_Contract__c 
                FROM ASI_TH_CRM_PaymentRequest__c 
                WHERE ASI_TH_CRM_Contract__c IN :setContract 
                AND ASI_TH_CRM_Status__c = 'Approved'
                AND ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c  = 'Final'
                AND ASI_TH_CRM_Contract__r.ASI_CRM_Terminate__c = FALSE
                AND ASI_TH_CRM_Contract__r.ASI_CRM_Obsolete_Version__c = FALSE
                GROUP BY ASI_TH_CRM_Contract__c 
            ]){
                Id idtemp = (Id) i.get('ASI_TH_CRM_Contract__c');
                Decimal dectemp = (Decimal) i.get('expr0');
                mapContractPayment.put(idtemp, dectemp);
            }
            
            for(ASI_TH_CRM_Contract__c i : lstContract){
               i.ASI_CRM_TotalPR__c = mapContractPayment.get(i.id);
            }
            
            try {
                update lstContract; // Temporary prevent to update the non edtiable contract because of the owner problem //TODO
            } catch (Exception e) {
                
            }**/
        }
    }
     
    /*
    public static void routineAfterInsert(list<ASI_TH_CRM_PaymentRequest__c> trigger_new) {
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)) {
            // Declaration
            ASI_CRM_MY_PaymentRequestCommon clsPRCommon = new ASI_CRM_MY_PaymentRequestCommon();
            list<ASI_TH_CRM_PaymentRequest__c> lstPR = new list<ASI_TH_CRM_PaymentRequest__c>();
            // Declaration - End
            
            // To auto spawn payment line items according to contract setting
            for (ASI_TH_CRM_PaymentRequest__c objPR : trigger_new) {
                lstPR.add(objPR);
            }
            
            clsPRCommon.spawnPaymentRequestLineItems(lstPR);
        }
    }
	*/
    
    public static void routineAfterInsert(list<ASI_TH_CRM_PaymentRequest__c> trigger_new) {
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)) {
            // Declaration
            ASI_CRM_MY_PaymentRequestCommon clsPRCommon = new ASI_CRM_MY_PaymentRequestCommon();
            list<ASI_TH_CRM_PaymentRequest__c> lstPR = new list<ASI_TH_CRM_PaymentRequest__c>();
            // Declaration - End
            
            // To auto spawn payment line items according to contract setting
            for (ASI_TH_CRM_PaymentRequest__c objPR : trigger_new) {
                lstPR.add(objPR);
            }
            
            //clsPRCommon.spawnPaymentRequestLineItems(lstPR);
        }
    }


    public static void routineAfterUpsert(list<ASI_TH_CRM_PaymentRequest__c> trigger_new) {
        if(setContract.size() > 0){
            Map<Id, Decimal> mapContractPayment = new Map<Id, Decimal>();
            Map<Id, Decimal> mapContractAdjustment = new Map<Id, Decimal>();
            Map<Id, Decimal> mapContractAPPayment = new Map<Id, Decimal>();
            lstContract = [SELECT id, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_Total_Paid_A_P_Cash__c, ASI_CRM_TotalPR__c FROM ASI_TH_CRM_Contract__c WHERE Id IN :setContract];
            
            //To get total payment & adjustment amount (exclude tax):
            for(AggregateResult i : [
                SELECT SUM(ASI_CRM_MY_Total_Adjusted_Payment__c) totalPayment, SUM(ASI_CRM_MY_Total_Adjustment_Amount__c) totalAdjustment, ASI_TH_CRM_Contract__c 
                FROM ASI_TH_CRM_PaymentRequest__c 
                WHERE ASI_TH_CRM_Contract__c IN :setContract 
                AND (ASI_TH_CRM_Status__c = 'Final' OR ASI_TH_CRM_Status__c='Approved' OR ASI_TH_CRM_Status__c='Submit for Cancel')
                AND ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c  = 'Final'
                AND ASI_TH_CRM_Contract__r.ASI_CRM_Terminate__c = FALSE
                AND ASI_TH_CRM_Contract__r.ASI_CRM_Obsolete_Version__c = FALSE
                GROUP BY ASI_TH_CRM_Contract__c 
            ]){
                Id idtemp = (Id) i.get('ASI_TH_CRM_Contract__c');
                Decimal dectemp = (Decimal) i.get('totalPayment');
                Decimal adjtemp = (Decimal) i.get('totalAdjustment');
                mapContractPayment.put(idtemp, dectemp);
                mapContractAdjustment.put(idtemp,adjtemp);
            }
            //system.debug('mapContractAdjustment:'+mapContractAdjustment);

            //To get total A&P payment amount(exclude tax):
            for(AggregateResult i : [
                SELECT SUM(ASI_CRM_MY_Total_Adjusted_Payment__c) totalPayment, ASI_TH_CRM_Contract__c 
                FROM ASI_TH_CRM_PaymentRequest__c 
                WHERE ASI_TH_CRM_Contract__c IN :setContract 
                AND (ASI_TH_CRM_Status__c = 'Final' OR ASI_TH_CRM_Status__c='Approved' OR ASI_TH_CRM_Status__c='Submit for Cancel')
                AND ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c  = 'Final'
                AND ASI_TH_CRM_Contract__r.ASI_CRM_Terminate__c = FALSE
                AND ASI_TH_CRM_Contract__r.ASI_CRM_Obsolete_Version__c = FALSE 
                AND ASI_CRM_A_P_Type__c = TRUE
                GROUP BY ASI_TH_CRM_Contract__c 
            ]){
                Id idtemp = (Id) i.get('ASI_TH_CRM_Contract__c');
                Decimal dectemp = (Decimal) i.get('totalPayment');
                mapContractAPPayment.put(idtemp, dectemp);
            }
            
            for(ASI_TH_CRM_Contract__c i : lstContract){
               i.ASI_CRM_TotalPR__c = mapContractPayment.get(i.id) == null ? 0 : mapContractPayment.get(i.id);
               i.ASI_CRM_MY_Total_Adjustment_Amount__c = mapContractAdjustment.get(i.id) == null ? 0 : mapContractAdjustment.get(i.id);
               i.ASI_CRM_Total_Paid_A_P_Cash__c = mapContractAPPayment.get(i.id) == null ? 0 :mapContractAPPayment.get(i.id);
               i.ASI_CRM_Total_Paid_Volume_Incentive__c = i.ASI_CRM_TotalPR__c - i.ASI_CRM_Total_Paid_A_P_Cash__c ;
            }
            
            try {
                update lstContract; // Temporary prevent to update the non edtiable contract because of the owner problem //TODO
            } catch (Exception e) {
                system.debug('ASI_CRM_MY_PaymentRequest_TriggerCls AfterTrigger  Update Contract Error:'+e);
            }
        }
                
    }

    public static void routineAfterUpdate(list<ASI_TH_CRM_PaymentRequest__c> trigger_new, Map<Id, ASI_TH_CRM_PaymentRequest__c> trigger_oldMap) {
        Set<Id> cancelPaymentIds = new Set<Id>();
         set<Id> FVPayIdSet = NEW set<Id>();
        for(ASI_TH_CRM_PaymentRequest__c payment: trigger_new ){
            if(payment.ASI_TH_CRM_Status__c =='Cancelled'){
                cancelPaymentIds.add(payment.Id);
            }
            if(trigger_oldMap.get(payment.Id) != NULL && payment.ASI_TH_CRM_Status__c != trigger_oldMap.get(payment.Id).ASI_TH_CRM_Status__c && payment.ASI_TH_CRM_Status__c =='Finance Verified' ){
                FVPayIdSet.add(payment.Id);
            }
        }
        if(FVPayIdSet.size()>0){
            Database.executeBatch(new ASI_CRM_MY_PaymentInterface_Batch(FVPayIdSet),1);
        }
        if(cancelPaymentIds.size()>0){
            List<ASI_CRM_Calculated_Payment__c> l_CalcPayment = new List<ASI_CRM_Calculated_Payment__c>();
            l_CalcPayment =[SELECT Id, Name, ASI_CRM_Used_for_Payment__c, ASI_CRM_Used_By_Payment_Request__c FROM ASI_CRM_Calculated_Payment__c WHERE ASI_CRM_Used_By_Payment_Request__c in:cancelPaymentIds AND RecordTypeId=:Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_Payment__cASI_CRM_MY_Calculated_FOC_Payment_Type') AND ASI_CRM_Used_for_Payment__c=true ];
            if(l_CalcPayment.size()>0){
                for(ASI_CRM_Calculated_Payment__c calcPayment :l_CalcPayment){
                    //calcPayment.ASI_CRM_Used_By_Payment_Request__c = null;
                    calcPayment.ASI_CRM_Used_for_Payment__c = false;
                }
                update l_CalcPayment;
            }
        }
    }
    
    
    
    public static void routineBeforeDelete(list<ASI_TH_CRM_PaymentRequest__c> trigger_old){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){

            for(ASI_TH_CRM_PaymentRequest__c objPR : trigger_old) {
                if(objPR.ASI_TH_CRM_Status__c != 'Draft'){
                    objPR.addError('Only Draft Payment Request can be deleted.');
                }
            }
            
        }
    }
}