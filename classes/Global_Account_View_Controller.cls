/*
    - This Controller controls the Page Traffic of the Account Standard Edit Action.
    - To Add Record Type or Roles to redirect traffic to your own visualforce page, please add the
    visualforce page API name along with the record type/role to the Global Account Controller
    custom setting.
    
    Example:
    ----------------------------------------------------------------------------------------
   |Name         |Action   |Redirected Page      |Record Type    |Role         |Customized  | 
    ----------------------------------------------------------------------------------------
   |Custom Name  |Edit     |/apex/your_page      |DeveloperName  |DeveloperName| true       |
    ----------------------------------------------------------------------------------------
    
    Remarks:
    - Role is an optional field which will only be used when customized is set to true.
    - With Role filled in, you can choose to redirect your page according to the role of the logged in
    user according to its record type.
    
    --> Laputa Technologies ? <--
*/

public class Global_Account_View_Controller {
    private Account Acct{get;set;}
    private String loggedInUserRole{get;set;}
    private String RecordTypeId{get;set;}
    private String RecordTypeName{get;set;}
    private List<Global_Account_Controller__c> globalControllersDefault{get;set;}// stores the custom setting where customize is false
    private List<Global_Account_Controller__c> globalControllersCustomized{get;set;}// stores the custom setting where customize is true
    private List<Global_Account_Controller__c> globalControllersGroup{get;set;}// stores the custom setting where Public Group is not NULL
    private String paramList {get;set;} // store parameters from previos page and pass it to the next
    
    
    //Added by Introv: Daniel 2015-05-27 Checking Public Group
    public static Map<String, Set<id>> getPublicGroup(String gName){ 
        Map<String, Set<id>> mapGroup_user = new Map<String, Set<Id>>();
        
        for(GroupMember i :[
                SELECT Group.DeveloperName,  UserOrGroupId 
                FROM GroupMember 
                WHERE GroupId IN (SELECT Id FROM Group WHERE DeveloperName = :gName)  //'ASI_CRM_MY_StandardUser')
            ]){
            Set<Id> uid = new Set<Id>();
                
            if(mapGroup_user.get(i.Group.DeveloperName) != NULL)
                uid = mapGroup_user.get(i.Group.DeveloperName);
            uid.add(i.UserOrGroupId);
            
            mapGroup_user.put(i.Group.DeveloperName, uid);
        }
        system.debug('mapGroup_user : ' + mapGroup_user);
        return mapGroup_user;
    }
    
    public static Boolean isGroupMember(Id uid, String gName){
        Map<String, Set<Id>> mapGroup_user = getPublicGroup(gName);
        Set<Id> setRoleId = new Set<Id>();
        Set<Id> roleRelatedGroupIds = new Set<Id>();
        
        //uid = (ID) string.valueof(uid).left(15);
        system.debug('isGroupMember-------------------------------' + uid);
        if(mapGroup_user.get(gName) != NULL){
            if(mapGroup_user.get(gName).CONTAINS(uid))
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
            if(mapGroup_user.get(gName) != NULL){
                system.debug('mapGroup_user.get(gName) : ' + mapGroup_user.get(gName));
                system.debug('rid :' + rid);
                if(mapGroup_user.get(gName).CONTAINS(rid))
                    return TRUE;
            }
        }
        return FALSE;
    }
    
    public Global_Account_View_Controller(ApexPages.StandardController controller) {
        Map<String, String> pageParam = ApexPages.currentPage().getParameters();       
        paramList='';
        if(pageParam!=null){
            for(String param : pageParam.keySet()){
                if(pageParam.get(param)==null){
                    paramList +='&'+param+'=null';
                }else{
                    if(!param.contains('save_new')&&!param.contains('sfdc.override'))
                    paramList +='&'+param+'='+pageParam.get(param);
                }
            }
        }
        
        Id UserRoleId =   Userinfo.getUserRoleId() ;
        if(UserRoleId != null){
            List<UserRole> role = [Select DeveloperName from UserRole where ID = :userRoleId ] ;
        
            if(role.size()>0)
                loggedInUserRole = role.get(0).DeveloperName;
        }
        globalControllersDefault = 
            [Select Global_Account_Action__c, Global_Account_Redirected_Page__c, 
                    Global_Account_Record_Type__c, Global_Account_Customized__c,
                    Global_Account_Role__c
             From   Global_Account_Controller__c
             Where Global_Account_Action__c = 'Read' And
                   Global_Account_Customized__c = false
                   AND Global_Account_Public_Group__c = NULL
            ];
        globalControllersCustomized = 
            [Select Global_Account_Action__c, Global_Account_Redirected_Page__c, 
                    Global_Account_Record_Type__c, Global_Account_Customized__c,
                    Global_Account_Role__c
             From   Global_Account_Controller__c
             Where Global_Account_Action__c = 'Read' And
                   Global_Account_Customized__c = true
                   AND Global_Account_Public_Group__c = NULL
            ];
        globalControllersGroup = 
            [Select Global_Account_Action__c, Global_Account_Redirected_Page__c, 
                    Global_Account_Record_Type__c, Global_Account_Customized__c,
                    Global_Account_Role__c, Global_Account_Public_Group__c
             From   Global_Account_Controller__c
             Where Global_Account_Action__c = 'Read'
             AND Global_Account_Public_Group__c != NULL
            ];
        
        Acct = (Account)controller.getRecord();
        RecordTypeId = ((Account)controller.getRecord()).RecordTypeId;
        
   /* GDT TEST
        //Added on 20151208, handles user with one record type assignment only
        if(RecordTypeId == null){
            Schema.DescribeSObjectResult describeAccount = Schema.SObjectType.Account;
            List<Schema.RecordTypeInfo> rtInfos = describeAccount.getRecordTypeInfos();
            for(Schema.RecordTypeInfo rtInfo:rtInfos){
                if(rtInfo.getName() != 'Master' && rtInfo.isAvailable()){
                    RecordTypeId = rtInfo.getRecordTypeId();
                }
            }
        }
   */
        RecordTypeName = 'null';
        for(RecordType rt:[select id,DeveloperName from recordtype where id = :recordtypeid])
             RecordTypeName = rt.DeveloperName;
    }
    // redirects page according to valus stored in custom settings
    public PageReference redirect(){
        for(Global_Account_Controller__c gac : globalControllersGroup){
            //matches the logged in user role to the value stored in custom settings
            if(isGroupMember(UserInfo.getUserId(), gac.Global_Account_Public_Group__c)){
                PageReference retPage =   new PageReference(gac.Global_Account_Redirected_Page__c+ '?'+paramList.subString(1,paramList.length()));           
                retPage.setRedirect(true);
                return retPage;
            }                  
        }
        
        for(Global_Account_Controller__c gac : globalControllersCustomized){
            //matches record's record type to the value stored in custom settings
            if(RecordTypeName == gac.Global_Account_Record_Type__c){               
               //matches the logged in user role to the value stored in custom settings     
               if(loggedInUserRole == gac.Global_Account_Role__c){
                  PageReference retPage = new PageReference(gac.Global_Account_Redirected_Page__c +'?id=' + Acct.ID+ paramList);
                  retPage.setRedirect(true);
                  return retPage;
               }                   
            }                      
        }
        
        for(Global_Account_Controller__c gac : globalControllersDefault){
             //matches record's record type to the value stored in custom settings
            if(RecordTypeName == gac.Global_Account_Record_Type__c){ 
                  PageReference retPage =new PageReference(gac.Global_Account_Redirected_Page__c +'?id=' + Acct.ID+ paramList);
                  retPage.setRedirect(true);             
                  return retPage;                                     
            }                      
        }
        
        PageReference retPage = new PageReference('/apex/Global_Account_Detail?id='+this.Acct.ID+ paramList);
        retPage.setRedirect(true);
        //redirect to a visual force page that only containts <apex:detail> of account
        return retPage ;

    }

}