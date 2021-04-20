public with sharing class EUR_CRM_AccountGroupComplexSelector {

	public List<EUR_CRM_AccountGroupUser__c> selectAGUsWhereAccIds(Set<Id> accIds) {
		return [
			SELECT Id
			,   EUR_CRM_AllowDeletion__c
			,   EUR_CRM_Status__c
			,   EUR_CRM_User__c
			,   EUR_CRM_AccessLevel__c
			,   EUR_CRM_AccountGroup__r.EUR_CRM_Account__c
			,   LastModifiedDate
			FROM EUR_CRM_AccountGroupUser__c
			WHERE EUR_CRM_AccountGroup__r.EUR_CRM_Account__c IN :accIds
			ORDER BY LastModifiedDate
		];
	}

	public List<EUR_CRM_AccountGroupUser__c> selectAGUsWhereIds(List<EUR_CRM_AccountGroupUser__c> agus) {
		return [SELECT Id
			,   EUR_CRM_User__c
			,   EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.EUR_CRM_Country_Code__c
			,   EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.OwnerId
			,   EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.CreatedById
			,   EUR_CRM_Status__c
		FROM EUR_CRM_AccountGroupUser__c
		WHERE Id IN :agus];
	}

}