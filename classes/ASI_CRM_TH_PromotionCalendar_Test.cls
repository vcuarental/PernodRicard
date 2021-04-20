/*********************************************************************************
 * Name: ASI_CRM_TH_PromotionCalendar_Test
 * 
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 01/06/2016       Introv: Twinkle LI      Created, Test Class for TH ASI_CRM_TH_PromotionCalendarCommonClass & ASI_CRM_TH_PromotionCalendarMonthCtrl
*********************************************************************************/
@isTest 
public with sharing class ASI_CRM_TH_PromotionCalendar_Test{
    public static List<ASI_HK_CRM_Promotion__c> dataInsert(){ 
        ASI_HK_CRM_Running_Number__c customerCodeRunningNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_Customer_Code', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = 'TH_A{000000}' );        
        insert customerCodeRunningNumber;
    
        ASI_HK_CRM_Running_Number__c contractRunningNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_Contract__c', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = '{YY/YY}{0000}' );        
        insert contractRunningNumber;   
        
        ASI_HK_CRM_Running_Number__c paymentRequestRunningNumber= new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_PaymentRequest__c', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = '60{YY}{0000}' );        
        insert paymentRequestRunningNumber; 
        
        ASI_HK_CRM_PromotionGenerator pmtGen = new ASI_HK_CRM_PromotionGenerator();
        Date todayDate = System.today();
        final Integer numOfPmt = 4;
        final List<Date> startAndEndDateList = new List<Date>{
            todayDate.addDays(3), todayDate.addDays(4)
            , todayDate.addDays(14), todayDate.addDays(20)
            , todayDate.addDays(13), todayDate.addDays(18)
            , todayDate.addDays(35), todayDate.addDays(41)
        };
        
        Id recordTypeid = Global_RecordTypeCache.getRtId('AccountASI_TH_CRM_Potential_Outlet');
        Account potentialOutlet = new Account(
            RecordTypeId = recordTypeid, 
            Name = 'TH Potential Outlet'
        );
        insert potentialOutlet;
        
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Promotion__cASI_TH_CRM_National');
        List<ASI_HK_CRM_Promotion__c> listPromotion = new List<ASI_HK_CRM_Promotion__c>();
        for (Integer i = 0; i < startAndEndDateList.size(); i += 2) {
          ASI_HK_CRM_Promotion__c pmt = pmtGen.generateGlobalPromotion(startAndEndDateList.get(i), startAndEndDateList.get(i + 1));
          pmt.recordtypeid = recordTypeid;
          pmt.ASI_CRM_Type__c = 'GWP';
          listPromotion.add(pmt);
        }
        listPromotion[0].ASI_CRM_Type__c = 'Event';
        insert listPromotion;
        
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Status__cASI_CRM_TH_PromotionStatus');
        List<ASI_CRM_Promotion_Status__c> listPromotionStatus = new List<ASI_CRM_Promotion_Status__c>();
        listPromotionStatus.add(new ASI_CRM_Promotion_Status__c(
            ASI_CRM_Account__c = potentialOutlet.id, 
            ASI_CRM_Promotion__c = listPromotion[0].id,
            ASI_CRM_Status__c = 'Proposed',
            ASI_CRM_Date__c = system.today())
        );
        listPromotionStatus.add(new ASI_CRM_Promotion_Status__c(
            ASI_CRM_Account__c = potentialOutlet.id, 
            ASI_CRM_Promotion__c = listPromotion[1].id,
            ASI_CRM_Status__c = 'Proposed',
            ASI_CRM_Date__c = system.today())
        );
        insert listPromotionStatus;
        
        return listPromotion;
    }
    
    static testMethod void PromotionCalendar_Test(){
        List<ASI_HK_CRM_Promotion__c> listPromotion = dataInsert(); 
        
        PageReference testPage = Page.ASI_CRM_TH_PromotionCalendarMonthPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put(ASI_CRM_TH_PromotionCalendarMonthCtrl.URL_PARAM_YEAR, String.valueOf(System.today().year()));
        pageParams.put(ASI_CRM_TH_PromotionCalendarMonthCtrl.URL_PARAM_MONTH, String.valueOf(System.today().month()));
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_TH_PromotionCalendarMonthCtrl controller = new ASI_CRM_TH_PromotionCalendarMonthCtrl(); 
        PageReference initRedirectPage = controller.initPage();
        
        List<ASI_CRM_TH_PromotionCalendarMonthCtrl.ASI_HK_CRM_PromotionMonthEvent> monthEventList = 
          ASI_CRM_TH_PromotionCalendarMonthCtrl.retrieveRecordsByTimeRange(
            ASI_CRM_TH_PromotionCalendarMonthCtrl.convertToRetrivalDateFormat(System.today())
            , ASI_CRM_TH_PromotionCalendarMonthCtrl.convertToRetrivalDateFormat(System.today().addDays(42))
        );
        
        List<ASI_CRM_TH_PromotionCalendarMonthCtrl.ASI_HK_CRM_PromotionMonthEvent> monthEventList_ps = 
          ASI_CRM_TH_PromotionCalendarMonthCtrl.retrieveFilteringRecordsByTimeRange(
            ASI_CRM_TH_PromotionCalendarMonthCtrl.convertToRetrivalDateFormat(System.today())
            , ASI_CRM_TH_PromotionCalendarMonthCtrl.convertToRetrivalDateFormat(System.today().addDays(42))
            , 'TH Potential Outlet'
            , '[Proposed]'
        );
          
        // Redirect to promotion detail page
        testPage.getParameters().put('pmtId', listPromotion.get(0).Id);
        testPage.getParameters().put('retURL', Page.ASI_CRM_TH_PromotionCalendarMonthPage.getUrl());
        PageReference pmtViewPage = controller.redirectToViewPage();
        List<SelectOption> statusList = controller.getStatusList();
    }
}