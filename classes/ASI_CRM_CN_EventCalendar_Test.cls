@isTest
global class ASI_CRM_CN_EventCalendar_Test {
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
        
        list<Event> es = new list<Event>();
        for(ASI_CRM_AccountsAdditionalField__c a2 :listAA) 
            es.add(new Event(Subject='TEST', WhatId=a2.Id, StartDateTime=datetime.newInstance(2014,1,1), EndDateTime=datetime.newInstance(2014,1,2), RecordTypeId=Global_RecordTypeCache.getRtId('EventASI_CRM_CN_Call_Plan')));
        insert es;
        
        list<ASI_MFM_Event__c> evs = new list<ASI_MFM_Event__c>();
        ASI_HK_CRM_Running_Number__c RunningNo = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_MFM_CN_Event', ASI_HK_CRM_Running_Number__c = 1, ASI_HK_CRM_Format__c = 'Event-{YY}{000000}', ASI_HK_CRM_Fiscal_Year__c = 2014, ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number'));
		insert RunningNo;
        for(Account acc :listA) 
            evs.add(new ASI_MFM_Event__c(ASI_MFM_Key_Event_Type_Budget_Share__c = 100,
            ASI_MFM_Sub_Event_Type__c = 'Thematic Promotion',                                 //Event Type
            ASI_MFM_Event_Type__c = 'Image/Brand Driven Event',   
            ASI_MFM_Start_Date__c=Date.valueof('2014-01-01'),               //Start date
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
                ASI_MFM_Beginning_Date__c=date.newInstance(2014,1,1),
                ASI_MFM_End_Date__c=date.newInstance(2014,1,2),  
                ASI_MFM_Event_Type__c='Image/Brand Driven Event',
                ASI_MFM_Event__c=ev.Id,
                ASI_MFM_Wave__c='TEST',
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Event_Outlet__cASI_MFM_CN_Event_Outlet')));
        insert eos;
        
        ASI_CRM_CN_Brand_Group__c tmpBrandGroup = new ASI_CRM_CN_Brand_Group__c(Name = 'Test');
        
        insert tmpBrandGroup;
        
        test.startTest();
        
        {
            ASI_CRM_CN_EventCalendar.CalendarEvent ce = new ASI_CRM_CN_EventCalendar.CalendarEvent();
            ce.id = ce.id;
            ce.text = ce.text;
            ce.start_date = ce.start_date;
            ce.end_date = ce.end_date;
            ce.details = ce.details;
            ce.outletId = ce.outletId;
            ce.css = ce.css;
        }
        
        {
            ASI_CRM_CN_EventCalendar.CalendarEvents ce = new ASI_CRM_CN_EventCalendar.CalendarEvents();
            ce.wholelist = ce.wholelist;
        }  
        
        ASI_CRM_CN_EventCalendar con = new ASI_CRM_CN_EventCalendar();
        List<String> user = con.getUsers();
        ASI_CRM_CN_EventCalendar.selectedBrand = 'All';
        ASI_CRM_CN_EventCalendar.selectedChannel = 'All';
        ASI_CRM_CN_EventCalendar.selectedDivision = 'All';
        ASI_CRM_CN_EventCalendar.selectedEventType = 'All';
        ASI_CRM_CN_EventCalendar.selectedRegion = 'All';
        ASI_CRM_CN_EventCalendar.selectedSubBrand = 'All';
        con.setUsers(user);
        con.getFullEventType();
        con.getFullchannel();
        con.getfullBrand();
        con.getfullDivision();
        con.getFullRegion();
        con.getSubBrandItems();
        //con.getUserItems();
        
        ASI_CRM_CN_EventCalendar.getEventData('','','','','','','All','2014-01-01');
        ASI_CRM_CN_EventCalendar.getEventData('','','','','','','','2014-01-01');
        
        delete es;
        
        test.stopTest();
    }
}