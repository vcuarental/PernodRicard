/**
Name: EUR_CRM_TradeFairPageController 
Description: Controller class for EUR_CRM_TradeFairTargetManagementPage
Main Functionalities:
    1. Initialize and display Objective > Regional > Manage Participants
    2. Searchable SKU - EUR_CRM_SKU__c object
    3. Editable targets, with User control depending on the Role
        Objective/Sales Agency Managed - TMKT/National only
        Regional & SR - REgional/Sales Manager only
        Manage Particpant - Regional 
   
Author/Company:    IP Converge Data Services,Inc.
History:      17.JUN.2014        IPC     Created
              30.DEV.2016        JAY     Change BQS to SKU
*/
public class EUR_CRM_TradeFairPageController extends EUR_CRM_AbstractSelectionItem{
 
    private EUR_CRM_ObjPromo__c objPromo;      
    public String searchString {get;set;} 
    
    public List<EUR_CRM_ObjPromo_Target__c> targets {get;set;}    
    public EUR_CRM_AbstractSelectionItem sCon {get;set;} 
    private List<EUR_CRM_ObjPromo_Target__c> toDeleteTargets; 
    public Boolean isTMKT{get;set;} //is Trade Marketing user?
    public Boolean isSalesManager{get;set;} // is Sales Manager?
    public Boolean isKAS{get;set;} // is Key Account Assitant?
    public Boolean isSuper{get;set;} // is Super User/admin
    private Map<String, ID> rtMap;
    public final String  REG_VOL_TARGET = 'EUR_DE_Regional_Volume_Target';
    public final String  SR_VOL_TARGET = 'EUR_DE_SR_Volume_Target';
    public final String OBJ_VOL_TARGET = 'EUR_DE_Objective_Volume_Target'; //Level 1 - Top  
    
    
    public String NSM_OFF_TRADE = 'EUR_DE_National_Sales_Manager_Off_Trade'; 
    Set<String> salesManagerRoles = new Set<String>{
    'EUR_DE_Regional_Sales_Manager_Off_Trade_North_East',
    'EUR_DE_Regional_Sales_Manager_Off_Trade_South',
    'EUR_DE_Regional_Sales_Manager_Off_Trade_West'};

    
    List<EUR_CRM_ObjPromo_Target__c > regionalTargets;  
    List<String> additionalFields;
    public Boolean isDraft {get;set;}
    
    public Boolean isEditAll {get;set;}
    public Boolean isNational {get;set;}
    public Boolean isRegional {get;set;}
    
    private List<User> regionalManagers;
    public Id regionManager{get;set;}
    public Id currentUserId {get;set;}
    
    public Boolean renderPage {get;set;}
    private Set<Id> taxonomyIds = new Set<Id>();    
    transient List<EUR_CRM_Account__c > euAccounts;
    public EUR_CRM_TradeFairPageController(ApexPages.StandardController stdController) {
        this.objPromo= (EUR_CRM_ObjPromo__c)stdController.getRecord();
        this.objPromo.Id = stdController.getRecord().id; 
        taxonomyIds = EUR_CRM_OPTargetHelperClass.retrieveCustomerTaxonomySet(objPromo.id);
        isDraft = false;
        if(taxonomyIds.size()<=0  ){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred. Please contact your System Administrator'));
                renderPage  = false;
        }else{
              euAccounts = [select id, EUR_CRM_Territory__r.EUR_CRM_Region__c,EUR_CRM_Status__c, ownerId,owner.name from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c in : taxonomyIds];
            if(euAccounts != null && euAccounts.size() > 0){
                isDraft = objPromo != null && objPromo.EUR_CRM_Status__c == 'Draft';
                renderPage  = true;
                searchString = ''; 
                rtMap = new Map<String,Id>();
                for(RecordType rt : [select id, developername from RecordType where developername in (:REG_VOL_TARGET,:SR_VOL_TARGET,:OBJ_VOL_TARGET ) and sobjecttype = 'EUR_CRM_ObjPromo_Target__c']){
                    rtMap.put(rt.developername,rt.id);
                }
                this.sCon = this;
                
                additionalFields = new List<String>{'EUR_CRM_SKU__c', 'EUR_CRM_SKU__r.name','EUR_CRM_BQS__c', 'EUR_CRM_BQS__r.name','EUR_CRM_Comments__c','EUR_CRM_Qty_Sell_in_Amount_Display__c','EUR_CRM_Qty_Sell_in_Amount_Bottle__c', 'EUR_CRM_Promotion_Type__c'};
                //regionalManagers = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(objPromo.EUR_CRM_Customer_Taxonomy__c);   
                regionalManagers = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(euAccounts);          
                
                Map<Id,UserRole> rolesMap = new Map<Id,UserRole>([select id,developername from UserRole where Developername in:salesManagerRoles OR Developername =:NSM_OFF_TRADE ]);
                Id currentUserRole = UserInfo.getUserRoleId();
                currentUserId = UserInfo.getUserId(); 
                if( rolesMap.get(currentUserRole) != null && salesManagerRoles.contains(rolesMap.get(currentUserRole).developername)){
                    isRegional = true;
                    regionManager = currentUserId;
                }else if(rolesMap.get(currentUserRole) != null && NSM_OFF_TRADE == rolesMap.get(currentUserRole).developername){
                    isNational = true; 
                    regionManager = (regionalManagers != null && regionalManagers.size() >0) ? regionalManagers.get(0).id : null;
           
                }else{
                    isEditAll= true;
                    regionManager = (regionalManagers != null && regionalManagers.size() >0) ? regionalManagers.get(0).id : null;
                }
                String uProfile = [select name from Profile where id=:UserInfo.getProfileID()][0].name;
                    
                isEditAll = EUR_CRM_OPTargetHelperClass.EDIT_ALL_PROFILES.contains(uProfile) ||  objPromo.ownerid == UserInfo.getUserId();
                   
                
                init();
                initParticipants();
            }else{
              renderPage  = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.EUR_CRM_CustomerTaxonomyHasNoAccounts));              
            }
        } 
    } 
    
    public List<SelectOption> getRegionalManagerOptions(){
        List<SelectOption> regionalManagerOptions = new List<SelectOption>();
        for(User regionManager : regionalManagers){
            regionalManagerOptions.add(new SelectOption(regionManager.id, regionManager.name));
        }
        return regionalManagerOptions;
    }
    private void init(){        
        targets = new List<EUR_CRM_ObjPromo_Target__c>();
        toDeleteTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        targets = [select id,
        EUR_CRM_SKU__c,
        EUR_CRM_SKU__r.name,EUR_CRM_Comments__c ,
            EUR_CRM_Qty_Sell_in_Amount_Bottle__c from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =: objPromo.Id
        AND recordtypeid =: rtMap.get(OBJ_VOL_TARGET)];  
        itemMap = new Map<Id,SObject>();
        for(EUR_CRM_ObjPromo_Target__c target : targets){ 
             existingIds.add(target.EUR_CRM_SKU__c);  
        }
        itemMap = new Map<Id,EUR_CRM_SKU__c>([select id, name from EUR_CRM_SKU__c where id in: existingIds]);
    }
    public void removeBQS(){
    }
    public void removeSKU(){
        Integer i = Integer.valueOf(ApexPages.CurrentPage().getParameters().get('rowIndex'));
        EUR_CRM_ObjPromo_Target__c  target = targets.remove(i-1);
        if(target.id != null)
            toDeleteTargets.add(target); 
        existingIDs.remove(target.EUR_CRM_SKU__c);
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
            if(targets != null && targets.size() > 0)
                upsert targets;    
        }catch(DMLException e){
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError)); 
        }
    }
    public PageReference save(){
        quickSave();
        quickSaveParticipants();
        quickSaveRegionalTargets();
        return cancel();  
    }  
   public override void add(){   
        EUR_CRM_ObjPromo_Target__c target = new EUR_CRM_ObjPromo_Target__c();
        String addedSKU = ApexPages.CurrentPage().getParameters().get('p1');
        target.EUR_CRM_SKU__c = (ID) addedSKU ;
        target.EUR_CRM_ObjPromo__c = objPromo.Id; 
        target.EUR_CRM_SKU__r = (EUR_CRM_SKU__c )itemMap.get((ID) addedSKU);
        target.recordtypeid = rtMap.get(OBJ_VOL_TARGET);
        targets.add(target);
        existingIds.add((ID) addedSKU );
   }
   
    public List<EUR_CRM_OPTargetHelperClass.TargetWrap> getRegionalTargetWraps(){ 
      //List<User> targetOwners = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(objPromo.EUR_CRM_Customer_Taxonomy__c);       
      regionalTargets = new List<EUR_CRM_ObjPromo_Target__c >();
      Id parentRecordTypeId = rtMap.get(OBJ_VOL_TARGET);
      Id subTargetRecordTypeId = rtMap.get(REG_VOL_TARGET);
      String targetField =  'EUR_CRM_SKU';
      Id rManager= null;     
      return EUR_CRM_OPTargetHelperClass.retrieveTargets(objPromo.id,regionalTargets ,parentRecordTypeId,subTargetRecordTypeId,targetField,regionalManagers
      ,rManager,additionalFields);
   } 
   
    public void quickSaveRegionalTargets(){
        try{
            if(regionalTargets != null && regionalTargets.size() > 0 )
                upsert regionalTargets;    
        }catch(DMLException e){
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError)); 
        }
    }
    public SelectOption[] selectedParticipants { get; set; }
    public SelectOption[] allParticipants { get; set; }
    
    Map<Id,EUR_CRM_ObjPromo_Trade_Fair_Participant__c> participantMap;
    
 
    public void initParticipants(){
        
        allParticipants = new List<SelectOption>();
        participantMap = new Map<Id,EUR_CRM_ObjPromo_Trade_Fair_Participant__c>();
        selectedParticipants = new List<SelectOption>();
        List<EUR_CRM_ObjPromo_Trade_Fair_Participant__c> participants = [select id,EUR_CRM_Participant__c, EUR_CRM_Participant__r.name from EUR_CRM_ObjPromo_Trade_Fair_Participant__c where EUR_CRM_Objectives_Promotions__c =:objPromo.id];
        
        for(EUR_CRM_ObjPromo_Trade_Fair_Participant__c c: participants){
            selectedParticipants.add(new SelectOption(c.EUR_CRM_Participant__c, c.EUR_CRM_Participant__r.name));
            participantMap.put(c.EUR_CRM_Participant__c, c);
        } 
        
        //List<User> allP = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(objPromo.EUR_CRM_Customer_Taxonomy__c,regionManager);
        if(euAccounts == null && taxonomyIds!=null)
            euAccounts = [select id, EUR_CRM_Territory__r.EUR_CRM_Region__c,EUR_CRM_Status__c,EUR_CRM_Status_of_Customer__c, ownerId,owner.name from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c in : taxonomyIds];
  

        List<User> allP = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(euAccounts,regionManager);

        size = allP.size();
        Set<Id> existingParticipants = new Set<Id>();
        
        for(EUR_CRM_ObjPromo_Trade_Fair_Participant__c  so : participants){
            existingParticipants.add(so.EUR_CRM_Participant__c);
        }
        for ( User c : allP ) {
            if(!existingParticipants.contains(c.id))
                allParticipants.add(new SelectOption(c.Id, c.Name));
        }
    }
    public Integer size {get;set;}
    public void quickSaveParticipants(){
        List<EUR_CRM_ObjPromo_Trade_Fair_Participant__c> participants = new List<EUR_CRM_ObjPromo_Trade_Fair_Participant__c>();
        List<EUR_CRM_ObjPromo_Trade_Fair_Participant__c> toDeleteParticipants = new List<EUR_CRM_ObjPromo_Trade_Fair_Participant__c>();
        Set<id> toSaveP = new Set<Id>();
        for ( SelectOption so : selectedParticipants){
            if(participantMap.get(so.getValue()) == null)
                participants.add(new EUR_CRM_ObjPromo_Trade_Fair_Participant__c(EUR_CRM_Objectives_Promotions__c = objPromo.id, EUR_CRM_Participant__c = so.getValue(),
                                    EUR_CRM_Sales_Manager__c = regionManager ));
            toSaveP.add(so.getValue());    
        }
        for(Id key :participantMap.keySet()){
            if(!toSaveP.contains(key))
                toDeleteParticipants.add(participantMap.get(key));
        }
        insert participants;
        delete toDeleteParticipants;
        initParticipants();
    }

}