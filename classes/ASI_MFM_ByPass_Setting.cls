//Custom Setting: ASI MFM ByPass Setting
public without sharing class ASI_MFM_ByPass_Setting {
    
    //Function 1 : check the class is bypass, return ture/false
    public static boolean ByPassClass(string ControllerName,string CountryName) {
        boolean ByPass=false;
        List<ASI_MFM_ByPass_Setting__c> SettingList = ASI_MFM_ByPass_Setting__c.getAll().values();
        
        if(SettingList!=null){
            for (ASI_MFM_ByPass_Setting__c Setting : SettingList) {
                if(Setting.ASI_MFM_ByPass_Controller__c!=null && Setting.ASI_MFM_Country__c !=null){
                    if(Setting.ASI_MFM_ByPass_Controller__c==ControllerName && Setting.ASI_MFM_Country__c==CountryName){
                        ByPass=setting.ASI_MFM_ByPass__c;
                    }
                }
                
            }
        }
        return ByPass;
    }
    
    
    
    //Function 2: get SQL Statement from Custom Setting by input 'Controller Name','Method Name','Country Name' , return SQL statemnt in string
    public static string ReturnSqlStatement(string ControllerName,string MethodName,string CountryName) {
        string sqlstatement=' ';
        List<ASI_MFM_ByPass_Setting__c> SettingList = ASI_MFM_ByPass_Setting__c.getAll().values();
        
        if(SettingList!=null){
            for (ASI_MFM_ByPass_Setting__c Setting : SettingList) {
                if(Setting.ASI_MFM_ByPass_Controller__c!=null && Setting.ASI_MFM_Country__c !=null && Setting.ASI_MFM_Method__c!=null){
                    if(Setting.ASI_MFM_ByPass_Controller__c==ControllerName && Setting.ASI_MFM_Country__c==CountryName && Setting.ASI_MFM_Method__c==MethodName){
                        sqlstatement=setting.ASI_MFM_SQL_Statement__c;
                    }
                }
            }
        }
        return sqlstatement;
    }
    
    //Function 3: check the class or Method is bypass, return ture/false
    public static boolean ByPassClassMethod(string ControllerName,string MethodName,string CountryName) {
        //default is false : Bypass : no
        boolean ByPass=false;
        //Get data from Custom Setting
        List<ASI_MFM_ByPass_Setting__c> SettingList = ASI_MFM_ByPass_Setting__c.getAll().values();
        
        if(SettingList!=null){
            for (ASI_MFM_ByPass_Setting__c Setting : SettingList) {
                if(Setting.ASI_MFM_ByPass_Controller__c!=null && Setting.ASI_MFM_Country__c !=null && Setting.ASI_MFM_Method__c !=null){
                    if(Setting.ASI_MFM_ByPass_Controller__c==ControllerName && Setting.ASI_MFM_Country__c==CountryName && Setting.ASI_MFM_Method__c==MethodName){
                        ByPass=setting.ASI_MFM_ByPass__c;
                    }
                }
                
            }
        }
        return ByPass;
    }
    
    
    //Function 4: check the class or Method is bypass, return set of bypass Method
    public static set<string> ByPassClassMap(string ControllerName,string CountryName) {
        set<string> bypassset = new  set<string>();
        List<ASI_MFM_ByPass_Setting__c> SettingList = ASI_MFM_ByPass_Setting__c.getAll().values();
        
        if(SettingList!=null){
            for (ASI_MFM_ByPass_Setting__c Setting : SettingList) {
                if(Setting.ASI_MFM_ByPass_Controller__c!=null && Setting.ASI_MFM_Country__c !=null && Setting.ASI_MFM_Method__c !=null){
                    if(Setting.ASI_MFM_ByPass_Controller__c==ControllerName && Setting.ASI_MFM_Country__c==CountryName && setting.ASI_MFM_ByPass__c== true){
                        bypassset.add(Setting.ASI_MFM_Method__c);
                    }
                }
                
            }
        }
        
        
        return bypassset;
    }
    
    //Function 5: return user's Public Group List 
    public static set<string> GetGroup(){
        set<string> PublicGroup = new set<string>();
        for (GroupMember gm : [SELECT Id, group.id, group.name, group.type FROM GroupMember where (UserOrGroupId = :UserInfo.getUserId())]){
            PublicGroup.add(gm.group.name);
        }
        return PublicGroup;
    }
    
    
    //Function 6: return user's Custom Permissions
    public static set<string> GetCustomPermissions(){
        set<string> CustomPermissions = new set<string>();
        
        //Get user ID
        Id userId =System.UserInfo.getUserId();
        
        List<SetupEntityAccess> access =[SELECT SetupEntityId FROM SetupEntityAccess WHERE SetupEntityType='CustomPermission' AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId=:userId)];
        Set<Id> customPermIds = new Set<Id>();
        
        for (SetupEntityAccess sea : access) {
            customPermIds.add(sea.SetupEntityId);
        }
        
        //Get Custom Permission
        List<CustomPermission> customPerms = [SELECT Id, DeveloperName, MasterLabel FROM CustomPermission WHERE Id IN :customPermIds];
        
        for (CustomPermission perm : customPerms) {
            CustomPermissions.add(perm.DeveloperName);
        }
        return CustomPermissions;
    }
    
    
    //Function 7:Get user Permission Set Assignment
    public static set<string> GetPermissionsSetAssignment(Id userId){
        set<string> PermissionsSet = new set<string>();
        
        for(PermissionSetAssignment psa :[SELECT Id, Assignee.Name, PermissionSet.Name FROM PermissionSetAssignment where AssigneeId=:userId]){
            if(psa.PermissionSet.Name!=null){
                PermissionsSet.add(psa.permissionSet.Name);
            }
        }
        
        
        return PermissionsSet;
    }
    
    
    public static void ErrorHandling(String ErrorMessage,String ClassName, String MethodName){
        try{
            ASI_CRM_CN_CustomSetting__c CustomSetting = ASI_CRM_CN_CustomSetting__c.getInstance();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {CustomSetting.ASI_CRM_System_Debug_Email__c});
            mail.setReplyTo(CustomSetting.ASI_CRM_System_Debug_Email__c);
            mail.setSenderDisplayName('ASI Error');
            mail.setSubject('ASI Error Notification');
            mail.setPlainTextBody('Please note that we got following error: \n Class Name: '+ClassName+'  \n Method Name: '+MethodName +'\n Details: '+ErrorMessage);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }catch (DmlException dmle) {
            
        }catch(Exception e){
            
        }
        
    }
    
    public static Boolean CheckingBypassByCurrentUser(string BypassName){
        Boolean isByPass = false;
        ID curUserId = UserInfo.getUserId();
        User u = ASI_CRM_CN_Function.getUser(curUserId);           
        if(u != null && u.BypassTriggers__c != null){
            if (u.BypassTriggers__c.contains(BypassName) && !Test.isRunningTest()){
                isByPass = true;
            }
        }
        return isByPass;
    }
    
    
}