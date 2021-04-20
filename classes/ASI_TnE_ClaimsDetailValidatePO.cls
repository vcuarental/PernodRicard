/*********************************************************************************
 * Name:ASI_TnE_ClaimsDetailValidatePO
 * Description: Validate PO Balance
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 09/12/2015       Laputa: Hank            Created
*********************************************************************************/

public without sharing class ASI_TnE_ClaimsDetailValidatePO extends ASI_TnE_TriggerAbstract {

    public ASI_TnE_ClaimsDetailValidatePO() {
        super('ASI_TnE_ClaimsDetailValidatePO');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        String CurrentClassName = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
        System.Debug('Execution Start := ' + CurrentClassName);
        
        List<ASI_TnE_ClaimDetail__c> detailList = (List<ASI_TnE_ClaimDetail__c>)sObjList;
        Set<Id> poIdSet = new Set<Id>();
        Set<Id> planIdSet = new Set<Id>();
        Map<Id, Decimal> balanceMap = new Map<Id, Decimal>();
        Set<Id> detailIdSet = new Set<Id>();
        Map<Id, String> Map_ExRateKey = new Map<Id, String>();
        Double nExchangeRate = 1;
        String sExRateMapKey = null;
		
        System.Debug('Start Getting Exchange Rate Map');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries());
        
		//Vincent 20161221 Initialize PO Exchange Rate Map
		//Contains USD-SGD, SGD-USD, SG Market
		Map<String, ASI_MFM_Exchange_Rate__c> map_ExRate = new Map<String, ASI_MFM_Exchange_Rate__c>();
		List <ASI_MFM_Exchange_Rate__c> List_ExRate = [SELECT id, name, ASI_MFM_Base_Currency__c, ASI_MFM_Counter_Currency__c, ASI_MFM_Country__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c where ASI_MFM_Base_Currency__c in ('USD', 'SGD') and ASI_MFM_Counter_Currency__c in ('SGD', 'USD') AND ASI_MFM_Effective_Date__c <= :System.today() and ASI_MFM_Country__c = 'SG' ORDER BY ASI_MFM_Effective_Date__c DESC LIMIT 1000];
		for (ASI_MFM_Exchange_Rate__c idx : List_ExRate) {
            if (!map_ExRate.containsKey(idx.ASI_MFM_Base_Currency__c+idx.ASI_MFM_Counter_Currency__c)) {
				map_ExRate.put(idx.ASI_MFM_Base_Currency__c+idx.ASI_MFM_Counter_Currency__c, idx);
            }
		}
		
        System.Debug('End Getting Exchange Rate Map');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries());
        
        System.Debug('Start Retrieve PO Id of the TnE Lines');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries());
        
        //Get Po Id
        if(oldMap == null){
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                
                if(detail.ASI_TnE_HK_Payment_Amount__c != null && detail.ASI_TnE_MFM_PO__c != null){
                    poIdSet.add(detail.ASI_TnE_MFM_PO__c); 
                    detailIdSet.add(detail.Id);
                }   
                if (Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_HK_Claim_Detail') && detail.ASI_TnE_CAP_Plan__c != null){
                    planIdSet.add(detail.ASI_TnE_CAP_Plan__c);
                }
            }
        }else{
            Map<Id, ASI_TnE_ClaimDetail__c> detailOldMap = (Map<Id, ASI_TnE_ClaimDetail__c>)oldMap;
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                if((detail.ASI_TnE_HK_Payment_Amount__c != null &&
                       detail.ASI_TnE_HK_Payment_Amount__c != detailOldMap.get(detail.Id).ASI_TnE_HK_Payment_Amount__c) ||
                       (detail.ASI_TnE_MFM_PO__c != null &&
                       detail.ASI_TnE_MFM_PO__c != detailOldMap.get(detail.Id).ASI_TnE_MFM_PO__c)){
                    poIdSet.add(detail.ASI_TnE_MFM_PO__c);
                    detailIdSet.add(detail.Id);
                }
                
                if (Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_HK_Claim_Detail') && detail.ASI_TnE_CAP_Plan__c != null && 
                    detail.ASI_TnE_CAP_Plan__c != detailOldMap.get(detail.id).ASI_TnE_CAP_Plan__c){
                    planIdSet.add(detail.ASI_TnE_CAP_Plan__c);
                }
            }
        }
        
		System.Debug('End Retrieve PO Id of the TnE Lines');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries());
        
		System.Debug('Start Retrieve All TnE Line of PO Lines');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries());
        
        //Get info from Po
        Map<Id, ASI_MFM_PO__c> poMap = new Map<Id, ASI_MFM_PO__c>([Select Id, Name, ASI_MFM_PO_Balance__c, ASI_MFM_Sys_Local_Currency__c, (Select Id, ASI_TnE_HK_Payment_Amount__c, ASI_TnE_ClaimHeader__r.ASI_TnE_Currency__c From Travel_Entertainment_Claims_Detail__r Where Id In:detailIdSet) From ASI_MFM_PO__c Where Id In :poIdSet]);
        Map<Id, Decimal> newNoMap = new Map<Id, Decimal>();

		System.Debug('End Retrieve All TnE Line of PO Lines');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries());
        
        //Set up Balance Map
        for(ASI_MFM_PO__c po:poMap.values()){
            balanceMap.put(po.Id, 0);
            for(ASI_TnE_ClaimDetail__c d:po.Travel_Entertainment_Claims_Detail__r){
                if(d.ASI_TnE_HK_Payment_Amount__c != null){
					Map_ExRateKey.put(d.Id, d.ASI_TnE_ClaimHeader__r.ASI_TnE_Currency__c + po.ASI_MFM_Sys_Local_Currency__c);
                    Decimal newNo = balanceMap.get(po.Id) + d.ASI_TnE_HK_Payment_Amount__c;
                    balanceMap.put(po.Id, newNo);
                    system.debug('Check1: ' + d.Id + ' number: ' + newNo);
                }
            }
        }
        
		System.Debug('Start Check PO Balance');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries());        
        
        //Check if exceed balance
        if(oldMap == null){
            Decimal newNo = 0;

            for(ASI_TnE_ClaimDetail__c detail:detailList){
                try {
                    //if (Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_SG_Claim_Detail')) {
                    	sExRateMapKey = Map_ExRateKey.get(detail.Id);
                        nExchangeRate = map_ExRate.get(sExRateMapKey).ASI_MFM_Exchange_Rate__c;
                    	System.Debug('PO Exchange Rate := ' + nExchangeRate);
                    //}
                }catch(Exception e){
                    nExchangeRate = 1;
                }

				if (nExchangeRate == null) {
					nExchangeRate = 1;
				}
				
                if(detail.ASI_TnE_HK_Payment_Amount__c != null && detail.ASI_TnE_MFM_PO__c != null){
                    if(newNoMap.get(detail.ASI_TnE_MFM_PO__c) == null){
                        newNoMap.put(detail.ASI_TnE_MFM_PO__c, (detail.ASI_TnE_HK_Payment_Amount__c));
                    }else{
                        newNo = newNoMap.get(detail.ASI_TnE_MFM_PO__c);
                        newNoMap.put(detail.ASI_TnE_MFM_PO__c, (detail.ASI_TnE_HK_Payment_Amount__c / nExchangeRate) + newNo);
						detail.ASI_TnE_Exchange_Rate_to_VND__c = nExchangeRate;
                    	system.debug('detail.ASI_TnE_Exchange_Rate_to_VND__c := ' + detail.ASI_TnE_Exchange_Rate_to_VND__c);
                    }

                    system.debug('Check3 := ' + newNoMap.get(detail.ASI_TnE_MFM_PO__c));
                    system.debug('Check3 := + poMap.get(detail.ASI_TnE_MFM_PO__c).ASI_MFM_PO_Balance__c');
                    system.debug('Check3 := ' + newNoMap.get(detail.ASI_TnE_MFM_PO__c));
                    system.debug('Check2: ' + detail.Id + ' number: ' + newNo + ' Balance: ' + poMap.get(detail.ASI_TnE_MFM_PO__c).ASI_MFM_PO_Balance__c);
                    //if(newNoMap.get(detail.ASI_TnE_MFM_PO__c) > (poMap.get(detail.ASI_TnE_MFM_PO__c).ASI_MFM_PO_Balance__c==null?0:poMap.get(detail.ASI_TnE_MFM_PO__c).ASI_MFM_PO_Balance__c) + balanceMap.get(detail.ASI_TnE_MFM_PO__c)){
					if(newNoMap.get(detail.ASI_TnE_MFM_PO__c) > (poMap.get(detail.ASI_TnE_MFM_PO__c).ASI_MFM_PO_Balance__c==null?0:poMap.get(detail.ASI_TnE_MFM_PO__c).ASI_MFM_PO_Balance__c) + newNoMap.get(detail.ASI_TnE_MFM_PO__c)){
                        detail.addError('[Line No.' + detail.Name + ']: ' + ' Exceeding the PO#[PO No.' + poMap.get(detail.ASI_TnE_MFM_PO__c).Name + '] Amount');
                    }
                }   
            }
        }else{
            Map<Id, ASI_TnE_ClaimDetail__c> detailOldMap = (Map<Id, ASI_TnE_ClaimDetail__c>)oldMap;
            Decimal newNo = 0;
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                try {
                    //if (Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_SG_Claim_Detail')) {
                    	sExRateMapKey = Map_ExRateKey.get(detail.Id);
                        nExchangeRate = map_ExRate.get(sExRateMapKey).ASI_MFM_Exchange_Rate__c;
                    	System.Debug('PO Exchange Rate := ' + nExchangeRate);
                    //}
                }catch(Exception e){
                    nExchangeRate = 1;
                }

				if (nExchangeRate == null) {
					nExchangeRate = 1;
				}
                System.Debug('PO Exchange Rate := ' + nExchangeRate);
                detail.ASI_TnE_Exchange_Rate_to_VND__c = nExchangeRate;
                system.debug('detail.id := ' + detail.id);
                system.debug('detail.ASI_TnE_Exchange_Rate_to_VND__c := ' + detail.ASI_TnE_Exchange_Rate_to_VND__c);
                if(detail.ASI_TnE_HK_Payment_Amount__c != null && detail.ASI_TnE_MFM_PO__c != null && (
                       detail.ASI_TnE_HK_Payment_Amount__c != detailOldMap.get(detail.Id).ASI_TnE_HK_Payment_Amount__c ||
                       detail.ASI_TnE_MFM_PO__c != detailOldMap.get(detail.Id).ASI_TnE_MFM_PO__c)){
                    if(newNoMap.get(detail.ASI_TnE_MFM_PO__c) == null){
                        newNoMap.put(detail.ASI_TnE_MFM_PO__c, detail.ASI_TnE_HK_Payment_Amount__c);
                    }else{
                        newNo = newNoMap.get(detail.ASI_TnE_MFM_PO__c);
                        newNoMap.put(detail.ASI_TnE_MFM_PO__c, (detail.ASI_TnE_HK_Payment_Amount__c / nExchangeRate) + newNo);
                    }
                    system.debug('Check2: ' + detail.Id + ' number: ' + newNo + ' Balance: ' + poMap.get(detail.ASI_TnE_MFM_PO__c).ASI_MFM_PO_Balance__c);
                    if(newNoMap.get(detail.ASI_TnE_MFM_PO__c) > (poMap.get(detail.ASI_TnE_MFM_PO__c).ASI_MFM_PO_Balance__c==null?0:poMap.get(detail.ASI_TnE_MFM_PO__c).ASI_MFM_PO_Balance__c) + balanceMap.get(detail.ASI_TnE_MFM_PO__c)){
                        detail.addError('[Line No.' + detail.Name + ']: ' + ' Exceeding the PO#[PO No.' + poMap.get(detail.ASI_TnE_MFM_PO__c).Name + '] Amount');
                    }               
                }
            }
        }

		System.Debug('End Check PO Balance');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries());
        
        //Wilken 20161007 Check CAPEX Plan is live, to prevent further T&E payment from Plan
        Map<Id,ASI_MFM_Plan__c> planMap = new Map<Id,ASI_MFM_Plan__c>([select Id, ASI_MFM_Actual_Depreciation_Start_Date__c from ASI_MFM_Plan__c where Id in :planIdSet]);
        for(ASI_TnE_ClaimDetail__c detail:detailList){
            if (Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_HK_Claim_Detail')){
                if (detail.ASI_TnE_CAP_Plan__c == null)
                    detail.ASI_TnE_Is_CAPEX_Plan_Live__c = false;
                else {
                    if (planMap.get(detail.ASI_TnE_CAP_Plan__c) != null && planMap.get(detail.ASI_TnE_CAP_Plan__c).ASI_MFM_Actual_Depreciation_Start_Date__c != null)
                        detail.ASI_TnE_Is_CAPEX_Plan_Live__c = true;
                    else 
                        detail.ASI_TnE_Is_CAPEX_Plan_Live__c = false;
                }
            }
        }
        
		System.Debug('End Check CAPEX Plan');
        System.debug('Current Number of SOQL Queries in this apex code context: ' +  Limits.getQueries());
        System.Debug('Execution End := ' + CurrentClassName);
    }
}