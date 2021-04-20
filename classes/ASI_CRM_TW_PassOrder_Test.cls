@isTest
public class ASI_CRM_TW_PassOrder_Test {
    static Id checkRecordType(string strsobject, string rt_name) {
        id RT_id;
        List<recordType> sobjectlist = Global_RecordTypeCache.getRtList(strsobject);
        for (recordtype pl : sobjectlist ){
            if (pl.developername == rt_name)
                RT_id = pl.id;
        }
        system.debug('RT_id: ' + RT_id);
        return RT_id;           
    }
    
	/*For ASI_CRM_TW_Pass_Order_Ctrl */
    public static testMethod void ASI_CRM_TW_PassOrderCtrl_Test() {
        user u = [SELECT id from user where id = :userInfo.getUserId()];                                                
        String strThisYear = String.valueof(Date.Today().Year());
        Date myDate = Date.newInstance(integer.valueof(Date.Today().Year()) , 1, 1);
        
        Test.startTest();
        System.runAs(u) {
            String recordTypeid = checkRecordType('ASI_CRM_CN_Channel__c','ASI_CRM_TW_Channel');
            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name = 'HBR', ASI_CRM_CN_Channel_Code__c = 'HBR', RecordTypeid = recordTypeid);
            insert channel; 
            
            recordTypeid = checkRecordType('ASI_MFM_Sub_Channel__c','ASI_CRM_TW_SubChannel');
            ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(Name = 'Sub-Channel', ASI_CRM_CN_Channel__c = channel.id, RecordTypeid = recordTypeid);
            insert subChannel;         
        
            recordTypeid = checkRecordType('ASI_TH_CRM_OutletType__c','ASI_CRM_TW_Outlet_Type');
            ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(Name = 'LS (零售菸專)', ASI_TH_CRM_Code__c = 'TW_LS', ASI_CRM_Sub_Channel__c = subChannel.id, RecordTypeid = recordTypeid);
            insert outletType;
        
            List<Account> insertAccountList = new List<Account>();
            List<ASI_CRM_AccountsAdditionalField__c> insertAccountAdditionalFieldList = new List<ASI_CRM_AccountsAdditionalField__c>();
            
            recordTypeid = checkRecordType('Account','ASI_CRM_TW_Outlet');    
            Account outlet = new Account(Name='Test Outlet', RecordTypeid = recordTypeid, ownerid = u.id);
            insertAccountList.add(outlet);                        
            insert insertAccountList;
            
            ASI_TH_CRM_OutletImage__c outletImage = new ASI_TH_CRM_OutletImage__c(Name = 'Iconic', ASI_TH_CRM_Code__c = 'TW_ICN');
            insert outletImage;
            
            recordTypeid = checkRecordType('ASI_CRM_AccountsAdditionalField__c','ASI_CRM_TW_Outlet');
            ASI_CRM_AccountsAdditionalField__c accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c(
                Name = 'Test Outlet', ASI_CRM_Account__c = outlet.id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North', RecordTypeid = recordTypeid,
                ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12',
                ASI_TH_CRM_OutletImage__c = outletImage.id, ASI_CRM_Channel__c = channel.id, ASI_CRM_Longitude__c = 25, ASI_CRM_Latitude__c = 20 
            );
            insertAccountAdditionalFieldList.add(accountAdditionalField);
            
            insert insertAccountAdditionalFieldList;
        
            recordTypeid = checkRecordType('ASI_HK_CRM_Visitation_Plan__c','ASI_CRM_TW_Visitation_Plan');
            ASI_HK_CRM_Visitation_Plan__c visitationPlan = new ASI_HK_CRM_Visitation_Plan__c(Name = 'Test Visitation Plan', RecordTypeid = recordTypeid,
                ASI_HK_CRM_Year__c = strThisYear, ASI_HK_CRM_Month__c = 'January');
                
            insert visitationPlan;
            
            ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_HK_CRM_Account__c = outlet.id, ASI_HK_CRM_Visit_Date__c = myDate, ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                ASI_TH_CRM_Visit_Date_Time_From__c = datetime.newInstance(myDate.year(), myDate.month(), myDate.day()), 
                ASI_TH_CRM_Visit_Date_Time_To__c = datetime.newInstance(myDate.year(), myDate.month(), myDate.day()),
                ASI_HK_CRM_Status__c = 'Achieved'
            );
            insert vpDetail;
            
            recordtypeId = checkRecordType('ASI_CRM_Pass_Order__c', 'ASI_CRM_TW_Pass_Order');
            ASI_CRM_Pass_Order__c passOrder = new ASI_CRM_Pass_Order__c(RecordTypeId = recordtypeId, ASI_CRM_Visitation_Plan_Detail__c = vpDetail.id, ASI_CRM_Account__c = insertAccountList[0].id);
            insert passOrder;
            update passOrder;
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(passOrder);
            ApexPages.currentPage().getParameters().put('vpid', vpDetail.id);    
            ApexPages.currentPage().getParameters().put('accid', outlet.id);
            ASI_CRM_TW_Pass_Order_Ctrl controller = new ASI_CRM_TW_Pass_Order_Ctrl(stdController);                          

            delete passOrder;
            
            List<SelectOption> supplierList = controller.SupplierList;
            List<SelectOption> itemGpList = controller.ItemGroupList;
            String channelCode = controller.strChannelCode;
            String region = controller.strRegion;
            
            controller.setAccount();
			controller.initValue(true);
            
            controller.AddRow();
            controller.RemoveRow();
            controller.AddRow();
            
            controller.listPassOrder[0].decQuantity = 10;
            
            controller.QuickSave();
            controller.Save();
            
            controller.acc.Name = 'Test Outlet';
            controller.searchAcc();
            controller.FirstPage();
            controller.LastPage();
            controller.getprev();
            controller.getnxt();
            
            controller.redirect();
        }
        
        Test.stopTest();
    }
}