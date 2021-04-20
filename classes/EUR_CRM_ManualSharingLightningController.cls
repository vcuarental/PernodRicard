/**
 * Created by V. Kamenskyi on 19.09.2017. 
 */
public with sharing class EUR_CRM_ManualSharingLightningController {

    @AuraEnabled
    public static Object getShareRecords(Id parentId) {
        
        List<Object> records = Database.query(getShareRecordsQuery(parentId));
        // make a list not tied to any concrete type
        List<Object> recs = new List<Object>();
        
        Set<Id> grpIds = new Set<Id>();
        for(sObject rec :(List<sObject>)records){
            Id grpId = (Id)rec.get('UserOrGroupId');
            if(!String.isEmpty(grpId)){
                grpIds.add(grpId);
            }
        }
        // query relevant groups
        Map<Id,Group> groups = new Map<Id,Group>([SELECT Id, Name,RelatedId,Type,Related.Name FROM Group WHERE RelatedId IN (SELECT Id FROM userRole) AND Id IN :grpIds]);
        
        for(Integer i = 0; i<records.size(); i++){
            Object rec = records[i];
            sObject record = (sObject)rec;
            if(record.getSObject('UserOrGroup') != null ){
                Group gr = groups.get((Id)record.get('UserOrGroupId'));
                if(gr != null){
                    // create representation of the object as a simple map,
                    // as we cant set name directry to group, and there is no 
                    // UserOrGroupName field on actual share sObject
                    // clone the representation as map returned by getPopulatedFieldsAsMap is final
                    Map<String, Object> rec1 = (Map<String, Object>)record.getPopulatedFieldsAsMap().clone();
                    // overrite non-existant field on share with Role name to be
                    // shown on layout
                    rec1.put('UserOrGroupName',gr.Related.Name);
                    Map<String, Object> ugr = (Map<String, Object>)record.getSObject('UserOrGroup').getPopulatedFieldsAsMap().clone();
                    // overwrite type of 'Queue' to actual group type
                    if(gr.Type == 'RoleAndSubordinates'){
                        ugr.put('Type', Label.EUR_CRM_RolesAndSubordinates);
                    } else if(gr.Type == 'Role') {
                        ugr.put('Type', Label.EUR_CRM_Roles);                        
                    } else {
                        ugr.put('Type', gr.Type);
                    }
                    // inject related role id prop
                    rec1.put('RoleId',gr.RelatedId);
                    rec1.put('UserOrGroup',ugr);
                    
                    // overwrite real record with doctored record
                    rec = rec1;
                }
            } 
            // mix and match doctored role/queue shares and real shares for users
            // into non-concrete object list
            recs.add(rec);
        }

        return new Map<String, Object>{
                'records' => recs
                , 'allReasons' => getAllReasons(parentId)
                , 'reasons' => getReasons(parentId)
                , 'accessLevels' => new Map<String, String>{
                    'edit' => Label.EUR_CRM_ReadWrite
                    , 'read' => Label.EUR_CRM_ReadOnly
                }
        };
    }

    public static String getShareRecordsQuery(String parentId) {
        return 'SELECT Id' +
                    ', UserOrGroupId' +
                    ', UserOrGroup.Name' +
                    ', toLabel(UserOrGroup.Type)' +
                    ', toLabel(AccessLevel)' +
                    ', RowCause' +
                ' FROM ' + getShareObjectName(parentId) +
                ' WHERE ParentId = :parentId';
    }
 
    @AuraEnabled
    public static Object getSharingSubjects(String searchTerm) {
        
        if(String.isEmpty(searchTerm)){
            return new Map<String, List<SObject>>{
                'users' => [SELECT Id, Name FROM User WHERE IsActive = TRUE AND UserType = 'Standard' ORDER BY Name ASC LIMIT 50]
                , 'groups' => [SELECT Id, Name, DeveloperName FROM Group WHERE Name LIKE '%' AND Type != 'Queue' ORDER BY Name ASC LIMIT 50]
                , 'roles' => [SELECT Id, Name, RelatedId,Type, Related.Name FROM Group WHERE RelatedId IN (SELECT Id FROM userRole) AND Type = 'Role' LIMIT 50]
                , 'rolesAndSubordinates' => [SELECT Id, Name, RelatedId,Type, Related.Name FROM Group WHERE RelatedId IN (SELECT Id FROM userRole) AND Type = 'RoleAndSubordinates' LIMIT 50]
        	};
         } else {
             searchTerm = String.escapeSingleQuotes(searchTerm);
             searchTerm = '%'+searchTerm+'%';
             return new Map<String, List<SObject>>{
                'users' => [SELECT Id, Name FROM User WHERE IsActive = TRUE AND UserType = 'Standard' AND Name LIKE :searchTerm ORDER BY Name ASC LIMIT 50]
                , 'groups' => [SELECT Id, Name, DeveloperName FROM Group WHERE Name LIKE :searchTerm AND Type != 'Queue' ORDER BY Name ASC LIMIT 50]
                , 'roles' => [SELECT Id, Name, RelatedId,Type, Related.Name FROM Group WHERE RelatedId IN (SELECT Id FROM userRole) AND Type = 'Role' AND Related.Name LIKE :searchTerm LIMIT 50]
                , 'rolesAndSubordinates' => [SELECT Id, Name, RelatedId,Type, Related.Name FROM Group WHERE RelatedId IN (SELECT Id FROM userRole) AND Type = 'RoleAndSubordinates' AND Related.Name LIKE :searchTerm LIMIT 50]
        	};
         }
        
    }

    @AuraEnabled
    public static String setSharing(Id parentId, List<Id> userOrGroupIds, String accessLevel, String reason) {
        Database.SaveResult[] sr;
        Type shareObjectType = Type.forName(getShareObjectName(parentId));
        Set<Id> idSet = new Set<Id>(userOrGroupIds);
        /*
        if (shareObjectType == EUR_CRM_Deal__share.class) { // animation
            sr = new Animation(parentId).createSharing(idSet, accessLevel, reason);
            return JSON.serialize(sr);
        } else 
        */
        if(shareObjectType == EUR_CRM_ProductCatalog__Share.class) {
            EUR_CRM_CatalogCreationService.updateSharedRecords(parentId);
        } else if(shareObjectType == EUR_CRM_Account_Target_Group__Share.class){
            // update target account group, so it is pulled in to mobile
            /* TODO: check if needed
            EUR_CRM_Account_Target_Group__c ag = new EUR_CRM_Account_Target_Group__c(Id = parentId);
            update ag;
            // update related objects to force mobile syncing
            List<EUR_CRM_Account_in_Target_Group__c> acinGrps = new List<EUR_CRM_Account_in_Target_Group__c>([SELECT Id FROM EUR_CRM_Account_in_Target_Group__c WHERE EUR_CRM_AccountGroup__c  = :ag.Id]);
            if(!acinGrps.isEmpty()){
                update acinGrps;
            }
            */
        } 
        
        DescribeSObjectResult dsr = parentId.getSobjectType().getDescribe();
        String parentIdName = dsr.isCustom() ? 'ParentId' : dsr.getName() + 'Id';
        List<SObject> shares = new List<SObject>();
        for (Id userOrGroupId : userOrGroupIds) {
            SObject share = (SObject) shareObjectType.newInstance();
            share.put('UserOrGroupId', userOrGroupId);
            share.put('AccessLevel', accessLevel);
            share.put(parentIdName, parentId);
            if (String.isNotEmpty(reason)) {
                share.put('RowCause', reason);
            }
            shares.add(share);
        }
        sr = Database.insert(shares, false);
        return JSON.serialize(sr);
    }

    @AuraEnabled
    public static String removeSharing(Id parentId, List<Id> userOrGroupIds) {
        Database.DeleteResult[] dr;
        Type shareObjectType = Type.forName(getShareObjectName(parentId));
        Set<Id> idSet = new Set<Id>(userOrGroupIds);
        /* TODO: check if needed
        if (shareObjectType == EUR_CRM_Deal__share.class) {
            dr = new Animation(parentId).removeSharing(idSet);
            return JSON.serialize(dr);
        } else 
        */
        if(shareObjectType == EUR_CRM_ProductCatalog__Share.class) {
            EUR_CRM_CatalogCreationService.updateSharedRecords(parentId);
        } 
        
        DescribeSObjectResult dsr = parentId.getSobjectType().getDescribe();
        String parentIdName = dsr.isCustom() ? 'ParentId' : dsr.getName() + 'Id';
        String query = 'SELECT Id FROM ' + shareObjectType.getName() + ' WHERE ' + parentIdName + ' = :parentId AND UserOrGroupId IN :userOrGroupIds';
        dr = Database.delete(Database.query(query), false);
        return JSON.serialize(dr);
    }

    @AuraEnabled
    public static Object getInitValues(String shareObjectType) {
        Map<String, SObjectField> fieldMap = Schema.getGlobalDescribe().get(shareObjectType).getDescribe().fields.getMap();
        return new Map<String, Object>{
                'reasons' => getCustomReasons(fieldMap.get('rowcause'))
                , 'allReasons' => getAllCustomReasons(fieldMap.get('rowcause'))
                , 'accessLevels' => new Map<String, String>{
                        'edit' => Label.EUR_CRM_ReadWrite
                        , 'read' => Label.EUR_CRM_ReadOnly
                }
                , 'userType' => Schema.User.SObjectType.getDescribe().getLabel()
                , 'groupType' => Schema.Group.SObjectType.getDescribe().getLabel()
                , 'userId' => UserInfo.getUserId()
        };
    }

    private static List<PicklistEntry> getReasons(Id parentId) {
        SObjectField f = Schema.getGlobalDescribe().get(getShareObjectName(parentId)).getDescribe().fields.getMap().get('rowcause');
        return getCustomReasons(f);
    }

    private static List<PicklistEntry> getCustomReasons(SObjectField f) {
        List<PicklistEntry> result = new List<PicklistEntry>();
        for (Schema.PicklistEntry ple : f.getDescribe().getPicklistValues()) {
            if (ple.value.endsWith('__c') || ple.value.equalsIgnoreCase('manual')) {
                result.add(new PicklistEntry(ple.value, ple.label));
            }
        }
        return result;
    }

    private static Map<String, String> getAllReasons(Id parentId) {
        SObjectField f = Schema.getGlobalDescribe().get(getShareObjectName(parentId)).getDescribe().fields.getMap().get('rowcause');
        return getAllCustomReasons(f);
    }

    private static Map<String, String> getAllCustomReasons(SObjectField f) {
        Map<String, String> result = new Map<String, String>();
        for (Schema.PicklistEntry ple : f.getDescribe().getPicklistValues()) {
            result.put(ple.value, ple.label);
        }
        return result;
    }

    private static String getShareObjectName(Id parentId) {
        SObjectType objType = parentId.getSobjectType();
        DescribeSObjectResult descr = objType.getDescribe();
        return descr.isCustom()
                ? descr.getName().removeEnd('__c') + '__share'
                : descr.getName() + 'Share';
    }

    class PicklistEntry {
        @AuraEnabled
        String value {get;set;}
        @AuraEnabled
        String label {get; set;}
        PicklistEntry(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
}