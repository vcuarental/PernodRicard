/*Created by Tony Ren @Elufa 11/24/2016
*
* Testclass for:
* ASI_MFM_SetPOStatusController
* ASI_MFM_TR_PO_TriggerClass
*/


@isTest
private class ASI_MFM_TR_PO_TestClass {
 
    public static string getFiscalYear(){
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
        /* 
    static testMethod void ASI_MFM_TRPO_TriggerTest() { //To  test ASI_MFM_TR_PO_TriggerClass  
        
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());
        //Set User
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TR';
        update u;
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='HKD',ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='TR', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        // Set  Prefix
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test',  ASI_MFM_Fiscal_year__c=getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;
        
       // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;

        
        
        //Route Type
		List<ASI_MFM_Route_Type__c> rtList = new List<ASI_MFM_Route_Type__c>();
        ASI_MFM_Route_Type__c planRT = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Plan');
        ASI_MFM_Route_Type__c poRT = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
     	rtList.add(planRT);
		rtList.add(poRT);
        insert rtList;
        
        // ASI MFM Route Rule Details Set Approver 
        List<ASI_MFM_Route_Rule_Detail__c> rrdList = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=poRT.id,ASI_MFM_Sequence__c=1);
        rrdList.add(rrd);
        ASI_MFM_Route_Rule_Detail__c rrds = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=poRT.id,ASI_MFM_Sequence__c=1);
        RRDList.add(rrds);
        
        insert rrdList;
        
        //Brand RT Map
        List<ASI_MFM_Brand_Route_Type_Map__c> brtList = new List<ASI_MFM_Brand_Route_Type_Map__c>();
        ASI_MFM_Brand_Route_Type_Map__c planBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = px.Id);
        ASI_MFM_Brand_Route_Type_Map__c poBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = pxo.Id);
        brtList.add(planBRT);
        brtList.add(poBRT); 
        insert brtList;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final',ASI_MFM_Approver_1__c=u.id);
        insert p1;
   
        
         
        
        
        // Create PO
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TR_Customer'),Name='Name3');        
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TR_Supplier'),Name='Name2'); 
        insert acc1;
        
        test.startTest();
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Responsible_By__c=u.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TR_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),ASI_MFM_Currency__c='HKD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addMonths(2), ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_MFM_TR_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true);
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),ASI_MFM_Complete__c = true,ASI_MFM_Amount__c=123);// ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,   
        insert poi;
        
        
        

        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('status', 'draft');   // change status as draft
        ASI_MFM_SetPOStatusController ext1 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext1.setStatus();
        
        
        test.stopTest();
    }
    
    
  
    static testMethod void SetPOSatus_Test() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='ASI_TR_Purchasing');
        insert Role_Test;
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', UserRoleid =Role_Test.id,
                          LocaleSidKey='en_US', ProfileId = p.Id,ASI_MFM_Country__c = 'TR',BypassTriggers__c='ASI_MFM_TR_ByPassTrigger',
                          TimeZoneSidKey='America/Los_Angeles', UserName='test4@tasdf.com');
        insert u;
        
        System.runAs(u){ 
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='HKD',ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='TR', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        // Set Plan Prefix
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='TR14', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c='ASI_TR_Purchasing');
        insert pr;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Plan');
        insert rt;
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id,ASI_MFM_Responsible_By__c=u.id);
        insert rtm;
        
        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final',ASI_MFM_Approver_1__c=u.id);
        insert p1;
        //Set PO prefix
        px = new ASI_MFM_Prefix__c(name='TRPO', ASI_MFM_Module__c='PO',ASI_MFM_Region__c=true );
        insert px;
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c='ASI_TR_Purchasing');
        insert pr;
        
        ASI_MFM_Route_Type__c rts = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rts;
        
        ASI_MFM_Brand_Route_Type_Map__c rtms = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rts.id, ASI_MFM_Prefix__c=px.id,ASI_MFM_Responsible_By__c=u.id);
        insert rtms;
        
        // ASI MFM  PO Route Rule Details Set Approver 
        List<ASI_MFM_Route_Rule_Detail__c> RRDList= new List<ASI_MFM_Route_Rule_Detail__c> ();
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        RRDList.add(rrd);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrd2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=3, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
        RRDList.add(rrd3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=4, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
        RRDList.add(rrd4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=5, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
        RRDList.add(rrd5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=6, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        RRDList.add(rrd6); 
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=7, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        RRDList.add(rrd7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=8, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        RRDList.add(rrd8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=9, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        RRDList.add(rrd9);
        ASI_MFM_Route_Rule_Detail__c rrd10 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=100, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=10);
        RRDList.add(rrd10);
        ASI_MFM_Route_Rule_Detail__c rrds = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=1);
        RRDList.add(rrds);
        ASI_MFM_Route_Rule_Detail__c rrds2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds2);
        ASI_MFM_Route_Rule_Detail__c rrds3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=3, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds3);
        ASI_MFM_Route_Rule_Detail__c rrds4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=4, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds4);
        ASI_MFM_Route_Rule_Detail__c rrds5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=5, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds5);
        ASI_MFM_Route_Rule_Detail__c rrds6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=6, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds6);
        ASI_MFM_Route_Rule_Detail__c rrds7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=7, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds7);
        ASI_MFM_Route_Rule_Detail__c rrds8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=8, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds8);
        ASI_MFM_Route_Rule_Detail__c rrds9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=9, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds9);
        ASI_MFM_Route_Rule_Detail__c rrds10 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        RRDList.add(rrds10);
        insert RRDList;
        
        
        
        // Create PO
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');  
        List<Account> AccList = new List<Account>();
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TR_Customer'),Name='Name3');        
        AccList.add(acc2);
        
        Account acc1 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TR_Supplier'),Name='Name2'); 
        AccList.add(acc1);
        insert AccList;
        
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Responsible_By__c=u.Id,
                                             recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TR_PO'),
                                             ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id,
                                             ASI_MFM_Status__c ='Final',
                                             ASI_MFM_PO_Raised_Date__c=date.today(),ASI_MFM_Currency__c='HKD',
                                             ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addMonths(2),
                                             ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_MFM_TR_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true);
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'),
                                                                  ASI_MFM_PO__c=po.id,
                                                                  ASI_MFM_A_C_Code__c=ac.id, 
                                                                  ASI_MFM_Customer_Name__c=acc2.id, 
                                                                  ASI_MFM_List_Item_Description__c='testDescription',
                                                                  ASI_MFM_Sub_brand_Code__c=sub.id, 
                                                                  ASI_MFM_G_L_Date__c = Date.today(),
                                                                  ASI_MFM_Synced__c=true,
                                                                  ASI_MFM_Complete__c = true,ASI_MFM_Amount__c=123);  
        insert poi;
        
        ASI_MFM_PO_Receipt__c POR =new ASI_MFM_PO_Receipt__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_TR_PO_Receipt'),
                                                             ASI_MFM_PO__c=po.id,ASI_MFM_Status__c='Draft');
        insert POR;
        
        test.startTest();
        System.debug(Limits.getDMLRows());
        
        List<ASI_MFM_PO_Receipt_Item__c> PORIList = new List<ASI_MFM_PO_Receipt_Item__c>();
        ASI_MFM_PO_Receipt_Item__c PORI = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_TR_PO_Receipt_item'),
                                                                         ASI_MFM_Amount__c=10,
                                                                         ASI_MFM_PO_Receipt__c=POR.id,
                                                                         ASI_MFM_PO_Line_Item__c=poi.id,
                                                                         ASI_MFM_ACC_Verify__c =false,ASI_MFM_Receipt_Date__c=date.today());
        PORIList.add(PORI);
        ASI_MFM_PO_Receipt_Item__c PORI2 = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_TR_PO_Receipt_item'),
                                                                          ASI_MFM_Amount__c=10,ASI_MFM_PO_Receipt__c=POR.id,
                                                                          ASI_MFM_PO_Line_Item__c=poi.id,
                                                                          ASI_MFM_ACC_Verify__c =true,
                                                                          ASI_MFM_Receipt_Date__c=date.today());
        PORIList.add(PORI2);
        insert PORIList;
        
        // Test Start
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.currentPage().getParameters().put('status', 'Voided');  
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext2.setStatus();
        
        test.stopTest();
        }
    }
    
    
    
    static testMethod void SetPOSatus_Test2() {
       // test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());
       
            
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='ASI_TR_Purchasing');
        insert Role_Test;
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', UserRoleid =Role_Test.id,
                          LocaleSidKey='en_US', ProfileId = p.Id,ASI_MFM_Country__c = 'TR',BypassTriggers__c='ASI_MFM_TR_ByPassTrigger',
                          TimeZoneSidKey='America/Los_Angeles', UserName='test4@tasdf.com');
        insert u;
        
        System.runAs(u){ 
            
            ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='HKD',ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='TR', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
            insert xr;         
            
            // Set Plan Prefix
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='TR14', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
            insert px;
            ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c='ASI_TR_Purchasing');
            insert pr;
            
            ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Plan');
            insert rt;
            ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id,ASI_MFM_Responsible_By__c=u.id);
            insert rtm;
            
            
            
            ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                     ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName',
                                                     ASI_MFM_Status__c = 'Final',ASI_MFM_Approver_1__c=u.id);
            insert p1;
            //Set PO prefix
            px = new ASI_MFM_Prefix__c(name='TRPO', ASI_MFM_Module__c='PO',ASI_MFM_Region__c=true );
            insert px;
            pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c='ASI_TR_Purchasing');
            insert pr;
            
            ASI_MFM_Route_Type__c rts = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
            insert rts;
            
            ASI_MFM_Brand_Route_Type_Map__c rtms = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rts.id, ASI_MFM_Prefix__c=px.id,ASI_MFM_Responsible_By__c=u.id);
            insert rtms;
            
            // ASI MFM  PO Route Rule Details Set Approver 
            List<ASI_MFM_Route_Rule_Detail__c> RRDList= new List<ASI_MFM_Route_Rule_Detail__c> ();
            ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
            RRDList.add(rrd);
            ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrd2);
            ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=3, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
            RRDList.add(rrd3);
            ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=4, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
            RRDList.add(rrd4);
            ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=5, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
            RRDList.add(rrd5);
            ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=6, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
            RRDList.add(rrd6); 
            ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=7, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
            RRDList.add(rrd7);
            ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=8, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
            RRDList.add(rrd8);
            ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=9, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
            RRDList.add(rrd9);
            ASI_MFM_Route_Rule_Detail__c rrd10 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=100, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=10);
            RRDList.add(rrd10);
            ASI_MFM_Route_Rule_Detail__c rrds = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=1);
            RRDList.add(rrds);
            ASI_MFM_Route_Rule_Detail__c rrds2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds2);
            ASI_MFM_Route_Rule_Detail__c rrds3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=3, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds3);
            ASI_MFM_Route_Rule_Detail__c rrds4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=4, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds4);
            ASI_MFM_Route_Rule_Detail__c rrds5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=5, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds5);
            ASI_MFM_Route_Rule_Detail__c rrds6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=6, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds6);
            ASI_MFM_Route_Rule_Detail__c rrds7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=7, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds7);
            ASI_MFM_Route_Rule_Detail__c rrds8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=8, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds8);
            ASI_MFM_Route_Rule_Detail__c rrds9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=9, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds9);
            ASI_MFM_Route_Rule_Detail__c rrds10 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
            RRDList.add(rrds10);
            insert RRDList;
            
            
            
            // Create PO
            map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');  
            List<Account> AccList = new List<Account>();
            Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TR_Customer'),Name='Name3');        
            AccList.add(acc2);
            
            Account acc1 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TR_Supplier'),Name='Name2'); 
            AccList.add(acc1);
            insert AccList;
            
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Responsible_By__c=u.Id,
                                                 recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TR_PO'),
                                                 ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id,
                                                 ASI_MFM_Status__c ='Final',
                                                 ASI_MFM_PO_Raised_Date__c=date.today(),ASI_MFM_Currency__c='HKD',
                                                 ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addMonths(2),
                                                 ASI_MFM_Supplier_Name__c = acc1.id);
            insert po;
            
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
            insert ac;
            
            Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_MFM_TR_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true);
            insert sub;
            
            ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'),
                                                                      ASI_MFM_PO__c=po.id,
                                                                      ASI_MFM_A_C_Code__c=ac.id, 
                                                                      ASI_MFM_Customer_Name__c=acc2.id, 
                                                                      ASI_MFM_List_Item_Description__c='testDescription',
                                                                      ASI_MFM_Sub_brand_Code__c=sub.id, 
                                                                      ASI_MFM_G_L_Date__c = Date.today(),
                                                                      ASI_MFM_Complete__c = true,ASI_MFM_Amount__c=123);  
            insert poi;
            
            ASI_MFM_PO_Receipt__c POR =new ASI_MFM_PO_Receipt__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_TR_PO_Receipt'),
                                                                 ASI_MFM_PO__c=po.id,ASI_MFM_Status__c='Draft');
            insert POR;
            
            test.startTest();
            System.debug(Limits.getDMLRows());
            
            List<ASI_MFM_PO_Receipt_Item__c> PORIList = new List<ASI_MFM_PO_Receipt_Item__c>();
            ASI_MFM_PO_Receipt_Item__c PORI = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_TR_PO_Receipt_item'),
                                                                             ASI_MFM_Amount__c=10,
                                                                             ASI_MFM_PO_Receipt__c=POR.id,
                                                                             ASI_MFM_PO_Line_Item__c=poi.id,
                                                                             ASI_MFM_ACC_Verify__c =false,ASI_MFM_Receipt_Date__c=date.today());
            PORIList.add(PORI);
            ASI_MFM_PO_Receipt_Item__c PORI2 = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_TR_PO_Receipt_item'),
                                                                              ASI_MFM_Amount__c=10,ASI_MFM_PO_Receipt__c=POR.id,
                                                                              ASI_MFM_PO_Line_Item__c=poi.id,
                                                                              ASI_MFM_ACC_Verify__c =true,
                                                                              ASI_MFM_Receipt_Date__c=date.today());
            PORIList.add(PORI2);
            insert PORIList;
            
            // Test Start
            
            PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('status', 'Voided');  
            ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
            ext2.setStatus();
            
            test.stopTest();
            
        }
    }
    */
    
    
    static testMethod void ASI_MFM_GF_PDFTestSetPOSatus() {
        Test.setCurrentPage(Page.ASI_MFM_PODetailPage);
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test3',
                                                 ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', 
                                                 ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id);
        insert p3;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item'), ASI_MFM_Plan__c=p3.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        insert acc1;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        Test.startTest();
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), 
                                             ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, 
                                             ASI_MFM_Status__c ='Final',ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
                                                                  ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100);
        insert poi;
        
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Draft');  
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext2.setStatus();
        
        
        test.stopTest(); 
    }
    
    
    
    static testMethod void ASI_MFM_GF_PDFTestSetPOSatus2() {
        Test.setCurrentPage(Page.ASI_MFM_PODetailPage);
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test3',
                                                 ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', 
                                                 ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id);
        insert p3;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item'), ASI_MFM_Plan__c=p3.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        insert acc1;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        Test.startTest();
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), 
                                             ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, 
                                             ASI_MFM_Status__c ='Final',ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
                                                                  ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100);
        insert poi;
        
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Complete');  //
        ApexPages.currentPage().getParameters().put('createdLine', 'No');
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext2.setStatus();
        
        
        test.stopTest(); 
    }
    
    
    static testMethod void ASI_MFM_GF_PDFTestSetPOSatus3() {
        Test.setCurrentPage(Page.ASI_MFM_PODetailPage);
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test3',
                                                 ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', 
                                                 ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id);
        insert p3;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item'), ASI_MFM_Plan__c=p3.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        insert acc1;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        Test.startTest();
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), 
                                             ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, 
                                             ASI_MFM_Status__c ='Final',ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
                                                                  ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100);
        insert poi;
        
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Complete');  //
        ApexPages.currentPage().getParameters().put('createdLine', 'Yes');
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext2.setStatus();
        
        
        test.stopTest(); 
    }
    
    
    static testMethod void ASI_MFM_GF_SetPOStatus() {
        Test.setCurrentPage(Page.ASI_MFM_PODetailPage);
        
        
        List<ASI_MFM_Prefix__c> PreList= new List<ASI_MFM_Prefix__c> ();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c = getFiscalYear());
        PreList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        PreList.add(pxo); 
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        PreList.add(pxa); 
        
        
        insert PreList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        
        List<ASI_MFM_Role_Prefix_Relationship__c> PrList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrList.add(pr);
            
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrList.add(pra);  
        
        insert PrList;
        
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test3',
                                                 ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', 
                                                 ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id);
        insert p3;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item'), ASI_MFM_Plan__c=p3.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        insert acc1;
        
      
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        Test.startTest();
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), 
                                             ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, 
                                             ASI_MFM_Status__c ='Final',ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
                                                                  ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100);
        insert poi;
        
        
        List<ASI_MFM_Payment__c> Paymentlist = new List<ASI_MFM_Payment__c>();
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment'), 
                                                       ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Pre_payment__c=true,
                                                       ASI_MFM_Supplier_Name__c = acc1.id);
        Paymentlist.add(py);
        
        ASI_MFM_Payment__c py2 = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment'), 
                                                        ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Pre_payment__c=true,
                                                        ASI_MFM_Status__c='Final',
                                                        ASI_MFM_Supplier_Name__c = acc1.id);
        Paymentlist.add(py2);
        insert Paymentlist;
        
        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_GF_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');                       
        
        pyi_list.add(pyi);
        insert pyi_list;
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Complete');  //
        ApexPages.currentPage().getParameters().put('createdLine', 'No');
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext2.setStatus();
        
        
        test.stopTest(); 
    }
    
    
    static testMethod void ASI_MFM_GF_SetPOStatus2() {
        Test.setCurrentPage(Page.ASI_MFM_PODetailPage);
        
        
        List<ASI_MFM_Prefix__c> PreList= new List<ASI_MFM_Prefix__c> ();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c = getFiscalYear());
        PreList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        PreList.add(pxo); 
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        PreList.add(pxa); 
        
        
        insert PreList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        
        List<ASI_MFM_Role_Prefix_Relationship__c> PrList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrList.add(pr);
            
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrList.add(pra);  
        
        insert PrList;
        
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test3',
                                                 ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', 
                                                 ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id);
        insert p3;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item'), ASI_MFM_Plan__c=p3.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        insert acc1;
        
      
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        Test.startTest();
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), 
                                             ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, 
                                             ASI_MFM_Status__c ='Final',ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
                                                                  ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100);
        insert poi;
        
        
        List<ASI_MFM_Payment__c> Paymentlist = new List<ASI_MFM_Payment__c>();
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment'), 
                                                       ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Pre_payment__c=true,ASI_MFM_Status__c='Final',
                                                       ASI_MFM_Supplier_Name__c = acc1.id);
        Paymentlist.add(py);
        
        ASI_MFM_Payment__c py2 = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment'), 
                                                        ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Pre_payment__c=true,
                                                        ASI_MFM_Status__c='Final',
                                                        ASI_MFM_Supplier_Name__c = acc1.id);
        Paymentlist.add(py2);
        insert Paymentlist;
        
        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_GF_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');                       
        
        pyi_list.add(pyi);
        insert pyi_list;
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Complete');  //
        ApexPages.currentPage().getParameters().put('createdLine', 'Yes');
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext2.setStatus();
        
      
        test.stopTest(); 
    }
    
    
    static testMethod void ASI_MFM_GF_SetPOStatus3() {
        Test.setCurrentPage(Page.ASI_MFM_PODetailPage);
        
        
        List<ASI_MFM_Prefix__c> PreList= new List<ASI_MFM_Prefix__c> ();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c = getFiscalYear());
        PreList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        PreList.add(pxo); 
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        PreList.add(pxa); 
        
        
        insert PreList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        
        List<ASI_MFM_Role_Prefix_Relationship__c> PrList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrList.add(pr);
            
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrList.add(pra);  
        
        insert PrList;
        
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test3',
                                                 ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', 
                                                 ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id);
        insert p3;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item'), ASI_MFM_Plan__c=p3.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        insert acc1;
        
      
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        Test.startTest();
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), 
                                             ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, 
                                             ASI_MFM_Status__c ='Final',ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
                                                                  ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100);
        insert poi;
        
        
        List<ASI_MFM_Payment__c> Paymentlist = new List<ASI_MFM_Payment__c>();
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment'), 
                                                       ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Pre_payment__c=true,ASI_MFM_Status__c='Final',
                                                       ASI_MFM_Supplier_Name__c = acc1.id);
        Paymentlist.add(py);
       
        insert Paymentlist;
        
        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_GF_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');                       
        
        pyi_list.add(pyi);
        insert pyi_list;
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Complete');  //
        ApexPages.currentPage().getParameters().put('createdLine', 'No');
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext2.setStatus();
        
        
        test.stopTest(); 
    }
    
    
    static testMethod void ASI_MFM_GF_SetPOStatus4() {
        Test.setCurrentPage(Page.ASI_MFM_PODetailPage);
        
        
        List<ASI_MFM_Prefix__c> PreList= new List<ASI_MFM_Prefix__c> ();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c = getFiscalYear());
        PreList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        PreList.add(pxo); 
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        PreList.add(pxa); 
        
        
        insert PreList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        
        List<ASI_MFM_Role_Prefix_Relationship__c> PrList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrList.add(pr);
            
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrList.add(pra);  
        
        insert PrList;
        
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test3',
                                                 ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', 
                                                 ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id);
        insert p3;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item'), ASI_MFM_Plan__c=p3.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        insert acc1;
        
      
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
       
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), 
                                             ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, 
                                             ASI_MFM_Status__c ='Final',ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
                                                                  ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100);
        insert poi;
        
        
      
       

        
        List<ASI_MFM_Payment__c> Paymentlist = new List<ASI_MFM_Payment__c>();
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment'), 
                                                       ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Pre_payment__c=true,ASI_MFM_Status__c='Final',
                                                       ASI_MFM_Supplier_Name__c = acc1.id);
        Paymentlist.add(py);
        
        ASI_MFM_Payment__c py2 = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment'), 
                                                        ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Pre_payment__c=true,
                                                        ASI_MFM_Status__c='Final',
                                                        ASI_MFM_Supplier_Name__c = acc1.id);
        Paymentlist.add(py2);
        insert Paymentlist;
        
        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_GF_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');                       
        
        pyi_list.add(pyi);
        insert pyi_list;
        
           ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_PO__c = po.id,
                                                                     ASI_MFM_Status__c = 'Draft',
                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_GF_PO_Receipt'));
        insert POR_Header;
        
        
         LIST<ASI_MFM_PO_Receipt_Item__c> PORList = NEW LIST<ASI_MFM_PO_Receipt_Item__c>();
        ASI_MFM_PO_Receipt_Item__c POR_Line = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                              ASI_MFM_PO_Line_Item__c = poi.id,
                                                                              ASI_MFM_Quantity__c = 1,
                                                                              ASI_MFM_PO__c = po.id,
                                                                              ASI_MFM_Paid__c= false,
                                                                              ASI_MFM_Amount__c = 1,
                                                                              recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_GF_PO_Receipt_item'));
        PORList.ADD(POR_Line);
        
        ASI_MFM_PO_Receipt_Item__c POR_Line2 = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                               ASI_MFM_PO_Line_Item__c = poi.id,
                                                                               ASI_MFM_Quantity__c = 1,
                                                                               ASI_MFM_PO__c = po.id,
                                                                               ASI_MFM_Paid__c = false,
                                                                               ASI_MFM_Amount__c = 1,
                                                                               recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_GF_PO_Receipt_item'));
        PORList.ADD(POR_Line2);
        INSERT PORList;
        
        
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Complete');  //
        ApexPages.currentPage().getParameters().put('createdLine', 'No');
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext2.setStatus();
        
      
        test.stopTest(); 
    }
    
    static testMethod void THSetPOSatus_Test() {
           Test.setCurrentPage(Page.ASI_MFM_TH_BAVerify);
        // Start Plan
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c'); 
        map<string, id> pxrt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c'); 
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415', recordTypeId = pxrt_map.get('ASI_MFM_TH_Prefix'), ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
        insert px;    
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        List<ASI_MFM_Plan__c> plist = new List<ASI_MFM_Plan__c>();
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), name='test', ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c=Date.today().addMonths(3), ASI_MFM_Plan_Description__c='testPlanDescription',ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Plan_Raised_Date__c=Date.today(), ASI_MFM_Status__c = 'Final');
        plist.add(p);
        
        ASI_MFM_Plan__c p3 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), name='test3', ASI_MFM_Prefix__c=px.id,ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription3', ASI_MFM_Plan_Name__c='testPlan3', ASI_MFM_Start_Date__c=Date.today());
        plist.add(p3);
        insert plist;
        // Start PO
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true);
        insert subBrand1;
        System.debug(Limits.getDMLRows());
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        System.debug(Limits.getDMLRows());
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> acclist = new List<Account>();
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Customer'),Name='Name3');           
        acclist.add(acc2);
        
        Account acc1 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1');     //ASI_MFM_SG_Supplier            
        acclist.add(acc1);
        insert acclist;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');             
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'), name='test',
                                             ASI_MFM_Is_FOC_PO__c=true,
                                             ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c = 'Draft'); 
        insert po;
        
        
        // Start PO line Items
        acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Customer'),Name='Name3');           
        insert acc2;
        Test.startTest();
        System.debug(Limits.getDMLRows());
        
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true);// ASI_HK_CRM_Sub_brand    ASI_TH_CRM_Outlet
        insert sub;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),ASI_MFM_SG_BA_verify__c = true);
        insert poi;
        
                
        
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('status', 'Final');  
        ASI_MFM_SetPOStatusController ext2 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext2.setStatus();
        
        
        test.stopTest(); 
        
        
    }
    
    static testMethod void PHSetPOSatus_Test() {
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=ASI_MFM_PH_TestClassHelper.getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        insert prefixList;
        
        
        
        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);

        insert RPList;
        
          
		//Route Type
		List<ASI_MFM_Route_Type__c> rtList = new List<ASI_MFM_Route_Type__c>();
		ASI_MFM_Route_Type__c planRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'Plan', Name = 'Plan RT');
		ASI_MFM_Route_Type__c poRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'PO', Name = 'PO RT');
		ASI_MFM_Route_Type__c paymentRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'Payment', Name = 'Payment RT');
		rtList.add(planRT);
		rtList.add(poRT);
		rtList.add(paymentRT);
		insert rtList;
		
		//Route Rule Details 
		List<ASI_MFM_Route_Rule_Detail__c> rrdList = new List<ASI_MFM_Route_Rule_Detail__c>();
		ASI_MFM_Route_Rule_Detail__c planRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c poRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		
		ASI_MFM_Route_Rule_Detail__c paymentRRD1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);	
		ASI_MFM_Route_Rule_Detail__c paymentRRD10 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);	
		
		rrdList.add(paymentRRD1);
		rrdList.add(paymentRRD2);
		rrdList.add(paymentRRD3);
		rrdList.add(paymentRRD4);
		rrdList.add(paymentRRD5);
		rrdList.add(paymentRRD6);
		rrdList.add(paymentRRD7);
		rrdList.add(paymentRRD8);
		rrdList.add(paymentRRD9);
		rrdList.add(paymentRRD10);

		
		rrdList.add(planRRD);
		rrdList.add(poRRD);
		
		insert rrdList;
        		
		//Brand RT Map
		List<ASI_MFM_Brand_Route_Type_Map__c> brtList = new List<ASI_MFM_Brand_Route_Type_Map__c>();
		ASI_MFM_Brand_Route_Type_Map__c planBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = px.Id);
        ASI_MFM_Brand_Route_Type_Map__c poBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = pxo.Id);
        brtList.add(planBRT);
        brtList.add(poBRT); 
		insert brtList;
        
        
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
       
        ASI_MFM_A_C_Code__c ac = ASI_MFM_PH_TestClassHelper.createACPHDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_PH_TestClassHelper.CreateDFSBrand();
        
        // Create Plan 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),ASI_MFM_Currency__c='SGD',
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
   
        // Create PO
          
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DF_PO'), 
        ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, 
                                             ASI_MFM_Is_FOC_PO__c=true,ASI_MFM_Status__c = 'Draft');
        insert po;
        
        
        
        // Create PO line Items
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(poi);                                                          
        insert poLineList;
  

        
        
        
        Test.startTest();
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('status', 'Complete');   // change status as draft
        ASI_MFM_SetPOStatusController ext1 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext1.setStatus();
        test.stopTest(); 
    }
    
    
   //Test ASI_MFM_ObjectPickListHelper
   
   static testMethod void ObjectPickListHelper_Test() {
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'TW';
        update u;
        
        List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', 
        Plan_Type__c='Marketing A&P Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxp);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxo);
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxy);
        insert prList;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        insert rprList;
        
         ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC',ASI_MFM_A_and_P_Tree__c='TOTAL A&P');
        insert ac;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), name='testAP');
        insert ap;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand',ASI_CRM_TW_Company__c='PRT', ASI_CRM_Active__c=TRUE, ASI_TH_CRM_Active__c=TRUE,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'));
        insert sub;
        
        List<Account> acctList = new List<Account>();     
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name3')); 
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), Name='Name2'));
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), Name='Name3'));       
        insert acctList;
        
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        insert listPlan;      
        
        List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing1',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Total_Cost__c=1000));
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing2',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_Total_Cost__c=2000));
        insert listPL;
        
        
       Test.startTest();
       ASI_MFM_ObjectPickListHelper  objectPickListHelper = new ASI_MFM_ObjectPickListHelper('ASI_MFM_Plan_Line_Item__c','ASI_MFM_A_C_Code__c','=\''+listPlan[0].Id+'\'');
       test.stopTest(); 
       
   }
   
   
     static testMethod void ObjectPickListHelper_Test2() {
       user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'TW';
        update u;
        
        List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', 
        Plan_Type__c='BC Type Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxp);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxo);
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxy);
        insert prList;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        insert rprList;
        
         ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC',ASI_MFM_A_and_P_Tree__c='TOTAL A&P');
        insert ac;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), name='testAP');
        insert ap;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand',ASI_CRM_TW_Company__c='PRT', ASI_CRM_Active__c=TRUE, ASI_TH_CRM_Active__c=TRUE,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'));
        insert sub;
        
        List<Account> acctList = new List<Account>();     
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name3')); 
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), Name='Name2'));
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), Name='Name3'));       
        insert acctList;
        
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        insert listPlan;      
        
        List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing1',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Total_Cost__c=1000));
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing2',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_Total_Cost__c=2000));
        insert listPL;
        
        
       Test.startTest();
       ASI_MFM_ObjectPickListHelper  objectPickListHelper = new ASI_MFM_ObjectPickListHelper('ASI_MFM_Plan_Line_Item__c','ASI_MFM_A_C_Code__c','=\''+listPlan[0].Id+'\'');
       test.stopTest(); 
       
   }
   
     static testMethod void ObjectPickListHelper_Test3() {
       user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'TW';
        update u;
        
        List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', 
        Plan_Type__c='Legal Contract',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxp);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxo);
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxy);
        insert prList;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        insert rprList;
        
         ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC',ASI_MFM_A_and_P_Tree__c='TOTAL A&P');
        insert ac;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), name='testAP');
        insert ap;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand',ASI_CRM_TW_Company__c='PRT', ASI_CRM_Active__c=TRUE, ASI_TH_CRM_Active__c=TRUE,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'));
        insert sub;
        
        List<Account> acctList = new List<Account>();     
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name3')); 
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), Name='Name2'));
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), Name='Name3'));       
        insert acctList;
        
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        insert listPlan;      
        
        List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing1',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Total_Cost__c=1000));
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing2',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_Total_Cost__c=2000));
        insert listPL;
        
        
       Test.startTest();
       ASI_MFM_ObjectPickListHelper  objectPickListHelper = new ASI_MFM_ObjectPickListHelper('ASI_MFM_Plan_Line_Item__c','ASI_MFM_A_C_Code__c','=\''+listPlan[0].Id+'\'');
       test.stopTest(); 
       
   }
   
     static testMethod void ObjectPickListHelper_Test4() {
       user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'TW';
        update u;
        
        List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', 
        Plan_Type__c='Allowance & Discount Spending Form',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxp);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxo);
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxy);
        insert prList;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        insert rprList;
        
         ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC',ASI_MFM_A_and_P_Tree__c='TOTAL A&P');
        insert ac;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), name='testAP');
        insert ap;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand',ASI_CRM_TW_Company__c='PRT', ASI_CRM_Active__c=TRUE, ASI_TH_CRM_Active__c=TRUE,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'));
        insert sub;
        
        List<Account> acctList = new List<Account>();     
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name3')); 
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), Name='Name2'));
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), Name='Name3'));       
        insert acctList;
        
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        insert listPlan;      
        
        List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing1',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Total_Cost__c=1000));
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing2',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_Total_Cost__c=2000));
        insert listPL;
        
        
       Test.startTest();
       ASI_MFM_ObjectPickListHelper  objectPickListHelper = new ASI_MFM_ObjectPickListHelper('ASI_MFM_Plan_Line_Item__c','ASI_MFM_A_C_Code__c','=\''+listPlan[0].Id+'\'');
       test.stopTest(); 
       
   }
   
   
   
     static testMethod void ObjectPickListHelper_Test5() {
       user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'TW';
        update u;
        
        List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', 
        Plan_Type__c='XXX',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxp);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxo);
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxy);
        insert prList;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        insert rprList;
        
         ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC',ASI_MFM_A_and_P_Tree__c='TOTAL A&P');
        insert ac;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), name='testAP');
        insert ap;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand',ASI_CRM_TW_Company__c='PRT', ASI_CRM_Active__c=TRUE, ASI_TH_CRM_Active__c=TRUE,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'));
        insert sub;
        
        List<Account> acctList = new List<Account>();     
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name3')); 
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), Name='Name2'));
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), Name='Name3'));       
        insert acctList;
        
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        insert listPlan;      
        
        List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing1',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Total_Cost__c=1000));
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing2',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_Total_Cost__c=2000));
        insert listPL;
        
        
       Test.startTest();
       ASI_MFM_ObjectPickListHelper  objectPickListHelper = new ASI_MFM_ObjectPickListHelper('ASI_MFM_Plan_Line_Item__c','ASI_MFM_A_C_Code__c','=\''+listPlan[0].Id+'\'');
       test.stopTest(); 
       
   }
   
   
   
     static testMethod void ObjectPickListHelper_Test6() {
       user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'TW';
        update u;
        
        List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', 
        Plan_Type__c='Trade A&P Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxp);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxo);
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxy);
        insert prList;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        insert rprList;
        
         ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC',ASI_MFM_A_and_P_Tree__c='TOTAL A&P');
        insert ac;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), name='testAP');
        insert ap;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand',ASI_CRM_TW_Company__c='PRT', ASI_CRM_Active__c=TRUE, ASI_TH_CRM_Active__c=TRUE,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'));
        insert sub;
        
        List<Account> acctList = new List<Account>();     
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name3')); 
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), Name='Name2'));
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), Name='Name3'));       
        insert acctList;
        
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        insert listPlan;      
        
        List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing1',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Total_Cost__c=1000));
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing2',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_Total_Cost__c=2000));
        insert listPL;
        
        
       Test.startTest();
       ASI_MFM_ObjectPickListHelper  objectPickListHelper = new ASI_MFM_ObjectPickListHelper('ASI_MFM_Plan_Line_Item__c','ASI_MFM_A_C_Code__c','=\''+listPlan[0].Id+'\'');
       test.stopTest(); 
       
   }
   
     static testMethod void ObjectPickListHelper_Test7() {
       user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'TW';
        update u;
        
        List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', 
        Plan_Type__c='Trade A&P and A&D Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxp);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxo);
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxy);
        insert prList;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        insert rprList;
        
         ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC',ASI_MFM_A_and_P_Tree__c='TOTAL A&P');
        insert ac;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), name='testAP');
        insert ap;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand',ASI_CRM_TW_Company__c='PRT', ASI_CRM_Active__c=TRUE, ASI_TH_CRM_Active__c=TRUE,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'));
        insert sub;
        
        List<Account> acctList = new List<Account>();     
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name3')); 
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), Name='Name2'));
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), Name='Name3'));       
        insert acctList;
        
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        insert listPlan;      
        
        List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing1',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Total_Cost__c=1000));
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing2',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_Total_Cost__c=2000));
        insert listPL;
        
        
       Test.startTest();
       ASI_MFM_ObjectPickListHelper  objectPickListHelper = new ASI_MFM_ObjectPickListHelper('ASI_MFM_Plan_Line_Item__c','ASI_MFM_A_C_Code__c','=\''+listPlan[0].Id+'\'');
      ASI_MFM_ObjectPickListHelper objectPickListHelper2 = new ASI_MFM_objectPickListHelper('ASI_MFM_Plan__c',' id =\''+listPlan[0].Id+'\'' , '','ASI_MFM_PP_Category__r', 'ASI_MFM_PP_Category_A_C__c' ,'ASI_MFM_A_C_Code__r'  ,true);
       ASI_MFM_ObjectPickListHelper objectPickListHelper3 = new ASI_MFM_objectPickListHelper('ASI_MFM_Plan_Line_Item__c',' ASI_MFM_Plan__c =\''+listPlan[0].Id+'\' ' , '','ASI_MFM_A_C_Code__r'  ,true);
      
       test.stopTest(); 
       
   }
   
    
    
      static testMethod void ObjectPickListHelper_Test8() {
       user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'TW';
        update u;
        
        List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', 
        Plan_Type__c='Mixed Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxp);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxo);
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxy);
        insert prList;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        insert rprList;
        
         ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC',ASI_MFM_A_and_P_Tree__c='TOTAL A&P');
        insert ac;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), name='testAP');
        insert ap;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand',ASI_CRM_TW_Company__c='PRT', ASI_CRM_Active__c=TRUE, ASI_TH_CRM_Active__c=TRUE,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'));
        insert sub;
        
        List<Account> acctList = new List<Account>();     
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name3')); 
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), Name='Name2'));
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), Name='Name3'));       
        insert acctList;
        
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        insert listPlan;      
        
        List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing1',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Total_Cost__c=1000));
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing2',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_Total_Cost__c=2000));
        insert listPL;
        
        
       Test.startTest();
       ASI_MFM_ObjectPickListHelper  objectPickListHelper = new ASI_MFM_ObjectPickListHelper('ASI_MFM_Plan_Line_Item__c','ASI_MFM_A_C_Code__c','=\''+listPlan[0].Id+'\'');
       ASI_MFM_ObjectPickListHelper  objectPickListHelper2 = new ASI_MFM_ObjectPickListHelper('ASI_MFM_Plan_Line_Item__c','ASI_MFM_A_C_Code__c');
        
       ASI_MFM_ObjectPickListHelper objectPickListHelper3 = new ASI_MFM_objectPickListHelper('ASI_MFM_Plan_Line_Item__c','ASI_MFM_A_C_Code__c','',' recordtype.developername =\'ASI_JP_A_C_Code\'  ');
       test.stopTest(); 
       
   }
   
   
   
}