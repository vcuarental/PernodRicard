public with sharing class LAT_MX_VFC_13_UpdateAccountOwner {
	
	public User oldUser {get;set;}
	public User newUser {get;set;}

	public Account accOldLookup {get;set;}
	public Account accNewLookup {get;set;}

	public List<Account> listOfAccount {get;set;}
	public List<AccountInner> listInnerAccount {get;set;}
	public Boolean selectAll {get; set;}
    
	Id regionId;
	Id plazaId;

	public LAT_MX_VFC_13_UpdateAccountOwner() {
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

			for(LAT_Account__c acc : [Select LAT_Accountid__c, LAT_Accountid__r.Name, LAT_Nombre_Comercial__c, 
									LAT_Accountid__r.OwnerId, LAT_Accountid__r.Client_code_AN8__c, LAT_MX_Descripcion__c 
							   From LAT_Account__c 
							   Where LAT_Accountid__r.OwnerId =:accOldLookup.OwnerId
							   		and LAT_ID_Status__c = 'Activo'
							   		and LAT_Accountid__r.Status__c = 'Cliente cadastrado no JDE']){

				accInn = new AccountInner();
				accInn.isSelected = false;
				accInn.razSocial = acc.LAT_Accountid__r.Name;
				accInn.accId = acc.LAT_Accountid__c;
				accInn.ownerId = acc.LAT_Accountid__r.OwnerId;
				accInn.an8 = acc.LAT_Accountid__r.Client_code_AN8__c;
				accInn.description = acc.LAT_MX_Descripcion__c;
				accInn.nameFantasia = acc.LAT_Nombre_Comercial__c;
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

		        Set <Id> accountsToUpdate = new Set <Id>();
		       	List<AccountInner> accountSelected = new LisT<AccountInner>();

	        	for(AccountInner accInn : listInnerAccount){

	        		if(accInn.isSelected){

	        			accountSelected.add(accInn);
	        			//accounts.add(accInn.accId);
	        		}
	        	}

	        	ApexPages.Message message;

	        	if(accountSelected.size() > 99){

	        		for(integer i = 0; i < 99; i++){

	        			accountsToUpdate.add(accountSelected.get(i).accId);
	        		}

	        		message = new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.LAT_MX_VFP_13_002);

	    		}else{

	    			for(integer i = 0; i < accountSelected.size(); i++){

	        			accountsToUpdate.add(accountSelected.get(i).accId);
	        		}

	    			message = new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.LAT_MX_VFP_13_001);	
	    		}

	        	if(!accountsToUpdate.isEmpty()){

	        		List<User> uList = [SELECT managerId From User where id = :accNewLookup.ownerId];

			        String mangerIdUser = '';
			        if(uList != null && uList.size()>0){
			            for(User u : uList){
			               mangerIdUser = u.ManagerId;
			            }
			            
			            List<LAT_MX_Region__c> regList = [SELECT Id from LAT_MX_Region__c where LAT_MX_KAM__c =:mangerIdUser];
			            if(regList != null && regList.size()>0){
			                regionId = regList.get(0).id;
			            }
			        }

					List<LAT_MX_Plaza__c> plaList = [SELECT id from LAT_MX_Plaza__c where LAT_MX_Ejecutivo__c = :accNewLookup.ownerId];
			                if(plaList != null && plaList.size()>0)
			                    plazaId = plaList.get(0).id;
	        		

	        		Database.executeBatch(new LAT_MX_UpdateAccountOwner_Batch(accountsToUpdate, accNewLookup.ownerid, plazaId, regionId), 99);

	        		ApexPages.addMessage(message);
	        		
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
		public String description {get;set;}
		public String phone {get;set;}
		public String address {get;set;}
	}
}