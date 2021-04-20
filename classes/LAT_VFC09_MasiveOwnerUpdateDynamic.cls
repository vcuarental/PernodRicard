public with sharing class LAT_VFC09_MasiveOwnerUpdateDynamic {

	public User oldUser {get;set;}
	public User newUser {get;set;}

	public Account accOldLookup {get;set;}
	public Account accNewLookup {get;set;}

	public List<Account> listOfAccount {get;set;}
	public List<AccountInner> listInnerAccount {get;set;}
	public Boolean selectAll {get; set;}
    
    //Countries variables
    public String country {get;set;}
	public Map<String,String> countryCodes = new Map<String,String>{'ARS'=>'6','UYU'=>'5','MXN'=>'12','BRL'=>'1'};
    public String secondMXApprover {get;set;}

	public LAT_VFC09_MasiveOwnerUpdateDynamic() {
		country = countryCodes.get(UserInfo.getDefaultCurrency());
		listOfAccount = new List<Account>();
		listInnerAccount = new List<AccountInner>();
		accOldLookup = new Account();
		accNewLookup = new Account();
		selectAll = false;
	}

	public PageReference getAccountsPerUser(){

		listInnerAccount = new List<AccountInner>();

		if(accOldLookup.OwnerId != null){

			AccountInner accInn;

			for(Account acc : [Select Id,Name,CNPJ__c,Corporate_Name__c,OwnerId,Client_code_AN8__c 
							   From Account 
							   Where OwnerId = :accOldLookup.OwnerId]){

				accInn = new AccountInner();
				accInn.isSelected = false;
				accInn.razSocial = acc.Name;
				accInn.accId = acc.Id;
				accInn.ownerId = acc.OwnerId;
				accInn.an8 = acc.Client_code_AN8__c;
				accInn.cnpj = acc.CNPJ__c;
				accInn.nameFantasia = acc.Corporate_Name__c;
				listInnerAccount.add(accInn);
			}

		}

		if( listInnerAccount.isEmpty() ){

			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No records for the user selected'));

		    return null;
		}

		return null;
	}

	public PageReference transferAccounts(){
		
		String[] approverIds = LAT_GeneralConfigDao.getValueAsStringArray('ACCOUNT_OWNER_UPDATE', ';');
        Map<String, String> approverMaps = new Map<String, String>();
        
		for (String s: approverIds) {

	    			String[] countryApp = s.split(':');

	    			if (countryApp != null && countryApp.size() > 1) {

	    				approverMaps.put(countryCodes.get(countryApp[0]), countryApp[1]);

	    				if(countryApp[0] == 'MXN2'){
	    					secondMXApprover = countryApp[1];
	    				}
	    			}
				}

		if(!listInnerAccount.isEmpty()){

			Boolean found = false;
			for(AccountInner ai : listInnerAccount){
				if(ai.isSelected){
					found = true;
					break;
				}
			}
			if(!found){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.LAT_VFP9_Account_Transfer));
				return null;
			}else if(accNewLookup.OwnerId == null){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.LAT_VFP09_New_Owner_Selection));
				return null;
			}

			try{

		            LAT_MasiveOwnerHeader__c header;
		        	header = new LAT_MasiveOwnerHeader__c();
		        	header.LAT_Status__c = 'New';
		        	header.LAT_Approver__c = approverMaps.get(country) != null ? approverMaps.get(country) : UserInfo.getUserId();
		        	//If it's MX we will add a second approval to the feature.
		        	//This means, that the record MasiveOwnerHeader will have two approval
		        	// && tmpAccs[0].recordtype.developerName == 'LAT_MX_ACC_OnTrade'
		        	if(country == '12'){
		        		header.LAT_Approver_2__c = 	secondMXApprover != null ? secondMXApprover : null;
		        	}
		        	insert header;

		        	List<LAT_MasiveOwnerLine__c> lines = new List<LAT_MasiveOwnerLine__c>();

		        	for(AccountInner accInn : listInnerAccount){

		        		if(accInn.isSelected){

			        		LAT_MasiveOwnerLine__c line = new LAT_MasiveOwnerLine__c();
			        		line.LAT_Account__c = accInn.accId;
			        		line.LAT_OldValue__c = accInn.OwnerId;
			        		line.LAT_Header__c = header.id;

							if (accInn.an8 != null) {

			        			line.LAT_AccountAN8__c = accInn.an8;
								line.LAT_NewValue__c = accNewLookup.OwnerId;
			        			//if (newValues.containsKey(acc.Client_country_AN8__c)) {
			        			//	line.LAT_NewValue__c = newValues.get(acc.Client_country_AN8__c).trim();
			        			//} else {
			        			//	String accId = String.valueOf(acc.Id).substring(0,15);
			        			//}
			        		} else {
			        			line.LAT_AccountAN8__c = 'Not exists';
			        			line.LAT_NewValue__c = accNewLookup.OwnerId;
			        			//String accId = String.valueOf(acc.Id).substring(0,15);
			        			//line.LAT_NewValue__c = newValues.get(accId).trim();
			        		}
			        		lines.add(line);
		        	    }
		        	}

		        	if(!lines.isEmpty()){
		        		insert(lines);	
		        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.LAT_VFP06_Message04 + '<a href="/'+ header.id +'">' + header.id + '</a>'));
		        	}
		        	
		        	

			}catch(Exception e){

				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
			}

		}
		return null;
	}

	public class AccountInner {
		public Boolean isSelected {get;set;}
		public String razSocial {get;set;}
		public String nameFantasia {get;set;}
		public String accId {get;set;}
		public String ownerId {get;set;}
		public String an8 {get;set;}
		public String cnpj {get;set;}
		public String phone {get;set;}
		public String address {get;set;}
	} 
}