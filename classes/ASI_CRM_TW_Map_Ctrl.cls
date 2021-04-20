public without sharing class ASI_CRM_TW_Map_Ctrl {
    private Id recordId {set; get;}
    public ASI_CRM_AccountsAdditionalField__c member {set; get;}
    private ASI_CRM_TW_Settings__c my_cs = ASI_CRM_TW_Settings__c.getInstance();
    public String API_KEY{get; private set;}{API_KEY = my_cs != null && my_cs.ASI_CRM_TW_Google_API_KEY__c != null ? my_cs.ASI_CRM_TW_Google_API_KEY__c : 'AIzaSyAz-G6GDwcN0c4XRvReLmUVImv-spOynU8';}
	
    public ASI_CRM_TW_Map_Ctrl(ApexPages.StandardController controller) {
        recordId = controller.getId();
        //contract = (ASI_CRM_AccountsAdditionalField__c) controller.getRecord();
        init();
    }
    
    public void init(){
		this.member = [SELECT Id, ASI_CRM_CN_GPS_info__Latitude__s, ASI_CRM_CN_GPS_info__Longitude__s, ASI_CRM_Latitude__c, ASI_CRM_Longitude__c 
                     	FROM ASI_CRM_AccountsAdditionalField__c 
                     	WHERE Id  = :recordId];
        /*
        this.member = [SELECT Id, ASI_CRM_CN_GPS_info__Latitude__s, ASI_CRM_CN_GPS_info__Longitude__s, ASI_CRM_Latitude__c, ASI_CRM_Longitude__c 
                     	FROM ASI_CRM_AccountsAdditionalField__c 
                     	WHERE ASI_CRM_Account__c  = :recordId];
		*/
        //system.debug('@@@member: '+member);
    }
    
}