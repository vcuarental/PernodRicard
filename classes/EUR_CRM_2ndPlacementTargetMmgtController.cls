/**
Name: EUR_CRM_2ndPlacementTargetMmgtController
Description: Controller class for EUR_CRM_2ndPlacementTargetMgmtPage
Main Functionalities:
    1. Initialize and display Objective, Regional, Sales Rep Targets 
    2. Searchable BQS
    3. Editable targets, with User control depending on the Role
        Objective - TMKT/National only
        Regional & SR - REgional/Sales Manager only
    4. Depending on the Record type, promotion field is already pre-populated with default value depending
        on the Objetive Promotion Recordtype. i.e. 
                    'EUR_DE_Off_Trade_Secondary_Placement_Carton'=>'Carton'.
    5. Special Case : For secondary place theme Objective/Promotion RecordType
        Promotion type is not displayed. And comment field is in placed, and only editable for nationa/tmkt user.
   
Author/Company:    IP Converge Data Services,Inc.
History:      17.JUN.2014        IPC     Created
    
*/
public class EUR_CRM_2ndPlacementTargetMmgtController extends EUR_CRM_AbstractSelectionItem{
  
    private EUR_CRM_ObjPromo__c objPromo;   
            
    public String searchString {get;set;} 
    public List<EUR_CRM_ObjPromo_Target__c> targets {get;set;} 
    List<EUR_CRM_ObjPromo_Target__c > srTargets;
    List<EUR_CRM_ObjPromo_Target__c > regionalTargets;  
    private List<EUR_CRM_ObjPromo_Target__c> toDeleteTargets;  
    private Map<String, ID> rtMap;
    public String REG_VOL_TARGET = 'EUR_DE_Regional_Volume_Target';
    public String SR_VOL_TARGET = 'EUR_DE_SR_Volume_Target';
    public static final String OBJ_VOL_TARGET = 'EUR_DE_Objective_Volume_Target'; //Level 1 - Top  
    public Boolean isAny {get;set;}
    public Boolean isTheme {get;set;}
    transient List<EUR_CRM_Account__c > euAccounts;
    Map<String,String> rtPromoTypeMap = new Map<String,String>{
    'EUR_DE_Off_Trade_Secondary_Placement_Any'=>'Any',
    'EUR_DE_Off_Trade_Secondary_Placement_Carton'=>'Carton',
    'EUR_DE_Off_Trade_Secondary_Placement_Gondelkopf'=>'Gondelkopf',
    'EUR_DE_Off_Trade_Secondary_Placement_Razz_Fazz'=>'Razz Fazz',
    'EUR_DE_Off_Trade_Secondary_Placement_Standard'=>'Standard Display',
    'EUR_DE_Off_Trade_Secondary_Placement_Theme'=>'Theme'
    };
    List<String> additionalFields;
    
    public String NSM_OFF_TRADE = 'EUR_DE_National_Sales_Manager_Off_Trade'; 
    Set<String> salesManagerRoles = new Set<String>{
    'EUR_DE_Regional_Sales_Manager_Off_Trade_North_East',
    'EUR_DE_Regional_Sales_Manager_Off_Trade_South',
    'EUR_DE_Regional_Sales_Manager_Off_Trade_West'};
    public Boolean isDraft {get;set;}
    public Boolean isPublish {get;set;}

    public Boolean isEditAll {get;set;}
    public Boolean isNational {get;set;}
    public Boolean isRegional {get;set;}
    
    private List<User> regionalManagers;
    public String currentUserName {get;set;}
    public Id regionManager{get;set;}
    public Id currentUserId {get;set;}
    public Boolean renderPage {get;set;}
    private Set<Id> taxonomyIds = new Set<Id>();  
    public EUR_CRM_2ndPlacementTargetMmgtController(ApexPages.StandardController stdController) {
        this.objPromo= (EUR_CRM_ObjPromo__c)stdController.getRecord();
        this.objPromo= [select id,RecordType.developername, OwnerId, EUR_CRM_Status__c from EUR_CRM_ObjPromo__c where id = : stdController.getId() ];
        taxonomyIds = EUR_CRM_OPTargetHelperClass.retrieveCustomerTaxonomySet(objPromo.id);
        isDraft = false;
        isPublish = false;
        if(taxonomyIds == null || taxonomyIds.size() == 0 ){
              //  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred. Please contact your System Administrator'));
                renderPage  = false;
        }else{
            euAccounts = [select id, EUR_CRM_Territory__r.EUR_CRM_Region__c,EUR_CRM_Status__c, ownerId,owner.name from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c in : taxonomyIds];
            if(euAccounts != null && euAccounts.size() > 0){
                isDraft = objPromo != null && objPromo.EUR_CRM_Status__c == 'Draft';
                isPublish = objPromo != null && objPromo.EUR_CRM_Status__c == 'Published';
                renderPage  = true;
                rtMap = new Map<String,Id>();
                for(RecordType rt : [select id, developername from RecordType where developername in (:REG_VOL_TARGET,:SR_VOL_TARGET,:OBJ_VOL_TARGET ) and sobjecttype = 'EUR_CRM_ObjPromo_Target__c']){
                    rtMap.put(rt.developername,rt.id);
                }
                searchString = ''; 
                sCon = this;
                isAny = rtPromoTypeMap.get(objPromo.RecordType.Developername) == 'Any';
                isTheme = 'EUR_DE_Off_Trade_Secondary_Placement_Theme' == objPromo.RecordType.Developername;
                additionalFields = new List<String>{'EUR_CRM_BQS__c', 'EUR_CRM_BQS__r.name','EUR_CRM_Comments__c','EUR_CRM_Qty_Sell_in_Amount_Display__c','EUR_CRM_Qty_Sell_in_Amount_Bottle__c', 'EUR_CRM_Promotion_Type__c'};
            
                init();
                
                //set users;
                regionalManagers = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(euAccounts);      
                Map<Id,UserRole> rolesMap = new Map<Id,UserRole>([select id,developername from UserRole where Developername in:salesManagerRoles OR Developername =:NSM_OFF_TRADE ]);
                Id currentUserRole = UserInfo.getUserRoleId();
                currentUserId = UserInfo.getUserId();
                currentUserName = UserInfo.getUserName();
                if( rolesMap.get(currentUserRole) != null && salesManagerRoles.contains(rolesMap.get(currentUserRole).developername)){
                    isRegional = true;
                    isEditAll= true;
                    regionManager = currentUserId;
                }else if(rolesMap.get(currentUserRole) != null && NSM_OFF_TRADE == rolesMap.get(currentUserRole).developername){
                    isNational = true;
                    isEditAll= true;    
                    regionManager = (regionalManagers != null && regionalManagers.size() >0) ? regionalManagers.get(0).id : null;
             
                }else{
                    isEditAll= true;
                    regionManager = (regionalManagers != null && regionalManagers.size() >0) ? regionalManagers.get(0).id : null;
                }
                
                    String uProfile = [select name from Profile where id=:UserInfo.getProfileID()][0].name;
                    
                    //isEditAll = EUR_CRM_OPTargetHelperClass.EDIT_ALL_PROFILES.contains(uProfile) || objPromo.ownerid == UserInfo.getUserId();
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
            EUR_CRM_BQS__c, 
            EUR_CRM_Promotion_Type__c,
            EUR_CRM_Qty_Sell_in_Amount_Bottle__c,
            EUR_CRM_Comments__c
            from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =: objPromo.id AND 
            EUR_CRM_Target_Owner__c = null 
            AND recordtypeid =: rtMap.get(OBJ_VOL_TARGET)];          
        
        for(EUR_CRM_ObjPromo_Target__c target : targets){
             existingIds.add(target.EUR_CRM_BQS__c); 
        } 
        itemMap = new Map<Id,EUR_CRM_Size__c>([select id, name from EUR_CRM_Size__c where id in: existingIds]);     
    }
    public void quickSaveRegionalTargets(){
        try{ 
            if(regionalTargets!=null && regionalTargets.size() > 0 )
                upsert regionalTargets;    
        }catch(DMLException e){
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError)); 
        }
    }
   public List<EUR_CRM_OPTargetHelperClass.TargetWrap> getRegionalTargetWraps(){   
   
     // List<User> targetOwners = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(euAccounts);       
      regionalTargets = new List<EUR_CRM_ObjPromo_Target__c >();
      Id parentRecordTypeId = rtMap.get(OBJ_VOL_TARGET);
      Id subTargetRecordTypeId = rtMap.get(REG_VOL_TARGET);
      String targetField =  'EUR_CRM_BQS';
      Id rManager = null;
     
      return EUR_CRM_OPTargetHelperClass.retrieveTargets(objPromo.id,regionalTargets ,parentRecordTypeId,subTargetRecordTypeId,targetField,regionalManagers
      ,rManager ,additionalFields);
   } 
    public void quickSaveSRTargets(){
        try{
            system.debug('saving sr targets: ' + srTargets );
            if(srTargets != null && srTargets.size() > 0 )
            upsert srTargets;   
        }catch(DMLException e){
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError)); 
        }
    }
   public List<EUR_CRM_OPTargetHelperClass.TargetWrap> getSRTargetWraps(){     
      if(euAccounts == null && taxonomyIds!=null)
                 euAccounts = [select id, EUR_CRM_Territory__r.EUR_CRM_Region__c,EUR_CRM_Status__c,EUR_CRM_Status_of_Customer__c, ownerId,owner.name from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c in : taxonomyIds];
          
      List<User> targetOwners = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(euAccounts,  regionManager);    
      srTargets = new List<EUR_CRM_ObjPromo_Target__c >();
      Id parentRecordTypeId = rtMap.get(REG_VOL_TARGET);
      Id subTargetRecordTypeId = rtMap.get(SR_VOL_TARGET);
      String targetField =  'EUR_CRM_BQS'; 
    
      return EUR_CRM_OPTargetHelperClass.retrieveTargets(objPromo.id,srTargets,parentRecordTypeId,subTargetRecordTypeId,targetField,targetOwners 
      ,regionManager,additionalFields);
   } 
      
   public override void add(){   
        EUR_CRM_ObjPromo_Target__c target = new EUR_CRM_ObjPromo_Target__c();
        String addedSKU = ApexPages.CurrentPage().getParameters().get('p1');
        target.EUR_CRM_BQS__c = (ID) addedSKU ;
        target.EUR_CRM_ObjPromo__c = objPromo.id; 
        target.EUR_CRM_BQS__r = (EUR_CRM_Size__c )itemMap.get((ID) addedSKU);
        target.recordtypeid = rtMap.get(OBJ_VOL_TARGET);
        if(!isAny){
          target.EUR_CRM_Promotion_Type__c = rtPromoTypeMap.get(objPromo.RecordType.Developername);
        }
        targets.add(target);        
        existingIds.add((ID) addedSKU );
   } 
    
    public void removeSKU(){
        Integer i = Integer.valueOf(ApexPages.CurrentPage().getParameters().get('rowIndex')) -1;
        EUR_CRM_ObjPromo_Target__c  target = targets.remove(i);
        if(target.id != null)
            toDeleteTargets.add(target);  
        existingIDs.remove(target.EUR_CRM_BQS__c); 
    } 
    public void quickSave(){
        try{
            EUR_CRM_OPTargetHelperClass.deleteTargets(toDeleteTargets);
            if(targets !=null && targets.size() > 0)
                upsert targets;
            init();    
        }catch(DMLException e){
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,  Label.EUR_CRM_SaveError)); 
        }
    }
    public PageReference save(){
        quickSave(); 
        quickSaveRegionalTargets(); 
        quickSaveSRTargets();
        return cancel();  
    }   
    public PageReference cancel(){            
        PageReference pageRef = new PageReference('/' + objPromo.id); 
        pageRef.setRedirect(true); 
        return pageRef;    
    }
}