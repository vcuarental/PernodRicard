public with sharing class LAT_BR_VFC32_CommercialProposalRepCont {
	
	public List<Account> accountsWhitAttachments {get; set;}
	
	public LAT_BR_VFC32_CommercialProposalRepCont() {
		accountsWhitAttachments = new List<Account>();
		List<Account> res = [SELECT Id, Name, Client_code_AN8__c, OwnerId, Owner.Name,
		 (SELECT Id, Name, Createddate FROM Attachments WHERE Name like 'propostacomercial%' ORDER BY Createddate DESC LIMIT 1) 
		  FROM Account where Recordtype.Developername = 'On_Trade' AND Client_country_An8__c <> null ];
		for (Account a : res) {
			if (a.Attachments.size() ==1) {
				accountsWhitAttachments.add(a);
			}
		}

	}




}