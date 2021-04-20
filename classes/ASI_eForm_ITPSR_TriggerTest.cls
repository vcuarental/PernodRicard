@isTest
private class ASI_eForm_ITPSR_TriggerTest
{

    @isTest
    public static void testITProcServiceItemsAfterUpdate()
    {
      User user = ASI_eForm_TestClassHelper.createUser();
        Map<String,User> userMap = new Map<String,User>();
        userMap.put('owner',user);
        
           ASI_eForm_TestClassHelper.createPrefillCustomSetting();
        ASI_eForm_TestClassHelper.createRouteTypeDetails(userMap);
        
        ASI_eForm_IT_Procurement_Service_Request__c  itpsr =
            ASI_eForm_TestClassHelper.createITPSRServiceRequest(userMap);        
     
      List<ASI_eForm_IT_Procurement_Service_Item__c> itpsrItems =
       ASI_eForm_TestClassHelper.createITPSRServiceRequestItem(itpsr);
        
      itpsr.ASI_eForm_CIO__c = user.Id; 
      itpsr.ASI_eForm_Finance_Director__c= user.Id;      
      RecordType itpsrRTFinal = [SELECT Id from RecordType where DeveloperName = 'ASI_eForm_HK_IT_Service_Request_Final'];
      itpsr.RecordTypeId = itpsrRTFinal.Id;
      itpsr.ASI_eForm_Status__c = 'Final';  
      update itpsr;
      
      itpsrItems.get(0).ASI_eForm_FD_Approve_Required__c =true;        
      itpsrItems.get(0).ASI_eForm_CIO_Approve_Required__c = true;
      itpsrItems.get(0).ASI_eForm_IT_Action__c = 'Invalid Submission';
      update itpsrItems;         
               
    }
    
    @isTest
    public static void testITProcHardwareAfterUpdate()
    {
      ASI_eForm_TestClassHelper.assignToPublicGroup();
      
      User user = ASI_eForm_TestClassHelper.createUser();
        Map<String,User> userMap = new Map<String,User>();
        userMap.put('owner',user);
        
           ASI_eForm_TestClassHelper.createPrefillCustomSetting();
        ASI_eForm_TestClassHelper.createRouteTypeDetails(userMap);
        
        ASI_eForm_IT_Procurement_Service_Request__c  itpsr =
            ASI_eForm_TestClassHelper.createITPSRHardware(userMap);        
     
      List<ASI_eForm_IT_Procurement_Service_Item__c> itpsrItems =
       ASI_eForm_TestClassHelper.createITPSRHardwareItem(itpsr);
        
      itpsr.ASI_eForm_CIO__c = user.Id; 
      itpsr.ASI_eForm_Finance_Director__c= user.Id;      
      RecordType itpsrRTFinal = [SELECT Id from RecordType where DeveloperName = 'ASI_eForm_HK_Hardware_Software_Request_Final'];
      itpsr.RecordTypeId = itpsrRTFinal.Id;
      itpsr.ASI_eForm_Status__c = 'Final';  
      update itpsr;      
               
    }
    
    @isTest
    public static void testITProcServiceItem()
    {
      User user = ASI_eForm_TestClassHelper.createUser();
        Map<String,User> userMap = new Map<String,User>();
        userMap.put('owner',user);
        
           ASI_eForm_TestClassHelper.createPrefillCustomSetting();
        ASI_eForm_TestClassHelper.createRouteTypeDetails(userMap);
        
        ASI_eForm_IT_Procurement_Service_Request__c  itpsr =
            ASI_eForm_TestClassHelper.createITPSRServiceRequest(userMap);
        
      ASI_eForm_IT_Procurement_Service_Request__c  itProcServiceReq =
        ASI_eForm_TestClassHelper.createITPSRServiceRequest(userMap);
      
      List<ASI_eForm_IT_Procurement_Service_Item__c> itpsrItems =
       ASI_eForm_TestClassHelper.createITPSRServiceRequestItem(itProcServiceReq );
        
      itpsrItems.get(0).ASI_eForm_FD_Approve_Required__c =true;        
      itpsrItems.get(0).ASI_eForm_CIO_Approve_Required__c = true;
      update itpsrItems;
      
      itpsr.ASI_eForm_CIO__c = user.Id; 
      itpsr.ASI_eForm_Finance_Director__c= user.Id;
      //itpsr.ASI_eForm_FD_Approve_Required__c = true;
      
      update itpsr;
      
      itpsr.ASI_eForm_CIO__c = user.Id; 
      update itpsr;
     
      delete itpsrItems;             
      delete itpsr;         
    }

}