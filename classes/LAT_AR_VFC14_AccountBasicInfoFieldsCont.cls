public with sharing class LAT_AR_VFC14_AccountBasicInfoFieldsCont {
	public map<String, Boolean> mapFieldIsAccessible {get;set;}
    public map<String, Boolean> mapFieldIsUpdateble {get;set;}
    public map<String, Boolean> mapFieldIsRequired {get;set;}
	public list<String> fieldsToShow {get;set;}
	public LAT_ACCOUNT__c latAcc {get;set;}
	public Boolean hasEdit {get;set;}
	public Boolean isEdit {get;set;}
	
	private Id accId;
	
	public LAT_AR_VFC14_AccountBasicInfoFieldsCont(ApexPages.StandardController controller){
		accId = controller.getId();
		init();
	}
	private void init(){
		String allFields = '';
		for(Schema.SObjectField nameAPIfield : Schema.SObjectType.LAT_ACCOUNT__c.fields.getMap().values()){
		    allFields += allFields==''?String.ValueOf(nameAPIfield):', '+String.ValueOf(nameAPIfield);
		}
		Profile currentProfile = [SELECT Name FROM Profile WHERE Id = :Userinfo.GetProfileId()];
		LAT_GeneralConfig__c gc = [SELECT LAT_Value__c FROM LAT_GeneralConfig__c WHERE Name = 'AR_CANT_UPDATE_BASIC_INFO_FIELDS_PROF'];
		Boolean profileCanUpdate = gc.LAT_Value__c.contains(currentProfile.Name);
		System.debug('%%%%% Acc :'+accId);
		latAcc = Database.query('SELECT '+allFields+', LAT_Accountid__r.RecordType.DeveloperName FROM LAT_ACCOUNT__c WHERE LAT_Accountid__c =: accId');
		System.debug('%%%%% latAcc :'+latAcc);
		
		if(latAcc != null){
			mapFieldIsAccessible = new map<String, Boolean>();
			mapFieldIsUpdateble = new map<String, Boolean>();
			mapFieldIsRequired = new map<String, Boolean>();
			fieldsToShow = new list<String>();
			hasEdit = false;
			isEdit = false;
			System.debug('%%%%% latAcc.LAT_Accountid__r.RecordType.DeveloperName :'+latAcc.LAT_Accountid__r.RecordType.DeveloperName);
			Map<String, Schema.FieldSet> mapFieldSetLatAccount = LAT_ACCOUNT__c.sObjectType.getDescribe().FieldSets.getMap();
			map<String, Schema.SObjectField> mapLatAccountDescr = Schema.SObjectType.LAT_ACCOUNT__c.fields.getMap();
	        for(String APIName : mapFieldSetLatAccount.keySet()){
	            if(APIName.equalsIgnoreCase(latAcc.LAT_Accountid__r.RecordType.DeveloperName)){
	                for(Schema.FieldSetMember f: mapFieldSetLatAccount.get(APIName).getFields()){
	                    fieldsToShow.add(f.getFieldPath());
					    mapFieldIsRequired.put(f.getFieldPath(), f.getRequired());
					    mapFieldIsAccessible.put(f.getFieldPath(), mapLatAccountDescr.get(f.getFieldPath()).getDescribe().isAccessible());
					    mapFieldIsUpdateble.put(f.getFieldPath(), mapLatAccountDescr.get(f.getFieldPath()).getDescribe().isUpdateable());
	                }
	            }
	        }
	        for(String field: mapFieldIsUpdateble.keySet()){
	        	if(mapFieldIsUpdateble.get(field) && !profileCanUpdate){
	        		hasEdit = true;
	        		break;
	        	}
	        }
		}
	}
	
	public void doEdit(){
		isEdit = true;
	}
	public void doSave(){
		try{
			update latAcc;
			isEdit = false;

		}catch(Exception e){}
	}
	public void doCancel(){
		init();
	}

	public PageReference updateAccount() {
        update latAcc;
		isEdit = false;

		PageReference tempPage = ApexPages.currentPage();            
        tempPage.setRedirect(true);
    	return tempPage ;

    }
}