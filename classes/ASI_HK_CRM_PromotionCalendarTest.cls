@isTest
public with sharing class ASI_HK_CRM_PromotionCalendarTest {
    
    
    public static testMethod void test_main_month() {
      ASI_HK_CRM_PromotionGenerator pmtGen = new ASI_HK_CRM_PromotionGenerator();
      Date todayDate = System.today();
      final Integer numOfPmt = 4;
      final List<Date> startAndEndDateList = new List<Date>{
        todayDate.addDays(3), todayDate.addDays(4)
        , todayDate.addDays(14), todayDate.addDays(20)
        , todayDate.addDays(13), todayDate.addDays(18)
        , todayDate.addDays(35), todayDate.addDays(41)
      };
        List<ASI_HK_CRM_Promotion__c> pmtList = new List<ASI_HK_CRM_Promotion__c>();
        for (Integer i = 0; i < startAndEndDateList.size(); i += 2) {
          pmtList.add(pmtGen.generateGlobalPromotion(startAndEndDateList.get(i), startAndEndDateList.get(i + 1)));
        }
        insert pmtList;
        
        Test.startTest();
        
        // Initialize page and controller
        PageReference testPage = Page.ASI_HK_CRM_PromotionCalendarMonthPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put(ASI_HK_CRM_PromotionCalendarMonthCON.URL_PARAM_YEAR, String.valueOf(todayDate.year()));
        pageParams.put(ASI_HK_CRM_PromotionCalendarMonthCON.URL_PARAM_MONTH, String.valueOf(todayDate.month()));
        Test.setCurrentPageReference(testPage);
        ASI_HK_CRM_PromotionCalendarMonthCON testController = new ASI_HK_CRM_PromotionCalendarMonthCON();
        PageReference initRedirectPage = testController.initPage();
        System.assertEquals(null, initRedirectPage);
        
        List<ASI_HK_CRM_PromotionCalendarMonthCON.ASI_HK_CRM_PromotionMonthEvent> monthEventList = 
          ASI_HK_CRM_PromotionCalendarMonthCON.retrievePromotionsByTimeRange(
            ASI_HK_CRM_PromotionCalendarMonthCON.convertToRetrivalDateFormat(todayDate)
            , ASI_HK_CRM_PromotionCalendarMonthCON.convertToRetrivalDateFormat(todayDate.addDays(42))
        );
      System.assertEquals(numOfPmt, monthEventList.size());
      
      // Redirect to promotion detail page
      testPage.getParameters().put('pmtId', pmtList.get(0).Id);
      testPage.getParameters().put('retURL', Page.ASI_HK_CRM_PromotionCalendarMonthPage.getUrl());
      PageReference pmtViewPage = testController.redirectToViewPage();
      System.assert(pmtViewPage != null);
      
      // Redirect to year view calendar
      testController.selectedCalendarType = ASI_HK_CRM_PromotionCalendarCommonClass.CALENDAR_TYPE_YEAR;
      PageReference anotherCalendarPage = testController.redirectToAnotherCalendarType();
      System.assertEquals(Page.ASI_HK_CRM_PromotionCalendarYearPage.getUrl(), anotherCalendarPage.getUrl());
        
        Test.stopTest();
    }
 
  
  public static testMethod void test_main_year() {
      ASI_HK_CRM_PromotionGenerator pmtGen = new ASI_HK_CRM_PromotionGenerator();
      ASI_HK_CRM_BrandGenerator brandGen = new ASI_HK_CRM_BrandGenerator();
      ASI_HK_CRM_SubBrandGenerator sbGen = new ASI_HK_CRM_SubBrandGenerator();
      ASI_HK_CRM_AccountGenerator acctGen = new ASI_HK_CRM_AccountGenerator();
      Date todayDate = System.today();
      final Integer numOfPmt = 4;
      final List<Date> startAndEndDateList = new List<Date>{
        todayDate.addDays(3), todayDate.addDays(4)
        , todayDate.addDays(14), todayDate.addDays(20)
        , todayDate.addDays(13), todayDate.addDays(18)
        , todayDate.addDays(35), todayDate.addDays(41)
      };
        List<ASI_HK_CRM_Promotion__c> pmtList = new List<ASI_HK_CRM_Promotion__c>();
        for (Integer i = 0; i < startAndEndDateList.size(); i += 2) {
          pmtList.add(pmtGen.generateTeamPromotion(startAndEndDateList.get(i), startAndEndDateList.get(i + 1)));
        }
        insert pmtList;
        
        ASI_MFM_Brand__c brand = brandGen.generateBrand();
        insert brand;
        List<ASI_MFM_Sub_brand__c> sbList = new List<ASI_MFM_Sub_brand__c>();
        for (Integer i = 0; i < 2; i++) {
          sbList.add(sbGen.generateSubBrand(brand));
        }
        insert sbList;
        Account ws = acctGen.generateAccount(ASI_HK_CRM_AccountGenerator.RT_JDE_CREDIT);
        insert ws;
        List<ASI_HK_CRM_Promotion_Detail__c> pmtDetailList = pmtGen.generatePromotionDetails(pmtList.get(0), sbList, new List<Account>{ws});
        insert pmtDetailList;
        
        Test.startTest();
        
        // Initialize page and controller
        PageReference testPage = Page.ASI_HK_CRM_PromotionCalendarYearPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put(ASI_HK_CRM_PromotionCalendarYearCON.URL_PARAM_YEAR, String.valueOf(todayDate.year()));
        pageParams.put(ASI_HK_CRM_PromotionCalendarYearCON.URL_PARAM_MONTH, String.valueOf(todayDate.month() - 1));
        Test.setCurrentPageReference(testPage);
        ASI_HK_CRM_PromotionCalendarYearCON testController = new ASI_HK_CRM_PromotionCalendarYearCON();
        PageReference initRedirectPage = testController.initPage();
        System.assertEquals(null, initRedirectPage);
        
        // Validate display promotions
      System.assertEquals(sbList.size() + (pmtList.size() > 1 ? 1 : 0), testController.eventGroups.size());
      System.assertEquals(pmtList.size() + sbList.size() - 1, testController.eventList.size());
      
      // Redirect to month view calendar
      testController.selectedCalendarType = ASI_HK_CRM_PromotionCalendarCommonClass.CALENDAR_TYPE_MONTH;
      PageReference anotherCalendarPage = testController.redirectToAnotherCalendarType();
      System.assertEquals(Page.ASI_HK_CRM_PromotionCalendarMonthPage.getUrl(), anotherCalendarPage.getUrl());
        
        Test.stopTest();
    }

    
}