/*Created by Twinkle Li @introv 05/06/2015
*
* Testclass for:
* ASI_CRM_TW_UpdateActualOfftake_Batch
* ASI_CRM_TW_UpdateActualOfftake_Schd
*/

@isTest
public class ASI_CRM_TW_UpdateActualOfftake_Test {
    private static string getFiscalYear(){
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
        Datetime GMTdate = Datetime.now();
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1;
        Integer yearA2 = Integer.valueOf(yearA1) +1;
        String Current_Fiscal_year;

        if(system.today()< orgFiscalYear){
            Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        }else{
            Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
        }       
        return Current_Fiscal_year;
    }
    
    /*For ASI_CRM_TW_UpdateActualOfftake_Batch*/
    public static testMethod void ASI_CRM_TW_UpdateActualOfftake_Batch_Test() {
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        //u.ASI_MFM_Country__c = 'TW';
        //update u;
        
        ASI_CRM_TW_Settings__c customSetting = new ASI_CRM_TW_Settings__c(ASI_CRM_TW_ActualOfftake_Offset__c = -1);
        insert customSetting;
        
        List<Account> acctList = new List<Account>();     
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name'));            
        insert acctList;
        
        List<ASI_MFM_Sub_brand__c> listSubBrand = new List<ASI_MFM_Sub_brand__c>(); 
        listSubBrand.add(new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'), ASI_CRM_TW_Company__c ='PRT', ASI_TH_CRM_Active__c = true));
        insert listSubBrand;
        
        List<ASI_TH_CRM_Actual_Offtake__c> listActOfftake = new List<ASI_TH_CRM_Actual_Offtake__c>();
        Date lastMonth = date.Today().addMonths(-1) ;
        listActOfftake.add(new ASI_TH_CRM_Actual_Offtake__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_TW_Actual_Offtake_Target_Vol'), ASI_TH_CRM_Offtake_G_L_Date__c=lastMonth,
                                                            ASI_TH_CRM_Outlet__c=acctList[0].id, ASI_TH_CRM_Sub_brand__c=listSubBrand[0].id));
        listActOfftake.add(new ASI_TH_CRM_Actual_Offtake__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_TW_Actual_Offtake'), ASI_TH_CRM_Offtake_G_L_Date__c=lastMonth,
                                                            ASI_TH_CRM_Outlet__c=acctList[0].id, ASI_TH_CRM_Sub_brand__c=listSubBrand[0].id));
        insert listActOfftake;
        
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='rade A&P Plan', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxp;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC');
        insert ac;
        
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                         ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Draft', ASI_MFM_Account__c=acctList[0].id));
        insert listPlan;  
        
        List<ASI_MFM_Plan_Line_Item__c> listPlanlt = new List<ASI_MFM_Plan_Line_Item__c>();
        listPlanlt.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_Plan__c=listPlan[0].id, 
                                                     ASI_MFM_Sub_brand_Code__c=listSubBrand[0].id, ASI_MFM_A_C_Code__c=ac.id));
        insert listPlanlt;
        
        List<ASI_CRM_OutletDepletion__c> listODep = new List<ASI_CRM_OutletDepletion__c>();
        listODep.add(new ASI_CRM_OutletDepletion__c(ASI_CRM_Outlet__c=acctList[0].id, ASI_CRM_SubBrand__c=listSubBrand[0].id));
        insert listODep;
        
        database.executebatch(new ASI_CRM_TW_UpdateActualOfftake_Batch());
    }
    
    /*For ASI_CRM_TW_UpdateActualOfftake_Schd*/
    public static testMethod void ASI_CRM_TW_UpdateActualOfftake_Schd_Test() {
        ASI_CRM_TW_Settings__c customSetting = new ASI_CRM_TW_Settings__c(ASI_CRM_TW_ActualOfftake_Offset__c = -1);
        insert customSetting;
        
        test.startTest();
        ASI_CRM_TW_UpdateActualOfftake_Schd myClass = new ASI_CRM_TW_UpdateActualOfftake_Schd();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }
}