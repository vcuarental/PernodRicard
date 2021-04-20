/********************************************************************
* Company: Valuenet 
* Desarrollador: Waldemar Mayo
* Nombre del pagina: LAT_VFP04_AccountAdicionalFields
* Fecha: 10/01/2014 
*********************************************************************/

public with sharing class LAT_VFC04_AccountAdicionalFields {
	
	public map<String, Boolean> mapFieldIsAccessible {get;set;}
    public map<String, Boolean> mapFieldIsUpdateble {get;set;}
    public map<String, Boolean> mapFieldIsRequired {get;set;}
	public list<String> fieldsToShow {get;set;}
	public LAT_ACCOUNT__c latAcc {get;set;}
	public Boolean hasEdit {get;set;}
	public Boolean isEdit {get;set;}
	
	private Id accId;
	
	public LAT_VFC04_AccountAdicionalFields(ApexPages.StandardController controller){
		accId = controller.getId();
		init();
	}
	private void init(){
		String allFields = '';
		for(Schema.SObjectField nameAPIfield : Schema.SObjectType.LAT_ACCOUNT__c.fields.getMap().values()){
		    allFields += allFields==''?String.ValueOf(nameAPIfield):', '+String.ValueOf(nameAPIfield);
		}
		try{latAcc = Database.query('SELECT '+allFields+', LAT_Accountid__r.RecordType.DeveloperName FROM LAT_ACCOUNT__c WHERE LAT_Accountid__c =: accId');}catch(Exception e){}
		LAT_GeneralConfig__c profilesCS = LAT_GeneralConfig__c.getInstance('MX_BASIC_INFO_FIELDS_PROFILES_EDITABLE');
		LAT_GeneralConfig__c fieldsCS = LAT_GeneralConfig__c.getInstance('MX_BASIC_INFO_FIELDS_NOT_EDITABLE');
		Profile currentProfile = [SELECT Name FROM Profile WHERE Id = :Userinfo.GetProfileId()];
		
		if(latAcc != null){
			mapFieldIsAccessible = new map<String, Boolean>();
			mapFieldIsUpdateble = new map<String, Boolean>();
			mapFieldIsRequired = new map<String, Boolean>();
			fieldsToShow = new list<String>();
			hasEdit = false;
			isEdit = false;
			
			Map<String, Schema.FieldSet> mapFieldSetLatAccount = LAT_ACCOUNT__c.sObjectType.getDescribe().FieldSets.getMap();
			map<String, Schema.SObjectField> mapLatAccountDescr = Schema.SObjectType.LAT_ACCOUNT__c.fields.getMap();
	        for(String APIName : mapFieldSetLatAccount.keySet()){
	            if(APIName.equalsIgnoreCase(latAcc.LAT_Accountid__r.RecordType.DeveloperName)){
	                for(Schema.FieldSetMember f: mapFieldSetLatAccount.get(APIName).getFields()){
	                    fieldsToShow.add(f.getFieldPath());
					    mapFieldIsRequired.put(f.getFieldPath(), f.getRequired());
					    mapFieldIsAccessible.put(f.getFieldPath(), mapLatAccountDescr.get(f.getFieldPath()).getDescribe().isAccessible());
					    mapFieldIsUpdateble.put(f.getFieldPath(), mapLatAccountDescr.get(f.getFieldPath()).getDescribe().isUpdateable()&&!fieldsCS.LAT_Value__c.contains(f.getFieldPath()));
	                }
	            }
	        }
	        for(String field: mapFieldIsUpdateble.keySet()){
	        	if(mapFieldIsUpdateble.get(field) && profilesCS.LAT_Value__c.contains(currentProfile.Name)){
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
}