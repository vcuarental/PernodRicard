/*********************************************************************************
 * Name:ASI_TnE_ClaimsDetailUpdatePO
 * Description: Update PO
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 24/06/2015       Laputa: Hank            Created
*********************************************************************************/

public without sharing class ASI_TnE_ClaimsDetailUpdatePO extends ASI_TnE_TriggerAbstract {

    public ASI_TnE_ClaimsDetailUpdatePO() {
        super('ASI_TnE_ClaimsDetailUpdatePO');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        String CurrentClassName = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
        System.Debug('Execution Start := ' + CurrentClassName);

        System.Debug('Start Getting Exchange Rate Map');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries());
        
		//Vincent 20161221 Initialize PO Exchange Rate Map
		//Contains USD-SGD, SGD-USD, SG Market
		Map<String, ASI_MFM_Exchange_Rate__c> map_ExRate = new Map<String, ASI_MFM_Exchange_Rate__c>();
		List <ASI_MFM_Exchange_Rate__c> List_ExRate = [SELECT id, name, ASI_MFM_Base_Currency__c, ASI_MFM_Counter_Currency__c, ASI_MFM_Country__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c where ASI_MFM_Base_Currency__c in ('USD', 'SGD') and ASI_MFM_Counter_Currency__c in ('SGD', 'USD') AND ASI_MFM_Effective_Date__c <= :System.today() and ASI_MFM_Country__c = 'SG' ORDER BY ASI_MFM_Effective_Date__c DESC];
		for (ASI_MFM_Exchange_Rate__c idx : List_ExRate) {
            if (!map_ExRate.containsKey(idx.ASI_MFM_Base_Currency__c+idx.ASI_MFM_Counter_Currency__c)) {
				map_ExRate.put(idx.ASI_MFM_Base_Currency__c+idx.ASI_MFM_Counter_Currency__c, idx);
            }
		}
        
        System.Debug('End Getting Exchange Rate Map');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries()); 
        
        System.Debug('Start Retrieve PO Id of the TnE Lines');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries());
        
        List<ASI_TnE_ClaimDetail__c> detailList = (List<ASI_TnE_ClaimDetail__c>)sObjList;
        Set<Id> poIdSet = new Set<Id>();
        if(oldMap == null){
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                if(detail.ASI_TnE_HK_Payment_Amount__c != null && detail.ASI_TnE_MFM_PO__c != null){
                    poIdSet.add(detail.ASI_TnE_MFM_PO__c);
                }   
            }
        }else if(sObjList !=null){
            Map<Id, ASI_TnE_ClaimDetail__c> detailOldMap = (Map<Id, ASI_TnE_ClaimDetail__c>)oldMap;
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                if((detail.ASI_TnE_HK_Payment_Amount__c != null &&
                       detail.ASI_TnE_HK_Payment_Amount__c != detailOldMap.get(detail.Id).ASI_TnE_HK_Payment_Amount__c) ||
                       (detail.ASI_TnE_MFM_PO__c != null &&
                       detail.ASI_TnE_MFM_PO__c != detailOldMap.get(detail.Id).ASI_TnE_MFM_PO__c)){
                    poIdSet.add(detail.ASI_TnE_MFM_PO__c);    
                }
                if(detail.ASI_TnE_MFM_PO__c != detailOldMap.get(detail.Id).ASI_TnE_MFM_PO__c && detail.ASI_TnE_MFM_PO__c == null){
                    poIdSet.add(detailOldMap.get(detail.Id).ASI_TnE_MFM_PO__c); 
                }
            }
        }else{
            Map<Id, ASI_TnE_ClaimDetail__c> detailOldMap = (Map<Id, ASI_TnE_ClaimDetail__c>)oldMap;
            for(ASI_TnE_ClaimDetail__c detail:detailOldMap.values()){
                poIdSet.add(detail.ASI_TnE_MFM_PO__c);
            }
        }
        
		System.Debug('End Retrieve PO Id of the TnE Lines');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries());
        
		System.Debug('Start Retrieve All TnE Line of PO Lines');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries());
        
        List<ASI_MFM_PO__c> poList = [Select ASI_MFM_T_E_Amount__c,ASI_MFM_T_E_Amount_Posted__c,ASI_MFM_Sys_Local_Currency__c, (Select recordtypeid, ASI_TnE_HK_Payment_Amount__c,ASI_TnE_ClaimHeader__r.ASI_TnE_Status__c,ASI_TnE_ClaimHeader__r.ASI_TnE_Export_to_AP_Voucher_GL__c,ASI_TnE_ClaimHeader__r.ASI_TnE_Currency__c,ASI_TnE_Currency__c,ASI_TnE_ClaimHeader__r.ASI_TnE_HK_Submission_Date__c From Travel_Entertainment_Claims_Detail__r) From ASI_MFM_PO__c Where Id In :poIdSet];
        //String UserId = UserInfo.getUserId();
        //String sUserMFMCountry = [SELECT ASI_MFM_Country__c FROM user WHERE id = :UserId].ASI_MFM_Country__c;
        //System.debug('sUserMFMCountry := ' + sUserMFMCountry);
        Double nExchangeRate = null;
        Map<Id, ASI_TnE_ClaimDetail__c> TnEUpdateMap = new Map<Id, ASI_TnE_ClaimDetail__c>();
        
		System.Debug('End Retrieve All TnE Line of PO Lines');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries());
        
        for(ASI_MFM_PO__c po:poList){
            po.ASI_MFM_T_E_Amount__c = 0;
            date dFXRateRef = null;
           // po.ASI_MFM_T_E_Amount_Posted__c =0;
            for(ASI_TnE_ClaimDetail__c detail:po.Travel_Entertainment_Claims_Detail__r){
                if (detail.ASI_TnE_ClaimHeader__r.ASI_TnE_HK_Submission_Date__c == null) {
                    dFXRateRef = detail.ASI_TnE_ClaimHeader__r.ASI_TnE_HK_Submission_Date__c;
                }else{
                    dFXRateRef = System.today();
                }
                System.debug('TnE Base Currency := ' + detail.ASI_TnE_ClaimHeader__r.ASI_TnE_Currency__c);
                System.debug('PO Base Currency := ' + po.ASI_MFM_Sys_Local_Currency__c);
			//	if (po.ASI_MFM_Sys_Local_Currency__c <> detail.ASI_TnE_Currency__c) {
				
                //if (Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_SG_Claim_Detail')) {
                    //Map is only available for SGD-USD, and USD-SGD. Not available for SGD-SGD, USD-USD
                    try {
                        nExchangeRate = map_ExRate.get(detail.ASI_TnE_ClaimHeader__r.ASI_TnE_Currency__c+po.ASI_MFM_Sys_Local_Currency__c).ASI_MFM_Exchange_Rate__c;
                        System.Debug('PO Exchange Rate := ' + nExchangeRate);
                    }catch(Exception e) {
                        nExchangeRate = 1;
                    }
                //}
                if (nExchangeRate == null) {
                    nExchangeRate = 1;
                }
				
                
                if (Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_HK_Claim_Detail')){
					//Vincent@2017/10/12 To omit 'Draft' T&E in T&E Amount field in linked MFM PO
                    if (detail.ASI_TnE_ClaimHeader__r.ASI_TnE_Status__c != 'Draft') {
						po.ASI_MFM_T_E_Amount__c += detail.ASI_TnE_HK_Payment_Amount__c;
                    }
                }else if (nExchangeRate != null) {
                    po.ASI_MFM_T_E_Amount__c = po.ASI_MFM_T_E_Amount__c + (detail.ASI_TnE_HK_Payment_Amount__c / nExchangeRate);
                }else {
					po.ASI_MFM_T_E_Amount__c += detail.ASI_TnE_HK_Payment_Amount__c;
				}
                //detail.ASI_TnE_Exchange_Rate_to_VND__c = nExchangeRate;
                TnEUpdateMap.put(detail.Id, detail);
                System.debug('TnE Amount := ' + po.ASI_MFM_T_E_Amount__c);
					//if(detail.ASI_TnE_ClaimHeader__r.ASI_TnE_Export_to_AP_Voucher_GL__c){
				   //     po.ASI_MFM_T_E_Amount_Posted__c+=detail.ASI_TnE_HK_Payment_Amount__c;
					//}
			//	}
            }
        }
		System.Debug('Start Update TnE Amount');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries());
        
        update poList;
        //update TnEUpdateMap.values();
        
		System.Debug('End Update TnE Amount');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries());
        
        System.Debug('Execution Start := ' + CurrentClassName);
    }
}