@isTest
public class ASI_CRM_KH_SalesOrderSummaryCtl_Test {
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
        
       ASI_MFM_Sub_Channel__c tmpSubChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);        
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
      ASI_CRM_AccountsAdditionalField__c   tmpCustomer = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test1', ASI_CRM_CN_Chi_Name__c = 'test1', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '555', ASI_CRM_CN_JDE_Code__c = '111', ASI_CRM_CN_JDE_Code_Premium__c = '456', ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c=tmpSubChannel.Id, ASI_CRM_CN_CCity__c=city.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_KH_Customer'), ASI_CRM_CN_NewChannel__c = newChannel.Id);
    insert tmpCustomer;
       ASI_MFM_Item_Group__c  tmpItemGroup = new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , ASI_CRM_Allocation_Information__c = true//20170217 Elufa
                                                  );
        insert tmpItemGroup;
        
              ASI_KOR_Sales_Order_Request__c  tmpSalesOrder = new ASI_KOR_Sales_Order_Request__c( ASI_KOR_Order_Status__c = 'Open'
                                                             , ASI_CRM_CN_Customer__c = tmpCustomer.id
                                                             , ASI_CRM_CN_RTD__c = FALSE
                                                             ,ASI_CRM_SG_Order_Date__c = date.today()
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_KH_Sales_Order')
                                                            );
        insert tmpSalesOrder;
         ASI_KOR_Sales_Order_Transaction__c soi = new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroup.id
                                                                         , ASI_KOR_Order_Qty__c = 1
                                                                         , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                                                                         , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_KH_SO_Item')
                                                                         , ASI_KOR_Sales_Order_Request__c = tmpSalesOrder.id
                                                                        );
        insert soi;
        test.startTest();
        	 ApexPages.StandardController sc = new ApexPages.StandardController(tmpSalesOrder);
        	ASI_CRM_KH_SalesOrderSummaryCtl ctrl = new ASI_CRM_KH_SalesOrderSummaryCtl(sc);
        ctrl.getSalesOrderRequestItems();
        ASI_CRM_SO_On_Customer_Light_Ctrl.getRecordTypes();
        ASI_CRM_KH_SalesOrderSummaryCompCtl ctrl1 = new ASI_CRM_KH_SalesOrderSummaryCompCtl();
        ctrl1.soRecordId = tmpSalesOrder.Id;
        ctrl1.getSalesOrderRequest();
        ctrl1.getSalesOrderRequestItems();
        test.stopTest();
    }
}