/*****************************************************************
*	EUR_CRM_CompetitorPromoActiveHandler
* 	Sets the ACTIVE flag for EUR_CRM_Competitor_Promo_Tracking__c according to start and end date
******************************************************************/

public with sharing class EUR_CRM_CompetitorPromoActiveHandler extends EUR_CRM_TriggerAbstract{

	// Valid record types
	Set<String> validRecordTypes = new Set<String>{'EUR_MA_On_Trade_CPT'};
	// Object API name
    private String sObjectString;
    // RecordType Map from the sObject
    private Map<Id,Recordtype> RecordTypesMap;

    /*
    *	Constructor
    *	Params:
    *		sObjectString: String 	The API name of the object
    */
    public EUR_CRM_CompetitorPromoActiveHandler (String sObjectString){
        super('EUR_CRM_CompetitorPromoActiveHandler');
        this.sObjectString = sObjectString;
    }

    /*
    *	executeTriggerAction
    *	Main trigger execution
    */
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
       	
       	// Retrieve all record types associated with the sObject
       	List<Recordtype> RecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Competitor_Promo_Tracking__c');
        RecordTypesMap = new Map<Id,Recordtype>();
        // Create Id to recordtype map
        for(Recordtype rt : RecordTypes){
           RecordTypesMap.put(rt.id,rt);
        }

        for(EUR_CRM_Competitor_Promo_Tracking__c obj :  (List<EUR_CRM_Competitor_Promo_Tracking__c>) sObjList){
        	String rtDevName = RecordTypesMap.get(obj.recordtypeid).developername;
        	// Cater only to the records with the allowed recordtype
            if(validRecordTypes.contains(rtDevName)){
            	// Retrieve date values
	        	Date startDate = obj.EUR_CRM_Start_Date__c;
	        	Date endDate = obj.EUR_CRM_End_Date__c;
	        	Date today = date.Today();
	        	
				if(startDate == NULL){ 					
					if (endDate >= today) { 
						obj.EUR_CRM_Active__c = true;
					} else {
						obj.EUR_CRM_Active__c = false;
					} 
				}
				else if(endDate == NULL){ 
					if(startDate <= today) {
						 obj.EUR_CRM_Active__c = true;
					} else {
						 obj.EUR_CRM_Active__c = false;
					} 
				}	
				else {
					if(startDate <= today && endDate >= today) { obj.EUR_CRM_Active__c = true;	}
					else if(startDate < today && endDate < today) {  obj.EUR_CRM_Active__c = false;  }
					else if(startDate > today && endDate > today) {  obj.EUR_CRM_Active__c = false;  } 
				}
    		}
    	}
    }	
}