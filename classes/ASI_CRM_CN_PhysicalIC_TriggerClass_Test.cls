@isTest
private class ASI_CRM_CN_PhysicalIC_TriggerClass_Test {
    
	static testMethod void testtiggerclass(){
    	
        User tempU = [select id from user where CompanyName = 'Pernod Ricard China' limit 1];
        //***creat account** / 
        Account account_outlet = new Account(
            Name='TestAcc',
            recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_CRM_CN_Wholesales_CN'),
            ASI_MFM_Customer_Supplier_Number__c='123',
            ASI_MFM_Customer_Supplier_Name__c='SupplierName'
        );
        insert account_outlet;
        
        Account account_outlet2 = new Account(
            Name='TestAcc2',
            recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_CRM_CN_Wholesales_CN'),
            ASI_MFM_Customer_Supplier_Number__c='1232',
            ASI_MFM_Customer_Supplier_Name__c='SupplierName2'
        );
        insert account_outlet2;
        
        ASI_HK_CRM_Running_Number__c RunningNo = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_MFM_CN_Event', ASI_HK_CRM_Running_Number__c = 1, ASI_HK_CRM_Format__c = 'Event-{YY}{000000}', ASI_HK_CRM_Fiscal_Year__c = 2014, ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number'));
		insert RunningNo;
        //***create account additionalfield ***
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(name = 'testDivision', ASI_CRM_CN_RTMK__c = tempU.id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name = 'testarea', ASI_CRM_Division__c = division.id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_Area__c = area.id,ASI_CRM_CN_City_Code__c='TESTCITY');
        ASI_CRM_City__c city2 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY2');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='testChannel',ASI_CRM_CN_On_Off__c='On');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(Name='testSubChannel',ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Brand_T1_Group__c g = new ASI_CRM_CN_Brand_T1_Group__c(Name='TEST');
        insert g;        
        
        
        
        ASI_CRM_AccountsAdditionalField__c childAA =  new ASI_CRM_AccountsAdditionalField__c(OwnerId = tempU.id, ASI_CRM_CN_PG_Head__c = tempU.id, Name='TEST3', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_Account__c=account_outlet.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name);
        insert childAA;
        
        test.startTest();
        
        ASI_CRM_Physical_Inventory_Check__c tmpObj = new ASI_CRM_Physical_Inventory_Check__c(ASI_CRM_WS__c = childAA.id
                                                                                             , RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Physical_Inventory_Check__cASI_CRM_CN_Inventory_Check')
                                                                                             , ASI_CRM_Month__c = date.today().addMonths(-2)
                                                                                            );
        
		ASI_MFM_Item_Group__c tmpItemGroup = new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                                       , Name = 'TestItemGroup'
                                                                       , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                                       , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                                       , OwnerID = tempU.id
                                                                       , ASI_CRM_CN_Consumer_web_Code_C__c = 'TestItemGroupCode'
                                                                       , ASI_CRM_CN_Consumer_Website__c = true
                                                  					  );
        insert tmpItemGroup;
        
        ASI_MFM_Item_Group__c tmpItemGroup2 = new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                                       , Name = 'TestItemGroup2'
                                                                       , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode2'
                                                                       , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                                       , OwnerID = tempU.id
                                                                        , ASI_CRM_CN_Consumer_web_Code_C__c = 'TestItemGroupCode2'
                                                                       , ASI_CRM_CN_Consumer_Website__c = true
                                                  					  );
        insert tmpItemGroup2;
		        
        insert tmpObj;
        update tmpObj;
        
        ASI_CRM_Physical_Inventory_Check_Item__c tmpLi = new ASI_CRM_Physical_Inventory_Check_Item__c(ASI_CRM_Physical_Inventory_Check__c = tmpObj.id
                                                                                                      , RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Physical_Inventory_Check_Item__cASI_CRM_CN_Physical_Inventory_Check_Item')
                                                                                                      , ASI_CRM_Item_Group__c = tmpItemGroup.id
                                                                                                     );
        ASI_CRM_Physical_Inventory_Check_Item__c tmpLi2 = new ASI_CRM_Physical_Inventory_Check_Item__c(ASI_CRM_Physical_Inventory_Check__c = tmpObj.id
                                                                                                      , RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Physical_Inventory_Check_Item__cASI_CRM_CN_Physical_Inventory_Check_Item')
                                                                                                      , ASI_CRM_Item_Group__c = tmpItemGroup2.id
                                                                                                     );
        insert tmpLi2;
        insert tmpLi;
        
        system.schedule('testschedule', '0 0 0 15 3 ? 2022', new ASI_CRM_CN_PhysicalInventory_Schd());
        
        test.stopTest();
    }
}