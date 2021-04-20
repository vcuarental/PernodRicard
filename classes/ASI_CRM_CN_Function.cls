public without sharing class ASI_CRM_CN_Function{
    
    public class CRMException extends Exception {}
 
    
    private static map<Id, User> MUserID = new map<Id, User>();
    private static list<user> LUser = new list<user>();
    static{
        LUser = [Select id, name, BypassTriggers__c, username from user where BypassTriggers__c != null];
        
        MUserID = new Map<id,user>(LUser);
        // Uncomment by Michael Yip (Introv) 08Aug2014
        for(User u : LUser){
            MUserID.put(u.id,u);
        }
    }

    public static User getSystemAdminUser(){      
        list<User> users = [SELECT Id, Name, Managerid, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User 
                            WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE
                            LIMIT 1];      
        return users.size()>0 ? users[0] : null;
    }
    
    public static user getUser(id UserID){
        return MUserID.get(UserID);
    }
    public static List<user> getUserList(){
        return LUser;
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

    public static string getFiscalYear(date d) {
        if(d.month()<=6)
            return string.valueOf(d.year()-1) + '/' + string.valueOf(d.year());
        else
            return string.valueOf(d.year()) + '/' + string.valueOf(d.year()+1);
    }
}