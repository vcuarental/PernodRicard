/**
* Name: EUR_CRM_DE_SKUTargetMgt_SalesDriveCtrllr 
* Description: Controller class for EUR_CRM_DE_SKUTargetMgt_SalesDrive
* Main Functionalities:
*     1. Initialize and display Objective, Regional, Sales Rep Targets, Sales Agency Managed Targets 
*     2. Searchable SKU - EUR_CRM_SKU__c
*     3. Editable targets, with User control depending on the Role
*         Objective/Sales Agency Managed - TMKT/National only
*         Regional & SR - REgional/Sales Manager only 
*     4. Combine Bottle / Display / Carton into single Tagret
* 
* Author/Company:    LPT
* History:      14.FEB.2017        JAY     Created     
*/

public class EUR_CRM_DE_SKUTargetMgt_SalesDriveCtrllr extends EUR_CRM_AbstractSelectionItem{ 
    public Id currentUserId {get;set;}
    private EUR_CRM_ObjPromo__c objPromo; 
    
    public String searchString {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> targets {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> regionalTargets {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> srTargets {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> salesAgencyTargets {get;set;}
    private List<EUR_CRM_ObjPromo_Target__c> toDeleteTargets; 
     
    public  Map<Id, Set<Id>> existingSRTargetMap;     
    public final String OBJ_VOL_TARGET = 'EUR_DE_Objective_Volume_Target'; //Level 1 - Top
    public final String REG_VOL_TARGET = 'EUR_DE_Regional_Volume_Target'; // Level 2 - Mid
    public final String SR_VOL_TARGET = 'EUR_DE_SR_Volume_Target'; // Level 3 - Low SR
    public final String SALES_AGENCY_TARGET = 'EUR_DE_Sales_Agency_Managed_Target'; //
    
    public final String SALES_AGENCY_MANAGED = 'Agency Managed'; //status managed.
    
    //ROLES
    public String NSM_OFF_TRADE = 'EUR_DE_National_Sales_Manager_Off_Trade';
    public String RSM_OFF_TRADE = 'EUR_DE_Regional_Sales_Manager_Off_Trade_North_East';
    Set<String> salesManagerRoles = new Set<String>{
    'EUR_DE_Regional_Sales_Manager_Off_Trade_North_East',
    'EUR_DE_Regional_Sales_Manager_Off_Trade_South',
    'EUR_DE_Regional_Sales_Manager_Off_Trade_West'};
    
    private final Integer NATIONAL = 0;
    private final Integer REGIONAL = 1;
    private final Integer SR = 2;
    private final Integer SALES_AGENCY = 3;
    
    private Set<Id> custTaxonomyTargets;
    private Map<String, ID> rtMap; 
    private transient List<EUR_CRM_Account__c> euAccounts;
    private List<EUR_CRM_Account__c> salesAgencyAccounts;
    //
    public Boolean isDraft {get;set;}
    public Boolean isPublish {get;set;}
    public Boolean isPrepare {get;set;}
    
    public Boolean isEditAll {get;set;}
    public Boolean isNational {get;set;}
    public Boolean isRegional {get;set;}
    public Boolean isSalesAgencyManaged {get;set;}
    
    private List<User> regionalManagers;
    
    public Id regionManager {get;set;}
    
    public Boolean renderPage {get;set;}
    
    public Boolean isKAM{get;set;} //check if the user is KAM or System admin
    
    private Set<Id> taxonomyIds = new Set<Id>();

    private Map<Id,Id> regionalSalesAgentsMap;
    public EUR_CRM_DE_SKUTargetMgt_SalesDriveCtrllr(ApexPages.StandardController stdController) { 
        sCon = this;
        this.objPromo= (EUR_CRM_ObjPromo__c)stdController.getRecord();
        taxonomyIds = EUR_CRM_OPTargetHelperClass.retrieveCustomerTaxonomySet(objPromo.id);
        isDraft = false;
        isPublish = false;

        if(taxonomyIds == null || taxonomyIds.size() == 0){
            renderPage  = false;
        } else{ 
        
            euAccounts = [	select id, EUR_CRM_Territory__r.EUR_CRM_Region__c,EUR_CRM_Status__c,EUR_CRM_Status_of_Customer__c, 
            				ownerId,owner.name, EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__r.UserRole.developerName , 
            				EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c in : taxonomyIds];

            if(euAccounts != null && euAccounts.size() > 0){
                isDraft = objPromo != null && objPromo.EUR_CRM_Status__c == 'Draft';
                isPublish = objPromo != null && objPromo.EUR_CRM_Status__c == 'Published';

                renderPage  = true;
                searchString = ''; 
                salesAgencyAccounts = new List<EUR_CRM_Account__c>();
                
                rtMap = new Map<String,Id>();
                existingSRTargetMap = new Map<Id, Set<Id>>(); 
                for(RecordType rt : [select id, developername from RecordType where developername in (:REG_VOL_TARGET,:SR_VOL_TARGET,:OBJ_VOL_TARGET,:SALES_AGENCY_TARGET ) and sobjecttype = 'EUR_CRM_ObjPromo_Target__c']){
                    rtMap.put(rt.developername,rt.id);
                }    
                regionalManagers = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(euAccounts);      
                Map<Id,UserRole> rolesMap = new Map<Id,UserRole>([select id,developername from UserRole where Developername in:salesManagerRoles OR Developername =:NSM_OFF_TRADE ]);
                Id currentUserRole = UserInfo.getUserRoleId();
                currentUserId = UserInfo.getUserId();
                
                if( rolesMap.get(currentUserRole) != null && salesManagerRoles.contains(rolesMap.get(currentUserRole).developername)){
                    isRegional = true;
                    isEditAll = true; //Let Everyone Edit All
                    regionManager = currentUserId;
                }else if(rolesMap.get(currentUserRole) != null && NSM_OFF_TRADE == rolesMap.get(currentUserRole).developername){
                    isNational = true;
                    isEditAll = true; //Let Everyone Edit All
                    regionManager = (regionalManagers != null && regionalManagers.size() >0) ? regionalManagers.get(0).id : null;
                }else{
                    isEditAll= true;
                    regionManager = (regionalManagers != null && regionalManagers.size() >0) ? regionalManagers.get(0).id : null;
                }
                String uProfile = [select name from Profile where id=:UserInfo.getProfileID()][0].name;
                system.debug('@@ regional manager: ' + regionManager);
                //isEditAll = EUR_CRM_OPTargetHelperClass.EDIT_ALL_PROFILES.contains(uProfile) || objPromo.ownerid == UserInfo.getUserId();
                init();
                initSalesAgency();
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
    public void init(){
        targets = new List<EUR_CRM_ObjPromo_Target__c>(); 
        toDeleteTargets = new List<EUR_CRM_ObjPromo_Target__c>(); 
        targets = [ select id,EUR_CRM_Qty_Sell_in_Amount_Display__c,EUR_CRM_Qty_Sell_in_Amount_Carton__c ,EUR_CRM_Unit_of_Measure__c,EUR_CRM_Grouping_Type__c,  
        			EUR_CRM_SKU__r.name, EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c, EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c, EUR_CRM_SKU__r.EUR_CRM_Bottles_in_Carton__c,
        			EUR_CRM_SKU__c,EUR_CRM_SKU__r.EUR_CRM_Article_no__c,EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c,
        			EUR_CRM_Customer_Reported_Ordered_Qty__c, 
        			EUR_CRM_ObjPromo__c,
        			EUR_CRM_Qty_Sell_in_Amount_Bottle__c ,  EUR_CRM_Actual_Volume_Cartons__c, EUR_CRM_Actual_Volume_Displays__c 
        			from EUR_CRM_ObjPromo_Target__c 
        			where EUR_CRM_ObjPromo__c =: objPromo.Id and recordtypeid =: rtMap.get(OBJ_VOL_TARGET)];
        for(EUR_CRM_ObjPromo_Target__c target : targets){
              existingIds.add(target.EUR_CRM_SKU__c); 
        }     
        itemMap = new Map<Id,EUR_CRM_SKU__c>([select id, name, EUR_CRM_Article_no__c,EUR_CRM_Unit_Type__c,EUR_CRM_Brand_Quality_Size__c, EUR_CRM_Number_of_Bottles__c, EUR_CRM_Bottles_in_Carton__c, EUR_CRM_Bottles_per_Case__c from EUR_CRM_SKU__c where id in:existingIDs]);
   
    }

    public void initSalesAgency(){
      regionalSalesAgentsMap = new Map<Id,Id>();
      
     Map<String,User> regionSalesAgencyUserMap = new Map<String,User>();
     String NORD = 'Nor';
     String WEST = 'West';
     String SOUTH = 'South';
        
      for(User u : [select id,name,userrole.developername from user where userroleid in (SELECT Id FROM UserRole  where DeveloperName in: EUR_CRM_OPTargetHelperClass.SALES_AGENCY_ROLES)]){
            if(u.userrole.developername.contains( NORD))
                regionSalesAgencyUserMap.put( NORD, u);
            if(u.userrole.developername.contains( WEST))
                regionSalesAgencyUserMap.put( WEST,u);
            if(u.userrole.developername.contains(SOUTH))
                regionSalesAgencyUserMap.put(SOUTH, u);
      } system.debug('### regionSalesAgencyUserMap ' + regionSalesAgencyUserMap );
      List<User> targetOwners = new List<User>();
      for(EUR_CRM_Account__c euAccount : euAccounts){
        if(euAccount.EUR_CRM_Status_of_Customer__c == SALES_AGENCY_MANAGED){
          salesAgencyAccounts.add(euAccount);
          String accountRegionDevName = euAccount.EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__r.UserRole.developerName;
            system.debug('### accountRegionDevName ' + accountRegionDevName );
             
            if(accountRegionDevName.contains(NORD) &&regionSalesAgencyUserMap.get(NORD) !=null   ){
                 
                regionalSalesAgentsMap.put(euAccount.EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c,regionSalesAgencyUserMap.get(NORD).id);
            }
            if(accountRegionDevName.contains(WEST) &&regionSalesAgencyUserMap.get(WEST) !=null  ){
              regionalSalesAgentsMap.put(euAccount.EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c,regionSalesAgencyUserMap.get(WEST).id);
            }
            if(accountRegionDevName.contains(SOUTH) &&regionSalesAgencyUserMap.get(SOUTH) !=null ){
             regionalSalesAgentsMap.put(euAccount.EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c,regionSalesAgencyUserMap.get(SOUTH).id);
            }
        }
      }
    system.debug('### salesAgencyAccounts ' + salesAgencyAccounts);
    system.debug('### regionalSalesAgentsMap' + regionalSalesAgentsMap);
    isSalesAgencyManaged  = false;
    if(salesAgencyAccounts.size() > 0)
      isSalesAgencyManaged = true;   
    }
    public override void add(){  
        EUR_CRM_ObjPromo_Target__c target = new EUR_CRM_ObjPromo_Target__c();
        String addedSKU = ApexPages.CurrentPage().getParameters().get('p1'); 
        target.EUR_CRM_ObjPromo__c = objPromo.Id;
        target.EUR_CRM_SKU__c = (ID) addedSKU;
        target.EUR_CRM_SKU__r = (EUR_CRM_SKU__c )itemMap.get((ID) addedSKU);
        target.recordtypeid = rtMap.get(OBJ_VOL_TARGET);
        targets.add(target);
        existingIds.add((ID) addedSKU);  

        System.Debug('>>>New Target Added' + target);
   }
    public void removeSKU(){
        Integer i = Integer.valueOf(ApexPages.CurrentPage().getParameters().get('rowIndex'));
        EUR_CRM_ObjPromo_Target__c  target = targets.remove(i);
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
        system.debug('>>>quickSave');
        try{
            EUR_CRM_OPTargetHelperClass.deleteTargets(toDeleteTargets); 
            if(targets != null && targets.size() >0){
                for(EUR_CRM_ObjPromo_Target__c target : targets){
                    if(target.EUR_CRM_SKU__c != null && target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c !=null
                        && (target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c).contains('Display')){
                        Decimal numberOfBottles = target.EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c != null? target.EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c : 0;
                        Decimal qtyAmountDisplay = target.EUR_CRM_Qty_Sell_in_Amount_Display__c != null? target.EUR_CRM_Qty_Sell_in_Amount_Display__c : 0;
                        target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = numberOfBottles * qtyAmountDisplay;
                    }
                    if(target.EUR_CRM_SKU__c != null && target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c !=null
                        && (target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c).contains('Carton')){
                        Decimal numberOfBottles = target.EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c != null? target.EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c : 0;
                        Decimal qtyAmountCarton = target.EUR_CRM_Qty_Sell_in_Amount_Carton__c != null? target.EUR_CRM_Qty_Sell_in_Amount_Carton__c : 0;
                        target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = numberOfBottles * qtyAmountCarton;
                    }
                    else if(target.EUR_CRM_SKU__c != null && target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c !=null && target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == null 
                        && (target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c).contains('Bottle')){ 
                            target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 0;
                    }    

                }
                upsert targets;
                init();
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Sucessfully saved'));  
        }catch(DMLException e){
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError));
        }
    }

//EDIT TILL HERE

    public void quickSaveRegionalTargets(){
        system.debug('>>>quickSaveRegionalTargets');
        try{ 
            if(regionalTargets != null && regionalTargets.size() >0){
                for(EUR_CRM_ObjPromo_Target__c target : regionalTargets){
                    if(target.EUR_CRM_SKU__c != null && target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c !=null
                        && (target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c).contains('Display')){
                        Decimal numberOfBottles = target.EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c != null? target.EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c : 0;
                        Decimal qtyAmountDisplay = target.EUR_CRM_Qty_Sell_in_Amount_Display__c != null? target.EUR_CRM_Qty_Sell_in_Amount_Display__c : 0;
                        target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = numberOfBottles * qtyAmountDisplay;
                    }else if(target.EUR_CRM_SKU__c != null && target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c !=null
                        && (target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c).contains('Carton')){
                        Decimal numberOfBottles = target.EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c != null? target.EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c : 0;
                        Decimal qtyAmountCarton= target.EUR_CRM_Qty_Sell_in_Amount_Carton__c != null? target.EUR_CRM_Qty_Sell_in_Amount_Carton__c : 0;
                        target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = numberOfBottles * qtyAmountCarton;
                    }
                    else if(target.EUR_CRM_SKU__c != null && target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c !=null && target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == null 
                        && (target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c).contains('Bottle')){ 
                            target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 0;
                    }               
                }
                upsert regionalTargets;   
            }
        }catch(DMLException e){
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError));
 
        }
    }
    public void quickSaveSRTargets(){
        system.debug('>>>quickSaveSRTargets');
        try{
            if(srTargets != null && srTargets.size()>0){
                for(EUR_CRM_ObjPromo_Target__c target : srTargets){
                    if(target.EUR_CRM_SKU__c != null && target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c !=null
                        && (target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c).contains('Display')){
                        Decimal numberOfBottles = target.EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c != null? target.EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c : 0;
                        Decimal qtyAmountDisplay = target.EUR_CRM_Qty_Sell_in_Amount_Display__c != null? target.EUR_CRM_Qty_Sell_in_Amount_Display__c : 0;
                        target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = numberOfBottles * qtyAmountDisplay;
                    }else if(target.EUR_CRM_SKU__c != null && target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c !=null
                        && (target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c).contains('Carton')){
                        Decimal numberOfBottles = target.EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c != null? target.EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c : 0;
                        Decimal qtyAmountCarton = target.EUR_CRM_Qty_Sell_in_Amount_Carton__c != null? target.EUR_CRM_Qty_Sell_in_Amount_Carton__c : 0;
                        target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = numberOfBottles * qtyAmountCarton;
                    }
                    else if(target.EUR_CRM_SKU__c != null && target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c !=null && target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == null 
                        && (target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c).contains('Bottle')){ 
                            target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 0;
                    }  
                }
                upsert srTargets;   
            }
        }catch(DMLException e){
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError)); 
        }
    } 
     public void quickSaveSalesAgencyTargets(){
        system.debug('>>>quickSaveSalesAgencyTargets');
        try{
            if(salesAgencyTargets != null && salesAgencyTargets.size()>0)
                upsert salesAgencyTargets;  
        }catch(DMLException e){
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error has occured while saving the data'));
 
        }
    }
    public PageReference save(){
        quickSave();
        quickSaveSalesAgencyTargets();
        quickSaveSRTargets();
        quickSaveRegionalTargets();
        return cancel();  
    }  
    
    public List<EUR_CRM_OPTargetHelperClass.TargetWrap> getRegionalTargetWraps(){ 
        system.debug('>>>getRegionalTargetWraps');
        try{
            regionalTargets = new List<EUR_CRM_ObjPromo_Target__c >();
            Id parentRecordTypeId = rtMap.get(OBJ_VOL_TARGET);
            Id subTargetRecordTypeId = rtMap.get(REG_VOL_TARGET);
            String targetField =  'EUR_CRM_SKU';
            Id rManager = null;
            List<String> additionalFields = new List<String>{'EUR_CRM_Qty_Sell_in_Amount_Carton__c','EUR_CRM_Qty_Sell_in_Amount_Bottle__c ','EUR_CRM_SKU__c','EUR_CRM_SKU__r.EUR_CRM_Article_no__c','EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c','EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c ','EUR_CRM_Qty_Sell_in_Amount_Display__c', 'EUR_CRM_SKU__r.name','EUR_CRM_Promotion_Type__c ','EUR_CRM_Unit_of_Measure__c','EUR_CRM_Grouping_Type__c'};
            return EUR_CRM_OPTargetHelperClass.retrieveTargets(objPromo.Id,regionalTargets ,parentRecordTypeId,subTargetRecordTypeId,targetField,regionalManagers
            ,rManager ,additionalFields);

        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e));
            return null;
        }
    } 
   
    public List<EUR_CRM_OPTargetHelperClass.TargetWrap> getSalesAgencyTargetWraps(){
        system.debug('>>>getSalesAgencyTargetWraps');
        try{
            List<User> targetOwners = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSalesAgencyLevel(taxonomyIds);       
            salesAgencyTargets = new List<EUR_CRM_ObjPromo_Target__c >();
            Id parentRecordTypeId = rtMap.get(OBJ_VOL_TARGET);
            Id subTargetRecordTypeId = rtMap.get(SALES_AGENCY_TARGET);
            String targetField =  'EUR_CRM_SKU';
            Id regionManager = null;
            List<String> additionalFields = new List<String>{'EUR_CRM_Qty_Sell_in_Amount_Carton__c','EUR_CRM_Qty_Sell_in_Amount_Bottle__c ','EUR_CRM_O_P_Target__c','EUR_CRM_SKU__c','EUR_CRM_SKU__r.EUR_CRM_Article_no__c', 'EUR_CRM_SKU__r.name','EUR_CRM_Promotion_Type__c ','EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c','EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c ','EUR_CRM_Qty_Sell_in_Amount_Display__c','EUR_CRM_Unit_of_Measure__c','EUR_CRM_Grouping_Type__c'};

            return EUR_CRM_OPTargetHelperClass.retrieveTargets(objPromo.Id,salesAgencyTargets ,parentRecordTypeId,subTargetRecordTypeId,targetField,targetOwners
            ,regionManager,additionalFields);

        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e));
            return null;
        }
    }
    public List<EUR_CRM_OPTargetHelperClass.TargetWrap> getSalesAgencyTargetWrapsByRegion(Id regionalManager){
        system.debug('>>>getSalesAgencyTargetWrapsByRegion');
        try{ 
            List<User> targetOwners =  [select name, id from User where id =: regionalSalesAgentsMap.get(regionalManager)];     
            salesAgencyTargets = new List<EUR_CRM_ObjPromo_Target__c >();
            Id parentRecordTypeId = rtMap.get(REG_VOL_TARGET);
            Id subTargetRecordTypeId = rtMap.get(SALES_AGENCY_TARGET);
            String targetField =  'EUR_CRM_SKU';
            List<String> additionalFields = new List<String>{'EUR_CRM_Qty_Sell_in_Amount_Carton__c','EUR_CRM_Qty_Sell_in_Amount_Bottle__c ','EUR_CRM_O_P_Target__c','EUR_CRM_SKU__c','EUR_CRM_SKU__r.EUR_CRM_Article_no__c', 'EUR_CRM_SKU__r.name','EUR_CRM_Promotion_Type__c ','EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c','EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c ','EUR_CRM_Qty_Sell_in_Amount_Display__c','EUR_CRM_Unit_of_Measure__c','EUR_CRM_Grouping_Type__c'};
            return EUR_CRM_OPTargetHelperClass.retrieveTargets(objPromo.Id,salesAgencyTargets ,parentRecordTypeId,subTargetRecordTypeId,targetField,targetOwners,regionManager,additionalFields);
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e));
            return null;
        }
    }  
    
    public List<EUR_CRM_OPTargetHelperClass.TargetWrap> getSRTargetWraps(){ 
        system.debug('>>>getSRTargetWraps');
        try{ 
            if(euAccounts == null && taxonomyIds!=null)
             euAccounts = [select id, EUR_CRM_Territory__r.EUR_CRM_Region__c,EUR_CRM_Status__c,EUR_CRM_Status_of_Customer__c, ownerId,owner.name from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c in : taxonomyIds];

            List<User> targetOwners = null; 
            targetOwners = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(euAccounts,  regionManager); 
            srTargets = new List<EUR_CRM_ObjPromo_Target__c >();
            system.debug('### targetOwners: ' + targetOwners);
            Id parentRecordTypeId = rtMap.get(REG_VOL_TARGET);
            Id subTargetRecordTypeId = rtMap.get(SR_VOL_TARGET);
            String targetField =  'EUR_CRM_SKU';
            List<String> additionalFields = new List<String>{'EUR_CRM_Qty_Sell_in_Amount_Carton__c','EUR_CRM_Qty_Sell_in_Amount_Bottle__c ','EUR_CRM_SKU__c','EUR_CRM_SKU__r.EUR_CRM_Article_no__c', 'EUR_CRM_SKU__r.name','EUR_CRM_Promotion_Type__c ','EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c','EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c ','EUR_CRM_Qty_Sell_in_Amount_Display__c','EUR_CRM_Unit_of_Measure__c','EUR_CRM_Grouping_Type__c'};

            return EUR_CRM_OPTargetHelperClass.retrieveTargets(objPromo.Id,srTargets,parentRecordTypeId,subTargetRecordTypeId,targetField,targetOwners,regionManager,additionalFields);
       
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e));
            return null;
        }
    } 
        
    public List<EUR_CRM_OPTargetHelperClass.TargetWrap> getRegionalAndSalesAgencyTargetWraps(){ 
        system.debug('>>>getRegionalAndSalesAgencyTargetWraps');
        try{
            regionalTargets = new List<EUR_CRM_ObjPromo_Target__c >();
            Id parentRecordTypeId = rtMap.get(OBJ_VOL_TARGET);
            Id subTargetRecordTypeId = rtMap.get(REG_VOL_TARGET);
            String targetField =  'EUR_CRM_SKU';
            Id rManager = null;
            List<String> additionalFields = new List<String>{'EUR_CRM_Qty_Sell_in_Amount_Carton__c','EUR_CRM_Qty_Sell_in_Amount_Bottle__c ','EUR_CRM_SKU__c','EUR_CRM_SKU__r.EUR_CRM_Article_no__c', 'EUR_CRM_SKU__r.name','EUR_CRM_Promotion_Type__c ','EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c','EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c ','EUR_CRM_Qty_Sell_in_Amount_Display__c','EUR_CRM_Unit_of_Measure__c','EUR_CRM_Grouping_Type__c'};
            List<EUR_CRM_OPTargetHelperClass.TargetWrap> tempList  =  EUR_CRM_OPTargetHelperClass.retrieveTargets(objPromo.Id,regionalTargets ,parentRecordTypeId,subTargetRecordTypeId,targetField,regionalManagers
            ,rManager ,additionalFields);
            return tempList;
        
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e));
            return null;
        }
    }
        
    public List<EUR_CRM_OPTargetHelperClass.TargetWrap> getSalesRepAndSalesAgencyTargetWraps(){ 
        system.debug('>>>getSalesRepAndSalesAgencyTargetWraps');
        try { 

            if(euAccounts == null && taxonomyIds!=null){
                euAccounts = [select id, EUR_CRM_Territory__r.EUR_CRM_Region__c,EUR_CRM_Status__c,EUR_CRM_Status_of_Customer__c, ownerId,owner.name from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c in : taxonomyIds];
            }           
            List<User> targetOwners = null; 
            targetOwners = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(euAccounts,  regionManager); 
            srTargets = new List<EUR_CRM_ObjPromo_Target__c >();
            system.debug('### targetOwners: ' + targetOwners);
            Id parentRecordTypeId = rtMap.get(REG_VOL_TARGET);
            Id subTargetRecordTypeId = rtMap.get(SR_VOL_TARGET);
            String targetField =  'EUR_CRM_SKU';
            List<String> additionalFields = new List<String>{'EUR_CRM_Qty_Sell_in_Amount_Carton__c','EUR_CRM_Qty_Sell_in_Amount_Bottle__c ','EUR_CRM_SKU__c','EUR_CRM_SKU__r.EUR_CRM_Article_no__c', 'EUR_CRM_SKU__r.name','EUR_CRM_Promotion_Type__c ','EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c','EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c ','EUR_CRM_Qty_Sell_in_Amount_Display__c','EUR_CRM_Unit_of_Measure__c','EUR_CRM_Grouping_Type__c'};
            List<EUR_CRM_OPTargetHelperClass.TargetWrap> tempList = EUR_CRM_OPTargetHelperClass.retrieveTargets(objPromo.Id,srTargets,parentRecordTypeId,subTargetRecordTypeId,targetField,targetOwners
            ,regionManager,additionalFields);

            Map<Id, List<EUR_CRM_ObjPromo_Target__c>> salesAgencyMap = new Map<Id,List<EUR_CRM_ObjPromo_Target__c>>();

            for(EUR_CRM_OPTargetHelperClass.TargetWrap sTarget : getSalesAgencyTargetWrapsByRegion(regionManager)){
                salesAgencyMap.put(sTarget.target.EUR_CRM_SKU__c, sTarget.srTargets);
            }

            system.debug('### salesAgencyMap: ' + salesAgencyMap);
            for(EUR_CRM_OPTargetHelperClass.TargetWrap targetWrap :  tempList){
                if(targetWrap.srTargets != null && targetWrap.target != null){
                    targetWrap.srTargets.addAll(salesAgencyMap.get(targetWrap.target.EUR_CRM_SKU__c));
                    srTargets.addAll(salesAgencyMap.get(targetWrap.target.EUR_CRM_SKU__c)); 
                }
            } 
            
            return tempList;

        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e));
            return null;
        }
    }
}