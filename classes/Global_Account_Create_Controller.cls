/*
    - This Controller controls the Page Traffic of the Account Standard New Action.
    - To Add Record Type or Roles to redirect traffic to your own visualforce page, please add the
    visualforce page API name along with the record type/role to the Global Account Controller
    custom setting.
    
    Example:
    ----------------------------------------------------------------------------------------
   |Name         |Action   |Redirected Page      |Record Type    |Role         |Customized  | 
    ----------------------------------------------------------------------------------------
   |Custom Name  |Create   |/apex/your_page      |DeveloperName  |DeveloperName|true        |
    ----------------------------------------------------------------------------------------
    
    Remarks:
    - Role is an optional field which will only be used when customized is set to true.
    - With Role filled in, you can choose to redirect your page according to the role of the logged in
    user according to its record type.
    
    --> Laputa Technologies ? <--
*/

public class Global_Account_Create_Controller {
    private Account Acct{get;set;}
    private String loggedInUserRole{get;set;}
    private String RecordTypeId{get;set;}
    private String RecordTypeName{get;set;}
    private List<Global_Account_Controller__c> globalControllersDefault{get;set;}// stores the custom setting where customize is false
    private List<Global_Account_Controller__c> globalControllersCustomized{get;set;}// stores the custom setting where customize is true
    private String paramList {get;set;} // store parameters from previos page and pass it to the next
    public Global_Account_Create_Controller(ApexPages.StandardController controller) {
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
             Where Global_Account_Action__c = 'Create' And
                   Global_Account_Customized__c = false
            ];
        globalControllersCustomized = 
            [Select Global_Account_Action__c, Global_Account_Redirected_Page__c, 
                    Global_Account_Record_Type__c, Global_Account_Customized__c,
                    Global_Account_Role__c
             From   Global_Account_Controller__c
             Where Global_Account_Action__c = 'Create' And
                   Global_Account_Customized__c = true
            ];
        
        Acct = (Account)controller.getRecord();
        RecordTypeId = ((Account)controller.getRecord()).RecordTypeId;
        
        //Added on 20151208, handles user with one record type assignment only
        if(RecordTypeId == null){
            Schema.DescribeSObjectResult describeAccount = Schema.SObjectType.Account;
            List<Schema.RecordTypeInfo> rtInfos = describeAccount.getRecordTypeInfos();
            for(Schema.RecordTypeInfo rtInfo:rtInfos){
                //GDT modified 20151221 if(rtInfo.getName() != 'Master' && rtInfo.isAvailable()){
                  if(rtInfo.isDefaultRecordTypeMapping() ){
                    RecordTypeId = rtInfo.getRecordTypeId();
                }
            }
        }
        RecordTypeName = 'null';
        for(RecordType rt:[select id,DeveloperName from recordtype where id = :recordtypeid])
             RecordTypeName = rt.DeveloperName;
    }
    // redirects page according to valus stored in custom settings
    public PageReference redirect(){
        for(Global_Account_Controller__c gac : globalControllersCustomized){
            //matches record's record type to the value stored in custom settings
            if(RecordTypeName == gac.Global_Account_Record_Type__c){  
               //matches the logged in user role to the value stored in custom settings                
               if(loggedInUserRole == gac.Global_Account_Role__c && paramlist.length() > 0){
                  PageReference retPage =  new PageReference(gac.Global_Account_Redirected_Page__c +'?'+ paramList.subString(1,paramList.length()));
                  retPage.setRedirect(true);
                  return retPage;
               }                   
            }else{
                if(loggedInUserRole == gac.Global_Account_Role__c && paramlist.length() > 0){
                  PageReference retPage =  new PageReference(gac.Global_Account_Redirected_Page__c +'?'+ paramList.subString(1,paramList.length()));
                  retPage.setRedirect(true);
                  return retPage;
               }
            }                     
        }
        
        for(Global_Account_Controller__c gac : globalControllersDefault){
            //matches record's record type to the value stored in custom settings
            if(RecordTypeName == gac.Global_Account_Record_Type__c && paramlist.length() > 0){    
                  PageReference retPage =   new PageReference(gac.Global_Account_Redirected_Page__c+ '?'+paramList.subString(1,paramList.length()));           
                  retPage.setRedirect(true);
                  return retPage;                                     
            }                      
        }
        
        //if none of the custom settings matches, redicrect to its defaul create page
        Schema.DescribeSObjectResult accObj = Account.sObjectType.getDescribe();
        PageReference retPage = new PageReference('/'+ accObj.getKeyPrefix() +'/e?RecordType='+recordtypeid+'&nooverride=1'+ paramList);
        if (recordtypeid == null)
            retPage = new PageReference('/'+ accObj.getKeyPrefix() +'/e?nooverride=1'+ paramList);
        retPage.setRedirect(true);
        return retPage;

    }

}