@isTest
private class ASI_CRM_CN_DashBoard_Test {

    Private Static TestMethod void testDashNoardController() {

        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS')));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS')));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
        insert a2s;
        
        List<ASI_CRM_City_Sales_Target__c> tmpCitySalesTar = new List<ASI_CRM_City_Sales_Target__c>();
        tmpCitySalesTar.add(new ASI_CRM_City_Sales_Target__c(ASI_CRM_City__c = city.id, ASI_CRM_Target_Date__c = date.today(), ASI_CRM_Target_Qty_9L__c = 10000, recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_City_Sales_Target__cASI_CRM_CN_City_Sales_Target')));
        tmpCitySalesTar.add(new ASI_CRM_City_Sales_Target__c(ASI_CRM_City__c = city.id, ASI_CRM_Target_Date__c = date.today().addMonths(-1), ASI_CRM_Target_Qty_9L__c = 10000, recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_City_Sales_Target__cASI_CRM_CN_City_Sales_Target')));
        tmpCitySalesTar.add(new ASI_CRM_City_Sales_Target__c(ASI_CRM_City__c = city.id, ASI_CRM_Target_Date__c = date.today(), ASI_CRM_Target_Qty_9L__c = 10000, recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_City_Sales_Target__cASI_CRM_CN_City_Sales_Target')));
        tmpCitySalesTar.add(new ASI_CRM_City_Sales_Target__c(ASI_CRM_City__c = city.id, ASI_CRM_Target_Date__c = date.today().addMonths(-1), ASI_CRM_Target_Qty_9L__c = 10000, recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_City_Sales_Target__cASI_CRM_CN_City_Sales_Target')));
        
        insert tmpCitySalesTar;
        
        test.startTest();
        
        ASI_CRM_CN_DashBoardController.getRecord();
        
        test.stopTest();
    } 
    
}