@isTest (seealldata=true)
public class ASI_CRM_Visual_Application_Test{
  
    static testMethod void ASI_CRM_Visual_Application_TriggerClass_TEST()
    {
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(Name='TEST', ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

         Account account = new Account(
            Name='TestAcc',
            recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Supplier'),
            ASI_MFM_Customer_Supplier_Number__c='123',
            ASI_MFM_Customer_Supplier_Name__c='SupplierName'
        );
        insert account;

        ASI_CRM_AccountsAdditionalField__c customer =  new ASI_CRM_AccountsAdditionalField__c(Name='TEST3', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_Account__c=account.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id);
        insert customer;
        
        customer.ASI_CRM_Account__c=account.Id;
        update customer;

        ASI_CRM_Fix_Approval_Route__c fapp = new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=UserInfo.getUserId(), ASI_CRM_CN_Type__c='Visual Application', ASI_CRM_CN_Region_Area_Channel__c='TEST', ownerid=UserInfo.getUserId());
        insert fapp;

        list<ASI_CRM_Visual_Application__c> listVA = new list<ASI_CRM_Visual_Application__c>();
        listVA.add(new ASI_CRM_Visual_Application__c(ASI_CRM_Agency__c=account.Id, ASI_CRM_Outlet__c=customer.Id));
        insert listVA;

        test.startTest();        
        {
            map<Id, ASI_CRM_Visual_Application__c> oldMap = new map<Id, ASI_CRM_Visual_Application__c>();
            for(ASI_CRM_Visual_Application__c va :listVA)
                oldMap.put(va.Id, va);

            ASI_CRM_Visual_Application_TriggerClass.routineBeforeInsert(listVA);

            map<string, ASI_CRM_Fix_Approval_Route__c> mapFApp = new map<string, ASI_CRM_Fix_Approval_Route__c>();
            mapFApp.put(fapp.Id, fapp);
            
            ASI_CRM_Visual_Application_TriggerClass.setApprovers(listVA[0], mapFApp);
            ASI_CRM_Visual_Application_TriggerClass.setApproverToNull(listVA[0]);
        }
        
        test.stopTest();
    }
}