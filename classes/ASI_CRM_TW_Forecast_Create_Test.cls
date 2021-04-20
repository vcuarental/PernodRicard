@isTest
public class ASI_CRM_TW_Forecast_Create_Test {
    static Id checkRecordType(string strsobject, string rt_name){
        id RT_id;
        List<recordType> sobjectlist = Global_RecordTypeCache.getRtList(strsobject);
            for (recordtype pl : sobjectlist ){
                if (pl.developername == rt_name)
                RT_id = pl.id;
            }
            system.debug('RT_id: ' + RT_id);
            return RT_id;
            
    }
    static testMethod void batchCreateTest() {
        // recordType
        Id rtIdForecast  = Schema.SObjectType.ASI_Forecast__c.getRecordTypeInfosByName().get('TW Forecast').getRecordTypeId();
        Id rtIdItemGroup = Schema.SObjectType.ASI_MFM_Item_Group__c.getRecordTypeInfosByName().get('TW Item Group').getRecordTypeId();
        ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(Name='tmp00',
                                                                    ASI_MFM_Item_Group_Code__c='tmp00',
                                                                    ASI_CRM_Size_ml__c=500,
                                                                    ASI_CRM_CN_pack__c='10',
                                                                    ASI_CRM_Active__c = true,
                                                                    ASI_CRM_Applied_To_Forecast__c='CVS'
                                                                   );
        itemGroup.RecordTypeId=rtIdItemGroup;
		insert itemGroup;
        
        // insert channel sub-channel
        Id rtIdChannel   = Schema.SObjectType.ASI_CRM_CN_Channel__c.getRecordTypeInfosByName().get('TW Channel').getRecordTypeId(); 
        ASI_CRM_CN_Channel__c  ch = new ASI_CRM_CN_Channel__c(Name='CVS',
                                                              ASI_CRM_CN_Channel_Code__c ='CVS',
                                                              RecordTypeId=rtIdChannel
                                                             );
        insert ch;
        Id rtIdSubChannel= Schema.SObjectType.ASI_MFM_Sub_Channel__c.getRecordTypeInfosByName().get('TW Sub-Channel').getRecordTypeId(); 
        ASI_MFM_Sub_Channel__c  subch = new ASI_MFM_Sub_Channel__c (Name='CVS 7-11',
                                                                    ASI_CRM_CN_Sub_Channel_Code__c = 'CVS_7-11',
                                                                    ASI_CRM_CN_Sub_Channel_Chi_Name__c = '便利商店統一超商',
                                                                    ASI_CRM_CN_Channel__c = ch.id,
																	RecordTypeId=rtIdSubChannel);
        insert subch;
        
        Id custRTID = checkRecordType('Account','ASI_CRM_TW_Outlet');
       	Account customer = new Account(RecordTypeId=custRTID, name='7-11_元大', ASI_HK_CRM_Channel__c = 'CVS',ASI_HK_CRM_JDE_Account_Number__c='123');
        insert customer;
        
        ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(name='7-11',
                                                                           ASI_CRM_Sub_Channel__c = subch.id,
                                                                           ASI_TH_CRM_Code__c  = 'TW_CSE');
        insert outletType;
        
        Id rtIdAddCust = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName().get('Key Account (TW)').getRecordTypeId(); 
        system.debug('rtIdAddCust : ' + rtIdAddCust);
        ASI_CRM_AccountsAdditionalField__c addCust = new ASI_CRM_AccountsAdditionalField__c(name='7-11_元大',
                                                                                            ASI_CRM_Is_SCA_Customer__c  = true,
                                                                                            ASI_CRM_Account__c = customer.id,
                                                                                            ASI_CRM_Channel__c = ch.id,
                                                                                            ASI_CRM_CN_Sub_Channel__c = subch.id,
                                                                                            ASI_TH_CRM_OutletType__c = outletType.id,
                                                                                            RecordTypeId = rtIdAddCust,
                                                                                            ASI_CRM_Region__c = 'CVS');
        insert addCust;
        
        //------ create users -------
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User user = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com');
        listUser.add(user);
        insert listUser;
        
        test.startTest();
        System.runAs(user) {
            
            id tmp2 = ASI_CRM_TW_Forecast_Util.getForecastReportId;
            tmp2 = ASI_CRM_TW_Forecast_Util.getBudgetReportId;
            
            EmailTemplate et = new EmailTemplate();  
            et.isActive = true;  
            et.Name = 'testTemplate';  
            et.DeveloperName = 'testTemplate';  
            et.TemplateType = 'text';  
            et.FolderId = UserInfo.getUserId();  
            et.Body = 'Body'; 
            et.Subject = 'Subject';
            et.HtmlValue = '<html><table>Hello</table></html>';
            insert et; 
            
            Id batchInstanceId = Database.executeBatch(new ASI_Forecast_TW_BatchCreate('Forecast',new Set<Id>(), '2018-01'), 10);
            batchInstanceId = Database.executeBatch(new ASI_Forecast_TW_BatchCreate('Budget',new Set<Id>(), '2018-01'), 10);
            ASI_Forecast_TW_BatchCreate tmp = new ASI_Forecast_TW_BatchCreate('Forecast',new Set<Id>(), '2018-01');
            tmp.execute(null, new List<ASI_Forecast__c>());
        }
        test.stopTest();
    }
    static testMethod void userForecastTest() {
        test.startTest();

        
        // insert channel sub-channel
        Id rtIdChannel   = Schema.SObjectType.ASI_CRM_CN_Channel__c.getRecordTypeInfosByName().get('TW Channel').getRecordTypeId(); 
        ASI_CRM_CN_Channel__c  ch = new ASI_CRM_CN_Channel__c(Name='CVS',
                                                              ASI_CRM_CN_Channel_Code__c ='CVS',
                                                              RecordTypeId=rtIdChannel
                                                             );
        insert ch;
        Id rtIdSubChannel= Schema.SObjectType.ASI_MFM_Sub_Channel__c.getRecordTypeInfosByName().get('TW Sub-Channel').getRecordTypeId(); 
        ASI_MFM_Sub_Channel__c  subch = new ASI_MFM_Sub_Channel__c (Name='CVS 7-11',
                                                                    ASI_CRM_CN_Sub_Channel_Code__c = 'CVS_7-11',
                                                                    ASI_CRM_CN_Sub_Channel_Chi_Name__c = '便利商店統一超商',
                                                                    ASI_CRM_CN_Channel__c = ch.id,
																	RecordTypeId=rtIdSubChannel);
        insert subch;
                
        //------ create users -------
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User admin = new User(Alias = 'standt', Email='dev.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev.pra@introv.com');
        listUser.add(admin);
        User user = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com');
        listUser.add(user);
        User user2 = new User(Alias = 'standt', Email='dev2.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev2.pra@introv.com');
        listUser.add(user2);
        User user3 = new User(Alias = 'standt', Email='dev3.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev3.pra@introv.com');
        listUser.add(user3);
        User user4 = new User(Alias = 'standt', Email='dev4.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing4', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev4.pra@introv.com');
        listUser.add(user4);
        insert listUser;
        
        //insert mapping
        Id trIdChMap = Schema.SObjectType.ASI_Forecast_Channel_Map__c.getRecordTypeInfosByName().get('TW Forecast Channel Map').getRecordTypeId(); 
        ASI_Forecast_Channel_Map__c  chMap1 = new ASI_Forecast_Channel_Map__c(
            ASI_Forecast_Sub_Channel__c = subch.Id,
            ASI_Forecast_Region__c = 'CVS',
            ASI_Forecast_ChannelRegion_Manger__c = user.id,
            ASI_Forecast_National_Manager__c = user2.id
        );
        insert chMap1;
        

        
        System.runAs(user) {
            
            EmailTemplate et = new EmailTemplate();  
            et.isActive = true;  
            et.Name = 'testTemplate';  
            et.DeveloperName = 'testTemplate';  
            et.TemplateType = 'text';  
            et.FolderId = UserInfo.getUserId();  
            et.Body = 'Body'; 
            et.Subject = 'Subject';
            et.HtmlValue = '<html><table>Hello</table></html>';
            insert et; 
            
			ASI_CRM_TW_Forecast_Util.checkSkipApprovalBySubChId(new Set<Id>{ch.id});
            ASI_CRM_TW_Forecast_Util.getChannelItemMap(new Set<String>{'CVS'});
            
            ASI_CRM_TW_Forecast_Util.searchForecastApproverByChannelCode(new Set<String>{'CVS'});
            ASI_CRM_TW_Forecast_Util.searchForecastInputerByChannelCode(new Set<String>{'CVS'});
            ASI_CRM_TW_Forecast_Util.searchForecastItemGroupInputerByChannelCode(new Set<String>{'CVS'});
            ASI_CRM_TW_Forecast_Util.searchForecastApprovedInputerByChannelCode(new Set<String>{'CVS'});
            ASI_CRM_TW_Forecast_Util.searchBudgetApproverByChannelCode(new Set<String>{'CVS'});
            ASI_CRM_TW_Forecast_Util.searchBudgetInputerByChannelCode(new Set<String>{'CVS'});
            ASI_CRM_TW_Forecast_Util.searchBudgetApprovedInputerByChannelCode(new Set<String>{'CVS'});
            ASI_CRM_TW_Forecast_Util.sendForecastEmail(new List<String>{'pra.dev@introv.com'},'2018-01-01' , 'CVS', '', 'testTemplate', 'testTemplate');
            ASI_CRM_TW_Forecast_Util.searchSubChannelUserMapping();
			ASI_CRM_TW_Forecast_Util.searchChannelUserMapping();
        }
        test.stopTest();
    }
    
    static testMethod void retriveForecastTest() {
        test.startTest();
        
        // recordType
        Id rtIdForecast  = Schema.SObjectType.ASI_Forecast__c.getRecordTypeInfosByName().get('TW Forecast').getRecordTypeId();
        Id rtIdItemGroup = Schema.SObjectType.ASI_MFM_Item_Group__c.getRecordTypeInfosByName().get('TW Item Group').getRecordTypeId();
        ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(Name='tmp00',
                                                                    ASI_MFM_Item_Group_Code__c='tmp00',
                                                                    ASI_CRM_Size_ml__c=500,
                                                                    ASI_CRM_CN_pack__c='10',
                                                                    ASI_CRM_Active__c = true,
                                                                    ASI_CRM_Applied_To_Forecast__c='CVS'
                                                                   );
        itemGroup.RecordTypeId=rtIdItemGroup;
		insert itemGroup;
        
        // insert channel sub-channel
        Id rtIdChannel   = Schema.SObjectType.ASI_CRM_CN_Channel__c.getRecordTypeInfosByName().get('TW Channel').getRecordTypeId(); 
        ASI_CRM_CN_Channel__c  ch = new ASI_CRM_CN_Channel__c(Name='CVS',
                                                              ASI_CRM_CN_Channel_Code__c ='CVS',
                                                              RecordTypeId=rtIdChannel
                                                             );
        insert ch;
        Id rtIdSubChannel= Schema.SObjectType.ASI_MFM_Sub_Channel__c.getRecordTypeInfosByName().get('TW Sub-Channel').getRecordTypeId(); 
        ASI_MFM_Sub_Channel__c  subch = new ASI_MFM_Sub_Channel__c (Name='CVS 7-11',
                                                                    ASI_CRM_CN_Sub_Channel_Code__c = 'CVS_7-11',
                                                                    ASI_CRM_CN_Sub_Channel_Chi_Name__c = '便利商店統一超商',
                                                                    ASI_CRM_CN_Channel__c = ch.id,
																	RecordTypeId=rtIdSubChannel);
        insert subch;
        
        Id custRTID = checkRecordType('Account','ASI_CRM_TW_Outlet');
       	Account customer = new Account(RecordTypeId=custRTID, name='7-11_元大', ASI_HK_CRM_Channel__c = 'CVS',ASI_HK_CRM_JDE_Account_Number__c='123');
        insert customer;
        
        ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(name='7-11',
                                                                           ASI_CRM_Sub_Channel__c = subch.id,
                                                                           ASI_TH_CRM_Code__c  = 'TW_CSE');
        insert outletType;
        
        Id rtIdAddCust = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName().get('Key Account (TW)').getRecordTypeId(); 
        ASI_CRM_AccountsAdditionalField__c addCust = new ASI_CRM_AccountsAdditionalField__c(name='7-11_元大',
                                                                                            ASI_CRM_Is_SCA_Customer__c  = true,
                                                                                            ASI_CRM_Account__c = customer.id,
                                                                                            ASI_CRM_Channel__c = ch.id,
                                                                                            ASI_CRM_CN_Sub_Channel__c = subch.id,
                                                                                            ASI_TH_CRM_OutletType__c = outletType.id,
                                                                                            RecordTypeId=rtIdAddCust,
                                                                                            ASI_CRM_Region__c = 'CVS');
        insert addCust;
        String rtIdFHeader = checkRecordType('ASI_Forecast__c','ASI_Forecast_TW');        
		String rtIdFitem = checkRecordType('ASI_Forecast_Item__c','ASI_Forecast_TW_Item');        
        ASI_Forecast__c fheader = new ASI_Forecast__c(
            ASI_Forecast_Channel__c = ch.id,
            RecordTypeId=rtIdFHeader,
            ASI_Forecast_Sub_Channel__c = subch.id,
            ASI_CRM_Customer__c  = addCust.id,
            ASI_Forecast_Period_Date__c = System.today().toStartOfMonth(),
            ASI_Forecast_Status__c = 'Draft',
            ASI_Forecast_Type__c ='Forecast'
        );
        Date d1 = ASI_CRM_TW_Forecast_Util.CURR_MONTH_BUDGET;
        ASI_Forecast__c bheader = new ASI_Forecast__c(
            ASI_Forecast_Channel__c = ch.id,
            RecordTypeId=rtIdFHeader,
            ASI_Forecast_Sub_Channel__c = subch.id,
            ASI_CRM_Customer__c  = addCust.id,
            ASI_Forecast_Period_Date__c = Date.newInstance(d1.year(), 7, 1),
            ASI_Forecast_Status__c = 'Draft',
            ASI_Forecast_Type__c ='Budget'
        );
        insert new List<ASI_Forecast__c>{fheader,bheader};
        ASI_Forecast_Item__c fitem = new ASI_Forecast_Item__c(
            ASI_Forecast__c = fheader.id,
            RecordTypeId=rtIdFitem,
            ASI_Forecast_Item_Group__c = itemgroup.id,
            ASI_Forecast_P1__c=10, ASI_Forecast_P2__c=20, ASI_Forecast_P3__c=30,
            ASI_Forecast_P4__c=40, ASI_Forecast_P5__c=50, ASI_Forecast_P6__c=60,
            ASI_Forecast_P7__c=40, ASI_Forecast_P8__c=50, ASI_Forecast_P9__c=60,
            ASI_Forecast_P10__c=40, ASI_Forecast_P11__c=50, ASI_Forecast_P12__c=60
        );
        ASI_Forecast_Item__c  bitem = new ASI_Forecast_Item__c(
            ASI_Forecast__c = bheader.id,
            RecordTypeId=rtIdFitem,
            ASI_Forecast_Item_Group__c = itemgroup.id,
            ASI_Forecast_P1__c=10, ASI_Forecast_P2__c=20, ASI_Forecast_P3__c=30,
            ASI_Forecast_P4__c=40, ASI_Forecast_P5__c=50, ASI_Forecast_P6__c=60,
            ASI_Forecast_P7__c=40, ASI_Forecast_P8__c=50, ASI_Forecast_P9__c=60,
            ASI_Forecast_P10__c=40, ASI_Forecast_P11__c=50, ASI_Forecast_P12__c=60
        );
        insert new List<ASI_Forecast_Item__c>{fitem,bitem};
        
        //------ create users -------
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User user = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com');
        listUser.add(user);
        insert listUser;

        System.runAs(user) {
            /*
            ASI_Forecast__c[] bList = ASI_CRM_TW_Forecast_Create.createBudgetHeader();
            ASI_Forecast__c[] fList = ASI_CRM_TW_Forecast_Create.createForecastHeader();
            Set<id> bidSet = new Set<Id>();
            Set<id> fidSet = new Set<Id>();
            for(ASI_Forecast__c f :bList) { bidSet.add(f.id); }
            for(ASI_Forecast__c f :fList) { fidSet.add(f.id); }
            ASI_CRM_TW_Forecast_Create.insertForecastItem(bidSet);
            ASI_CRM_TW_Forecast_Create.insertForecastItem(fidSet);
            if(fList.size() > 0) { ASI_CRM_TW_Forecast_Create.forecastSetToDraft(fList.get(0).id); }
            */
            ASI_CRM_TW_Forecast_Create.forecastSetToDraft(fheader.id);
//            Date d1 = ASI_CRM_TW_Forecast_Util.CURR_MONTH_BUDGET;
            Date d2 = ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST;
            ASI_CRM_TW_Forecast_Util.retrieveBudgetSummary(new Set<Id>{ch.id},new Set<Id>{subch.id},new Set<String>{'CVS'});
            ASI_CRM_TW_Forecast_Util.retrieveBudgetSummaryForForecast(new Set<Id>{ch.id},new Set<Id>{subch.id},new Set<String>{'CVS'});

        }
        test.stopTest();
    }
    
    static testMethod void utilForecastTest() {
        // recordType
        Id rtIdForecast  = Schema.SObjectType.ASI_Forecast__c.getRecordTypeInfosByName().get('TW Forecast').getRecordTypeId();
        Id rtIdItemGroup = Schema.SObjectType.ASI_MFM_Item_Group__c.getRecordTypeInfosByName().get('TW Item Group').getRecordTypeId();
        ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(Name='tmp00',
                                                                    ASI_MFM_Item_Group_Code__c='tmp00',
                                                                    ASI_CRM_Size_ml__c=500,
                                                                    ASI_CRM_CN_pack__c='10',
                                                                    ASI_CRM_Active__c = true,
                                                                    ASI_CRM_Applied_To_Forecast__c='CVS'
                                                                   );
        itemGroup.RecordTypeId=rtIdItemGroup;
		insert itemGroup;
        
        // insert channel sub-channel
        Id rtIdChannel   = Schema.SObjectType.ASI_CRM_CN_Channel__c.getRecordTypeInfosByName().get('TW Channel').getRecordTypeId(); 
        ASI_CRM_CN_Channel__c  ch = new ASI_CRM_CN_Channel__c(Name='CVS',
                                                              ASI_CRM_CN_Channel_Code__c ='CVS',
                                                              RecordTypeId=rtIdChannel
                                                             );
        insert ch;
        Id rtIdSubChannel= Schema.SObjectType.ASI_MFM_Sub_Channel__c.getRecordTypeInfosByName().get('TW Sub-Channel').getRecordTypeId(); 
        ASI_MFM_Sub_Channel__c  subch = new ASI_MFM_Sub_Channel__c (Name='CVS 7-11',
                                                                    ASI_CRM_CN_Sub_Channel_Code__c = 'CVS_7-11',
                                                                    ASI_CRM_CN_Sub_Channel_Chi_Name__c = '便利商店統一超商',
                                                                    ASI_CRM_CN_Channel__c = ch.id,
																	RecordTypeId=rtIdSubChannel);
        insert subch;
        
        Id custRTID = checkRecordType('Account','ASI_CRM_TW_Outlet');
       	Account customer = new Account(RecordTypeId=custRTID, name='7-11_元大', ASI_HK_CRM_Channel__c = 'CVS',ASI_HK_CRM_JDE_Account_Number__c='123');
        insert customer;
        
        ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(name='7-11',
                                                                           ASI_CRM_Sub_Channel__c = subch.id,
                                                                           ASI_TH_CRM_Code__c  = 'TW_CSE');
        insert outletType;
        
        Id rtIdAddCust = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName().get('Key Account (TW)').getRecordTypeId(); 
        ASI_CRM_AccountsAdditionalField__c addCust = new ASI_CRM_AccountsAdditionalField__c(name='7-11_元大',
                                                                                            ASI_CRM_Is_SCA_Customer__c  = true,
                                                                                            ASI_CRM_Account__c = customer.id,
                                                                                            ASI_CRM_Channel__c = ch.id,
                                                                                            ASI_CRM_CN_Sub_Channel__c = subch.id,
                                                                                            ASI_TH_CRM_OutletType__c = outletType.id,
                                                                                            RecordTypeId=rtIdAddCust,
                                                                                            ASI_CRM_Region__c = 'CVS');
        insert addCust;
        
        String rtIdFHeader = checkRecordType('ASI_Forecast__c','ASI_Forecast_TW');        
		String rtIdFitem = checkRecordType('ASI_Forecast_Item__c','ASI_Forecast_TW_Item');        
        
        ASI_Forecast__c fheader = new ASI_Forecast__c(
            ASI_Forecast_Channel__c = ch.id,
            RecordTypeId=rtIdFHeader,
            ASI_Forecast_Sub_Channel__c = subch.id,
            ASI_CRM_Customer__c  = addCust.id,
            ASI_Forecast_Period_Date__c = System.today().toStartOfMonth(),
            ASI_Forecast_Status__c = 'Draft',
            ASI_Forecast_Type__c ='Forecast'
        );
        Date d1 = ASI_CRM_TW_Forecast_Util.CURR_MONTH_BUDGET;
        ASI_Forecast__c bheader = new ASI_Forecast__c(
            ASI_Forecast_Channel__c = ch.id,
            RecordTypeId=rtIdFHeader,
            ASI_Forecast_Sub_Channel__c = subch.id,
            ASI_CRM_Customer__c  = addCust.id,
            ASI_Forecast_Period_Date__c = Date.newInstance(d1.year(), 7, 1),
            ASI_Forecast_Status__c = 'Draft',
            ASI_Forecast_Type__c ='Budget'
        );
        insert new List<ASI_Forecast__c>{fheader,bheader};
        ASI_Forecast_Item__c fitem = new ASI_Forecast_Item__c(
            ASI_Forecast__c = fheader.id,
            RecordTypeId=rtIdFitem,
            ASI_Forecast_Item_Group__c = itemgroup.id,
            ASI_Forecast_P1__c=10, ASI_Forecast_P2__c=20, ASI_Forecast_P3__c=30,
            ASI_Forecast_P4__c=40, ASI_Forecast_P5__c=50, ASI_Forecast_P6__c=60,
            ASI_Forecast_P7__c=40, ASI_Forecast_P8__c=50, ASI_Forecast_P9__c=60,
            ASI_Forecast_P10__c=40, ASI_Forecast_P11__c=50, ASI_Forecast_P12__c=60
        );
        ASI_Forecast_Item__c  bitem = new ASI_Forecast_Item__c(
            ASI_Forecast__c = bheader.id,
            RecordTypeId=rtIdFitem,
            ASI_Forecast_Item_Group__c = itemgroup.id,
            ASI_Forecast_P1__c=10, ASI_Forecast_P2__c=20, ASI_Forecast_P3__c=30,
            ASI_Forecast_P4__c=40, ASI_Forecast_P5__c=50, ASI_Forecast_P6__c=60,
            ASI_Forecast_P7__c=40, ASI_Forecast_P8__c=50, ASI_Forecast_P9__c=60,
            ASI_Forecast_P10__c=40, ASI_Forecast_P11__c=50, ASI_Forecast_P12__c=60
        );
        insert new List<ASI_Forecast_Item__c>{fitem,bitem};
        
        //------ create users -------
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User user = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com');
        listUser.add(user);
        insert listUser;
		test.startTest();
        System.runAs(user) {
//            ASI_Forecast__c[] bList = ASI_CRM_TW_Forecast_Create.createBudgetHeader();
            ASI_Forecast__c[] fList = ASI_CRM_TW_Forecast_Create.createForecastHeader();
//            Set<id> bidSet = new Set<Id>();
            Set<id> fidSet = new Set<Id>();
//            for(ASI_Forecast__c f :bList) { bidSet.add(f.id); }
            for(ASI_Forecast__c f :fList) { fidSet.add(f.id); }
//            ASI_CRM_TW_Forecast_Create.insertForecastItem(bidSet);
            ASI_CRM_TW_Forecast_Create.insertForecastItem(fidSet);
            if(fList.size() > 0) { ASI_CRM_TW_Forecast_Create.forecastSetToDraft(fList.get(0).id); }
            
            d1 = ASI_CRM_TW_Forecast_Util.CURR_MONTH_BUDGET;
            Date d2 = ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST;
            ASI_CRM_TW_Forecast_Util.searchForecastForReport(d2,d2.addMonths(1));
            ASI_CRM_TW_Forecast_Util.searchBudgetForReport(d1.addYears(-2),d1.addYears(1));
	        ASI_CRM_TW_Forecast_Util.retrieveBudget(new Set<Id>{ch.id},null,null);

        }
        test.stopTest();
    }
	static testMethod void createForecastTest() {
        
        
        // recordType
        Id rtIdForecast  = Schema.SObjectType.ASI_Forecast__c.getRecordTypeInfosByName().get('TW Forecast').getRecordTypeId();
        Id rtIdItemGroup = Schema.SObjectType.ASI_MFM_Item_Group__c.getRecordTypeInfosByName().get('TW Item Group').getRecordTypeId();
        ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(Name='tmp00',
                                                                    ASI_MFM_Item_Group_Code__c='tmp00',
                                                                    ASI_CRM_Size_ml__c=500,
                                                                    ASI_CRM_CN_pack__c='10',
                                                                    ASI_CRM_Active__c = true,
                                                                    ASI_CRM_Applied_To_Forecast__c='CVS'
                                                                   );
        itemGroup.RecordTypeId=rtIdItemGroup;
		insert itemGroup;
        
        system.debug('itemGroup : ' + JSON.serialize(itemGroup));
        
        // insert channel sub-channel
        Id rtIdChannel   = Schema.SObjectType.ASI_CRM_CN_Channel__c.getRecordTypeInfosByName().get('TW Channel').getRecordTypeId(); 
        ASI_CRM_CN_Channel__c  ch = new ASI_CRM_CN_Channel__c(Name='CVS',
                                                              ASI_CRM_CN_Channel_Code__c ='CVS',
                                                              RecordTypeId=rtIdChannel
                                                             );
        insert ch;
        Id rtIdSubChannel= Schema.SObjectType.ASI_MFM_Sub_Channel__c.getRecordTypeInfosByName().get('TW Sub-Channel').getRecordTypeId(); 
        ASI_MFM_Sub_Channel__c  subch = new ASI_MFM_Sub_Channel__c (Name='CVS 7-11',
                                                                    ASI_CRM_CN_Sub_Channel_Code__c = 'CVS_7-11',
                                                                    ASI_CRM_CN_Sub_Channel_Chi_Name__c = '便利商店統一超商',
                                                                    ASI_CRM_CN_Channel__c = ch.id,
																	RecordTypeId=rtIdSubChannel);
        insert subch;
        
        Id custRTID = checkRecordType('Account','ASI_CRM_TW_Outlet');
       	Account customer = new Account(RecordTypeId=custRTID, name='7-11_元大', ASI_HK_CRM_Channel__c = 'CVS',ASI_HK_CRM_JDE_Account_Number__c='123');
        insert customer;
        
        ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(name='7-11',
                                                                           ASI_CRM_Sub_Channel__c = subch.id,
                                                                           ASI_TH_CRM_Code__c  = 'TW_CSE');
        insert outletType;
        
        Id rtIdAddCust = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName().get('Key Account (TW)').getRecordTypeId(); 
        ASI_CRM_AccountsAdditionalField__c addCust = new ASI_CRM_AccountsAdditionalField__c(name='7-11_元大',
                                                                                            ASI_CRM_Is_SCA_Customer__c  = true,
                                                                                            ASI_CRM_Account__c = customer.id,
                                                                                            ASI_CRM_Channel__c = ch.id,
                                                                                            ASI_CRM_CN_Sub_Channel__c = subch.id,
                                                                                            ASI_TH_CRM_OutletType__c = outletType.id,
                                                                                            RecordTypeId=rtIdAddCust,
                                                                                            ASI_CRM_Region__c = 'CVS');
        insert addCust;
        system.debug('addCust : ' + addCust);
        
        //------ create users -------
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User user = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com');
        listUser.add(user);
        insert listUser;
        
        test.startTest();
        System.runAs(user) {
            
            List<ASI_CRM_AccountsAdditionalField__c> custList = ASI_CRM_TW_Forecast_Create.getScaCustomer();
            ASI_Forecast__c[] bList = ASI_CRM_TW_Forecast_Create.createBudgetHeader();
            ASI_Forecast__c[] fList = ASI_CRM_TW_Forecast_Create.createForecastHeader();
            Set<id> bidSet = new Set<Id>();        
            Set<id> fidSet = new Set<Id>();
            for(ASI_Forecast__c f :bList) { bidSet.add(f.id); }
            for(ASI_Forecast__c f :fList) { fidSet.add(f.id); }
            ASI_CRM_TW_Forecast_Create.insertForecastItem(bidSet);
            ASI_CRM_TW_Forecast_Create.insertForecastItem(fidSet);
            if(bList.size() > 0) { ASI_CRM_TW_Forecast_Create.forecastSetToDraft(bList.get(0).id); }
            if(fList.size() > 0) { ASI_CRM_TW_Forecast_Create.forecastSetToDraft(fList.get(0).id); }
            
            ASI_CRM_TW_Forecast_Create.searchChannelCodeByHeaderIdSet(fidSet);
            ASI_CRM_TW_Forecast_Create.searchEmptyForecastHeader();
            
            ASI_MFM_Item_Group__c itemGroup2 = new ASI_MFM_Item_Group__c(Name='tmp01',
                                                                         ASI_MFM_Item_Group_Code__c='tmp01',
                                                                         ASI_CRM_Size_ml__c=400,
                                                                         ASI_CRM_CN_pack__c='12',
                                                                         ASI_CRM_Active__c = true,
                                                                         ASI_CRM_Applied_To_Forecast__c='CVS'
                                                                        );
            itemGroup2.RecordTypeId=rtIdItemGroup;
            insert itemGroup2;
            ASI_CRM_TW_Forecast_Create.applyNewItemToCurrentForecast(itemGroup2.id);
            ASI_CRM_TW_Forecast_Create.getBatchCount();
            ASI_CRM_TW_Forecast_Create.presetSCA_cust(new Set<String>{'123'});
            
            Datetime dt = ASI_CRM_TW_Forecast_Util.LAST_FORECAST_CD;
            Date d1 = ASI_CRM_TW_Forecast_Util.CURR_MONTH_BUDGET;
            Date d2 = ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST;
            Date d3 = ASI_CRM_TW_Forecast_Util.FREEZED_MONTH_BUDGET;
            
            ASI_CRM_TW_Forecast_Util.updateForecastStatus(fidSet,'Draft');
            ASI_CRM_TW_Forecast_Util.forecastDraftCount();
            ASI_CRM_TW_Forecast_Util.budgetDraftCount();
            
            ASI_CRM_TW_Forecast_Util.searchCurrForecastSummary(d2);
            ASI_CRM_TW_Forecast_Util.retrieveForecastSummary(new Set<Id>{ch.id}, new Set<Id>{subch.id}, new Set<String>{'CVS'}, ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST);
            ASI_CRM_TW_Forecast_Util.retrieveForecastRange(new Set<Id>{ch.id}, new Set<Id>{subch.Id}, new Set<String>{'CVS'}, System.today().addMonths(-1), System.today().addMonths(1));
        }
        test.stopTest();
    }
}