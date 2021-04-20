@isTest
public class ASI_CRM_CN_updateContractChannel_Test
{
    static testMethod void testBatch()
    {
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_Province__c province = new ASI_CRM_Province__c(Name='A');
        insert province;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id, ASI_CRM_CN_Province__c=province.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel1 = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, ASI_CRM_For_Contract__c = true, Name='Test1',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel1;
        
        ASI_CRM_CN_Channel__c newChannel2 = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, ASI_CRM_For_Contract__c = true, Name='Test2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='ON');
        insert newChannel2;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            ASI_CRM_CN_NewChannel__c=newChannel1.Id,
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            ASI_CRM_CN_NewChannel__c=newChannel1.Id,
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c,ASI_CRM_CN_NewChannel__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[1].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_Status__c='Final',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Description__c='Description',
            ASI_CRM_CN_Bottle_Collection_Rate__c=10,
            ASI_CRM_CN_Vol_Budget_LE__c=10,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract')
        ));
        insert cts[0];
        
        ASI_CRM_AccountsAdditionalField__History test1 = new ASI_CRM_AccountsAdditionalField__History(ParentId=a2s[1].Id, Field = 'ASI_CRM_CN_NewChannel__c');
        ASI_CRM_AccountsAdditionalField__History test2 = new ASI_CRM_AccountsAdditionalField__History(ParentId=a2s[1].Id, Field = 'ASI_CRM_CN_NewChannel__c');
        insert test1;
        insert test2;
        
        test.startTest();
        database.executebatch(new ASI_CRM_CN_updateContractChannel_Batch());
        test.stopTest();
    }
}