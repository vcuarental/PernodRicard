@isTest
private class ASI_CRM_CN_AccountAdditional_Test {

    static testMethod void ASI_CRM_CN_Acc2CallSummaryUpdate_TEST() {

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
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Prestige', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS') ,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Prestige', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS') ,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert a2s;
        
        insert new Event(StartDateTime=system.today().addDays(1), WhatId = a2s[1].Id, DurationInMinutes=1, RecordTypeId=Global_RecordTypeCache.getRtId('EventASI_CRM_CN_Call_Plan'));
        
        test.startTest();
        
        ASI_CRM_CN_Acc2CallSummaryUpdate u = new ASI_CRM_CN_Acc2CallSummaryUpdate();
        u.execute(null);
        u.start(null);
        u.execute(null, a2s);
        u.finish(null);
        
        test.stopTest();
    } 
       
    static testMethod void ASI_CRM_CN_Acc2VisitSuggestionUpdate_TEST() {
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST');
        insert city;
        
        List<ASI_CRM_CN_Channel__c> channel = new List<ASI_CRM_CN_Channel__c>();
        channel.add(new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON'));
        channel.add(new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='OFF'));
        insert channel;
        
        List<ASI_MFM_Sub_Channel__c> subChannel = new List<ASI_MFM_Sub_Channel__c>();
        subChannel.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel[0].Id));
        subChannel.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel[1].Id));
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Prestige', RecordTypeId=rtWS, ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel[0].Id,ASI_CRM_CN_WS_Tier__c='T1'));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', RecordTypeId=rtOutlet, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel[1].Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', RecordTypeId=rtOutlet, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_NewChannel__c=newChannel.Id,ASI_CRM_CN_New_Image__c='Iconic'));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'd', ASI_CRM_CN_Chi_Name__c = 'd', ASI_CRM_CN_Commercial_Team__c = 'Premium', RecordTypeId=rtOutlet, ASI_CRM_CN_CCity__c=city.Id));
        insert a2s;
        
        ASI_CRM_Call_Log_Suggestion_Setting__c clss = new ASI_CRM_Call_Log_Suggestion_Setting__c(ASI_CRM_Suggested_No_of_Visit__c=1,ASI_CRM_SuggestedNoofVisitCompetitor__c=1,ASI_CRM_Type__c='WS',ASI_CRM_WS_Tier__c='T1');
        insert clss;
        ASI_CRM_Call_Log_Suggestion_Setting__c clss2 = new ASI_CRM_Call_Log_Suggestion_Setting__c(ASI_CRM_Suggested_No_of_Visit__c=1,ASI_CRM_SuggestedNoofVisitCompetitor__c=1,ASI_CRM_WS_Tier__c='Outlet',ASI_CRM_New_Channel__c=newChannel.Id,ASI_CRM_Image__c='Iconic');
        insert clss2;
        
        test.startTest();
        
        ASI_CRM_CN_Acc2VisitSuggestionUpdate u = new ASI_CRM_CN_Acc2VisitSuggestionUpdate();
        u.execute(null);
        u.start(null);
        u.execute(null, a2s);
        u.finish(null);
        
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_AccountGradeGeneration_Schd_AND_Batch_TEST() {
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='testChannel',ASI_CRM_CN_On_Off__c='On');
        insert channel;
        
        ASI_CRM_CN_Channel__c channel2 = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='testChannel',ASI_CRM_CN_On_Off__c='On',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'));
        insert channel2;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(Name='testSubChannel',ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName='ASI_CRM_CN_WS'];
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY');
        insert city;
        
        ASI_CRM_AccountsAdditionalField__c accountAdditional = new ASI_CRM_AccountsAdditionalField__c(Name='testAccountAdditional',ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_CR12_Btl_per_month__c=1200, RecordTypeId=recordType.Id, ASI_CRM_CN_CCity__c=city.Id);
        insert accountAdditional;
        
        ASI_CRM_AccountsAdditionalField__c accountAdditional2 = new ASI_CRM_AccountsAdditionalField__c(Name='testAccountAdditional',ASI_CRM_CN_NewChannel__c=channel2.id,ASI_CRM_CN_CR12_Btl_per_month__c=1200, RecordTypeId=recordType.Id, ASI_CRM_CN_CCity__c=city.Id);
        insert accountAdditional2;
        
        RecordType recordTypeAGS = [SELECT Id FROM RecordType WHERE DeveloperName='ASI_CRM_CN_AccountGradingSetting_RcrdTyp'];
        
        ASI_CRM_CN_AccountGradingSetting__c accountGradingSetting = new ASI_CRM_CN_AccountGradingSetting__c(ASI_CRM_CN_Grade__c='A',ASI_CRM_CN_OnOff__c='On',ASI_CRM_CN_QtyFrom__c=1000,ASI_CRM_CN_QtyTo__c=3000,RecordTypeId=recordTypeAGS.Id);      
        insert accountGradingSetting;    
        
        Test.StartTest();
        
        string CORN_EXP = '0 0 0 1 4 ?';
        
        system.schedule('Account Grade Generation Schedule job', CORN_EXP, new ASI_CRM_CN_AccountGradeGeneration_Schd());
        
        Test.StopTest();
    }

    static testMethod void ASI_CRM_CN_AccountAdlRltListCtrl_TEST() {
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='KTV',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Prestige', RecordTypeId=rtWS, ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', RecordTypeId=rtOutlet, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Room_Price__c =1,ASI_CRM_CN_Service_Tips_Price__c=1));
        insert a2s;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c ();
        insert subBrand;
        
        list<ASI_CRM_Subbrand_Volume__c> svols = new list<ASI_CRM_Subbrand_Volume__c>();
        for(integer i=1; i<5; i++) {
            svols.add(new ASI_CRM_Subbrand_Volume__c(
                ASI_CRM_Account__c = a2s[0].Id,
                ASI_CRM_Subbrand__c = subBrand.Id,
                ASI_CRM_End_Date__c = system.today().addMonths(-i)));
            svols.add(new ASI_CRM_Subbrand_Volume__c(
                ASI_CRM_Account__c = a2s[1].Id,
                ASI_CRM_Subbrand__c = subBrand.Id,
                ASI_CRM_End_Date__c = system.today().addMonths(-i)));
            svols.add(new ASI_CRM_Subbrand_Volume__c(
                ASI_CRM_Account__c = a2s[1].Id,
                ASI_CRM_Subbrand__c = subBrand.Id,
                ASI_CRM_End_Date__c = system.today().addMonths(-i)));
        }
        insert svols;
                       
        ApexPages.StandardController scon0 = new ApexPages.StandardController(a2s[0]);
        ApexPages.StandardController scon1 = new ApexPages.StandardController(a2s[1]);
        
        test.startTest();
        
        {  // VolumeSummary
            ASI_CRM_CN_AccountAdlRltListCtrl.VolumeSummary vs = new ASI_CRM_CN_AccountAdlRltListCtrl.VolumeSummary();
            vs.subBrand = vs.subBrand;
            vs.lastMonthAmount = vs.lastMonthAmount;
            vs.last2ndMonthAmount = vs.last2ndMonthAmount;
            vs.last3thMonthAmount = vs.last3thMonthAmount;
        }
        
        { // Wholesaler
            ASI_CRM_CN_AccountAdlRltListCtrl con = new ASI_CRM_CN_AccountAdlRltListCtrl(scon0);
            con.isOutlet = con.isOutlet;
            con.isWholesaler = con.isWholesaler;
            con.intakesMap = con.intakesMap;
            con.depletionsMap = con.depletionsMap;
            con.inventoriesMap = con.inventoriesMap;
            con.top10IntakesMap = con.top10IntakesMap;
            con.top10DepletionsMap = con.top10DepletionsMap;
            con.top10CapCollectionsMap = con.top10CapCollectionsMap;
        }
        
        { // outlet
            ASI_CRM_CN_AccountAdlRltListCtrl con = new ASI_CRM_CN_AccountAdlRltListCtrl(scon1);
        }
        
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_AccountsAdditionalFieldCtrl_TEST() {
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Nightclub',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Prestige', Name='TEST1', RecordTypeId=rtWS ,ASI_CRM_CN_NewChannel__c = newChannel.Id ,ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', Name='TEST2', RecordTypeId=rtOutlet, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Energy__c = 'High Energy', ASI_CRM_CN_Size_sqm__c='<50',ASI_CRM_CN_Sofa_Table_Price__c=1));
        insert a2s[0];
        insert a2s[1];
        
        list<Id> aid = new list<Id>();
        for(ASI_CRM_AccountsAdditionalField__c aa :[SELECT ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id]) {
            aid.add(aa.ASI_CRM_Account__c);
        }
        
        list<Account> accs = [SELECT Id, RecordTypeId FROM Account WHERE Id IN :aid];
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(Account a :accs) {
            scons.add(new ApexPages.StandardController(a));
        }
        
        test.startTest();
        
        for(ApexPages.StandardController scon :scons) {
            ASI_CRM_CN_AccountsAdditionalFieldCtrl con = new ASI_CRM_CN_AccountsAdditionalFieldCtrl(scon);
            con.save();
        }
        
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_AccountsAdditional_TriggerCls_TEST() {
        
        map<string, RecordType> mapRtA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('Account'))
            mapRtA.put(rt.developerName, rt);
        
        map<string, RecordType> mapRtAA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('ASI_CRM_AccountsAdditionalField__c'))
            mapRtAA.put(rt.developerName, rt);
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY');
        ASI_CRM_City__c city2 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY2');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='testChannel',ASI_CRM_CN_On_Off__c='On');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(Name='testSubChannel',ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Hotel',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='ON');
        insert newChannel;
        ASI_CRM_CN_PROS_Segmentation__c prosSeg = new ASI_CRM_CN_PROS_Segmentation__c(Name = 'Test',
                                                                                      RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PROS_Segmentation__cASI_CRM_CN_Segmentation'));
        insert prosSeg;
        ASI_CRM_PROS_Segmentation_Mapping__c prosSegMap = new ASI_CRM_PROS_Segmentation_Mapping__c(ASI_CRM_New_Channel__c=newChannel.Id,ASI_CRM_PROS_Segmentation__c=prosSeg.Id,ASI_CRM_Energy__c='High Energy',
                                                                                                   RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_PROS_Segmentation_Mapping__cASI_CRM_CN_PROS_SegmentationMap'));
        insert prosSegMap;
        
        ASI_CRM_CN_Brand_T1_Group__c g = new ASI_CRM_CN_Brand_T1_Group__c(Name='TEST');
        insert g;
        
        list<Account> listA = new list<Account>();
        listA.add(new Account(Name='TEST1', RecordTypeId=mapRtA.get('ASI_CRM_CN_Wholesales_CN').Id));
        listA.add(new Account(Name='TEST2', RecordTypeId=mapRtA.get('ASI_MFM_CN_Outlet').Id));
        insert listA;

        list<ASI_CRM_AccountsAdditionalField__c> listAA = new list<ASI_CRM_AccountsAdditionalField__c>();
        listAA.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Prestige', Name='TEST1', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS') ,ASI_CRM_CN_NewChannel__c = newChannel.Id ,ASI_CRM_Account__c=listA[0].Id, 
                                                          ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name));
        listAA.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', Name='TEST2', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_Account__c=listA[1].Id, 
                                                          ASI_CRM_CN_Chi_Name__c = 'Test Chi', ASI_CRM_CN_Eng_Name__c = 'Test Eng', ASI_CRM_CN_Legal_Name__c = 'Test Legal',
                                                          ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name, ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Energy__c = 'High Energy',
                                                          ASI_CRM_SG_Outlet_Capacity__c='a',ASI_CRM_CN_IS_Volume__c='a',ASI_CRM_CN_Occupancy_Rate__c='a',ASI_CRM_CN_Size_sqm__c='a',ASI_CRM_CN_PRC_Volume__c=1));
        
        
        insert listAA;
        listAA[1].ASI_CRM_CN_Chi_Name__c = 'Test Chi2';
        listAA[1].ASI_CRM_CN_Eng_Name__c = 'Test Eng2';
        listAA[1].ASI_CRM_CN_Legal_Name__c = 'Test Legal2';
        // update listAA;

        ASI_CRM_AccountsAdditionalField__c childAA =  new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', Name='TEST3', RecordTypeId=mapRtAA.get('ASI_CRM_Outlet_CN').Id, ASI_CRM_Account__c=listA[1].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name, ASI_CRM_CN_Parent_Outlet__c=listAA[0].id, ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Energy__c = 'High Energy',
                                                                                             ASI_CRM_SG_Outlet_Capacity__c='a',ASI_CRM_CN_IS_Volume__c='a',ASI_CRM_CN_Occupancy_Rate__c='a',ASI_CRM_CN_Size_sqm__c='a',ASI_CRM_CN_PRC_Volume__c=1);
        insert childAA;
        
        childAA.ASI_CRM_CN_Parent_Outlet__c = listAA[1].id;
        // update childAA;
        
        Set<id> pid = new Set<id>();
        pid.add(listAA[1].id);
        
        // ASI_CRM_CN_AccountsAdditional_HelperCls.getParentOutlet(pid);
        
        map<Id, ASI_CRM_AccountsAdditionalField__c> oldMap = new map<Id, ASI_CRM_AccountsAdditionalField__c>();
        
        /*listAA = new list<ASI_CRM_AccountsAdditionalField__c>([SELECT ASI_CRM_CN_Commercial_Team__c, Name, RecordTypeId , ASI_CRM_Account__c , 
                                                               ASI_CRM_CN_Chi_Name__c , ASI_CRM_CN_Eng_Name__c , ASI_CRM_CN_Legal_Name__c ,
                                                               ASI_CRM_CN_CCity__c , ASI_CRM_CN_Sub_Channel__c , ASI_CRM_CN_Brand__c, ASI_CRM_CN_NewChannel__c , ASI_CRM_CN_Energy__c ,
                                                               ASI_CRM_SG_Outlet_Capacity__c ,ASI_CRM_CN_IS_Volume__c ,ASI_CRM_CN_Occupancy_Rate__c ,ASI_CRM_CN_Size_sqm__c ,ASI_CRM_CN_PRC_Volume__c
                                                               , ASI_CRM_CN_Parent_Outlet__c, ASI_CRM_National_Group_Picklist__c, OwnerId
                                                               FROM ASI_CRM_AccountsAdditionalField__c where id = : listAA[0].id or id = : listAA[1].id
                                                              ]);*/
        
        for(ASI_CRM_AccountsAdditionalField__c aa :listAA)
            oldMap.put(aa.Id, aa);
        
        list<ASI_CRM_AccountsAdditionalField__c> childList = new List<ASI_CRM_AccountsAdditionalField__c>();
        childList.add(childAA);
        
        // ASI_CRM_CN_AccountsAdditional_HelperCls.SetCustomGroupFlag(childList, null);
        
        Set<id> accId = new Set<id>();
        accId.add(listA[0].id);
        accId.add(listA[1].id);
        
        // ASI_CRM_CN_AccountsAdditional_HelperCls.GetT1WSID(accId);
        test.startTest();
        
        ASI_CRM_CN_AccountsAdditional_TriggerCls.className = 'None';//21061104 Elufa
        //ASI_CRM_CN_AccountsAdditional_TriggerCls.routineBeforeUpdate(listAA, oldMap);
        //ASI_CRM_CN_AccountsAdditional_TriggerCls.routineBeforeInsert(listAA, oldMap);
        // ASI_CRM_CN_AccountsAdditional_TriggerCls.routineBeforeDelete(listAA, oldMap);
        // ASI_CRM_CN_AccountsAdditional_TriggerCls.routineAfterInsert(listAA, oldMap);
        // ASI_CRM_CN_AccountsAdditional_TriggerCls.routineAfterUpdate(listAA, oldMap);
        // ASI_CRM_CN_AccountsAdditional_TriggerCls.routineAfterDelete(listAA, oldMap);
        // ASI_CRM_CN_AccountsAdditional_TriggerCls.SetCustomGroupFlag(listAA, oldMap);
        
        listAA[1].ASI_CRM_CN_Energy__c = '';
        listAA[1].ASI_CRM_CN_Size_sqm__c = '';
        listAA[1].ASI_CRM_CN_IS_Volume__c = '';
        ASI_CRM_CN_AccountsAdditional_TriggerCls.prosSegmentationMapping(listAA, oldMap);
        
        newChannel.name = 'KTV';
        Update newChannel;
        
        ASI_CRM_CN_AccountsAdditional_TriggerCls.prosSegmentationMapping(listAA, oldMap);
        
        newChannel.name = 'Restaurant';
        Update newChannel;
        
        ASI_CRM_CN_AccountsAdditional_TriggerCls.prosSegmentationMapping(listAA, oldMap);
        
        newChannel.name = 'Hotel';
        listAA[1].ASI_CRM_CN_Brand2__c = Null;
        listAA[1].ASI_CRM_CN_Outlet_Channel_type__c = Null;
        Update newChannel;
        
        ASI_CRM_CN_AccountsAdditional_TriggerCls.prosSegmentationMapping(listAA, oldMap);
        
        
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_AccountsAdditional_TriggerCls_TEST1() {
        
        map<string, RecordType> mapRtA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('Account'))
            mapRtA.put(rt.developerName, rt);
        
        map<string, RecordType> mapRtAA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('ASI_CRM_AccountsAdditionalField__c'))
            mapRtAA.put(rt.developerName, rt);
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY');
        ASI_CRM_City__c city2 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY2');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='testChannel',ASI_CRM_CN_On_Off__c='On');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(Name='testSubChannel',ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Hotel',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='ON');
        insert newChannel;
        ASI_CRM_CN_PROS_Segmentation__c prosSeg = new ASI_CRM_CN_PROS_Segmentation__c(Name = 'Test',
                                                                                      RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PROS_Segmentation__cASI_CRM_CN_Segmentation'));
        insert prosSeg;
        ASI_CRM_PROS_Segmentation_Mapping__c prosSegMap = new ASI_CRM_PROS_Segmentation_Mapping__c(ASI_CRM_New_Channel__c=newChannel.Id,ASI_CRM_PROS_Segmentation__c=prosSeg.Id,ASI_CRM_Energy__c='High Energy',
                                                                                                   RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_PROS_Segmentation_Mapping__cASI_CRM_CN_PROS_SegmentationMap'));
        insert prosSegMap;
        
        ASI_CRM_CN_Brand_T1_Group__c g = new ASI_CRM_CN_Brand_T1_Group__c(Name='TEST');
        insert g;
        
        list<Account> listA = new list<Account>();
        listA.add(new Account(Name='TEST1', RecordTypeId=mapRtA.get('ASI_CRM_CN_Wholesales_CN').Id));
        listA.add(new Account(Name='TEST2', RecordTypeId=mapRtA.get('ASI_MFM_CN_Outlet').Id));
        insert listA;

        list<ASI_CRM_AccountsAdditionalField__c> listAA = new list<ASI_CRM_AccountsAdditionalField__c>();
        listAA.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Prestige', Name='TEST1', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS') ,ASI_CRM_CN_NewChannel__c = newChannel.Id ,ASI_CRM_Account__c=listA[0].Id, 
                                                          ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name));
        listAA.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', Name='TEST2', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_Account__c=listA[1].Id, 
                                                          ASI_CRM_CN_Chi_Name__c = 'Test Chi', ASI_CRM_CN_Eng_Name__c = 'Test Eng', ASI_CRM_CN_Legal_Name__c = 'Test Legal',
                                                          ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name, ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Energy__c = 'High Energy',
                                                          ASI_CRM_SG_Outlet_Capacity__c='a',ASI_CRM_CN_IS_Volume__c='a',ASI_CRM_CN_Occupancy_Rate__c='a',ASI_CRM_CN_Size_sqm__c='a',ASI_CRM_CN_PRC_Volume__c=1));
        
        
        insert listAA;
        // listAA[1].ASI_CRM_CN_Chi_Name__c = 'Test Chi2';
        // listAA[1].ASI_CRM_CN_Eng_Name__c = 'Test Eng2';
        // listAA[1].ASI_CRM_CN_Legal_Name__c = 'Test Legal2';
        // update listAA;

        ASI_CRM_AccountsAdditionalField__c childAA =  new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', Name='TEST3', RecordTypeId=mapRtAA.get('ASI_CRM_Outlet_CN').Id, ASI_CRM_Account__c=listA[1].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name, ASI_CRM_CN_Parent_Outlet__c=listAA[0].id, ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Energy__c = 'High Energy',
                                                                                             ASI_CRM_SG_Outlet_Capacity__c='a',ASI_CRM_CN_IS_Volume__c='a',ASI_CRM_CN_Occupancy_Rate__c='a',ASI_CRM_CN_Size_sqm__c='a',ASI_CRM_CN_PRC_Volume__c=1);
        insert childAA;
        
        // childAA.ASI_CRM_CN_Parent_Outlet__c = listAA[1].id;
        // update childAA;
        
        Set<id> pid = new Set<id>();
        pid.add(listAA[1].id);
        
        
        map<Id, ASI_CRM_AccountsAdditionalField__c> oldMap = new map<Id, ASI_CRM_AccountsAdditionalField__c>();
        
        /*listAA = new list<ASI_CRM_AccountsAdditionalField__c>([SELECT ASI_CRM_CN_Commercial_Team__c, Name, RecordTypeId , ASI_CRM_Account__c , 
                                                               ASI_CRM_CN_Chi_Name__c , ASI_CRM_CN_Eng_Name__c , ASI_CRM_CN_Legal_Name__c ,
                                                               ASI_CRM_CN_CCity__c , ASI_CRM_CN_Sub_Channel__c , ASI_CRM_CN_Brand__c, ASI_CRM_CN_NewChannel__c , ASI_CRM_CN_Energy__c ,
                                                               ASI_CRM_SG_Outlet_Capacity__c ,ASI_CRM_CN_IS_Volume__c ,ASI_CRM_CN_Occupancy_Rate__c ,ASI_CRM_CN_Size_sqm__c ,ASI_CRM_CN_PRC_Volume__c
                                                               , ASI_CRM_CN_Parent_Outlet__c, ASI_CRM_National_Group_Picklist__c, OwnerId
                                                               FROM ASI_CRM_AccountsAdditionalField__c where id = : listAA[0].id or id = : listAA[1].id
                                                              ]);*/
        
        for(ASI_CRM_AccountsAdditionalField__c aa :listAA)
            oldMap.put(aa.Id, aa);
        
        list<ASI_CRM_AccountsAdditionalField__c> childList = new List<ASI_CRM_AccountsAdditionalField__c>();
        childList.add(childAA);
        
        
        Set<id> accId = new Set<id>();
        accId.add(listA[0].id);
        accId.add(listA[1].id);
        
        test.startTest();
        
        ASI_CRM_CN_AccountsAdditional_TriggerCls.className = 'None';//21061104 Elufa
        //ASI_CRM_CN_AccountsAdditional_TriggerCls.routineBeforeUpdate(listAA, oldMap);
        //ASI_CRM_CN_AccountsAdditional_TriggerCls.routineBeforeInsert(listAA, oldMap);
        ASI_CRM_CN_AccountsAdditional_TriggerCls.routineBeforeDelete(listAA, oldMap);
        ASI_CRM_CN_AccountsAdditional_TriggerCls.routineAfterInsert(listAA, oldMap);
        ASI_CRM_CN_AccountsAdditional_TriggerCls.routineAfterUpdate(listAA, oldMap);
        ASI_CRM_CN_AccountsAdditional_TriggerCls.routineAfterDelete(listAA, oldMap);
        ASI_CRM_CN_AccountsAdditional_TriggerCls.SetCustomGroupFlag(listAA, oldMap);
        
        // listAA[1].ASI_CRM_CN_Energy__c = '';
        // listAA[1].ASI_CRM_CN_Size_sqm__c = '';
        // listAA[1].ASI_CRM_CN_IS_Volume__c = '';
        // ASI_CRM_CN_AccountsAdditional_TriggerCls.prosSegmentationMapping(listAA, oldMap);
        
        // newChannel.name = 'KTV';
        // Update newChannel;
        
        // ASI_CRM_CN_AccountsAdditional_TriggerCls.prosSegmentationMapping(listAA, oldMap);
        
        // newChannel.name = 'Restaurant';
        // Update newChannel;
        
        // ASI_CRM_CN_AccountsAdditional_TriggerCls.prosSegmentationMapping(listAA, oldMap);
        
        // newChannel.name = 'Hotel';
        // listAA[1].ASI_CRM_CN_Brand2__c = Null;
        // listAA[1].ASI_CRM_CN_Outlet_Channel_type__c = Null;
        // Update newChannel;
        
        // ASI_CRM_CN_AccountsAdditional_TriggerCls.prosSegmentationMapping(listAA, oldMap);
        
        // ASI_CRM_AccountsAdditionalField__c a = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', Name='TEST2', RecordTypeId=mapRtAA.get('ASI_CRM_Outlet_CN').Id, ASI_CRM_Account__c=listA[1].Id, 
        //                                                                               ASI_CRM_CN_Chi_Name__c = 'Test Chi', ASI_CRM_CN_Eng_Name__c = 'Test Eng', ASI_CRM_CN_Legal_Name__c = 'Test Legal',
        //                                                                               ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name, ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Energy__c = 'High Energy',
        //                                                                               ASI_CRM_SG_Outlet_Capacity__c='a',ASI_CRM_CN_IS_Volume__c='a',ASI_CRM_CN_Occupancy_Rate__c='a',ASI_CRM_CN_Size_sqm__c='a',ASI_CRM_CN_PRC_Volume__c=1);
        
        // insert a;
        
        
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_AccountsAdditional_HelperCls_TEST() {
        
        map<string, RecordType> mapRtA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('Account'))
            mapRtA.put(rt.developerName, rt);
        
        map<string, RecordType> mapRtAA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('ASI_CRM_AccountsAdditionalField__c'))
            mapRtAA.put(rt.developerName, rt);
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY');
        ASI_CRM_City__c city2 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY2');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='testChannel',ASI_CRM_CN_On_Off__c='On');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(Name='testSubChannel',ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Hotel',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='ON');
        insert newChannel;
        ASI_CRM_CN_PROS_Segmentation__c prosSeg = new ASI_CRM_CN_PROS_Segmentation__c(Name = 'Test',
                                                                                      RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_PROS_Segmentation__cASI_CRM_CN_Segmentation'));
        insert prosSeg;
        ASI_CRM_PROS_Segmentation_Mapping__c prosSegMap = new ASI_CRM_PROS_Segmentation_Mapping__c(ASI_CRM_New_Channel__c=newChannel.Id,ASI_CRM_PROS_Segmentation__c=prosSeg.Id,ASI_CRM_Energy__c='High Energy',
                                                                                                   RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_PROS_Segmentation_Mapping__cASI_CRM_CN_PROS_SegmentationMap'));
        insert prosSegMap;
        
        ASI_CRM_CN_Brand_T1_Group__c g = new ASI_CRM_CN_Brand_T1_Group__c(Name='TEST');
        insert g;
        
        list<Account> listA = new list<Account>();
        listA.add(new Account(Name='TEST1', RecordTypeId=mapRtA.get('ASI_CRM_CN_Wholesales_CN').Id));
        listA.add(new Account(Name='TEST2', RecordTypeId=mapRtA.get('ASI_MFM_CN_Outlet').Id));
        insert listA;

        list<ASI_CRM_AccountsAdditionalField__c> listAA = new list<ASI_CRM_AccountsAdditionalField__c>();
        listAA.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Prestige', Name='TEST1', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS') ,ASI_CRM_CN_NewChannel__c = newChannel.Id ,ASI_CRM_Account__c=listA[0].Id, 
                                                          ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name));
        listAA.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', Name='TEST2', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_Account__c=listA[1].Id, 
                                                          ASI_CRM_CN_Chi_Name__c = 'Test Chi', ASI_CRM_CN_Eng_Name__c = 'Test Eng', ASI_CRM_CN_Legal_Name__c = 'Test Legal',
                                                          ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name, ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Energy__c = 'High Energy',
                                                          ASI_CRM_SG_Outlet_Capacity__c='a',ASI_CRM_CN_IS_Volume__c='a',ASI_CRM_CN_Occupancy_Rate__c='a',ASI_CRM_CN_Size_sqm__c='a',ASI_CRM_CN_PRC_Volume__c=1));
        
        
        insert listAA;

        ASI_CRM_AccountsAdditionalField__c childAA =  new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', Name='TEST3', RecordTypeId=mapRtAA.get('ASI_CRM_Outlet_CN').Id, ASI_CRM_Account__c=listA[1].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name, ASI_CRM_CN_Parent_Outlet__c=listAA[0].id, ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Energy__c = 'High Energy',
                                                                                             ASI_CRM_SG_Outlet_Capacity__c='a',ASI_CRM_CN_IS_Volume__c='a',ASI_CRM_CN_Occupancy_Rate__c='a',ASI_CRM_CN_Size_sqm__c='a',ASI_CRM_CN_PRC_Volume__c=1);
        insert childAA;
        
        childAA.ASI_CRM_CN_Parent_Outlet__c = listAA[1].id;
        update childAA;
        
        Set<id> pid = new Set<id>();
        pid.add(listAA[1].id);
        
        ASI_CRM_CN_AccountsAdditional_HelperCls.getParentOutlet(pid);
        
        map<Id, ASI_CRM_AccountsAdditionalField__c> oldMap = new map<Id, ASI_CRM_AccountsAdditionalField__c>();
        
        /*listAA = new list<ASI_CRM_AccountsAdditionalField__c>([SELECT ASI_CRM_CN_Commercial_Team__c, Name, RecordTypeId , ASI_CRM_Account__c , 
                                                               ASI_CRM_CN_Chi_Name__c , ASI_CRM_CN_Eng_Name__c , ASI_CRM_CN_Legal_Name__c ,
                                                               ASI_CRM_CN_CCity__c , ASI_CRM_CN_Sub_Channel__c , ASI_CRM_CN_Brand__c, ASI_CRM_CN_NewChannel__c , ASI_CRM_CN_Energy__c ,
                                                               ASI_CRM_SG_Outlet_Capacity__c ,ASI_CRM_CN_IS_Volume__c ,ASI_CRM_CN_Occupancy_Rate__c ,ASI_CRM_CN_Size_sqm__c ,ASI_CRM_CN_PRC_Volume__c
                                                               , ASI_CRM_CN_Parent_Outlet__c, ASI_CRM_National_Group_Picklist__c, OwnerId
                                                               FROM ASI_CRM_AccountsAdditionalField__c where id = : listAA[0].id or id = : listAA[1].id
                                                              ]);*/
        
        for(ASI_CRM_AccountsAdditionalField__c aa :listAA)
            oldMap.put(aa.Id, aa);
        
        list<ASI_CRM_AccountsAdditionalField__c> childList = new List<ASI_CRM_AccountsAdditionalField__c>();
        childList.add(childAA);
        
        ASI_CRM_CN_AccountsAdditional_HelperCls.SetCustomGroupFlag(childList, null);
        
        Set<id> accId = new Set<id>();
        accId.add(listA[0].id);
        accId.add(listA[1].id);
        
        ASI_CRM_CN_AccountsAdditional_HelperCls.GetT1WSID(accId);
        ASI_CRM_CN_AccountsAdditional_HelperCls.GetT2WSID(accId);
        ASI_CRM_CN_AccountsAdditional_HelperCls.getCustomerMap(accId);
        ASI_CRM_CN_AccountsAdditional_HelperCls.getCustomerT2Map(accId);
        test.startTest();
        
        ASI_CRM_CN_AccountsAdditional_TriggerCls.className = 'None';//21061104 Elufa
        //ASI_CRM_CN_AccountsAdditional_TriggerCls.routineBeforeUpdate(listAA, oldMap);
        //ASI_CRM_CN_AccountsAdditional_TriggerCls.routineBeforeInsert(listAA, oldMap);
        //ASI_CRM_CN_AccountsAdditional_TriggerCls.routineBeforeDelete(listAA, oldMap);
        ASI_CRM_CN_AccountsAdditional_TriggerCls.routineAfterInsert(listAA, oldMap);
        ASI_CRM_CN_AccountsAdditional_TriggerCls.routineAfterUpdate(listAA, oldMap);
        //ASI_CRM_CN_AccountsAdditional_TriggerCls.routineAfterDelete(listAA, oldMap);
        ASI_CRM_CN_AccountsAdditional_TriggerCls.SetCustomGroupFlag(listAA, oldMap);
        
        listAA[1].ASI_CRM_CN_Energy__c = '';
        listAA[1].ASI_CRM_CN_Size_sqm__c = '';
        listAA[1].ASI_CRM_CN_IS_Volume__c = '';
        ASI_CRM_CN_AccountsAdditional_TriggerCls.prosSegmentationMapping(listAA, oldMap);
        
        newChannel.name = 'KTV';
        Update newChannel;
        
        ASI_CRM_CN_AccountsAdditional_TriggerCls.prosSegmentationMapping(listAA, oldMap);
        
        newChannel.name = 'Restaurant';
        Update newChannel;
        
        ASI_CRM_CN_AccountsAdditional_TriggerCls.prosSegmentationMapping(listAA, oldMap);
        
        newChannel.name = 'Hotel';
        listAA[1].ASI_CRM_CN_Brand2__c = Null;
        listAA[1].ASI_CRM_CN_Outlet_Channel_type__c = Null;
        Update newChannel;
        
        ASI_CRM_CN_AccountsAdditional_TriggerCls.prosSegmentationMapping(listAA, oldMap);
        
        ASI_CRM_AccountsAdditionalField__c a = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', Name='TEST2', RecordTypeId=mapRtAA.get('ASI_CRM_Outlet_CN').Id, ASI_CRM_Account__c=listA[1].Id, 
                                                                                      ASI_CRM_CN_Chi_Name__c = 'Test Chi', ASI_CRM_CN_Eng_Name__c = 'Test Eng', ASI_CRM_CN_Legal_Name__c = 'Test Legal',
                                                                                      ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name, ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Energy__c = 'High Energy',
                                                                                      ASI_CRM_SG_Outlet_Capacity__c='a',ASI_CRM_CN_IS_Volume__c='a',ASI_CRM_CN_Occupancy_Rate__c='a',ASI_CRM_CN_Size_sqm__c='a',ASI_CRM_CN_PRC_Volume__c=1);
        
        insert a;
        
        
        test.stopTest();
    }
    
    /*static testMethod void ASI_CRM_CN_AccountsCRMCodeAutoNumber_TEST() {
        
        map<string, RecordType> mapRtA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('Account'))
            mapRtA.put(rt.developerName, rt);
        
        map<string, RecordType> mapRtAA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('ASI_CRM_AccountsAdditionalField__c'))
            mapRtAA.put(rt.developerName, rt);
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='testChannel',ASI_CRM_CN_On_Off__c='On');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(Name='testSubChannel',ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(Name='Bar',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'));
        insert newChannel;
        
        ASI_CRM_CN_Brand_T1_Group__c g = new ASI_CRM_CN_Brand_T1_Group__c(Name='TEST');
        insert g;
        
        list<Account> listA = new list<Account>();
        listA.add(new Account(Name='TEST1', RecordTypeId=mapRtA.get('ASI_CRM_CN_Wholesales_CN').Id));
        listA.add(new Account(Name='TEST2', RecordTypeId=mapRtA.get('ASI_MFM_CN_Outlet').Id));
        insert listA;
        list<ASI_CRM_AccountsAdditionalField__c> listAA = new list<ASI_CRM_AccountsAdditionalField__c>();
        listAA.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST1', RecordTypeId=mapRtAA.get('ASI_CRM_CN_WS').Id, ASI_CRM_Account__c=listA[0].Id, 
                                                          ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name));
        listAA.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST2', RecordTypeId=mapRtAA.get('ASI_CRM_Outlet_CN').Id, ASI_CRM_Account__c=listA[1].Id, 
                                                          ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name, ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Energy__c = 'High Energy'));
        
        test.startTest();
        
        insert listAA;
        
        test.stopTest();
        
    }*/

    static testMethod void ASI_CRM_CN_ApplyBrandT1T2Ctrl_TEST1() {
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='OFF');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Hotel',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Prestige', RecordTypeId=rtWS, ASI_CRM_CN_NewChannel__c = newChannel.Id , ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        //a2s.add(new ASI_CRM_AccountsAdditionalField__c(RecordTypeId=rtOutlet, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        //a2s.add(new ASI_CRM_AccountsAdditionalField__c(RecordTypeId=rtOutlet, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c ();
        insert subBrand;
        
        list<ASI_CRM_Subbrand_Volume__c> svols = new list<ASI_CRM_Subbrand_Volume__c>();
        svols.add(new ASI_CRM_Subbrand_Volume__c(
            ASI_CRM_Account__c = a2s[0].Id,
            ASI_CRM_Subbrand__c = subBrand.Id,
            ASI_CRM_End_Date__c = system.today().addMonths(-1)));
        //svols.add(new ASI_CRM_Subbrand_Volume__c(
        //    ASI_CRM_Account__c = a2s[1].Id,
        //    ASI_CRM_Subbrand__c = subBrand.Id,
        //    ASI_CRM_End_Date__c = system.today().addMonths(-1)));
        insert svols;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_CRM_AccountsAdditionalField__c a2 :a2s) 
            scons.add(new ApexPages.StandardController(a2));
        
        test.startTest();
        
        for(ApexPages.StandardController scon :scons) {
            ASI_CRM_CN_ApplyBrandT1T2Ctrl con = new ASI_CRM_CN_ApplyBrandT1T2Ctrl(scon);
            con.SuccessMessage = con.SuccessMessage;
            con.hasError = con.hasError;
            con.initBT1();
            con.initT2();
        }
        
        //{ //exception test
        //    delete new ASI_CRM_AccountsAdditionalField__c(Id=a2s[2].Id);
        //    ASI_CRM_CN_ApplyBrandT1T2Ctrl con = new ASI_CRM_CN_ApplyBrandT1T2Ctrl(scons[0]);
        //    con.initBT1();
        //    con.initT2();
        //}
        
        test.stopTest();
        
    }
    
    static testMethod void ASI_CRM_CN_ApplyBrandT1T2Ctrl_TEST2() {
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='OFF');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        //a2s.add(new ASI_CRM_AccountsAdditionalField__c(RecordTypeId=rtWS, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', RecordTypeId=rtOutlet, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        //a2s.add(new ASI_CRM_AccountsAdditionalField__c(RecordTypeId=rtOutlet, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c ();
        insert subBrand;
        
        list<ASI_CRM_Subbrand_Volume__c> svols = new list<ASI_CRM_Subbrand_Volume__c>();
        svols.add(new ASI_CRM_Subbrand_Volume__c(
            ASI_CRM_Account__c = a2s[0].Id,
            ASI_CRM_Subbrand__c = subBrand.Id,
            ASI_CRM_End_Date__c = system.today().addMonths(-1)));
        //svols.add(new ASI_CRM_Subbrand_Volume__c(
        //    ASI_CRM_Account__c = a2s[1].Id,
        //    ASI_CRM_Subbrand__c = subBrand.Id,
        //    ASI_CRM_End_Date__c = system.today().addMonths(-1)));
        insert svols;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_CRM_AccountsAdditionalField__c a2 :a2s) 
            scons.add(new ApexPages.StandardController(a2));
        
        test.startTest();
        
        for(ApexPages.StandardController scon :scons) {
            ASI_CRM_CN_ApplyBrandT1T2Ctrl con = new ASI_CRM_CN_ApplyBrandT1T2Ctrl(scon);
            con.SuccessMessage = con.SuccessMessage;
            con.hasError = con.hasError;
            con.initBT1();
            con.initT2();
        }
        
        //{ //exception test
        //    delete new ASI_CRM_AccountsAdditionalField__c(Id=a2s[2].Id);
        //    ASI_CRM_CN_ApplyBrandT1T2Ctrl con = new ASI_CRM_CN_ApplyBrandT1T2Ctrl(scons[0]);
        //    con.initBT1();
        //    con.initT2();
        //}
        
        test.stopTest();
        
    }
    
    static testMethod void ASI_CRM_CN_ApplyBrandT1T2Ctrl_TEST3() {
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='OFF');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        //a2s.add(new ASI_CRM_AccountsAdditionalField__c(RecordTypeId=rtWS, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', RecordTypeId=rtOutlet, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', RecordTypeId=rtOutlet, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c ();
        insert subBrand;
        
        //list<ASI_CRM_Subbrand_Volume__c> svols = new list<ASI_CRM_Subbrand_Volume__c>();
        //svols.add(new ASI_CRM_Subbrand_Volume__c(
        //    ASI_CRM_Account__c = a2s[0].Id,
        //    ASI_CRM_Subbrand__c = subBrand.Id,
        //    ASI_CRM_End_Date__c = system.today().addMonths(-1)));
        //svols.add(new ASI_CRM_Subbrand_Volume__c(
        //    ASI_CRM_Account__c = a2s[1].Id,
        //    ASI_CRM_Subbrand__c = subBrand.Id,
        //    ASI_CRM_End_Date__c = system.today().addMonths(-1)));
        //insert svols;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_CRM_AccountsAdditionalField__c a2 :a2s) 
            scons.add(new ApexPages.StandardController(a2));
        
        test.startTest();
        
        //for(ApexPages.StandardController scon :scons) {
        //    ASI_CRM_CN_ApplyBrandT1T2Ctrl con = new ASI_CRM_CN_ApplyBrandT1T2Ctrl(scon);
        //    con.SuccessMessage = con.SuccessMessage;
        //    con.hasError = con.hasError;
        //    con.initBT1();
        //    con.initT2();
        //}
        
        { //exception test
            delete new ASI_CRM_AccountsAdditionalField__c(Id=a2s[1].Id);
            ASI_CRM_CN_ApplyBrandT1T2Ctrl con = new ASI_CRM_CN_ApplyBrandT1T2Ctrl(scons[0]);
            con.initBT1();
            con.initT2();
        }
        
        test.stopTest();
        
    }

    static testMethod void ASI_CRM_CN_ApplyCapCollectionCtrl_TEST() {
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Hotel',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Prestige', RecordTypeId=rtWS, ASI_CRM_CN_NewChannel__c = newChannel.Id ,ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', RecordTypeId=rtOutlet, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Brand2__c = 'Chinese',ASI_CRM_CN_Outlet_Channel_type__c='Nightclub',ASI_CRM_CN_Guest_room_price__c=1,ASI_CRM_CN_Number_of_Stars__c='1'));
        insert a2s;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_CRM_AccountsAdditionalField__c a2 :a2s) 
            scons.add(new ApexPages.StandardController(a2));
        
        test.startTest();
        
        for(ApexPages.StandardController scon :scons) {
            ASI_CRM_CN_ApplyCapCollectionCtrl con = new ASI_CRM_CN_ApplyCapCollectionCtrl(scon);
            con.init();
        }
        
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_T1T2_ApprovalPage_Ctrl_TEST() {

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
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
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST1', ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a',  RecordTypeId=rtWS, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Status_T1__c='Draft'));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST2', ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b',  RecordTypeId=rtWS, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Status_T2__c='Draft'));        
        insert a2s;

        list<ASI_CRM_AccountsAdditionalField__c> listCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        listCustomers = [SELECT Name, id, RecordTypeId, ASI_CRM_CN_CCity__c, ASI_CRM_CN_Sub_Channel__c, ASI_CRM_CN_Status_T1__c, ASI_CRM_CN_Status_T2__c, ASI_CRM_CN_Region__c FROM
            ASI_CRM_AccountsAdditionalField__c ORDER BY ASI_CRM_CN_Type__c];

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_CRM_AccountsAdditionalField__c a2 :listCustomers) 
            scons.add(new ApexPages.StandardController(a2));


        Id currentUserId = UserInfo.getUserId(); 
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testing123.com', CompanyName = 'Pernod Ricard China');
        Map<id, User> MUser = new Map<id, User>();
        MUser.put(u.id, u);        

        List<ASI_CRM_Dynamic_Approval_Route__c> LDynApproval = new List<ASI_CRM_Dynamic_Approval_Route__c >();
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='WS T1',ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true));
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='WS T2',ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true));
        insert LDynApproval ;

        List<ASI_CRM_Fix_Approval_Route__c> listFixRoute = new List<ASI_CRM_Fix_Approval_Route__c>();
        listFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=currentUserId, ASI_CRM_CN_Approver_2__c=currentUserId, ASI_CRM_CN_Approver_3__c=currentUserId, ASI_CRM_CN_Approver_4__c=currentUserId, ASI_CRM_CN_Approver_5__c=currentUserId, ASI_CRM_CN_Approver_6__c=currentUserId, ASI_CRM_CN_Type__c='WS T1', ASI_CRM_CN_Region_Area_Channel__c='TEST', ownerid=currentUserId));
        listFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=currentUserId, ASI_CRM_CN_Type__c='WS T2', ASI_CRM_CN_Region_Area_Channel__c='TEST', ownerid=currentUserId));
        insert listFixRoute;

        Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute = new Map<id, ASI_CRM_Dynamic_Approval_Route__c>();
        Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();

        MAppRoute.put(LDynApproval[0].ASI_CRM_User__c, LDynApproval[0]);
        MAppRouteFix.put(listFixRoute[0].ASI_CRM_CN_Region_Area_Channel__c, listFixRoute[0]);
                
        test.startTest();
        
        ApexPages.currentPage().getParameters().put('Id', listCustomers[0].id);
        ApexPages.currentPage().getParameters().put('WSType', 'T1');
        ASI_CRM_CN_T1T2_ApprovalPage_Ctrl  con = new ASI_CRM_CN_T1T2_ApprovalPage_Ctrl (scons[0]);
        con.init();
        ASI_CRM_CN_T1T2_ApprovalPage_Ctrl.defineApproval('WS T1', listCustomers[0]);
        // ASI_CRM_CN_T1T2_ApprovalPage_Ctrl.setApprovers(listCustomers[0], MAppRouteFix, MAppRoute, MAppRouteFix, MUser);
        ASI_CRM_CN_T1T2_ApprovalPage_Ctrl.setApproverToNull(listCustomers[0]);
        for(Integer i=0; i<10; i++)
        {
            ASI_CRM_CN_T1T2_ApprovalPage_Ctrl.setApproverByCount(listCustomers[0], i, currentUserId);
        }  
        test.stopTest();          
    }
    
    static testMethod void ASI_CRM_CN_T1T2_ApprovalPage_Ctrl_TEST_1() {

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
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
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST1', ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a',  RecordTypeId=rtWS, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Status_T1__c='Draft'));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST2', ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b',  RecordTypeId=rtWS, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Status_T2__c='Draft'));        
        insert a2s;

        list<ASI_CRM_AccountsAdditionalField__c> listCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        listCustomers = [SELECT Name, id, RecordTypeId, ASI_CRM_CN_CCity__c, ASI_CRM_CN_Sub_Channel__c, ASI_CRM_CN_Status_T1__c, ASI_CRM_CN_Status_T2__c, ASI_CRM_CN_Region__c FROM
            ASI_CRM_AccountsAdditionalField__c ORDER BY ASI_CRM_CN_Type__c];

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_CRM_AccountsAdditionalField__c a2 :listCustomers) 
            scons.add(new ApexPages.StandardController(a2));


        Id currentUserId = UserInfo.getUserId(); 
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testing123.com');
        Map<id, User> MUser = new Map<id, User>();
        MUser.put(u.id, u);    

        List<ASI_CRM_Dynamic_Approval_Route__c> LDynApproval = new List<ASI_CRM_Dynamic_Approval_Route__c >();
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='WS T1',ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true));
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='WS T2',ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true));
        insert LDynApproval ;

        List<ASI_CRM_Fix_Approval_Route__c> listFixRoute = new List<ASI_CRM_Fix_Approval_Route__c>();
        listFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=currentUserId, ASI_CRM_CN_Approver_2__c=currentUserId, ASI_CRM_CN_Approver_3__c=currentUserId, ASI_CRM_CN_Approver_4__c=currentUserId, ASI_CRM_CN_Approver_5__c=currentUserId, ASI_CRM_CN_Approver_6__c=currentUserId, ASI_CRM_CN_Type__c='WS T1', ASI_CRM_CN_Region_Area_Channel__c='TEST', ownerid=currentUserId));
        listFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=currentUserId, ASI_CRM_CN_Type__c='WS T2', ASI_CRM_CN_Region_Area_Channel__c='TEST', ownerid=currentUserId));
        insert listFixRoute;

        Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute = new Map<id, ASI_CRM_Dynamic_Approval_Route__c>();
        Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();

        MAppRoute.put(LDynApproval[0].ASI_CRM_User__c, LDynApproval[0]);
        MAppRouteFix.put(listFixRoute[0].ASI_CRM_CN_Region_Area_Channel__c, listFixRoute[0]);
                
        test.startTest();
        
        ApexPages.currentPage().getParameters().put('Id', listCustomers[0].id);
        ApexPages.currentPage().getParameters().put('WSType', 'T1');
        ASI_CRM_CN_T1T2_ApprovalPage_Ctrl  con = new ASI_CRM_CN_T1T2_ApprovalPage_Ctrl (scons[0]);
        
        ApexPages.currentPage().getParameters().put('Id', listCustomers[1].id);
        ApexPages.currentPage().getParameters().put('WSType', 'T2');
        ASI_CRM_CN_T1T2_ApprovalPage_Ctrl  con2 = new ASI_CRM_CN_T1T2_ApprovalPage_Ctrl (scons[1]);
        con2.init();
        
        test.stopTest();
    }
    static testMethod void ASI_CRM_CN_Cancel_T1T2_ApprovalPage_Ctrl_TEST() {

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
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
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST1', ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a',  RecordTypeId=rtWS, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Status_T1__c='Draft'));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST2', ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b',  RecordTypeId=rtWS, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Status_T2__c='Draft'));        
        insert a2s;

        list<ASI_CRM_AccountsAdditionalField__c> listCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        listCustomers = [SELECT Name, id, RecordTypeId, ASI_CRM_CN_CCity__c, ASI_CRM_CN_Sub_Channel__c, ASI_CRM_CN_Status_T1__c, ASI_CRM_CN_Status_T2__c, ASI_CRM_CN_Region__c FROM
            ASI_CRM_AccountsAdditionalField__c ORDER BY ASI_CRM_CN_Type__c];

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_CRM_AccountsAdditionalField__c a2 :listCustomers) 
            scons.add(new ApexPages.StandardController(a2));


        Id currentUserId = UserInfo.getUserId(); 
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testing123.com', CompanyName = 'Pernod Ricard China');
        Map<id, User> MUser = new Map<id, User>();
        MUser.put(u.id, u);        

        List<ASI_CRM_Dynamic_Approval_Route__c> LDynApproval = new List<ASI_CRM_Dynamic_Approval_Route__c >();
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='WS T1',ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true));
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='WS T2',ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true));
        insert LDynApproval ;

        List<ASI_CRM_Fix_Approval_Route__c> listFixRoute = new List<ASI_CRM_Fix_Approval_Route__c>();
        listFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=currentUserId, ASI_CRM_CN_Approver_2__c=currentUserId, ASI_CRM_CN_Approver_3__c=currentUserId, ASI_CRM_CN_Approver_4__c=currentUserId, ASI_CRM_CN_Approver_5__c=currentUserId, ASI_CRM_CN_Approver_6__c=currentUserId, ASI_CRM_CN_Type__c='WS T1', ASI_CRM_CN_Region_Area_Channel__c='TEST', ownerid=currentUserId));
        listFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=currentUserId, ASI_CRM_CN_Type__c='WS T2', ASI_CRM_CN_Region_Area_Channel__c='TEST', ownerid=currentUserId));
        insert listFixRoute;

        Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute = new Map<id, ASI_CRM_Dynamic_Approval_Route__c>();
        Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();

        MAppRoute.put(LDynApproval[0].ASI_CRM_User__c, LDynApproval[0]);
        MAppRouteFix.put(listFixRoute[0].ASI_CRM_CN_Region_Area_Channel__c, listFixRoute[0]);
                
        test.startTest();
        
        ApexPages.currentPage().getParameters().put('Id', listCustomers[0].id);
        ApexPages.currentPage().getParameters().put('WSType', 'T1');
        ASI_CRM_CN_T1T2_CancelApprovalPage_Ctrl  con = new ASI_CRM_CN_T1T2_CancelApprovalPage_Ctrl (scons[0]);
        con.init();
        ASI_CRM_CN_T1T2_CancelApprovalPage_Ctrl.defineApproval('WS T1', listCustomers[0]);
        ASI_CRM_CN_T1T2_CancelApprovalPage_Ctrl.setApprovers(listCustomers[0], 'TEST', MAppRoute, MAppRouteFix, MUser);
        ASI_CRM_CN_T1T2_CancelApprovalPage_Ctrl.setApproverToNull(listCustomers[0]);
        for(Integer i=0; i<10; i++)
        {
            ASI_CRM_CN_T1T2_CancelApprovalPage_Ctrl.setApproverByCount(listCustomers[0], i, currentUserId);
        }  
        test.stopTest();          
    }
    
    static testMethod void ASI_CRM_CN_Cancel_T1T2_ApprovalPage_Ctrl_TEST_1() {

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
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
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST1', ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a',  RecordTypeId=rtWS, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Status_T1__c='Draft'));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST2', ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b',  RecordTypeId=rtWS, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Status_T2__c='Draft'));        
        insert a2s;

        list<ASI_CRM_AccountsAdditionalField__c> listCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        listCustomers = [SELECT Name, id, RecordTypeId, ASI_CRM_CN_CCity__c, ASI_CRM_CN_Sub_Channel__c, ASI_CRM_CN_Status_T1__c, ASI_CRM_CN_Status_T2__c, ASI_CRM_CN_Region__c FROM
            ASI_CRM_AccountsAdditionalField__c ORDER BY ASI_CRM_CN_Type__c];

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_CRM_AccountsAdditionalField__c a2 :listCustomers) 
            scons.add(new ApexPages.StandardController(a2));


        Id currentUserId = UserInfo.getUserId(); 
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testing123.com');
        Map<id, User> MUser = new Map<id, User>();
        MUser.put(u.id, u);    

        List<ASI_CRM_Dynamic_Approval_Route__c> LDynApproval = new List<ASI_CRM_Dynamic_Approval_Route__c >();
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='WS T1',ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true));
        LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='WS T2',ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true));
        insert LDynApproval ;

        List<ASI_CRM_Fix_Approval_Route__c> listFixRoute = new List<ASI_CRM_Fix_Approval_Route__c>();
        listFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=currentUserId, ASI_CRM_CN_Approver_2__c=currentUserId, ASI_CRM_CN_Approver_3__c=currentUserId, ASI_CRM_CN_Approver_4__c=currentUserId, ASI_CRM_CN_Approver_5__c=currentUserId, ASI_CRM_CN_Approver_6__c=currentUserId, ASI_CRM_CN_Type__c='WS T1', ASI_CRM_CN_Region_Area_Channel__c='TEST', ownerid=currentUserId));
        listFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=currentUserId, ASI_CRM_CN_Type__c='WS T2', ASI_CRM_CN_Region_Area_Channel__c='TEST', ownerid=currentUserId));
        insert listFixRoute;

        Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute = new Map<id, ASI_CRM_Dynamic_Approval_Route__c>();
        Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();

        MAppRoute.put(LDynApproval[0].ASI_CRM_User__c, LDynApproval[0]);
        MAppRouteFix.put(listFixRoute[0].ASI_CRM_CN_Region_Area_Channel__c, listFixRoute[0]);
                
        test.startTest();
        
        ApexPages.currentPage().getParameters().put('Id', listCustomers[0].id);
        ApexPages.currentPage().getParameters().put('WSType', 'T1');
        ASI_CRM_CN_T1T2_CancelApprovalPage_Ctrl  con = new ASI_CRM_CN_T1T2_CancelApprovalPage_Ctrl (scons[0]);
        
        ApexPages.currentPage().getParameters().put('Id', listCustomers[1].id);
        ApexPages.currentPage().getParameters().put('WSType', 'T2');
        ASI_CRM_CN_T1T2_CancelApprovalPage_Ctrl  con2 = new ASI_CRM_CN_T1T2_CancelApprovalPage_Ctrl (scons[1]);
        con2.init();
        
        test.stopTest();
    }
}