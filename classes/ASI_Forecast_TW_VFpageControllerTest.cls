@isTest
public class ASI_Forecast_TW_VFpageControllerTest {
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
    static testMethod void CreateAccountTest(){
        
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User u = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com');
        listUser.add(u);
        insert listUser;
        
        System.runAs(u) {
            String recordTypeid = checkRecordType('ASI_TH_CRM_OutletType__c','ASI_CRM_TW_Outlet_Type');
            ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(Name = 'LS (零售菸專)', ASI_TH_CRM_Code__c = 'TW_LS', RecordTypeid = recordTypeid);
            insert outletType;
        
            List<Account> insertAccountList = new List<Account>();
            List<ASI_CRM_AccountsAdditionalField__c> insertAccountAdditionalFieldList = new List<ASI_CRM_AccountsAdditionalField__c>();
            
            recordTypeid = checkRecordType('Account','ASI_CRM_TW_Outlet');    
            Account outlet = new Account(Name='Test Outlet', RecordTypeid = recordTypeid, ownerid = u.id);
            insertAccountList.add(outlet);

            Account outlet2 = new Account(Name='Test Outlet 2', RecordTypeid = recordTypeid, ownerid = u.id  );
            insertAccountList.add(outlet2);
            
            Account outlet3 = new Account(Name='Test Outlet 3', ownerid = u.id, RecordTypeid = recordTypeid );
            insertAccountList.add(outlet3);
            
            Account outlet4 = new Account(Name='Test Outlet 3', ownerid = u.id, RecordTypeid = recordTypeid );
            insertAccountList.add(outlet4);
            
            insert insertAccountList;
            
            recordTypeid = checkRecordType('ASI_CRM_AccountsAdditionalField__c','ASI_CRM_TW_Outlet');
            ASI_CRM_AccountsAdditionalField__c accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c(
                Name = 'Test Outlet', ASI_CRM_Account__c = outlet.id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',RecordTypeid = recordTypeid,
                ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12'
            );
            insertAccountAdditionalFieldList.add(accountAdditionalField);
            
            insert insertAccountAdditionalFieldList;
            
            Test.starttest();
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(outlet);
            ASI_CRM_TW_AccountEdit_Controller controller = new ASI_CRM_TW_AccountEdit_Controller(stdController); 
            controller.save();

            stdController = new ApexPages.Standardcontroller(outlet3);
            controller = new ASI_CRM_TW_AccountEdit_Controller(stdController); 
            controller.save();
            
            stdController = new ApexPages.Standardcontroller(outlet4);
            controller = new ASI_CRM_TW_AccountEdit_Controller(stdController); 
            controller.save();
            
            stdController = new ApexPages.Standardcontroller(outlet);          
            controller = new ASI_CRM_TW_AccountEdit_Controller(stdController);
            controller.accountAdditionalField.ASI_CRM_Account__c = null; 
            controller.save();
            
            List<SelectOption> OutletTypeList = controller.OutletTypeList;
            
            insertAccountAdditionalFieldList[0].ASI_CRM_TW_Parent_Account__c = outlet4.id;
            insertAccountAdditionalFieldList[0].ASI_CRM_IsParentAccount__c = true;
            
            //update insertAccountAdditionalFieldList[0];
            
            Test.stoptest();
            
        }
    }

    static testMethod void exportForecastControllerTest() {
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
        
       	system.debug(itemGroup);
        
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
        
        //------ create users -------
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User user = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com');
        listUser.add(user);
        User user2 = new User(Alias = 'standt', Email='dev2.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev2.pra@introv.com');
        listUser.add(user2);
        insert listUser;
        
        //insert mapping
        Id trIdChMap = Schema.SObjectType.ASI_Forecast_Channel_Map__c.getRecordTypeInfosByName().get('TW Forecast Channel Map').getRecordTypeId(); 
        ASI_Forecast_Channel_Map__c  chMap1 = new ASI_Forecast_Channel_Map__c(
            ASI_Forecast_Sub_Channel__c = subch.Id,
            ASI_Forecast_Region__c = 'CVS',
            ASI_Forecast_SubmitUser__c = true,
            ASI_Forecast_ChannelRegion_Manger__c = user.id,
            RecordTypeId=trIdChMap,
            ASI_Forecast_National_Manager__c = user.id
        );
        insert chMap1;
        Date period = System.today().addMonths(-1).toStartOfMonth();
        String rtIdFHeader = checkRecordType('ASI_Forecast__c','ASI_Forecast_TW');        
        String rtIdFitem = checkRecordType('ASI_Forecast_Item__c','ASI_Forecast_TW_Item');        
        ASI_Forecast__c fheader = new ASI_Forecast__c(
            ASI_Forecast_Channel__c = ch.id,
            RecordTypeId=rtIdFHeader,
            ASI_Forecast_Sub_Channel__c = subch.id,
            ASI_CRM_Customer__c  = addCust.id,
            ASI_Forecast_Period_Date__c = period,
            ASI_Forecast_Status__c = 'Submitted',
            ASI_Forecast_Type__c ='Forecast'
        );
        ASI_Forecast__c fheader2 = new ASI_Forecast__c(
            ASI_Forecast_Channel__c = ch.id,
            RecordTypeId=rtIdFHeader,
            ASI_Forecast_Sub_Channel__c = subch.id,
            ASI_CRM_Customer__c  = addCust.id,
            ASI_Forecast_Period_Date__c = period,
            ASI_Forecast_Status__c = 'Submitted',
            ASI_Forecast_Type__c ='Forecast'
        );
        insert new List<ASI_Forecast__c>{fheader,fheader2};
        
        ASI_Forecast_Item__c  fitem = new ASI_Forecast_Item__c(
            ASI_Forecast__c = fheader.id,
            RecordTypeId=rtIdFitem,
            ASI_Forecast_Item_Group__c = itemgroup.id,
            ASI_Forecast_P1__c=10, ASI_Forecast_P2__c=20, ASI_Forecast_P3__c=30,
            ASI_Forecast_P4__c=40, ASI_Forecast_P5__c=50, ASI_Forecast_P6__c=60,
            ASI_Forecast_P7__c=40, ASI_Forecast_P8__c=50, ASI_Forecast_P9__c=60,
            ASI_Forecast_P10__c=40, ASI_Forecast_P11__c=50, ASI_Forecast_P12__c=60
        );
        ASI_Forecast_Item__c  fitem2 = new ASI_Forecast_Item__c(
            ASI_Forecast__c = fheader2.id,
            RecordTypeId=rtIdFitem,
            ASI_Forecast_Item_Group__c = itemgroup.id,
            ASI_Forecast_P1__c=10, ASI_Forecast_P2__c=20, ASI_Forecast_P3__c=30,
            ASI_Forecast_P4__c=40, ASI_Forecast_P5__c=50, ASI_Forecast_P6__c=60,
            ASI_Forecast_P7__c=40, ASI_Forecast_P8__c=50, ASI_Forecast_P9__c=60,
            ASI_Forecast_P10__c=40, ASI_Forecast_P11__c=50, ASI_Forecast_P12__c=60
        );
        insert new List<ASI_Forecast_Item__c>{fitem,fitem2};
        
        test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.ASI_Forecast_TW_ForecastExportPage;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getParameters().put('dateperiod',period.year()+'-'+period.month());
            ASI_Forecast_TW_ForecastExport c1 = new ASI_Forecast_TW_ForecastExport();
            ApexPages.currentPage().getParameters().put('type','Forecast');
            c1 = new ASI_Forecast_TW_ForecastExport();
            c1.fetchList();
            ASI_Forecast_TW_ForecastExport c = new ASI_Forecast_TW_ForecastExport();
            ApexPages.currentPage().getParameters().put('type','Budget');
            c = new ASI_Forecast_TW_ForecastExport();
            c.fetchList();
            
            ASI_Forecast_TW_ForecastExport.ItemCsvWrapper wrapper = new ASI_Forecast_TW_ForecastExport.ItemCsvWrapper(fitem);
            wrapper.itemPeriodAdd(fitem2);
        }
        test.stopTest();
    }
    
    static testMethod void approveForecastControllerTest() {
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
        
        //------ create users -------
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User user = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com');
        listUser.add(user);
        User user2 = new User(Alias = 'standt', Email='dev2.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev2.pra@introv.com');
        listUser.add(user2);
        insert listUser;
        
        //insert mapping
        Id trIdChMap = Schema.SObjectType.ASI_Forecast_Channel_Map__c.getRecordTypeInfosByName().get('TW Forecast Channel Map').getRecordTypeId(); 
        ASI_Forecast_Channel_Map__c  chMap1 = new ASI_Forecast_Channel_Map__c(
            ASI_Forecast_Sub_Channel__c = subch.Id,
            ASI_Forecast_Region__c = 'CVS',
            ASI_Forecast_SubmitUser__c = true,
            ASI_Forecast_ChannelRegion_Manger__c = user.id,
            RecordTypeId=trIdChMap,
            ASI_Forecast_National_Manager__c = user.id
        );
        insert chMap1;

		String rtIdFHeader = checkRecordType('ASI_Forecast__c','ASI_Forecast_TW');        
        ASI_Forecast__c fheader = new ASI_Forecast__c(
            ASI_Forecast_Channel__c = ch.id,
            ASI_Forecast_Sub_Channel__c = subch.id,
            ASI_CRM_Customer__c  = addCust.id,
            ASI_Forecast_Period_Date__c = System.today().addMonths(-1).toStartOfMonth(),
            ASI_Forecast_Status__c = 'Submitted',
            RecordTypeId=rtIdFHeader,
            ASI_Forecast_Type__c ='Forecast'
        );
        insert fheader;
        String rtIdFitem = checkRecordType('ASI_Forecast_Item__c','ASI_Forecast_TW_Item');        
        ASI_Forecast_Item__c  fitem = new ASI_Forecast_Item__c(
            ASI_Forecast__c = fheader.id,
            RecordTypeId=rtIdFitem,
            ASI_Forecast_Item_Group__c = itemgroup.id,
            ASI_Forecast_P1__c=10, ASI_Forecast_P2__c=20, ASI_Forecast_P3__c=30,
            ASI_Forecast_P4__c=40, ASI_Forecast_P5__c=50, ASI_Forecast_P6__c=60,
            ASI_Forecast_P7__c=40, ASI_Forecast_P8__c=50, ASI_Forecast_P9__c=60,
            ASI_Forecast_P10__c=40, ASI_Forecast_P11__c=50, ASI_Forecast_P12__c=60
        );
        insert fitem;
        
        test.startTest();
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

            ASI_Forecast_TW_MassApproveController c = new ASI_Forecast_TW_MassApproveController();
            //String dataSet = c.dataSet;
            //Map<String, Object> dataSetMap = (Map<String, Object>)JSON.deserializeUntyped(dataSet);
            Map<String, Object> dataSetMap = ASI_Forecast_TW_MassApproveController.requestForecast('');
			List<Object> submitted = (List<Object>)dataSetMap.get('Submitted');
            String toSave = JSON.serialize(submitted);
            
            ASI_Forecast_TW_MassApproveController.approveForecast(toSave);

            Map<String, Object> rejectMap = new Map<String, Object>{
                'reason'=>'tmp',
                'approvalData'=>submitted
            };
            ASI_Forecast_TW_MassApproveController.rejectForecast(JSON.serialize(rejectMap));

        }
        test.stopTest();
    }
    
    static testMethod void approveBudgetControllerTest() {
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
        
        //------ create users -------
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User user = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com');
        listUser.add(user);
        User user2 = new User(Alias = 'standt', Email='dev2.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev2.pra@introv.com');
        listUser.add(user2);
        insert listUser;
        
        //insert mapping
        Id trIdChMap = Schema.SObjectType.ASI_Forecast_Channel_Map__c.getRecordTypeInfosByName().get('TW Forecast Channel Map').getRecordTypeId(); 
        ASI_Forecast_Channel_Map__c  chMap1 = new ASI_Forecast_Channel_Map__c(
            ASI_Forecast_Sub_Channel__c = subch.Id,
            ASI_Forecast_Region__c = 'CVS',
            ASI_Forecast_SubmitUser__c = true,
            ASI_Forecast_ChannelRegion_Manger__c = user.id,
            RecordTypeId=trIdChMap,
            ASI_Forecast_National_Manager__c = user.id
        );
        insert chMap1;
        
        String rtIdFHeader = checkRecordType('ASI_Forecast__c','ASI_Forecast_TW');        
		String rtIdFitem = checkRecordType('ASI_Forecast_Item__c','ASI_Forecast_TW_Item');        
        
        ASI_Forecast__c bheader = new ASI_Forecast__c(
            ASI_Forecast_Channel__c = ch.id,
            RecordTypeId=rtIdFHeader,
            ASI_Forecast_Sub_Channel__c = subch.id,
            ASI_CRM_Customer__c  = addCust.id,
            ASI_Forecast_Period_Date__c = Date.newInstance(2017, 7, 1),
            ASI_Forecast_Status__c = 'Submitted',
            ASI_Forecast_Type__c ='Budget'
        );
        insert bheader;
        
        ASI_Forecast_Item__c  bitem = new ASI_Forecast_Item__c(
            ASI_Forecast__c = bheader.id,
            RecordTypeId=rtIdFitem,
            ASI_Forecast_Item_Group__c = itemgroup.id,
            ASI_Forecast_P1__c=10, ASI_Forecast_P2__c=20, ASI_Forecast_P3__c=30,
            ASI_Forecast_P4__c=40, ASI_Forecast_P5__c=50, ASI_Forecast_P6__c=60,
            ASI_Forecast_P7__c=40, ASI_Forecast_P8__c=50, ASI_Forecast_P9__c=60,
            ASI_Forecast_P10__c=40, ASI_Forecast_P11__c=50, ASI_Forecast_P12__c=60
        );
        insert bitem;
        
        test.startTest();
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

			ASI_Forecast_TW_ApproveBudgetController c = new ASI_Forecast_TW_ApproveBudgetController();
            Set<id> tmp = c.channel;
            tmp = c.subChannel;
			Set<String> region = c.region;
            String debug = c.debug;
            Date d = c.defDate;
            Integer i = c.fiscalYearMonth;
			
			//Map<String, Object> dataSetMap = (Map<String, Object>)JSON.deserializeUntyped(c.dataSet);
			Map<String, Object> dataSetMap = ASI_Forecast_TW_ApproveBudgetController.requestBudget('');
			List<Object> dataSet = (List<Object>)dataSetMap.get('Submitted');
            String toSave = JSON.serialize(dataSet);
            
            ASI_Forecast_TW_ApproveBudgetController.approveBudget(toSave);
            Map<String, Object> rejectMap = new Map<String, Object>{
                'reason'=>'tmp',
                'approvalData'=>dataSet
            };
            
            ASI_Forecast_TW_ApproveBudgetController.rejectBudget(JSON.serialize(rejectMap));
        }
        test.stopTest();
    }
    
    static testMethod void inputBudgetControllerTest() {
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
        
        //------ create users -------
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User user = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com');
        listUser.add(user);
        User user2 = new User(Alias = 'standt', Email='dev2.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev2.pra@introv.com');
        listUser.add(user2);
        insert listUser;
        
        //insert mapping
        Id trIdChMap = Schema.SObjectType.ASI_Forecast_Channel_Map__c.getRecordTypeInfosByName().get('TW Forecast Channel Map').getRecordTypeId(); 
        ASI_Forecast_Channel_Map__c  chMap1 = new ASI_Forecast_Channel_Map__c(
            ASI_Forecast_Sub_Channel__c = subch.Id,
            ASI_Forecast_Region__c = 'CVS',
            ASI_Forecast_SubmitUser__c = true,
            ASI_Forecast_ChannelRegion_Manger__c = user.id,
            RecordTypeId=trIdChMap,
            ASI_Forecast_National_Manager__c = user.id
        );
        insert chMap1;
        String rtIdFHeader = checkRecordType('ASI_Forecast__c','ASI_Forecast_TW');        
		String rtIdFitem = checkRecordType('ASI_Forecast_Item__c','ASI_Forecast_TW_Item');        
        ASI_Forecast__c bheader = new ASI_Forecast__c(
            ASI_Forecast_Channel__c = ch.id,
            ASI_Forecast_Sub_Channel__c = subch.id,
            ASI_CRM_Customer__c  = addCust.id,
            ASI_Forecast_Period_Date__c = Date.newInstance(2017, 7, 1),
            ASI_Forecast_Status__c = 'Draft',
            RecordTypeId=rtIdFHeader,
            ASI_Forecast_Type__c ='Budget'
        );
        insert bheader;
        
        ASI_Forecast_Item__c  bitem = new ASI_Forecast_Item__c(
            ASI_Forecast__c = bheader.id,
            RecordTypeId=rtIdFitem,
            ASI_Forecast_Item_Group__c = itemgroup.id,
            ASI_Forecast_P1__c=10, ASI_Forecast_P2__c=20, ASI_Forecast_P3__c=30,
            ASI_Forecast_P4__c=40, ASI_Forecast_P5__c=50, ASI_Forecast_P6__c=60,
            ASI_Forecast_P7__c=40, ASI_Forecast_P8__c=50, ASI_Forecast_P9__c=60,
            ASI_Forecast_P10__c=40, ASI_Forecast_P11__c=50, ASI_Forecast_P12__c=60
        );
        insert bitem;
        
        test.startTest();
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
            
            ASI_Forecast__c[] bList = ASI_CRM_TW_Forecast_Create.createBudgetHeader();
            Set<id> bidSet = new Set<Id>();        
            for(ASI_Forecast__c f :bList) { bidSet.add(f.id); }
            ASI_CRM_TW_Forecast_Create.insertForecastItem(bidSet);
            if(bList.size() > 0) { ASI_CRM_TW_Forecast_Create.forecastSetToDraft(bList.get(0).id); }
            
			ASI_Forecast_TW_InputBudgetController c = new ASI_Forecast_TW_InputBudgetController();
            Set<id> tmp = c.channel;
            tmp = c.subChannel;
			Set<String> region = c.region;
            Date d = c.defDate;
            Integer i = c.fiscalYearMonth;
			
            c.assignForecastPeriod(new ASI_Forecast_TW_InputBudgetController.ASI_Forecast_TW_Input_Item(), bitem);
			Map<String, Object> dataSetMap = (Map<String, Object>)JSON.deserializeUntyped(c.dataSet);
			List<Object> dataSet = (List<Object>)dataSetMap.get('Draft');
            String toSave = JSON.serialize(dataSet);
            
            ASI_Forecast_TW_InputBudgetController.saveBudget(toSave);
            ASI_Forecast_TW_InputBudgetController.submitBudget(toSave);
        }
        test.stopTest();
    }
    
    static testMethod void inputForecastControllerTest() {
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
        
        //------ create users -------
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User user = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com');
        listUser.add(user);
        User user2 = new User(Alias = 'standt', Email='dev2.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev2.pra@introv.com');
        listUser.add(user2);
        insert listUser;
        
        //insert mapping
        Id trIdChMap = Schema.SObjectType.ASI_Forecast_Channel_Map__c.getRecordTypeInfosByName().get('TW Forecast Channel Map').getRecordTypeId(); 
        ASI_Forecast_Channel_Map__c  chMap1 = new ASI_Forecast_Channel_Map__c(
            ASI_Forecast_Sub_Channel__c = subch.Id,
            ASI_Forecast_Region__c = 'CVS',
            ASI_Forecast_SubmitUser__c = true,
            ASI_Forecast_ChannelRegion_Manger__c = user.id,
            RecordTypeId=trIdChMap,
            ASI_Forecast_National_Manager__c = user.id
        );
        insert chMap1;
        String rtIdFHeader = checkRecordType('ASI_Forecast__c','ASI_Forecast_TW');        
		String rtIdFitem = checkRecordType('ASI_Forecast_Item__c','ASI_Forecast_TW_Item');        
        //past forecast 
        ASI_Forecast__c fheader = new ASI_Forecast__c(
            ASI_Forecast_Channel__c = ch.id,
            RecordTypeId=rtIdFHeader,
            ASI_Forecast_Sub_Channel__c = subch.id,
            ASI_CRM_Customer__c  = addCust.id,
            ASI_Forecast_Period_Date__c = System.today().addMonths(-1).toStartOfMonth(),
            ASI_Forecast_Status__c = 'Draft',
            ASI_Forecast_Type__c ='Forecast'
        );
        insert fheader;
        
        ASI_Forecast_Item__c  fitem = new ASI_Forecast_Item__c(
            ASI_Forecast__c = fheader.id,
            RecordTypeId=rtIdFitem,
            ASI_Forecast_Item_Group__c = itemgroup.id,
            ASI_Forecast_P1__c=10, ASI_Forecast_P2__c=20, ASI_Forecast_P3__c=30,
            ASI_Forecast_P4__c=40, ASI_Forecast_P5__c=50, ASI_Forecast_P6__c=60,
            ASI_Forecast_P7__c=40, ASI_Forecast_P8__c=50, ASI_Forecast_P9__c=60,
            ASI_Forecast_P10__c=40, ASI_Forecast_P11__c=50, ASI_Forecast_P12__c=60
        );
        insert fitem;
        
        ASI_Forecast__c bheader = new ASI_Forecast__c(
            ASI_Forecast_Channel__c = ch.id,
            RecordTypeId=rtIdFHeader,
            ASI_Forecast_Sub_Channel__c = subch.id,
            ASI_CRM_Customer__c  = addCust.id,
            ASI_Forecast_Period_Date__c = Date.newInstance(2017, 7, 1),
            ASI_Forecast_Status__c = 'Freezed',
            ASI_Forecast_Type__c ='Budget'
        );
        insert bheader;
        
        ASI_Forecast_Item__c  bitem = new ASI_Forecast_Item__c(
            ASI_Forecast__c = bheader.id,
            RecordTypeId=rtIdFitem,
            ASI_Forecast_Item_Group__c = itemgroup.id,
            ASI_Forecast_P1__c=10, ASI_Forecast_P2__c=20, ASI_Forecast_P3__c=30,
            ASI_Forecast_P4__c=40, ASI_Forecast_P5__c=50, ASI_Forecast_P6__c=60,
            ASI_Forecast_P7__c=40, ASI_Forecast_P8__c=50, ASI_Forecast_P9__c=60,
            ASI_Forecast_P10__c=40, ASI_Forecast_P11__c=50, ASI_Forecast_P12__c=60
        );
        insert bitem;
        
        test.startTest();
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
            
            ASI_Forecast__c[] fList = ASI_CRM_TW_Forecast_Create.createForecastHeader();
            Set<id> fidSet = new Set<Id>();
            for(ASI_Forecast__c f :fList) { fidSet.add(f.id); }
            ASI_CRM_TW_Forecast_Create.insertForecastItem(fidSet);
            
            
            
			ASI_Forecast_TW_InputForecastController c = new ASI_Forecast_TW_InputForecastController();
            Set<id> tmp = c.channel;
            tmp = c.subChannel;
			Set<String> region = c.region;
            Date d = c.currMonth;
            
            c.assignForecastPeriod(new ASI_Forecast_TW_InputForecastController.ASI_Forecast_TW_Input_Item(), fitem);
            c.assignForecastSecondPeriod(new ASI_Forecast_TW_InputForecastController.ASI_Forecast_TW_Input_Item(), fitem);
            c.getBudgetPeriod(bitem,0);
            c.getBudgetPeriod(bitem,1);
            c.getBudgetPeriod(bitem,2);
            c.getBudgetPeriod(bitem,3);
            c.getBudgetPeriod(bitem,4);
            c.getBudgetPeriod(bitem,5);
            c.getBudgetPeriod(bitem,6);
            c.getBudgetPeriod(bitem,7);
            c.getBudgetPeriod(bitem,8);
            c.getBudgetPeriod(bitem,9);
            c.getBudgetPeriod(bitem,10);
            c.getBudgetPeriod(bitem,11);
            c.getBudgetPeriod(bitem,12);
            
			Map<String, Object> dataSetMap = (Map<String, Object>)JSON.deserializeUntyped(c.dataSet);
			List<Object> dataSet = (List<Object>)dataSetMap.get('Draft');
            String toSave = JSON.serialize(dataSet);
            
            ASI_Forecast_TW_InputForecastController.saveForecast(toSave);
            ASI_Forecast_TW_InputForecastController.submitForecast(toSave);

        }
        test.stopTest();
    }
    
    static testMethod void adminControllerTest() {
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
        
        //------ create users -------
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User user = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com');
        listUser.add(user);
        User user2 = new User(Alias = 'standt', Email='dev2.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev2.pra@introv.com');
        listUser.add(user2);
        insert listUser;
        
        //insert mapping
        Id trIdChMap = Schema.SObjectType.ASI_Forecast_Channel_Map__c.getRecordTypeInfosByName().get('TW Forecast Channel Map').getRecordTypeId(); 
        ASI_Forecast_Channel_Map__c  chMap1 = new ASI_Forecast_Channel_Map__c(
            ASI_Forecast_Sub_Channel__c = subch.Id,
            ASI_Forecast_Region__c = 'CVS',
            ASI_Forecast_SubmitUser__c = true,
            ASI_Forecast_ChannelRegion_Manger__c = user.id,
            RecordTypeId=trIdChMap,
            ASI_Forecast_National_Manager__c = user2.id
        );
        insert chMap1;
        
        test.startTest();
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
            
            ASI_Forecast__c[] fList = ASI_CRM_TW_Forecast_Create.createForecastHeader();
            Set<id> fidSet = new Set<Id>();
            for(ASI_Forecast__c f :fList) { fidSet.add(f.id); }
            ASI_CRM_TW_Forecast_Create.insertForecastItem(fidSet);
            
			ASI_Forecast_TW_ForecastAdminController c = new ASI_Forecast_TW_ForecastAdminController();
            integer tmp = c.getDarftCount;
            tmp = c.getCutoffDay;
			Boolean b = c.isBatch;
            
            
            ASI_Forecast_TW_ForecastAdminController.freezeForecast('tmp');
            ASI_Forecast_TW_ForecastAdminController.createForecast('tmp');
            
            ASI_Forecast__c[] bList = ASI_CRM_TW_Forecast_Create.createBudgetHeader();
            Set<id> bidSet = new Set<Id>();
            for(ASI_Forecast__c f :bList) { bidSet.add(f.id); }
            ASI_CRM_TW_Forecast_Create.insertForecastItem(bidSet);
           
			ASI_Forecast_TW_BudgetAdminController bc = new ASI_Forecast_TW_BudgetAdminController();
            tmp = bc.getDarftCount;
			b = bc.isBatch;
            ASI_Forecast_TW_BudgetAdminController.freezeBudget('tmp');
            ASI_Forecast_TW_BudgetAdminController.createBudget('tmp');
        }
        test.stopTest();
    }
}