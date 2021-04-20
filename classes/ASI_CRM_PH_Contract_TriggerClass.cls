/***************************************************************************************************************************
 * Name:        ASI_CRM_PH_Contract_TriggerClass
 * Description: CRM PH Contract Trigger Class
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-08-30       LAPUTA: Calvin Chiu     Created
 * 2018-09-05       LAPUTA: Vincent Lam     Add currency population
 * 2018-10-18       LAPUTA: Calvin Chiu     Add checking on Special Contract field in contract date overlap validation
 ****************************************************************************************************************************/
public without sharing class ASI_CRM_PH_Contract_TriggerClass{    
    private static Boolean isBypassByCurrentUser() {
        Boolean isByPass = false;
        ID curUserId = UserInfo.getUserId();
        User u = ASI_CRM_CN_Function.getUser(curUserId);           
        if(u != null && u.BypassTriggers__c != null){
            if (u.BypassTriggers__c.contains('ASI_CRM_PH_Contract_TriggerClass')){
                isByPass = true;
            }
        }
        return isByPass;
    }
    
    public static void routineBeforeInsert(List<ASI_TH_CRM_Contract__c> trigger_new) {
        ASI_CRM_PH_AutoNumberAssignment autoNumAssign = new ASI_CRM_PH_AutoNumberAssignment('ASI_CRM_PH_Contract');
        for (ASI_TH_CRM_Contract__c so : trigger_new) {
            System.Debug('Start Assign');
            so.Name = autoNumAssign.nextAutoNumStr();
        }
        autoNumAssign.writeToDB();
    }
    
    public static void routineBeforeUpsert(list<ASI_TH_CRM_Contract__c> trigger_new, Map<Id, ASI_TH_CRM_Contract__c> trigger_oldMap){
		if(!isBypassByCurrentUser()){
             checkOverlap(trigger_new,trigger_oldMap);
             populateCurrency(trigger_new,trigger_oldMap);
			 populateDistributionRate(trigger_new);
        }
    }
    
    public static void routineAfterUpdate(list<ASI_TH_CRM_Contract__c> trigger_new, Map<Id, ASI_TH_CRM_Contract__c> trigger_oldMap){
        Set<Id> approvedContract = new Set<Id>();
        for(ASI_TH_CRM_Contract__c contract: trigger_new){
            if(trigger_oldMap.get(contract.id).ASI_CRM_CN_Approval_Status__c != contract.ASI_CRM_CN_Approval_Status__c && contract.ASI_CRM_CN_Approval_Status__c == 'Approved'){
                approvedContract.add(contract.id);
            }
        }        
        
        List<ASI_CRM_ContractTarget__c> targetList = new List<ASI_CRM_ContractTarget__c>();
        for(ASI_CRM_ContractTarget__c target:[select ASI_CRM_Approved__c from ASI_CRM_ContractTarget__c where ASI_CRM_Contract__c in: approvedContract]){
            target.ASI_CRM_Approved__c = true;
            targetList.add(target);
        }
        
        update targetList;
    }
    
    public static void routineBeforeDelete(list<ASI_TH_CRM_Contract__c> trigger_old){
        for(ASI_TH_CRM_Contract__c contract: trigger_old){
            contract.addError(Label.ASI_CRM_PH_BlockDeleteContract);
        }     
    }
    
    public static void checkOverlap(list <ASI_TH_CRM_Contract__c > trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap){
        List<ASI_TH_CRM_Contract__c> existingContract= [Select ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c, ASI_CRM_CN_Outlet_WS__c                                                      
                                                          from ASI_TH_CRM_Contract__c 
                                                          where recordType.DeveloperName in ('ASI_CRM_PH_Contract','ASI_CRM_PH_Contract_Read_Only') and id not in :trigger_new order by ASI_TH_CRM_Start_Date__c desc];
        if(!existingContract.isEmpty()){
            for(ASI_TH_CRM_Contract__c c : trigger_new){
                if(!c.ASI_CRM_Special_Contract__c){
                    Boolean isOverlap = false;
                    for(ASI_TH_CRM_Contract__c contractOld : existingContract){
                       if(isOverlap(contractOld.ASI_TH_CRM_Start_Date__c, contractOld.ASI_TH_CRM_End_Date__c, c.ASI_TH_CRM_Start_Date__c, c.ASI_TH_CRM_End_Date__c) && contractOld.ASI_CRM_CN_Outlet_WS__c == c.ASI_CRM_CN_Outlet_WS__c){
                           isOverlap = true;
                           break;
                       }
                    }               
                    if(isOverlap){
                        c.addError(Label.ASI_CRM_CN_Contract_Date_Overlap);
                    }                
                }
            }
        }        
    }
    
    public static void populateCurrency(list <ASI_TH_CRM_Contract__c > trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap){
        set<string> set_customerId = new set<string>();
        for(ASI_TH_CRM_Contract__c c : trigger_new){
            if(c.ASI_CRM_CN_Outlet_WS__c != null){
                set_customerId.add(c.ASI_CRM_CN_Outlet_WS__c);
            }
        }
        map<Id, ASI_CRM_AccountsAdditionalField__c> map_c = new map<Id, ASI_CRM_AccountsAdditionalField__c>([select id, ASI_CRM_Duty_Free__c from ASI_CRM_AccountsAdditionalField__c where id in :set_customerId]);
        for(ASI_TH_CRM_Contract__c c : trigger_new){
            if(
                (trigger_oldMap == null || trigger_oldMap.get(c.id).ASI_CRM_CN_Outlet_WS__c != c.ASI_CRM_CN_Outlet_WS__c)
            ){
                if(c.ASI_CRM_CN_Outlet_WS__c != null && map_c.get(c.ASI_CRM_CN_Outlet_WS__c).ASI_CRM_Duty_Free__c){
                    c.ASI_CRM_CN_Currency__c = 'USD';
                }else{
                    c.ASI_CRM_CN_Currency__c = 'PHP';
                    c.ASI_CRM_CN_Exchange_Rate__c = 1;
                }
                
            }
        }
    }
    
    public static void populateDistributionRate(list <ASI_TH_CRM_Contract__c > trigger_new){
        ASI_CRM_PH_Rate__mdt rate = [select ASI_CRM_Rate__c from ASI_CRM_PH_Rate__mdt where MasterLabel = 'Distribution' limit 1];
        for(ASI_TH_CRM_Contract__c c : trigger_new){
            c.ASI_CRM_Distribution_Rate__c = rate.ASI_CRM_Rate__c;
        }
    }
    
    public static boolean isOverlap(Date LastConStartDate, Date LastConEndDate, Date ThisConStartDate, Date ThisConEndDate){
        boolean overlap = false;
        /*
        LastConStartDate = LastConStartDate.toStartOfMonth();
        LastConEndDate = LastConEndDate.toStartOfMonth().addMonths(1).addDays(-1);   */
        if((ThisConStartDate < LastConStartDate && ThisConEndDate < LastConStartDate) || (ThisConStartDate > LastConEndDate && ThisConEndDate > LastConEndDate))
            overlap = false;
        else
            overlap = true;
        return overlap;
    }
    
}