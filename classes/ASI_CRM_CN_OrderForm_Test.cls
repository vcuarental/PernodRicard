@isTest
private class ASI_CRM_CN_OrderForm_Test {
	
    Private static List<ASI_MFM_Sub_brand__c> tmpSB = new List<ASI_MFM_Sub_brand__c>();
    
    Private static User tempU = [select id from user where CompanyName = 'Pernod Ricard China' limit 1];
    
    Private static List<ASI_CRM_CN_Brand_Group__c> tmpBrandGroup = new List<ASI_CRM_CN_Brand_Group__c>();
    
    Private Static List<ASI_CRM_Order_Form__c> tmpOrderForm = new List<ASI_CRM_Order_Form__c>();
    
    Private Static List<ASI_CRM_Order_Form_Detail__c> tmpOrderFormLineItem = new List<ASI_CRM_Order_Form_Detail__c>();
    
    Private Static List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
    
    Private Static List<ASI_CRM_CN_T1_Price__c> tmpT1Price = new List<ASI_CRM_CN_T1_Price__c>();
    
    Private Static List<ASI_CRM_Order_Form_Customer_Relationship__c> tmpOFCR = new List<ASI_CRM_Order_Form_Customer_Relationship__c>();
    
    Private Static List<ASI_CRM_AccountsAdditionalField__c> tmpCustomer = new List<ASI_CRM_AccountsAdditionalField__c>();
    
    Private Static List<ASI_CRM_Item_Group_Customer_Price__c> tmpIGCP = new List<ASI_CRM_Item_Group_Customer_Price__c>();
    
    Private static testMethod void testMethod1(){
        
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
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(
            Name = 'OFF MOT',
            ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
            ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
            ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
            ASI_CRM_External_ID__c = 'CN_OFF MOT',
            ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF', ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert newChannel;
        
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'Test1', ASI_CRM_CN_Chi_Name__c = 'Test1', ASI_CRM_CN_Commercial_Team__c = 'Prestige', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Customer_Type_Picklist__c='MOT', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel.Id));
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'Test2', ASI_CRM_CN_Chi_Name__c = 'Test2', ASI_CRM_CN_Commercial_Team__c = 'Prestige', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Customer_Type_Picklist__c='MOT', ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel.Id));
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'Test3', ASI_CRM_CN_Chi_Name__c = 'Test3', ASI_CRM_CN_Commercial_Team__c = 'Prestige', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Customer_Type_Picklist__c='MOT', ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
        insert tmpCustomer;
        
        tmpSB.add(new ASI_MFM_Sub_brand__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')
                                           , Name = 'TestSB'
                                           , OwnerId = tempU.id
                                           , ASI_MFM_Sub_brand_Code__c = '1'
                                           , ASI_HK_CRM_English_Name__c = 'TestSB'
                                          ));
        insert tmpSB;
        
        tmpBrandGroup.add(new ASI_CRM_CN_Brand_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_Group__cASI_CRM_CN_Brand_Group')
                                                        , Name = 'TestBrandGroup'
                                                        , OwnerId = tempU.id
                                                        , ASI_CRM_CN_English_Name__c = 'TestBrandGroup'
                                                        , ASI_CRM_CN_Chinese_Name__c = 'TestBrandGroup'
                                                        , ASI_CRM_CN_Sequence2__c = 10
                                                        , ASI_CRM_Brand_Group_Code__c = '1'
                                                       ));
        insert tmpBrandGroup;
        
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , OwnerID = tempU.id
                                                  ));
        insert tmpItemGroup;
        
        tmpT1Price.add(new ASI_CRM_CN_T1_Price__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_T1_Price__cASI_CRM_CN_T1_Price')
                                                  , ASI_CRM_CN_Effective_Date__c = date.today().addDays(-1)
                                                  , ASI_CRM_CN_T1_Price__c = 1
                                                  , ASI_CRM_CN_Item_Group__c = tmpItemGroup[0].id
                                                 ));
		insert tmpT1Price;
        
        tmpIGCP.add(new ASI_CRM_Item_Group_Customer_Price__c(OwnerId = tempU.id
                                                             , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Customer_Price__cASI_CRM_CN_ItemGroupCustomerPrice')
                                                             , ASI_CRM_Customer__c = tmpCustomer[0].id
                                                             , ASI_CRM_Item_Group__c = tmpItemGroup[0].id
                                                             , ASI_CRM_Unit_Price_BT__c = 1
                                                            ));
        insert tmpIGCP;
        update tmpIGCP;
        
        test.startTest();
        
        tmpOrderForm.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                                                   , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                                                   , ASI_CRM_Order_Form_Type__c = 'Normal Item'
                                                   , ASI_CRM_T1_Master__c = TRUE
                                                   , OwnerID = tempU.id
                                                  ));
        tmpOrderForm.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                                                   , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                                                   , ASI_CRM_Order_Form_Type__c = 'RTD'
                                                   , ASI_CRM_T1_Master__c = TRUE
                                                   , OwnerID = tempU.id
                                                  ));
    	insert tmpOrderForm;
        
        tmpOrderFormLineItem.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                                                                  , ASI_CRM_Available__c = TRUE
                                                                  , ASI_CRM_Order_Form__c = tmpOrderForm[0].id
                                                                  , ASI_CRM_Product_Name__c = tmpItemGroup[0].id
                                                                  , ASI_CRM_Remark__c = 'TestRemark'
                                                                 ));
        tmpOrderFormLineItem.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                                                                  , ASI_CRM_Available__c = TRUE
                                                                  , ASI_CRM_Order_Form__c = tmpOrderForm[1].id
                                                                  , ASI_CRM_Product_Name__c = tmpItemGroup[0].id
                                                                  , ASI_CRM_Remark__c = 'TestRemark'
                                                                 ));
        
        insert tmpOrderFormLineItem;
        
        tmpOFCR.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship')
                                                                    , ASI_CRM_Order_Form__c = tmpOrderForm[0].id
                                                                    , ASI_CRM_Customer__c = tmpCustomer[0].id
                                                                   ));
        tmpOFCR.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship')
                                                                    , ASI_CRM_Order_Form__c = tmpOrderForm[1].id
                                                                    , ASI_CRM_Customer__c = tmpCustomer[0].id
                                                                   ));
        insert tmpOFCR;
        update tmpOFCR;
        
        update tmpOrderForm;
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;
        
        Test.setCurrentPage(Page.ASI_CRM_CN_OrderFormRequestPage);
        Apexpages.currentPage().getParameters().put('id', tmpOrderForm[0].id);
        Apexpages.StandardSetController sc = new apexpages.StandardSetController(tmpOrderForm);
        ASI_CRM_CN_OrderFormRequestCtrller orderForm = new ASI_CRM_CN_OrderFormRequestCtrller(sc);
        
        ASI_CRM_CN_OrderFormRequestCtrller.lineItemList(tmpOrderForm[0].id);
        ASI_CRM_CN_OrderFormRequestCtrller.normalProductList(tmpOrderForm[0].id, '', FALSE);
        
        List<ASI_CRM_CN_OrderFormRequestCtrller.ASI_HK_CRM_SOLineItem> tmpSOLineItem = new List<ASI_CRM_CN_OrderFormRequestCtrller.ASI_HK_CRM_SOLineItem>();
        
        ASI_CRM_CN_OrderFormRequestCtrller.ASI_HK_CRM_SOLineItem tmpSOLineItem2 = new ASI_CRM_CN_OrderFormRequestCtrller.ASI_HK_CRM_SOLineItem();
        
        tmpSOLineItem2.skuId = tmpItemGroup[0].id;
        tmpSOLineItem2.remark = 'TestRemark';
        tmpSOLineItem2.available = TRUE;
        
        tmpSOLineItem.add(tmpSOLineItem2);
        
        ASI_CRM_CN_OrderFormRequestCtrller.ASI_HK_CRM_SOLineItem tmpSOLineItem3 = new ASI_CRM_CN_OrderFormRequestCtrller.ASI_HK_CRM_SOLineItem();
        
        tmpSOLineItem3.skuId = tmpItemGroup[0].id;
        tmpSOLineItem3.remark = 'TestRemark';
        tmpSOLineItem3.available = TRUE;
        tmpSOLineItem3.id = tmpOrderFormLineItem[0].id;
        
        tmpSOLineItem.add(tmpSOLineItem3);
        
        ASI_CRM_CN_OrderFormRequestCtrller.saveChanges(tmpOrderForm[0].id, tmpSOLineItem);
        
        orderForm.getBrandType();
        
        Test.setCurrentPage(Page.ASI_CRM_CN_OrderFormPDF);
        Apexpages.currentPage().getParameters().put('id', tmpCustomer[0].id);
        Apexpages.StandardController sc2 = new apexpages.StandardController(tmpCustomer[0]);
        ASI_CRM_CN_OrderFormPDFCtrller ofPDF = new ASI_CRM_CN_OrderFormPDFCtrller(sc2);
        ofPDF.currentHeaderId = tmpCustomer[0].id;
        ofPDF.dummyVar = FALSE;
		ofPDF.dummyI = FALSE;
        ofPDF.orderFormType = 'RTD';//20161027 Ben @ Elufa
        ofPDF.init();
        ofPDF.initI();
        
        ASI_CRM_CN_OrderForm_CSV_Controller ofCSV = new ASI_CRM_CN_OrderForm_CSV_Controller(sc2);
        ofCSV.currentHeaderId = tmpCustomer[0].id;
        ofCSV.dummyVar = FALSE;
		ofCSV.dummyI = FALSE;
        ofCSV.orderFormType = 'RTD';//20161027 Ben @ Elufa
        ofCSV.init();
        ofCSV.initI();
        test.stopTest();
    }
}