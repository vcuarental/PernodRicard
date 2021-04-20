public with sharing class EUR_CRM_PrsAnswerAccUpdateServ {

	private static final String CLASS_NAME = 'EUR_CRM_PrsAnswerAccUpdateServ';
	private static final Set<String> ANSWER_COUNTRY_CODES_TO_UPDATE_ACC = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(CLASS_NAME, 'ANSWER_COUNTRY_CODES_TO_UPDATE_ACC');
	private static final Set<String> ANSWER_RT_TO_UPDATE_ACC = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(CLASS_NAME, 'ANSWER_RT_TO_UPDATE_ACC');


	/* ========================================================= */
	/*      Interfaces
	/* ========================================================= */
	public void onAfterInsert(List<EUR_CRM_PRS_Answer__c> answers) {
		Map<Id, RecordTypeInfo> rtInfoById = Schema.SObjectType.EUR_CRM_PRS_Answer__c.getRecordTypeInfosById();

		List<EUR_CRM_PRS_Answer__c> answersToUpdateAccs = this.getAnswersToUpdateAccs(answers, rtInfoById);
		System.debug('\n answersToUpdateAccs.size() => ' + answersToUpdateAccs.size() + '\n');
		System.debug('\n answersToUpdateAccs => ' + JSON.serializePretty(answersToUpdateAccs) + '\n');
		if (answersToUpdateAccs.isEmpty()) { return; }

		List<EUR_CRM_Account__c> accountsToUpdate = this.updateAccounts(answersToUpdateAccs);
		System.debug('\n accountsToUpdate.size() => ' + accountsToUpdate.size() + '\n');
		System.debug('\n accountsToUpdate => ' + JSON.serializePretty(accountsToUpdate) + '\n');
		if (accountsToUpdate.isEmpty()) { return; }
		update accountsToUpdate;
	}

	public void onAfterUpdate(List<EUR_CRM_PRS_Answer__c> answers, Map<Id, EUR_CRM_PRS_Answer__c> oldAnswerById) {
		Map<Id, RecordTypeInfo> rtInfoById = Schema.SObjectType.EUR_CRM_PRS_Answer__c.getRecordTypeInfosById();

		List<EUR_CRM_PRS_Answer__c> answersToUpdateAccs = this.getAnswersToUpdateAccs(answers, oldAnswerById, rtInfoById);
		System.debug('\n answersToUpdateAccs.size() => ' + answersToUpdateAccs.size() + '\n');
		System.debug('\n answersToUpdateAccs => ' + JSON.serializePretty(answersToUpdateAccs) + '\n');
		if (answersToUpdateAccs.isEmpty()) { return; }

		List<EUR_CRM_Account__c> accountsToUpdate = this.updateAccounts(answersToUpdateAccs);
		System.debug('\n accountsToUpdate.size() => ' + accountsToUpdate.size() + '\n');
		System.debug('\n accountsToUpdate => ' + JSON.serializePretty(accountsToUpdate) + '\n');
		if (accountsToUpdate.isEmpty()) { return; }
		update accountsToUpdate;
	}


	/* ========================================================= */
	/*      High Level Helpers
	/* ========================================================= */
	private List<EUR_CRM_PRS_Answer__c> getAnswersToUpdateAccs(List<EUR_CRM_PRS_Answer__c> answers, Map<Id, RecordTypeInfo> rtInfoById) {
		List<EUR_CRM_PRS_Answer__c> answersToUpdateAccs = new List<EUR_CRM_PRS_Answer__c>();
		for (EUR_CRM_PRS_Answer__c answer : answers) {
			if ( ! this.isAnswerValidToUpdateAcc(answer, rtInfoById)) { continue; }
			answersToUpdateAccs.add(answer);
		}
		return answersToUpdateAccs;
	}

	private List<EUR_CRM_PRS_Answer__c> getAnswersToUpdateAccs(List<EUR_CRM_PRS_Answer__c> answers, Map<Id, EUR_CRM_PRS_Answer__c> oldAnswerById, Map<Id, RecordTypeInfo> rtInfoById) {
		List<EUR_CRM_PRS_Answer__c> answersToUpdateAccs = new List<EUR_CRM_PRS_Answer__c>();
		for (EUR_CRM_PRS_Answer__c answer : answers) {
			if ( ! this.isAnswerValidToUpdateAcc(answer, oldAnswerById.get(answer.Id), rtInfoById)) { continue; }
			answersToUpdateAccs.add(answer);
		}
		return answersToUpdateAccs;
	}



	private List<EUR_CRM_Account__c> updateAccounts(List<EUR_CRM_PRS_Answer__c> answersToUpdateAccs) {
		Map<Id, Map<String, Decimal>> answValueByAccFieldByAccId = this.getAnswValueByAccFieldByAccId(answersToUpdateAccs);

		List<EUR_CRM_Account__c> accountsToUpdate = this.selectAccountsWhereIds(answValueByAccFieldByAccId.keySet());
		for (EUR_CRM_Account__c account : accountsToUpdate) {
			Map<String, Decimal> answByAccField = answValueByAccFieldByAccId.get(account.Id);
			for (String accField : answByAccField.keySet()) {
				try {
					account.put(accField, answByAccField.get(accField));
				}
				catch(System.SObjectException e) {
					System.debug('Exception during field populating => ' + e.getMessage() + ' , ' + e.getCause());
					continue; }
			}
		}
		return accountsToUpdate;
	}

	private Map<Id, Map<String, Decimal>> getAnswValueByAccFieldByAccId(List<EUR_CRM_PRS_Answer__c> answersToUpdateAccs) {
		List<EUR_CRM_PRS_Answer__c> answersWithRelatives = this.selectAnswersWhereIds(answersToUpdateAccs);

		Map<Id, Map<String, Decimal>> answByAccFieldByAccId = new Map<Id, Map<String, Decimal>>();
		for (EUR_CRM_PRS_Answer__c answer : answersWithRelatives) {
			String accField = this.getAccFieldToPopulate(answer);
			if ( ! this.isNumeric(answer.EUR_CRM_Answer__c) || String.isEmpty(accField)) { continue; }
			if (answByAccFieldByAccId.containsKey(answer.EUR_CRM_PRS_Segmentation__r.EUR_CRM_Account__c)) {
				answByAccFieldByAccId
					.get(answer.EUR_CRM_PRS_Segmentation__r.EUR_CRM_Account__c)
					.put(accField, Decimal.valueOf(answer.EUR_CRM_Answer__c));
			} else {
				answByAccFieldByAccId.put(
					answer.EUR_CRM_PRS_Segmentation__r.EUR_CRM_Account__c
					,	new Map<String, Decimal>{ accField => Decimal.valueOf(answer.EUR_CRM_Answer__c)});
			}
		}
		return answByAccFieldByAccId;
	}


	/* ========================================================= */
	/*      Middle Level Helpers
	/* ========================================================= */
	private String getAccFieldToPopulate(EUR_CRM_PRS_Answer__c answer) {
		if (answer.EUR_CRM_PRS_Question__r.EUR_CRM_Total_Champagne_Volume__c) { return 'EUR_CRM_Total_Champaign_Volume__c'; }
		if (answer.EUR_CRM_PRS_Question__r.EUR_CRM_Total_Spirits_Volume__c) { return 'EUR_CRM_Total_Spirits_Volume__c'; }
		return '';
	}


	/* ========================================================= */
	/*      Low Level Helpers
	/* ========================================================= */
	private Boolean isAnswerValidToUpdateAcc(EUR_CRM_PRS_Answer__c answer, Map<Id, RecordTypeInfo> rtInfoById) {
		return this.isValidCountryCode(answer)
			&& this.isValidRT(rtInfoById, answer);
	}

	private Boolean isAnswerValidToUpdateAcc(EUR_CRM_PRS_Answer__c answer, EUR_CRM_PRS_Answer__c oldAnswer, Map<Id, RecordTypeInfo> rtInfoById) {
		return this.isValidCountryCode(answer)
			&& this.isValidRT(rtInfoById, answer)
			&& this.isAnswerChanged(answer, oldAnswer);
	}

	private Boolean isValidRT(Map<Id, RecordTypeInfo> rtInfoById, EUR_CRM_PRS_Answer__c answer) {
		return ANSWER_RT_TO_UPDATE_ACC.contains(rtInfoById.get(answer.RecordTypeId).getDeveloperName());
	}

	private Boolean isValidCountryCode(EUR_CRM_PRS_Answer__c answer) {
		return ANSWER_COUNTRY_CODES_TO_UPDATE_ACC.contains(answer.EUR_CRM_Country_Code__c);
	}

	private Boolean isAnswerChanged(EUR_CRM_PRS_Answer__c answer, EUR_CRM_PRS_Answer__c oldAnswer) {
		return answer.EUR_CRM_Answer__c != oldAnswer.EUR_CRM_Answer__c;
	}

	private Boolean isNumeric(String s){
		Boolean isNumeric;
		try{
			Decimal.valueOf(s);
			isNumeric = true;
		} catch (Exception e) { isNumeric = false; }
		return isNumeric;
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private List<EUR_CRM_PRS_Answer__c> selectAnswersWhereIds(List<EUR_CRM_PRS_Answer__c> answers) {
		return [
			SELECT Id
			,	EUR_CRM_PRS_Question__r.EUR_CRM_Total_Champagne_Volume__c
			,	EUR_CRM_PRS_Question__r.EUR_CRM_Total_Spirits_Volume__c
			,	EUR_CRM_PRS_Segmentation__r.EUR_CRM_Account__c
			,	EUR_CRM_Answer__c
			FROM EUR_CRM_PRS_Answer__c
			WHERE Id IN :answers
		];
	}

	private List<EUR_CRM_Account__c> selectAccountsWhereIds(Set<Id> accIds) {
		return [
			SELECT Id
			,	EUR_CRM_Total_Champaign_Volume__c
			,	EUR_CRM_Total_Spirits_Volume__c
			FROM EUR_CRM_Account__c
			WHERE Id IN :accIds
		];
	}
}