/*Created by Twinkle Li @introv 01/12/2015
/*
*/
@isTest (SeeAllData=false)
public class ASI_CRM_CN_ApexSharing_Test {
    static testMethod void ASI_CRM_CN_AccountsAdditionalShareBatch_TEST() {  
        //User adminUser = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User adminUser = new User(Alias = 'standt', Email='testudc@yahoo.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testudc000000001@yahoo.com');


        ASI_CRM_Division__c objDiv = new ASI_CRM_Division__c(name='Division1');
        insert objDiv;
            
        ASI_CRM_CN_Area__c objArea = new ASI_CRM_CN_Area__c(name='Area1', ASI_CRM_Division__c=objDiv.id);
        insert objArea;
        
        ASI_CRM_City__c objCity = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='City1', ASI_CRM_CN_Area__c=objArea.Id);
        insert objCity;
        
        List<ASI_CRM_CN_Channel__c> lstChannel = new List<ASI_CRM_CN_Channel__c>();          
        lstChannel.add(new ASI_CRM_CN_Channel__c(Name='Channel1', ASI_CRM_CN_On_Off__c='On'));
        lstChannel.add(new ASI_CRM_CN_Channel__c(Name='Channel2', ASI_CRM_CN_On_Off__c='Off'));
        insert lstChannel;
        
        List<ASI_MFM_Sub_Channel__c> lstSubChannel = new List<ASI_MFM_Sub_Channel__c>();
        lstSubChannel.add(new ASI_MFM_Sub_Channel__c(Name='SubChannel1', ASI_CRM_CN_Channel__c=lstChannel[0].Id));
        lstSubChannel.add(new ASI_MFM_Sub_Channel__c(Name='SubChannel2', ASI_CRM_CN_Channel__c=lstChannel[1].Id));
        insert lstSubChannel;
        
        string recordTypeID;        
        List<ASI_CRM_AccountsAdditionalField__c> lstCust = new List<ASI_CRM_AccountsAdditionalField__c>();  
        system.runAs(adminUser) {
            recordTypeID = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet1', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[0].Id, ASI_CRM_CN_CCity__c=objCity.Id, ASI_CRM_CN_PG_Head__c=adminUser.id, recordTypeId=recordTypeID, ASI_CRM_CN_Commercial_Team__c = 'Premium'));
            /*insert lstCust[0];      
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet2', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[1].Id, ASI_CRM_CN_Parent_Outlet__c=lstCust[0].id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID));
            insert lstCust[1];        
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet3', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[1].Id, ASI_CRM_CN_Parent_Outlet__c=lstCust[1].id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID));
            insert lstCust[2];*/
            insert lstCust;
        }
        
        recordTypeID = Global_RecordTypeCache.getRTId('ASI_CRM_Division_Security_Setting__cASI_CRM_CN_Division_Security_Setting');
        List<ASI_CRM_Division_Security_Setting__c> lstDSS = new List<ASI_CRM_Division_Security_Setting__c>();  
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Channel Manager', ASI_CRM_On_Off__c='On', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Channel Manager', ASI_CRM_On_Off__c='On', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Channel Manager', ASI_CRM_On_Off__c='Off', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='BA', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Finance', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Regional Trade Marketing', recordTypeId=recordTypeID));    
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='WS Manager', recordTypeId=recordTypeID)); 
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='WS Manager', recordTypeId=recordTypeID)); 
        insert lstDSS;
     
        test.startTest();
        database.executebatch(new ASI_CRM_CN_AccountsAdditionalShare_Batch());
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_CitySalesTargetShareBatch_TEST() {  
        //User adminUser = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND isActive = true Limit 1]; 
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User adminUser = new User(Alias = 'standt', Email='testudc@yahoo.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testudc000000001@yahoo.com');

        ASI_CRM_Division__c objDiv = new ASI_CRM_Division__c(name='Division1');
        insert objDiv;
            
        ASI_CRM_CN_Area__c objArea = new ASI_CRM_CN_Area__c(name='Area1', ASI_CRM_Division__c=objDiv.id);
        insert objArea;
        
        ASI_CRM_City__c objCity = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='City1', ASI_CRM_CN_Area__c=objArea.Id);
        insert objCity;
        
        List<ASI_CRM_CN_Channel__c> lstChannel = new List<ASI_CRM_CN_Channel__c>();          
        lstChannel.add(new ASI_CRM_CN_Channel__c(Name='Channel1', ASI_CRM_CN_On_Off__c='On'));
        lstChannel.add(new ASI_CRM_CN_Channel__c(Name='Channel2', ASI_CRM_CN_On_Off__c='Off'));
        insert lstChannel;
        
        List<ASI_MFM_Sub_Channel__c> lstSubChannel = new List<ASI_MFM_Sub_Channel__c>();
        lstSubChannel.add(new ASI_MFM_Sub_Channel__c(Name='SubChannel1', ASI_CRM_CN_Channel__c=lstChannel[0].Id));
        lstSubChannel.add(new ASI_MFM_Sub_Channel__c(Name='SubChannel2', ASI_CRM_CN_Channel__c=lstChannel[1].Id));
        insert lstSubChannel;
        
        string recordTypeID;        
        List<ASI_CRM_AccountsAdditionalField__c> lstCust = new List<ASI_CRM_AccountsAdditionalField__c>();  
        system.runAs(adminUser) {
            recordTypeID = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet1', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[0].Id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID, ASI_CRM_CN_Commercial_Team__c = 'Premium'));
            /*insert lstCust[0];        
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet2', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[1].Id, ASI_CRM_CN_Parent_Outlet__c=lstCust[0].id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID));
            insert lstCust[1];        
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet3', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[1].Id, ASI_CRM_CN_Parent_Outlet__c=lstCust[1].id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID));
            insert lstCust[2];*/
            insert lstCust;
        }
        
        recordTypeID = Global_RecordTypeCache.getRTId('ASI_CRM_City_Sales_Target__cASI_CRM_CN_City_Sales_Target');
        List<ASI_CRM_City_Sales_Target__c> lstCSTarget = new List<ASI_CRM_City_Sales_Target__c>();  
        lstCSTarget.add(new ASI_CRM_City_Sales_Target__c(ASI_CRM_City__c=objCity.Id, recordTypeId=recordTypeID));
        insert lstCSTarget;
        
        recordTypeID = Global_RecordTypeCache.getRTId('ASI_CRM_Division_Security_Setting__cASI_CRM_CN_Division_Security_Setting');
        List<ASI_CRM_Division_Security_Setting__c> lstDSS = new List<ASI_CRM_Division_Security_Setting__c>();  
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='BA', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Finance', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Regional Trade Marketing', recordTypeId=recordTypeID));    
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='WS Manager', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='WS Manager', recordTypeId=recordTypeID));        
        insert lstDSS;
        
        test.startTest();
        database.executebatch(new ASI_CRM_CN_CitySalesTargetShare_Batch());
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_CityOfficialShareBatch_TEST() {  
        //User adminUser = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND isActive = true Limit 1]; 
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User adminUser = new User(Alias = 'standt', Email='testudc@yahoo.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testudc000000001@yahoo.com');

        ASI_CRM_Division__c objDiv = new ASI_CRM_Division__c(name='Division1');
        insert objDiv;
            
        ASI_CRM_CN_Area__c objArea = new ASI_CRM_CN_Area__c(name='Area1', ASI_CRM_Division__c=objDiv.id);
        insert objArea;
        
        ASI_CRM_City__c objCity = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='City1', ASI_CRM_CN_Area__c=objArea.Id);
        insert objCity;
        
        List<ASI_CRM_CN_Channel__c> lstChannel = new List<ASI_CRM_CN_Channel__c>();          
        lstChannel.add(new ASI_CRM_CN_Channel__c(Name='Channel1', ASI_CRM_CN_On_Off__c='On'));
        lstChannel.add(new ASI_CRM_CN_Channel__c(Name='Channel2', ASI_CRM_CN_On_Off__c='Off'));
        insert lstChannel;
        
        List<ASI_MFM_Sub_Channel__c> lstSubChannel = new List<ASI_MFM_Sub_Channel__c>();
        lstSubChannel.add(new ASI_MFM_Sub_Channel__c(Name='SubChannel1', ASI_CRM_CN_Channel__c=lstChannel[0].Id));
        lstSubChannel.add(new ASI_MFM_Sub_Channel__c(Name='SubChannel2', ASI_CRM_CN_Channel__c=lstChannel[1].Id));
        insert lstSubChannel;
        
        string recordTypeID;        
        List<ASI_CRM_AccountsAdditionalField__c> lstCust = new List<ASI_CRM_AccountsAdditionalField__c>();  
        system.runAs(adminUser) {
            recordTypeID = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet1', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[0].Id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID, ASI_CRM_CN_Commercial_Team__c = 'Premium'));
            /*insert lstCust[0];        
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet2', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[1].Id, ASI_CRM_CN_Parent_Outlet__c=lstCust[0].id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID));
            insert lstCust[1];        
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet3', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[1].Id, ASI_CRM_CN_Parent_Outlet__c=lstCust[1].id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID));
            insert lstCust[2];*/
            insert lstCust;
        }
        
        recordTypeID = Global_RecordTypeCache.getRTId('ASI_CRM_City_Official__cASI_CRM_CN_City_Official');
        List<ASI_CRM_City_Official__c> lstCityOff = new List<ASI_CRM_City_Official__c>();  
        lstCityOff.add(new ASI_CRM_City_Official__c(ASI_CRM_City__c=objCity.Id, recordTypeId=recordTypeID));
        insert lstCityOff;
        
        recordTypeID = Global_RecordTypeCache.getRTId('ASI_CRM_Division_Security_Setting__cASI_CRM_CN_Division_Security_Setting');
        List<ASI_CRM_Division_Security_Setting__c> lstDSS = new List<ASI_CRM_Division_Security_Setting__c>();  
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='BA', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Finance', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Regional Trade Marketing', recordTypeId=recordTypeID));    
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='WS Manager', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='WS Manager', recordTypeId=recordTypeID));        
        insert lstDSS;
        
        test.startTest();
        database.executebatch(new ASI_CRM_CN_CityOfficeShare_Batch());
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_WSTargetShareBatch_TEST() {  
        //User adminUser = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User adminUser = new User(Alias = 'standt', Email='testudc@yahoo.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testudc000000001@yahoo.com');
                
        ASI_CRM_Division__c objDiv = new ASI_CRM_Division__c(name='Division1');
        insert objDiv;
            
        ASI_CRM_CN_Area__c objArea = new ASI_CRM_CN_Area__c(name='Area1', ASI_CRM_Division__c=objDiv.id);
        insert objArea;
        
        ASI_CRM_City__c objCity = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='City1', ASI_CRM_CN_Area__c=objArea.Id);
        insert objCity;
        
        List<ASI_CRM_CN_Channel__c> lstChannel = new List<ASI_CRM_CN_Channel__c>();          
        lstChannel.add(new ASI_CRM_CN_Channel__c(Name='Channel1', ASI_CRM_CN_On_Off__c='On'));
        lstChannel.add(new ASI_CRM_CN_Channel__c(Name='Channel2', ASI_CRM_CN_On_Off__c='Off'));
        insert lstChannel;
        
        List<ASI_MFM_Sub_Channel__c> lstSubChannel = new List<ASI_MFM_Sub_Channel__c>();
        lstSubChannel.add(new ASI_MFM_Sub_Channel__c(Name='SubChannel1', ASI_CRM_CN_Channel__c=lstChannel[0].Id));
        lstSubChannel.add(new ASI_MFM_Sub_Channel__c(Name='SubChannel2', ASI_CRM_CN_Channel__c=lstChannel[1].Id));
        insert lstSubChannel;
        
        string recordTypeID;        
        List<ASI_CRM_AccountsAdditionalField__c> lstCust = new List<ASI_CRM_AccountsAdditionalField__c>();  
        system.runAs(adminUser) {
            recordTypeID = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet1', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[0].Id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID, ASI_CRM_CN_Commercial_Team__c = 'Premium'));
            /*insert lstCust[0];        
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet2', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[1].Id, ASI_CRM_CN_Parent_Outlet__c=lstCust[0].id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID));
            insert lstCust[1];        
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet3', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[1].Id, ASI_CRM_CN_Parent_Outlet__c=lstCust[1].id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID));
            insert lstCust[2];*/
            insert lstCust;
        }
       
        recordTypeID = Global_RecordTypeCache.getRTId('ASI_CRM_WS_Target__cASI_CRM_CN_WS_Target');
        List<ASI_CRM_WS_Target__c> lstWSTarget = new List<ASI_CRM_WS_Target__c>();  
        lstWSTarget.add(new ASI_CRM_WS_Target__c(ASI_CRM_T2_WS__c=lstCust[0].id, recordTypeId=recordTypeID));
        insert lstWSTarget;
        
        recordTypeID = Global_RecordTypeCache.getRTId('ASI_CRM_Division_Security_Setting__cASI_CRM_CN_Division_Security_Setting');
        List<ASI_CRM_Division_Security_Setting__c> lstDSS = new List<ASI_CRM_Division_Security_Setting__c>();  
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='WS Manager', recordTypeId=recordTypeID));        
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='WS Manager', recordTypeId=recordTypeID)); 
        insert lstDSS;
        
        test.startTest();
        database.executebatch(new ASI_CRM_CN_WSTargetShare_Batch());
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_ContractShare_TEST() {  
        //User adminUser = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND isActive = true Limit 1]; 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User adminUser = new User(Alias = 'standt', Email='testudc@yahoo.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testudc000000001@yahoo.com');

        ASI_CRM_Division__c objDiv = new ASI_CRM_Division__c(name='Division1');
        insert objDiv;
            
        ASI_CRM_CN_Area__c objArea = new ASI_CRM_CN_Area__c(name='Area1', ASI_CRM_Division__c=objDiv.id);
        insert objArea;
        
        ASI_CRM_City__c objCity = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='City1', ASI_CRM_CN_Area__c=objArea.Id);
        insert objCity;
        
        List<ASI_CRM_CN_Channel__c> lstChannel = new List<ASI_CRM_CN_Channel__c>();          
        lstChannel.add(new ASI_CRM_CN_Channel__c(Name='Channel1', ASI_CRM_CN_On_Off__c='On'));
        lstChannel.add(new ASI_CRM_CN_Channel__c(Name='Channel2', ASI_CRM_CN_On_Off__c='Off'));
        insert lstChannel;
        
        List<ASI_MFM_Sub_Channel__c> lstSubChannel = new List<ASI_MFM_Sub_Channel__c>();
        lstSubChannel.add(new ASI_MFM_Sub_Channel__c(Name='SubChannel1', ASI_CRM_CN_Channel__c=lstChannel[0].Id));
        lstSubChannel.add(new ASI_MFM_Sub_Channel__c(Name='SubChannel2', ASI_CRM_CN_Channel__c=lstChannel[1].Id));
        insert lstSubChannel;
        
        string recordTypeID;        
        List<ASI_CRM_AccountsAdditionalField__c> lstCust = new List<ASI_CRM_AccountsAdditionalField__c>();  
        system.runAs(adminUser) {
            recordTypeID = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet1', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[0].Id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID, ASI_CRM_CN_Commercial_Team__c = 'Premium'));
            /*insert lstCust[0];        
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet2', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[1].Id, ASI_CRM_CN_Parent_Outlet__c=lstCust[0].id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID));
            insert lstCust[1];        
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet3', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[1].Id, ASI_CRM_CN_Parent_Outlet__c=lstCust[1].id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID));
            insert lstCust[2];*/
            insert lstCust;
        }
        
        recordTypeID = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet');        
        list<Account> lstAcc = new list<Account>();
        lstAcc.add(new Account(RecordTypeId=recordTypeID, Name='Acc'));
        insert lstAcc;
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> lstRNO = new list<ASI_HK_CRM_Running_Number__c>();
        lstRNO.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            lstRNO.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            lstRNO.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            lstRNO.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert lstRNO;
        
        List<ASI_TH_CRM_Contract__c> lstContract = new List<ASI_TH_CRM_Contract__c>();  
        recordTypeID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        //lstContract.add(new ASI_TH_CRM_Contract__c(Name='Contract1', ASI_TH_CRM_Outlet__c=lstAcc[0].Id, ASI_CRM_CN_Outlet_WS__c=lstCust[2].id, recordTypeId=recordTypeID));
        lstContract.add(new ASI_TH_CRM_Contract__c(Name='Contract1', ASI_TH_CRM_Outlet__c=lstAcc[0].Id, ASI_CRM_CN_Outlet_WS__c=lstCust[0].id, recordTypeId=recordTypeID));
        insert lstContract;
        
        recordTypeID = Global_RecordTypeCache.getRTId('ASI_CRM_Division_Security_Setting__cASI_CRM_CN_Division_Security_Setting');
        List<ASI_CRM_Division_Security_Setting__c> lstDSS = new List<ASI_CRM_Division_Security_Setting__c>();  
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Channel Manager', ASI_CRM_On_Off__c='On', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Channel Manager', ASI_CRM_On_Off__c='On', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Channel Manager', ASI_CRM_On_Off__c='Off', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='BA', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Finance', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Regional Trade Marketing', recordTypeId=recordTypeID));    
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='WS Manager', recordTypeId=recordTypeID)); 
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='WS Manager', recordTypeId=recordTypeID));     
        insert lstDSS;
        
        test.startTest();
        database.executebatch(new ASI_CRM_CN_ContractShare_Batch());
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_PaymentRequestShare_TEST() {  
        //User adminUser = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User adminUser = new User(Alias = 'standt', Email='testudc@yahoo.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testudc000000001@yahoo.com');
                
        ASI_CRM_Division__c objDiv = new ASI_CRM_Division__c(name='Division1');
        insert objDiv;
            
        ASI_CRM_CN_Area__c objArea = new ASI_CRM_CN_Area__c(name='Area1', ASI_CRM_Division__c=objDiv.id);
        insert objArea;
        
        ASI_CRM_City__c objCity = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='City1', ASI_CRM_CN_Area__c=objArea.Id);
        insert objCity;
        
        List<ASI_CRM_CN_Channel__c> lstChannel = new List<ASI_CRM_CN_Channel__c>();          
        lstChannel.add(new ASI_CRM_CN_Channel__c(Name='Channel1', ASI_CRM_CN_On_Off__c='On'));
        lstChannel.add(new ASI_CRM_CN_Channel__c(Name='Channel2', ASI_CRM_CN_On_Off__c='Off'));
        insert lstChannel;
        
        List<ASI_MFM_Sub_Channel__c> lstSubChannel = new List<ASI_MFM_Sub_Channel__c>();
        lstSubChannel.add(new ASI_MFM_Sub_Channel__c(Name='SubChannel1', ASI_CRM_CN_Channel__c=lstChannel[0].Id));
        lstSubChannel.add(new ASI_MFM_Sub_Channel__c(Name='SubChannel2', ASI_CRM_CN_Channel__c=lstChannel[1].Id));
        insert lstSubChannel;
        
        string recordTypeID;        
        List<ASI_CRM_AccountsAdditionalField__c> lstCust = new List<ASI_CRM_AccountsAdditionalField__c>();  
        system.runAs(adminUser) {
            recordTypeID = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet1', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[0].Id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID, ASI_CRM_CN_Commercial_Team__c = 'Premium'));
            /*insert lstCust[0];        
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet2', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[1].Id, ASI_CRM_CN_Parent_Outlet__c=lstCust[0].id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID));
            insert lstCust[1];        
            lstCust.add(new ASI_CRM_AccountsAdditionalField__c(Name='Outlet3', ASI_CRM_CN_Sub_Channel__c=lstSubChannel[1].Id, ASI_CRM_CN_Parent_Outlet__c=lstCust[1].id, ASI_CRM_CN_CCity__c=objCity.Id, recordTypeId=recordTypeID));
            insert lstCust[2];*/
            insert lstCust;
        }
        
        List<ASI_TH_CRM_PaymentRequest__c> lstPR = new List<ASI_TH_CRM_PaymentRequest__c>();  
        recordTypeID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        //lstPR.add(new ASI_TH_CRM_PaymentRequest__c(Name='PR1', ASI_CRM_CN_OutletWS__c=lstCust[2].id, recordTypeId=recordTypeID));
        lstPR.add(new ASI_TH_CRM_PaymentRequest__c(Name='PR1', ASI_CRM_CN_OutletWS__c=lstCust[0].id, recordTypeId=recordTypeID));
        insert lstPR;
        
        recordTypeID = Global_RecordTypeCache.getRTId('ASI_CRM_Division_Security_Setting__cASI_CRM_CN_Division_Security_Setting');
        List<ASI_CRM_Division_Security_Setting__c> lstDSS = new List<ASI_CRM_Division_Security_Setting__c>();  
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Channel Manager', ASI_CRM_On_Off__c='On', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Channel Manager', ASI_CRM_On_Off__c='On', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Channel Manager', ASI_CRM_On_Off__c='Off', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='BA', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Finance', recordTypeId=recordTypeID));
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='Regional Trade Marketing', recordTypeId=recordTypeID));    
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='WS Manager', recordTypeId=recordTypeID));  
        lstDSS.add(new ASI_CRM_Division_Security_Setting__c(ASI_CRM_User__c=adminUser.id, ASI_CRM_Division__c=objDiv.id, ASI_CRM_Role__c='WS Manager', recordTypeId=recordTypeID));     
        insert lstDSS;
        
        test.startTest();
        database.executebatch(new ASI_CRM_CN_PaymentRequestShare_Batch());
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_ContractShareSchd_TEST() {
        test.startTest();
        ASI_CRM_CN_ContractShare_Schd myClass = new ASI_CRM_CN_ContractShare_Schd();   
        String chron = '0 0 23 * * ?';       
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }
}