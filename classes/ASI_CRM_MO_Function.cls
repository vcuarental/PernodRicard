/*********************************************************************************
 * Name: ASI_CRM_MO_Function
 * Description: General Functions for PRMO CRM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 2015-03-26       Daniel WONG             Initial
 *********************************************************************************/
public without sharing class ASI_CRM_MO_Function{

    public static Map<String, Set<id>> getMOGroup(){ 
        Map<String, Set<id>> mapMOGroup_user = new Map<String, Set<Id>>();
        
        for(GroupMember i :[
                SELECT Group.DeveloperName,  UserOrGroupId 
                FROM GroupMember 
                WHERE GroupId IN (SELECT Id FROM Group WHERE DeveloperName LIKE 'ASI_CRM_MO%')  //'ASI_CRM_MO_StandardUser')
            ]){
            Set<Id> uid = new Set<Id>();
                
            if(mapMOGroup_user.get(i.Group.DeveloperName) != NULL)
                uid = mapMOGroup_user.get(i.Group.DeveloperName);
            uid.add(i.UserOrGroupId);
            
            mapMOGroup_user.put(i.Group.DeveloperName, uid);
        }
        system.debug('mapMOGroup_user : ' + mapMOGroup_user);
        return mapMOGroup_user;
    }
    
    public static Boolean isGroupMember(Id uid, String gName, Map<String, Set<id>> MOGroup){
        Map<String, Set<Id>> mapMOGroup_user = MOGroup;
        Set<Id> setRoleId = new Set<Id>();
        Set<Id> roleRelatedGroupIds = new Set<Id>();
        
        //uid = (ID) string.valueof(uid).left(15);
        system.debug('isGroupMember-------------------------------' + uid);
        if(mapMOGroup_user.get(gName) != NULL){
            if(mapMOGroup_user.get(gName).CONTAINS(uid))
                return TRUE;
        }
        
        // CHECK User Role
        for(User r : [SELECT id, UserRoleId FROM User WHERE Id = :uid]){
            setRoleId.add(r.UserRoleId);
        }
        system.debug('setRoleId :' + setRoleId);
        
        if(setRoleId.size() > 0) {
            for(Group g : [SELECT id, RelatedId, Type FROM Group where RelatedId IN :setRoleId]){
                roleRelatedGroupIds.add(g.id);
            }
        }
        system.debug('isGroupMember-------------------------------' + setRoleId);
        for(Id rid : roleRelatedGroupIds){
            if(mapMOGroup_user.get(gName) != NULL){
                system.debug('mapMOGroup_user.get(gName) : ' + mapMOGroup_user.get(gName));
                system.debug('rid :' + rid);
                if(mapMOGroup_user.get(gName).CONTAINS(rid))
                    return TRUE;
            }
        }
        return FALSE;
    }
    
    public static Map<Id, Boolean> isGroupMemberSet(set<Id> uid, String gName, Map<String, Set<id>> MOGroup){
        map<id, boolean> mapUserGroup = new map<id, boolean>();
        
        return mapUserGroup;
    }
    
    private static set<string> m_BypassedTriggers = null;
    public static set<string> BypassedTriggers {
        get {
            if(m_BypassedTriggers==null) {
                m_BypassedTriggers = new set<String>();
                list<User> users = [SELECT Id, BypassTriggers__c FROM User WHERE Id = :UserInfo.getUserId()];
                System.debug(users[0]);
                if (users.size() > 0 && users[0].BypassTriggers__c != null) {
                    String bypassTriggerWholeStr = users[0].BypassTriggers__c;                    
                    List<String> bypassTriggerStrs = bypassTriggerWholeStr.split(';', 0);
                    System.debug(bypassTriggerStrs );
                    for (String bypassTriggerStr : bypassTriggerStrs) {
                    system.debug(bypassTriggerStr.toLowerCase());
                        m_BypassedTriggers.add(bypassTriggerStr.toLowerCase());
                    }
                }
            }    
            return m_BypassedTriggers;
        }
    }
    
    public static boolean IsBypassTrigger(string triggerKey) {
        set<string> tempBypassedTriggers = BypassedTriggers;
        system.debug(tempBypassedTriggers);
        system.debug(triggerKey);
        return tempBypassedTriggers!=null && tempBypassedTriggers.contains(triggerKey.toLowerCase());
    }
}