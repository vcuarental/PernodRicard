public with sharing class LAT_BR_Return_AccountMobileController {

	public String accId {get;set;}
	

	public LAT_BR_Return_AccountMobileController() {
		accId = ApexPages.currentPage().getParameters().get('id');
	}
}