@isTest
public class ASI_eForm_TestClassHelper
{
    
    public static void createRunningNumbers()
    {
      
      List<ASI_eForm_Running_Number__c> runningNumbers = new List<ASI_eForm_Running_Number__c>();
    
        ASI_eForm_Running_Number__c runningNumber1 = new ASI_eForm_Running_Number__c(CURRENCYISOCODE='EUR', ASI_EFORM_FIRST_MONTH_OF_FISCAL_YEAR__C=null, ASI_EFORM_FISCAL_YEAR__C=null, ASI_EFORM_FORMAT__C='CRCN{000000}', ASI_EFORM_OBJECT_NAME__C='ASI_eForm_IT_Change_Request_CN', ASI_EFORM_RUNNING_NUMBER__C=2.0);
runningNumbers.add(runningNumber1); 
ASI_eForm_Running_Number__c runningNumber2 = new ASI_eForm_Running_Number__c(CURRENCYISOCODE='EUR', ASI_EFORM_FIRST_MONTH_OF_FISCAL_YEAR__C=null, ASI_EFORM_FISCAL_YEAR__C=null, ASI_EFORM_FORMAT__C='CR{000000}', ASI_EFORM_OBJECT_NAME__C='ASI_eForm_IT_Change_Request_HK', ASI_EFORM_RUNNING_NUMBER__C=3.0);
runningNumbers.add(runningNumber2);

      insert runningNumbers;   
    
    }
    
    
    public static void createEmailSetting()
    {
        ASI_eForm_Email_Setting__c emailSetting =
            new ASI_eForm_Email_Setting__c();
        emailSetting.Travel_Agent_Email__c = 'test@sfdc.com';
        emailSetting.Location__c = 'Hong Kong';
        emailSetting.Name = 'Hong Kong';
    
       insert emailSetting;
    }
    
    public static void createFormAttachment(Id parentId)
    {
        ASI_eForm_ITPSR_Attachment__c eFormAttachment=new ASI_eForm_ITPSR_Attachment__c();     
        eFormAttachment.ASI_eForm_Category__c='Others';
        eFormAttachment.ASI_eForm_File_Name__c = 'File Attachment' + parentId;
        eFormAttachment.ASI_eForm_IT_Procurement_Service_Request__c = parentId;
        eFormAttachment.ASI_eForm_Attach_in_Approval_Email__c = true;
        insert eFormAttachment;   
    }
    
    public static void createFormAttachmentITCR(Id parentId)
    {
        ASI_eForm_ITCRF_Attachment__c eFormAttachment=new ASI_eForm_ITCRF_Attachment__c();     
        eFormAttachment.ASI_eForm_Category__c='Others';
        eFormAttachment.ASI_eForm_File_Name__c = 'File Attachment' + parentId;
        eFormAttachment.ASI_eForm_IT_Change_Request__c = parentId;
        eFormAttachment.ASI_eForm_Attach_in_Approval_Email__c = true;
        insert eFormAttachment;   
    }
    
    public static void createAttachment(Id parentId)
    {
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'+parentId);
        attach.body=bodyBlob;
        attach.parentId=parentId;
        insert attach;   
    }
    
    public static void createNote(Id parentId)
    {
        Note note=new Note();     
        note.Title='Unit Test Note';
        //Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'+parentId);
        note.body='Unit Test Note Body'+parentId;
        note.parentId=parentId;
        insert note;   
    }
    
    public static Map<String,ASI_eForm_User_Profile__c> createUserProfile()
    {
       ASI_eForm_User_Profile__c userProfile = new ASI_eForm_User_Profile__c();
       userProfile.ASI_eForm_Last_Name__c = 'LastName';            
       //userProfile.ASI_eForm_Line_Manager__c = userRequest.ASI_eForm_Line_Manager__c;            
       userProfile.ASI_eForm_Service_Period_From__c = Date.today();            
       userProfile.ASI_eForm_Service_Period_To__c = Date.today();            
       userProfile.ASI_eForm_User_Company__c = 'PR' ;            
       userProfile.ASI_eForm_User_Position__c= 'IT Man';            
       userProfile.ASI_eForm_User_Country__c = 'Hong Kong';            
       userProfile.ASI_eForm_User_Department__c = 'Department';     
       
       insert userProfile;
       
       Map<String,ASI_eForm_User_Profile__c> userProfileMap = new Map<String,ASI_eForm_User_Profile__c>();
       userProfileMap.put('userProfile',userProfile);
       return userProfileMap;
    }
    
    public static Map<String,ASI_eForm_PR_System__c> createSystem(Map<String,User> userMap)
    {
        Map<String,ASI_eForm_PR_System__c> prSystemMap = new Map<String,ASI_eForm_PR_System__c>();
        User user = userMap.get('owner');
        
        ASI_eForm_PR_System__c prSystem  = new ASI_eForm_PR_System__c();
        prSystem.ASI_eForm_Responsible_By_1__c = user.Id; 
        prSystem.ASI_eForm_Responsible_By_2__c = user.Id;
        prSystem.ASI_eForm_Responsible_By_3__c = user.Id;
        prSystem.ASI_eForm_Responsible_By_4__c = user.Id;
        prSystem.ASI_eForm_Responsible_By_5__c = user.Id;
        prSystem.ASI_eForm_Responsible_By_6__c = user.Id;
        prSystem.ASI_eForm_Responsible_By_7__c = user.Id;
        prSystem.ASI_eForm_Responsible_By_8__c = user.Id;
        prSystem.ASI_eForm_Responsible_By_9__c = user.Id;
        prSystem.ASI_eForm_Responsible_By_10__c = user.Id;       
        prSystem.ASI_eForm_Basic_Selection__c = true;
        prSystem.Name = 'Email';
        
        
        ASI_eForm_PR_System__c prSystem2  = new ASI_eForm_PR_System__c();
        prSystem2.ASI_eForm_Responsible_By_1__c = user.Id; 
        prSystem2.ASI_eForm_Responsible_By_2__c = user.Id;
        prSystem2.ASI_eForm_Responsible_By_3__c = user.Id;
        prSystem2.ASI_eForm_Responsible_By_4__c = user.Id;
        prSystem2.ASI_eForm_Responsible_By_5__c = user.Id;
        prSystem2.ASI_eForm_Responsible_By_6__c = user.Id;
        prSystem2.ASI_eForm_Responsible_By_7__c = user.Id;
        prSystem2.ASI_eForm_Responsible_By_8__c = user.Id;
        prSystem2.ASI_eForm_Responsible_By_9__c = user.Id;
        prSystem2.ASI_eForm_Responsible_By_10__c = user.Id;       
        prSystem2.ASI_eForm_Basic_Selection__c = true;
        prSystem2.Name = 'Active Directory User Profile';
        
        List<ASI_eForm_PR_System__c> prSystemList = new List<ASI_eForm_PR_System__c>();
        
        prSystemList.add(prSystem);
        prSystemList.add(prSystem2);
        
        insert prSystemList;
        
        prSystemMap.put(prSystem.Name, prSystem);
        prSystemMap.put(prSystem2.Name, prSystem2);
        
        return prSystemMap;
    }
    
    
    public static Map<String,ASI_eForm_Permission_Type__c> createSystemPermissionType(Map<String,ASI_eForm_PR_System__c> prSystemMap)
    {
        List<ASI_eForm_Permission_Type__c> permissionTypes =  new List<ASI_eForm_Permission_Type__c>();
        
        Map<String,ASI_eForm_Permission_Type__c> prSystemPermissionTypeMap = new Map<String,ASI_eForm_Permission_Type__c>();
        
        ASI_eForm_Permission_Type__c prSystemPermissionType  = new ASI_eForm_Permission_Type__c();
        prSystemPermissionType.ASI_eForm_PR_System__c = prSystemMap.get('Email').Id; 
        prSystemPermissionType.Name = 'Default'; 
        
        ASI_eForm_Permission_Type__c prSystemPermissionType2  = new ASI_eForm_Permission_Type__c();
        prSystemPermissionType2.ASI_eForm_PR_System__c = prSystemMap.get('Active Directory User Profile').Id; 
        prSystemPermissionType2.Name = 'Default'; 
        
        permissionTypes.add(prSystemPermissionType);
        permissionTypes.add(prSystemPermissionType2);
                       
        insert permissionTypes;
        
        prSystemPermissionTypeMap.put('Email', prSystemPermissionType);
        prSystemPermissionTypeMap.put('Active Directory User Profile', prSystemPermissionType2);
        return prSystemPermissionTypeMap;
    }
    
    
    public static Map<String,ASI_eForm_User_System_Permission__c> createSystemPermission(Map<String,User> userMap,
         Map<String,ASI_eForm_Permission_Type__c> permissionMap, ASI_eForm_User_Profile__c userProfile)
    {
        Map<String,ASI_eForm_User_System_Permission__c> prSystemPermissionMap = new Map<String,ASI_eForm_User_System_Permission__c>();
        User user = userMap.get('owner');
        
        ASI_eForm_User_System_Permission__c prSystemPermission  = new ASI_eForm_User_System_Permission__c();
        prSystemPermission.ASI_eForm_Permission_TypeN__c= permissionMap.get('Email').Id; 
        prSystemPermission.ASI_eForm_PR_System__c = permissionMap.get('Email').ASI_eForm_PR_System__c ;
        prSystemPermission.ASI_eForm_User_Profile_Name__c = userProfile.id;
        //prSystemPermission.ASI_eForm_System_Privilege__c = 'Admin';
        //prSystemPermission.ASI_eForm_User__c = user.Id;
        
        insert prSystemPermission;
        prSystemPermissionMap.put(prSystemPermission.Name, prSystemPermission);
        return prSystemPermissionMap;
    }
    
    public static ASI_eForm_User_ID_Request__c createUserIDRequestRemove(Map<String,User> userMap)
    {
        User createdUser = userMap.get('owner');
        
        RecordType removeEmployeeRecordType = 
         [Select id from RecordType where SobjectType='ASI_eForm_User_ID_Request__c' and DeveloperName = 'ASI_eForm_HK_Remove_ID'];        
                
        ASI_eForm_User_ID_Request__c userIdRequest =
            new ASI_eForm_User_ID_Request__c();
            
        userIdRequest.recordtypeid = removeEmployeeRecordType.id;    
        userIdRequest.ASI_eForm_Preview_Approver__c = createdUser.Id;
        userIdRequest.ASI_eForm_HR_Business_Department_Manager__c = createdUser.Id;
        userIdRequest.ASI_eForm_Sys_User_Permission_Applied__c = true;        
        userIdRequest.ASI_eForm_User_Position__c = 'IT';
        userIdRequest.ASI_eForm_Status__c = 'Draft';
        userIdRequest.ASI_eForm_User_Alias__c = 'aai';
        userIdRequest.ASI_eForm_Submit_Flag__c=true;
        //userIdRequest.ASI_eForm_User_Name__c = createdUser.Id;
               
        insert userIdRequest;  
        
        return userIdRequest;               
    }
    
    public static ASI_eForm_User_ID_Request__c createUserIDRequest(Map<String,User> userMap)
    {
        User createdUser = userMap.get('owner');
        
        RecordType newEmployeePermanentRecordType = 
         [Select id from RecordType Where DeveloperName='ASI_eForm_HK_New_Employee_Permanent'];        
                
        ASI_eForm_User_ID_Request__c userIdRequest =
            new ASI_eForm_User_ID_Request__c();
            
        userIdRequest.recordtypeid = newEmployeePermanentRecordType.id;    
        userIdRequest.ASI_eForm_Preview_Approver__c = createdUser.Id;
        userIdRequest.ASI_eForm_HR_Business_Department_Manager__c = createdUser.Id;
        //userIdRequest.ASI_eForm_Sys_User_Permission_Applied__c = true;        
        userIdRequest.ASI_eForm_Status__c = 'Draft';
        userIdRequest.ASI_eForm_User_Alias__c = 'aai';
        userIdRequest.ASI_eForm_First_Name__c = 'FName';            
        userIdRequest.ASI_eForm_Last_Name__c= 'LName';            
        userIdRequest.ASI_eForm_Line_Manager__c= createdUser.Id;            
        userIdRequest.ASI_eForm_Service_Period_From__c= Date.today();            
        userIdRequest.ASI_eForm_Service_Period_To__c= Date.today();            
        userIdRequest.ASI_eForm_User_Company__c= 'PR' ;      
        userIdRequest.ASI_eForm_User_Country__c= 'Hong Kong';            
        userIdRequest.ASI_eForm_User_Department__c= 'Finance';            
        userIdRequest.ASI_eForm_User_Position__c= 'IT Man';
        userIdRequest.ASI_eForm_Submit_Flag__c=true;
               
        insert userIdRequest;  
        
        return userIdRequest;               
    }
    
    
    public static ASI_eForm_User_ID_Request__c createUserIDRequestChangeProfileWithUserProfile(Map<String,User> userMap)
    {
        User createdUser = userMap.get('owner');
        
        RecordType newEmployeePermanentRecordType = 
         [Select id from RecordType Where DeveloperName='ASI_eForm_HK_Change_Profile'];        
                
        ASI_eForm_User_ID_Request__c userIdRequest =
            new ASI_eForm_User_ID_Request__c();
            
        userIdRequest.recordtypeid = newEmployeePermanentRecordType.id;    
        userIdRequest.ASI_eForm_Preview_Approver__c = createdUser.Id;
        userIdRequest.ASI_eForm_HR_Business_Department_Manager__c = createdUser.Id;
        userIdRequest.ASI_eForm_Sys_User_Permission_Applied__c = true;        
        //userIdRequest.ASI_eForm_User_Position__c = 'IT';
        userIdRequest.ASI_eForm_Status__c = 'Draft';
        userIdRequest.ASI_eForm_User_Alias__c = 'aai';
        userIdRequest.ASI_eForm_Submit_Flag__c=true;
        userIdRequest.ASI_eForm_User_Company__c= 'PR'  ; 
        
        Map<String,ASI_eForm_User_Profile__c>  userProfileMap = ASI_eForm_TestClassHelper.createUserProfile();
        ASI_eForm_User_Profile__c userProfile = userProfileMap.get('userProfile'); 
        userIDRequest.ASI_eForm_User_Profile_Name__c = userProfile.Id;
               
        insert userIdRequest;  
        
        return userIdRequest;               
    }
    
    public static ASI_eForm_User_ID_Request__c createUserIDRequestChangeProfile(Map<String,User> userMap)
    {
        User createdUser = userMap.get('owner');
        User approverUsers = createUser('appr1234');
        
        RecordType newEmployeePermanentRecordType = 
         [Select id from RecordType Where DeveloperName='ASI_eForm_HK_Change_Profile'];        
                
        ASI_eForm_User_ID_Request__c userIdRequest =
            new ASI_eForm_User_ID_Request__c();
            
        userIdRequest.recordtypeid = newEmployeePermanentRecordType.id;    
        userIdRequest.ASI_eForm_Preview_Approver__c = createdUser.Id;
        userIdRequest.ASI_eForm_HR_Business_Department_Manager__c = createdUser.Id;
        userIdRequest.ASI_eForm_Sys_User_Permission_Applied__c = true;        
        //userIdRequest.ASI_eForm_User_Position__c = 'IT';
        userIdRequest.ASI_eForm_Status__c = 'Draft';
        userIdRequest.ASI_eForm_User_Alias__c = 'aai';
        userIdRequest.ASI_eForm_First_Name__c = 'FName';            
        userIdRequest.ASI_eForm_Last_Name__c= 'LName';            
        userIdRequest.ASI_eForm_Line_Manager__c= createdUser.Id;            
        userIdRequest.ASI_eForm_Service_Period_From__c= Date.today();            
        userIdRequest.ASI_eForm_Service_Period_To__c= Date.today();            
        userIdRequest.ASI_eForm_User_Company__c= 'PR' ;      
        userIdRequest.ASI_eForm_User_Country__c= 'Hong Kong';            
        userIdRequest.ASI_eForm_User_Department__c= 'Finance';            
        userIdRequest.ASI_eForm_User_Position__c= 'IT Man';
        userIdRequest.ASI_eForm_Submit_Flag__c=true;
        
               
        insert userIdRequest;  
        
        return userIdRequest;               
    }
    
    public static List<ASI_eForm_User_ID_Request_Item__c> createUserIDRequestItemSingle(
    ASI_eForm_User_ID_Request__c userIdRequest,Map<String,User> userMap, 
    Map<String,ASI_eForm_Permission_Type__c> permissionTypeMap)
    { 
        List<ASI_eForm_User_ID_Request_Item__c> userIDRequestItems =
            new List<ASI_eForm_User_ID_Request_Item__c>();    
           
       
        RecordType serviceRequestItemRecordType = 
         [Select id from RecordType Where DeveloperName='ASI_eForm_User_ID_Request_Item'];            
          
        ASI_eForm_User_ID_Request_Item__c userIDRequestItem =
            new ASI_eForm_User_ID_Request_Item__c();     
        userIDRequestItem.RecordtypeId = serviceRequestItemRecordType.id;    
        userIDRequestItem.ASI_eForm_User_ID_Request__c= userIdRequest.Id;
        userIDRequestItem.ASI_eForm_Permission_Action__c= 'Add';        
        userIDRequestItem.ASI_eForm_Permission_TypeN__c= permissionTypeMap.get('Email').Id;
        //userIDRequestItem.ASI_eForm_Sys_Count__c = 1;
        userIDRequestItem.ASI_eForm_PR_System__c =  permissionTypeMap.get('Email').ASI_eForm_PR_System__c;
        userIDRequestItems.add(userIDRequestItem);
        
                   
        insert userIDRequestItems;  
        
        return userIDRequestItems;               
    }
    
    public static List<ASI_eForm_User_ID_Request_Item__c> createUserIDRequestItemComplete(
    ASI_eForm_User_ID_Request__c userIdRequest,Map<String,User> userMap, 
    Map<String,ASI_eForm_Permission_Type__c> permissionTypeMap)
    { 
        List<ASI_eForm_User_ID_Request_Item__c> userIDRequestItems =
            new List<ASI_eForm_User_ID_Request_Item__c>();    
           
       
        RecordType serviceRequestItemRecordType = 
         [Select id from RecordType Where DeveloperName='ASI_eForm_User_ID_Request_Item'];            
          
        ASI_eForm_User_ID_Request_Item__c userIDRequestItem =
            new ASI_eForm_User_ID_Request_Item__c();     
        userIDRequestItem.RecordtypeId = serviceRequestItemRecordType.id;    
        userIDRequestItem.ASI_eForm_User_ID_Request__c= userIdRequest.Id;
        userIDRequestItem.ASI_eForm_Permission_Action__c= 'Add';        
        userIDRequestItem.ASI_eForm_Permission_TypeN__c= permissionTypeMap.get('Email').Id;
        //userIDRequestItem.ASI_eForm_Sys_Count__c = 1;
        userIDRequestItem.ASI_eForm_PR_System__c =  permissionTypeMap.get('Email').ASI_eForm_PR_System__c;
        userIDRequestItem.ASI_eForm_IT_Action__c = 'Complete';
        userIDRequestItems.add(userIDRequestItem);
        
                   
        insert userIDRequestItems;  
        
        return userIDRequestItems;               
    }
    
    public static List<ASI_eForm_User_ID_Request_Item__c> createUserIDRequestItem(
    ASI_eForm_User_ID_Request__c userIdRequest,Map<String,User> userMap, 
    Map<String,ASI_eForm_Permission_Type__c> permissionTypeMap)
    { 
        List<ASI_eForm_User_ID_Request_Item__c> userIDRequestItems =
            new List<ASI_eForm_User_ID_Request_Item__c>();    
        
        
       
        RecordType serviceRequestItemRecordType = 
         [Select id from RecordType Where DeveloperName='ASI_eForm_User_ID_Request_Item'];            
          
        ASI_eForm_User_ID_Request_Item__c userIDRequestItem =
            new ASI_eForm_User_ID_Request_Item__c();     
        userIDRequestItem.RecordtypeId = serviceRequestItemRecordType.id;    
        userIDRequestItem.ASI_eForm_User_ID_Request__c= userIdRequest.Id;
        userIDRequestItem.ASI_eForm_Permission_Action__c= 'Add';        
        userIDRequestItem.ASI_eForm_Permission_TypeN__c= permissionTypeMap.get('Email').Id;
        //userIDRequestItem.ASI_eForm_Sys_Count__c = 1;
        userIDRequestItem.ASI_eForm_PR_System__c =  permissionTypeMap.get('Email').ASI_eForm_PR_System__c;
        
        userIDRequestItems.add(userIDRequestItem);
        
        ASI_eForm_User_ID_Request_Item__c userIDRequestItem2 =
            new ASI_eForm_User_ID_Request_Item__c();     
        userIDRequestItem2.RecordtypeId = serviceRequestItemRecordType.id;    
        userIDRequestItem2.ASI_eForm_User_ID_Request__c= userIdRequest.Id;
        userIDRequestItem2.ASI_eForm_Permission_Action__c= 'Delete';        
        userIDRequestItem2.ASI_eForm_Permission_TypeN__c= permissionTypeMap.get('Email').Id;
        //userIDRequestItem2.ASI_eForm_Sys_Count__c = 1;
        userIDRequestItem2.ASI_eForm_PR_System__c =  permissionTypeMap.get('Email').ASI_eForm_PR_System__c;
        
        userIDRequestItems.add(userIDRequestItem2);
               
        insert userIDRequestItems;  
        
        return userIDRequestItems;               
    }
    
    
    public static ASI_eForm_IT_Procurement_Service_Request__c createITPSRServiceRequest(Map<String,User> userMap)
    {
        User createdUser = userMap.get('owner');
        
        RecordType serviceRequestRecordType = 
         [Select id from RecordType Where DeveloperName='ASI_eForm_HK_IT_Service_Request'];        
                
        ASI_eForm_IT_Procurement_Service_Request__c itpsr =
            new ASI_eForm_IT_Procurement_Service_Request__c();
            
        itpsr.recordtypeid = serviceRequestRecordType.id;    
        itpsr.ASI_eForm_Preview_Approver__c = createdUser.Id;
        itpsr.ASI_eForm_Approver__c = createdUser.Id;
        //System.Datetime.now().date();       
        itpsr.ASI_eForm_Status__c = 'Draft';
        itpsr.ASI_eForm_CIO__c = createdUser.id;
        itpsr.ASI_eForm_Finance_Director__c = createdUser.id;
        itpsr.ASI_eForm_Submit_Flag__c=true;
               
        insert itpsr;  
        
        return itpsr;               
    }
    
    public static ASI_eForm_IT_Procurement_Service_Request__c createITPSRHardware (Map<String,User> userMap)
    {
        User createdUser = userMap.get('owner');
        
        RecordType serviceRequestRecordType = 
         [Select id from RecordType Where DeveloperName='ASI_eForm_HK_Hardware_Software_Request'];        
                
        ASI_eForm_IT_Procurement_Service_Request__c itpsr =
            new ASI_eForm_IT_Procurement_Service_Request__c();
            
        itpsr.recordtypeid = serviceRequestRecordType.id;    
        itpsr.ASI_eForm_Preview_Approver__c = createdUser.Id;
        itpsr.ASI_eForm_Approver__c = createdUser.Id;
        //System.Datetime.now().date();       
        itpsr.ASI_eForm_Status__c = 'Draft';
        itpsr.ASI_eForm_Submit_Flag__c=true;
               
        insert itpsr;  
        
        return itpsr;               
    }
    
    public static List<ASI_eForm_IT_Procurement_Service_Item__c> createITPSRHardwareItem(
    ASI_eForm_IT_Procurement_Service_Request__c itpsr)
    { 
        
        List<ASI_eForm_IT_Procurement_Service_Item__c>  itpsrItems = new List<ASI_eForm_IT_Procurement_Service_Item__c>();     
        ASI_eForm_IT_Procurement_Service_Item__c itpsrItem =
            new ASI_eForm_IT_Procurement_Service_Item__c();     
       
        RecordType serviceRequestItemRecordType = 
         [Select id from RecordType Where DeveloperName='ASI_eForm_Hardware_Software_Request_Item'];   
            
        itpsrItem.RecordtypeId = serviceRequestItemRecordType.id;    
        itpsrItem.ASI_eForm_IT_Procurement_Service_Request__c = itpsr.Id;
        
        itpsrItem.ASI_eForm_Item__c = 'test';
        itpsrItem.ASI_eForm_Requisition_Type__c = 'Software';
        itpsrItem.ASI_eForm_HASRF_Category__c = 'New SW - Non Listed';
        itpsrItem.ASI_eForm_Quantity__c = 1;
        itpsrItem.ASI_eForm_Currency__c = 'HKD';
        itpsrItem.ASI_eForm_Unit_Price__c = 10000;
        itpsrItem.ASI_eForm_Specification__c = 'test';
        
        itpsrItems.add(itpsrItem);       
        insert itpsrItems;  
        
        return itpsrItems;               
    }
    
    public static List<ASI_eForm_IT_Procurement_Service_Item__c> createITPSRServiceRequestItem(
    ASI_eForm_IT_Procurement_Service_Request__c itpsr)
    { 
        
        List<ASI_eForm_IT_Procurement_Service_Item__c>  itpsrItems = new List<ASI_eForm_IT_Procurement_Service_Item__c>();     
        ASI_eForm_IT_Procurement_Service_Item__c itpsrItem =
            new ASI_eForm_IT_Procurement_Service_Item__c();     
       
        RecordType serviceRequestItemRecordType = 
         [Select id from RecordType Where DeveloperName='ASI_eForm_IT_Service_Request_Item'];   
            
        itpsrItem.RecordtypeId = serviceRequestItemRecordType.id;    
        itpsrItem.ASI_eForm_IT_Procurement_Service_Request__c = itpsr.Id;
        //System.Datetime.now().date();
        itpsrItem.ASI_eForm_ITSRF_Category__c = 'Hardware Loan';        
        itpsrItem.ASI_eForm_Item__c = 'Laptop';
        itpsrItem.ASI_eForm_Specification__c = 'i5';
        //itpsrItem.ASI_eForm_Sys_Count__c = 1;
        
        itpsrItems.add(itpsrItem);       
        insert itpsrItems;  
        
        return itpsrItems;               
    }
      
    
    public static ASI_eForm_Pre_Trip_Approval__c createPreTripApproval(Map<String,User> userMap)
    {
        recordtype record_type = [Select id from RecordType where SobjectType='ASI_eForm_Pre_Trip_Approval__c' and DeveloperName = 'ASI_eForm_HK_Pre_Trip_Approval'];
        User createdUser = userMap.get('owner');
        user otherUser = createuser('abcdefgh');
                
        ASI_eForm_Pre_Trip_Approval__c preTripApproval =
            new ASI_eForm_Pre_Trip_Approval__c();
            
        preTripApproval.ASI_eForm_Preview_Approver__c = createdUser.Id;
        preTripApproval.ASI_eForm_Approver__c = createdUser.Id;
        //System.Datetime.now().date();
        preTripApproval.ASI_eForm_Employee_Traveller__c = otherUser.id;
        //preTripApproval.ASI_eForm_Traveller_Company__c = 'testExtCompany';
        preTripApproval.ASI_eForm_Notify_Travel_Agent__c = true;
        preTripApproval.ASI_eForm_Payment_Method__c = 'Individual Corp Card';
        preTripApproval.ASI_eForm_Status__c = 'Draft';
        preTripApproval.recordtypeid = record_type.id;
        preTripApproval.ASI_eForm_Submit_Flag__c=true;
               
        insert preTripApproval;  
        
        return preTripApproval;               
    }
    
    
    public static List<ASI_eForm_Pre_Trip_Approval_Item__c> createPreTripApprovalItems(ASI_eForm_Pre_Trip_Approval__c preTrip)
    {
        
        recordtype record_type = [Select id from RecordType where SobjectType='ASI_eForm_Pre_Trip_Approval_Item__c' and DeveloperName = 'ASI_eForm_Pre_Trip_Approval_Item'];
        ASI_eForm_Pre_Trip_Approval_Item__c preTripApprovalItem =
            new ASI_eForm_Pre_Trip_Approval_Item__c();
            
        preTripApprovalItem.ASI_eForm_Pre_Trip_Approval__c = preTrip.Id;
        //System.Datetime.now().date();
        preTripApprovalItem.ASI_eForm_Booking_Status__c = 'Booked';
        preTripApprovalItem.ASI_eForm_Class__c = 'Economy';
        preTripApprovalItem.ASI_eForm_Date__c = System.Datetime.now().date();
        preTripApprovalItem.ASI_eForm_ETA__c = System.Datetime.now();
        preTripApprovalItem.ASI_eForm_ETD__c = System.Datetime.now();
        preTripApprovalItem.ASI_eForm_From__c = 'Hong Kong';
        preTripApprovalItem.ASI_eForm_To__c = 'Japan';
        preTripApprovalItem.recordtypeid = record_type.id;
        //preTripApprovalItem.ASI_eForm_Sys_Count__c = 1;      
        insert preTripApprovalItem;  
        
        return new List<ASI_eForm_Pre_Trip_Approval_Item__c>{preTripApprovalItem};               
    }
    
    
    public static Map<String,ASI_eForm_Context__c> createContexts(Map<String,User> userMap)
    {
        Map<String,ASI_eForm_Context__c> contextMap = new Map<String,ASI_eForm_Context__c>();
        User user = userMap.get('owner');
        
        ASI_eForm_Context__c eFormContext = new ASI_eForm_Context__c();
        eFormContext.ASI_eForm_External_Email_1__c = 'user@email.com';
        eFormContext.ASI_eForm_External_Email_2__c = 'user2@email.com';        
        eFormContext.ASI_eForm_Responsible_By_1__c = user.Id;
        eFormContext.ASI_eForm_Responsible_By_2__c = user.Id;
        eFormContext.ASI_eForm_Responsible_By_3__c = user.Id;
        eFormContext.ASI_eForm_Responsible_By_4__c = user.Id;
        eFormContext.ASI_eForm_Responsible_By_5__c = user.Id;
        eFormContext.ASI_eForm_Responsible_By_6__c = user.Id;
        eFormContext.ASI_eForm_Responsible_By_7__c = user.Id;
        eFormContext.ASI_eForm_Responsible_By_8__c = user.Id;
        eFormContext.ASI_eForm_Responsible_By_9__c = user.Id;
        eFormContext.ASI_eForm_Responsible_By_10__c = user.Id; 
        
        eFormContext.Name = 'SAP';
        
        insert eFormContext;
        contextMap.put(eFormContext.Name, eFormContext);
        return contextMap;
    }

    public static ASI_eForm_IT_Change_Request__c createITChangeRequestCN(Map<String,User> userMap)
    {
        User createdUser = userMap.get('owner');
        
               
        ASI_eForm_IT_Change_Request__c itChangeRequest =
            new ASI_eForm_IT_Change_Request__c();
            
        RecordType hkRecordType = [Select Id from RecordType where DeveloperName = 'ASI_eForm_CN_IT_Change_Request'];     
        itChangeRequest.RecordTypeId = hkRecordType.Id;    
        itChangeRequest.ASI_eForm_Change_Category__c = 'Low';
        itChangeRequest.ASI_eForm_Date_Needed__c = System.Datetime.now().date();
        itChangeRequest.ASI_eForm_Change_Type__c = 'Normal';
        itChangeRequest.ASI_eForm_Status__c = 'Draft';
        itChangeRequest.ASI_eForm_Project_Name__c = 'testProject';
        //itChangeRequest.OwnerId = createdUser.Id;
        itChangeRequest.ASI_eForm_Preview_Approver__c = createdUser.Id;
        itChangeRequest.ASI_eForm_Change_Authorizer__c  = createdUser.Id;
        itChangeRequest.ASI_eForm_Further_Authorizer__c  = createdUser.Id;
        itChangeRequest.ASI_eForm_High_Level_Authorizer__c  = createdUser.Id;
        itChangeRequest.ASI_eForm_Project_Coordinator__c = createdUser.Id;
        itChangeRequest.ASI_eForm_Project_Implementer__c = createdUser.Id;
        itChangeRequest.ASI_eForm_Submit_Flag__c=true;
                
        insert itChangeRequest;  
        
        return itChangeRequest;               
    }
    
    public static ASI_eForm_IT_Change_Request__c createITChangeRequest(Map<String,User> userMap)
    {
        User createdUser = userMap.get('owner');
                
        ASI_eForm_IT_Change_Request__c itChangeRequest =
            new ASI_eForm_IT_Change_Request__c();
        
        RecordType hkRecordType = [Select Id from RecordType where DeveloperName = 'ASI_eForm_HK_IT_Change_Request'];
        
        itChangeRequest.RecordTypeId = hkRecordType.Id;    
        itChangeRequest.ASI_eForm_Change_Category__c = 'Low';
        itChangeRequest.ASI_eForm_Date_Needed__c = System.Datetime.now().date();
        itChangeRequest.ASI_eForm_Change_Type__c = 'Normal';
        itChangeRequest.ASI_eForm_Status__c = 'Draft';
        itChangeRequest.ASI_eForm_Project_Name__c = 'testProject';
        //itChangeRequest.OwnerId = createdUser.Id;
        itChangeRequest.ASI_eForm_Preview_Approver__c = createdUser.Id;
        itChangeRequest.ASI_eForm_Change_Authorizer__c  = createdUser.Id;
        itChangeRequest.ASI_eForm_Further_Authorizer__c  = createdUser.Id;
        itChangeRequest.ASI_eForm_High_Level_Authorizer__c  = createdUser.Id;
        itChangeRequest.ASI_eForm_Project_Coordinator__c = createdUser.Id;
        itChangeRequest.ASI_eForm_Project_Implementer__c = createdUser.Id;
        itChangeRequest.ASI_eForm_Submit_Flag__c=true;
                
        insert itChangeRequest;  
        
        return itChangeRequest;               
    }
    
    public static List<ASI_eForm_IT_Change_Request_Item__c> createITChangeRequestItems(ASI_eForm_IT_Change_Request__c itChangeRequest, Map<String,User> userMap)
    {
        
        RecordType hkRecordType = [Select Id from RecordType where DeveloperName = 'ASI_eForm_IT_Change_Request_Item'];
        
        List<ASI_eForm_IT_Change_Request_Item__c> itChangeRequestItems =
            new List<ASI_eForm_IT_Change_Request_Item__c>();
        
        User owner = userMap.get('owner');    
        
        Map<String,ASI_eForm_Context__c> contextMap = createContexts(userMap);
        
        ASI_eForm_IT_Change_Request_Item__c itChangeRequestItem = 
            new ASI_eForm_IT_Change_Request_Item__c ();
        
        itChangeRequestItem.ASI_eForm_IT_Change_Request__c = itChangeRequest.Id;
        itChangeRequestItem.ASI_eForm_Context__c = contextMap.values().get(0).Id;
        //itChangeRequestItem.ASI_eForm_Sys_Count__c =  1;
        itChangeRequestItem.ASI_eForm_IT_Handle_By__c = owner.id;
        itChangeRequestItem.recordtypeid = hkRecordType.id;
        
        itChangeRequestItems.add(itChangeRequestItem);
        insert itChangeRequestItems; 
        return itChangeRequestItems;   
    }
    
    public static User createUser()
    {
                    
        Profile profile = [SELECT Id 
                         FROM profile WHERE name = 'System Administrator'];   
         
        User normalUser = new User(
        username = 'testqwe12390nsd@test123.com',
        Email = 'test1234nsd@test123.com',
        lastName = 'normalUser',
        firstName = 'nomalUser',
        alias  = 'nrmUsr12',
        languagelocalekey = 'en_US',
        localesidkey = 'en_US',
        emailEncodingKey = 'UTF-8',
        timeZoneSidKey = 'America/Los_Angeles',        
        profileId = profile.id,
        ASI_eForm_Indicator__c = '\'CN Change Authorizer\'Project Implementer\'',
        companyName='PR'
        );
        
        insert normalUser;           
             
        return normalUser;        
     }
    
    public static void assignToPublicGroup()
    {
        List<group> AllGroupList = [SELECT ID, DeveloperName FROM group WHERE DeveloperName = : 'ASI_eForm_Infra_Group' OR DeveloperName = : 'ASI_eForm_General_Admin' LIMIT 2];
        
        List<GroupMember> GMlist = new List<GroupMember>();
        
        User user1 = createUser('abbcdas');
        User user2 = createUser('abbdas1');     

        GroupMember GM = new GroupMember();
        GM.GroupId = AllGroupList.get(0).id;
        GM.UserOrGroupId = user1.Id;
        GMList.add(GM);
        
        GroupMember GM1 = new GroupMember();
        GM1.GroupId = AllGroupList.get(1).id;
        GM1.UserOrGroupId = user2.Id;
        GMList.add(GM1);         
        System.runAs(user1){
            insert GMList;
        }
    }
    
    public static User createUser(String customName)
    {
                    
        Profile profile = [SELECT Id 
                         FROM profile WHERE name = 'System Administrator'];   
         
        User normalUser = new User(
        username = customName + '@test123.com',
        Email = customName + '1234nsd@test123.com',
        lastName = customName + 'normalUser',
        firstName = customName + 'nomalUser',
        alias  = customName.substring(0,7),
        languagelocalekey = 'en_US',
        localesidkey = 'en_US',
        emailEncodingKey = 'UTF-8',
        timeZoneSidKey = 'America/Los_Angeles',        
        profileId = profile.id,
        Department = 'Finance',
        ASI_MFM_Country__c = 'TW',
        CompanyName ='PR' ,      
        managerId = UserInfo.getUserId()
        );
        
        insert normalUser;           
             
        return normalUser;        
     }

     public static void executeApprovalProcess(Id recordId)
     {
      
      Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
      req1.setComments('Submitting request for approval.');
      req1.setObjectId(recordId);  
      
      Approval.ProcessResult result1 = Approval.process(req1);      
      // Verify the results  
      System.assert(result1.isSuccess());
      
      List<Id> newWorkItemIds = result1.getNewWorkitemIds();      
   
      // Instantiate the new ProcessWorkitemRequest object and populate it           
      Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
      req2.setComments('Approving request.');
      req2.setAction('Approve');
      req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
      // Use the ID from the newly created item to specify the item to be worked  
      req2.setWorkitemId(newWorkItemIds.get(0));
        
      // Submit the request for approval  
      Approval.ProcessResult result2 =  Approval.process(req2);
        
      // Verify the results  
      System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());     
     }
    
    public static void createRouteTypeDetails(Map<String,User> userMap)
    {
        
    User user = userMap.get('owner');
    List<ASI_eForm_Route_Rule_Details__c> routeTypeDetails = new List<ASI_eForm_Route_Rule_Details__c>();    
    
    Map<String,ASI_eForm_Route_Type__c> routeTypeMap = createRouteType();
    
    ASI_eForm_Route_Rule_Details__c routeTypeDetail1 = new ASI_eForm_Route_Rule_Details__c(CURRENCYISOCODE='EUR', ASI_EFORM_ROUTE_TYPE__C=routeTypeMap.get('ITCRF-PRHK-Finance').Id, ASI_EFORM_APPROVER__C=user.Id, ASI_EFORM_NOTE__C='Preview Approver', ASI_EFORM_PREVIEW_APPROVER__C=true);
routeTypeDetails.add(routeTypeDetail1); 
    ASI_eForm_Route_Rule_Details__c routeTypeDetail2 = new ASI_eForm_Route_Rule_Details__c(CURRENCYISOCODE='EUR', ASI_EFORM_ROUTE_TYPE__C=routeTypeMap.get('ITCRF-PRHK-Finance').Id, ASI_EFORM_APPROVER__C=user.Id, ASI_EFORM_NOTE__C='Change Authorizer', ASI_EFORM_PREVIEW_APPROVER__C=false);
routeTypeDetails.add(routeTypeDetail2); 
ASI_eForm_Route_Rule_Details__c routeTypeDetail3 = new ASI_eForm_Route_Rule_Details__c(CURRENCYISOCODE='EUR', ASI_EFORM_ROUTE_TYPE__C=routeTypeMap.get('ITCRF-PRHK-Finance').Id, ASI_EFORM_APPROVER__C=user.Id, ASI_EFORM_NOTE__C='High-Level Authorizer', ASI_EFORM_PREVIEW_APPROVER__C=false);
routeTypeDetails.add(routeTypeDetail3); 
ASI_eForm_Route_Rule_Details__c routeTypeDetail4 = new ASI_eForm_Route_Rule_Details__c(CURRENCYISOCODE='EUR', ASI_EFORM_ROUTE_TYPE__C=routeTypeMap.get('ITCRF-PRHK-Finance').Id, ASI_EFORM_APPROVER__C=user.Id, ASI_EFORM_NOTE__C='High-Level Authorizer', ASI_EFORM_PREVIEW_APPROVER__C=false);
routeTypeDetails.add(routeTypeDetail4);

    
    //PreTripApproval-PRHK-Finace    
    //ASI_eForm_Route_Rule_Details__c routeTypeDetail5 = new ASI_eForm_Route_Rule_Details__c(CURRENCYISOCODE='EUR', ASI_EFORM_ROUTE_TYPE__C=routeTypeMap.get('PreTripApproval-PRHK-Finace').Id, ASI_EFORM_APPROVER__C=user.Id, ASI_EFORM_NOTE__C='Approver', ASI_EFORM_PREVIEW_APPROVER__C=false, ASI_EFORM_SYS_COUNT__C=1);
//routeTypeDetails.add(routeTypeDetail5); 
ASI_eForm_Route_Rule_Details__c routeTypeDetail6 = new ASI_eForm_Route_Rule_Details__c(CURRENCYISOCODE='EUR', ASI_EFORM_ROUTE_TYPE__C=routeTypeMap.get('PreTripApproval-PRHK-Finace').Id, ASI_EFORM_APPROVER__C=user.Id, ASI_EFORM_NOTE__C='Preview Approver', ASI_EFORM_PREVIEW_APPROVER__C=true);
routeTypeDetails.add(routeTypeDetail6); 

    //ITPS-SR-PRHK-Finance
    ASI_eForm_Route_Rule_Details__c routeTypeDetail7 = new ASI_eForm_Route_Rule_Details__c(CURRENCYISOCODE='EUR', ASI_EFORM_ROUTE_TYPE__C=routeTypeMap.get('ITPS-SR-PRHK-Finance').Id, ASI_EFORM_APPROVER__C=user.Id, ASI_EFORM_NOTE__C='Preview Approver', ASI_EFORM_PREVIEW_APPROVER__C=true);
routeTypeDetails.add(routeTypeDetail7); 
 ASI_eForm_Route_Rule_Details__c routeTypeDetail8 = new ASI_eForm_Route_Rule_Details__c(CURRENCYISOCODE='EUR', ASI_EFORM_ROUTE_TYPE__C=routeTypeMap.get('ITPS-SR-PRHK-Finance').Id, ASI_EFORM_APPROVER__C=user.Id, ASI_EFORM_NOTE__C='Finance Director', ASI_EFORM_PREVIEW_APPROVER__C=true);
routeTypeDetails.add(routeTypeDetail8); 
 ASI_eForm_Route_Rule_Details__c routeTypeDetail9 = new ASI_eForm_Route_Rule_Details__c(CURRENCYISOCODE='EUR', ASI_EFORM_ROUTE_TYPE__C=routeTypeMap.get('ITPS-SR-PRHK-Finance').Id, ASI_EFORM_APPROVER__C=user.Id, ASI_EFORM_NOTE__C=ASI_eForm_PreFillApproversHandler.CIO, ASI_EFORM_PREVIEW_APPROVER__C=true);
routeTypeDetails.add(routeTypeDetail9); 

 ASI_eForm_Route_Rule_Details__c routeTypeDetail11 = new ASI_eForm_Route_Rule_Details__c(CURRENCYISOCODE='EUR', ASI_EFORM_ROUTE_TYPE__C=routeTypeMap.get('ITCRF-PRHK-Finance').Id, ASI_EFORM_APPROVER__C=user.Id, ASI_EFORM_NOTE__C=ASI_eForm_PreFillApproversHandler.CIO, ASI_EFORM_PREVIEW_APPROVER__C=true);
routeTypeDetails.add(routeTypeDetail11); 

    //UIR-NEWP-PRHK-Finance
    ASI_eForm_Route_Rule_Details__c routeTypeDetail10 = new ASI_eForm_Route_Rule_Details__c(CURRENCYISOCODE='EUR', ASI_EFORM_ROUTE_TYPE__C=routeTypeMap.get('UIR-NEWP-PRHK-Finance').Id, ASI_EFORM_APPROVER__C=user.Id, ASI_EFORM_NOTE__C='Preview Approver', ASI_EFORM_PREVIEW_APPROVER__C=true);
routeTypeDetails.add(routeTypeDetail10); 

    insert routeTypeDetails;
    
    }
    
     
    public static Map<String,ASI_eForm_Route_Type__c> createRouteType()
    {
     
     Map<String,ASI_eForm_Route_Type__c> routeTypeMap = new Map<String,ASI_eForm_Route_Type__c>();
     
      ASI_eForm_Route_Type__c routeType1 = new ASI_eForm_Route_Type__c(NAME='ITCRF-PRHK-Finance', CURRENCYISOCODE='EUR', ASI_EFORM_COMPANY__C='Pernod Ricard Hong Kong', ASI_EFORM_COUNTRY_DEL__C='Hong Kong', ASI_EFORM_DEPARTMENT__C='Finance', ASI_EFORM_FORM_RECORD_TYPE__C='IT Change Request (HK)', ASI_EFORM_FORM_TYPE__C='IT Change Request');
routeTypeMap.put(routeType1.name,routeType1);                                                                                                                                                                                                  //Issue #7 Change Label name
ASI_eForm_Route_Type__c routeType2 = new ASI_eForm_Route_Type__c(NAME='UIR-NEWP-PRHK-Finance', CURRENCYISOCODE='EUR', ASI_EFORM_COMPANY__C='Pernod Ricard Hong Kong', ASI_EFORM_COUNTRY_DEL__C='Hong Kong', ASI_EFORM_DEPARTMENT__C='Finance', ASI_EFORM_FORM_RECORD_TYPE__C='New User ID Permanent (HK)', ASI_EFORM_FORM_TYPE__C='User ID Request');
routeTypeMap.put(routeType2.name,routeType2);
ASI_eForm_Route_Type__c routeType3 = new ASI_eForm_Route_Type__c(NAME='ITPS-SR-PRHK-Finance', CURRENCYISOCODE='EUR', ASI_EFORM_COMPANY__C='Pernod Ricard Hong Kong', ASI_EFORM_COUNTRY_DEL__C='Hong Kong', ASI_EFORM_DEPARTMENT__C='Finance', ASI_EFORM_FORM_RECORD_TYPE__C='IT Service Request (HK)', ASI_EFORM_FORM_TYPE__C='IT Procurement & Service Request');
routeTypeMap.put(routeType3.name,routeType3);                                                                                                                                                                                                  //Issue #7 Change Label name                                                                                                 
ASI_eForm_Route_Type__c routeType4 = new ASI_eForm_Route_Type__c(NAME='UIR-NEWT-PRHK-Finance', CURRENCYISOCODE='EUR', ASI_EFORM_COMPANY__C='Pernod Ricard Hong Kong', ASI_EFORM_COUNTRY_DEL__C='Hong Kong', ASI_EFORM_DEPARTMENT__C='Finance', ASI_EFORM_FORM_RECORD_TYPE__C='New User ID Temporary (HK)', ASI_EFORM_FORM_TYPE__C='User ID Request');
routeTypeMap.put(routeType4.name,routeType4);
ASI_eForm_Route_Type__c routeType5 = new ASI_eForm_Route_Type__c(NAME='UIR-CHANGE-PRHK-Finance', CURRENCYISOCODE='EUR', ASI_EFORM_COMPANY__C='Pernod Ricard Hong Kong', ASI_EFORM_COUNTRY_DEL__C='Hong Kong', ASI_EFORM_DEPARTMENT__C='Finance', ASI_EFORM_FORM_RECORD_TYPE__C='Change Profile (HK)', ASI_EFORM_FORM_TYPE__C='User ID Request');
routeTypeMap.put(routeType5.name,routeType5); 
ASI_eForm_Route_Type__c routeType6 = new ASI_eForm_Route_Type__c(NAME='PreTripApproval-PRHK-Finace', CURRENCYISOCODE='EUR', ASI_EFORM_COMPANY__C='Pernod Ricard Hong Kong', ASI_EFORM_COUNTRY_DEL__C='Hong Kong', ASI_EFORM_DEPARTMENT__C='Finance', ASI_EFORM_FORM_RECORD_TYPE__C='', ASI_EFORM_FORM_TYPE__C='Pre-Trip Approval');
routeTypeMap.put(routeType6.name,routeType6); 
ASI_eForm_Route_Type__c routeType7 = new ASI_eForm_Route_Type__c(NAME='ITPS-PRHK-Finance', CURRENCYISOCODE='EUR', ASI_EFORM_COMPANY__C='Pernod Ricard Hong Kong', ASI_EFORM_COUNTRY_DEL__C='Hong Kong', ASI_EFORM_DEPARTMENT__C='Finance', ASI_EFORM_FORM_RECORD_TYPE__C='Hardware & Software Request (HK)', ASI_EFORM_FORM_TYPE__C='IT Procurement & Service Request');
routeTypeMap.put(routeType7.name,routeType7); 
ASI_eForm_Route_Type__c routeType8 = new ASI_eForm_Route_Type__c(NAME='UIR-REMOVE-PRHK-Finance', CURRENCYISOCODE='EUR', ASI_EFORM_COMPANY__C='Pernod Ricard Hong Kong', ASI_EFORM_COUNTRY_DEL__C='Hong Kong', ASI_EFORM_DEPARTMENT__C='Finance', ASI_EFORM_FORM_RECORD_TYPE__C='Remove ID (HK)', ASI_EFORM_FORM_TYPE__C='User ID Request');
routeTypeMap.put(routeType8.name,routeType8);
ASI_eForm_Route_Type__c routeType9 = new ASI_eForm_Route_Type__c(NAME='');
routeTypeMap.put(routeType9.name,routeType9);
  
    insert routeTypeMap.values();
    
    return routeTypeMap;
    
  }  
    
    public static void createPrefillCustomSetting()
    {

    List<ASI_eForm_Prefill_Fields__c> preFilledFields = new List<ASI_eForm_Prefill_Fields__c>();
        
ASI_eForm_Prefill_Fields__c preFilledField1 = new ASI_eForm_Prefill_Fields__c(NAME='ITCRPreviewApproverField', CURRENCYISOCODE='EUR', OBJECT_API_NAME__C='ASI_eForm_IT_Change_Request__c', FIELD_VALUE__C='CF00NM0000000svoD', FIELD_API_NAME__C='ASI_eForm_Preview_Approver__c');
preFilledFields.add(preFilledField1); 
ASI_eForm_Prefill_Fields__c preFilledField2 = new ASI_eForm_Prefill_Fields__c(NAME='UIRApproverField', CURRENCYISOCODE='EUR', OBJECT_API_NAME__C='', FIELD_VALUE__C='CF00NM0000000svpd', FIELD_API_NAME__C='');
preFilledFields.add(preFilledField2); 
ASI_eForm_Prefill_Fields__c preFilledField3 = new ASI_eForm_Prefill_Fields__c(NAME='ITPSRPreviewApproverField', CURRENCYISOCODE='EUR', OBJECT_API_NAME__C='', FIELD_VALUE__C='CF00NM0000000svoi', FIELD_API_NAME__C='');
preFilledFields.add(preFilledField3); 
ASI_eForm_Prefill_Fields__c preFilledField4 = new ASI_eForm_Prefill_Fields__c(NAME='ITPSRApproverField', CURRENCYISOCODE='EUR', OBJECT_API_NAME__C='ASI_eForm_IT_Procurement_Service_Request', FIELD_VALUE__C='CF00NM0000000svoZ', FIELD_API_NAME__C='ASI_eForm_Approver');
preFilledFields.add(preFilledField4); 
ASI_eForm_Prefill_Fields__c preFilledField5 = new ASI_eForm_Prefill_Fields__c(NAME='ITCRChangeAuthorizerField', CURRENCYISOCODE='EUR', OBJECT_API_NAME__C='ASI_eForm_IT_Change_Request', FIELD_VALUE__C='CF00NM0000000svo0', FIELD_API_NAME__C='ASI_eForm_Change_Authorizer');
preFilledFields.add(preFilledField5); 
ASI_eForm_Prefill_Fields__c preFilledField6 = new ASI_eForm_Prefill_Fields__c(NAME='UIRPreviewApproverField', CURRENCYISOCODE='EUR', OBJECT_API_NAME__C='ASI_eForm_User_ID_Request', FIELD_VALUE__C='CF00NM0000000svpi', FIELD_API_NAME__C='ASI_eForm_HR_Business_Department_Manager');
preFilledFields.add(preFilledField6); 
ASI_eForm_Prefill_Fields__c preFilledField7 = new ASI_eForm_Prefill_Fields__c(NAME='ITCRHighLevelAuthorizerField', CURRENCYISOCODE='EUR', OBJECT_API_NAME__C='ASI_eForm_IT_Change_Request', FIELD_VALUE__C='CF00NM0000000svoA', FIELD_API_NAME__C='ASI_eForm_High_Level_Authorizer');
preFilledFields.add(preFilledField7); 
ASI_eForm_Prefill_Fields__c preFilledField8 = new ASI_eForm_Prefill_Fields__c(NAME='PTAApproverField', CURRENCYISOCODE='EUR', OBJECT_API_NAME__C='ASI_eForm_Pre_Trip_Approval', FIELD_VALUE__C='CF00NM0000000svp1', FIELD_API_NAME__C='ASI_eForm_Approver');
preFilledFields.add(preFilledField8); 
ASI_eForm_Prefill_Fields__c preFilledField9 = new ASI_eForm_Prefill_Fields__c(NAME='ITPSRFinanceDirectorField', CURRENCYISOCODE='EUR', OBJECT_API_NAME__C='', FIELD_VALUE__C='CF00NM0000000svoe', FIELD_API_NAME__C='');
preFilledFields.add(preFilledField9); 
ASI_eForm_Prefill_Fields__c preFilledField10 = new ASI_eForm_Prefill_Fields__c(NAME='ITCRFurtherAuthorizerField', CURRENCYISOCODE='EUR', OBJECT_API_NAME__C='ASI_eForm_IT_Change_Request', FIELD_VALUE__C='CF00NM0000000svo9', FIELD_API_NAME__C='ASI_eForm_Further_Authorizer');
preFilledFields.add(preFilledField10); 
ASI_eForm_Prefill_Fields__c preFilledField11 = new ASI_eForm_Prefill_Fields__c(NAME='PTAPreviewApproverField', CURRENCYISOCODE='EUR', OBJECT_API_NAME__C='', FIELD_VALUE__C='CF00NM0000000svpB', FIELD_API_NAME__C='');
preFilledFields.add(preFilledField11); 
ASI_eForm_Prefill_Fields__c preFilledField12 = new ASI_eForm_Prefill_Fields__c(NAME='ITPSRCIOField', CURRENCYISOCODE='EUR', OBJECT_API_NAME__C='ASI_eForm_IT_Procurement_Service_Request', FIELD_VALUE__C='CF00NM0000000swQr', FIELD_API_NAME__C='ASI_eForm_CIO');
preFilledFields.add(preFilledField12); 
ASI_eForm_Prefill_Fields__c preFilledField13 = new ASI_eForm_Prefill_Fields__c(NAME='ITCRCIOApproverField', CURRENCYISOCODE='EUR', OBJECT_API_NAME__C='ASI_eForm_IT_Change_Request', FIELD_VALUE__C='CF00NM0000000trix', FIELD_API_NAME__C='ASI_eForm_CIO_Approver');
preFilledFields.add(preFilledField13);
ASI_eForm_Prefill_Fields__c preFilledField14 = new ASI_eForm_Prefill_Fields__c(NAME='PTATravellerCompanyField', CURRENCYISOCODE='EUR', OBJECT_API_NAME__C='ASI_eForm_Pre_Trip_Approval', FIELD_VALUE__C='00NM0000000svpG', FIELD_API_NAME__C='ASI_eForm_Traveller_Company');
preFilledFields.add(preFilledField14); 
 
 

    insert preFilledFields;
    
    
    }

}