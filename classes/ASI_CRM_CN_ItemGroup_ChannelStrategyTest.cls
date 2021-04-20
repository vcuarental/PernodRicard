@isTest
private class ASI_CRM_CN_ItemGroup_ChannelStrategyTest {
    static testMethod void testMethod1() {
        
    	try{
    	ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c();
    	itemGroup.Name = 'TestItemGroupName';
    	itemGroup.ASI_MFM_Item_Group_Code__c = '123456';
    	insert itemGroup;

    	ASI_CRM_CN_Channel_Strategy__c cs = new ASI_CRM_CN_Channel_Strategy__c();
    	cs.ASI_NPL_Item_Group__c = itemGroup.Id;
    	insert cs;

    	ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c();
    	channel.Name = 'TestChannelName';
    	insert channel;

    	ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c();
    	subChannel.Name = 'TestsubChannelName';
    	insert subChannel;

    	ASI_MFM_Channel_Mapping__c  mapping = new ASI_MFM_Channel_Mapping__c();
    	mapping.ASI_MFM_Sell_In_Channel__c = 'PT_WS';
    	mapping.ASI_MFM_Sell_In_Region__c = 'NORTH';
    	mapping.ASI_MFM_Intake_Channel__c = channel.Id;
    	mapping.ASI_MFM_Intake_Sub_Channel__c = subChannel.Id;
    	mapping.ASI_MFM_Intake_Region__c = 'NORTH';
    	insert mapping;

    	ASI_CRM_CN_Channel_Strategy_Line_Item__c item = new ASI_CRM_CN_Channel_Strategy_Line_Item__c();
    	item.ASI_CRM_CN_Channel_Strategy__c = cs.Id;
    	item.ASI_NPL_Channel__c = channel.Id;
    	item.ASI_NPL_Sub_Channel__c = subChannel.Id;
    	item.ASI_NPL_Region__c = 'NORTH';
    	item.ASI_NPL_Type__c = 'Sub-Channel Entitlement';
    	item.ASI_NPL_Entitled__c = true;
    	insert item;
    	}catch(Exception e){}
    	
    	Test.startTest();
    	ASI_CRM_CN_ItemGroup_Channel_Strategy.requestInfo requestbody = new ASI_CRM_CN_ItemGroup_Channel_Strategy.requestInfo();
    	ASI_CRM_CN_ItemGroup_Channel_Strategy.ResponeInfo responebody = new ASI_CRM_CN_ItemGroup_Channel_Strategy.ResponeInfo();
        String sellinChannels = 'PT_WS';
    	String sellinRegions = 'NORTH';
    	requestBody.sellinChannel = sellinChannels.split(',');
    	requestBody.sellinRegion = sellinRegions.split(',');
    	requestBody.lastModified_Dt_from = '2020-06-01 00:00:00';
        DateTime dt = Datetime.now().addDays(2);

    	requestBody.lastModified_Dt_to = String.valueOf(dt);

    	String myJSON = JSON.serialize(requestbody);

    	RestRequest request = new RestRequest();
        request.requestUri ='https://pernod-ricard--asisb5conf.my.salesforce.com/services/apexrest/ASI_CRM_CN_ItemGroup_Channel_Strategy';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);         
        RestContext.request = request;

        responebody = ASI_CRM_CN_ItemGroup_Channel_Strategy.doPost();
        Test.stopTest();

    }
}