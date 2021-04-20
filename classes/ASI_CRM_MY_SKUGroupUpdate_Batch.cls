global class ASI_CRM_MY_SKUGroupUpdate_Batch implements Database.Batchable<sObject> {
	
	String query;
	
	global ASI_CRM_MY_SKUGroupUpdate_Batch() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		String str_dt =getQueryStrDate(date.today());
		query ='SELECT Id, Name, ASI_CRM_Effective_Date__c, ASI_CRM_SKU_Group__c, ASI_CRM_Need_Check_for_SKU_Group__c FROM ASI_MFM_SKU_Code__c WHERE RecordTypeId = \''+Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_MY_SKU')+'\' AND ASI_CRM_Need_Check_for_SKU_Group__c= TRUE AND ASI_CRM_SKU_Group__c!=null AND ASI_CRM_Effective_Date__c<='+ str_dt+' ORDER BY CreatedDate ASC ';
		system.debug('string query='+query);

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<ASI_MFM_SKU_Code__c> l_SKU) {
		
		Map<Id, Map<Integer, ASI_MFM_SKU_Code__c>> m_GrpId_DateSortedSKU = new Map<Id, Map<Integer, ASI_MFM_SKU_Code__c>>();
		Set<Id> s_SKUGrpId = new Set<Id>();
		for(ASI_MFM_SKU_Code__c sku : l_SKU){
			s_SKUGrpId.add(sku.ASI_CRM_SKU_Group__c);

			Integer dateIndex = sku.ASI_CRM_Effective_Date__c.year() *10000 + sku.ASI_CRM_Effective_Date__c.month() *100 + sku.ASI_CRM_Effective_Date__c.day();
			if(m_GrpId_DateSortedSKU.get(sku.ASI_CRM_SKU_Group__c)!=null){
				m_GrpId_DateSortedSKU.get(sku.ASI_CRM_SKU_Group__c).put(dateIndex, sku);
			}else{
				m_GrpId_DateSortedSKU.put (sku.ASI_CRM_SKU_Group__c, new Map<Integer, ASI_MFM_SKU_Code__c>{dateIndex => sku});
			}

		}

		system.debug('ASI_CRM_MY_SKUGroupUpdate_Batch m_GrpId_DateSortedSKU='+m_GrpId_DateSortedSKU);

		Map<Id,ASI_CRM_SKU_Group__c> m_IdSKUGrp = new Map<Id,ASI_CRM_SKU_Group__c>([SELECT Id, ASI_CRM_Effective_SKU__c,ASI_CRM_SKU_Effective_Date__c,ASI_CRM_Related_SKU_Ids__c FROM ASI_CRM_SKU_Group__c WHERE Id in:s_SKUGrpId]);
		List<ASI_CRM_SKU_Group__c> l_SKUGrp_ToUpdate = new List<ASI_CRM_SKU_Group__c>();
		for(ASI_CRM_SKU_Group__c grp : m_IdSKUGrp.values()){
			Map<Integer, ASI_MFM_SKU_Code__c> m_DateSortedSKU =  m_GrpId_DateSortedSKU.get(grp.Id);
			if(m_DateSortedSKU!=null && m_DateSortedSKU.size()>0){
				//Retrieve the last element and last index value in the map:
				ASI_MFM_SKU_Code__c latestSKUInGrp =m_DateSortedSKU.values()[m_DateSortedSKU.size()-1];
				Integer largestDateInGrp = new List<Integer>(m_DateSortedSKU.keyset())[m_DateSortedSKU.size()-1];
				if(grp.ASI_CRM_SKU_Effective_Date__c ==null){
					grp.ASI_CRM_Effective_SKU__c = latestSKUInGrp.Id;
					grp.ASI_CRM_SKU_Effective_Date__c = latestSKUInGrp.ASI_CRM_Effective_Date__c;
					l_SKUGrp_ToUpdate.add(grp);
				}else{
					Integer currentGrpDate = grp.ASI_CRM_SKU_Effective_Date__c.year() *10000 + grp.ASI_CRM_SKU_Effective_Date__c.month() *100 + grp.ASI_CRM_SKU_Effective_Date__c.day();
					if(largestDateInGrp >= currentGrpDate){
						grp.ASI_CRM_Effective_SKU__c = latestSKUInGrp.Id;
						grp.ASI_CRM_SKU_Effective_Date__c = latestSKUInGrp.ASI_CRM_Effective_Date__c;
						l_SKUGrp_ToUpdate.add(grp);
					}
				}
			}
		}

		system.debug('ASI_CRM_MY_SKUGroupUpdate_Batch l_SKUGrp_ToUpdate='+l_SKUGrp_ToUpdate);
		if(l_SKUGrp_ToUpdate.size()>0){
			update l_SKUGrp_ToUpdate;
		}
		if(l_SKU.size()>0){
			for(ASI_MFM_SKU_Code__c sku: l_SKU){
				sku.ASI_CRM_Need_Check_for_SKU_Group__c = False;
			}
			update l_SKU;
		}

	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
	global String getQueryStrDate (Date dt){
		String str_dt;
		String str_month = (''+dt.month()).leftPad(2,'0');
		String str_day = (''+dt.day()).leftPad(2,'0');
		str_dt=''+dt.year()+'-'+str_month+'-'+str_day;
		return str_dt;
	}
}