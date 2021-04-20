@isTest
public class ASI_CRM_Visitation_TestClass
{
    static testMethod void visitPlanTest()
	{
        ID userID = UserInfo.getUserId();

        ASI_CRM_MY_TestClassHelper.createMYSetting();

        ASI_CRM_MY_Settings__c mySetting = new ASI_CRM_MY_Settings__c(
            ASI_CRM_MY_GST_Rate__c = 6.00,
            ASI_CRM_MY_Offtake_Cutoff_Day__c = 26,
            ASI_CRM_MY_Salesman_Commission__c = 0.01,
            ASI_CRM_MY_Visitation_Plan_Outlet_Limit__c = 5000,
            ASI_CRM_MY_Google_API_KEY__c = 'AIzaSyAz-G6GDwcN0c4XRvReLmUVImv-spOynU8'
        );
        insert mySetting;
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();

        ASI_CRM_VisitationPlanSetting__c vpdSetting = new ASI_CRM_VisitationPlanSetting__c(
            ASI_CRM_Bottle_Label__c = 'PR,GMA,Counterfeit',
            ASI_CRM_Custody_Condition__c = 'Clean,Not Clean',
            ASI_CRM_Event_Active__c = false,
            ASI_CRM_Event_Label__c = 'Event',
            ASI_CRM_Event_Required__c = false,
            ASI_CRM_Familiar_With_PRM__c = 'Yes,No',
            ASI_CRM_GMA_Active__c = false,
            ASI_CRM_GMA_Label__c = 'GMA',
            ASI_CRM_GMA_Required__c = false,
            ASI_CRM_IOT_Active__c = true,
            ASI_CRM_IOT_Email__c = true,
            ASI_CRM_IOT_Label__c = 'IOT',
            ASI_CRM_IOT_Required__c = false,
            ASI_CRM_Outlet_Type__c = 'CO,NCO,Competitor CO',
            ASI_CRM_Own_Activations__c = 'Yes,No',
            ASI_CRM_QVAP_Active__c = true,
            ASI_CRM_QVAP_Label__c = 'QVAP',
            ASI_CRM_QVAP_Required__c = false,
            ASI_CRM_RSP_Active__c = true,
            ASI_CRM_RSP_Label__c = 'RSP',
            ASI_CRM_RSP_Required__c = false,
            ASI_CRM_Top_Of_Staff_Mind__c = 'Yes,No',
            ASI_CRM_Customer_Detail_Field_1__c = 'Channel|ASI_CRM_AccountsAdditionalField__c.ASI_CRM_Channel__r.Name',
            ASI_CRM_Customer_Detail_Field_2__c = 'Outlet Prioritization|ASI_CRM_Pros_Segmentation__c.ASI_CRM_OP__r.Name',
            ASI_CRM_Customer_Detail_Field_3__c = 'Visit Frequency|ASI_CRM_Pros_Segmentation__c.ASI_CRM_Visit_Frequency_Thresholds__r.ASI_CRM_Visit_Frequency__c',
            ASI_CRM_Customer_Detail_Field_4__c = 'Sub-Channel Name|ASI_CRM_Pros_Segmentation__c.Sub_Channel__r.Name',
            ASI_CRM_Customer_Detail_Field_5__c = 'Image Level Name|ASI_CRM_Pros_Segmentation__c.ASI_CRM_SG_Image_Level__r.ASI_CRM_SG_Name__c',
            ASI_CRM_Customer_Detail_Field_6__c = 'Recommended CM|ASI_CRM_Pros_Segmentation__c.ASI_CRM_Investment_Guidelines_Thresholds__r.ASI_CRM_Recommended_CM__c',
            ASI_CRM_Visitation_Plan_Field_1__c = 'Customer Name|Name',
            ASI_CRM_Visitation_Plan_Field_2__c = 'Channel|ASI_CRM_Channel__r|ASI_CRM_CN_Channel__c',
            ASI_CRM_Visitation_Plan_Field_3__c = 'Outlet Type|ASI_TH_CRM_OutletType__r|ASI_TH_CRM_OutletType__c',
            ASI_CRM_Visitation_Plan_Field_4__c = 'Outlet Image|ASI_TH_CRM_OutletImage__r|ASI_TH_CRM_OutletImage__c',
            ASI_CRM_Visitation_Plan_Field_5__c = 'Phone Number|ASI_CRM_CN_Phone_Number__c',
            ASI_CRM_Visitation_Plan_Field_6__c = 'Grade|ASI_CRM_CN_Grade__c',
            ASI_CRM_Visitation_Plan_Filter_1__c = 'Customer Name|Name',
            ASI_CRM_Visitation_Plan_Filter_2__c = 'Customer Grade|ASI_CRM_CN_Grade__c',
            ASI_CRM_Visitation_Plan_Filter_3__c = 'Owner Name|Owner.Name',
            ASI_CRM_Customer_Address__c = 'ASI_CRM_CN_Address__c',
            ASI_CRM_Customer_Phone__c = 'ASI_CRM_CN_Phone_Number__c'
        );
        insert vpdSetting;

        ASI_CRM_VisitationRTypeMapping__c rtSetting = new ASI_CRM_VisitationRTypeMapping__c(
            ASI_CRM_CustomerRTypeAPI__c = 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet',
            ASI_CRM_VisitationPlanRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan__cASI_CRM_MY_VisitationPlan',
            ASI_CRM_VisitationPlanDetailRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_VisitationPlanDetail',
            ASI_CRM_VisitationPlanDetailAHRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Ad_Hoc',
            ASI_CRM_VisitationPlanDetailCCRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Cold_Call',
            ASI_CRM_WholesalerRTypeAPI__c = 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Wholesaler',
            ASI_CRM_BrandRTypeAPI__c = 'ASI_MFM_Brand__cASI_MFM_MY_Brand',
            ASI_CRM_SubBrandRTypeAPI__c = 'ASI_MFM_Sub_brand__cASI_MFM_MY_Sub_brand',
            ASI_CRM_SKURTypeAPI__c = 'ASI_MFM_SKU_Code__cASI_CRM_MY_SKU',
            ASI_CRM_RSPHeaderRTypeAPI__c = 'ASI_CRM_RSPHeader__cASI_CRM_MY_RSPHeader',
            ASI_CRM_RSPDetailRTypeAPI__c = 'ASI_TH_CRM_RSP__cASI_CRM_MY_RSP',
            ASI_CRM_IOTHeaderRTypeAPI__c = 'ASI_CRM_IOTHeader__cASI_CRM_MY_IOTHeader',
            ASI_CRM_IOTDetailRTypeAPI__c = 'ASI_CRM_IOTLine__cASI_CRM_MY_IOTLine',
            ASI_CRM_EventRTypeAPI__c = 'ASI_CRM_EVENTCapture__cASI_CRM_MY_EVENTCapture',
            ASI_CRM_CustomerFilter__c = '',
            ASI_CRM_SKURSPFilter__c = 'ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c != \'PR\'',
            ASI_CRM_SKUIOTFilter__c = 'ASI_CRM_Selectable_In_Order__c = true'
        );
        insert rtSetting;

        ASI_CRM_SegmentationCriteria__c seg = new ASI_CRM_SegmentationCriteria__c(
            ASI_CRM_CallFrequency__c = 10
        );
        insert seg;

        ASI_CRM_AccountsAdditionalField__c wholesaler = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Wholesaler');
        ASI_CRM_AccountsAdditionalField__c outlet = ASI_CRM_MY_TestClassHelper.createCustomer('customer2', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
        wholesaler.ASI_CRM_MY_IOTEmail__c = 'user1@test.com;user2@test.com';
        wholesaler.ASI_CRM_Segmentation_Criteria__c = seg.id;
        outlet.ASI_CRM_Segmentation_Criteria__c = seg.id;
        upsert wholesaler;
        upsert outlet;
		
		ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
		ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
		ASI_MFM_SKU_Code__c sku2 = ASI_CRM_MY_TestClassHelper.createSKU('sku2', productCategory);
        
        ASI_HK_CRM_Visitation_Plan__c visitationPlan = new ASI_HK_CRM_Visitation_Plan__c(Name = 'Test Visitation Plan', RecordTypeid = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_MY_VisitationPlan'), ASI_HK_CRM_Year__c = String.valueOf(System.today().year()), ASI_HK_CRM_Month__c = System.now().format('MMMM')); 
        insert visitationPlan;
        
        visitationPlan.ownerid = userID;
        update visitationPlan;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail1 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = outlet.id, ASI_HK_CRM_Visit_Date__c = System.today(), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_VisitationPlanDetail'));
        insert vpDetail1;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail2 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = outlet.id, ASI_HK_CRM_Visit_Date__c = System.today(), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Cold_Call'));
        insert vpDetail2;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail3 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = outlet.id, ASI_HK_CRM_Visit_Date__c = System.today(), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Ad_Hoc'));
		insert vpDetail3;
		
		ASI_CRM_IOTHeader__c iotHeader = new ASI_CRM_IOTHeader__c(
            ASI_CRM_Wholesaler__c = wholesaler.Id,
            ASI_CRM_Customer__c = outlet.Id,
            ASI_CRM_MY_IOTConfirm__c = true,
            ASI_CRM_MY_EmailSent__c = false,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_IOTHeader__cASI_CRM_MY_IOTHeader')
        );
        insert iotHeader;
        
        ASI_CRM_IOTLine__c iotLine = new ASI_CRM_IOTLine__c(
            ASI_CRM_IOTHeader__c = iotHeader.Id,
            ASI_CRM_SKU__c = sku1.Id,
            ASI_CRM_Quantity__c = 1,
            ASI_CRM_FOCQuantity__c = 1,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_IOTLine__cASI_CRM_MY_IOTLine')
        );
        insert iotLine;
        
        ASI_CRM_RSPHeader__c rspHeader = new ASI_CRM_RSPHeader__c(ASI_CRM_Customer__c = outlet.id, ASI_CRM_Date__c = System.today(), recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_RSPHeader__cASI_CRM_MY_RSPHeader'));
        insert rspHeader; 
            
        ASI_TH_CRM_RSP__c rspLine = new ASI_TH_CRM_RSP__c(ASI_CRM_RSPHeader__c = rspHeader.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Price_to_Consumer__c = 200, recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_RSP__cASI_CRM_MY_RSP'));
        insert rspLine;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail4 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = outlet.id, ASI_HK_CRM_Visit_Date__c = System.today(), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Ad_Hoc'));

		String rspHeaderStr = '{"ASI_CRM_Customer__c":"' + outlet.id + '","ASI_CRM_Date__c":"2020-06-10","ASI_CRM_Remark__c":"ab"}';
		String rspDetailStr = '[{"ASI_CRM_RSPHeader__c":null,"ASI_CRM_CN_Input_Date_Time__c":null,"ASI_CRM_Price_to_Consumer__c":"10","ASI_CRM_SKU__c":"' + sku1.id + '"}]';
        String rspDeleteStr = '[{"id":"' + rspLine.id + '"}]';
        
        Note note = new Note(
            ParentId = vpDetail1.id,
            Title = 'title',
            Body = 'Body'
        );
        insert note;
        
		Test.startTest();
        ASI_CRM_VisitationPlanDetailCtr.getCustomVisitationPlan(visitationPlan.id);
        ASI_CRM_VisitationPlanDetailCtr.getMyCustomCustomerCount(new List<String>{ 'customer', '', '' });
        ASI_CRM_VisitationPlanDetailCtr.getMYCustomCustomerList(new List<String>{ '', '', '' }, 10, 0);
        ASI_CRM_VisitationPlanDetailCtr.getMYVisitationPlanRequirement(new List<String>{ Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_VisitationPlanDetail') });
        ASI_CRM_VisitationPlanDetailCtr.saveVisitationPlanDetail('[' + JSON.serialize(vpDetail4) + ']', '[' + JSON.serialize(vpDetail1) + ']', '["' + vpDetail2.id + '"]');
        Test.stopTest();
    }
    
	static testMethod void visitTodayTest()
	{
        ID userID = UserInfo.getUserId();

        ASI_CRM_MY_TestClassHelper.createMYSetting();

        ASI_CRM_MY_Settings__c mySetting = new ASI_CRM_MY_Settings__c(
            ASI_CRM_MY_GST_Rate__c = 6.00,
            ASI_CRM_MY_Offtake_Cutoff_Day__c = 26,
            ASI_CRM_MY_Salesman_Commission__c = 0.01,
            ASI_CRM_MY_Visitation_Plan_Outlet_Limit__c = 5000,
            ASI_CRM_MY_Google_API_KEY__c = 'AIzaSyAz-G6GDwcN0c4XRvReLmUVImv-spOynU8'
        );
        insert mySetting;
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();

        ASI_CRM_VisitationPlanSetting__c vpdSetting = new ASI_CRM_VisitationPlanSetting__c(
            ASI_CRM_Bottle_Label__c = 'PR,GMA,Counterfeit',
            ASI_CRM_Custody_Condition__c = 'Clean,Not Clean',
            ASI_CRM_Event_Active__c = false,
            ASI_CRM_Event_Label__c = 'Event',
            ASI_CRM_Event_Required__c = false,
            ASI_CRM_Familiar_With_PRM__c = 'Yes,No',
            ASI_CRM_GMA_Active__c = false,
            ASI_CRM_GMA_Label__c = 'GMA',
            ASI_CRM_GMA_Required__c = false,
            ASI_CRM_IOT_Active__c = true,
            ASI_CRM_IOT_Email__c = true,
            ASI_CRM_IOT_Label__c = 'IOT',
            ASI_CRM_IOT_Required__c = false,
            ASI_CRM_Outlet_Type__c = 'CO,NCO,Competitor CO',
            ASI_CRM_Own_Activations__c = 'Yes,No',
            ASI_CRM_QVAP_Active__c = true,
            ASI_CRM_QVAP_Label__c = 'QVAP',
            ASI_CRM_QVAP_Required__c = false,
            ASI_CRM_RSP_Active__c = true,
            ASI_CRM_RSP_Label__c = 'RSP',
            ASI_CRM_RSP_Required__c = false,
            ASI_CRM_Top_Of_Staff_Mind__c = 'Yes,No',
            ASI_CRM_Customer_Detail_Field_1__c = 'Channel|ASI_CRM_AccountsAdditionalField__c.ASI_CRM_Channel__r.Name',
            ASI_CRM_Customer_Detail_Field_2__c = 'Outlet Prioritization|ASI_CRM_Pros_Segmentation__c.ASI_CRM_OP__r.Name',
            ASI_CRM_Customer_Detail_Field_3__c = 'Visit Frequency|ASI_CRM_Pros_Segmentation__c.ASI_CRM_Visit_Frequency_Thresholds__r.ASI_CRM_Visit_Frequency__c',
            ASI_CRM_Customer_Detail_Field_4__c = 'Sub-Channel Name|ASI_CRM_Pros_Segmentation__c.Sub_Channel__r.Name',
            ASI_CRM_Customer_Detail_Field_5__c = 'Image Level Name|ASI_CRM_Pros_Segmentation__c.ASI_CRM_SG_Image_Level__r.ASI_CRM_SG_Name__c',
            ASI_CRM_Customer_Detail_Field_6__c = 'Recommended CM|ASI_CRM_Pros_Segmentation__c.ASI_CRM_Investment_Guidelines_Thresholds__r.ASI_CRM_Recommended_CM__c',
            ASI_CRM_Visitation_Plan_Field_1__c = 'Customer Name|Name',
            ASI_CRM_Visitation_Plan_Field_2__c = 'Channel|ASI_CRM_Channel__r',
            ASI_CRM_Visitation_Plan_Field_3__c = 'Outlet Type|ASI_TH_CRM_OutletType__r',
            ASI_CRM_Visitation_Plan_Field_4__c = 'Outlet Image|ASI_TH_CRM_OutletImage__r',
            ASI_CRM_Visitation_Plan_Field_5__c = 'Phone Number|ASI_CRM_CN_Phone_Number__c',
            ASI_CRM_Visitation_Plan_Field_6__c = 'Grade|ASI_CRM_CN_Grade__c',
            ASI_CRM_Visitation_Plan_Filter_1__c = 'Customer Name|Name',
            ASI_CRM_Visitation_Plan_Filter_2__c = 'Customer Grade|ASI_CRM_CN_Grade__c',
            ASI_CRM_Visitation_Plan_Filter_3__c = 'Owner Name|Owner.Name',
            ASI_CRM_Customer_Address__c = 'ASI_CRM_CN_Address__c',
            ASI_CRM_Customer_Phone__c = 'ASI_CRM_CN_Phone_Number__c'
        );
        insert vpdSetting;

        ASI_CRM_VisitationRTypeMapping__c rtSetting = new ASI_CRM_VisitationRTypeMapping__c(
            ASI_CRM_CustomerRTypeAPI__c = 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet',
            ASI_CRM_VisitationPlanRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan__cASI_CRM_MY_VisitationPlan',
            ASI_CRM_VisitationPlanDetailRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_VisitationPlanDetail',
            ASI_CRM_VisitationPlanDetailAHRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Ad_Hoc',
            ASI_CRM_VisitationPlanDetailCCRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Cold_Call',
            ASI_CRM_WholesalerRTypeAPI__c = 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Wholesaler',
            ASI_CRM_BrandRTypeAPI__c = 'ASI_MFM_Brand__cASI_MFM_MY_Brand',
            ASI_CRM_SubBrandRTypeAPI__c = 'ASI_MFM_Sub_brand__cASI_MFM_MY_Sub_brand',
            ASI_CRM_SKURTypeAPI__c = 'ASI_MFM_SKU_Code__cASI_CRM_MY_SKU',
            ASI_CRM_RSPHeaderRTypeAPI__c = 'ASI_CRM_RSPHeader__cASI_CRM_MY_RSPHeader',
            ASI_CRM_RSPDetailRTypeAPI__c = 'ASI_TH_CRM_RSP__cASI_CRM_MY_RSP',
            ASI_CRM_IOTHeaderRTypeAPI__c = 'ASI_CRM_IOTHeader__cASI_CRM_MY_IOTHeader',
            ASI_CRM_IOTDetailRTypeAPI__c = 'ASI_CRM_IOTLine__cASI_CRM_MY_IOTLine',
            ASI_CRM_EventRTypeAPI__c = 'ASI_CRM_EVENTCapture__cASI_CRM_MY_EVENTCapture',
            ASI_CRM_CustomerFilter__c = '',
            ASI_CRM_SKURSPFilter__c = 'ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c != \'PR\'',
            ASI_CRM_SKUIOTFilter__c = 'ASI_CRM_Selectable_In_Order__c = true'
        );
        insert rtSetting;
        
        ASI_CRM_AccountsAdditionalField__c wholesaler = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Wholesaler');
        ASI_CRM_AccountsAdditionalField__c outlet = ASI_CRM_MY_TestClassHelper.createCustomer('customer2', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
        wholesaler.ASI_CRM_MY_IOTEmail__c = 'user1@test.com;user2@test.com';
        upsert wholesaler;
        upsert outlet;
		
		ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
		ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
		ASI_MFM_SKU_Code__c sku2 = ASI_CRM_MY_TestClassHelper.createSKU('sku2', productCategory);
        
        DateTime today = System.now();
        Date date1 = Date.newInstance(today.year(), today.month(), (today.day() > 15 ? 10 : 20));
        ASI_HK_CRM_Visitation_Plan__c visitationPlan = new ASI_HK_CRM_Visitation_Plan__c(Name = 'Test Visitation Plan', RecordTypeid = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_MY_VisitationPlan'), ASI_HK_CRM_Year__c = String.valueOf(today.year()), ASI_HK_CRM_Month__c = today.format('MMMM')); 
        insert visitationPlan;
        
        visitationPlan.ownerid = userID;
        update visitationPlan;

        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail1 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = outlet.id, ASI_HK_CRM_Visit_Date__c = date1.addDays(-1), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_VisitationPlanDetail'));
        insert vpDetail1;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail2 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = outlet.id, ASI_HK_CRM_Visit_Date__c = date1.addDays(-2), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Cold_Call'));
        insert vpDetail2;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail3 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = outlet.id, ASI_HK_CRM_Visit_Date__c = date1.addDays(-3), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Ad_Hoc'));
		insert vpDetail3;
		
		ASI_CRM_IOTHeader__c iotHeader = new ASI_CRM_IOTHeader__c(
            ASI_CRM_Wholesaler__c = wholesaler.Id,
            ASI_CRM_Customer__c = outlet.Id,
            ASI_CRM_MY_IOTConfirm__c = true,
            ASI_CRM_MY_EmailSent__c = false,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_IOTHeader__cASI_CRM_MY_IOTHeader')
        );
        insert iotHeader;
        
        ASI_CRM_IOTLine__c iotLine = new ASI_CRM_IOTLine__c(
            ASI_CRM_IOTHeader__c = iotHeader.Id,
            ASI_CRM_SKU__c = sku1.Id,
            ASI_CRM_Quantity__c = 1,
            ASI_CRM_FOCQuantity__c = 1,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_IOTLine__cASI_CRM_MY_IOTLine')
        );
        insert iotLine;
        
        ASI_CRM_RSPHeader__c rspHeader = new ASI_CRM_RSPHeader__c(ASI_CRM_Customer__c = outlet.id, ASI_CRM_Date__c = System.today(), recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_RSPHeader__cASI_CRM_MY_RSPHeader'));
        insert rspHeader; 
            
        ASI_TH_CRM_RSP__c rspLine = new ASI_TH_CRM_RSP__c(ASI_CRM_RSPHeader__c = rspHeader.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Price_to_Consumer__c = 200, recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_RSP__cASI_CRM_MY_RSP'));
		insert rspLine;

		String rspHeaderStr = '{"ASI_CRM_Customer__c":"' + outlet.id + '","ASI_CRM_Date__c":"2020-06-10","ASI_CRM_Remark__c":"ab"}';
		String rspDetailStr = '[{"ASI_CRM_RSPHeader__c":null,"ASI_CRM_CN_Input_Date_Time__c":null,"ASI_CRM_Price_to_Consumer__c":"10","ASI_CRM_SKU__c":"' + sku1.id + '"}]';
		String rspDeleteStr = '[{"id":"' + rspLine.id + '"}]';
        
		Test.startTest();
        ASI_CRM_VisitationController.getTodayVisit();
        ASI_CRM_VisitationController.getPreviousVisit(outlet.id, vpDetail3.id, 1, 10);
        ASI_CRM_VisitationController.getCustomerList('customer');
        ASI_CRM_VisitationController.getSKUList('sku');
        ASI_CRM_VisitationController.getRSP(vpDetail1.id);
        ASI_CRM_VisitationController.saveRSP(rspHeaderStr, rspDetailStr, rspDeleteStr);
        ASI_CRM_VisitationController.saveAdhoc(outlet.id);
        Test.stopTest();
    }
    
    static testMethod void iotTest()
	{
        ID userID = UserInfo.getUserId();

        ASI_CRM_MY_TestClassHelper.createMYSetting();

        ASI_CRM_MY_Settings__c mySetting = new ASI_CRM_MY_Settings__c(
            ASI_CRM_MY_GST_Rate__c = 6.00,
            ASI_CRM_MY_Offtake_Cutoff_Day__c = 26,
            ASI_CRM_MY_Salesman_Commission__c = 0.01,
            ASI_CRM_MY_Visitation_Plan_Outlet_Limit__c = 5000,
            ASI_CRM_MY_Google_API_KEY__c = 'AIzaSyAz-G6GDwcN0c4XRvReLmUVImv-spOynU8'
        );
        insert mySetting;
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();

        ASI_CRM_VisitationPlanSetting__c vpdSetting = new ASI_CRM_VisitationPlanSetting__c(
            ASI_CRM_Bottle_Label__c = 'PR,GMA,Counterfeit',
            ASI_CRM_Custody_Condition__c = 'Clean,Not Clean',
            ASI_CRM_Event_Active__c = false,
            ASI_CRM_Event_Label__c = 'Event',
            ASI_CRM_Event_Required__c = false,
            ASI_CRM_Familiar_With_PRM__c = 'Yes,No',
            ASI_CRM_GMA_Active__c = false,
            ASI_CRM_GMA_Label__c = 'GMA',
            ASI_CRM_GMA_Required__c = false,
            ASI_CRM_IOT_Active__c = true,
            ASI_CRM_IOT_Email__c = true,
            ASI_CRM_IOT_Label__c = 'IOT',
            ASI_CRM_IOT_Required__c = false,
            ASI_CRM_Outlet_Type__c = 'CO,NCO,Competitor CO',
            ASI_CRM_Own_Activations__c = 'Yes,No',
            ASI_CRM_QVAP_Active__c = true,
            ASI_CRM_QVAP_Label__c = 'QVAP',
            ASI_CRM_QVAP_Required__c = false,
            ASI_CRM_RSP_Active__c = true,
            ASI_CRM_RSP_Label__c = 'RSP',
            ASI_CRM_RSP_Required__c = false,
            ASI_CRM_Top_Of_Staff_Mind__c = 'Yes,No',
            ASI_CRM_Customer_Detail_Field_1__c = 'Channel|ASI_CRM_AccountsAdditionalField__c.ASI_CRM_Channel__r.Name',
            ASI_CRM_Customer_Detail_Field_2__c = 'Outlet Prioritization|ASI_CRM_Pros_Segmentation__c.ASI_CRM_OP__r.Name',
            ASI_CRM_Customer_Detail_Field_3__c = 'Visit Frequency|ASI_CRM_Pros_Segmentation__c.ASI_CRM_Visit_Frequency_Thresholds__r.ASI_CRM_Visit_Frequency__c',
            ASI_CRM_Customer_Detail_Field_4__c = 'Sub-Channel Name|ASI_CRM_Pros_Segmentation__c.Sub_Channel__r.Name',
            ASI_CRM_Customer_Detail_Field_5__c = 'Image Level Name|ASI_CRM_Pros_Segmentation__c.ASI_CRM_SG_Image_Level__r.ASI_CRM_SG_Name__c',
            ASI_CRM_Customer_Detail_Field_6__c = 'Recommended CM|ASI_CRM_Pros_Segmentation__c.ASI_CRM_Investment_Guidelines_Thresholds__r.ASI_CRM_Recommended_CM__c',
            ASI_CRM_Visitation_Plan_Field_1__c = 'Customer Name|Name',
            ASI_CRM_Visitation_Plan_Field_2__c = 'Channel|ASI_CRM_Channel__r',
            ASI_CRM_Visitation_Plan_Field_3__c = 'Outlet Type|ASI_TH_CRM_OutletType__r',
            ASI_CRM_Visitation_Plan_Field_4__c = 'Outlet Image|ASI_TH_CRM_OutletImage__r',
            ASI_CRM_Visitation_Plan_Field_5__c = 'Phone Number|ASI_CRM_CN_Phone_Number__c',
            ASI_CRM_Visitation_Plan_Field_6__c = 'Grade|ASI_CRM_CN_Grade__c',
            ASI_CRM_Visitation_Plan_Filter_1__c = 'Customer Name|Name',
            ASI_CRM_Visitation_Plan_Filter_2__c = 'Customer Grade|ASI_CRM_CN_Grade__c',
            ASI_CRM_Visitation_Plan_Filter_3__c = 'Owner Name|Owner.Name',
            ASI_CRM_Customer_Address__c = 'ASI_CRM_CN_Address__c',
            ASI_CRM_Customer_Phone__c = 'ASI_CRM_CN_Phone_Number__c'
        );
        insert vpdSetting;

        ASI_CRM_VisitationRTypeMapping__c rtSetting = new ASI_CRM_VisitationRTypeMapping__c(
            ASI_CRM_CustomerRTypeAPI__c = 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet',
            ASI_CRM_VisitationPlanRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan__cASI_CRM_MY_VisitationPlan',
            ASI_CRM_VisitationPlanDetailRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_VisitationPlanDetail',
            ASI_CRM_VisitationPlanDetailAHRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Ad_Hoc',
            ASI_CRM_VisitationPlanDetailCCRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Cold_Call',
            ASI_CRM_WholesalerRTypeAPI__c = 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Wholesaler',
            ASI_CRM_BrandRTypeAPI__c = 'ASI_MFM_Brand__cASI_MFM_MY_Brand',
            ASI_CRM_SubBrandRTypeAPI__c = 'ASI_MFM_Sub_brand__cASI_MFM_MY_Sub_brand',
            ASI_CRM_SKURTypeAPI__c = 'ASI_MFM_SKU_Code__cASI_CRM_MY_SKU',
            ASI_CRM_RSPHeaderRTypeAPI__c = 'ASI_CRM_RSPHeader__cASI_CRM_MY_RSPHeader',
            ASI_CRM_RSPDetailRTypeAPI__c = 'ASI_TH_CRM_RSP__cASI_CRM_MY_RSP',
            ASI_CRM_IOTHeaderRTypeAPI__c = 'ASI_CRM_IOTHeader__cASI_CRM_MY_IOTHeader',
            ASI_CRM_IOTDetailRTypeAPI__c = 'ASI_CRM_IOTLine__cASI_CRM_MY_IOTLine',
            ASI_CRM_EventRTypeAPI__c = 'ASI_CRM_EVENTCapture__cASI_CRM_MY_EVENTCapture',
            ASI_CRM_CustomerFilter__c = '',
            ASI_CRM_SKURSPFilter__c = 'ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c != \'PR\'',
            ASI_CRM_SKUIOTFilter__c = 'ASI_CRM_Selectable_In_Order__c = true'
        );
        insert rtSetting;
        
        ASI_CRM_AccountsAdditionalField__c wholesaler = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Wholesaler');
        ASI_CRM_AccountsAdditionalField__c outlet = ASI_CRM_MY_TestClassHelper.createCustomer('customer2', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
        wholesaler.ASI_CRM_MY_IOTEmail__c = 'user1@test.com;user2@test.com';
        upsert wholesaler;
        upsert outlet;
		
		ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
		ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
		ASI_MFM_SKU_Code__c sku2 = ASI_CRM_MY_TestClassHelper.createSKU('sku2', productCategory);
        
        ASI_HK_CRM_Visitation_Plan__c visitationPlan = new ASI_HK_CRM_Visitation_Plan__c(Name = 'Test Visitation Plan', RecordTypeid = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_MY_VisitationPlan'), ASI_HK_CRM_Year__c = String.valueOf(System.today().year()), ASI_HK_CRM_Month__c = System.now().format('MMMM')); 
        insert visitationPlan;
        
        visitationPlan.ownerid = userID;
        update visitationPlan;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail1 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = outlet.id, ASI_HK_CRM_Visit_Date__c = System.today(), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_VisitationPlanDetail'));
        insert vpDetail1;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail2 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = outlet.id, ASI_HK_CRM_Visit_Date__c = System.today(), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Cold_Call'));
        insert vpDetail2;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail3 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = outlet.id, ASI_HK_CRM_Visit_Date__c = System.today(), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Ad_Hoc'));
		insert vpDetail3;
		
		ASI_CRM_IOTHeader__c iotHeader = new ASI_CRM_IOTHeader__c(
            ASI_CRM_Wholesaler__c = wholesaler.Id,
            ASI_CRM_Customer__c = outlet.Id,
            ASI_CRM_MY_IOTConfirm__c = true,
            ASI_CRM_MY_EmailSent__c = false,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_IOTHeader__cASI_CRM_MY_IOTHeader')
        );
        insert iotHeader;
        
        ASI_CRM_IOTLine__c iotLine = new ASI_CRM_IOTLine__c(
            ASI_CRM_IOTHeader__c = iotHeader.Id,
            ASI_CRM_SKU__c = sku1.Id,
            ASI_CRM_Quantity__c = 1,
            ASI_CRM_FOCQuantity__c = 1,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_IOTLine__cASI_CRM_MY_IOTLine')
        );
        insert iotLine;
        
        ASI_CRM_RSPHeader__c rspHeader = new ASI_CRM_RSPHeader__c(ASI_CRM_Customer__c = outlet.id, ASI_CRM_Date__c = System.today(), recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_RSPHeader__cASI_CRM_MY_RSPHeader'));
        insert rspHeader; 
            
        ASI_TH_CRM_RSP__c rspLine = new ASI_TH_CRM_RSP__c(ASI_CRM_RSPHeader__c = rspHeader.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Price_to_Consumer__c = 200, recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_RSP__cASI_CRM_MY_RSP'));
		insert rspLine;

		String iotHeaderStr = '{"ASI_CRM_Customer__c":"' + outlet.id + '","ASI_CRM_Wholesaler__c":"' + wholesaler.id + '"}';
		String iotDetailStr = '[{"ASI_CRM_Quantity__c":10,"ASI_CRM_SKU__c":"' + sku1.id + '"}]';
        
		Test.startTest();
        ASI_CRM_VisitationPlaceOrderController.getSKUs(outlet.id, 'text', 'all', 10, 0);
        ASI_CRM_VisitationPlaceOrderController.getSKUs(outlet.id, 'text', 'sku', 10, 0);
        ASI_CRM_VisitationPlaceOrderController.getSKUs(outlet.id, 'text', 'sku_code', 10, 0);
        ASI_CRM_VisitationPlaceOrderController.getSKUs(outlet.id, 'text', 'brand', 10, 0);
        ASI_CRM_VisitationPlaceOrderController.getSKUs(outlet.id, 'text', 'brand_code', 10, 0);
        ASI_CRM_VisitationPlaceOrderController.getSKUs(outlet.id, 'text', 'sub_brand', 10, 0);
        ASI_CRM_VisitationPlaceOrderController.getSKUs(outlet.id, 'text', 'sub_brand_code', 10, 0);
        ASI_CRM_VisitationPlaceOrderController.getWholesalers('customer');
        ASI_CRM_VisitationPlaceOrderController.saveIOT(iotHeaderStr, iotDetailStr);
        ASI_CRM_VisitationPreviousOrdersCtr.getPreviousOrders(outlet.id, 10, 0);
        ASI_CRM_VisitationPreviousOrdersCtr.getOrderDetails(iotHeader.id);
        Test.stopTest();
    }
    
    static testMethod void customerDetailTest()
	{
        ID userID = UserInfo.getUserId();

        ASI_CRM_MY_TestClassHelper.createMYSetting();

        ASI_CRM_MY_Settings__c mySetting = new ASI_CRM_MY_Settings__c(
            ASI_CRM_MY_GST_Rate__c = 6.00,
            ASI_CRM_MY_Offtake_Cutoff_Day__c = 26,
            ASI_CRM_MY_Salesman_Commission__c = 0.01,
            ASI_CRM_MY_Visitation_Plan_Outlet_Limit__c = 5000,
            ASI_CRM_MY_Google_API_KEY__c = 'AIzaSyAz-G6GDwcN0c4XRvReLmUVImv-spOynU8'
        );
        insert mySetting;
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();

        ASI_CRM_VisitationPlanSetting__c vpdSetting = new ASI_CRM_VisitationPlanSetting__c(
            ASI_CRM_Bottle_Label__c = 'PR,GMA,Counterfeit',
            ASI_CRM_Custody_Condition__c = 'Clean,Not Clean',
            ASI_CRM_Event_Active__c = false,
            ASI_CRM_Event_Label__c = 'Event',
            ASI_CRM_Event_Required__c = false,
            ASI_CRM_Familiar_With_PRM__c = 'Yes,No',
            ASI_CRM_GMA_Active__c = false,
            ASI_CRM_GMA_Label__c = 'GMA',
            ASI_CRM_GMA_Required__c = false,
            ASI_CRM_IOT_Active__c = true,
            ASI_CRM_IOT_Email__c = true,
            ASI_CRM_IOT_Label__c = 'IOT',
            ASI_CRM_IOT_Required__c = false,
            ASI_CRM_Outlet_Type__c = 'CO,NCO,Competitor CO',
            ASI_CRM_Own_Activations__c = 'Yes,No',
            ASI_CRM_QVAP_Active__c = true,
            ASI_CRM_QVAP_Label__c = 'QVAP',
            ASI_CRM_QVAP_Required__c = false,
            ASI_CRM_RSP_Active__c = true,
            ASI_CRM_RSP_Label__c = 'RSP',
            ASI_CRM_RSP_Required__c = false,
            ASI_CRM_Top_Of_Staff_Mind__c = 'Yes,No',
            ASI_CRM_Customer_Detail_Field_1__c = 'Channel|ASI_CRM_AccountsAdditionalField__c.ASI_CRM_Channel__r.Name',
            ASI_CRM_Customer_Detail_Field_2__c = 'Outlet Prioritization|ASI_CRM_Pros_Segmentation__c.ASI_CRM_OP__r.Name',
            ASI_CRM_Customer_Detail_Field_3__c = 'Visit Frequency|ASI_CRM_Pros_Segmentation__c.ASI_CRM_Visit_Frequency_Thresholds__r.ASI_CRM_Visit_Frequency__c',
            ASI_CRM_Customer_Detail_Field_4__c = 'Sub-Channel Name|ASI_CRM_Pros_Segmentation__c.Sub_Channel__r.Name',
            ASI_CRM_Customer_Detail_Field_5__c = 'Image Level Name|ASI_CRM_Pros_Segmentation__c.ASI_CRM_SG_Image_Level__r.ASI_CRM_SG_Name__c',
            ASI_CRM_Customer_Detail_Field_6__c = 'Recommended CM|ASI_CRM_Pros_Segmentation__c.ASI_CRM_Investment_Guidelines_Thresholds__r.ASI_CRM_Recommended_CM__c',
            ASI_CRM_Visitation_Plan_Field_1__c = 'Customer Name|Name',
            ASI_CRM_Visitation_Plan_Field_2__c = 'Channel|ASI_CRM_Channel__r',
            ASI_CRM_Visitation_Plan_Field_3__c = 'Outlet Type|ASI_TH_CRM_OutletType__r',
            ASI_CRM_Visitation_Plan_Field_4__c = 'Outlet Image|ASI_TH_CRM_OutletImage__r',
            ASI_CRM_Visitation_Plan_Field_5__c = 'Phone Number|ASI_CRM_CN_Phone_Number__c',
            ASI_CRM_Visitation_Plan_Field_6__c = 'Grade|ASI_CRM_CN_Grade__c',
            ASI_CRM_Visitation_Plan_Filter_1__c = 'Customer Name|Name',
            ASI_CRM_Visitation_Plan_Filter_2__c = 'Customer Grade|ASI_CRM_CN_Grade__c',
            ASI_CRM_Visitation_Plan_Filter_3__c = 'Owner Name|Owner.Name',
            ASI_CRM_Customer_Address__c = 'ASI_CRM_CN_Address__c',
            ASI_CRM_Customer_Phone__c = 'ASI_CRM_CN_Phone_Number__c'
        );
        insert vpdSetting;

        ASI_CRM_VisitationRTypeMapping__c rtSetting = new ASI_CRM_VisitationRTypeMapping__c(
            ASI_CRM_CustomerRTypeAPI__c = 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet',
            ASI_CRM_VisitationPlanRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan__cASI_CRM_MY_VisitationPlan',
            ASI_CRM_VisitationPlanDetailRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_VisitationPlanDetail',
            ASI_CRM_VisitationPlanDetailAHRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Ad_Hoc',
            ASI_CRM_VisitationPlanDetailCCRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Cold_Call',
            ASI_CRM_WholesalerRTypeAPI__c = 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Wholesaler',
            ASI_CRM_BrandRTypeAPI__c = 'ASI_MFM_Brand__cASI_MFM_MY_Brand',
            ASI_CRM_SubBrandRTypeAPI__c = 'ASI_MFM_Sub_brand__cASI_MFM_MY_Sub_brand',
            ASI_CRM_SKURTypeAPI__c = 'ASI_MFM_SKU_Code__cASI_CRM_MY_SKU',
            ASI_CRM_RSPHeaderRTypeAPI__c = 'ASI_CRM_RSPHeader__cASI_CRM_MY_RSPHeader',
            ASI_CRM_RSPDetailRTypeAPI__c = 'ASI_TH_CRM_RSP__cASI_CRM_MY_RSP',
            ASI_CRM_IOTHeaderRTypeAPI__c = 'ASI_CRM_IOTHeader__cASI_CRM_MY_IOTHeader',
            ASI_CRM_IOTDetailRTypeAPI__c = 'ASI_CRM_IOTLine__cASI_CRM_MY_IOTLine',
            ASI_CRM_EventRTypeAPI__c = 'ASI_CRM_EVENTCapture__cASI_CRM_MY_EVENTCapture',
            ASI_CRM_CustomerFilter__c = '',
            ASI_CRM_SKURSPFilter__c = 'ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c != \'PR\'',
            ASI_CRM_SKUIOTFilter__c = 'ASI_CRM_Selectable_In_Order__c = true'
        );
        insert rtSetting;
        
        ASI_CRM_AccountsAdditionalField__c wholesaler = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Wholesaler');
        ASI_CRM_AccountsAdditionalField__c outlet = ASI_CRM_MY_TestClassHelper.createCustomer('customer2', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
        wholesaler.ASI_CRM_MY_IOTEmail__c = 'user1@test.com;user2@test.com';
        upsert wholesaler;
        upsert outlet;
		
		ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
		ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
		ASI_MFM_SKU_Code__c sku2 = ASI_CRM_MY_TestClassHelper.createSKU('sku2', productCategory);
        
        ASI_HK_CRM_Visitation_Plan__c visitationPlan = new ASI_HK_CRM_Visitation_Plan__c(Name = 'Test Visitation Plan', RecordTypeid = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_MY_VisitationPlan'), ASI_HK_CRM_Year__c = String.valueOf(System.today().year()), ASI_HK_CRM_Month__c = System.now().format('MMMM')); 
        insert visitationPlan;
        
        visitationPlan.ownerid = userID;
        update visitationPlan;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail1 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = outlet.id, ASI_HK_CRM_Visit_Date__c = System.today(), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_VisitationPlanDetail'));
        insert vpDetail1;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail2 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = outlet.id, ASI_HK_CRM_Visit_Date__c = System.today(), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Cold_Call'));
        insert vpDetail2;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail3 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = outlet.id, ASI_HK_CRM_Visit_Date__c = System.today(), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Ad_Hoc'));
		insert vpDetail3;

		ASI_CRM_IOTHeader__c iotHeader = new ASI_CRM_IOTHeader__c(
            ASI_CRM_Wholesaler__c = wholesaler.Id,
            ASI_CRM_Customer__c = outlet.Id,
            ASI_CRM_MY_IOTConfirm__c = true,
            ASI_CRM_MY_EmailSent__c = false,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_IOTHeader__cASI_CRM_MY_IOTHeader')
        );
        insert iotHeader;

        ASI_CRM_IOTLine__c iotLine = new ASI_CRM_IOTLine__c(
            ASI_CRM_IOTHeader__c = iotHeader.Id,
            ASI_CRM_SKU__c = sku1.Id,
            ASI_CRM_Quantity__c = 1,
            ASI_CRM_FOCQuantity__c = 1,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_IOTLine__cASI_CRM_MY_IOTLine')
        );
        insert iotLine;
        
        ASI_CRM_RSPHeader__c rspHeader = new ASI_CRM_RSPHeader__c(ASI_CRM_Customer__c = outlet.id, ASI_CRM_Date__c = System.today(), recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_RSPHeader__cASI_CRM_MY_RSPHeader'));
        insert rspHeader; 
            
        ASI_TH_CRM_RSP__c rspLine = new ASI_TH_CRM_RSP__c(ASI_CRM_RSPHeader__c = rspHeader.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Price_to_Consumer__c = 200, recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_RSP__cASI_CRM_MY_RSP'));
		insert rspLine;

		String rspHeaderStr = '{"ASI_CRM_Customer__c":"' + outlet.id + '","ASI_CRM_Date__c":"2020-06-10","ASI_CRM_Remark__c":"ab"}';
		String rspDetailStr = '[{"ASI_CRM_RSPHeader__c":null,"ASI_CRM_CN_Input_Date_Time__c":null,"ASI_CRM_Price_to_Consumer__c":"10","ASI_CRM_SKU__c":"' + sku1.id + '"}]';
		String rspDeleteStr = '[{"id":"' + rspLine.id + '"}]';
        
		Test.startTest();
        ASI_CRM_VisitationStoreDetailsController.getCustomerProsSegmentation(outlet.id);
        Test.stopTest();
    }
    
    static testMethod void visitTest()
	{
        ID userID = UserInfo.getUserId();

        ASI_CRM_MY_TestClassHelper.createMYSetting();

        ASI_CRM_MY_Settings__c mySetting = new ASI_CRM_MY_Settings__c(
            ASI_CRM_MY_GST_Rate__c = 6.00,
            ASI_CRM_MY_Offtake_Cutoff_Day__c = 26,
            ASI_CRM_MY_Salesman_Commission__c = 0.01,
            ASI_CRM_MY_Visitation_Plan_Outlet_Limit__c = 5000,
            ASI_CRM_MY_Google_API_KEY__c = 'AIzaSyAz-G6GDwcN0c4XRvReLmUVImv-spOynU8'
        );
        insert mySetting;
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();

        ASI_CRM_VisitationPlanSetting__c vpdSetting = new ASI_CRM_VisitationPlanSetting__c(
            ASI_CRM_Bottle_Label__c = 'PR,GMA,Counterfeit',
            ASI_CRM_Custody_Condition__c = 'Clean,Not Clean',
            ASI_CRM_Event_Active__c = false,
            ASI_CRM_Event_Label__c = 'Event',
            ASI_CRM_Event_Required__c = false,
            ASI_CRM_Familiar_With_PRM__c = 'Yes,No',
            ASI_CRM_GMA_Active__c = false,
            ASI_CRM_GMA_Label__c = 'GMA',
            ASI_CRM_GMA_Required__c = false,
            ASI_CRM_IOT_Active__c = true,
            ASI_CRM_IOT_Email__c = true,
            ASI_CRM_IOT_Label__c = 'IOT',
            ASI_CRM_IOT_Required__c = false,
            ASI_CRM_Outlet_Type__c = 'CO,NCO,Competitor CO',
            ASI_CRM_Own_Activations__c = 'Yes,No',
            ASI_CRM_QVAP_Active__c = true,
            ASI_CRM_QVAP_Label__c = 'QVAP',
            ASI_CRM_QVAP_Required__c = false,
            ASI_CRM_RSP_Active__c = true,
            ASI_CRM_RSP_Label__c = 'RSP',
            ASI_CRM_RSP_Required__c = false,
            ASI_CRM_Top_Of_Staff_Mind__c = 'Yes,No',
            ASI_CRM_Customer_Detail_Field_1__c = 'Channel|ASI_CRM_AccountsAdditionalField__c.ASI_CRM_Channel__r.Name',
            ASI_CRM_Customer_Detail_Field_2__c = 'Outlet Prioritization|ASI_CRM_Pros_Segmentation__c.ASI_CRM_OP__r.Name',
            ASI_CRM_Customer_Detail_Field_3__c = 'Visit Frequency|ASI_CRM_Pros_Segmentation__c.ASI_CRM_Visit_Frequency_Thresholds__r.ASI_CRM_Visit_Frequency__c',
            ASI_CRM_Customer_Detail_Field_4__c = 'Sub-Channel Name|ASI_CRM_Pros_Segmentation__c.Sub_Channel__r.Name',
            ASI_CRM_Customer_Detail_Field_5__c = 'Image Level Name|ASI_CRM_Pros_Segmentation__c.ASI_CRM_SG_Image_Level__r.ASI_CRM_SG_Name__c',
            ASI_CRM_Customer_Detail_Field_6__c = 'Recommended CM|ASI_CRM_Pros_Segmentation__c.ASI_CRM_Investment_Guidelines_Thresholds__r.ASI_CRM_Recommended_CM__c',
            ASI_CRM_Visitation_Plan_Field_1__c = 'Customer Name|Name',
            ASI_CRM_Visitation_Plan_Field_2__c = 'Channel|ASI_CRM_Channel__r',
            ASI_CRM_Visitation_Plan_Field_3__c = 'Outlet Type|ASI_TH_CRM_OutletType__r',
            ASI_CRM_Visitation_Plan_Field_4__c = 'Outlet Image|ASI_TH_CRM_OutletImage__r',
            ASI_CRM_Visitation_Plan_Field_5__c = 'Phone Number|ASI_CRM_CN_Phone_Number__c',
            ASI_CRM_Visitation_Plan_Field_6__c = 'Grade|ASI_CRM_CN_Grade__c',
            ASI_CRM_Visitation_Plan_Filter_1__c = 'Customer Name|Name',
            ASI_CRM_Visitation_Plan_Filter_2__c = 'Customer Grade|ASI_CRM_CN_Grade__c',
            ASI_CRM_Visitation_Plan_Filter_3__c = 'Owner Name|Owner.Name',
            ASI_CRM_Customer_Address__c = 'ASI_CRM_CN_Address__c',
            ASI_CRM_Customer_Phone__c = 'ASI_CRM_CN_Phone_Number__c'
        );
        insert vpdSetting;

        ASI_CRM_VisitationRTypeMapping__c rtSetting = new ASI_CRM_VisitationRTypeMapping__c(
            ASI_CRM_CustomerRTypeAPI__c = 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet',
            ASI_CRM_VisitationPlanRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan__cASI_CRM_MY_VisitationPlan',
            ASI_CRM_VisitationPlanDetailRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_VisitationPlanDetail',
            ASI_CRM_VisitationPlanDetailAHRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Ad_Hoc',
            ASI_CRM_VisitationPlanDetailCCRTypeAPI__c = 'ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Cold_Call',
            ASI_CRM_WholesalerRTypeAPI__c = 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Wholesaler',
            ASI_CRM_BrandRTypeAPI__c = 'ASI_MFM_Brand__cASI_MFM_MY_Brand',
            ASI_CRM_SubBrandRTypeAPI__c = 'ASI_MFM_Sub_brand__cASI_MFM_MY_Sub_brand',
            ASI_CRM_SKURTypeAPI__c = 'ASI_MFM_SKU_Code__cASI_CRM_MY_SKU',
            ASI_CRM_RSPHeaderRTypeAPI__c = 'ASI_CRM_RSPHeader__cASI_CRM_MY_RSPHeader',
            ASI_CRM_RSPDetailRTypeAPI__c = 'ASI_TH_CRM_RSP__cASI_CRM_MY_RSP',
            ASI_CRM_IOTHeaderRTypeAPI__c = 'ASI_CRM_IOTHeader__cASI_CRM_MY_IOTHeader',
            ASI_CRM_IOTDetailRTypeAPI__c = 'ASI_CRM_IOTLine__cASI_CRM_MY_IOTLine',
            ASI_CRM_EventRTypeAPI__c = 'ASI_CRM_EVENTCapture__cASI_CRM_MY_EVENTCapture',
            ASI_CRM_CustomerFilter__c = '',
            ASI_CRM_SKURSPFilter__c = 'ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c != \'PR\'',
            ASI_CRM_SKUIOTFilter__c = 'ASI_CRM_Selectable_In_Order__c = true'
        );
        insert rtSetting;
        
        ASI_CRM_AccountsAdditionalField__c wholesaler = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Wholesaler');
        ASI_CRM_AccountsAdditionalField__c outlet = ASI_CRM_MY_TestClassHelper.createCustomer('customer2', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
        wholesaler.ASI_CRM_MY_IOTEmail__c = 'user1@test.com;user2@test.com';
        upsert wholesaler;
        upsert outlet;
		
		ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
		ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
		ASI_MFM_SKU_Code__c sku2 = ASI_CRM_MY_TestClassHelper.createSKU('sku2', productCategory);
        
        ASI_HK_CRM_Visitation_Plan__c visitationPlan = new ASI_HK_CRM_Visitation_Plan__c(Name = 'Test Visitation Plan', RecordTypeid = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_MY_VisitationPlan'), ASI_HK_CRM_Year__c = String.valueOf(System.today().year()), ASI_HK_CRM_Month__c = System.now().format('MMMM')); 
        insert visitationPlan;
        
        visitationPlan.ownerid = userID;
        update visitationPlan;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail1 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = outlet.id, ASI_HK_CRM_Visit_Date__c = System.today(), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_VisitationPlanDetail'));
        insert vpDetail1;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail2 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = outlet.id, ASI_HK_CRM_Visit_Date__c = System.today(), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Cold_Call'));
        insert vpDetail2;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail3 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = outlet.id, ASI_HK_CRM_Visit_Date__c = System.today(), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Ad_Hoc'));
		insert vpDetail3;
		
		ASI_CRM_IOTHeader__c iotHeader = new ASI_CRM_IOTHeader__c(
            ASI_CRM_Wholesaler__c = wholesaler.Id,
            ASI_CRM_Customer__c = outlet.Id,
            ASI_CRM_MY_IOTConfirm__c = true,
            ASI_CRM_MY_EmailSent__c = false,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_IOTHeader__cASI_CRM_MY_IOTHeader')
        );
        insert iotHeader;
        
        ASI_CRM_IOTLine__c iotLine = new ASI_CRM_IOTLine__c(
            ASI_CRM_IOTHeader__c = iotHeader.Id,
            ASI_CRM_SKU__c = sku1.Id,
            ASI_CRM_Quantity__c = 1,
            ASI_CRM_FOCQuantity__c = 1,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_IOTLine__cASI_CRM_MY_IOTLine')
        );
        insert iotLine;
        
        ASI_CRM_RSPHeader__c rspHeader = new ASI_CRM_RSPHeader__c(ASI_CRM_Customer__c = outlet.id, ASI_CRM_Date__c = System.today(), recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_RSPHeader__cASI_CRM_MY_RSPHeader'));
        insert rspHeader; 
            
        ASI_TH_CRM_RSP__c rspLine = new ASI_TH_CRM_RSP__c(ASI_CRM_RSPHeader__c = rspHeader.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Price_to_Consumer__c = 200, recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_RSP__cASI_CRM_MY_RSP'));
		insert rspLine;

		String rspHeaderStr = '{"ASI_CRM_Customer__c":"' + outlet.id + '","ASI_CRM_Date__c":"2020-06-10","ASI_CRM_Remark__c":"ab"}';
		String rspDetailStr = '[{"ASI_CRM_RSPHeader__c":null,"ASI_CRM_CN_Input_Date_Time__c":null,"ASI_CRM_Price_to_Consumer__c":"10","ASI_CRM_SKU__c":"' + sku1.id + '"}]';
        String rspDeleteStr = '[{"id":"' + rspLine.id + '"}]';
        
        Note note = new Note(
            ParentId = vpDetail1.id,
            Title = 'title',
            Body = 'Body'
        );
        insert note;

        ASI_CRM_EVENTCapture__c eventCapture = new ASI_CRM_EVENTCapture__c(
            Name = 'promotion',
            ASI_CRM_MY_TypeActivation__c = 'Promotion',
            ASI_CRM_MY_VisitationPlanDetail__c = vpDetail1.id
        );

        ASI_CRM_EVENTCapture__c eventCapture1 = new ASI_CRM_EVENTCapture__c(
            Name = 'promotion',
            ASI_CRM_MY_TypeActivation__c = 'Promotion',
            ASI_CRM_MY_VisitationPlanDetail__c = vpDetail1.id
        );
        insert eventCapture1;

		Test.startTest();
        ASI_CRM_VisitationPlanDetailTodayCtr.getVisitationPlanDetail(vpDetail1.id);
        ASI_CRM_VisitationPlanDetailTodayCtr.getCurrentVisitationPlanDetail(vpDetail1.id);
        ASI_CRM_VisitationPlanDetailTodayCtr.saveVisitationPlanDetail(JSON.serialize(vpDetail1));
        ASI_CRM_VisitationPlanDetailTodayCtr.updateVisitationTime(vpDetail1.id, 'StartVisit');
        ASI_CRM_VisitationPlanDetailTodayCtr.updateVisitationTime(vpDetail1.id, 'CancelVisit');
        ASI_CRM_VisitationPlanDetailTodayCtr.updateVisitationTime(vpDetail1.id, 'EndVisit');
        ASI_CRM_VisitationPlanDetailTodayCtr.getNote(note.id);
        ASI_CRM_VisitationPlanDetailTodayCtr.upsertNote(note.id, 'title1', 'body1', vpDetail1.id);
        ASI_CRM_VisitationPlanDetailTodayCtr.getEventList(vpDetail1.id);
        ASI_CRM_VisitationPlanDetailTodayCtr.createEventCapture(JSON.serialize(eventCapture));
        ASI_CRM_VisitationPlanDetailTodayCtr.getEventCapture(eventCapture1.id);
        ASI_CRM_VisitationPlanDetailTodayCtr.updateEventCapture(JSON.serialize(eventCapture1));
        ASI_CRM_CustomLookupCtr.getRecordList('ASI_CRM_AccountsAdditionalField__c', 'Name', 'RecordTypeId', new List<String>{'ASI_CRM_CN_Eng_Name__c'}, 'customer1', '', 10);
        Test.stopTest();
	}
	
	static testMethod void sendIOTEmailTest() 
    {
        ASI_CRM_MY_TestClassHelper.createMYSetting();
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();

        ASI_CRM_AccountsAdditionalField__c wholesaler = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Wholesaler');
        ASI_CRM_AccountsAdditionalField__c outlet = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
        wholesaler.ASI_CRM_MY_IOTEmail__c = 'user1@test.com;user2@test.com';
        upsert wholesaler;
        upsert outlet;
	
        ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
        ASI_MFM_SKU_Code__c sku = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
        
        ASI_CRM_IOTHeader__c header = new ASI_CRM_IOTHeader__c(
            ASI_CRM_Wholesaler__c = wholesaler.Id,
            ASI_CRM_Customer__c = outlet.Id,
            ASI_CRM_MY_IOTConfirm__c = true,
			ASI_CRM_MY_EmailSent__c = false,
			ASI_CRM_Send_Email__c = true
        );
        insert header;

        ASI_CRM_IOTLine__c line = new ASI_CRM_IOTLine__c(
            ASI_CRM_IOTHeader__c = header.Id,
            ASI_CRM_SKU__c = sku.Id,
            ASI_CRM_Quantity__c = 1,
            ASI_CRM_FOCQuantity__c = 1
        );
        insert line;

        Test.startTest();
            ASI_CRM_MY_SendIOTEmailBatch obj = new ASI_CRM_MY_SendIOTEmailBatch();
            DataBase.executeBatch(obj, 5);
            ASI_CRM_MY_SendIOTEmailScheduler sh1 = new ASI_CRM_MY_SendIOTEmailScheduler();
            String sch = '0 0 * * * ?'; 
            system.schedule('Send IOT Email Scheduler Check', sch, sh1); 
        Test.stopTest();
    }
    
    public class HTTPMockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            string jsonResBody = '{"results":[{"address_components":[{"long_name":"Muir Lane","short_name":"Muir Ln","types":["route"]},{"long_name":"Torrey Pines","short_name":"Torrey Pines","types":["neighborhood","political"]},{"long_name":"San Diego","short_name":"San Diego","types":["locality","political"]},{"long_name":"San Diego County","short_name":"San Diego County","types":["administrative_area_level_2","political"]},{"long_name":"California","short_name":"CA","types":["administrative_area_level_1","political"]},{"long_name":"United States","short_name":"US","types":["country","political"]},{"long_name":"92161","short_name":"92161","types":["postal_code"]}],"formatted_address":"Muir Ln, San Diego, CA 92161, USA","geometry":{"location":{"lat":32.8790299,"lng":-117.2413533},"location_type":"GEOMETRIC_CENTER","viewport":{"northeast":{"lat":32.8803788802915,"lng":-117.2400043197085},"southwest":{"lat":32.8776809197085,"lng":-117.2427022802915}}},"place_id":"ChIJV1aG1sAG3IAR6EsgRezpoa0","plus_code":{"compound_code":"VQH5+JF San Diego, California, United States","global_code":"8544VQH5+JF"},"types":["establishment","point_of_interest","school"]}],"status":"OK"}';
            res.setBody(jsonResBody);
            return res;
        }
    }
}