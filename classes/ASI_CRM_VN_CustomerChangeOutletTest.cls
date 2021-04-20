/*********************************************************************************
 * Name:ASI_CRM_VN_CustomerChangeOutletTest 
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 15/05/2017       Wilken		            [WL 1.0] Updated UpdateRspRegionTest method to add Service Pack test data to increase code coverage
*********************************************************************************/
@isTest(SeeAllData=false)
private class ASI_CRM_VN_CustomerChangeOutletTest {
    @testSetup
    public static void setupTestData(){
        // DC - 08/02/2016 - Created Running Number Data
            ASI_HK_CRM_Running_Number__c testRunningNumber = ASI_CRM_VN_TestDataFactory.getRunningNumber(
                system.Label.ASI_CRM_VN_Customer_Code,
                1,
                'VN-{YYYY}',
                date.today().month() + 2,
                Date.today().year()
            );
            insert testRunningNumber;    
    }
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
    
    static testMethod void UpdateRspRegionTest(){      
        Profile p = [select id from profile where name='System Administrator'];
        UserRole ur=new UserRole(Name='Test UserRole');
        insert ur;
        System.debug('-----------------------------'+ur.id);
        User u = new User(alias = 'systemA', email='systemadmin@testorg.com',
                          emailencodingkey='UTF-8', lastname='Testing', 
                          languagelocalekey='en_US', localesidkey='en_US', 
                          profileid = p.Id,isactive = true ,
                          timezonesidkey='America/Los_Angeles',
                          username='systemadmin@updaterspregiontest.com',userroleID=ur.id);
        Id CustRecordTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName()
                                                                                   .get('Outlet (VN) - Inactive').getRecordTypeId();

        System.runAs(u) {            
			//[WL 1.0 Begin]
			List<ASI_CRM_ServicePack__c> svcPackList = new List<ASI_CRM_ServicePack__c>();
            ASI_CRM_ServicePack__c svcPack1 = new ASI_CRM_ServicePack__c(Name='Service Pack 1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_ServicePack__cASI_CRM_VN_ServicePack'));
			svcPackList.add(svcPack1);
			
			ASI_CRM_ServicePack__c svcPack2 = new ASI_CRM_ServicePack__c(Name='Service Pack 2', recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_ServicePack__cASI_CRM_VN_ServicePack'));
			svcPackList.add(svcPack2);
			insert svcPackList;
			//[WL 1.0 End]
			
            Account acc=new Account(Name='Test Account');
            insert acc;
            System.debug('------------------------------------------'+acc.id);
            
            ASI_CRM_AccountsAdditionalField__c accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c(
                Name = 'Testing Outlet', ASI_CRM_VN_Region__c = 'Central', ASI_CRM_Account__c = acc.id,RecordTypeid = CustRecordTypeId, ASI_CRM_Service_Pack__c = svcPack1.Id);
            insert accountAdditionalField;  
            System.debug('------------------------------------------'+accountAdditionalField.id);
            
                         
            ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c(
                ASI_CRM_Active__c = True , Name = 'Testing subBrand', RecordTypeid = checkRecordType('ASI_MFM_Sub_brand__c','ASI_CRM_VN_SubBrand')
            );     
            insert subBrand; 
                    
            ASI_CRM_Promoter__c promoter = new ASI_CRM_Promoter__c(
                Name = 'Testing promoter', ASI_CRM_VNId__c = '12345678' , ASI_CRM_MobileNo__c = '234567879', RecordTypeid = checkRecordType('ASI_CRM_Promoter__c','ASI_CRM_VN_Promoter')                      
            );
            insert promoter;     
                                 
                    
            /* ASI_TH_CRM_RSP__c rsp = new ASI_TH_CRM_RSP__c(
                ASI_TH_CRM_Sub_Brand__c = subBrand.id , ASI_CRM_CN_Customer__c = accountAdditionalField.id , ASI_CRM_Promoter__c = promoter.id ,ASI_CRM_PGLeader__c = u.id, ASI_CRM_DateTime__c = datetime.now() ,ASI_CRM_SubmitDateTime__c = datetime.now() 
            );
            insert rsp;*/
            //RecordTypeid = checkRecordType('ASI_CRM_VN_Region__c','ASI_CRM_VN_Outlet'
                    
            Test.startTest();
              
                accountAdditionalField.ASI_CRM_VN_Region__c = 'North';
                // accountAdditionalField.ASI_CRM_VN_OutletType__c = 'Iconic';
                // accountAdditionalField.ASI_CRM_Outlet_Sub_Type__c = 'Hotel Lounge';
                accountAdditionalField.ASI_TH_CRM_Contracted_With__c = 'PRT';
                update accountAdditionalField;

				//[WL 1.0 Begin]
				accountAdditionalField.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_VN_Outlet');
				accountAdditionalField.ASI_CRM_Service_Pack__c = svcPack2.Id;
				update accountAdditionalField;
				//[WL 1.0 End]
				
            Test.stopTest();
        }  
    }
}