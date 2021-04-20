@isTest
private class ASI_CRM_CN_Event_Test {
    
    static testMethod void ASI_CRM_CN_EventSubBrand_TriggerClass_TEST() {
        //***creat account** / 
        Account account_outlet = new Account(
            Name='TestAcc',
            recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'),
            ASI_MFM_Customer_Supplier_Number__c='123',
            ASI_MFM_Customer_Supplier_Name__c='SupplierName'
        );
        insert account_outlet;
        
        ASI_HK_CRM_Running_Number__c RunningNo = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_MFM_CN_Event', ASI_HK_CRM_Running_Number__c = 1, ASI_HK_CRM_Format__c = 'Event-{YY}{000000}', ASI_HK_CRM_Fiscal_Year__c = 2014, ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7);
		insert RunningNo;
        //***creat event*** /
        ASI_MFM_Event__c new_event = new ASI_MFM_Event__c(
            ASI_MFM_Start_Date__c=Date.valueof('2014-01-01'),               //Start date
            recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Event__cASI_MFM_CN_Event'),         
            Name='new event',                                               //Event Name
            ASI_MFM_Status__c='On Going',                                   //Status
            ASI_MFM_Mechanics__c='abcdefg',                                 //Mechanics
ASI_MFM_Key_Event_Type_Budget_Share__c = 100,
            ASI_MFM_Sub_Event_Type__c = 'Thematic Promotion',                                 //Event Type
            ASI_MFM_Event_Type__c = 'Image/Brand Driven Event', 
            ASI_MFM_Objective__c='xyzabc',                                  //Objective       
            ASI_MFM_Agency_Team__c='Team A',                                //mAgency Team
            CurrencyIsoCode='',                                             //Currency
            ASI_MFM_Agency__c=account_outlet.id                             //Agency
            
        );
        insert new_event;
    
        //***creat brand*** /
        ASI_MFM_Brand__c new_brand = new ASI_MFM_Brand__c(
            name='brandname',
            recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_CN_Brand')
        );
        insert new_brand; 
        
        //***creat sub brand*** /        
        list<ASI_MFM_Sub_brand__c> listSubBrands = new list<ASI_MFM_Sub_brand__c>();
        listSubBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1', ASI_MFM_Active_for_MFM__c=TRUE, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        listSubBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2', ASI_MFM_Active_for_MFM__c=TRUE, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        insert listSubBrands;
        
        //***creat event sub brand*** /        
        list<ASI_MFM_Event_Sub_Brand__c> listEventSubBrands = new list<ASI_MFM_Event_Sub_brand__c>();
        listEventSubBrands.add(new ASI_MFM_Event_Sub_Brand__c(ASI_MFM_Event__c=new_event.Id, ASI_MFM_Sub_Brand__c=listSubBrands[0].Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Event_Sub_Brand__cASI_MFM_CN_Event_Sub_Brand')));
        listEventSubBrands.add(new ASI_MFM_Event_Sub_Brand__c(ASI_MFM_Event__c=new_event.Id, ASI_MFM_Sub_Brand__c=listSubBrands[1].Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Event_Sub_Brand__cASI_MFM_CN_Event_Sub_Brand')));        
        insert listEventSubBrands;
        
        test.startTest();        
        {
            map<Id, ASI_MFM_Event_Sub_Brand__c> oldMap = new map<Id, ASI_MFM_Event_Sub_Brand__c>();
            for(ASI_MFM_Event_Sub_Brand__c eventSubBrand :listEventSubBrands)
                oldMap.put(eventSubBrand.Id, eventSubBrand);
                
            ASI_CRM_CN_EventSubBrand_TriggerClass.routineAfterInsert(listEventSubBrands, oldMap);
            ASI_CRM_CN_EventSubBrand_TriggerClass.routineAfterUpdate(listEventSubBrands, oldMap);
            ASI_CRM_CN_EventSubBrand_TriggerClass.routineAfterDelete(listEventSubBrands, oldMap);
            delete listEventSubBrands;
        }        
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_EventSubChannel_TriggerClass_TEST() {
        //***creat account** / 
        Account account_outlet = new Account(
            Name='TestAcc',
            recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'),
            ASI_MFM_Customer_Supplier_Number__c='123',
            ASI_MFM_Customer_Supplier_Name__c='SupplierName'
        );
        insert account_outlet;
        ASI_HK_CRM_Running_Number__c RunningNo = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_MFM_CN_Event', ASI_HK_CRM_Running_Number__c = 1, ASI_HK_CRM_Format__c = 'Event-{YY}{000000}', ASI_HK_CRM_Fiscal_Year__c = 2014, ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7);
		insert RunningNo;
        //***creat event*** /
        ASI_MFM_Event__c new_event = new ASI_MFM_Event__c(
            ASI_MFM_Start_Date__c=Date.valueof('2014-01-01'),               //Start date
            recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Event__cASI_MFM_CN_Event'),          
            Name='new event',                                               //Event Name
            ASI_MFM_Status__c='On Going',                                   //Status
            ASI_MFM_Mechanics__c='abcdefg',                                 //Mechanics
ASI_MFM_Key_Event_Type_Budget_Share__c = 100,
            ASI_MFM_Sub_Event_Type__c = 'Thematic Promotion',                                 //Event Type
            ASI_MFM_Event_Type__c = 'Image/Brand Driven Event', 
            ASI_MFM_Objective__c='xyzabc',                                  //Objective       
            ASI_MFM_Agency_Team__c='Team A',                                //mAgency Team
            CurrencyIsoCode='',                                             //Currency
            ASI_MFM_Agency__c=account_outlet.id                             //Agency
            
        );
        insert new_event;

        //***creat sub channel*** /        
        list<ASI_MFM_Sub_Channel__c> listSubChannels = new list<ASI_MFM_Sub_Channel__c>();
        listSubChannels.add(new ASI_MFM_Sub_Channel__c(Name='sub channel',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_MFM_CN_Sub_Channel'),ASI_MFM_Channel__c='channel'));
        listSubChannels.add(new ASI_MFM_Sub_Channel__c(Name='sub channel2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_MFM_CN_Sub_Channel'),ASI_MFM_Channel__c='channel'));
        insert listSubChannels;

        //***creat event sub channel*** /        
        list<ASI_MFM_Event_Sub_Channel__c> listEventSubChannels = new list<ASI_MFM_Event_Sub_Channel__c>();
        listEventSubChannels.add(new ASI_MFM_Event_Sub_Channel__c(ASI_MFM_Event__c=new_event.Id, ASI_MFM_Sub_Channel__c=listSubChannels[0].Id));
        listEventSubChannels.add(new ASI_MFM_Event_Sub_Channel__c(ASI_MFM_Event__c=new_event.Id, ASI_MFM_Sub_Channel__c=listSubChannels[1].Id));        
        insert listEventSubChannels;

        test.startTest();        
        {
            map<Id, ASI_MFM_Event_Sub_Channel__c> oldMap = new map<Id, ASI_MFM_Event_Sub_Channel__c>();
            for(ASI_MFM_Event_Sub_Channel__c eventSubChannel :listEventSubChannels)
                oldMap.put(eventSubChannel.Id, eventSubChannel);
                
            ASI_CRM_CN_EventSubChannel_TriggerClass.routineAfterInsert(listEventSubChannels, oldMap);
            ASI_CRM_CN_EventSubChannel_TriggerClass.routineAfterUpdate(listEventSubChannels, oldMap);
            ASI_CRM_CN_EventSubChannel_TriggerClass.routineAfterDelete(listEventSubChannels, oldMap);
            delete listEventSubChannels;

        }        
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_UpdateParentfromChild_TEST() {
        //***creat account** / 
        Account account_outlet = new Account(
            Name='TestAcc',
            recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'),
            ASI_MFM_Customer_Supplier_Number__c='123',
            ASI_MFM_Customer_Supplier_Name__c='SupplierName'
        );
        insert account_outlet;
        ASI_HK_CRM_Running_Number__c RunningNo = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_MFM_CN_Event', ASI_HK_CRM_Running_Number__c = 1, ASI_HK_CRM_Format__c = 'Event-{YY}{000000}', ASI_HK_CRM_Fiscal_Year__c = 2014, ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7);
		insert RunningNo;
        //***creat event*** /
        ASI_MFM_Event__c new_event = new ASI_MFM_Event__c(
            ASI_MFM_Start_Date__c=Date.valueof('2014-01-01'),               //Start date
            recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Event__cASI_MFM_CN_Event'),          
            Name='new event',                                               //Event Name
            ASI_MFM_Status__c='On Going',                                   //Status
            ASI_MFM_Mechanics__c='abcdefg',                                 //Mechanics
ASI_MFM_Key_Event_Type_Budget_Share__c = 100,
            ASI_MFM_Sub_Event_Type__c = 'Thematic Promotion',                                 //Event Type
            ASI_MFM_Event_Type__c = 'Image/Brand Driven Event', 
            ASI_MFM_Objective__c='xyzabc',                                  //Objective       
            ASI_MFM_Agency_Team__c='Team A',                                //mAgency Team
            CurrencyIsoCode='',                                             //Currency
            ASI_MFM_Agency__c=account_outlet.id                             //Agency
            
        );
        insert new_event;

       
        //***creat brand*** /
        ASI_MFM_Brand__c new_brand = new ASI_MFM_Brand__c(
            name='brandname',
            recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_CN_Brand')
        );
        insert new_brand; 
        
        //***creat sub brand*** /        
        list<ASI_MFM_Sub_brand__c> listSubBrands = new list<ASI_MFM_Sub_brand__c>();
        listSubBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1', ASI_MFM_Active_for_MFM__c=TRUE, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        listSubBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2', ASI_MFM_Active_for_MFM__c=TRUE, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        insert listSubBrands;
        
        //***creat event sub brand*** /        
        list<ASI_MFM_Event_Sub_Brand__c> listEventSubBrands = new list<ASI_MFM_Event_Sub_brand__c>();
        listEventSubBrands.add(new ASI_MFM_Event_Sub_Brand__c(ASI_MFM_Event__c=new_event.Id, ASI_MFM_Sub_Brand__c=listSubBrands[0].Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Event_Sub_Brand__cASI_MFM_CN_Event_Sub_Brand')));
        listEventSubBrands.add(new ASI_MFM_Event_Sub_Brand__c(ASI_MFM_Event__c=new_event.Id, ASI_MFM_Sub_Brand__c=listSubBrands[1].Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Event_Sub_Brand__cASI_MFM_CN_Event_Sub_Brand')));        
        insert listEventSubBrands;

         //***creat sub channel*** /        
        list<ASI_MFM_Sub_Channel__c> listSubChannels = new list<ASI_MFM_Sub_Channel__c>();
        listSubChannels.add(new ASI_MFM_Sub_Channel__c(Name='sub channel',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_MFM_CN_Sub_Channel'),ASI_MFM_Channel__c='channel'));
        listSubChannels.add(new ASI_MFM_Sub_Channel__c(Name='sub channel2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_MFM_CN_Sub_Channel'),ASI_MFM_Channel__c='channel'));
        insert listSubChannels;

        //***creat event sub channel*** /        
        list<ASI_MFM_Event_Sub_Channel__c> listEventSubChannels = new list<ASI_MFM_Event_Sub_Channel__c>();
        listEventSubChannels.add(new ASI_MFM_Event_Sub_Channel__c(ASI_MFM_Event__c=new_event.Id, ASI_MFM_Sub_Channel__c=listSubChannels[0].Id));
        listEventSubChannels.add(new ASI_MFM_Event_Sub_Channel__c(ASI_MFM_Event__c=new_event.Id, ASI_MFM_Sub_Channel__c=listSubChannels[1].Id));        
        insert listEventSubChannels;

        test.startTest();        
        {
            map<Id, ASI_MFM_Event_Sub_Brand__c> oldMap_SubBrand = new map<Id, ASI_MFM_Event_Sub_Brand__c>();
            for(ASI_MFM_Event_Sub_Brand__c eventSubBrand :listEventSubBrands)
                oldMap_SubBrand.put(eventSubBrand.Id, eventSubBrand);

            map<Id, ASI_MFM_Event_Sub_Channel__c> oldMap_SubChannel = new map<Id, ASI_MFM_Event_Sub_Channel__c>();
            for(ASI_MFM_Event_Sub_Channel__c eventSubChannel :listEventSubChannels)
                oldMap_SubChannel.put(eventSubChannel.Id, eventSubChannel);
                
            ASI_CRM_CN_UpdateParentfromChild uef = new ASI_CRM_CN_UpdateParentfromChild();            
            
            uef.UpdateEventSubBrandName(listEventSubBrands);
            uef.UpdateEventSubChannelName(listEventSubChannels);            

            delete listSubBrands[0];
            delete listSubBrands[1];
            uef.UpdateEventSubBrandName(listEventSubBrands);
            
            delete listSubChannels[0];
            delete listSubChannels[1];
            uef.UpdateEventSubChannelName(listEventSubChannels);

            
        }        
        test.stopTest();
    }
    
    
    static testMethod void ASI_CRM_CN_EventEvaluation_Schd_TEST() {
        ASI_CRM_CN_EventEvaluation_Schd schdCls = new ASI_CRM_CN_EventEvaluation_Schd();
        test.starttest();
        String sch = '0 0 23 * * ?';
        system.schedule('EventEvaluation', sch, schdCls);
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_EventEvaluation_Batch_TEST() {  
        User tempU = [select id from user where CompanyName = 'Pernod Ricard China' limit 1];
        //***creat account** / 
        Account account_outlet = new Account(
            Name='TestAcc',
            recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'),
            ASI_MFM_Customer_Supplier_Number__c='123',
            ASI_MFM_Customer_Supplier_Name__c='SupplierName'
        );
        insert account_outlet;
        
        Account account_outlet2 = new Account(
            Name='TestAcc2',
            recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'),
            ASI_MFM_Customer_Supplier_Number__c='1232',
            ASI_MFM_Customer_Supplier_Name__c='SupplierName2'
        );
        insert account_outlet2;
        
        ASI_HK_CRM_Running_Number__c RunningNo = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_MFM_CN_Event', ASI_HK_CRM_Running_Number__c = 1, ASI_HK_CRM_Format__c = 'Event-{YY}{000000}', ASI_HK_CRM_Fiscal_Year__c = 2014, ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7);
		insert RunningNo;
        //***create account additionalfield ***
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(name = 'testDivision', ASI_CRM_CN_RTMK__c = tempU.id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name = 'testarea', ASI_CRM_Division__c = division.id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_Area__c = area.id,ASI_CRM_CN_City_Code__c='TESTCITY');
        ASI_CRM_City__c city2 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY2');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='testChannel',ASI_CRM_CN_On_Off__c='On');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(Name='testSubChannel',ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Brand_T1_Group__c g = new ASI_CRM_CN_Brand_T1_Group__c(Name='TEST');
        insert g;        
        
        
        
        ASI_CRM_AccountsAdditionalField__c childAA =  new ASI_CRM_AccountsAdditionalField__c(OwnerId = tempU.id, ASI_CRM_CN_PG_Head__c = tempU.id, Name='TEST3', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_Account__c=account_outlet.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name);
        insert childAA;
        
        childAA.ASI_CRM_Account__c=account_outlet.Id;
        update childAA;
        
        ASI_CRM_AccountsAdditionalField__c childAA2 =  new ASI_CRM_AccountsAdditionalField__c(OwnerId = tempU.id, Name='TEST4', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_Account__c=account_outlet2.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Brand__c=g.Name);
        insert childAA2;
        
        system.debug('childAA: ' + childAA.ASI_CRM_Account__c);
        
        //***creat event*** /
        ASI_MFM_Event__c new_event = new ASI_MFM_Event__c(
            ASI_MFM_Proposed_Outet_Coverage_Total__c = '100',
            ASI_MFM_Key_Event_Type_Budget_Share__c = 100,
            ASI_MFM_CN_After_End_Date_Alert__c = FALSE,
            ASI_MFM_CN_Before_10_Day_Alert__c = FALSE,
            ASI_MFM_Sub_Event_Type__c = 'Thematic Promotion',                                 //Event Type
            ASI_MFM_Event_Type__c = 'Image/Brand Driven Event',  
            ASI_MFM_End_Date__c = date.today().addDays(10),
            ASI_MFM_Start_Date__c=Date.today().addDays(1),               //Start date
            recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Event__cASI_MFM_CN_Event'),          
            Name='new event',                                               //Event Name
            ASI_MFM_Status__c='On Going',                                   //Status
            ASI_MFM_Mechanics__c='abcdefg',                                 //Mechanics                                      
            ASI_MFM_Objective__c='xyzabc',                                  //Objective       
            ASI_MFM_Agency_Team__c='Team A',                                //mAgency Team
            CurrencyIsoCode='',                                             //Currency
            ASI_MFM_Agency__c=account_outlet.id                             //Agency
            
        );
        insert new_event;
        
        ASI_MFM_Event__c new_event2 = new ASI_MFM_Event__c(
            ASI_MFM_Proposed_Outet_Coverage_Total__c = '100',
            ASI_MFM_Key_Event_Type_Budget_Share__c = 100,
            ASI_MFM_CN_After_End_Date_Alert__c = FALSE,
            ASI_MFM_CN_Before_10_Day_Alert__c = FALSE,
            ASI_MFM_Sub_Event_Type__c = 'Thematic Promotion',                                 //Event Type
            ASI_MFM_Event_Type__c = 'Image/Brand Driven Event',  
            ASI_MFM_End_Date__c = date.today().addDays(-1),
            ASI_MFM_Start_Date__c=Date.today().addDays(-10),               //Start date
            recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Event__cASI_MFM_CN_Event'),          
            Name='new event',                                               //Event Name
            ASI_MFM_Status__c='On Going',                                   //Status
            ASI_MFM_Mechanics__c='abcdefg',                                 //Mechanics                                      
            ASI_MFM_Objective__c='xyzabc',                                  //Objective       
            ASI_MFM_Agency_Team__c='Team A',                                //mAgency Team
            CurrencyIsoCode='',                                             //Currency
            ASI_MFM_Agency__c=account_outlet2.id                             //Agency
            
        );
        insert new_event2;   
        
        ASI_MFM_Event_Outlet__c eventoutlet = new ASI_MFM_Event_Outlet__c(ASI_MFM_CN_Customer__c = childAA.id,recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Event_Outlet__cASI_MFM_CN_Event_Outlet') ,
            ASI_MFM_Event_Type__c='Image/Brand Driven Event', ASI_MFM_Event__c=new_event.id,ASI_MFM_Outlet__c=account_outlet.id,
            ASI_MFM_Beginning_Date__c=date.today().addDays(1),ASI_MFM_End_Date__c =date.today().addDays(7),ASI_MFM_Wave__c='1',ASI_CRM_CN_EvaluationCreated__c = false);            
        insert eventoutlet;    
		
        ASI_MFM_Event_Outlet__c eventoutletabc = new ASI_MFM_Event_Outlet__c(ASI_MFM_CN_Customer__c = childAA2.id,recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Event_Outlet__cASI_MFM_CN_Event_Outlet') ,
                                                                             ASI_MFM_Event_Type__c='Thematic Promotion', ASI_MFM_Event__c=new_event2.id,ASI_MFM_Outlet__c = childAA2.ASI_CRM_Account__c,
                                                                             ASI_MFM_Beginning_Date__c=date.today().adddays(-3),ASI_MFM_End_Date__c =date.today().adddays(-1),ASI_MFM_Wave__c='1',ASI_CRM_CN_EvaluationCreated__c = false);
        insert eventoutletabc;
        
        eventoutletabc.ASI_MFM_Outlet__c = account_outlet.id;
        update eventoutletabc;
        
        ASI_CRM_CN_EventEvaluation_Batch bc = new ASI_CRM_CN_EventEvaluation_Batch();        
        Test.startTest();
        Database.executeBatch(bc, 200);
        Test.stopTest();
    }    
}