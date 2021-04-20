@isTest
private class EUR_CRM_CompetitorPromoActiveHandlerTest {
	
	static testMethod void myUnitTest() {

        Test.startTest();
        Id recordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Competitor_Promo_Tracking__c','EUR_MA_On_Trade_CPT');


        // EndDate = NULL; StartDate<=TODAY
        EUR_CRM_Competitor_Promo_Tracking__c tempCompPromo = new EUR_CRM_Competitor_Promo_Tracking__c();
        tempCompPromo.RecordTypeId = recordTypeId;
     	tempCompPromo.EUR_CRM_Start_Date__c = Date.Today();
        insert tempCompPromo;
	
        EUR_CRM_Competitor_Promo_Tracking__c compPromo = [SELECT Id, EUR_CRM_Active__c, EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c 
        												  FROM EUR_CRM_Competitor_Promo_Tracking__c 
        												  Where Id =:tempCompPromo.Id
        												  ];

        system.assertEquals(compPromo.EUR_CRM_End_Date__c, NULL);
        system.assertEquals(compPromo.EUR_CRM_Active__c, TRUE);


        // EndDate = NULL; StartDate > TODAY
		compPromo.EUR_CRM_Start_Date__c = Date.Today().addDays(1);
		update compPromo;
		
		compPromo = [SELECT Id, EUR_CRM_Active__c, EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c 
        												  FROM EUR_CRM_Competitor_Promo_Tracking__c 
        												  Where Id =:tempCompPromo.Id
        												  ];
        												  
        system.assertEquals(compPromo.EUR_CRM_Active__c, FALSE);


        // EndDate => TODAY; StartDate = NULL
		compPromo.EUR_CRM_Start_Date__c = NULL;
		compPromo.EUR_CRM_End_Date__c = Date.Today();
		update compPromo;
		
		compPromo = [SELECT Id, EUR_CRM_Active__c, EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c 
        												  FROM EUR_CRM_Competitor_Promo_Tracking__c 
        												  Where Id =:tempCompPromo.Id
        												  ];
        												  
        system.assertEquals(compPromo.EUR_CRM_Active__c, TRUE);

        // EndDate < TODAY; StartDate = NULL
		compPromo.EUR_CRM_Start_Date__c = NULL;
		compPromo.EUR_CRM_End_Date__c = Date.Today().addDays(-1);
		update compPromo;
		
		compPromo = [SELECT Id, EUR_CRM_Active__c, EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c 
        												  FROM EUR_CRM_Competitor_Promo_Tracking__c 
        												  Where Id =:tempCompPromo.Id
        												  ];
        												  
        system.assertEquals(compPromo.EUR_CRM_Active__c, FALSE);



        // EndDate => TODAY; StartDate<=TODAY
		compPromo.EUR_CRM_Start_Date__c = Date.Today();
		compPromo.EUR_CRM_End_Date__c = Date.Today();
		update compPromo;
		
		compPromo = [SELECT Id, EUR_CRM_Active__c, EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c 
        												  FROM EUR_CRM_Competitor_Promo_Tracking__c 
        												  Where Id =:tempCompPromo.Id
        												  ];
        												  
        system.assertEquals(compPromo.EUR_CRM_Active__c, TRUE);
        

        // EndDate < Today; StartDate < TODAY
		compPromo.EUR_CRM_Start_Date__c = Date.Today().addDays(-1);
		compPromo.EUR_CRM_End_Date__c = Date.Today().addDays(-1);
		update compPromo;
		
		compPromo = [SELECT Id, EUR_CRM_Active__c, EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c 
        												  FROM EUR_CRM_Competitor_Promo_Tracking__c 
        												  Where Id =:tempCompPromo.Id
        												  ];
        												  
        system.assertEquals(compPromo.EUR_CRM_Active__c, FALSE);
        

        // EndDate > Today; StartDate > TODAY
		compPromo.EUR_CRM_Start_Date__c = Date.Today().addDays(1);
		compPromo.EUR_CRM_End_Date__c = Date.Today().addDays(1);
		update compPromo;
		
		compPromo = [SELECT Id, EUR_CRM_Active__c, EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c 
        												  FROM EUR_CRM_Competitor_Promo_Tracking__c 
        												  Where Id =:tempCompPromo.Id
        												  ];
        												  
        system.assertEquals(compPromo.EUR_CRM_Active__c, FALSE);
		
        Test.stopTest();
    }
}