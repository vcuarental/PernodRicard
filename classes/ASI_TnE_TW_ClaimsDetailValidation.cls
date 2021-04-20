/*********************************************************************************
 * Name:ASI_TnE_TW_ClaimsDetailValidation
 * Description: Validation for claims detail
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 23/11/2015         Laputa: Hank            Created
 * 05/09/2018       SOA                     [SOA 1.0] Modify A&P/A&D overspend checking logic
 * 21/05/2019       SH                      [SH 1.0] Assign Email Notice from Charge To or Plan Owner
*********************************************************************************/

public without sharing class ASI_TnE_TW_ClaimsDetailValidation extends ASI_TnE_TriggerAbstract {

    public ASI_TnE_TW_ClaimsDetailValidation() {
        super('ASI_TnE_TW_ClaimsDetailValidation');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_TnE_ClaimDetail__c> detailList = (List<ASI_TnE_ClaimDetail__c>)sObjList;
        Set<Id> headerIdSet = new Set<Id>();
        
        Set<id> SupplierIdSet = new Set<id>();
        Set<Id> PlanIdSet = new Set<Id>();
        Map<Id, Id> UserPlanMap = new Map<Id, Id>();
        if(oldMap == null){
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                headerIDSet.add(detail.ASI_TnE_ClaimHeader__c);    
            }
        }else{
            Map<Id, ASI_TnE_ClaimDetail__c> detailOldMap = (Map<Id, ASI_TnE_ClaimDetail__c>)oldMap;
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                if(detail.ASI_TnE_Receipt_Date__c != detailOldMap.get(detail.Id).ASI_TnE_Receipt_Date__c || detail.ASI_TnE_KR_Receipt_Time__c == null){
                    headerIDSet.add(detail.ASI_TnE_ClaimHeader__c);    
                }
                // [SH] 2019-05-21
        		if(detail.ASI_TnE_Charge_To_Acc__c != detailOldMap.get(detail.Id).ASI_TnE_Charge_To_Acc__c && detail.ASI_TnE_Charge_To_Acc__c != null)
                    SupplierIdSet.add(detail.ASI_TnE_Charge_To_Acc__c);
                if(detail.ASI_TnE_CAP_Plan__c != detailOldMap.get(detail.Id).ASI_TnE_CAP_Plan__c && detail.ASI_TnE_CAP_Plan__c != null)
                    PlanIdSet.add(detail.ASI_TnE_CAP_Plan__c);
                // END - [SH]
            }
        }
        
        //Get owner/payee information from header
        Map<Id, ASI_TnE_ClaimHeader__c> headerMap = new Map<Id, ASI_TnE_ClaimHeader__c>(
            [Select Id, 
                    ownerId, 
                    owner.firstname,
                    ASI_TnE_Payee_Employee__c
             From ASI_TnE_ClaimHeader__c 
             Where Id In:headerIdSet
            ]
        );
        
        // [SH] 2019-05-21        
        Map<Id, Account> SupplierMap = new Map<Id, Account>(
            [Select id,
             ASI_LUX_Email_Business__c 
             From Account
             Where Id in :SupplierIdSet]                
        );        
        Map<Id, User> UserMap ;
        if(PlanIdSet.size() > 0){
            for(ASI_MFM_Plan__c plan: [Select ASI_MFM_Owner_link__c from ASI_MFM_Plan__c where id in:PlanIdSet]){
                UserPlanMap.put(plan.id, plan.ASI_MFM_Owner_link__c);
            }
            UserMap = new Map<Id, User>([Select id, email from User where id in :UserPlanMap.values()]);
        }
        // END - [SH]
        
        if(oldMap == null){
            for(ASI_TnE_ClaimDetail__c detail:detailList){
               detail.ASI_TnE_KR_Receipt_Time__c = headerMap.get(detail.ASI_TnE_ClaimHeader__c).ownerId + 
                                                   headerMap.get(detail.ASI_TnE_ClaimHeader__c).owner.firstname + 
                                                   ((detail.ASI_TnE_Receipt_Date__c == null)?'':string.valueof(detail.ASI_TnE_Receipt_Date__c.year())) + 
                                                   ((detail.ASI_TnE_Receipt_Date__c == null)?'':string.valueof(detail.ASI_TnE_Receipt_Date__c.month())) +
                                                   ((detail.ASI_TnE_Receipt_Date__c == null)?'':string.valueof(detail.ASI_TnE_Receipt_Date__c.day()));
            }
        }else{
            Map<Id, ASI_TnE_ClaimDetail__c> detailOldMap = (Map<Id, ASI_TnE_ClaimDetail__c>)oldMap;
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                if(detail.ASI_TnE_Receipt_Date__c != detailOldMap.get(detail.Id).ASI_TnE_Receipt_Date__c || detail.ASI_TnE_KR_Receipt_Time__c == null){
                    system.debug('Validation check: ' + headerMap.get(detail.ASI_TnE_ClaimHeader__c).ownerId);
                    detail.ASI_TnE_KR_Receipt_Time__c = headerMap.get(detail.ASI_TnE_ClaimHeader__c).ownerId + 
                                                        headerMap.get(detail.ASI_TnE_ClaimHeader__c).owner.firstname + 
                                                        ((detail.ASI_TnE_Receipt_Date__c == null)?'':string.valueof(detail.ASI_TnE_Receipt_Date__c.year())) + 
                                                        ((detail.ASI_TnE_Receipt_Date__c == null)?'':string.valueof(detail.ASI_TnE_Receipt_Date__c.month())) +
                                                        ((detail.ASI_TnE_Receipt_Date__c == null)?'':string.valueof(detail.ASI_TnE_Receipt_Date__c.day()));  
                }
                // [SH] 2019-05-21
        		if(detail.ASI_TnE_Charge_To_Acc__c != detailOldMap.get(detail.Id).ASI_TnE_Charge_To_Acc__c && detail.ASI_TnE_Charge_To_Acc__c != null)
                    detail.ASI_TnE_Email_Notice__c = SupplierMap.get(detail.ASI_TnE_Charge_To_Acc__c).ASI_LUX_Email_Business__c;
                if(detail.ASI_TnE_CAP_Plan__c != detailOldMap.get(detail.Id).ASI_TnE_CAP_Plan__c && detail.ASI_TnE_CAP_Plan__c != null)
                    detail.ASI_TnE_Email_Notice__c = UserMap.get(UserPlanMap.get(detail.ASI_TnE_CAP_Plan__c)).Email;
                // END - [SH]
            } 
        }
        
        // [SOA 1.0]
        Map<string,string>ac_codeMap=new Map<string,string> ();
        for(asi_mfm_a_c_code__c ac:   [select ASI_MFM_A_C_Code__c,ASI_MFM_A_and_P_Tree__c from asi_mfm_a_c_code__c where recordtype.name ='TW A/C Code']){
            ac_codeMap.put(ac.ASI_MFM_A_C_Code__c,ac.ASI_MFM_A_and_P_Tree__c );
        }  
        
        for(ASI_TnE_ClaimDetail__c detail: detailList){
            String accode=detail.ASI_TnE_Account_Number__c==null || detail.ASI_TnE_Account_Number__c.equals('')? '':detail.ASI_TnE_Account_Number__c.substring(detail.ASI_TnE_Account_Number__c.indexof('.')+1);
            
            if(!ac_codeMap.containsKey(accode))
                continue;
            if(ac_codeMap.get(accode)=='TOTAL A&P') {                
                detail.ASI_TnE_AD_AP__c = 'A&P';
            }else{
                detail.ASI_TnE_AD_AP__c = 'A&D';
            }
        }
        // [SOA 1.0] End                 
    }
}