/*********************************************************************************
 * Name:        ASI_CRM_MY_FreeGoodsRequest_TriggerClass --> ASI_CRM_MY_FreeGoodsRequest_TriggerCls
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-12-31       Introv: Daniel WONG     Created
 * 2015-01-22       Introv: Twinkle LI      Outlet/WS Parent Child Validation "Outlet should be the same as Contract Outlet or its child outlet"
 * 2014-12-31       Introv                  Updated summary info, e.g. total paid A&P bottle value
*********************************************************************************/

public without sharing class ASI_CRM_MY_FreeGoodsRequest_TriggerCls{
    public static String className = 'ASI_CRM_MY_FreeGoodsRequest_TriggerCls';
    public static ID RTID = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_FOC_MY_FreeGoodsRequest');
   	public static ID RTID_RO = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_FOC_MY_FreeGoodsRequest_Read_Only');
    public static set<id> setContractId = new set<id>();
    public static List<ASI_TH_CRM_Contract__c> listContract = new List<ASI_TH_CRM_Contract__c>();


    public static void routineBeforeInsert(list<ASI_FOC_Free_Goods_Request__c> trigger_new){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)) {
            ASI_CRM_MY_RunningNumber_TriggerClass autoNumAssign = null;        
            set<id> setCustomerID = new set<id>();
            //set<id> setContractId = new set<id>();
            list<ASI_CRM_AccountsAdditionalField__c> listCustomer = new list<ASI_CRM_AccountsAdditionalField__c>();
            map<Id, ASI_CRM_AccountsAdditionalField__c> mapCustomer = new map<Id, ASI_CRM_AccountsAdditionalField__c>();
            //List<ASI_TH_CRM_Contract__c> listContract = new List<ASI_TH_CRM_Contract__c>();
            map<Id, ASI_TH_CRM_Contract__c> mapContract = new map<Id, ASI_TH_CRM_Contract__c>();
            
            for (ASI_FOC_Free_Goods_Request__c i : trigger_new){
                if(i.recordTypeId == RTID){
                    setCustomerID.add(i.ASI_CRM_Outlet__c);
                    setContractId.add(i.ASI_CRM_Contract__c);
                    i.ASI_FOC_Date_of_Delivery__c = system.today();
                }
            }        
            
            listContract = [SELECT id, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_Contract_Entitled_AP_Btl_Value__c, ASI_CRM_Total_Paid_A_P_Bottle_Value__c FROM ASI_TH_CRM_Contract__c WHERE Id IN:setContractId];
            listCustomer = [SELECT id, ASI_CRM_CN_Legal_Name__c, ASI_CRM_CN_Parent_Outlet__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN:setCustomerID];
            
            for (ASI_CRM_AccountsAdditionalField__c i : listCustomer) {
                mapCustomer.put(i.id, i);
            }
            for(ASI_TH_CRM_Contract__c con : listContract){
                mapContract.put(con.id, con);
            }
            
            for(ASI_FOC_Free_Goods_Request__c i : trigger_new){
                
                if(i.recordTypeId == RTID){
                    if(autoNumAssign == NULL){
                        autoNumAssign = new ASI_CRM_MY_RunningNumber_TriggerClass('FIS'); // to Match the Module in Running Number
                        i.ASI_CRM_Request_Number__c = autoNumAssign.nextAutoNumStr();
                        autoNumAssign.writeToDB();
                    }
                }
                if(i.ASI_CRM_Outlet__c == null || 
                   (mapContract.get(i.ASI_CRM_Contract__c) != null && mapCustomer.get(i.ASI_CRM_Outlet__c) != null &&
                    i.ASI_CRM_Outlet__c != mapContract.get(i.ASI_CRM_Contract__c).ASI_CRM_CN_Outlet_WS__c && 
                    mapCustomer.get(i.ASI_CRM_Outlet__c).ASI_CRM_CN_Parent_Outlet__c != mapContract.get(i.ASI_CRM_Contract__c).ASI_CRM_CN_Outlet_WS__c)){
                    i.addError('Outlet/WS or parent of Outlet/WS must be Outlet/WS of Contract.');
                }

                if(i.ASI_CRM_AP_Type__c== true && mapContract.get(i.ASI_CRM_Contract__c)!=null){
                    Decimal totalEntitleBtlVal = mapContract.get(i.ASI_CRM_Contract__c).ASI_CRM_Contract_Entitled_AP_Btl_Value__c !=null ?  mapContract.get(i.ASI_CRM_Contract__c).ASI_CRM_Contract_Entitled_AP_Btl_Value__c  :0;
                    Decimal totalPaidBtlVal = mapContract.get(i.ASI_CRM_Contract__c).ASI_CRM_Total_Paid_A_P_Bottle_Value__c !=null ?  mapContract.get(i.ASI_CRM_Contract__c).ASI_CRM_Total_Paid_A_P_Bottle_Value__c  :0;
                    Decimal currentFOCVal = i.ASI_CRM_Total_Bottle_Value__c != null ? i.ASI_CRM_Total_Bottle_Value__c : 0;
                    
                    if((totalPaidBtlVal+currentFOCVal)>totalEntitleBtlVal){
                        i.ASI_CRM_MY_Exceed_AP_Entitled_Amt__c =true;
                        i.ASI_CRM_System_Remark__c ='Please note that current FOC Bottle Value (A&P) + Paid FOC Bottle Value (A&P) exceeds Total Entitled A&P Bottle Values (by '+(totalPaidBtlVal+currentFOCVal-totalEntitleBtlVal) +'). ';
                    }else {
                        i.ASI_CRM_MY_Exceed_AP_Entitled_Amt__c =false;
                        i.ASI_CRM_System_Remark__c ='';
                    }
                    
                }
            }     
        }  
    }
    
    public static void routineBeforeUpdate(list<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap) {
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)) {
            set<id> setCustomerID = new set<id>();
            //set<id> setContractId = new set<id>();
            list<ASI_CRM_AccountsAdditionalField__c> listCustomer = new list<ASI_CRM_AccountsAdditionalField__c>();
            map<Id, ASI_CRM_AccountsAdditionalField__c> mapCustomer = new map<Id, ASI_CRM_AccountsAdditionalField__c>();
            //List<ASI_TH_CRM_Contract__c> listContract = new List<ASI_TH_CRM_Contract__c>();
            map<Id, ASI_TH_CRM_Contract__c> mapContract = new map<Id, ASI_TH_CRM_Contract__c>();
            
            for (ASI_FOC_Free_Goods_Request__c i : trigger_new){
                setCustomerID.add(i.ASI_CRM_Outlet__c);
                setContractId.add(i.ASI_CRM_Contract__c);
            }        
            
            listContract = [SELECT id, ASI_CRM_CN_Outlet_WS__c,ASI_CRM_Contract_Entitled_AP_Btl_Value__c, ASI_CRM_Total_Paid_A_P_Bottle_Value__c FROM ASI_TH_CRM_Contract__c WHERE Id IN:setContractId];
            listCustomer = [SELECT id, ASI_CRM_CN_Legal_Name__c, ASI_CRM_CN_Parent_Outlet__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN:setCustomerID];
            
            for (ASI_CRM_AccountsAdditionalField__c i : listCustomer) {
                mapCustomer.put(i.id, i);
            }
            for(ASI_TH_CRM_Contract__c con : listContract){
                mapContract.put(con.id, con);
            }

            for(ASI_FOC_Free_Goods_Request__c i : trigger_new){
                if(i.ASI_CRM_Status__c != 'Draft'){
                    i.RecordTypeId = RTID_RO;
                }
                else{
                    i.RecordTypeId = RTID;
                }
                
                if(i.ASI_CRM_Outlet__c == null || 
                  (mapContract.get(i.ASI_CRM_Contract__c) != null && mapCustomer.get(i.ASI_CRM_Outlet__c) != null &&
                   i.ASI_CRM_Outlet__c != mapContract.get(i.ASI_CRM_Contract__c).ASI_CRM_CN_Outlet_WS__c && 
                   mapCustomer.get(i.ASI_CRM_Outlet__c).ASI_CRM_CN_Parent_Outlet__c != mapContract.get(i.ASI_CRM_Contract__c).ASI_CRM_CN_Outlet_WS__c)){
                    i.addError('Outlet should be the same as Contract Outlet or its child outlet.');
                }

                if(i.ASI_CRM_AP_Type__c== true && mapContract.get(i.ASI_CRM_Contract__c)!=null && (i.ASI_CRM_Status__c!='Final' ||(i.ASI_CRM_Status__c=='Final' && trigger_oldMap.get(i.Id).ASI_CRM_Status__c!='Final'))){
                    Decimal totalEntitleBtlVal = mapContract.get(i.ASI_CRM_Contract__c).ASI_CRM_Contract_Entitled_AP_Btl_Value__c !=null ?  mapContract.get(i.ASI_CRM_Contract__c).ASI_CRM_Contract_Entitled_AP_Btl_Value__c  :0;
                    Decimal totalPaidBtlVal = mapContract.get(i.ASI_CRM_Contract__c).ASI_CRM_Total_Paid_A_P_Bottle_Value__c !=null ?  mapContract.get(i.ASI_CRM_Contract__c).ASI_CRM_Total_Paid_A_P_Bottle_Value__c  :0;
                    Decimal currentFOCVal = i.ASI_CRM_Total_Bottle_Value__c != null ? i.ASI_CRM_Total_Bottle_Value__c : 0;
                    Decimal oldFOCVal = trigger_oldMap.get(i.Id).ASI_CRM_Total_Bottle_Value__c != null ? trigger_oldMap.get(i.Id).ASI_CRM_Total_Bottle_Value__c : 0;
                    
                    if((totalPaidBtlVal+currentFOCVal)>totalEntitleBtlVal){
                        i.ASI_CRM_MY_Exceed_AP_Entitled_Amt__c =true;
                        i.ASI_CRM_System_Remark__c ='Please note that current FOC Bottle Value (A&P) + Paid FOC Bottle Value (A&P) exceeds Total Entitled A&P Bottle Values (by '+(totalPaidBtlVal+currentFOCVal-totalEntitleBtlVal) +'). ';
                    }else{
                        i.ASI_CRM_MY_Exceed_AP_Entitled_Amt__c =false;
                        i.ASI_CRM_System_Remark__c ='';
                    }
                }
            }       
        }
    }


    public static void routineAfterUpsert(list<ASI_FOC_Free_Goods_Request__c> trigger_new) {
        
        if(listContract.size() > 0){
            Map<Id, Decimal> mapContractAPBottleValue = new Map<Id, Decimal>();
            
            //Update total final A&P bottle values:
            for(AggregateResult i : [
                SELECT SUM(ASI_CRM_Total_Bottle_Value__c), ASI_CRM_Contract__c  
                FROM ASI_FOC_Free_Goods_Request__c 
                WHERE ASI_CRM_Contract__c IN :setContractId 
                AND (ASI_CRM_Status__c = 'Final' OR ASI_CRM_Status__c = 'Sent' OR ASI_CRM_Status__c ='Not Converted' OR ASI_CRM_Status__c ='Submit for Cancel')
                AND ASI_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c  = 'Final'
                AND ASI_CRM_Contract__r.ASI_CRM_Terminate__c = FALSE
                AND ASI_CRM_Contract__r.ASI_CRM_Obsolete_Version__c = FALSE 
                AND ASI_CRM_AP_Type__c = TRUE
                GROUP BY ASI_CRM_Contract__c 
            ]){
                Id idtemp = (Id) i.get('ASI_CRM_Contract__c');
                Decimal dectemp = (Decimal) i.get('expr0');
                mapContractAPBottleValue.put(idtemp, dectemp);
            }
            
            for(ASI_TH_CRM_Contract__c i : listContract){
               i.ASI_CRM_Total_Paid_A_P_Bottle_Value__c = mapContractAPBottleValue.get(i.id) == null ? 0 :mapContractAPBottleValue.get(i.id);
            }
            
            try {
                update listContract; // Temporary prevent to update the non edtiable contract because of the owner problem //TODO
            } catch (Exception e) {
                system.debug('ASI_FOC_Free_Goods_Request__c AfterTrigger  Update Contract Error:'+e);
            }
        }

    }

    public static void routineAfterUpdate(list<ASI_FOC_Free_Goods_Request__c> trigger_new, Map<Id,ASI_FOC_Free_Goods_Request__c>trigger_oldMap) {
        Set<Id> cancelOrderIds = new Set<Id>();
        for(ASI_FOC_Free_Goods_Request__c foc: trigger_new ){
            if(foc.ASI_CRM_Status__c =='Cancelled'){
                cancelOrderIds.add(foc.Id);
            }
        }
        if(cancelOrderIds.size()>0){
            List<ASI_CRM_Calculated_FOC__c> l_CalcFOC = new List<ASI_CRM_Calculated_FOC__c>();
            l_CalcFOC =[SELECT Id, Name, ASI_CRM_Used_By_FOC__c, ASI_CRM_Used_For_FOC__c FROM ASI_CRM_Calculated_FOC__c WHERE ASI_CRM_Used_By_FOC__c in:cancelOrderIds AND RecordTypeId=:Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_FOC__cASI_CRM_MY_Calculated_FOC') AND ASI_CRM_Used_For_FOC__c=true ];
            if(l_CalcFOC.size()>0){
                for(ASI_CRM_Calculated_FOC__c calcFOC :l_CalcFOC){
                    //calcFOC.ASI_CRM_Used_By_FOC__c = null;
                    calcFOC.ASI_CRM_Used_For_FOC__c = false;
                }
                update l_CalcFOC;
            }
        }
    }

}