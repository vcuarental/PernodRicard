public without sharing class ASI_MFM_Function {
    
    public class MFMException extends Exception {}
    
    public static integer callout_count = 0;
    
    private static map<Id, User> MUserID = new map<Id, User>();
    private static list<user> LUser = new list<user>();
    
    private static Set<String> bypassTriggersCache = new Set<String>();
    
    private static List<User> users = [SELECT Id, BypassTriggers__c FROM User WHERE Id = :UserInfo.getUserId()];//20170112 Elufa
        
    static{
        LUser = [select ASI_MFM_Bypass_Callouts__c from user where ASI_MFM_Bypass_Callouts__c = true];
        
        MUserID = new Map<id,user>(LUser);
        for(User u : LUser){
            MUserID.put(u.id,u);
        }
        
        //Constructor for ByPassTriggerCache
        ID bypassUserId;
        ID curUserId = UserInfo.getUserId();
        if (curUserId != bypassUserId || bypassTriggersCache == null) {
          //List<User> users = [SELECT Id, BypassTriggers__c FROM User WHERE Id = :curUserId]; 20170112 Elufa commented to reduce soql
          if (users.size() > 0 && users[0].BypassTriggers__c != null) {
            String bypassTriggerWholeStr = users[0].BypassTriggers__c;
            List<String> bypassTriggerStrs = bypassTriggerWholeStr.split(';', 0);
            for (String bypassTriggerStr : bypassTriggerStrs) {
              bypassTriggersCache.add(bypassTriggerStr.toLowerCase());
            }
          }
        }
    }
        
    public static boolean bypassCallouts() {
        //Modified by Michael (Introv) 9Apr2014 for too many soql in test class
        if(test.isRunningTest()){
            return false;
        }
        else{
            //Modified by Michael (Introv) 13Aug2014 for reducing soql
            //return [select ASI_MFM_Bypass_Callouts__c from user where id = :userInfo.getUserId()].ASI_MFM_Bypass_Callouts__c;
            Boolean bypass = false;
            if(MUserID.containsKey(UserInfo.getUserId())){
                bypass = true;
            }
            return bypass;
        }
    }
   
   //Added by Wilken on 20140924, re-use GlobalRecordTypeCache to reduce SOQL
    public static Boolean bypassTriggersFunctionCache(string bypassTriggerKey ) {
        return bypassTriggersCache.contains(bypassTriggerKey.toLowerCase());
    }   
    public static Boolean bypassTriggersFunction(string bypassTriggerKey ) {
        Set<String> bypassTriggers;
        ID bypassUserId;
        ID curUserId = UserInfo.getUserId();
        if (curUserId != bypassUserId || bypassTriggers == null) {
          bypassTriggers = new Set<String>();
          //List<User> users = [SELECT Id, BypassTriggers__c FROM User WHERE Id = :curUserId]; //20170112 Elufa Commented to reduce soql
          if (users.size() > 0 && users[0].BypassTriggers__c != null) {
            String bypassTriggerWholeStr = users[0].BypassTriggers__c;
            List<String> bypassTriggerStrs = bypassTriggerWholeStr.split(';', 0);
            for (String bypassTriggerStr : bypassTriggerStrs) {
              bypassTriggers.add(bypassTriggerStr.toLowerCase());
            }
          }
        }
        return bypassTriggers.contains(bypassTriggerKey.toLowerCase());
    }
    
    public static string buildQuery(string sobject_name, string additional_fields, string relationship_name) {
        string q = 'select '; 
        boolean start = true;             
        for (string f:schema.getGlobalDescribe().get(sobject_name).getDescribe().fields.getMap().keySet()) {
            if (start) {
                q += f;
                start = false;
            }
            else {
                q += ', ' + f;
            }
        }
        if (additional_fields != null) {
            q += ', ' + additional_fields;
        }
        q += ' from ';
        if (relationship_name != null) {
            q += relationship_name;
        }
        else {
            q += sobject_name;
        }        
        return q;
    }
    
    public static string buildQuery(string sobject_name, string additional_fields) {
        return buildQuery(sobject_name, additional_fields, null);
    }
        
    public static string buildQuery(string sobject_name) {
        return buildQuery(sobject_name, null);
    }

    public static void displayCalloutCount(string action) {
        callout_count++;
        system.debug('Callout to DWI for ' + action + ' request');
        system.debug('Callout count = ' + callout_count);
    }

    public static string getFieldId(string sobject_name, string field_name) {
        string field_id;
        for (ASI_MFM_Field_ID_Mappings__c fmp:ASI_MFM_Field_ID_Mappings__c.getAll().values()) {
            if (fmp.ASI_MFM_Object_Name__c == sobject_name && fmp.ASI_MFM_Field_Name__c == field_name) {
                field_id = fmp.ASI_MFM_Field_ID__c;
                break;
            }
        }
        return field_id;
    }

    public static decimal getPercentage(string percentage_code) {
        if (percentage_code != null) {
            string percentage_x = percentage_code.substringAfter('(').substringBefore('%').trim();
            if (percentage_x != null && percentage_x.containsOnly('1234567890.')) {
                return decimal.valueOf(percentage_x)/100;
            }
            else {
                return null;
            }
        }
        else {
            return null;
        }
    }

    public static map<string, id> getRecordTypeId(string object_type) {
        map<string, id> rt_map = new map<string, id>();
        for (recordType rt:[select id, DeveloperName from recordType where SobjectType = :object_type]) {
            rt_map.put(rt.DeveloperName, rt.id);            
        }
        return rt_map;
    }
    
    public static void updatePrefix(list<asi_mfm_prefix__c> px_list) {
        update px_list;
    }
    
    public static boolean containsDecimalValue(decimal d)
    {
        if (d == null)
            return false;
        
        decimal c = d- d.intValue();
        if (c == 0)
            return false;
        else
            return true;
    }
    
    

    //// START: FOR TEST    
    
    public static Id CreateFakeId(Schema.SObjectType sObjectType, integer seed) {
        String result = String.valueOf(seed);
        return sObjectType.getDescribe().getKeyPrefix() + '0'.repeat(12-result.length()) + result;
    }
    
    public static Id checkRecordType(string strsobject, string rt_name){
        id RT_id;
        List<recordType> sobjectlist = Global_RecordTypeCache.getRtList(strsobject);
        for (recordtype rt : sobjectlist ){
            if (rt.developername == rt_name)
                return rt.id;
        }
        return null;
    }

    public static User getSystemAdminUser(){      
        list<User> usersAdmin = [SELECT Id, Name, Managerid, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User 
                            WHERE Profile.Name like '%System Administrator' AND IsActive = TRUE order by id asc
                            LIMIT 1];      
        return usersAdmin.size()>0 ? usersAdmin[0] : null;
    }
 /*   
    public static User getManagerCN(){
        list<User> users = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName
                            FROM User 
                            WHERE Profile.Name = 'ASI CN Standard User' AND UserRole.DeveloperName = 'ASI_CN_NTMK_Merchandizing_SM' AND isActive = TRUE
                            LIMIT 1];      
        return users.size()>0 ? users[0] : null;
    }

    public static User getUserCN(){      
        list<User> users = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE Profile.Name ='ASI CN Standard User' AND isActive = TRUE
                            LIMIT 1];      
        return users.size()>0 ? users[0] : null;
    }

*/    
    //// END: FOR TEST    
    
     
}