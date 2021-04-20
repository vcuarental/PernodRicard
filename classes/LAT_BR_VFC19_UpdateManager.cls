public without sharing class LAT_BR_VFC19_UpdateManager {
	
	public Account accLookup {get;set;}
	
	public LAT_BR_VFC19_UpdateManager() {
		accLookup = new Account();
	}

	public PageReference saveManager(){

		if (accLookup.ownerId != null ){

			User myUser = [Select id From User where id = :accLookup.ownerId];

			myUser.ManagerId = accLookup.Area_Manager__c;
				
			try{

				update myUser;

				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.LAT_BR_VFP33_002));


			}catch(Exception e){

				//if( e.getMessage().contains('Gerente de')){
					//ApexPages.getMessages().clear();
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.LAT_BR_VFP33_003));	
				//}else{
				//	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
				//}

				
			}

		}

    	return null;
		
	}

}