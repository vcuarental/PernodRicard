@isTest
private class ASI_CRM_RedirectChannelStrategy_Test {
    
    static testMethod void ASI_CRM_ChannelStrategy_Test() {
        //---- covered classes: ----
        //---- 1. ASI_CRM_RedirectChannelStrategyNew_Ctr ----
        //---- 2. ASI_CRM_RedirectChannelStrategyView_Ctr ----
        //---- 3. ASI_CRM_RedirectChannelStrategyEdit_Ctr ----
        
        list<ASI_CRM_CN_Channel_Strategy__c> list_cs = new list<ASI_CRM_CN_Channel_Strategy__c>();
		ASI_CRM_CN_Channel_Strategy__c cs1 = new ASI_CRM_CN_Channel_Strategy__c(
			recordtypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Strategy__cASI_CRM_CN_National')
		);
		ASI_CRM_CN_Channel_Strategy__c cs2 = new ASI_CRM_CN_Channel_Strategy__c(
			recordtypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Strategy__cASI_NPL_CN_Channel_Strategy')
		);
		list_cs.add(cs1);
		list_cs.add(cs2);
		insert list_cs;
        
        test.startTest();
        
        ApexPages.StandardController stdController1 = new ApexPages.StandardController(cs1);
        ApexPages.StandardController stdController2 = new ApexPages.StandardController(cs2);
		
        ASI_CRM_RedirectChannelStrategyView_Ctr controllerView = new ASI_CRM_RedirectChannelStrategyView_Ctr(stdController1);		
        ASI_CRM_RedirectChannelStrategyView_Ctr controllerView2 = new ASI_CRM_RedirectChannelStrategyView_Ctr(stdController2);
        controllerView.redirect();
        controllerView2.redirect();

        ASI_CRM_RedirectChannelStrategyEdit_Ctr controllerEdit = new ASI_CRM_RedirectChannelStrategyEdit_Ctr(stdController1);        
        ASI_CRM_RedirectChannelStrategyEdit_Ctr controllerEdit2 = new ASI_CRM_RedirectChannelStrategyEdit_Ctr(stdController2);
        controllerEdit.redirect();
        controllerEdit2.redirect(); 
        
        /*
        ASI_CRM_RedirectChannelStrategyNew_Ctr controllerNew = new ASI_CRM_RedirectChannelStrategyNew_Ctr(stdController1);        
        ASI_CRM_RedirectChannelStrategyNew_Ctr controllerNew2 = new ASI_CRM_RedirectChannelStrategyNew_Ctr(stdController2);
        controllerNew.redirect();
        controllerNew2.redirect();
		*/		
        
        test.stopTest();       
    }

}