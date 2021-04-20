/***************************************************************************************************************************
* Name:        ASI_CRM_CN_InventoryVisibilityJob_Test
* Description: Test class for ASI_CRM_CN_Inventory_Visibility_Schedule, ASI_CRM_CN_InventoryVisibilityDetail_Job
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-03-05       vincent Lam             Created
****************************************************************************************************************************/
@isTest
public class ASI_CRM_CN_InventoryVisibilityJob_Test{
    @testSetup static void setUpData(){
        
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
        insert ProductCategoryList;
        
        
        
        
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
        insert SubCategoryList;
        
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
        Insert BrandList;
        
        
        
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;
        
        // create item group
        ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'), 
            Name = 'TestItemGroup',
            ASI_MFM_Item_Group_Code__c = 'aaa',
            ASI_CRM_CN_Eng_Name__c = 'TestItemGroup',
            ASI_CRM_Request_Dispatch_Day__c = 10,
            ASI_MFM_Sub_brand__c = subBrands[0].id
        );
        insert itemGroup;

        // insert warehouse code
        String warehouseCode = '398DPWH6';
        /*
        ASI_CRM_CN_InventoryVisibilityWarehouse__mdt wh = new ASI_CRM_CN_InventoryVisibilityWarehouse__mdt(
            ASI_CRM_Location__c = 'SH',
            ASI_CRM_Status__c = 'DP1',
            ASI_CRM_Warehouse_Code__c = warehouseCode
        );
        insert wh;
        */

        // prepare insert inventory visibility header
        String OPERATION_TYPE_DP = 'Duty Paid';
        String OPERATION_TYPE_MOVE_TO_DP = 'PO Move to DP';
        String OPERATION_TYPE_PENDING = 'PO Move to Pending';
        String OPERATION_TYPE_DF = 'Duty Free';
        String OPERATION_TYPE_MOVE_TO_DF = 'PO Move to DF';
        String OPERATION_TYPE_IN_TRANSIT = 'PO Intransit';
        List<string> List_operationType = new List<string>{
            OPERATION_TYPE_DP,
            OPERATION_TYPE_MOVE_TO_DP,
            OPERATION_TYPE_PENDING,
            OPERATION_TYPE_DF,
            OPERATION_TYPE_MOVE_TO_DF,
            OPERATION_TYPE_IN_TRANSIT
        };
        String RTID_IV_Original = Global_RecordTypeCache.getRTId('ASI_CRM_Inventory_Visibility__cASI_CRM_CN_Inventory_Visibility');
        List<String> API_TYPE_PENDING_PO_FOR_CALCULATION = new List<String>{
            'PWC_IN_IDF_8', '3PL_IN_TAX_12'
    	};

        // insert inventory visibility header
        List<ASI_CRM_Inventory_Visibility__c> list_iv = new List<ASI_CRM_Inventory_Visibility__c>();
        for(string operationType : List_operationType){
            for(string apiType : API_TYPE_PENDING_PO_FOR_CALCULATION){
                ASI_CRM_Inventory_Visibility__c iv = new ASI_CRM_Inventory_Visibility__c(
                    RecordTypeId = RTID_IV_Original,
                    ASI_CRM_PO_Number__c = 'PONumber1',
                    ASI_CRM_Operation_Type__c = operationType,
                    ASI_CRM_WH_Code_To__c = warehouseCode,
                    ASI_CRM_ETA_Date__c = system.today().addDays(10),
                    ASI_CRM_IDF_Invoice_Date__c = system.today().addDays(5),
                    ASI_CRM_Date__c = system.today().addDays(1),
                    ASI_CRM_API_Type__c = apiType
                );
                list_iv.add(iv);
            }
            
        }
        insert list_iv;

        // insert inventory visibility line
        List<ASI_CRM_Inventory_Visibility_Detail__c> list_ivd = new List<ASI_CRM_Inventory_Visibility_Detail__c>();
        String RTID_IVD = Global_RecordTypeCache.getRTId('ASI_CRM_Inventory_Visibility_Detail__cASI_CRM_CN_Inventory_Visibility_Detail');
        for(ASI_CRM_Inventory_Visibility__c iv : list_iv){
            ASI_CRM_Inventory_Visibility_Detail__c ivd = new ASI_CRM_Inventory_Visibility_Detail__c(
                RecordtypeId = RTID_IVD,
                ASI_CRM_Inventory_Visibility__c = iv.id,
                ASI_CRM_Item_Group__c = itemGroup.id,
                ASI_CRM_UOM__c = 'BT',
                ASI_CRM_Purchase_QTY__c = 100
            );
            list_ivd.add(ivd);
        }
        insert list_ivd;

    }

    static testMethod void testSummaryReport(){
        Database.executeBatch(new ASI_CRM_CN_Inventory_Visibility_Schedule());
    }

    static testMethod void testDetailReport(){
        Database.executeBatch(new ASI_CRM_CN_InventoryVisibilityDetail_Job());
    }

    static testMethod void testDetailReportByLocation(){
        Database.executeBatch(new ASI_CRM_CN_InventoryVisibilityDetail_Job('SH'));
    }
}