public class LAT_RegionalPOP {

	public static void notificationTask (Map<Id,LAT_RegionalPOP__c> newMap, Map<Id, LAT_RegionalPOP__c> oldMap) {
		
		Map<Id,LAT_RegionalPOP__c> tmpNewMap = new Map<Id, LAT_RegionalPOP__c>([Select id,Amount__c,AmountLeft__c, product__r.SKU__c, product__r.name,Regional_Supervisor_POP__r.Supervisor__c from LAT_RegionalPOP__c where id in: newMap.keyset()]);

		String groupId = ''; 
		Integer days = 30;

		List<Task> insertList = new List<Task>();

		String[] groups = LAT_GeneralConfigDao.getValueAsStringArray('POP_CHATTER_GROUP', ' ');
		if(groups != null && groups.size()>0)groupId = groups[0];

		String[] tdays = LAT_GeneralConfigDao.getValueAsStringArray('POP_REGIONAL_TASK_DAYS', ' ');
		if(tdays != null && tdays.size()>0)days = Integer.valueOf(tdays[0]);

		Set<String> mentions = new Set<String>();

		for (LAT_RegionalPOP__c rp: tmpNewMap.values()) {
			if (oldMap != null && oldMap.get(rp.id) != null) {
				if (rp.Amount__c != oldMap.get(rp.id).Amount__c) {
					mentions.add(rp.Regional_Supervisor_POP__r.Supervisor__c);
					Task t = LAT_ProcessesTaks.createTask(rp.id, rp.Regional_Supervisor_POP__r.Supervisor__c, Label.LAT_Processes_001,Label.LAT_Processes_002.replace('{0}',tmpNewMap.get(rp.id).product__r.SKU__c + ' ' + tmpNewMap.get(rp.id).product__r.name).replaceAll('</br>','\n'), Global_RecordTypeCache.getRtId('Task'+'LAT_POP'),days,'POP-Distribuicao Regional');
					insertList.add(t);
				} 
			} else {
				Task t = LAT_ProcessesTaks.createTask(rp.id, rp.Regional_Supervisor_POP__r.Supervisor__c, Label.LAT_Processes_001, Label.LAT_Processes_002.replace('{0}',tmpNewMap.get(rp.id).product__r.SKU__c + ' ' + tmpNewMap.get(rp.id).product__r.name).replaceAll('</br>','\n'), Global_RecordTypeCache.getRtId('Task'+'LAT_POP'),days,'POP-Distribuicao Regional');
				insertList.add(t);
				mentions.add(rp.Regional_Supervisor_POP__r.Supervisor__c);		
			}
		}

		if(mentions.size() > 0){
			String theId = LAT_RegionalPOP__c.sObjectType.getDescribe().getKeyPrefix();
			ConnectApi.BatchInput post = LAT_ProcessesNotifications.generateChatterPost(groupId,new List<String>(mentions), Label.LAT_Processes_003,theId);
			LAT_ProcessesNotifications.post(new List<ConnectApi.BatchInput>{post});
		}

		LAT_ProcessesTaks.insertAndNotificate(insertList);
	}

	public static void updateOwner(List<LAT_RegionalPOP__c> newReg){
		List<String> supervisores = new List<String>();
		MAp<String,String> supervisoresMap = new MAp<String,String>();

		for(LAT_RegionalPOP__c reg : newReg){
			if(reg.Regional_Supervisor_POP__c != null){
				supervisores.add(reg.Regional_Supervisor_POP__c);
			}
		}

		 for(LAT_RegionalSupervisor__c regSup : [Select id,Supervisor__c from LAT_RegionalSupervisor__c where id in: supervisores]){
            supervisoresMap.put(regSup.id, regSup.Supervisor__c);
        }

        for(LAT_RegionalPOP__c reg : newReg){
        	if(supervisoresMap.get(reg.Regional_Supervisor_POP__c) != null)reg.ownerId = supervisoresMap.get(reg.Regional_Supervisor_POP__c);
        }
	}


}