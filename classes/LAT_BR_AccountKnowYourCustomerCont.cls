public with sharing class LAT_BR_AccountKnowYourCustomerCont {
    public map<String, Boolean> mapFieldIsAccessible {get;set;}
    public map<String, Boolean> mapFieldIsUpdateble {get;set;}
    public map<String, Boolean> mapFieldIsRequired {get;set;}
    public list<String> fieldsToShow {get;set;}
    public LAT_ACCOUNT__c latAcc {get;set;}
    public Boolean hasEdit {get;set;}
    public Boolean isEdit {get;set;}
    
    private final Id accId;
    
    public LAT_BR_AccountKnowYourCustomerCont(ApexPages.StandardController controller){
        accId = controller.getId();
        init();
    }
    
    private void init(){
        latAcc = Database.query('SELECT LAT_BR_StatusDueDiligence__c, LAT_BR_DataDueDiligence__c, LAT_BR_PurchaseForecast__c, LAT_BR_Comments__c, LAT_Accountid__r.RecordType.DeveloperName FROM LAT_ACCOUNT__c WHERE LAT_Accountid__c =: accId');
        System.debug('%%%%% latAcc :'+latAcc);
        // Get Users in Permission Set LAT_BR_Legal
        List<Id> users = new List<Id>();
        for (PermissionSetAssignment psa: [SELECT p.Assignee.ID FROM PermissionSetAssignment p WHERE p.PermissionSet.Name = 'LAT_BR_Legal']) {
            users.add(psa.Assignee.Id);
        }
        Boolean profileCanUpdate = users.contains(UserInfo.getUserId());
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
            for (String APIName : mapFieldSetLatAccount.keySet()) {
                // WORKAROUND: use off_trade fieldset for all BR instances
                String developerRtName = '';
                if (latAcc.LAT_Accountid__r.RecordType.DeveloperName != 'On_Trade' && AP01_Account_BR.BR_RECORDTYPES.contains(latAcc.LAT_Accountid__r.RecordType.DeveloperName)){
                    developerRtName = 'Know_Your_Customer';
                } else {
                    developerRtName = latAcc.LAT_Accountid__r.RecordType.DeveloperName;
                }
                
                if (APIName.equalsIgnoreCase(developerRtName)) {
                   // if (APIName.equalsIgnoreCase(latAcc.LAT_Accountid__r.RecordType.DeveloperName)) {
                		for (Schema.FieldSetMember f: mapFieldSetLatAccount.get(APIName).getFields()) {
                    		system.debug('fieldset = '+f.getFieldPath());
                    		system.debug('fieldset = '+f.getRequired());
                    		fieldsToShow.add(f.getFieldPath());
                    		mapFieldIsRequired.put(f.getFieldPath(), f.getRequired());
                    		system.debug('fieldset = '+mapLatAccountDescr.get(f.getFieldPath()).getDescribe().isAccessible());
                    		mapFieldIsAccessible.put(f.getFieldPath(), mapLatAccountDescr.get(f.getFieldPath()).getDescribe().isAccessible());
                    		system.debug('fieldset = '+mapLatAccountDescr.get(f.getFieldPath()).getDescribe().isUpdateable());
                    		mapFieldIsUpdateble.put(f.getFieldPath(), mapLatAccountDescr.get(f.getFieldPath()).getDescribe().isUpdateable());
                        }
                    //}
                }
            }
            for(String field: mapFieldIsUpdateble.keySet()){
                if(mapFieldIsUpdateble.get(field) && profileCanUpdate){
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