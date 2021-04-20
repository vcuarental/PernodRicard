/*Created by Twinkle Li @11/11/2104
/*
*/
@isTest
public class ASI_CRM_CN_UpdateChannelStrategy_Test {

     static testMethod void ASI_CRM_CN_updateChannelStrategyBatch_TEST() {     
         Account account_outlet = new Account(
            Name='TestAcc',
            recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'),
            ASI_MFM_Customer_Supplier_Number__c='123',
            ASI_MFM_Customer_Supplier_Name__c='SupplierName'
        );
        insert account_outlet;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY');
        ASI_CRM_City__c city2 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY2');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='testChannel',ASI_CRM_CN_On_Off__c='On');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(Name='testSubChannel',ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Brand_T1_Group__c gp = new ASI_CRM_CN_Brand_T1_Group__c(Name='TEST');
        insert gp; 
        
        insert new ASI_CRM_AccountsAdditionalField__c(Name = 'Customer1', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_Account__c=account_outlet.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=gp.Name);
         
        Date myDate = date.today();
        List<ASI_CRM_CN_Channel_Strategy__c> lstChannelStrategy = new List<ASI_CRM_CN_Channel_Strategy__c>();         
        lstChannelStrategy.add(new ASI_CRM_CN_Channel_Strategy__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Strategy__cASI_CRM_CN_Area'), ASI_CRM_CN_Status__c = 'Final', ASI_CRM_CN_Fiscal_Year__c = String.valueof(myDate.year()) +'/'+ String.valueof(myDate.year()+1), ASI_CRM_CN_Sub_Channel__c=subChannel.Id));        
        lstChannelStrategy.add(new ASI_CRM_CN_Channel_Strategy__c(RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Strategy__cASI_CRM_CN_National'), ASI_CRM_CN_Status__c = 'Final', ASI_CRM_CN_Fiscal_Year__c = String.valueof(myDate.year()) +'/'+ String.valueof(myDate.year()+1), ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert lstChannelStrategy;
     
        database.executebatch(new ASI_CRM_CN_UpdateChannelStrategy_Batch());
     }
     
     static testMethod void ASI_CRM_CN_updateChannelStrategySchd_TEST() {
        test.startTest();
        ASI_CRM_CN_UpdateChannelStrategy_Schd myClass = new ASI_CRM_CN_UpdateChannelStrategy_Schd();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
     }
}