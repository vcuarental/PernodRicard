/*Assign PRS Value from Prs Segmentation to Account Record
*User will answer PRS Question from mobile and update EUR_CRM_PRS_Segmentation__c
*This handle will populate the result from EUR_CRM_PRS_Segmentation__c to EUR_CRM_Account__c.
*/

public with sharing class EUR_CRM_PRSSegmentationToAccHandler {

	private static final String ACCOUNT_CAN_HAVE_ONLY_ONE_PRS_SEGMENTATION = 'Account can have only one PRS Segmentation';

	private static Integer afterUpdateCount = 0;

//	private static final Map<String, List<String>> ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA = new Map<String, List<String>>{
//		'EUR_PRS_Segmentation_Off_Trade' => new List<String>{ 'EUR_BE_Off_Trade' }
//	};
	private static final Map<String, Set<String>> ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA =
		EUR_CRM_RecordTypeHelper_v2.getSettingsMultivalueMap('EUR_CRM_PRSSegmentationToAccHandler', 'ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA');

	//Interfaces

	//on before insert
	public void onBeforeInsert(List<EUR_CRM_PRS_Segmentation__c> segmentations) {
		this.checkPrsSegmentationCount(segmentations);
		this.updatePriorityLevelCriteria(segmentations);
	}

	public void checkPrsSegmentationCount(List<EUR_CRM_PRS_Segmentation__c> segmentations) {

		Map<Id, EUR_CRM_Account__c> accountById = new Map<Id, EUR_CRM_Account__c>(this.selectAccounts(this.extractAccountIds(segmentations)));
		if (accountById.isEmpty()) { return; }

		Map<Id, List<EUR_CRM_PRS_Segmentation__c>> segmentationsByAccId = this.getSegmentationsByAccId(segmentations);
		this.checkPrsSegmentationCount(accountById, segmentationsByAccId);
	}

	public void updateAccountPros(List<EUR_CRM_PRS_Segmentation__c> segmentations) {
		Map<Id, EUR_CRM_Account__c> accountById = new Map<Id, EUR_CRM_Account__c>(this.selectAccounts(this.extractAccountIds(segmentations)));
		if (accountById.isEmpty()) { return; }

		List<EUR_CRM_Account__c> accountsToUpdate = this.updateAccountsPros(segmentations, accountById);
		if (accountsToUpdate.isEmpty()) { return; }

		Database.update(accountsToUpdate, false);
	}

	//on before update
	public void updateAccountPros(List<EUR_CRM_PRS_Segmentation__c> segmentations, Map<Id, EUR_CRM_PRS_Segmentation__c> oldSegmentationById) {
		System.debug('\n EUR_CRM_PRSSegmentationToAccHandler.afterUpdateCount => ' + EUR_CRM_PRSSegmentationToAccHandler.afterUpdateCount + '\n');
		if (afterUpdateCount > 0) { return; }
		Map<Id, EUR_CRM_Account__c> accountById = new Map<Id, EUR_CRM_Account__c>(this.selectAccounts(this.extractAccountIds(segmentations)));
		if (accountById.isEmpty()) { return; }

		List<EUR_CRM_Account__c> accountsToUpdate = this.updateAccountsPros(segmentations, oldSegmentationById, accountById);
		if (accountsToUpdate.isEmpty()) { return; }

		afterUpdateCount++;
		Database.update(accountsToUpdate, false);
	}

	//On before insert
	public void updatePriorityLevelCriteria(List<EUR_CRM_PRS_Segmentation__c> segmentations) {
		System.debug('\n segmentations.size() => ' + segmentations.size() + '\n');
		System.debug('\n segmentations => ' + JSON.serializePretty(segmentations) + '\n');
		List<EUR_CRM_PRS_Segmentation__c> segmsToCheckAccRt = this.getSegmsToCheckAccRt(segmentations);
		if (segmsToCheckAccRt.isEmpty()) { return; }

		Map<Id, EUR_CRM_Account__c> accountById = new Map<Id, EUR_CRM_Account__c>(this.selectAccounts(this.extractAccountIds(segmsToCheckAccRt)));

		List<EUR_CRM_PRS_Segmentation__c> segmsToUpdatePriorityLevelCriteria = this.getSegmsToUpdatePriorityLevelCriteria(segmsToCheckAccRt, accountById);
		System.debug('\n segmsToUpdatePriorityLevelCriteria.size() => ' + segmsToUpdatePriorityLevelCriteria.size() + '\n');
		System.debug('\n segmsToUpdatePriorityLevelCriteria => ' + JSON.serializePretty(segmsToUpdatePriorityLevelCriteria) + '\n');
		this.assignPriorityLevelCriteria(segmsToUpdatePriorityLevelCriteria);
	}

	//on before update
	public void updatePriorityLevelCriteria(List<EUR_CRM_PRS_Segmentation__c> segmentations, Map<Id, EUR_CRM_PRS_Segmentation__c> oldSegmentationById) {
		List<EUR_CRM_PRS_Segmentation__c> changedSegmentations = this.getChangedSegmentations(segmentations, oldSegmentationById);
		if (changedSegmentations.isEmpty()) { return; }
		List<EUR_CRM_PRS_Segmentation__c> segmsToCheckAccRt = this.getSegmsToCheckAccRt(changedSegmentations);
		if (segmsToCheckAccRt.isEmpty()) { return; }

		Map<Id, EUR_CRM_Account__c> accountById = new Map<Id, EUR_CRM_Account__c>(this.selectAccounts(this.extractAccountIds(segmsToCheckAccRt)));

		List<EUR_CRM_PRS_Segmentation__c> segmsToUpdatePriorityLevelCriteria = this.getSegmsToUpdatePriorityLevelCriteria(segmsToCheckAccRt, accountById);
		this.assignPriorityLevelCriteria(segmsToUpdatePriorityLevelCriteria);
	}




	//High level helpers
	private List<EUR_CRM_PRS_Segmentation__c> getSegmsToCheckAccRt(List<EUR_CRM_PRS_Segmentation__c> segmentations) {
		Map<Id, RecordTypeInfo> segmsRtInfoById = SObjectType.EUR_CRM_PRS_Segmentation__c.getRecordTypeInfosById();

		List<EUR_CRM_PRS_Segmentation__c> segmsToCheckAccRt = new List<EUR_CRM_PRS_Segmentation__c>();
		for (EUR_CRM_PRS_Segmentation__c segm : segmentations) {
			RecordTypeInfo segmRtInfo = segmsRtInfoById.get(segm.RecordTypeId);
			if (segmRtInfo == null) { continue; }
			String segmRtDevName = segmRtInfo.getDeveloperName();
			if ( ! ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA.containsKey(segmRtDevName)) { continue; }
			segmsToCheckAccRt.add(segm);
		}
		return segmsToCheckAccRt;
	}

	private List<EUR_CRM_PRS_Segmentation__c> getSegmsToUpdatePriorityLevelCriteria(List<EUR_CRM_PRS_Segmentation__c> segms) {
		List<EUR_CRM_PRS_Segmentation__c> segmsToUpdatePriorityLevelCriteria = new List<EUR_CRM_PRS_Segmentation__c>();
		for (EUR_CRM_PRS_Segmentation__c segm : segms) {
			Set<String> accRtsToUpdatePLC = ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA.get(segm.RecordType.DeveloperName);
			if (accRtsToUpdatePLC == null || ( ! accRtsToUpdatePLC.contains(segm.EUR_CRM_Account__r.RecordType.DeveloperName))) { continue; }
			segmsToUpdatePriorityLevelCriteria.add(segm);
		}
		return segmsToUpdatePriorityLevelCriteria;
	}

	private List<EUR_CRM_PRS_Segmentation__c> getSegmsToUpdatePriorityLevelCriteria(List<EUR_CRM_PRS_Segmentation__c> segms, Map<Id, EUR_CRM_Account__c> accountById) {
		Map<Id, RecordTypeInfo> segmsRtInfoById = SObjectType.EUR_CRM_PRS_Segmentation__c.getRecordTypeInfosById();

		List<EUR_CRM_PRS_Segmentation__c> segmsToUpdatePriorityLevelCriteria = new List<EUR_CRM_PRS_Segmentation__c>();

		for (EUR_CRM_PRS_Segmentation__c segm : segms) {
			Set<String> accRtsToUpdatePLC = ACC_RTS_BY_SEGMENTATION_RT_TO_UPDATE_PRIORITY_LEVEL_CRITERIA.get(segmsRtInfoById.get(segm.RecordTypeId).getDeveloperName());
			String accRtDevName = '';
			if (accountById.containsKey(segm.EUR_CRM_Account__c)) {
				accRtDevName = accountById.get(segm.EUR_CRM_Account__c).RecordType.DeveloperName;
			}
			if (accRtsToUpdatePLC == null || ( ! accRtsToUpdatePLC.contains(accRtDevName))) { continue; }
			segmsToUpdatePriorityLevelCriteria.add(segm);
		}
		return segmsToUpdatePriorityLevelCriteria;
	}

	private void assignPriorityLevelCriteria(List<EUR_CRM_PRS_Segmentation__c> segms) {
		Map<String, EUR_CRM_PRS_Priority_Level_Criteria__c> plcByCustKey = this.getPriorityLevelCriteriaByCustKey(this.getSegmsCountryCodes(segms));

		for (EUR_CRM_PRS_Segmentation__c segm : segms) {
			String key = createKey(segm.EUR_CRM_Brand_Building_Potential__c, segm.EUR_CRM_Business_Potential__c);
			if ( ! plcByCustKey.containsKey(key)) { continue; }
			segm.EUR_CRM_PRS_Priority_Level_Criteria__c = plcByCustKey.get(key).Id;
		}
	}

	private List<EUR_CRM_PRS_Segmentation__c> getChangedSegmentations(List<EUR_CRM_PRS_Segmentation__c> segmentations, Map<Id, EUR_CRM_PRS_Segmentation__c> oldSegmentationById) {
		List<EUR_CRM_PRS_Segmentation__c> changedSegmentations = new List<EUR_CRM_PRS_Segmentation__c>();
		for (EUR_CRM_PRS_Segmentation__c segm : segmentations) {
			EUR_CRM_PRS_Segmentation__c oldSegm = oldSegmentationById.get(segm.Id);
			if (!this.isBBPorBPchanged(segm, oldSegm)) { continue; }
			changedSegmentations.add(segm);
		}
		return changedSegmentations;
	}

	private Map<String, EUR_CRM_PRS_Priority_Level_Criteria__c> getPriorityLevelCriteriaByCustKey(Set<String> countryCodes) {
		Map<String, EUR_CRM_PRS_Priority_Level_Criteria__c> plcByCustKey = new Map<String, EUR_CRM_PRS_Priority_Level_Criteria__c>(); // Key is BBP+BP Ids
		List<EUR_CRM_PRS_Priority_Level_Criteria__c> plcs = selectPriorityLevelCriteriaWhereCountryCodes(countryCodes);
		if (plcs.isEmpty()) { return plcByCustKey; }
		String key;
		for (EUR_CRM_PRS_Priority_Level_Criteria__c plc : plcs) {
			key = createKey(plc.EUR_CRM_Brand_Building_Potential__c, plc.EUR_CRM_Business_Potential__c);
			plcByCustKey.put(key, plc);
		}
		return plcByCustKey;
	}

	private void checkPrsSegmentationCount(Map<Id, EUR_CRM_Account__c> accountById, Map<Id, List<EUR_CRM_PRS_Segmentation__c>> segmentationsByAccId) {
		for (Id accId : segmentationsByAccId.keySet()) {
			List<EUR_CRM_PRS_Segmentation__c> segmentations = segmentationsByAccId.get(accId);
			if (segmentations.isEmpty()) { continue; }
			for (Integer i = 0; i <  segmentations.size(); i++) {
				EUR_CRM_Account__c account = accountById.get(accId);
				if (account.EUR_CRM_PRS_Segmentation__r.size() == 1) {
					segmentations.get(i).addError(ACCOUNT_CAN_HAVE_ONLY_ONE_PRS_SEGMENTATION);
				} else {
					if (i == 0) { continue; }
					else {
						segmentations.get(i).addError(ACCOUNT_CAN_HAVE_ONLY_ONE_PRS_SEGMENTATION);
					}
				}
			}
		}
	}


	//Middle level helpers
	private Map<Id, List<EUR_CRM_PRS_Segmentation__c>> getSegmentationsByAccId(List<EUR_CRM_PRS_Segmentation__c> segmentations) {
		Map<Id, List<EUR_CRM_PRS_Segmentation__c>> segmentationsByAccId = new Map<Id, List<EUR_CRM_PRS_Segmentation__c>>();
		for (EUR_CRM_PRS_Segmentation__c segmentation : segmentations) {
			if (segmentationsByAccId.containsKey(segmentation.EUR_CRM_Account__c)) {
				segmentationsByAccId.get(segmentation.EUR_CRM_Account__c).add(segmentation);
			} else {
				segmentationsByAccId.put(segmentation.EUR_CRM_Account__c, new List<EUR_CRM_PRS_Segmentation__c>{ segmentation });
			}
		}
		return segmentationsByAccId;
	}

	private List<EUR_CRM_Account__c> updateAccountsPros(List<EUR_CRM_PRS_Segmentation__c> segmentations, Map<Id, EUR_CRM_Account__c> accountById) {
		List<EUR_CRM_Account__c> accountsToUpdate = new List<EUR_CRM_Account__c>();
		for(EUR_CRM_PRS_Segmentation__c segmentation : segmentations) {
			EUR_CRM_Account__c account = accountById.get(segmentation.EUR_CRM_Account__c);
			this.updateAccountPros(account, segmentation);
			accountsToUpdate.add(account);
		}
		return accountsToUpdate;
	}

	private List<EUR_CRM_Account__c> updateAccountsPros(List<EUR_CRM_PRS_Segmentation__c> segmentations, Map<Id, EUR_CRM_PRS_Segmentation__c> oldSegmentationById, Map<Id, EUR_CRM_Account__c> accountById) {
		List<EUR_CRM_Account__c> accountsToUpdate = new List<EUR_CRM_Account__c>();
		for(EUR_CRM_PRS_Segmentation__c segmentation : segmentations) {
			if ( ! this.isPrsChanged(segmentation, oldSegmentationById.get(segmentation.Id))) { continue; }

			EUR_CRM_Account__c account = accountById.get(segmentation.EUR_CRM_Account__c);
			this.updateAccountPros(account, segmentation);
			accountsToUpdate.add(account);
		}
		return accountsToUpdate;
	}

	private void updateAccountPros(EUR_CRM_Account__c account, EUR_CRM_PRS_Segmentation__c segmentation) {
		account.EUR_CRM_Brand_Building_Potential__c = segmentation.EUR_CRM_Brand_Building_Potential__c;
		account.EUR_CRM_PRS_Priority_Level_Criteria__c = segmentation.EUR_CRM_PRS_Priority_Level_Criteria__c;
		account.EUR_CRM_PRS_Group_Outlet_Type__c = segmentation.EUR_CRM_PRS_Group_Outlet_Type__c;
		account.EUR_CRM_PRS_Outlet_Type__c = segmentation.EUR_CRM_PRS_Outlet_Type__c;
		account.EUR_CRM_PRS_Volume_Potential__c = segmentation.EUR_CRM_Volume_Potential__c;
		account.EUR_CRM_PRS_Image_Level__c = segmentation.EUR_CRM_Image_Level__c;
		account.EUR_CRM_Business_Potential__c = segmentation.EUR_CRM_Business_Potential__c;
	}


	//Low level helpers
	private Boolean isPrsChanged(EUR_CRM_PRS_Segmentation__c segmentation, EUR_CRM_PRS_Segmentation__c oldSegmentation) {
		return segmentation.EUR_CRM_PRS_Group_Outlet_Type__c != oldSegmentation.EUR_CRM_PRS_Group_Outlet_Type__c
			|| segmentation.EUR_CRM_PRS_Outlet_Type__c != oldSegmentation.EUR_CRM_PRS_Outlet_Type__c
			|| segmentation.EUR_CRM_Volume_Potential__c != oldSegmentation.EUR_CRM_Volume_Potential__c
			|| segmentation.EUR_CRM_Image_Level__c != oldSegmentation.EUR_CRM_Image_Level__c
			|| segmentation.EUR_CRM_Business_Potential__c != oldSegmentation.EUR_CRM_Business_Potential__c
			|| segmentation.EUR_CRM_Brand_Building_Potential__c != oldSegmentation.EUR_CRM_Brand_Building_Potential__c
			|| segmentation.EUR_CRM_PRS_Priority_Level_Criteria__c != oldSegmentation.EUR_CRM_PRS_Priority_Level_Criteria__c
		;
	}

	private Boolean isBBPorBPchanged(EUR_CRM_PRS_Segmentation__c segm, EUR_CRM_PRS_Segmentation__c oldSegm) {
		return segm.EUR_CRM_Brand_Building_Potential__c != oldSegm.EUR_CRM_Brand_Building_Potential__c
			|| segm.EUR_CRM_Business_Potential__c != oldSegm.EUR_CRM_Business_Potential__c;
	}

	private Set<Id> extractAccountIds(List<EUR_CRM_PRS_Segmentation__c> segmentations) {
		Set<Id> accountIds = new Set<Id>();
		for (EUR_CRM_PRS_Segmentation__c segmentation : segmentations) {
			accountIds.add(segmentation.EUR_CRM_Account__c);
		}
		return accountIds;
	}

	private Set<String> getSegmsCountryCodes(List<EUR_CRM_PRS_Segmentation__c> segms) {
		Set<String> countryCodes = new Set<String>();
		for (EUR_CRM_PRS_Segmentation__c segm : segms) {
			countryCodes.add(segm.EUR_CRM_Country_Code__c);
		}
		return countryCodes;
	}

	private String createKey(String valueA, String valueB) {
		return valueA + valueB;
	}


	//Selectors
	private List<EUR_CRM_Account__c> selectAccounts(Set<Id> accountIds) {
		return [
			SELECT Id
			,	EUR_CRM_PRS_Group_Outlet_Type__c
			,	EUR_CRM_PRS_Outlet_Type__c
			,	EUR_CRM_Business_Potential__c
			,	EUR_CRM_PRS_Priority_Level_Criteria__c
			,	EUR_CRM_Brand_Building_Potential__c
			,	EUR_CRM_PRS_Volume_Potential__c
			,	EUR_CRM_PRS_Image_Level__c
			,	RecordType.DeveloperName
			,	(
				SELECT Id
				FROM EUR_CRM_PRS_Segmentation__r
			)
		FROM EUR_CRM_Account__c
		WHERE Id IN :accountIds];
	}

	private List<EUR_CRM_PRS_Segmentation__c> selectSegmentations(List<EUR_CRM_PRS_Segmentation__c> segms) {
		return [
			SELECT Id
			,   EUR_CRM_Brand_Building_Potential__c
			,   EUR_CRM_Business_Potential__c
			,   EUR_CRM_Account__r.RecordType.DeveloperName
			,   RecordType.DeveloperName
			FROM EUR_CRM_PRS_Segmentation__c
			WHERE Id IN :segms
		];
	}

	private List<EUR_CRM_PRS_Priority_Level_Criteria__c> selectPriorityLevelCriteriaWhereCountryCodes(Set<String> countryCodes) {
		return [
			SELECT Id
			,	EUR_CRM_Brand_Building_Potential__c
			,   EUR_CRM_Business_Potential__c
			,   EUR_CRM_Brand_Building_Potential_Name__c
			,   EUR_CRM_Business_Potential_Name__c
			,   EUR_CRM_Country_Code__c
			,   EUR_CRM_Priority_Level__c
			FROM EUR_CRM_PRS_Priority_Level_Criteria__c
			WHERE EUR_CRM_Country_Code__c = :countryCodes
		];
	}
}