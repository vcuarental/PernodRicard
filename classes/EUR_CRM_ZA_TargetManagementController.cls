public with sharing class EUR_CRM_ZA_TargetManagementController extends EUR_CRM_AbstractSelectionItem{
 
    private EUR_CRM_ObjPromo__c objPromo; 
    public List<EUR_CRM_Size__c> bqsList{get;set;}     
    public String searchString {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> targets {get;set;}
    private List<EUR_CRM_ObjPromo_Target__c> toDeleteTargets;     
    public EUR_CRM_AbstractSelectionItem sCon {get;set;} 
    public Boolean isDraft {get;set;}
    public Boolean isOff {get; set;}
    public final String OBJ_PRODUCT = 'EUR_CRM_Objective_Product'; //Level 1 - Top
    public final String EUR_ZA_OFF_TRADE_DISPLAY_PROMO = 'EUR_ZA_Off_Trade_Promotion';
    public final String EUR_ZA_ON_TRADE_OP = 'EUR_ZA_On_Trade_Promotion';
    public final List<String> recordTypes = new List<String>{OBJ_PRODUCT, EUR_ZA_OFF_TRADE_DISPLAY_PROMO, EUR_ZA_ON_TRADE_OP};
    public final List<String> sobjectTypes = new List<String>{'EUR_CRM_ObjPromo_Target__c', 'EUR_CRM_ObjPromo__c'};
    Map<String,Id>  rtMap;
    
    public EUR_CRM_ZA_TargetManagementController(ApexPages.StandardController stdController) {
        this.objPromo= (EUR_CRM_ObjPromo__c)stdController.getRecord();
        this.objPromo.Id = stdController.getRecord().id;
        searchString = '';  
        this.sCon = this;
        isDraft = false;
        isDraft = objPromo != null && objPromo.EUR_CRM_Status__c == 'Draft';
        rtMap = new Map<String,Id>();
        for(RecordType rt : [select id, developername from RecordType where developername in :recordTypes and sobjecttype in :sobjectTypes]){
            rtMap.put(rt.developername,rt.id);
        }
        
        // Check if the OP is an off trade or on trade
        isOff = objPromo != null && rtMap.get(EUR_ZA_OFF_TRADE_DISPLAY_PROMO) == objPromo.recordTypeId;
        
        init(); 
    }
    
    private void init(){        
        // targets = new List<EUR_CRM_ObjPromo_Target__c>();
        toDeleteTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        targets = [select id,
        EUR_CRM_BQ__c, EUR_CRM_BQ__r.Name,
        EUR_CRM_BQS__c,
        EUR_CRM_BQS__r.name,EUR_CRM_Comments__c   from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =: objPromo.Id];
        itemMap = new Map<Id,SObject>();
        for(EUR_CRM_ObjPromo_Target__c target : targets){
            if(isOff) {
                existingIds.add(target.EUR_CRM_BQS__c);                     
            } else {
                existingIds.add(target.EUR_CRM_BQ__c);
            }
        }
        
        // Populate item map with BQ or BQS regarding the recordType
        if(isOff) {
            itemMap = new Map<Id,EUR_CRM_SIZE__c>([select id, name from EUR_CRM_SIZE__c where id in: existingIds]);            
        } else {
            itemMap = new Map<Id,EUR_CRM_Quality__c>([SELECT Id, Name FROM EUR_CRM_Quality__c WHERE Id IN :existingIds]);
        }
    }
    
    public void removeBQS(){
        Integer i = Integer.valueOf(ApexPages.CurrentPage().getParameters().get('rowIndex'));
        EUR_CRM_ObjPromo_Target__c  target = targets.remove(i-1);
        if(target.id != null) {
            toDeleteTargets.add(target);             
        }
        if(isOff) {
            existingIDs.remove(target.EUR_CRM_BQS__c);            
        } else {
            existingIDs.remove(target.EUR_CRM_BQ__c);
        }

    }
    
    public PageReference cancel(){            
        PageReference pageRef = new PageReference('/' + objPromo.Id); 
        pageRef.setRedirect(true); 
        return pageRef;    
    }
    
    public void quickSave(){
        try{
            if(toDeleteTargets.size() > 0)
                delete toDeleteTargets;
            upsert targets;     
        }catch(DMLException e){
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError )); 
        }
    }
    
    public PageReference save(){
        quickSave();
        return cancel();  
    }
    
    public override void add(){   
		EUR_CRM_ObjPromo_Target__c target = new EUR_CRM_ObjPromo_Target__c();
		String addedBQS = ApexPages.CurrentPage().getParameters().get('p1');
		if(isOff) {
            target.EUR_CRM_BQS__c = (ID) addedBQS;	 
            target.EUR_CRM_BQS__r = (EUR_CRM_Size__c )itemMap.get((ID) addedBQS);               
		} else {
		    target.EUR_CRM_BQ__c = (Id) addedBQS;
		    target.EUR_CRM_BQ__r = (EUR_CRM_Quality__c)itemMap.get((Id) addedBQS);
		}

		target.EUR_CRM_ObjPromo__c = objPromo.Id; 
		targets.add(target);
		target.recordtypeid = rtMap.get(OBJ_PRODUCT);
		existingIds.add((ID) addedBQS );
    }
}