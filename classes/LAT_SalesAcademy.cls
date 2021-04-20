public with sharing class LAT_SalesAcademy {


	public LAT_SalesAcademy() {
		
	}
	

	public static Map<String,String> getRTMap(List<sObject> newList){
		List<String> parentIds = new List<String>();
		Map<String,String> rtMap = new Map<String,String>();

		for(sObject sa : newList){
			parentIds.add((String)sa.get('SalesAcademy__c'));
		}
		for(LAT_SalesAcademy__c sa : [Select id,recordType.DeveloperName from LAT_SalesAcademy__c where id in : parentIds]){
			rtMap.put(sa.id, sa.recordType.DeveloperName);
		}
		return rtMap;
	}



	public static void setAnalysisRecordType(List<LAT_ClientAnalysis__c> newList){
		Map<String,String> rtMap = getRTMap(newList);
		for(LAT_ClientAnalysis__c sa : newList){
			sa.recordTypeId = Global_RecordTypeCache.getRtId('LAT_ClientAnalysis__c' + rtMap.get(sa.SalesAcademy__c));
		}
	}

	public static void setSWOTRecordType(List<LAT_SWOTAnalysis__c> newList){
		Map<String,String> rtMap = getRTMap(newList);
		for(LAT_SWOTAnalysis__c sa : newList){
			sa.recordTypeId = Global_RecordTypeCache.getRtId('LAT_SWOTAnalysis__c' + rtMap.get(sa.SalesAcademy__c));
		}
	}

	public static void setPlanoAcaoRecordType(List<LAT_ActionPlan__c> newList){
		Map<String,String> rtMap = getRTMap(newList);
		for(LAT_ActionPlan__c sa : newList){
			sa.recordTypeId = Global_RecordTypeCache.getRtId('LAT_ActionPlan__c' + rtMap.get(sa.SalesAcademy__c));
		}
	}


	public static void setStrategicObjectivesRecordType(List<LAT_StrategicObjectives__c> newList){
		List<String> parentIds = new List<String>();
		Map<String,String> rtMap = new Map<String,String>();

		for(LAT_StrategicObjectives__c sa : newList){
			parentIds.add(sa.objetive__c);
		}
		for(LAT_ObjectivesDefinition__c sa : [Select id,recordType.DeveloperName from LAT_ObjectivesDefinition__c where id in : parentIds]){
			rtMap.put(sa.id, sa.recordType.DeveloperName);
		}
		for(LAT_StrategicObjectives__c sa : newList){
			sa.recordTypeId = Global_RecordTypeCache.getRtId('LAT_StrategicObjectives__c' + rtMap.get(sa.objetive__c));
		}
	}

	public static void setObjectivesDefinitionRecordType(List<LAT_ObjectivesDefinition__c> newList){
		Map<String,String> rtMap = getRTMap(newList);
		for(LAT_ObjectivesDefinition__c sa : newList){
			sa.recordTypeId = Global_RecordTypeCache.getRtId('LAT_ObjectivesDefinition__c' + rtMap.get(sa.SalesAcademy__c));
		}
	}

	public static void setRecordType(List<LAT_SalesAcademy__c> newList){
		List<String> accLst = new List<String>();
		Map<String,Account> accMap = new Map<String,Account>();
		for(LAT_SalesAcademy__c sa : newList){
			accLst.add(sa.account__c);
		}
		for(Account acc : [Select id,recordTypeId, Regional__r.Name from Account where id in : accLst]){
			accMap.put(acc.id, acc);
		}

		String offTradeId = Global_RecordTypeCache.getRtId('Account'+'Off_Trade');
		String onTradeId = Global_RecordTypeCache.getRtId('Account'+'On_Trade');


		for(LAT_SalesAcademy__c sa : newList){
			system.debug(accMap.get(sa.account__c).recordTypeId + '   ' + offTradeId);
			if(accMap.get(sa.account__c).recordTypeId == offTradeId){
				if(accMap.get(sa.account__c).Regional__r.Name == 'REG MODERN TRADE VR' || accMap.get(sa.account__c).Regional__r.Name == 'REG MODERN TRADE KA'){
					sa.recordTypeId = Global_RecordTypeCache.getRtId('LAT_SalesAcademy__c'+'LAT_Modern_Trade');	
				}else{
					sa.recordTypeId = Global_RecordTypeCache.getRtId('LAT_SalesAcademy__c'+'LAT_Distribuicao');	
				}

			}else if(accMap.get(sa.account__c).recordTypeId == onTradeId){
				sa.recordTypeId = Global_RecordTypeCache.getRtId('LAT_SalesAcademy__c'+'LAT_On_Trade');	
			}
		}


	}


}