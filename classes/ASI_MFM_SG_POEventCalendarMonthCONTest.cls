@isTest
public class ASI_MFM_SG_POEventCalendarMonthCONTest {
    
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
    
    static testMethod void ASI_MFM_SG_POEventCalendarMonthCONTest(){
        
        //Set User
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        //Set Plan prefix
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        //Set PO
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='Singapore');
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        //Set   Route Type
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        System.debug(Limits.getDMLRows());
        
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_SG_Customer'),Name='Name3');           
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Event_Name__c = 'Test',
                                             ASI_MFM_Event_Start_Date__c = date.today().addDays(-7),
                                             ASI_MFM_Event_End_Date__c = date.today().addDays(3),
                                             ASI_MFM_PO_Start_Date__c=date.today(),
                                             ASI_MFM_PO_End_Date__c=date.today(),
                                             ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Status__c = 'Final',
                                             ASI_MFM_Plan__c = p1.id,
                                             ASI_MFM_Prefix__c=px.id,
                                             recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO_Read_Only'));
        
        insert po;  
        
        
        
        Date today = Date.today();
        String StartDateStr = ''+today.addDays(-7);
        String EndDateStr = ''+today.addDays(7);
        
        ASI_MFM_SG_POEventCalendarMonthCON con = new ASI_MFM_SG_POEventCalendarMonthCON();
        
        test.startTest();
        PageReference ManageAllPage = Page.ASI_MFM_SG_POEventCalendarMonthPage;
        ManageAllPage.getParameters().put('year', ''+today.year());
        ManageAllPage.getParameters().put('month', ''+(today.month()+1));
        ManageAllPage.getParameters().put('pmtId', ''+po.id);
        Test.setCurrentPageReference(ManageAllPage);
        con.initPage();
        
        List<ASI_MFM_SG_POEventCalendarMonthCON.ASI_MFM_SG_MonthEvent> tmp = ASI_MFM_SG_POEventCalendarMonthCON.retrievePromotionsByTimeRange(StartDateStr,EndDateStr);
        
        String tmp1 = con.pmtPopupTitle;
        String tmp2 = ASI_MFM_SG_POEventCalendarMonthCON.convertToRetrivalDateFormat(today);
        String tmp3 = ASI_MFM_SG_POEventCalendarMonthCON.convertToRetrivalDateFormat(2018,1,1);
        
        PageReference tmp4 = con.redirectToViewPage();
        PageReference tmp5 = con.redirectToAnotherCalendarType();
        
        
        test.stopTest();
        
    }
}