/*
    - This Controller controls the Page Traffic of the Account Standard View.
    - To Add Record Type or Roles to redirect traffic to your own visualforce page, please add the
    visualforce page API name along with the record type/role to the Global Account Controller
    custom setting.
    
    Example:
    ----------------------------------------------------------------------------------------
   |Name         |Action   |Redirected Page      |Record Type    |Role         |Customized  | 
    ----------------------------------------------------------------------------------------
   |Custom Name  |Read     |/apex/your_page      |DeveloperName  |DeveloperName| true       |
    ----------------------------------------------------------------------------------------
    
    Remarks:
    - Role is an optional field which will only be used when customized is set to true.
    - With Role filled in, you can choose to redirect your page according to the role of the logged in
    user according to its record type.
    
    --> Laputa Technologies ☁ <--
*/
public class Global_Account_Edit_Controller {

    private Account Acct{get;set;}
    private String loggedInUserRole{get;set;}
    private String RecordTypeId{get;set;}
    private String RecordTypeName{get;set;}
    private List<Global_Account_Controller__c> globalControllersDefault{get;set;} // stores the custom setting where customize is false
    private List<Global_Account_Controller__c> globalControllersCustomized{get;set;}// stores the custom setting where customize is true
    private String paramList {get;set;} // store parameters from previos page and pass it to the next
    public Global_Account_Edit_Controller(ApexPages.StandardController controller) {
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
             Where Global_Account_Action__c = 'Edit' And
                   Global_Account_Customized__c = false
            ];
            
        globalControllersCustomized = 
            [Select Global_Account_Action__c, Global_Account_Redirected_Page__c, 
                    Global_Account_Record_Type__c, Global_Account_Customized__c,
                    Global_Account_Role__c
             From   Global_Account_Controller__c
             Where Global_Account_Action__c = 'Edit' And
                   Global_Account_Customized__c = true
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
   
        RecordTypeName = 'null';//
        for(RecordType rt:[select id,DeveloperName from recordtype where id = :recordtypeid])
             RecordTypeName = rt.DeveloperName;
     }
    // redirects page according to valus stored in custom settings
     public PageReference redirect(){
        for(Global_Account_Controller__c gac : globalControllersCustomized){
            //matches record's record type to the value stored in custom settings
            if(RecordTypeName == gac.Global_Account_Record_Type__c){   
               //matches the logged in user role to the value stored in custom settings            
               if(loggedInUserRole == gac.Global_Account_Role__c){
                  
                  PageReference retPage = new PageReference(gac.Global_Account_Redirected_Page__c +'?id=' + Acct.ID + paramList);
                  retPage.setRedirect(true);
                  return retPage;
               }                   
            }                      
        }
        
        for(Global_Account_Controller__c gac : globalControllersDefault){
            //matches record's record type to the value stored in custom settings
            if(RecordTypeName == gac.Global_Account_Record_Type__c){ 
                  PageReference retPage =    new PageReference(gac.Global_Account_Redirected_Page__c +'?id=' + Acct.ID + paramList);
                  retPage.setRedirect(true);             
                  return retPage;                                     
            }                      
        }
        
        //if there are no matches in the custom setting, the default record type edit page will be shown
        String address = '/'+String.valueOf(Acct.Id)+'/e?retURL=%2F'+ String.valueOf(Acct.ID)+'&nooverride=1'+ paramList;
        PageReference retPage =  new PageReference(address);
        retPage.setRedirect(true);    
        return retPage;

    }
     
        
        




}