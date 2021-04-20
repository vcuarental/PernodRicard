@isTest
public class ASI_CRM_SG_Submit_to_PRS_Wholesaler_Test {
	  Private Class salesOrderClass{
        private list<salesOrderStructure> salesOrderlist = new List<salesOrderStructure>();
    }
    
    Private Class salesOrderStructure{
        
        Private String Outlet;
        Private String recordTypeID;
        Private String recordID;
        Private String requestedDate;
        Private String orderDate;
        Private Boolean RTD;
        Private Boolean premium;
        Private String contactPerson;
        Private String otherRequirement;
        Private String TelMobile;
        Private String Address;
    }
        
        
    
    Private Static List<ASI_KOR_Sales_Order_Request__c> tmpSalesOrder = new List<ASI_KOR_Sales_Order_Request__c>();
    
    Private Static List<ASI_KOR_Sales_Order_Transaction__c> tmpSalesOrderLineItem = new List<ASI_KOR_Sales_Order_Transaction__c>();
  
    Private Static List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
        
    Private Static List<ASI_CRM_AccountsAdditionalField__c> tmpCustomer = new List<ASI_CRM_AccountsAdditionalField__c>();
        
    Private Static List<ASI_MFM_Sub_Channel__c> tmpSubChannel = new List<ASI_MFM_Sub_Channel__c>();
    
    public static testMethod void test1(){
    
        
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
        
        tmpSubChannel.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id));
        tmpSubChannel.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c=channel.Id));
        
        insert tmpSubChannel;
        
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
        
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test1', ASI_CRM_CN_Chi_Name__c = 'test1', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '555', ASI_CRM_CN_JDE_Code__c = '111', ASI_CRM_CN_JDE_Code_Premium__c = '456', ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_CCity__c=city.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel.Id));
    insert tmpCustomer;

        
      tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , ASI_CRM_Allocation_Information__c = true//20170217 Elufa
                                                  ));
        insert tmpItemGroup;

        
        tmpSalesOrder.add(new ASI_KOR_Sales_Order_Request__c( ASI_KOR_Order_Status__c = 'Open'
                                                             , ASI_CRM_CN_Customer__c = tmpCustomer[0].id
                                                             , ASI_CRM_CN_RTD__c = FALSE
                                                             ,ASI_CRM_SG_Order_Date__c = date.today()
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_SG_Wholesaler')
                                                            ));
        tmpSalesOrder.add(new ASI_KOR_Sales_Order_Request__c( ASI_KOR_Order_Status__c = 'New'
                                                             , ASI_CRM_CN_Customer__c = tmpCustomer[0].id
                                                             , ASI_CRM_CN_RTD__c = False
                                                             ,ASI_CRM_SG_Order_Date__c = date.today()
                                                             ,ASI_CRM_Expected_Delivery_Date__c = date.today().addDays(-2)
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_SG_Wholesaler')
                                                            ));
        tmpSalesOrder.add(new ASI_KOR_Sales_Order_Request__c( ASI_KOR_Order_Status__c = 'Open'
                                                             , ASI_CRM_CN_Customer__c = tmpCustomer[0].id
                                                             , ASI_CRM_CN_RTD__c = True
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_SG_Wholesaler')
                                                            ));
        
        insert tmpSalesOrder; 
        ASI_CRM_SG_Submit_to_PRS_WholesalerCtrl.getRecord(tmpSalesOrder[0].Id);
        ASI_CRM_SG_Submit_to_PRS_WholesalerCtrl.getRecord(null);
        
        tmpSalesOrderLineItem.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroup[0].id
                                                                         , ASI_KOR_Order_Qty__c = 1
                                                                         , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                                                                         , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                                                                         , ASI_KOR_Sales_Order_Request__c = tmpSalesOrder[0].id
                                                                        ));
       tmpSalesOrderLineItem.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroup[0].id
                                                                         , ASI_KOR_Order_Qty__c = 1
                                                                         , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                                                                         , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                                                                         , ASI_KOR_Sales_Order_Request__c = tmpSalesOrder[1].id
                                                                        ));
        insert tmpSalesOrderLineItem;
        
        test.startTest();
        ASI_CRM_SG_Submit_to_PRS_WholesalerCtrl.getRecord(tmpSalesOrder[0].Id);
        ASI_CRM_SG_Submit_to_PRS_WholesalerCtrl.updateRecord(true,tmpSalesOrder[0].Id);
		ASI_KOR_Sales_Order_Transaction__c txn = new ASI_KOR_Sales_Order_Transaction__c(Id = tmpSalesOrderLineItem[0].Id,ASI_CRM_SG_Request_Quantity_Carton__c=200,ASI_CRM_Packaging_Size__c=500);
        update txn;
         ASI_CRM_SG_Submit_to_PRS_WholesalerCtrl.updateRecord(true,tmpSalesOrder[0].Id);
        ASI_CRM_SG_Submit_to_PRS_WholesalerCtrl.getRecord(tmpSalesOrder[1].Id); 
        ASI_CRM_SG_Submit_to_PRS_WholesalerCtrl.updateRecord(true,null);
        
        test.stopTest();
    }
}