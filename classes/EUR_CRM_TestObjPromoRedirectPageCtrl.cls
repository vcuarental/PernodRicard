@isTest
public class EUR_CRM_TestObjPromoRedirectPageCtrl{

    private static final String CLASS_NAME = 'EUR_CRM_ObjPromoRedirectPageController';

    private static final Map<String,String> recordTypePageMap = new Map<String,String>{
        'EUR_DE_Off_Trade_Leaflet_Campaign'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_Off_Trade_Sales_Drive'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_Off_Trade_Secondary_Placement'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_OnTrade_PROS_TMKT_Promo'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_Off_Trade_Tasting_Campaign'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_Off_Trade_Trade_Fair'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_Off_Trade_Secondary_Placement_Carton'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_Off_Trade_Secondary_Placement_Gondelkopf'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_Off_Trade_Secondary_Placement_Razz_Fazz'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_Off_Trade_Secondary_Placement_Standard'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_Off_Trade_Secondary_Placement_Theme'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_Off_Trade_Secondary_Placement_Promo_Display'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_Off_Trade_Distribution_Drive'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_Off_Trade_Sales_Drive_SKU_Bottles'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_Off_Trade_Sales_Drive_SKU_Displays'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_WS_Objective'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_WS_Promotion_with_Lead_Time'=>'EUR_CRM_DE_ObjectivePromoPage',
        'EUR_DE_WS_Promotion_without_Lead_Time'=>'EUR_CRM_DE_ObjectivePromoPage',

        'EUR_FI_Off_Trade_O_P'=>'EUR_CRM_FI_ObjectivePromoPage',
        'EUR_FI_On_Trade_O_P'=>'EUR_CRM_FI_ObjectivePromoPage',

        'EUR_ZA_Off_Trade_Promotion' => 'EUR_CRM_ZA_ObjectivePromoPage',
        'EUR_ZA_On_Trade_Promotion' => 'EUR_CRM_ZA_ObjectivePromoPage',

        'EUR_RU_Off_Trade_Loyalty_POSM_Placement' => 'EUR_CRM_RU_ObjectivePromoPage',
        'EUR_RU_Off_Trade_POSM_Placement' => 'EUR_CRM_RU_ObjectivePromoPage',
        'EUR_RU_ON_Trade_Phase_1'=>'EUR_CRM_RU_ObjectivePromoPage',
        'EUR_RU_ON_Trade_Phase_2'=>'EUR_CRM_RU_ObjectivePromoPage',
        'EUR_RU_Off_Trade_Discount_Campaign'=>'EUR_CRM_RU_ObjectivePromoPage',
        'EUR_RU_Off_Trade_InStore_Media_POSM_Control'=>'EUR_CRM_RU_ObjectivePromoPage',
        'EUR_RU_Off_Trade_Leaflet_Campaign'=>'EUR_CRM_RU_ObjectivePromoPage',
        'EUR_RU_Off_Trade_Model_Store'=>'EUR_CRM_RU_ObjectivePromoPage',
        'EUR_RU_Off_Trade_On_Site_Promo_Activities'=>'EUR_CRM_RU_ObjectivePromoPage',
        'EUR_RU_Off_Trade_Outlet_Staff_Incentive'=>'EUR_CRM_RU_ObjectivePromoPage',
        'EUR_RU_Off_Trade_Sales_Rep_Competition'=>'EUR_CRM_RU_ObjectivePromoPage',
        'EUR_RU_Off_Trade_Stop_Rayon'=>'EUR_CRM_RU_ObjectivePromoPage',

        'EUR_BE_Off_Trade_Sales_Drive' => 'EUR_CRM_BE_ObjectivePromoPage',
        'EUR_BE_Off_Trade_Secondary_placement_Spyder_display' => 'EUR_CRM_BE_ObjectivePromoPage',
        'EUR_BE_On_Trade_Promo_Kit_Activation' => 'EUR_CRM_BE_ObjectivePromoPage',
        'EUR_BE_On_Trade_Secondary_Display_Placement' => 'EUR_CRM_BE_ObjectivePromoPage',
        'EUR_BE_On_Trade_Display_Placement_For_Special_Cavist' => 'EUR_CRM_BE_ObjectivePromoPage',

        'EUR_PT_Off_Trade_OP_No_of_Display' => 'EUR_CRM_PT_ObjectivePromoPage',

        'EUR_DK_Off_Trade_EM_Price_Promotion'=> 'EUR_CRM_DK_ObjectivePromoPage',
        'EUR_DK_Off_Trade_Distribution_Drive'=> 'EUR_CRM_DK_ObjectivePromoPage',
        'EUR_DK_Off_Trade_Leaflet_Campaign'=> 'EUR_CRM_DK_ObjectivePromoPage',
        'EUR_DK_Off_Trade_Tasting_Campaign'=> 'EUR_CRM_DK_ObjectivePromoPage',

        'EUR_DK_OFF_Trade_Sales_Drive_SKU_Cartons'=> 'EUR_CRM_DK_ObjectivePromoPage',
        'EUR_DK_Off_2nd_Placement_Sell_In_Qty_Promo_Display'=> 'EUR_CRM_DK_ObjectivePromoPage',
        'EUR_DK_Off_Trade_Sales_Drive_SKU_Bottles'=> 'EUR_CRM_DK_ObjectivePromoPage',
        'EUR_DK_Off_Trade_Sales_Drive_SKU_Displays'=> 'EUR_CRM_DK_ObjectivePromoPage',
        'EUR_DK_Off_Trade_Secondary_Placement_Carton'=> 'EUR_CRM_DK_ObjectivePromoPage',
        'EUR_DK_Off_Trade_Secondary_Placement_Gondola_End'=> 'EUR_CRM_DK_ObjectivePromoPage',
        'EUR_DK_Off_Trade_Secondary_Placement_Standard'=> 'EUR_CRM_DK_ObjectivePromoPage',
        'EUR_DK_Off_Trade_Secondary_Placement_Theme'=> 'EUR_CRM_DK_ObjectivePromoPage',

        'EUR_SE_Listing_Campaign'=>'EUR_CRM_SE_ObjectivePromoPage',
        'EUR_SE_Staff_Communication'=>'EUR_CRM_SE_ObjectivePromoPage',
        'EUR_SE_Volume_Campaign'=>'EUR_CRM_SE_ObjectivePromoPage',
        'EUR_SE_Volume_Trip_Campaign_Bundle'=>'EUR_CRM_SE_ObjectivePromoPage',
        'EUR_SE_Volume_Campaign_Slow_moving'=>'EUR_CRM_SE_ObjectivePromoPage',
        'EUR_SE_Events'=>'EUR_CRM_SE_ObjectivePromoPage',
        'EUR_SE_Staff_Training_Education'=>'EUR_CRM_SE_ObjectivePromoPage'
    };

    private static void initCMT() {
        EUR_CRM_RecordTypeHelper_v2.rtMapsForTest
            .addAll(EUR_CRM_RecordTypeHelper_v2.makeRtMapsForTest(CLASS_NAME, 'recordTypePageMap', recordTypePageMap));
    }



    @IsTest
    private static void redirectTest() {
        initCMT();
        
        EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
        EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
        1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE,'test')[0];
        objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2017, 07,02);
        //objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
        insert objPromo;
        objPromo = [SELECT Id, RecordTypeId, RecordType.DeveloperName From EUR_CRM_ObjPromo__c WHERE Id = :objPromo.Id];
        Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
        EUR_CRM_ObjPromoRedirectPageController con = new EUR_CRM_ObjPromoRedirectPageController(sc );

        PageReference pr = con.redirect();
        system.Assert(pr != null );
    }

//    @isTest
//    public static void testRedirect(){
//        EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
//        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
//            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
//            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
//            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE,'test')[0];
//            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2017, 07,02);
//            //objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
//            insert objPromo;
//            objPromo = [SELECT Id, RecordTypeId, RecordType.DeveloperName From EUR_CRM_ObjPromo__c WHERE Id = :objPromo.Id];
//            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
//            EUR_CRM_ObjPromoRedirectPageController con = new EUR_CRM_ObjPromoRedirectPageController(sc );
//
//            PageReference pr = con.redirect();
//            system.Assert(pr != null );
//        }
//    }
}