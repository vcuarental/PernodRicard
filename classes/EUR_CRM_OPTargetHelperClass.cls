/**

*/
public class EUR_CRM_OPTargetHelperClass {
    public static final String OBJ_VOL_TARGET = 'EUR_DE_Objective_Volume_Target'; //Level 1 - Top
    public static final String REG_VOL_TARGET = 'EUR_DE_Regional_Volume_Target'; // Level 2 - Mid
    public static final String SR_VOL_TARGET = 'EUR_DE_SR_Volume_Target'; // Level 3 - Low SR
    public static final String SALES_AGENCY_TARGET = 'EUR_DE_Sales_Agency_Managed_Target'; //
    public static String RSM_OFF_TRADE = 'EUR_DE_Regional_Sales_Manager_Off_Trade_North_East';
    public static final String SALES_AGENCY_MANAGED = 'Agency Managed'; //status managed.

    public static final Set<String> SALES_MANAGER_ROLES = new Set<String>{
            'EUR_DE_Regional_Sales_Manager_Off_Trade_North_East',
            'EUR_DE_Regional_Sales_Manager_Off_Trade_South',
            'EUR_DE_Regional_Sales_Manager_Off_Trade_West'
    };
    public static final Set<String> OP_ADMIN_PERMISSION_SET = new Set<String>{
            'EUR_DE_ON_Trade_O_P_Admin',
            'EUR_DE_OFF_Trade_O_P_Admin'
    };

    public static final Set<String> EDIT_ALL_PROFILES = new Set<String>{
            'System Administrator',
            'EUR System Admin',
            'EUR DE KAM User'
    };
    public static Set<String> SALES_AGENCY_ROLES = new Set<String>{
            'EUR_DE_OFF_Sales_Agency_Nord_East',
            'EUR_DE_OFF_Sales_Agency_South',
            'EUR_DE_OFF_Sales_Agency_West'
    };

    public static final String NORD = 'Nor';
    public static final String WEST = 'West';
    public static final String SOUTH = 'South';
    public static List<EUR_CRM_Account__c> retrieveAccountsByTaxonomy(Set<Id> custIds) {
        return [select ownerid, EUR_CRM_Territory__r.EUR_CRM_Region__c from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c in:custIds limit 50000];
    }
    public static void deleteTargets(List<EUR_CRM_ObjPromo_Target__c> toDeleteTargets) {
        Set<Id> toDeleteSrTargets = new Set<Id>();
        for (EUR_CRM_ObjPromo_Target__c toDelete : toDeleteTargets) {
            if (toDelete.id != null)
                toDeleteSrTargets.add(toDelete.id);
        }

        List<EUR_CRM_ObjPromo_Target__c> deleteSRTargets = [select id from EUR_CRM_ObjPromo_Target__c where EUR_CRM_O_P_Target__c in:toDeleteSrTargets];

        if (deleteSRTargets.size() > 0) {
            deleteTargets(deleteSRTargets);
        }
        delete toDeleteTargets;
    }
    public static List<User> retrieveTargetOwnersSRLevel(Id customerTaxonomyId, Id regionalManager) {
        System.Debug('retrieveTargetOwnersSRLevel:Single Input:' + customerTaxonomyId + ':' + regionalManager);
        Set<Id> salesRepsId = new Set<ID>();
        Set<Id> validSalesRepsId = new Set<Id>();
        salesRepsId = EUR_CRM_RoleUtils.getRoleSubordinateUsers(regionalManager);

        AggregateResult[] groupedResults = [select ownerId, count(name) from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c = :customerTaxonomyId group by ownerid];

        for (AggregateResult ar : groupedResults) {
            if (salesRepsId.contains((String) ar.get('ownerId')))
                validSalesRepsId.add((String) ar.get('ownerId'));
        }


        List<User> targetOwners = new List<User>();
        if (validSalesRepsId.size() > 0)
            targetOwners = [select name, id from User where id in:validSalesRepsId];
        return targetOwners ;
    }
    public static List<User> retrieveTargetOwnersSRLevel(Set<Id> customerTaxonomyId, Id regionalManager) {

        System.Debug('retrieveTargetOwnersSRLevel:Set CTax Input:' + customerTaxonomyId + ':' + regionalManager);

        Set<Id> salesRepsId = new Set<ID>();
        Set<Id> validSalesRepsId = new Set<Id>();
        salesRepsId = EUR_CRM_RoleUtils.getRoleSubordinateUsers(regionalManager);

        AggregateResult[] groupedResults = [select ownerId, count(name) from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c in:customerTaxonomyId group by ownerid];

        for (AggregateResult ar : groupedResults) {
            if (salesRepsId.contains((String) ar.get('ownerId')))
                validSalesRepsId.add((String) ar.get('ownerId'));
        }


        List<User> targetOwners = new List<User>();
        if (validSalesRepsId.size() > 0)
            targetOwners = [select name, id from User where id in:validSalesRepsId];
        return targetOwners ;
    }
    public static List<User> retrieveTargetOwnersSRLevel(List<EUR_CRM_Account__c> euAccounts, Id regionalManager) {
        System.Debug('retrieveTargetOwnersSRLevel:List Acc Input:' + euAccounts + ':' + regionalManager);
        Set<Id> salesRepsId = new Set<ID>();
        Set<Id> validSalesRepsId = new Set<Id>();
        salesRepsId = EUR_CRM_RoleUtils.getRoleSubordinateUsers(regionalManager);
        System.Debug('retrieveTargetOwnersSRLevel:getRoleSubordinateUsers:' + salesRepsId);
        for (EUR_CRM_Account__c euAccount : euAccounts) {
            if (salesRepsId.contains(euAccount.ownerId))
                validSalesRepsId.add(euAccount.ownerId);
        }

        List<User> targetOwners = new List<User>();
        if (validSalesRepsId.size() > 0)
            targetOwners = [select name, id from User where id in:validSalesRepsId];
        return targetOwners ;
    }
    public static List<User> retrieveTargetOwnersRegionalLevel(Id customerTaxonomyId) {
        Set<Id> regions = new Set<Id>();
        Set<Id> validSalesRepsId = new Set<ID>();
        AggregateResult[] groupedResults = [select EUR_CRM_Territory__r.EUR_CRM_Region__c, count(name) from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c = :customerTaxonomyId group by EUR_CRM_Territory__r.EUR_CRM_Region__c];
        for (AggregateResult ar : groupedResults) {

            regions.add((String) ar.get('EUR_CRM_Region__c'));
        }
        for (EUR_CRM_Region__c region : [select ownerid,EUR_CRM_Region_Owner__c from EUR_CRM_Region__c where id in:regions]) {
            validSalesRepsId.add(region.EUR_CRM_Region_Owner__c);
        }
        List<User> targetOwners = [select name, id from User where id in:validSalesRepsId];
        return targetOwners;
    }
    public static List<User> retrieveTargetOwnersAccountOwnerManagerLevel(List<EUR_CRM_Account__c> euAccounts) {
        Set<Id> accountOwnerMgrsId = new Set<Id>();
        List<User> accountownermgrs = new List<User>();

        for (EUR_CRM_Account__c euAccount : euAccounts) {
            accountOwnerMgrsId.add(euAccount.EUR_CRM_Manager_of_Account_Owner__c);
        }

        accountownermgrs = [SELECT name,email,id FROM User WHERE id in:accountOwnerMgrsId];

        return accountownermgrs;
    }
    public static List<User> retrieveTargetOwnersAccountOwnerRegionalHeadLevel(List<EUR_CRM_Account__c> euAccounts) {
        return New List<User>();
    }
    public static List<User> retrieveTargetOwnersAccountOwnerRegionalHeadLevel(List<Id> accountOwnerId) {
        //For RU Phase 2, Assign target to head of on trade region
        Set<Id> accountOwnerMgrsId = new Set<Id>();
        //List<Id> accountOwnerId= new List<Id>();

        /*for(EUR_CRM_Account__c euAccount : euAccounts ){            
          accountOwnerId.add(euAccount.OwnerId);
        }*/

        /*accountownermgrs = [SELECT name,email,id FROM User WHERE id in:accountOwnerId];
        
        return accountownermgrs;*/


////////////////////////////////////
        Set<Id> TargetOwnerRoleIdSet = New Set<Id>();
        List<User> TargetOwnerList = New List<User>();
        Map<Id, UserRole> AllRURole = new Map<Id, UserRole>([SELECT Name,Id,ParentRoleId FROM UserRole WHERE Name like '%EUR RU%']);

        System.debug('All RU Role:' + AllRURole.Size());

        List<User> AccountOwnerList = [SELECT Id,Name,UserRoleId FROM User Where id in:accountOwnerId];

        Map<Id, Id> RoleToHeadRoleMap = New Map<Id, Id>();
        For (User AccOwner : AccountOwnerList) {

            Integer LoopCount = 1;
            //String RolePath= AllRURole.get(AccOwner.UserRoleId).Name + '|';
            Id UpperLevel = AccOwner.UserRoleId;
            Id HeadRole;
            Boolean HeadFound = False;

            List<Id> RoleCache = New List<Id>();

            If (RoleToHeadRoleMap.get(UpperLevel) != null) {
                //HeadRole = RoleToHeadUserMap.get(UpperLevel);
                HeadFound = True;
                System.Debug('GotCha!');
            } else if (AllRURole.get(UpperLevel) == null) {
                System.debug('This one no upper leverl at all!' + AccOwner);
            } else {
                //Loop of Single Account.Owner.Role
                do {
                    System.debug('Loop:' + LoopCount);
                    System.debug('UpperRole:Name:' + AllRURole.get(UpperLevel).Name);
                    System.debug('UpperRole:Is Head Account?:' + AllRURole.get(UpperLevel).Name.Contains('Head ON'));
                    System.debug('UpperRole:Parent:' + AllRURole.get(UpperLevel).ParentRoleId);

                    RoleCache.add(AllRURole.get(UpperLevel).Id);
                    if (AllRURole.get(UpperLevel).Name.Contains('Head ON')) {
                        //Found
                        HeadFound = True;
                        //LowerToUpperMap.put(RolePath,UpperLevel);
                        //HeadUser = [SELECT Id,Name,UserRoleId FROM User Where UserRoleId =: UpperLevel Limit 1];
                        //System.Debug(HeadOn);
                        TargetOwnerRoleIdSet.add(UpperLevel);
                    } else {
                        UpperLevel = AllRURole.get(UpperLevel).ParentRoleId;
                    }
                    LoopCount += 1;
                    System.Debug('Next Upper:' + UpperLevel);
                    //System.Debug('Next Parent:' + AllRURole.get(UpperLevel).ParentRoleId);
                } While (!HeadFound && AllRURole.get(UpperLevel) != null && LoopCount < 10000);

                System.Debug('RoleCache' + RoleCache);
                System.Debug('UpperLevel' + UpperLevel);
                If (!HeadFound) {
                    System.Debug('Head Not Found:' + AccOwner);
                }

                for (Id CacheRoleID : RoleCache) {
                    RoleToHeadRoleMap.put(CacheRoleID, UpperLevel);
                }
            }
            //System.Debug(AccOwner +':>>>' + HeadUser);

        }
        /*For(Id RoleId : RoleToHeadUserMap.KeySet()){
            System.Debug('RoleId:' + RoleId + ' Head On is: ' + RoleToHeadRoleMap.Get(RoleId));
        }*/
        System.Debug('Target Owner Role:' + TargetOwnerRoleIdSet);
        TargetOwnerList = [SELECT Id,Name,UserRoleId FROM User Where UserRoleId in :TargetOwnerRoleIdSet];
        System.Debug('Target Owner:' + TargetOwnerList);
        return TargetOwnerList;
    }
    public static List<User> retrieveTargetOwnersAccountOwnerLevel(List<EUR_CRM_Account__c> euAccounts) {
        Set<Id> accountOwnerMgrsId = new Set<Id>();
        List<User> accountownermgrs = new List<User>();

        for (EUR_CRM_Account__c euAccount : euAccounts) {
            accountOwnerMgrsId.add(euAccount.OwnerId);
        }

        accountownermgrs = [SELECT name,email,id FROM User WHERE id in:accountOwnerMgrsId];

        return accountownermgrs;
    }
    public static List<User> retrieveTargetOwnersRegionalLevel(Set<Id> customerTaxonomyId) {
        Set<Id> regions = new Set<Id>();
        Set<Id> validSalesRepsId = new Set<ID>();

        AggregateResult[] groupedResults = [select EUR_CRM_Territory__r.EUR_CRM_Region__c, count(name) from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c = :customerTaxonomyId group by EUR_CRM_Territory__r.EUR_CRM_Region__c];
        for (AggregateResult ar : groupedResults) {

            regions.add((String) ar.get('EUR_CRM_Region__c'));
        }
        for (EUR_CRM_Region__c region : [select ownerid,EUR_CRM_Region_Owner__c from EUR_CRM_Region__c where id in:regions]) {
            validSalesRepsId.add(region.EUR_CRM_Region_Owner__c);
        }
        List<User> targetOwners = [select name, email, id from User where id in:validSalesRepsId];
        return targetOwners;
    }
    public static List<User> retrieveTargetOwnersRegionalLevel(List<EUR_CRM_Account__c> euAccounts) {
        Set<Id> regions = new Set<Id>();
        Set<Id> validSalesRepsId = new Set<ID>();

        for (EUR_CRM_Account__c euAccount : euAccounts) {
            regions.add(euAccount.EUR_CRM_Territory__r.EUR_CRM_Region__c);
        }
        for (EUR_CRM_Region__c region : [select ownerid,EUR_CRM_Region_Owner__c from EUR_CRM_Region__c where id in:regions]) {
            validSalesRepsId.add(region.EUR_CRM_Region_Owner__c);
        }

        List<User> targetOwners = [select name, email, id from User where id in:validSalesRepsId];

        return targetOwners;
    }
    public static List<User> retrieveTargetOwnersSalesAgencyLevel(Id customerTaxonomyId) {

        Set<Id> validSalesRepsId = new Set<ID>();
        AggregateResult[] groupedResults = [
                select ownerId, count(name)
                from EUR_CRM_Account__c
                where EUR_JB_Customer_Taxonomy__c = :customerTaxonomyId
                and EUR_CRM_Status_of_Customer__c = :SALES_AGENCY_MANAGED
                group by ownerId
        ];
        for (AggregateResult ar : groupedResults) {

            validSalesRepsId.add((String) ar.get('ownerId'));
        }
        /*
    for(EUR_CRM_Account__c euAccount : euAccounts){

                validSalesRepsId.add(euAccount.ownerId);
        } */
        List<User> targetOwners = new List<User>();
        if (validSalesRepsId.size() > 0)
            targetOwners = [select name, id from User where id in:validSalesRepsId];
        return targetOwners;
    }
    public static List<User> retrieveTargetOwnersSalesAgencyLevel(Set<Id> customerTaxonomyId) {
        AggregateResult[] groupedResults = [
                select EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__r.UserRole.developerName dev, count(name)
                from EUR_CRM_Account__c
                where EUR_JB_Customer_Taxonomy__c in:customerTaxonomyId
                and EUR_CRM_Status_of_Customer__c = :SALES_AGENCY_MANAGED
                group by EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__r.UserRole.developerName
        ];
        Map<String, User> regionSalesAgencyUserMap = new Map<String, User>();

        for (User u : [select id,name,userrole.developername from user where userroleid in (SELECT Id FROM UserRole where DeveloperName in:SALES_AGENCY_ROLES)]) {
            if (u.userrole.developername.contains(NORD))
                regionSalesAgencyUserMap.put(NORD, u);
            if (u.userrole.developername.contains(WEST))
                regionSalesAgencyUserMap.put(WEST, u);
            if (u.userrole.developername.contains(SOUTH))
                regionSalesAgencyUserMap.put(SOUTH, u);
        }
        List<User> targetOwners = new List<User>();

        Set<Id> validSalesRepsId = new Set<ID>();

        //for(EUR_CRM_Account__c euAccount : euAccounts){
        for (AggregateResult ar : groupedResults) {
            String accountRegionDevName = (String) ar.get('dev');

            if (accountRegionDevName.contains(NORD) && regionSalesAgencyUserMap.get(NORD) != null && !validSalesRepsId.contains(regionSalesAgencyUserMap.get(NORD).id)) {
                targetOwners.add(regionSalesAgencyUserMap.get(NORD));
                validSalesRepsId.add(regionSalesAgencyUserMap.get(NORD).id);
            }
            if (accountRegionDevName.contains(WEST) && regionSalesAgencyUserMap.get(WEST) != null && !validSalesRepsId.contains(regionSalesAgencyUserMap.get(WEST).id)) {
                targetOwners.add(regionSalesAgencyUserMap.get(WEST));
                validSalesRepsId.add(regionSalesAgencyUserMap.get(WEST).id);
            }
            if (accountRegionDevName.contains(SOUTH) && regionSalesAgencyUserMap.get(SOUTH) != null && !validSalesRepsId.contains(regionSalesAgencyUserMap.get(SOUTH).id)) {
                targetOwners.add(regionSalesAgencyUserMap.get(SOUTH));
                validSalesRepsId.add(regionSalesAgencyUserMap.get(SOUTH).id);
            }

        }
        return targetOwners;
    }
    public static List<TargetWrap> retrieveTargetSpyder(
            Id objPromoId,
            List<EUR_CRM_ObjPromo_Target__c > subTargets,
            Id parentRecordTypeId,
            Id subTargetRecordTypeId,
            List<User> targetOwners,
            Id regionalManager,
            List<String> addtionalFields) {
        Map<Id, EUR_CRM_ObjPromo_Target__c> parentTargets = new Map<Id, EUR_CRM_ObjPromo_Target__c>();
        //EUR_CRM_Qty_Sell_in_Amount_Display__c, <<remove field
        //EUR_CRM_Target_Quantity_Promo_Kits__c  <<remove field
        String parentTargetsQuery = 'select id, EUR_CRM_ObjPromo__c, EUR_CRM_Target_Owner__c,EUR_CRM_Target_Owner__r.name  '
                + formatFields(addtionalFields)
                + 'from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =: objPromoId and recordtypeid =:parentRecordTypeId';

        if (regionalManager != null)
            parentTargetsQuery += ' AND EUR_CRM_Target_Owner__c =: regionalManager';

        for (EUR_CRM_ObjPromo_Target__c pTarget : (List<EUR_CRM_ObjPromo_Target__c>) Database.query(parentTargetsQuery)) {
            parentTargets.put(pTarget.id, pTarget);
        }

        Set<Id> parentKeySet = parentTargets.keySet();
        String subTargetsQuery = 'select id, EUR_CRM_ObjPromo__c, EUR_CRM_Target_Owner__c,EUR_CRM_Target_Owner__r.name '
                + formatFields(addtionalFields)
                + ' from EUR_CRM_ObjPromo_Target__c'
                + ' where EUR_CRM_ObjPromo__c =: objPromoId '
                + ' and EUR_CRM_O_P_Target__c in: parentKeySet and '
                + ' recordtypeid =: subTargetRecordTypeId';

        subTargets.addAll((List<EUR_CRM_ObjPromo_Target__c>) Database.query(subTargetsQuery));

//        Map<id, EUR_CRM_ObjPromo_Target__c> subTargetsMap = new Map<Id, EUR_CRM_ObjPromo_Target__c>(subTargets);

        System.debug(parentRecordTypeId);
        System.debug(objPromoId);

        System.debug(parentTargetsQuery);
        System.debug(parentTargets);
        System.debug(parentRecordTypeId);

        System.debug(subTargetsQuery);
        System.debug(subTargetRecordTypeId);
        system.debug('@subTargets' + subTargets);


        List<TargetWrap> targetWraps = new List<TargetWrap>();
        for (Id key : parentTargets.keySet()) {
            EUR_CRM_ObjPromo_Target__c target = parentTargets.get(key);
            List<EUR_CRM_ObjPromo_Target__c> subTargetsTemp = new List<EUR_CRM_ObjPromo_Target__c>();
            TargetWrap targetWrap = new TargetWrap(subTargetsTemp, target);
            for (User targetOwner : targetOwners) {
                //EUR_CRM_ObjPromo_Target__c subTarget = new EUR_CRM_ObjPromo_Target__c();
                //subTarget.EUR_CRM_ObjPromo__c = objPromoId;
                //subTarget.put('EUR_CRM_Target_Quantity_Spyders__c',target.get('EUR_CRM_Target_Quantity_Spyders__c'));
                //subTarget.EUR_CRM_Target_Quantity_Spyders__c = 0;
                //subTarget.EUR_CRM_O_P_Target__c = target.id;
                //subTarget.recordtypeid = subTargetRecordTypeId;
                //subTarget.EUR_CRM_Target_Owner__c = targetOwner.id;
                //subTargetsTemp.add(subTarget);
                for (EUR_CRM_ObjPromo_Target__c subT : subTargets) {
                    if (subT.EUR_CRM_Target_Owner__c == targetOwner.Id) {
                        subTargetsTemp.add(subT);
                        //subTargets.add(subT);
                    }
                }
            }
            System.Debug('>>>Target:' + targetWrap);
            targetWraps.add(targetWrap);
        }
        System.Debug('>>>Targets:' + targetWraps);
        return targetWraps;
    }

    public static List<TargetWrap> retrieveTargets(
            Id objPromoId,
            List<EUR_CRM_ObjPromo_Target__c > subTargets,
            Id parentRecordTypeId,
            Id subTargetRecordTypeId,
            String targetField,
            List<User> targetOwners,
            Id regionalManager,
            List<String> addtionalFields) {
        Map<Id, EUR_CRM_ObjPromo_Target__c> parentTargets = new Map<Id, EUR_CRM_ObjPromo_Target__c>();
        //EUR_CRM_Qty_Sell_in_Amount_Display__c, <<remove field
        //EUR_CRM_Target_Quantity_Promo_Kits__c  <<remove field
        String parentTargetsQuery = 'select id, EUR_CRM_ObjPromo__c, EUR_CRM_Target_Owner__c,EUR_CRM_Target_Owner__r.name  '
                + formatFields(addtionalFields)
                + 'from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =: objPromoId and recordtypeid =:parentRecordTypeId';

        if (regionalManager != null)
            parentTargetsQuery += ' AND EUR_CRM_Target_Owner__c =: regionalManager';

        for (EUR_CRM_ObjPromo_Target__c pTarget : (List<EUR_CRM_ObjPromo_Target__c>) Database.query(parentTargetsQuery)) {
            parentTargets.put(pTarget.id, pTarget);
        }

        Set<Id> parentKeySet = parentTargets.keySet();
        String subTargetsQuery = 'select id, EUR_CRM_ObjPromo__c, EUR_CRM_Target_Owner__c,EUR_CRM_Target_Owner__r.name '

                + formatFields(addtionalFields)
                + ' from EUR_CRM_ObjPromo_Target__c'
                + ' where EUR_CRM_ObjPromo__c =: objPromoId '
                + ' and EUR_CRM_O_P_Target__c in: parentKeySet and '
                + ' recordtypeid =: subTargetRecordTypeId';

        subTargets.addAll((List<EUR_CRM_ObjPromo_Target__c>) Database.query(subTargetsQuery));

        System.debug(parentRecordTypeId);
        System.debug(objPromoId);

        System.debug(parentTargetsQuery);
        System.debug(parentTargets);
        System.debug(parentRecordTypeId);

        System.debug(subTargetsQuery);
        System.debug(subTargetRecordTypeId);
        system.debug('@subTargets' + subTargets);

        Map<Id, Set<Id>> existingTargetMap = new Map<Id, Set<Id>>();
        for (EUR_CRM_ObjPromo_Target__c subTarget : subTargets) {
            if (existingTargetMap.get((ID) subTarget.get(targetField + '__c')) == null)
                existingTargetMap.put((ID) subTarget.get(targetField + '__c'), new Set<Id>());
            existingTargetMap.get((ID) subTarget.get(targetField + '__c')).add(subTarget.EUR_CRM_Target_Owner__c);
        }

        List<TargetWrap> targetWraps = new List<TargetWrap>();
        for (Id key : parentTargets.keySet()) {
            EUR_CRM_ObjPromo_Target__c target = parentTargets.get(key);
            List<EUR_CRM_ObjPromo_Target__c> subTargetsTemp = new List<EUR_CRM_ObjPromo_Target__c>();
            TargetWrap targetWrap = new TargetWrap(subTargetsTemp, target);
            Set<id> temp = existingTargetMap.get((ID) target.get(targetField + '__c'));
            for (User targetOwner : targetOwners) {
                system.debug('Flag');
                if (temp != null && temp.contains(targetOwner.id)) {
                    subTargetsTemp.add(retrieveTarget((ID) target.get(targetField + '__c'), targetOwner.id, subTargets, targetField));
                    system.debug('@@ Flag 1');
                } else {
                    system.debug('@@ Flag 2');
                    EUR_CRM_ObjPromo_Target__c subTarget = new EUR_CRM_ObjPromo_Target__c();
                    subTarget.EUR_CRM_ObjPromo__c = objPromoId;
                    subTarget.put(targetField + '__c', target.get(targetField + '__c'));
                    subTarget.putSObject(targetField + '__r', target.getSobject(targetField + '__r'));
                    subTarget.EUR_CRM_O_P_Target__c = target.id;
                    subTarget.recordtypeid = subTargetRecordTypeId;
                    subTarget.EUR_CRM_Target_Owner__c = targetOwner.id;
                    subTarget.EUR_CRM_Target_Owner__c = targetOwner.id;
                    // subTarget.EUR_CRM_Qty_Sell_in_Amount_Display__c = target.EUR_CRM_Qty_Sell_in_Amount_Display__c;
                    if (target.EUR_CRM_Promotion_Type__c != null)
                        subTarget.EUR_CRM_Promotion_Type__c = target.EUR_CRM_Promotion_Type__c;
                    if ('EUR_CRM_SKU' == targetField && target.EUR_CRM_Unit_of_Measure__c != null)
                        subTarget.EUR_CRM_Unit_of_Measure__c = target.EUR_CRM_Unit_of_Measure__c;
                    if ('EUR_CRM_SKU' == targetField && target.EUR_CRM_Grouping_Type__c != null)
                        subTarget.EUR_CRM_Grouping_Type__c = target.EUR_CRM_Grouping_Type__c;
                    subTargetsTemp.add(subTarget);
                    subTargets.add(subTarget);
                }
            }
            targetWraps.add(targetWrap);
        }
        return targetWraps;
    }
    /* 
    */
    public static List<TargetWrap> retrieveTargetsSKUnBQS(
            Id objPromoId,
            List<EUR_CRM_ObjPromo_Target__c > subTargets,
            Id parentRecordTypeId,
            Id subTargetRecordTypeId,
            List<User> targetOwners,
            Id regionalManager,
            List<String> addtionalFields) {
        Map<Id, EUR_CRM_ObjPromo_Target__c> parentTargets = new Map<Id, EUR_CRM_ObjPromo_Target__c>();
        String targetField = 'EUR_CRM_SKU';
        //EUR_CRM_Qty_Sell_in_Amount_Display__c, <<remove field
        //EUR_CRM_Target_Quantity_Promo_Kits__c  <<remove field
        String parentTargetsQuery = 'select id, EUR_CRM_ObjPromo__c, EUR_CRM_Target_Owner__c,EUR_CRM_Target_Owner__r.name  '
                + formatFields(addtionalFields)
                + 'from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =: objPromoId and recordtypeid =:parentRecordTypeId';

        if (regionalManager != null)
            parentTargetsQuery += ' AND EUR_CRM_Target_Owner__c =: regionalManager';

        for (EUR_CRM_ObjPromo_Target__c pTarget : (List<EUR_CRM_ObjPromo_Target__c>) Database.query(parentTargetsQuery)) {
            parentTargets.put(pTarget.id, pTarget);
        }

        Set<Id> parentKeySet = parentTargets.keySet();
        String subTargetsQuery = 'select id, EUR_CRM_ObjPromo__c, EUR_CRM_Target_Owner__c,EUR_CRM_Target_Owner__r.name '

                + formatFields(addtionalFields)
                + ' from EUR_CRM_ObjPromo_Target__c'
                + ' where EUR_CRM_ObjPromo__c =: objPromoId '
                + ' and EUR_CRM_O_P_Target__c in: parentKeySet and '
                + ' recordtypeid =: subTargetRecordTypeId';

        subTargets.addAll((List<EUR_CRM_ObjPromo_Target__c>) Database.query(subTargetsQuery));

        System.debug(parentRecordTypeId);
        System.debug(objPromoId);

        System.debug(parentTargetsQuery);
        System.debug(parentTargets);
        System.debug(parentRecordTypeId);

        System.debug(subTargetsQuery);
        System.debug(subTargetRecordTypeId);
        system.debug('@subTargets' + subTargets);

        Map<Id, Set<Id>> existingTargetMap = new Map<Id, Set<Id>>();
        for (EUR_CRM_ObjPromo_Target__c subTarget : subTargets) {
            If ((ID) subTarget.get('EUR_CRM_SKU__c') != null) {
                targetField = 'EUR_CRM_SKU';
            } Else If ((ID) subTarget.get('EUR_CRM_BQS__c') != null) {
                targetField = 'EUR_CRM_BQS';
            }

            if (existingTargetMap.get((ID) subTarget.get(targetField + '__c')) == null)
                existingTargetMap.put((ID) subTarget.get(targetField + '__c'), new Set<Id>());
            existingTargetMap.get((ID) subTarget.get(targetField + '__c')).add(subTarget.EUR_CRM_Target_Owner__c);
        }

        List<TargetWrap> targetWraps = new List<TargetWrap>();

        for (Id key : parentTargets.keySet()) {
            EUR_CRM_ObjPromo_Target__c target = parentTargets.get(key);
            List<EUR_CRM_ObjPromo_Target__c> subTargetsTemp = new List<EUR_CRM_ObjPromo_Target__c>();

            TargetWrap targetWrap = new TargetWrap(subTargetsTemp, target);

            If ((ID) target.get('EUR_CRM_SKU__c') != null) {
                targetField = 'EUR_CRM_SKU';
            } Else If ((ID) target.get('EUR_CRM_BQS__c') != null) {
                targetField = 'EUR_CRM_BQS';
            }

            Set<id> temp = existingTargetMap.get((ID) target.get(targetField + '__c'));

            for (User targetOwner : targetOwners) {
                system.debug('Flag');
                if (temp != null && temp.contains(targetOwner.id)) {
                    subTargetsTemp.add(retrieveTarget((ID) target.get(targetField + '__c'), targetOwner.id, subTargets));
                    system.debug('@@ Flag 1');
                } else {
                    system.debug('@@ Flag 2');
                    EUR_CRM_ObjPromo_Target__c subTarget = new EUR_CRM_ObjPromo_Target__c();
                    subTarget.EUR_CRM_ObjPromo__c = objPromoId;

                    subTarget.put(targetField + '__c', target.get(targetField + '__c'));
                    subTarget.putSObject(targetField + '__r', target.getSobject(targetField + '__r'));


                    subTarget.EUR_CRM_O_P_Target__c = target.id;
                    subTarget.recordtypeid = subTargetRecordTypeId;
                    subTarget.EUR_CRM_Target_Owner__c = targetOwner.id;
                    subTarget.EUR_CRM_Target_Owner__c = targetOwner.id;
                    // subTarget.EUR_CRM_Qty_Sell_in_Amount_Display__c = target.EUR_CRM_Qty_Sell_in_Amount_Display__c;
                    if (target.EUR_CRM_Promotion_Type__c != null)
                        subTarget.EUR_CRM_Promotion_Type__c = target.EUR_CRM_Promotion_Type__c;
                    if ('EUR_CRM_SKU' == targetField && target.EUR_CRM_Unit_of_Measure__c != null)
                        subTarget.EUR_CRM_Unit_of_Measure__c = target.EUR_CRM_Unit_of_Measure__c;
                    if ('EUR_CRM_SKU' == targetField && target.EUR_CRM_Grouping_Type__c != null)
                        subTarget.EUR_CRM_Grouping_Type__c = target.EUR_CRM_Grouping_Type__c;
                    subTargetsTemp.add(subTarget);
                    subTargets.add(subTarget);
                }
            }
            targetWraps.add(targetWrap);
        }
        return targetWraps;
    }

    private static String formatFields(List<String> fields) {
        String x = '';
        for (String f : fields) {
            x += ', ' + f + ' ';
        }
        return x;
    }
    private static EUR_CRM_ObjPromo_Target__c retrieveTarget(Id itemId, Id srId, List<EUR_CRM_ObjPromo_Target__c > subTargets) {

        EUR_CRM_ObjPromo_Target__c temp = null;
        for (EUR_CRM_ObjPromo_Target__c srTarget : subTargets) {
            if (((ID) srTarget.get('EUR_CRM_SKU__c') == itemId || (ID) srTarget.get('EUR_CRM_BQS__c') == itemId) && (srTarget.EUR_CRM_Target_Owner__c == srId)) {
                temp = srTarget;
                system.debug('@@ Flag 3 : SKU or BQS -->');
                break;
            }
        }
        return temp;
    }

    private static EUR_CRM_ObjPromo_Target__c retrieveTarget(Id skuId, Id srId, List<EUR_CRM_ObjPromo_Target__c > subTargets, String targetField) {

        EUR_CRM_ObjPromo_Target__c temp = null;
        for (EUR_CRM_ObjPromo_Target__c srTarget : subTargets) {
            if ((ID) srTarget.get(targetField + '__c') == skuId && (srTarget.EUR_CRM_Target_Owner__c == srId)) {
                temp = srTarget;
                system.debug('@@ Flag 3 -->');
                break;
            }
        }
        return temp;
    }


    public class TargetWrap {

        public EUR_CRM_ObjPromo_Target__c target { get; set; }
        public List<EUR_CRM_ObjPromo_Target__c> srTargets { get; set; }

        public TargetWrap(List<EUR_CRM_ObjPromo_Target__c> srTargets, EUR_CRM_ObjPromo_Target__c target) {
            this.target = target;
            this.srTargets = srTargets;
        }

        public Boolean getIsCarton() {
            return this.target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c.contains('Carton');
        }

        public Boolean getIsDisplay() {
            return this.target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c.contains('Display');
        }

        public Boolean getisBottle() {
            return this.target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c.contains('Bottle');
        }

        public Boolean getIsSKU() {
            return this.target.EUR_CRM_SKU__c == null;
        }

        public Boolean getISBQS() {
            return this.target.EUR_CRM_BQS__c == null;
        }

        public Boolean getQtyPromoKitMatched() {
            if (target != null) {
                Decimal total = getSubTargetPromoKitTotal();
                System.Debug('Total PromoKit:' + total + ':' + target.EUR_CRM_Target_Quantity_Promo_Kits__c);
                if (target.EUR_CRM_Target_Quantity_Promo_Kits__c <= total) {
                    return false;  //MATCH!!!!
                } else {
                    return true;
                }

            }
            return false; //NOT MATCH!!!!
        }

        public Boolean getQtyPromoKitMatchedExactly() {
            if (target != null) {
                Decimal total = getSubTargetPromoKitTotal();
                System.Debug('Total PromoKit:' + total + ':' + target.EUR_CRM_Target_Quantity_Promo_Kits__c);
                if (target.EUR_CRM_Target_Quantity_Promo_Kits__c == total) {
                    return false;  //MATCH!!!!
                } else {
                    return true;
                }

            }
            return false; //NOT MATCH!!!!
        }

        public Boolean getVolumeSpyderMatched() {
            if (target != null) {
                Decimal total = getSubTargetSpyderTotal();

                if (target.EUR_CRM_Target_Quantity_Spyders__c <= total) {
                    return false;  //MATCH!!!!-
                } else {
                    return true;
                }
            }

            return false; //NOT MATCH!!!!
        }

        public Boolean getVolumeSpyderMatchedExactly() {
            if (target != null) {
                Decimal total = getSubTargetSpyderTotal();

                if (target.EUR_CRM_Target_Quantity_Spyders__c == total) {
                    return false;  //MATCH!!!!-
                } else {
                    return true;
                }
            }

            return false; //NOT MATCH!!!!
        }

        public Boolean getVolumeBottleMatched() {
            if (target != null) {
                Decimal total = getSubTargetBottleTotal();
                if (target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c <= total) {
                    return false; //MATCH!!!!
                } else {
                    return true;  //NOT MATCH!!!!
                }
            }
            return false;
        }

        public Boolean getVolumeBottleMatchedexactly() {
            if (target != null) {
                Decimal total = getSubTargetBottleTotal();
                System.Debug('getVolumeBottleMatchedexactly:' + target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c + ':' + total);
                if (target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == total) {
                    return false; //MATCH!!!!
                } else {
                    return true;  //NOT MATCH!!!!
                }
            }
            return true;
        }

        public Boolean getTargetListingMatched() {
            if (target != null) {
                Decimal total = getSubTargetListingTotal();
                if (target.EUR_CRM_Target_Quantity_Listing__c <= total) {
                    return false; //MATCH!!!!
                } else {
                    return true;  //NOT MATCH!!!!
                }
            }
            return false;
        }

        public Boolean getTargetVisitMatched() {
            System.debug('getTargetVisitMatched');
            System.debug('target == null => ' + target == null);
            System.debug('target ' + JSON.serializePretty(target));
            if (target != null) {
                Decimal total = getSubTargetVisitTotal();
                if (target.EUR_CRM_Visit_Targets__c <= total) {
                    return false; //MATCH!!!!
                } else {
                    return true;  //NOT MATCH!!!!
                }
            }
            return false;
        }

        public Boolean getTargetPeopleMatched() {
            System.debug('getTargetPeopleMatched');
            System.debug('target == null => ' + target == null);
            System.debug('target ' + JSON.serializePretty(target));
            if (target != null) {
                Decimal total = getSubTargetPeopleTotal();
                if (target.EUR_CRM_Target_Quantity_People__c <= total) {
                    return false; //MATCH!!!!
                } else {
                    return true;  //NOT MATCH!!!!
                }
            }
            return false;
        }

        //NOT MATCH RETURN TRUE!!!
        public Boolean getVolumeDisplayMatchedExactly() {
            System.debug('getVolumeDisplayMatchedExactly');
            System.debug('target == null => ' + target == null);
            System.debug('target ' + JSON.serializePretty(target));

            //return getVolumeBottleMatchedExactly();
            if (target != null) {
                Decimal total = getSubTargetDisplayTotal();

                if (target.EUR_CRM_Qty_Sell_in_Amount_Display__c == total) {
                    return false;  //MATCH!!!!-
                } else {
                    return true;
                }
            }

            return false; //NOT MATCH!!!!
        }

        public Boolean getVolumeDisplayMatched() {

            return getVolumeBottleMatched();
        }

        public Boolean getEverythingMatched() {
            return getVolumeBottleMatched() && getTargetListingMatched() && getTargetVisitMatched() && getTargetPeopleMatched();
        }

        public Boolean getVolumeBottleAchieved() {
            Decimal total = 0;
            if (srTargets != null && srTargets.size() > 0)
                for (EUR_CRM_ObjPromo_Target__c sTarget : srTargets) {
                    Decimal stotal = sTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == null ? 0 : sTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c;
                    total += stotal;
                }
            if (target != null && target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c > total)
                return true;
            return false;
        }

        public Boolean getVolumeBottleNotOverlimit() {
            if (target == null) {
                return false;
            }
            Decimal total = 0;
            Decimal goal = target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == null ? 0 : target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c;
            if (srTargets != null && srTargets.size() > 0) {
                for (EUR_CRM_ObjPromo_Target__c sTarget : srTargets) {
                    Decimal stotal = sTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == null ? 0 : sTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c;
                    total += stotal;
                }
            }
            if (goal >= total) {
                return true;
            } else {
                return false;
            }
        }

        public Boolean getVolumeDisplayNotOverlimit() {
            if (target == null) {
                return false;
            }
            Decimal total = 0;
            Decimal goal = target.EUR_CRM_Qty_Sell_in_Amount_Display__c == null ? 0 : target.EUR_CRM_Qty_Sell_in_Amount_Display__c;
            if (srTargets != null && srTargets.size() > 0) {
                for (EUR_CRM_ObjPromo_Target__c sTarget : srTargets) {
                    Decimal stotal = sTarget.EUR_CRM_Qty_Sell_in_Amount_Display__c == null ? 0 : sTarget.EUR_CRM_Qty_Sell_in_Amount_Display__c;
                    total += stotal;

                }
            }
            if (goal >= total) {
                return true;
            } else {
                return false;
            }
        }

        public Boolean getVolumeDisplayAchieved() {
            Decimal total = 0;
            if (srTargets != null && srTargets.size() > 0)
                for (EUR_CRM_ObjPromo_Target__c sTarget : srTargets) {
                    Decimal stotal = sTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == null ? 0 : sTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c;
                    total += stotal;

                }
            if (target != null && target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c > total)
                return true;
            return false;
        }

        public Decimal getSubTargetListingTotal() {
            Decimal total = 0;
            if (srTargets != null && srTargets.size() > 0)
                for (EUR_CRM_ObjPromo_Target__c sTarget : srTargets) {
                    Decimal stotal = sTarget.EUR_CRM_Target_Quantity_Listing__c == null ? 0 : sTarget.EUR_CRM_Target_Quantity_Listing__c;
                    total += stotal;
                }
            return total;
        }

        public Decimal getSubTargetVisitTotal() {
            Decimal total = 0;
            if (srTargets != null && srTargets.size() > 0)
                for (EUR_CRM_ObjPromo_Target__c sTarget : srTargets) {
                    Decimal stotal = sTarget.EUR_CRM_Visit_Targets__c == null ? 0 : sTarget.EUR_CRM_Visit_Targets__c;
                    total += stotal;
                }
            return total;
        }

        public Decimal getSubTargetPeopleTotal() {
            Decimal total = 0;
            if (srTargets != null && srTargets.size() > 0)
                for (EUR_CRM_ObjPromo_Target__c sTarget : srTargets) {
                    Decimal stotal = sTarget.EUR_CRM_Target_Quantity_People__c == null ? 0 : sTarget.EUR_CRM_Target_Quantity_People__c;
                    total += stotal;
                }
            return total;
        }

        public Decimal getSubTargetSpyderTotal() {
            Decimal total = 0;
            if (srTargets != null && srTargets.size() > 0)
                for (EUR_CRM_ObjPromo_Target__c sTarget : srTargets) {
                    Decimal stotal = sTarget.EUR_CRM_Target_Quantity_Spyders__c == null ? 0 : sTarget.EUR_CRM_Target_Quantity_Spyders__c;
                    total += stotal;
                }
            return total;
        }

        public Decimal getSubTargetPromoKitTotal() {
            Decimal total = 0;
            if (srTargets != null && srTargets.size() > 0)
                for (EUR_CRM_ObjPromo_Target__c sTarget : srTargets) {
                    Decimal stotal = sTarget.EUR_CRM_Target_Quantity_Promo_Kits__c == null ? 0 : sTarget.EUR_CRM_Target_Quantity_Promo_Kits__c;
                    total += stotal;
                }
            return total;
        }

        public Decimal getSubTargetBottleTotal() {
            Decimal total = 0;
            if (srTargets != null && srTargets.size() > 0)
                for (EUR_CRM_ObjPromo_Target__c sTarget : srTargets) {
                    Decimal stotal = sTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == null ? 0 : sTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c;
                    total += stotal;
                }
            return total;
        }

        public Decimal getSubTargetDisplayTotal() {
            Decimal total = 0;
            if (srTargets != null && srTargets.size() > 0)
                for (EUR_CRM_ObjPromo_Target__c sTarget : srTargets) {
                    Decimal stotal = sTarget.EUR_CRM_Qty_Sell_in_Amount_Display__c == null ? 0 : sTarget.EUR_CRM_Qty_Sell_in_Amount_Display__c;
                    total += stotal;
                }
            return total;
        }

        public Boolean getQuantityMatched() {
            if (target != null) {
                Decimal total = getSubTargetQuantityTotal();

                if (target.EUR_CRM_Target_Quantity_Promo_Kits__c != total) {
                    return true;
                }
            }

            return false;
        }

        public Boolean getQuantityAchieved() {
            Decimal total = 0;
            if (srTargets != null && srTargets.size() > 0)
                for (EUR_CRM_ObjPromo_Target__c sTarget : srTargets) {
                    Decimal stotal = sTarget.EUR_CRM_Target_Quantity_Promo_Kits__c == null ? 0 : sTarget.EUR_CRM_Target_Quantity_Promo_Kits__c;
                    total += stotal;

                }
            if (target != null && target.EUR_CRM_Target_Quantity_Promo_Kits__c > total)
                return true;
            return false;
        }

        public Decimal getSubTargetQuantityTotal() {
            Decimal total = 0;
            if (srTargets != null && srTargets.size() > 0)
                for (EUR_CRM_ObjPromo_Target__c sTarget : srTargets) {
                    Decimal stotal = sTarget.EUR_CRM_Target_Quantity_Promo_Kits__c == null ? 0 : sTarget.EUR_CRM_Target_Quantity_Promo_Kits__c;
                    total += stotal;
                }
            return total;
        }
    }


    public static Set<Id> retrieveCustomerTaxonomySet(Id opHeaderId) {
        Set<Id> taxonomyIds = new Set<Id>();
        for (EUR_CRM_OP_Customer_Taxonomy_Mapping__c x : [select EUR_CRM_Customer_Taxonomy__c from EUR_CRM_OP_Customer_Taxonomy_Mapping__c where EUR_CRM_ObjPromo__c = :opHeaderId]) {
            taxonomyIds.add(x.EUR_CRM_Customer_Taxonomy__c);
        }
        return taxonomyIds;
    }

    public static Set<Id> retrieveAccountsByOPAccountMapping(Id opHeaderId) {
        Set<Id> accountIds = new Set<Id>();
        for (EUR_CRM_ObjPromo_Account_Mapping__c opAccountMapping : [
                SELECT EUR_CRM_Account__c
                FROM EUR_CRM_ObjPromo_Account_Mapping__c
                WHERE EUR_CRM_ObjPromo__c = :opHeaderId
        ]) {

            accountIds.add(opAccountMapping.EUR_CRM_Account__c);
        }

        return accountIds;
    }
}