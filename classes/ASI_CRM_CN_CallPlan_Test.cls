@isTest
public class ASI_CRM_CN_CallPlan_Test{

    static testMethod void ASI_CRM_CN_AddCallPlanController_TEST() {
        
        map<string, RecordType> mapRtA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('Account'))
            mapRtA.put(rt.developerName, rt);
        
        map<string, RecordType> mapRtAA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('ASI_CRM_AccountsAdditionalField__c'))
            mapRtAA.put(rt.developerName, rt);
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY');
        insert city;
        
        list<Account> listA = new list<Account>();
        listA.add(new Account(Name='TEST', RecordTypeId=mapRtA.get('ASI_CRM_CN_Wholesales_CN').Id));
        insert listA;
        list<ASI_CRM_AccountsAdditionalField__c> listAA = new list<ASI_CRM_AccountsAdditionalField__c>();
        listAA.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST', RecordTypeId=mapRtAA.get('ASI_CRM_CN_WS').Id, ASI_CRM_Account__c=listA[0].Id, ASI_CRM_CN_CCity__c=city.Id));
        insert listAA;
        
        test.startTest();
        
        {
            ApexPages.StandardSetController scon = new ApexPages.StandardSetController(listA);
            ASI_CRM_CN_AddCallPlanController con = new ASI_CRM_CN_AddCallPlanController(scon);
            con.DummyContact.Birthdate = system.today();
            con.createCallPlans();
        }
        
        {
            ApexPages.StandardSetController scon = new ApexPages.StandardSetController(listA);
            scon.setSelected(listA);
            ASI_CRM_CN_AddCallPlanController con = new ASI_CRM_CN_AddCallPlanController(scon);
            con.DummyContact.Birthdate = system.today();
            con.createCallPlans();
        }
        
        {
            ApexPages.StandardSetController scon = new ApexPages.StandardSetController(listAA);
            scon.setSelected(listAA);
            ASI_CRM_CN_AddCallPlanController con = new ASI_CRM_CN_AddCallPlanController(scon);
            con.DummyContact.Birthdate = system.today();
            con.createCallPlans();
        }
    }
    
    static testMethod void ASI_CRM_CN_AddCallLogController_TEST() {
        map<string, RecordType> mapRtA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('Account'))
            mapRtA.put(rt.developerName, rt);
        
        map<string, RecordType> mapRtAA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('ASI_CRM_AccountsAdditionalField__c'))
            mapRtAA.put(rt.developerName, rt);
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY');
        insert city;
        
        Account a = new Account(Name='TEST', RecordTypeId=mapRtA.get('ASI_CRM_CN_Wholesales_CN').Id);
        insert a;
        
        list<ASI_CRM_AccountsAdditionalField__c> aas = new list<ASI_CRM_AccountsAdditionalField__c>();
        aas.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_Account__c=a.Id, RecordTypeId=mapRtAA.get('ASI_CRM_CN_WS').Id, ASI_CRM_CN_CCity__c=city.Id));
        insert aas;
        aas = [SELECT Id, ASI_CRM_Account__c, RecordType.developerName FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:aas[0].Id]; 
        
        
        test.startTest();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(aas[0]);
        ASI_CRM_CN_AddCallLogController actController = new ASI_CRM_CN_AddCallLogController(stdController);
        actController.AccountAdditional = actController.AccountAdditional;
        actController.CallLog = actController.CallLog;
        actController.Type = actController.Type;
        actController.Msg = actController.Msg;
        actController.InventoryInOutCheck = actController.InventoryInOutCheck;
        actController.StockCheck = actController.StockCheck;
        //actController.DiscussCompetitorProduct = actController.DiscussCompetitorProduct;
        actController.GMACheck = actController.GMACheck;
        actController.DataQualityCheck = actController.DataQualityCheck;
        actController.DiscussBusiness = actController.DiscussBusiness;
        actController.IncentivePayment = actController.IncentivePayment;
        actController.DailyBusiness = actController.DailyBusiness;
        actController.BusinessDevelopment = actController.BusinessDevelopment;
        actController.OfftakeCheck = actController.OfftakeCheck;
        actController.RSPCheck = actController.RSPCheck;
        actController.submit();
        
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_CallPlanEventCalendar_TEST() {
        
        map<string, RecordType> mapRtA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('Account'))
            mapRtA.put(rt.developerName, rt);
        
        map<string, RecordType> mapRtAA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('ASI_CRM_AccountsAdditionalField__c'))
            mapRtAA.put(rt.developerName, rt);
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY');
        insert city;
        
        list<Account> listA = new list<Account>();
        listA.add(new Account(Name='TEST', RecordTypeId=mapRtA.get('ASI_MFM_CN_Outlet').Id));
        insert listA;
        
        list<ASI_CRM_AccountsAdditionalField__c> listAA = new list<ASI_CRM_AccountsAdditionalField__c>();
        listAA.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST', RecordTypeId=mapRtAA.get('ASI_CRM_CN_WS').Id, ASI_CRM_Account__c=listA[0].Id, ASI_CRM_CN_CCity__c=city.Id));
        insert listAA;
        
        //*********** MODIFIED BY GDT
        date StartDate= ASI_CRM_JP_TestClassHelper.createTestDate();
        //***********   
        
        list<Event> es = new list<Event>();
        for(ASI_CRM_AccountsAdditionalField__c a2 :listAA) 
            //es.add(new Event(Subject='TEST', WhatId=a2.Id, StartDateTime=datetime.newInstance(2014,1,1), EndDateTime=datetime.newInstance(2014,1,2), RecordTypeId=Global_RecordTypeCache.getRtId('EventASI_CRM_CN_Call_Plan')));
            es.add(new Event(Subject='TEST', WhatId=a2.Id, StartDateTime=StartDate, EndDateTime=StartDate.adddays(1), RecordTypeId=Global_RecordTypeCache.getRtId('EventASI_CRM_CN_Call_Plan')));
        insert es;
        
        list<ASI_MFM_Event__c> evs = new list<ASI_MFM_Event__c>();
        ASI_HK_CRM_Running_Number__c RunningNo = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_MFM_CN_Event', ASI_HK_CRM_Running_Number__c = 1, ASI_HK_CRM_Format__c = 'Event-{YY}{000000}', ASI_HK_CRM_Fiscal_Year__c = 2014, ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number'));
        insert RunningNo;
        for(Account acc :listA) 
            evs.add(new ASI_MFM_Event__c(ASI_MFM_Key_Event_Type_Budget_Share__c = 100,
            ASI_MFM_Sub_Event_Type__c = 'Thematic Promotion',                                 //Event Type
            ASI_MFM_Event_Type__c = 'Image/Brand Driven Event',   
            ASI_MFM_Start_Date__c=Date.valueof('2014-04-04'),               //Start date
            recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Event__cASI_MFM_CN_Event'),          
            Name='new event',                                               //Event Name
            ASI_MFM_Status__c='On Going',                                   //Status
            ASI_MFM_Mechanics__c='abcdefg',                                 //Mechanics                                      
            ASI_MFM_Objective__c='xyzabc',                                  //Objective       
            ASI_MFM_Agency_Team__c='Team A',                                //mAgency Team
            CurrencyIsoCode='',
            ASI_MFM_Agency__c=acc.Id));
        insert evs;
        
        
        list<ASI_MFM_Event_Outlet__c> eos = new list<ASI_MFM_Event_Outlet__c>();
        for(ASI_MFM_Event__c ev: evs)
            eos.add( new ASI_MFM_Event_Outlet__c(
                ASI_MFM_Outlet__c=ev.ASI_MFM_Agency__c,
                
                //*********** MODIFIED BY GDT
                //ASI_MFM_Beginning_Date__c=date.newInstance(2014,1,1),
                ASI_MFM_Beginning_Date__c=StartDate,
                //ASI_MFM_End_Date__c=date.newInstance(2014,1,2),  
                ASI_MFM_End_Date__c=StartDate.addmonths(1),
                //***********
                 
                ASI_MFM_Event_Type__c='Image/Brand Driven Event',
                ASI_MFM_Event__c=ev.Id,
                ASI_MFM_Wave__c='TEST',
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Event_Outlet__cASI_MFM_CN_Event_Outlet')));
        insert eos;
        
        test.startTest();
        
        {
            ASI_CRM_CN_CallPlanEventCalendar.CalendarEvent ce = new ASI_CRM_CN_CallPlanEventCalendar.CalendarEvent();
            ce.id = ce.id;
            ce.text = ce.text;
            ce.start_date = ce.start_date;
            ce.end_date = ce.end_date;
            ce.details = ce.details;
            ce.outletId = ce.outletId;
            ce.css = ce.css;
        }
        
        {
            ASI_CRM_CN_CallPlanEventCalendar.CalendarEvents ce = new ASI_CRM_CN_CallPlanEventCalendar.CalendarEvents();
            ce.wholelist = ce.wholelist;
        }  
        
        ASI_CRM_CN_CallPlanEventCalendar con = new ASI_CRM_CN_CallPlanEventCalendar();
        List<String> user = con.getUsers();
        con.setUsers(user);
        con.getUserItems();
        
        ASI_CRM_CN_CallPlanEventCalendar.getEventData('All','2014-01-01');
        ASI_CRM_CN_CallPlanEventCalendar.getEventData('','2014-01-01');
        
        delete es;
        
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_Call_Log_TriggerClass_TEST() {
        
        map<string, RecordType> mapRtA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('Account'))
            mapRtA.put(rt.developerName, rt);
        
        map<string, RecordType> mapRtAA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('ASI_CRM_AccountsAdditionalField__c'))
            mapRtAA.put(rt.developerName, rt);
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY');
        insert city;
        
        list<Account> listA = new list<Account>();
        listA.add(new Account(Name='TEST', RecordTypeId=mapRtA.get('ASI_MFM_CN_Outlet').Id));
        insert listA;
        
        list<ASI_CRM_AccountsAdditionalField__c> listAA = new list<ASI_CRM_AccountsAdditionalField__c>();
        listAA.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST', RecordTypeId=mapRtAA.get('ASI_CRM_CN_WS').Id, ASI_CRM_Account__c=listA[0].Id, ASI_CRM_CN_CCity__c=city.Id));
        insert listAA;

        list<ASI_CRM_Call_Log__c> logs = new list<ASI_CRM_Call_Log__c>();        
        for(ASI_CRM_AccountsAdditionalField__c a2: listAA)
            logs.add(new ASI_CRM_Call_Log__c(ASI_CRM_AccountsAdditionalField__c=a2.Id, ASI_CRM_Visit_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Call_Log__cASI_CRM_CallLog_CN_WS'), ASI_CRM_Follow_up__c='xxxxxxx'));
        insert logs;
        
        list<ASI_CRM_Call_Log__c> tmpLog = [SELECT id, CreatedById, ASI_CRM_AccountsAdditionalField__c, RecordTypeId, ASI_CRM_Follow_up__c, ASI_CRM_Visit_Date__c,ASI_CRM_Due_Date__c FROM ASI_CRM_Call_Log__c WHERE Id =: logs[0].Id];
        
        map<Id, ASI_CRM_Call_Log__c> oldMap = new map<Id, ASI_CRM_Call_Log__c>();
        for(ASI_CRM_Call_Log__c log :logs)
            oldMap.put(log.Id, log);
        
        test.startTest();
        
        //ASI_CRM_CN_Call_Log_TriggerClass.routineAfterInsert(logs);
        ASI_CRM_CN_Call_Log_TriggerClass.routineAfterUpdate(logs, oldMap);
        ASI_CRM_CN_Call_Log_TriggerClass.routineAfterDelete(logs);
        
        ASI_CRM_CN_Call_Log_TriggerClass.routineAfterInsert(tmpLog);
        update logs;
        delete logs;
        test.stopTest();
        
    }

    static testMethod void ASI_CRM_CN_NewCallLogRedirectController_TEST() {
        
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_CRM_AccountsAdditionalField__c a2: a2s)
            scons.add(new ApexPages.StandardController(a2));
        
        test.startTest();
        
        for(ApexPages.StandardController scon :scons) {
            ASI_CRM_CN_NewCallLogRedirectController con = new ASI_CRM_CN_NewCallLogRedirectController(scon);
            con.redirect();
        }
        
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_Event_TriggerClass_TEST() {
        map<string, RecordType> mapRtA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('Account'))
            mapRtA.put(rt.developerName, rt);
        
        map<string, RecordType> mapRtAA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('ASI_CRM_AccountsAdditionalField__c'))
            mapRtAA.put(rt.developerName, rt);
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY');
        insert city;
        
        list<Account> listA = new list<Account>();
        listA.add(new Account(Name='TEST', RecordTypeId=mapRtA.get('ASI_MFM_CN_Outlet').Id));
        insert listA;
        
        list<ASI_CRM_AccountsAdditionalField__c> listAA = new list<ASI_CRM_AccountsAdditionalField__c>();
        listAA.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST', RecordTypeId=mapRtAA.get('ASI_CRM_CN_WS').Id, ASI_CRM_Account__c=listA[0].Id, ASI_CRM_CN_CCity__c=city.Id));
        insert listAA;
        
        //*********** MODIFIED BY GDT
        date StartDate = ASI_CRM_JP_TestClassHelper.createTestDate();
        //***********        
        list<Event> es = new list<Event>();
        for(ASI_CRM_AccountsAdditionalField__c a2 :listAA) 
            //es.add(new Event(WhatId=a2.Id, StartDateTime=datetime.newInstance(2014,1,1), EndDateTime=datetime.newInstance(2014,1,2), RecordTypeId=Global_RecordTypeCache.getRtId('EventASI_CRM_CN_Call_Plan')));
            es.add(new Event(WhatId=a2.Id, StartDateTime=StartDate, EndDateTime=StartDate.adddays(1), RecordTypeId=Global_RecordTypeCache.getRtId('EventASI_CRM_CN_Call_Plan')));
        insert es;

        test.startTest();        
        {
            map<Id, Event> oldMap = new map<Id, Event>();
            for(Event e :es)
                oldMap.put(e.Id, e);
                
            ASI_CRM_CN_Event_TriggerClass.routineAfterInsert(es);
            ASI_CRM_CN_Event_TriggerClass.routineAfterUpdate(es, oldMap);
            ASI_CRM_CN_Event_TriggerClass.routineAfterDelete(es);

        }        
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_EventTaskCalendar_Controller_TEST() {
        //##### create Event #####
        map<string, RecordType> mapRtA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('Account'))
            mapRtA.put(rt.developerName, rt);
        
        map<string, RecordType> mapRtAA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('ASI_CRM_AccountsAdditionalField__c'))
            mapRtAA.put(rt.developerName, rt);
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY');
        insert city;
        
        list<Account> listA = new list<Account>();
        listA.add(new Account(Name='TEST', RecordTypeId=mapRtA.get('ASI_MFM_CN_Outlet').Id));
        insert listA;
        
        list<ASI_CRM_AccountsAdditionalField__c> listAA = new list<ASI_CRM_AccountsAdditionalField__c>();
        listAA.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST', RecordTypeId=mapRtAA.get('ASI_CRM_CN_WS').Id, ASI_CRM_Account__c=listA[0].Id, ASI_CRM_CN_CCity__c=city.Id));
        insert listAA;
        
        //*********** MODIFIED BY GDT
        date StartDate = ASI_CRM_JP_TestClassHelper.createTestDate();
        //***********        
        list<Event> es = new list<Event>();
        for(ASI_CRM_AccountsAdditionalField__c a2 :listAA) 
            //es.add(new Event(WhatId=a2.Id, StartDateTime=datetime.newInstance(2014,1,1), EndDateTime=datetime.newInstance(2014,1,2), RecordTypeId=Global_RecordTypeCache.getRtId('EventASI_CRM_CN_Call_Plan')));
            es.add(new Event(WhatId=a2.Id, StartDateTime=StartDate, EndDateTime=StartDate.adddays(1), RecordTypeId=Global_RecordTypeCache.getRtId('EventASI_CRM_CN_Call_Plan')));
        insert es;

        //##### create MFM Event #####
            //***creat account** / 
        Account account_outlet = new Account(
            Name='TestAcc',
            recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'),
            ASI_MFM_Customer_Supplier_Number__c='123',
            ASI_MFM_Customer_Supplier_Name__c='SupplierName'
        );
        insert account_outlet;
        
            //***create account additionalfield ***
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='testChannel',ASI_CRM_CN_On_Off__c='On');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(Name='testSubChannel',ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Brand_T1_Group__c g = new ASI_CRM_CN_Brand_T1_Group__c(Name='TEST');
        insert g;        
        
        ASI_CRM_AccountsAdditionalField__c childAA =  new ASI_CRM_AccountsAdditionalField__c(Name='TEST3', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_Account__c=account_outlet.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name);
        insert childAA;
        ASI_HK_CRM_Running_Number__c RunningNo = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_MFM_CN_Event', ASI_HK_CRM_Running_Number__c = 1, ASI_HK_CRM_Format__c = 'Event-{YY}{000000}', ASI_HK_CRM_Fiscal_Year__c = 2014, ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number'));
        insert RunningNo;
        childAA.ASI_CRM_Account__c=account_outlet.Id;
        update childAA;
             
            //***creat event*** /
        ASI_MFM_Event__c new_event = new ASI_MFM_Event__c(
            //*********** MODIFIED BY GDT
            //ASI_MFM_Start_Date__c=Date.valueof('2014-04-04'),               //Start date
            ASI_MFM_Start_Date__c=StartDate,               //Start date
            //***********
            recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Event__cASI_MFM_CN_Event'),          
            Name='new event',                                               //Event Name
            ASI_MFM_Status__c='On Going',                                   //Status
            ASI_MFM_Mechanics__c='abcdefg',                                 //Mechanics
ASI_MFM_Key_Event_Type_Budget_Share__c = 100,
            ASI_MFM_Sub_Event_Type__c = 'Thematic Promotion',                                 //Event Type
            ASI_MFM_Event_Type__c = 'Image/Brand Driven Event',                            //Key Event Type
            ASI_MFM_Objective__c='xyzabc',                                  //Objective       
            ASI_MFM_Agency_Team__c='Team A',                                //mAgency Team
            CurrencyIsoCode='',                                             //Currency
            ASI_MFM_Agency__c=account_outlet.id                             //Agency
            
        );
        insert new_event;       
        
        ASI_MFM_Event_Outlet__c eventoutlet = new ASI_MFM_Event_Outlet__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Event_Outlet__cASI_MFM_CN_Event_Outlet') ,
            ASI_MFM_Event_Type__c='Image/Brand Driven Event', ASI_MFM_Event__c=new_event.id,ASI_MFM_Outlet__c=account_outlet.id,
            //ASI_MFM_Beginning_Date__c=date.newInstance(2014,1,1),ASI_MFM_End_Date__c =date.newInstance(2014,1,2),ASI_MFM_Wave__c='1',ASI_CRM_CN_EvaluationCreated__c = false);
            ASI_MFM_Beginning_Date__c=StartDate,ASI_MFM_End_Date__c =StartDate.addmonths(1),ASI_MFM_Wave__c='1',ASI_CRM_CN_EvaluationCreated__c = false);             
        insert eventoutlet;    


        test.startTest();        
        {
            ASI_CRM_CN_EventTaskCalendar_Controller.event e = new ASI_CRM_CN_EventTaskCalendar_Controller.event();
            //ASI_CRM_CN_EventTaskCalendar_Controller.getEventData(String.valueOf(date.newInstance(2014,1,1)));
            ASI_CRM_CN_EventTaskCalendar_Controller.getEventData(String.valueOf(StartDate));
        }        
        test.stopTest();
    }

}