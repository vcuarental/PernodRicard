public without sharing class EUR_CRM_ObjectivePromoPageController {

    private EUR_CRM_ObjPromo__c objPromo;
    public Boolean isLeafletCampaign  {get;set;}
    public Boolean isTasting{get;set;}
    public Boolean isSalesDrive {get;set;}
    public Boolean isSalesDriveDisplays {get;set;}
    public Boolean isSalesDriveBottles {get;set;}
    public Boolean is2ndPlacement {get;set;}
    public Boolean isSecondary {get;set;}
    public Boolean isPROSSegment {get;set;}
    public Boolean isTradeFair{get;set;}
    public Boolean isDistDrive{get;set;}
    public Boolean isReadOnly{get;set;}
    public Boolean isSalesDriveType{get;set;}
    private Boolean isValid = false;

    public String  userCurrentID {get;set;}
    public Boolean isAdmin {get;set;}
    public Boolean isEditAll {get;set;}
    public Boolean isNational {get;set;}
    public Boolean isTMKT {get;set;}
    public Boolean isRegional {get;set;}

    public Boolean isKAM_Sub {get;set;}
    public Boolean isTMKT_Sub {get;set;}
    public Boolean isKAM_Specialized {get;set;}
    public Boolean isNAtManagerPrestige {get;set;}

    private Set<String> offtradeAccountRecordTypes = new Set<String>{'EUR_DE_OFF_STD'};
    private Set<Id> taxonomySet = new Set<Id>();
    private transient Set<ID> opAccountsSet;
    public Boolean pageError {get;set;}
    public transient List<euAccountsWrapper> euAccounts {get;set;}
    public Boolean isReady{get;set;}
    public List<String> validationMessages;
    public Boolean publishDisabled {get;set;}
    public Boolean isPROS {get;set;}
    public Boolean isLeaflet {get;set;}
    public Boolean isDistributionDrive {get;set;}
    public Boolean isWSPromoCampaign{get;set;}
    public Boolean isWSObjectiveCampaign{get;set;}
    private final String ON_TRADE_PROS_TMKT_PROMO = 'EUR_DE_OnTrade_PROS_TMKT_Promo';
    private final String OFF_TRADE_TASTING = 'EUR_DE_Off_Trade_Tasting_Campaign';
    private final String OFF_TRADE_TRADE_FAIR = 'EUR_DE_Off_Trade_Trade_Fair';
    private final String OFF_TRADE_LEAFLET = 'EUR_DE_Off_Trade_Leaflet_Campaign';
    private final String OFF_SALES_DRIVE = 'EUR_DE_Off_Trade_Sales_Drive';
    private final String OFF_DISTRIBUTION_DRIVE = 'EUR_DE_Off_Trade_Distribution_Drive';

    private final String WS_PROMO = 'EUR_DE_WS_Promotion';
    private final String WS_OBJECT = 'EUR_DE_WS_Objective';


    private String HEAD_TMKT ='EUR_DE_Head_of_Trade_Marketing';
    private String HEAD_KAM = 'EUR_DE_Head_of_Key_Account_Management';
    private String KAM_SPEACIALIZED = 'EUR_DE_KAM_Specialized_Wholesalers';
    private String NAT_MANAGER_PRESTIGE = 'EUR_DE_Regional_Sales_Manager_On_Trade_Prestige';

    private String NSM_OFF_TRADE = 'EUR_DE_National_Sales_Manager_Off_Trade';
    private String TMKT = 'EUR_DE_Trade_Marketing_Manager_Off_Trade';
    private Set<String> keyAccountAssitantRoles= new Set<String>{
        'EUR_DE_KAM_Assistant_Metro_Markant', 'EUR_DE_KAM_Assistant_Rewe_Edeka'};

    private Set<String> salesManagerRoles = new Set<String>{
        'EUR_DE_Regional_Sales_Manager_Off_Trade_North_East',
        'EUR_DE_Regional_Sales_Manager_Off_Trade_South',
        'EUR_DE_Regional_Sales_Manager_Off_Trade_West'};

    private Set<String> validRecordTypes  = new Set<String> {
        'EUR_DE_Off_Trade_Leaflet_Campaign',
        'EUR_DE_Off_Trade_Sales_Drive',
        'EUR_DE_Off_Trade_Secondary_Placement',
        'EUR_DE_OnTrade_PROS_TMKT_Promo',
        'EUR_DE_Off_Trade_Tasting_Campaign',
        'EUR_DE_Off_Trade_Trade_Fair',
        'EUR_DE_Off_Trade_Secondary_Placement_Carton',
        'EUR_DE_Off_Trade_Secondary_Placement_Gondelkopf',
        'EUR_DE_Off_Trade_Secondary_Placement_Razz_Fazz',
        'EUR_DE_Off_Trade_Secondary_Placement_Standard',
        'EUR_DE_Off_Trade_Secondary_Placement_Theme',
        'EUR_DE_Off_Trade_Secondary_Placement_Promo_Display',
        'EUR_DE_Off_Trade_Distribution_Drive',
        'EUR_DE_Off_Trade_Sales_Drive_SKU_Bottles',
        'EUR_DE_Off_Trade_Sales_Drive_SKU_Displays',
        'EUR_DE_WS_Objective',
        'EUR_DE_WS_Promotion_with_Lead_Time',
        'EUR_DE_WS_Promotion_without_Lead_Time'};

    private Set<String> secondaryRTs = new Set<String>{
        'EUR_DE_Off_Trade_Secondary_Placement_Carton',
        'EUR_DE_Off_Trade_Secondary_Placement_Gondelkopf',
        'EUR_DE_Off_Trade_Secondary_Placement_Razz_Fazz',
        'EUR_DE_Off_Trade_Secondary_Placement_Standard',
        'EUR_DE_Off_Trade_Secondary_Placement_Theme',
        'EUR_DE_Off_Trade_Secondary_Placement_Promo_Display'};

    public List<EUR_CRM_ObjPromo_Target__c> targets {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> skuTargets {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> secondaryTargets {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> tradeFairTargets{get;set;}
    public List<EUR_CRM_ObjPromo_Trade_Fair_Participant__c> tradeFairParticipants{get;set;}
    private String OBJ_VOL_TARGET = 'EUR_DE_Objective_Volume_Target'; //Level 1 - Top
    private String REG_VOL_TARGET = 'EUR_DE_Regional_Volume_Target'; // Level 2 - Mid
    private String SR_VOL_TARGET = 'EUR_DE_SR_Volume_Target'; // Level 3 - Low SR
    private Map<String, ID> rtMap;

    public Boolean isEditTarget {get;set;}
    public Boolean isDraft {get;set;}
    public Boolean isKAA {get;set;}

    public EUR_CRM_ObjectivePromoPageController() {}

    public EUR_CRM_ObjectivePromoPageController(ApexPages.StandardController stdController) {

        objPromo = (EUR_CRM_ObjPromo__c) stdController.getRecord();

        isDraft = objPromo.EUR_CRM_Status__c == 'Draft';

        isEditTarget =false;
        isKAA = false;
        isValid = validRecordTypes.contains(objPromo.RecordType.Developername);
        isSalesDrive = objPromo.RecordType.Developername == 'EUR_DE_Off_Trade_Sales_Drive';
        isSalesDriveBottles = objPromo.RecordType.Developername == 'EUR_DE_Off_Trade_Sales_Drive_SKU_Bottles';
        isSalesDriveDisplays = objPromo.RecordType.Developername == 'EUR_DE_Off_Trade_Sales_Drive_SKU_Displays';
        isLeafletCampaign  = objPromo.RecordType.Developername == 'EUR_DE_Off_Trade_Leaflet_Campaign';
        isTasting = objPromo.RecordType.Developername == 'EUR_DE_Off_Trade_Tasting_Campaign';
        is2ndPlacement = objPromo.RecordType.Developername == 'EUR_DE_Off_Trade_Secondary_Placement';
        isSecondary = secondaryRTs.contains(objPromo.RecordType.Developername);
        isPROSSegment = objPromo.RecordType.Developername == 'EUR_DE_OnTrade_PROS_TMKT_Promo';
        isTradeFair = objPromo.RecordType.Developername == 'EUR_DE_Off_Trade_Trade_Fair';
        isDistDrive = objPromo.RecordType.Developername == 'EUR_DE_Off_Trade_Distribution_Drive';

        isWSPromoCampaign =  objPromo.RecordType.Developername.contains(WS_PROMO);
        isWSObjectiveCampaign =  objPromo.RecordType.Developername == WS_OBJECT;

        targets = new List<EUR_CRM_ObjPromo_Target__c>();
        if(isLeafletCampaign || isTasting ||isDistDrive  )
            initBQS();
        if(isSalesDrive || isSalesDriveBottles || isSalesDriveDisplays)
            initSKUTargets();
        if(isTradeFair)
            initTradeFairTargets();
        if(isSecondary)
            initSecondaryTargets();
        if(isWSPromoCampaign)
            initBQS();
        if(isWSObjectiveCampaign)
            initMixedObjTargets();

        userCurrentID = UserInfo.getName();

        //checkMissingAssignedTarget();

        Map<Id,UserRole> rolesMap = new Map<Id,UserRole>([select id,developername from UserRole where
        Developername in:salesManagerRoles
            OR Developername =:NSM_OFF_TRADE
            OR  Developername in:keyAccountAssitantRoles
            OR  Developername =: TMKT
            OR  Developername =: HEAD_TMKT
            OR  Developername =: HEAD_KAM
            OR  Developername =: KAM_SPEACIALIZED
            OR  Developername =: NAT_MANAGER_PRESTIGE]);
        Id currentUserRole = UserInfo.getUserRoleId();
        Id currentUserId = UserInfo.getUserId();
        String currentRoleDevName = rolesMap.get(currentUserRole) != null ? rolesMap.get(currentUserRole).developername : '';
        String uProfile = [select name from Profile where id=:UserInfo.getProfileID()][0].name;

        isAdmin = uProfile == 'System Administrator' || uProfile == 'EUR System Admin';
        isEditAll = uProfile == 'System Administrator' || uProfile == 'EUR System Admin' || objPromo.ownerid == UserInfo.getUserId() || hasEditAccess();
        isRegional = rolesMap.get(currentUserRole) != null && salesManagerRoles.contains(rolesMap.get(currentUserRole).developername);
        isTMKT= rolesMap.get(currentUserRole) != null && TMKT == rolesMap.get(currentUserRole).developername;
        isNational = rolesMap.get(currentUserRole) != null && NSM_OFF_TRADE == rolesMap.get(currentUserRole).developername;
        isKAA = rolesMap.get(currentUserRole) != null && keyAccountAssitantRoles.contains(rolesMap.get(currentUserRole).developername);

        Set<Id> validOPAdminUsers = new Set<Id>();
        for(PermissionSetAssignment pa : [SELECT Id, Assignee.Name, Assignee.Id, PermissionSet.Name
        FROM PermissionSetAssignment where  PermissionSet.Name in: EUR_CRM_OPTargetHelperClass.OP_ADMIN_PERMISSION_SET] ){
            validOPAdminUsers.add(pa.Assignee.Id);
        }
        isReadOnly = !validOPAdminUsers.contains(UserInfo.getUserId()) && !(isEditAll ||isRegional || isNational);


        isNAtManagerPrestige = isKAM_Sub = isTMKT_Sub = isKAM_Specialized = false;

        isTMKT_Sub = getRoleSubordinateUsers(HEAD_TMKT).contains(currentUserId) || currentRoleDevName == HEAD_TMKT;
        isKAM_Sub = getRoleSubordinateUsers(HEAD_KAM).contains(currentUserId) || currentRoleDevName == HEAD_KAM;
        isKAM_Specialized = currentRoleDevName == KAM_SPEACIALIZED;
        isNAtManagerPrestige = currentRoleDevName == NAT_MANAGER_PRESTIGE;

        rtMap = new Map<String,Id>();
        for(RecordType rt : [select id, developername from RecordType where developername in (:REG_VOL_TARGET,:SR_VOL_TARGET,:OBJ_VOL_TARGET ) and sobjecttype = 'EUR_CRM_ObjPromo_Target__c']){
            rtMap.put(rt.developername,rt.id);
        }
        //    retrieveTradeFairTargets();

        /* verify Missing Targets - Run through the EUR_CRM_PublishObjectivePage*/
        //verifyMissingTargetInit();
    }

    @TestVisible
    private Boolean hasEditAccess(){
        Boolean hasEditAccess = false;
        if(objPromo != null){
            UserRecordAccess ura = [SELECT  RecordId, HasEditAccess FROM UserRecordAccess
            WHERE   UserId=:UserInfo.getUserId() AND
                RecordId =: objPromo.Id];
            if(ura != null)
                hasEditAccess = ura.hasEditAccess;
        }
        return hasEditAccess;
    }
    public void verifyMissingTargetInit(){
        publishDisabled = false;

        EUR_CRM_ObjPromo__c objective =  [select   RecordType.developername, EUR_CRM_Status__c,
            EUR_CRM_PROS_Image_Level__c, EUR_CRM_ObjPromo_OnTrade_Variation__c,
            EUR_CRM_Region__c, EUR_CRM_PROS_Group_Outlet__c ,EUR_CRM_Active_Start_Date__c,
            EUR_CRM_Territory__c, EUR_CRM_Type__c from EUR_CRM_ObjPromo__c where id =: objPromo.Id];
        euAccounts = new List<euAccountsWrapper>();
        pageError=false;

        String rtDevName = objective.RecordType.developername;

        isLeaflet = rtDevName == OFF_TRADE_LEAFLET;
        isTasting = rtDevName == OFF_TRADE_TASTING;
        isTradeFair = rtDevName == OFF_TRADE_TRADE_FAIR;
        isPROS = rtDevName == ON_TRADE_PROS_TMKT_PROMO;
        isSalesDriveType = rtDevName == OFF_SALES_DRIVE || rtDevName == 'EUR_DE_Off_Trade_Sales_Drive_SKU_Bottles' || rtDevName == 'EUR_DE_Off_Trade_Sales_Drive_SKU_Displays';
        isSalesDrive  = rtDevName == OFF_SALES_DRIVE ;
        isSalesDriveBottles = rtDevName == 'EUR_DE_Off_Trade_Sales_Drive_SKU_Bottles';
        isSalesDriveDisplays = rtDevName == 'EUR_DE_Off_Trade_Sales_Drive_SKU_Displays';
        isDistributionDrive = rtDevName == OFF_DISTRIBUTION_DRIVE;

        opAccountsSet = new Set<Id>();
        List<EUR_CRM_ObjPromo_Target__c> targets = null;
        for(EUR_CRM_ObjPromo_Account_Mapping__c opA :[select EUR_CRM_Account__c from EUR_CRM_ObjPromo_Account_Mapping__c where EUR_CRM_ObjPromo__c =:objective.id]){
            opAccountsSet.add(opA.EUR_CRM_Account__c);
        }

        if(isPROS  ){

            if(objective.EUR_CRM_PROS_Group_Outlet__c  == null){
                pageError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Missing Group Outlet Type'));
            }

            if(objective.EUR_CRM_PROS_Image_Level__c == null){
                pageError= true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Missing Image level'));
            }
            if(objective.EUR_CRM_ObjPromo_OnTrade_Variation__c == null){
                pageError= true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Missing On Trade Variation'));
            }

            if(!pageError){
                //system.debug('++ region: ' + objective.EUR_CRM_Region__c);
                //System.Debug('++ imagelevel: ' + objective.EUR_CRM_PROS_Image_Level__c);
                //System.Debug('++ groupoutlet: ' + objective.EUR_CRM_PROS_Group_Outlet__c);
                //System.Debug('++ territory: ' + objective.EUR_CRM_Territory__c);

                Set<Id> accSet= new Set<Id>();
                Set<String> images = new Set<String>();
                /* @@
                for(String image : (objective.EUR_CRM_PROS_Image_Level__c).split(';')){
                    if(image != null && image != '')
                        images.add(image);
                }
                */
                for(EUR_CRM_Pros_Segmentation__c pros : [select EUR_CRM_Account__c from  EUR_CRM_Pros_Segmentation__c where
                EUR_CRM_Account__r.EUR_CRM_Image_Level_Name__c =: objective.EUR_CRM_PROS_Image_Level__c and
                    EUR_CRM_Group_Outlet_Type__r.eur_crm_group_outlet_name__c  =: objective.EUR_CRM_PROS_Group_Outlet__c]){
                    accSet.add(pros.EUR_CRM_Account__c);
                }

                String query = 'select id from EUR_CRM_Territory__c where recordtype.developername = \'EUR_DE_Territory\' ';

                if(objective.EUR_CRM_Region__c != 'All Regions' && objective.EUR_CRM_Region__c != 'Alle Regionen'){
                    String regionName =  objective.EUR_CRM_Region__c;
                    query += ' and EUR_CRM_Region__r.name =:regionName';
                }
                String territoryName = objective.EUR_CRM_Territory__c;
                if(territoryName  != null && territoryName  != 'All Territories' && territoryName !='Alle Gabiete'){
                    query += ' and name =:territoryName';
                }

                Set<Id> territorySet = new Set<Id>();
                for(EUR_CRM_Territory__c terr: (List<EUR_CRM_Territory__c >)Database.query(query)){
                    territorySet.add(terr.id);
                }

                for(EUR_CRM_Account__c euA :[select id, name,Owner.name from eur_crm_account__c
                where  id in:accSet and EUR_CRM_Territory__c in: territorySet
                    AND (EUR_CRM_Status_of_Customer__c != 'Inactive' AND EUR_CRM_Status_of_Customer__c != 'Deleted')]){
                    euAccounts.add(new euAccountsWrapper(euA, false));
                }
            }
        }
        else{
            taxonomySet= new Set<Id>();
            for(EUR_CRM_OP_Customer_Taxonomy_Mapping__c taxMap : [select id,EUR_CRM_Customer_Taxonomy__c from EUR_CRM_OP_Customer_Taxonomy_Mapping__c where EUR_CRM_ObjPromo__c =: objective.id]){
                taxonomySet.add(taxMap.EUR_CRM_Customer_Taxonomy__c);
            }
            if(taxonomySet.size() == 0){
                publishDisabled = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.EUR_CRM_Select_Customer_Taxonomy_First));

            }else{
                String query = 'Select Id, name,Owner.name From EUR_CRM_Account__c where ';
                query += ' recordtype.developername in : offtradeAccountRecordTypes';
                query += ' AND EUR_CRM_Status_of_Customer__c != \'Inactive\' AND EUR_CRM_Status_of_Customer__c != \'Deleted\'';
                if(isTasting){
                    query +=' AND EUR_CRM_Outlet_suitable_for_tastings__c = \'Yes\'';
                }else if(isTradeFair){
                    query +=' AND EUR_CRM_Is_Trade_Fair_Location__c = true';
                }
                if(!isTradeFair)
                    query +=' AND EUR_JB_Customer_Taxonomy__c in : taxonomySet';

                List<EUR_CRM_Account__c> tempAccounts = (List<EUR_CRM_Account__c>) Database.query(query);
                for(EUR_CRM_Account__c euA :tempAccounts){
                    if(opAccountsSet.contains(euA.Id)){
                        euAccounts.add(new euAccountsWrapper(euA, true));
                    }else{
                        euAccounts.add(new euAccountsWrapper(euA, false));
                    }
                }
                targets = [select id, EUR_CRM_BQS__r.name, EUR_CRM_Qty_Sell_in_Amount_Bottle__c, EUR_CRM_SKU__c from EUR_CRM_ObjPromo_Target__c  where   EUR_CRM_ObjPromo__c =: objective.id];
                if(targets == null || targets.size() == 0){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,  Label.EUR_CRM_No_Product_Selected));
                    publishDisabled = true;
                }

            }
        }




        if(!isTasting && !isLeaflet && !isPROS && !isTradeFair&& !isDistributionDrive)
            verifyMissingTargets(objective.id, isSalesDriveType,  EUR_CRM_OPTargetHelperClass.retrieveCustomerTaxonomySet(objective.id));
        //System.Debug('@isTradeFair'+isTradeFair);
        /*
        if(isSalesDrive || isSalesDriveBottles || isSecondary){
            if(targets != null){
                for(EUR_CRM_ObjPromo_Target__c target : targets){
                    system.debug('@target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c'+target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c);
                    if(target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == null || target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == 0){
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.EUR_CRM_Missing_Target_for_Product + target.EUR_CRM_BQS__r.name));
                    publishDisabled = true;
                    }
                }
            }

            List<EUR_CRM_ObjPromo_Trade_Fair_Participant__c> participants = [select id from EUR_CRM_ObjPromo_Trade_Fair_Participant__c where EUR_CRM_Objectives_Promotions__c =: objPromo.id];
            if(participants == null || participants.size() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.EUR_CRM_Missing_Participants)); publishDisabled = true;
            }

        }
        */
    }

    public class ProductUser{
        public User targetOwner {get;set;}
        public EUR_CRM_SKU__c sku  {get;set;}
        public EUR_CRM_Size__c bqs{get;set;}
    }

    /*
  @Description: Wrapper Class for OFF Trade Tasting
  @History:     JUL.11.2014 - Created
*/
    public class euAccountsWrapper {
        public Boolean isSelected {get;set;}
        public EUR_CRM_Account__c euAccount {get;set;}

        public euAccountsWrapper(EUR_CRM_Account__c euAccount, Boolean isSelected){
            this.euAccount = euAccount;
            this.isSelected = isSelected;
        }
    }

    public void verifyMissingTargets(Id opId, Boolean isSalesDrive, Set<Id> taxonomyIds){

        Map<String,ProductUser> comboMap = new Map<String, ProductUser>();
        List<EUR_CRM_Account__c> euAccounts = EUR_CRM_OPTargetHelperClass.retrieveAccountsByTaxonomy(taxonomyIds);
        List<User> userList = new List<User>();
        List<User> regionalManagers = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(euAccounts);
        validationMessages = new List<String>();
        userList.addAll(regionalManagers);
        if(isSalesDrive)
            userList.addAll(EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSalesAgencyLevel(taxonomyIds));

        for(User regionManager: regionalManagers){
            List<User> targetOwners = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(euAccounts,  regionManager.id);
            userList.addAll(targetOwners);
        }
        // get the targets

        for(EUR_CRM_ObjPromo_Target__c target :[select EUR_CRM_SKU__r.name,  EUR_CRM_SKU__c, EUR_CRM_BQS__c, EUR_CRM_BQS__r.name from EUR_CRM_ObjPromo_Target__c
        where recordtype.developername = 'EUR_DE_Objective_Volume_Target'
            and EUR_CRM_ObjPromo__c =: opId]){
            for(User u : userList){
                String product = isSalesDrive ? target.EUR_CRM_SKU__c : target.EUR_CRM_BQS__c;
                String key = product + u.id;
                ProductUser pu = new ProductUser();
                pu.targetOwner = u;
                if(isSalesDrive)
                    pu.sku = target.EUR_CRM_SKU__r;
                else
                    pu.bqs = target.EUR_CRM_BQS__r;
                comboMap.put(key,pu);
            }
        }

        Map<String, EUR_CRM_ObjPromo_Target__c> existingTargets = new MAp<String, EUR_CRM_ObjPromo_Target__c>();

        //get existing targets
        for(EUR_CRM_ObjPromo_Target__c target : [select EUR_CRM_Qty_Sell_in_Amount_Bottle__c, EUR_CRM_SKU__r.name,  EUR_CRM_Target_Owner__c, EUR_CRM_SKU__c, EUR_CRM_BQS__c, EUR_CRM_BQS__r.name from EUR_CRM_ObjPromo_Target__c
        where recordtype.developername != 'EUR_DE_Objective_Volume_Target'
            and EUR_CRM_ObjPromo__c =: opId]){
            String product = isSalesDrive ? target.EUR_CRM_SKU__c : target.EUR_CRM_BQS__c;
            String key = product + target.EUR_CRM_Target_Owner__c;
            existingTargets.put(key, target);
        }

        for(String key : comboMap.keySet()){
            EUR_CRM_ObjPromo_Target__c target = existingTargets.get(key);
            if(target == null || target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == null || target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == 0 || target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c < 0){
                isReady = false;
                ProductUser pu = comboMap.get(key);
                String message = Label.EUR_CRM_Missing_Target_for_User+ pu.targetOwner.name + ' ';
                message += Label.EUR_CRM_For_Product;
                message += isSalesDrive  ?     pu.sku.name :  pu.bqs.name;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, message));
                publishDisabled = true;
            }
        }
    }

    public List<EUR_CRM_ObjPromo_OnTrade_Var_Detail__c> getVariationDetails(){

        List<EUR_CRM_ObjPromo_OnTrade_Var_Detail__c> details = [select id,EUR_CRM_Quality__r.name,EUR_CRM_Quality__c,EUR_CRM_Description__c from EUR_CRM_ObjPromo_OnTrade_Var_Detail__c where EUR_CRM_ObjPromo_OnTrade_Variation__c =:objPromo.EUR_CRM_ObjPromo_OnTrade_Variation__c];
        return details;
    }

    public List<TargetWrapper> targetWraps {get;set;}
    Map<Id,Map<Id,Set<Id>>> superMap = new  Map<Id,Map<Id,Set<Id>>>();
    Map<Id,EUR_CRM_ObjPromo_Target__c > targetsMap;


    private void initSKUTargets(){
        //System.Debug('initSKUTargets');
        targetsMap = new Map<Id,EUR_CRM_ObjPromo_Target__c >( [select id,name,
            EUR_CRM_BQS__c,
            EUR_CRM_BQS__r.name,
            EUR_CRM_SKU__c,
            EUR_CRM_O_P_Target__c,
            EUR_CRM_Achieved__c,
            EUR_CRM_Target_Owner__c,
            EUR_CRM_Target_Owner__r.name,
            EUR_CRM_Target_Level__c,
            EUR_CRM_SKU__r.EUR_CRM_Article_no__c,
            EUR_CRM_SKU__r.name,
            EUR_CRM_Qty_Sell_in_Amount_Bottle__c,
            EUR_CRM_Qty_Sell_in_Amount_Display__c,
            EUR_CRM_Qty_Sell_in_Amount_Carton__c,
            EUR_CRM_Percentage_Achieved__c,
            EUR_CRM_Customer_Reported_Ordered_Qty__c,
            EUR_CRM_Actual_Volume_Bottles__c,
            EUR_CRM_Actual_Volume_Displays__c,
            EUR_CRM_Actual_Volume_Cartons__c,
            EUR_CRM_Distance_to_Goal__c,
            EUR_CRM_Grouping_Type__c,
            EUR_CRM_Unit_of_Measure__c,
            EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c,
            EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c
        from EUR_CRM_ObjPromo_Target__c
        where EUR_CRM_ObjPromo__c = :objPromo.id
        order by EUR_CRM_Target_Level__c,EUR_CRM_SKU__r.name ]);
        targetWraps = new  List<TargetWrapper>();
        skuTargets = targetsMap.values();
        //System.Debug('@skuTargets'+skuTargets);

        for(EUR_CRM_ObjPromo_Target__c target : skuTargets){
            mapObject(target);
        }
        for(String objKey : superMap.keySet()){

            List<TargetWrapper> regionalTargets = new List<TargetWrapper>();
            TargetWrapper targetWrap = new TargetWrapper(targetsMap.get(objKey),regionalTargets);
            for(String regionalKey : superMap.get(objKey).keySet()){
                List<TargetWrapper> salesRepTargets = new List<TargetWrapper>();
                TargetWrapper regionalTargetWrap = new TargetWrapper(targetsMap.get(regionalKey),salesRepTargets );

                for(Id srId : superMap.get(objKey).get(regionalKey )){
                    salesRepTargets.add(new TargetWrapper(targetsMap.get(srId ),null));
                }
                regionalTargets.add(regionalTargetWrap);
            }
            targetWraps.add(targetWrap);
        }
        //System.Debug('@targetWraps'+targetWraps);
    }

    @TestVisible
    private void initMixedObjTargets(){
        //System.Debug('initMixedObjTargets');
        targetsMap = new Map<Id,EUR_CRM_ObjPromo_Target__c >( [select id,name,
            EUR_CRM_BQS__c,
            EUR_CRM_BQS__r.name,
            EUR_CRM_SKU__c,
            EUR_CRM_O_P_Target__c,
            EUR_CRM_Achieved__c,
            EUR_CRM_Target_Owner__c,
            EUR_CRM_Target_Owner__r.name,
            EUR_CRM_Target_Level__c,
            EUR_CRM_SKU__r.EUR_CRM_Article_no__c,
            EUR_CRM_SKU__r.name,
            EUR_CRM_Qty_Sell_in_Amount_Bottle__c,
            EUR_CRM_Qty_Sell_in_Amount_Display__c,
            EUR_CRM_Qty_Sell_in_Amount_Carton__c,
            EUR_CRM_Percentage_Achieved__c,
            EUR_CRM_Customer_Reported_Ordered_Qty__c,
            EUR_CRM_Actual_Volume_Bottles__c,
            EUR_CRM_Actual_Volume_Displays__c,
            EUR_CRM_Actual_Volume_Cartons__c,
            EUR_CRM_Distance_to_Goal__c,
            EUR_CRM_Grouping_Type__c,
            EUR_CRM_Unit_of_Measure__c,
            EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c,
            EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c
        from EUR_CRM_ObjPromo_Target__c
        where EUR_CRM_ObjPromo__c = :objPromo.id
        order by EUR_CRM_Target_Level__c,EUR_CRM_SKU__r.name ]);
        targetWraps = new  List<TargetWrapper>();
        skuTargets = targetsMap.values();
        //System.Debug('@skuTargets'+skuTargets);

        for(EUR_CRM_ObjPromo_Target__c target : skuTargets){
            mapObject(target);
        }
        for(String objKey : superMap.keySet()){

            List<TargetWrapper> regionalTargets = new List<TargetWrapper>();
            TargetWrapper targetWrap = new TargetWrapper(targetsMap.get(objKey),regionalTargets);
            for(String regionalKey : superMap.get(objKey).keySet()){
                List<TargetWrapper> salesRepTargets = new List<TargetWrapper>();
                TargetWrapper regionalTargetWrap = new TargetWrapper(targetsMap.get(regionalKey),salesRepTargets );

                for(Id srId : superMap.get(objKey).get(regionalKey )){
                    salesRepTargets.add(new TargetWrapper(targetsMap.get(srId ),null));
                }
                regionalTargets.add(regionalTargetWrap);
            }
            targetWraps.add(targetWrap);
        }
        //System.Debug('@targetWraps'+targetWraps);
    }

    String OBJECTIVE = 'Objective';
    String SALES_AGENCY = 'Sales Agency Managed';
    String REGIONAL = 'Regional';
    String SALES_REP = 'Sales Rep';


    public Object mapObject(EUR_CRM_ObjPromo_Target__c target){
        if(target.EUR_CRM_Target_Level__c == SALES_REP ){
            Set<Id> srTargets = (Set<Id>) mapObject(targetsMap.get(target.EUR_CRM_O_P_Target__c));
            srTargets.add(target.id);
            return null;
        }else if(target.EUR_CRM_Target_Level__c == REGIONAL ){
            Map<Id,Set<Id>> c = (Map<Id,Set<Id>>) mapObject(targetsMap.get(target.EUR_CRM_O_P_Target__c));
            if(c.get(target.id)==null)
                c.put(target.id, new Set<Id>());
            return c.get(target.id);
        }else if(target.EUR_CRM_Target_Level__c == SALES_AGENCY ){
            Set<Id> srTargets = (Set<Id>)  mapObject(targetsMap.get(target.EUR_CRM_O_P_Target__c));
            srTargets.add(target.id);
            return null;
        }else if(target.EUR_CRM_Target_Level__c == OBJECTIVE ){
            if(superMap.get(target.id) == null)
                superMap.put(target.id, new Map<Id,Set<Id>>());
            return superMap.get(target.id);
        }
        return null;
    }
    public void initBQS(){
        //System.Debug('initBQS');
        targets = [select id, name,
            EUR_CRM_BQS__c,
            EUR_CRM_BQS__r.name,EUR_CRM_Comments__c,EUR_CRM_SKU__c  from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =: objPromo.Id];
    }
    public void initTradeFairTargets(){
        //System.Debug('initTradeFairTargets');
        retrieveTradeFairTargets();
        tradeFairParticipants = [select id,name,EUR_CRM_Participant__c,EUR_CRM_Sales_Manager__c
        from EUR_CRM_ObjPromo_Trade_Fair_Participant__c
        where EUR_CRM_Objectives_Promotions__c =: objPromo.Id
        order by EUR_CRM_Sales_Manager__r.name,EUR_CRM_Participant__r.name];
    }

    public void initSecondaryTargets(){
        //System.Debug('initSecondaryTargets');
        //2016-12-30:Update BQS to SKU
        targetsMap = new Map<Id,EUR_CRM_ObjPromo_Target__c >( [select id, name,
            EUR_CRM_BQS__c,
            EUR_CRM_BQS__r.Name,
            EUR_CRM_SKU__c,
            EUR_CRM_Comments__c,
            EUR_CRM_Qty_Sell_in_Amount_Bottle__c,
            EUR_CRM_Actual_Volume_Bottles__c,
            EUR_CRM_Customer_Reported_Ordered_Qty__c,
            EUR_CRM_Percentage_Achieved__c,
            EUR_CRM_Target_Owner__c,
            EUR_CRM_Achieved__c,
            EUR_CRM_O_P_Target__c ,
            EUR_CRM_Target_Level__c,
            EUR_CRM_Distance_to_Goal__c
        from EUR_CRM_ObjPromo_Target__c
        where EUR_CRM_ObjPromo__c =: objPromo.Id
        order by EUR_CRM_Target_Level__c,EUR_CRM_BQS__r.name]);
        targetWraps = new  List<TargetWrapper>();
        secondaryTargets = targetsMap.values();


        for(EUR_CRM_ObjPromo_Target__c target : secondaryTargets){
            mapObject(target);
        }
        for(String objKey : superMap.keySet()){

            List<TargetWrapper> regionalTargets = new List<TargetWrapper>();
            TargetWrapper targetWrap = new TargetWrapper(targetsMap.get(objKey),regionalTargets);
            for(String regionalKey : superMap.get(objKey).keySet()){
                List<TargetWrapper> salesRepTargets = new List<TargetWrapper>();
                TargetWrapper regionalTargetWrap = new TargetWrapper(targetsMap.get(regionalKey),salesRepTargets );

                for(Id srId : superMap.get(objKey).get(regionalKey )){
                    salesRepTargets.add(new TargetWrapper(targetsMap.get(srId ),null));
                }
                regionalTargets.add(regionalTargetWrap);
            }
            targetWraps.add(targetWrap);
        }
        //System.Debug('@targetWraps'+targetWraps);

    }
    public List<EUR_CRM_ObjPromo_Action__c> getActions(){

        List<EUR_CRM_ObjPromo_Action__c> actionList = new List<EUR_CRM_ObjPromo_Action__c>();
        actionList = [select id,
            Name,
            EUR_CRM_Can_Reoccur__c,
            EUR_CRM_Entitle_Achievement__c,
            EUR_CRM_OP_Action_List_Template__c,
            EUR_CRM_Stage__c,
            EUR_CRM_OP_Sequence_Order__c,
            EUR_CRM_Stage_Sequence_Order__c
        from EUR_CRM_ObjPromo_Action__c
        where
            EUR_CRM_OP_Action_List_Template__c =: objPromo.EUR_CRM_OP_Action_List_Template__c
        order by EUR_CRM_Stage__c ASC];

        return actionList;
    }
    public PageReference redirect(){
        PageReference ref;
        if(!isValid){
            ref = new PageReference('/'+this.objPromo.Id+'?nooverride=1');
            ref.setRedirect(true);
        }
        return ref;
    }

    public class TargetWrapper{
        public Boolean getHasChild(){
            return this.subTargets != null && this.subTargets.size() > 0;
        }
        public EUR_CRM_ObjPromo_Target__c target {get;set;}
        public List<TargetWrapper> subTargets {get;set;}
        public TargetWrapper(EUR_CRM_ObjPromo_Target__c target, List<TargetWrapper> subTargets) {
            this.target = target;
            this.subTargets = subTargets;
        }
    }
    public void editTargets(){
        isEditTarget= true;
    }

    public void saveTarget(){
        isEditTarget= false;
        if(isTradeFair){
            update tradeFairTargets;
            retrieveTradeFairTargets();
        }if(isSalesDrive){
            List<EUR_CRM_ObjPromo_Target__c> targets = new List<EUR_CRM_ObjPromo_Target__c>();
            for(TargetWrapper t: targetWraps){
                targets.add(t.target);
            }
            update targets;
        }
    }

    public PageReference saveObjPromoDetail() {
        PageReference pageRef = new PageReference('/' + objPromo.Id);
        isEditTarget = false;
        //System.Debug(objPromo);
        update objPromo;
        return pageRef;
    }

    public void cancel(){
        isEditTarget= false;
        if(isTradeFair)
            retrieveTradeFairTargets();
    }

    public List<EUR_CRM_ObjPromo_Target__c> retrieveTradeFairTargets(){
        //2016-12-30:Update to BQS to SKU
        tradeFairTargets = [select id, name,
            EUR_CRM_SKU__c,
            EUR_CRM_Comments__c,
            EUR_CRM_Qty_Sell_in_Amount_Bottle__c,
            EUR_CRM_Actual_Volume_Bottles__c,
            EUR_CRM_Percentage_Achieved__c,
            EUR_CRM_Target_Owner__c,
            EUR_CRM_Customer_Reported_Ordered_Qty__c,
            EUR_CRM_Target_Level__c,
            EUR_CRM_O_P_Target__c,
            EUR_CRM_Distance_to_Goal__c,
            EUR_CRM_Achieved__c
        from EUR_CRM_ObjPromo_Target__c
        where EUR_CRM_ObjPromo__c =: objPromo.Id
        order by EUR_CRM_BQS__r.name,EUR_CRM_Target_Owner__r.name];
        return tradeFairTargets;
    }


    public static Set<ID> getRoleSubordinateUsers(String roleDevName) {

        // get requested user's role
        UserRole uRole = [select id from UserRole where Developername =: roleDevName];
        if(uRole == null)
            return new Set<Id>();

        Id roleId = uRole.id;
        // get all of the roles underneath the user
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
        // get all of the ids for the users in those roles
        Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where
            UserRoleId IN :allSubRoleIds]);
        // return the ids as a set so you can do what you want with them
        if(users != null && users.size() > 0)
            return users.keySet();
        else
            return new Set<Id>();

    }

    private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {

        Set<ID> currentRoleIds = new Set<ID>();

        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id from UserRole where ParentRoleId
            IN :roleIds AND ParentRoleID != null])
            currentRoleIds.add(userRole.Id);

        //go fetch some more rolls!
        if(currentRoleIds.size() > 0)
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));

        return currentRoleIds;

    }

}