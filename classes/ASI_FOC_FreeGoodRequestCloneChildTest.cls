@isTest
private class ASI_FOC_FreeGoodRequestCloneChildTest {

    static testMethod void test_main() {
        final Integer numOfSKU = 5;
        final Integer numOfFGReqDetail = 3;

        User user1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',BypassVR__c = true, BypassWF__c  = true, BypassTriggers__c  = 'Autofollow_User_InsertUpdate; AutoJoin_User_InsertUpdate; ChatterEmailSettings; ESNProjectTrigger; AP01; ASI_HK_CRM_SalesOrderAssignApprover; ASI_MFM_ValidateSubBrandCode; ASI_MFM_GF_LockPOLine; ASI_CRM_CN_AccountsCRMCodeAutoNumber; ASI_CRM_TW_AccountMovement_TgrHdlr; ASI_CRM_CN_AccountsAdditional_TriggerCls; ASI_CRM_CN_ContractPONoAutoNumber; ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr; ASI_CRM_CN_Contract_TriggerClass; ASI_MFM_TR_ByPassTrigger; ASI_MFM_KR_Cross_Fiscal_Year_Checking; Autofollow_User_InsertUpdate,AutoJoin_Us', ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        user1.ASI_CRM_Sales_Team__c = 'HQ-Others';
        insert user1;
         System.runAs(user1){
        
        ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
        ASI_FOC_FreeGoodRequestGenerator fgReqGen = new ASI_FOC_FreeGoodRequestGenerator();
        ASI_FOC_FreeGoodRequestDetailGenerator fgReqDetailGen = new ASI_FOC_FreeGoodRequestDetailGenerator();
        
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_FOC_Free_Goods_Request__c cloneFromFGReq;
        ASI_FOC_Free_Goods_Request__c cloneToFGReq;
        List<ASI_FOC_Request_Item__c> fgReqDetailList = new List<ASI_FOC_Request_Item__c>();

      
        ASI_CRM_Region__c hqRegion = new ASI_CRM_Region__c(Name = 'Headquarter');
        insert hqRegion;
        ASI_CRM_Division__c hqDiv = new ASI_CRM_Division__c(Name = 'HQ(Div)');
        hqDiv.ASI_CRM_Region__c = hqRegion.Id;
        insert hqDiv;
        ASI_CRM_Sales_Team__c steam = new ASI_CRM_Sales_Team__c();
        steam.Name = 'HQ-Others';
        steam.ASI_CRM_Division__c = hqDiv.Id;
        insert steam;
        
        for (Integer i = 0; i < numOfSKU; i++) {
            skuList.add(skuGen.generateSKU(null));
        }
        insert skuList;

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
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;

        ASI_CRM_AccountsAdditionalField__c qu = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium',
        ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), 
        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), 
        ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1);
        insert qu;
        
        cloneFromFGReq = fgReqGen.generateTradeFreeGoodRequest();
        String recordTypeID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        ASI_TH_CRM_Contract__c contr = new ASI_TH_CRM_Contract__c(Name='Contract1', recordTypeId=recordTypeID,ASI_CRM_CN_Status__c = 'Final' );
        insert contr;
        cloneFromFGReq.ASI_CRM_CN_FG_Trade_A_P_PO__c = contr.Id;
        cloneFromFGReq.ASI_CRM_CN_FG_Not_Applicable_ForCustomer__c = false;
        cloneFromFGReq.ASI_CRM_Outlet__c = qu.Id;
        insert cloneFromFGReq;
        
        for (Integer i = 0; i < numOfFGReqDetail; i++) {
            fgReqDetailList.add(fgReqDetailGen.generateFreeGoodRequestDetail(cloneFromFGReq, skuList[i]));
        }
        insert fgReqDetailList;
        
        cloneToFGReq = fgReqGen.generateTradeFreeGoodRequest();
         cloneToFGReq.ASI_CRM_CN_FG_Trade_A_P_PO__c = contr.Id;
        cloneToFGReq.ASI_CRM_CN_FG_Not_Applicable_ForCustomer__c = false;
        cloneToFGReq.ASI_CRM_Outlet__c = qu.Id;
        cloneToFGReq.ASI_CRM_CN_Region__c = 'Central';
        insert cloneToFGReq;
        
        Test.startTest();
        
        PageReference testPage = Page.ASI_FOC_FreeGoodRequestCloneChildPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put(ASI_FOC_FreeGoodRequestCloneChildCON.URL_PARAM_NEW_ID, cloneToFGReq.Id);
        Test.setCurrentPageReference(testPage);
        ASI_FOC_FreeGoodRequestCloneChildCON testController = new ASI_FOC_FreeGoodRequestCloneChildCON();
        PageReference initRedirectPage = testController.initPage();
        PageReference linkRedirectPage = testController.redirectToAnotherPage();
        String linkDisplayStr = testController.anotherPageLabel;
        
        System.assertEquals(null, initRedirectPage);
        System.assertEquals(Page.ASI_FOC_FreeGoodRequestDetailEditPage.getUrl(), linkRedirectPage.getUrl().substringBefore('?'));
        System.assertEquals(ASI_FOC_FreeGoodRequestCloneChildCON.FAIL_LINK_LABEL_Continue, linkDisplayStr);
        
        
        pageParams.put(ASI_FOC_FreeGoodRequestCloneChildCON.URL_PARAM_FROM_ID, cloneFromFGReq.Id);
        testController = new ASI_FOC_FreeGoodRequestCloneChildCON();
        initRedirectPage = testController.initPage();
        testController.showPageWarning('Hello my friend');
        //System.assertEquals(Page.ASI_FOC_FreeGoodRequestDetailEditPage.getUrl(), initRedirectPage.getUrl().substringBefore('?'));
        List<ASI_FOC_Request_Item__c> testReqItemList = [SELECT Id FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c = :cloneToFGReq.Id];
        //System.assertEquals(numOfFGReqDetail, testReqItemList.size());
        
        Test.stopTest();
    }
    }
}