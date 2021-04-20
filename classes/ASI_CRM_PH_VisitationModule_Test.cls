@isTest
public class ASI_CRM_PH_VisitationModule_Test {
    
    @TestSetup
	public static void setup() {
        List<String> monthList = new List<String> {
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December'
        };

        String ownerId = UserInfo.getUserId();
        Date today = Date.today();

        List<ASI_CRM_AccountsAdditionalField__c> customerList = new List<ASI_CRM_AccountsAdditionalField__c>();
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c();
        customer.Name         = 'Testing';
        customer.OwnerId      = ownerId;
        customer.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_PH_Potential_Outlet');
        customerList.add(customer);

        ASI_CRM_AccountsAdditionalField__c customer2 = new ASI_CRM_AccountsAdditionalField__c();
        customer2.Name         = 'Testing 2';
        customer2.OwnerId      = ownerId;
        customer2.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_PH_Potential_Outlet');
        customerList.add(customer2);

        insert customerList;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c();
		brand.Name         = 'Test Brand';
	    brand.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_CRM_PH_DP_Brand');
		insert brand;

        List<ASI_MFM_Sub_brand__c> subBrandList = new List<ASI_MFM_Sub_brand__c>();
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c();
        subBrand1.Name             = 'Sub Brand';
        subBrand1.ASI_MFM_Brand__c = brand.Id;
        subBrand1.RecordTypeId     = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_PH_DP_Sub_brand');
        subBrandList.add(subBrand1);

        ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c();
        subBrand2.Name             = 'Sub Brand2';
        subBrand2.ASI_MFM_Brand__c = brand.Id;
        subBrand2.RecordTypeId     = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_PH_DP_Sub_brand');
        subBrandList.add(subBrand2);

		insert subBrandList;

        ASI_HK_CRM_Visitation_Plan__c visitationPlan = new ASI_HK_CRM_Visitation_Plan__c();
        visitationPlan.Name                = 'Testing Visitation Plan';   
        visitationPlan.ASI_HK_CRM_Year__c  = String.valueOf(today.year());
        visitationPlan.ASI_HK_CRM_Month__c = monthList.get(today.month() - 1);
        visitationPlan.OwnerId             = ownerId;
        visitationPlan.RecordTypeId        = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_PH_Visitation_Plan');
        insert visitationPlan;

        ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c();
        visitationPlanDetail.ASI_HK_CRM_Visitation_Plan__c      = visitationPlan.Id;
        visitationPlanDetail.ASI_HK_CRM_Visit_Date__c           = today;
        visitationPlanDetail.ASI_CRM_MY_Customer__c             = customer.Id;
        visitationPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c = today;
        visitationPlanDetail.ASI_HK_CRM_Status__c               = 'Achieved';
        visitationPlanDetail.ASI_CRM_Menu_Listing__c            = subBrand1.Name + ';' + subBrand2.Name;
        visitationPlanDetail.RecordTypeId                       = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_PH_Visitation_Plan_Detail');
        visitationPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c = Datetime.now();
        visitationPlanDetail.ASI_TH_CRM_Visit_Date_Time_To__c   = Datetime.now();
        insert visitationPlanDetail;
    }

    @isTest
    public static void testVisitationPlanCtrl() {
        Date today = Date.today();

        List<ASI_HK_CRM_Visitation_Plan__c> visitationPlanList = [SELECT Id FROM ASI_HK_CRM_Visitation_Plan__c];

        ASI_CRM_VisitationPlanCtrl.CustomVisitationPlan customVisitationPlan = ASI_CRM_VisitationPlanCtrl.getCustomVisitationPlan(visitationPlanList.get(0).Id);

        Integer customerCount = ASI_CRM_VisitationPlanCtrl.getPHCustomCustomerCount('Testing', true);
        List<ASI_CRM_AccountsAdditionalField__c> customerList = ASI_CRM_VisitationPlanCtrl.getPHCustomCustomerList('Testing', true, 20, 1);

        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
        ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c();
        visitationPlanDetail.ASI_HK_CRM_Visitation_Plan__c      = customVisitationPlan.visitationPlan.Id;
        visitationPlanDetail.ASI_HK_CRM_Visit_Date__c           = today;
        visitationPlanDetail.ASI_CRM_MY_Customer__c             = customerList.get(0).Id;
        visitationPlanDetail.ASI_HK_CRM_Status__c               = 'Planned';
        visitationPlanDetail.RecordTypeId                       = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_PH_Visitation_Plan_Detail');
        visitationPlanDetailList.add(visitationPlanDetail);

        String insertDetailListJson = JSON.serialize(visitationPlanDetailList);
        String updateDetailListJson = '[]';
        String deleteDetailIdListJson = '[]';

        ASI_CRM_VisitationPlanCtrl.savePHVisitationPlanDetail(insertDetailListJson, updateDetailListJson, deleteDetailIdListJson);
    }

    @isTest
    public static void testVisitationDetailMenuListingAndPouring() {
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList = [SELECT Id FROM ASI_HK_CRM_Visitation_Plan_Detail__c];

        ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail = ASI_CRM_PH_VisitationPlanModifyCtrl.getRecord(visitationPlanDetailList.get(0).Id);
        Map<String, Id> subBrandNameIdMap = ASI_CRM_PH_VisitationPlanModifyCtrl.getSubBrand();

        String menuListing = '';
        String pouring  = ''; 

        for(String subBrand : subBrandNameIdMap.keySet()) {
            menuListing += subBrand + ';';
            pouring     += pouring + ';';
        }

        ASI_CRM_PH_VisitationPlanModifyCtrl.saveRecord(visitationPlanDetailList.get(0).Id, menuListing, pouring);
        Delete visitationPlanDetail;        
    }

    @isTest
    public static void testingWorkInProgressReport() {
        ASI_CRM_PH_WorkInProgressReportCtrl.getCustomerDataSet();
    }

}