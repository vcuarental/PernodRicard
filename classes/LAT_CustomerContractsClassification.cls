/*
* LAT_Contract2
* Author: Joaquin Arcardini (joaquin@zimmic.com)
* Date: 07/28/2016
*/
/*
* Modified
* Author: Javier Fagian (javier@zimmic.com) and Martin Prado (martin@zimmic.com)
* Date: 19/05/2017
*/
public with sharing class LAT_CustomerContractsClassification {


	public LAT_CustomerContractsClassification() { }

	public static void accountHasMoreThanOneActiveContract(Map<id, LAT_Contract2__c> newMap)
	{
		Set<ID> accountIDs = new Set<ID>();
		Set<ID> accountToChangeFieldTrue = new Set<ID>();
		Set<ID> accountToChangeFieldFalse = new Set<ID>();

		for (Id idContract : newMap.keySet()) {
			LAT_Contract2__c latContract2 = newMap.get(idContract);
			accountIDs.add(latContract2.Account__c);
		}

		// By default we uncheck "Cliente com Contrato" on lat account
		List<LAT_ACCOUNT__c> latActsFalse = [SELECT Id, LAT_CustomerContractsClassification__c FROM LAT_ACCOUNT__c WHERE LAT_Accountid__c IN: accountIDs];
		for (LAT_ACCOUNT__c latAct :latActsFalse ) {
			latAct.LAT_CustomerContractsClassification__c = false;
		}
		update latActsFalse;

		// If the user has at least 1 contract as Active, we check the "Cliente com Contrato" field
		for (AggregateResult agr : [SELECT Account__c accountID, Count(Id) numberOfContracts FROM LAT_Contract2__c WHERE Status__c  = 'Ativo' AND Account__c IN: accountIDs GROUP BY Account__c]) {
			Integer numberOfActiveContracts = Integer.valueOf(agr.get('numberOfContracts'));
			Id accountID = String.valueOf(agr.get('accountID'));
			if (numberOfActiveContracts >= 1) {
				accountToChangeFieldTrue.add(accountID);
			}
		}

		List<LAT_ACCOUNT__c> latActsTrue = [SELECT Id, LAT_CustomerContractsClassification__c FROM LAT_ACCOUNT__c WHERE LAT_Accountid__c IN : accountToChangeFieldTrue];

		for (LAT_ACCOUNT__c latAct :latActsTrue ) {
			latAct.LAT_CustomerContractsClassification__c = true;
		}

		if (latActsTrue.size() != 0) {
			update latActsTrue;
		}



	}

}