@isTest (SeeAllData=false)
public class ASI_MFM_MKTEXP_TestClass 
{
    public static String Current_Fiscal_year;

    static testMethod void TestBatch1() 
    {
        ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'TR',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='India', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        ASI_MFM_Route_Type__c rt2 = new ASI_MFM_Route_Type__c(name='testRT2',ASI_MFM_Module__c='Payment',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        insert rt2;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10000, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        ASI_MFM_Brand_Route_Type_Map__c rtm2 = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=px2.id );
        insert rtm;
        insert rtm2;

        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        ASI_MFM_Role_Prefix_Relationship__c pro2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr2= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt2.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&P'); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        insert poi;

        Test.startTest();
        ASI_MFM_Accrual_Request__c ar = new ASI_MFM_Accrual_Request__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Accrual_Request__cASI_MFM_MKTEXP_Accrual_Request')
            , ASI_MFM_Company_Code__c = '00326'
            , ASI_MFM_G_L_Date__c = Date.today().addDays(-20)
            , ASI_MFM_Interface_Method__c = 'Actual Marketing Expense Allocation'
            , ASI_MFM_Status__c = 'Draft'
        );
        insert ar;

        ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment')
            , ASI_MFM_Accrual_Request__c = ar.ID
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = true
            , ASI_MFM_Currency__c = 'HKD'
            , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po.ID
            , ASI_MFM_PO_1_Amount__c = 1000
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = 1000
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_Status__c = 'Draft'
            , ASI_MFM_Credit_Note__c = true
            , ASI_MFM_AlternatePayee__c = acc2.ID
        );

        insert pm;

        List<ASI_MFM_Payment__c> pList = new List<ASI_MFM_Payment__c>();
        pList.add(pm);
        Set<ID> pIDs = new Set<ID>();
        pIDs.add(pm.ID);

        List<ASI_MFM_Accrual_Request__c> aList = new List<ASI_MFM_Accrual_Request__c>();
        aList.add(ar);
        Set<ID> arIDs = new Set<ID>();
        arIDs.add(ar.ID);

        ar.ASI_MFM_Status__c = 'Submitted';
        update ar;

        ar.ASI_MFM_Status__c = 'Snapshot Work In Progress';
        update ar;

        ar.ASI_MFM_Status__c = 'ETL Create Payment Completed';
        update ar;

        ASI_MFM_MKTEXP_Payment_Batch obj = new ASI_MFM_MKTEXP_Payment_Batch(pIDs);
        DataBase.executeBatch(obj, 1);

        Test.stopTest();
    }

    static testMethod void TestBatch2() 
    {
        ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'RM',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_RM_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_RM_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_RM_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_RM_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_RM_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_RM_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_RM_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326');
        insert bu;
        
        // ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_RM_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
        //     ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        // insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        // ASI_MFM_Route_Type__c rt2 = new ASI_MFM_Route_Type__c(name='testRT2',ASI_MFM_Module__c='Payment',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        // insert rt2;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_RM_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD',ASI_MFM_AP_AD__c = 'A&P'); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_RM_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        insert poi;

        Test.startTest();
        ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_RM_Payment')
            // , ASI_MFM_Accrual_Request__c = ar.ID
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = false
            , ASI_MFM_Currency__c = 'HKD'
            , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po.ID
            , ASI_MFM_PO_1_Amount__c = 1005
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = 1005
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_AlternatePayee__c = acc2.ID
            , ASI_MFM_PO_1_Remark__c = 'Testing DBNote'
            , ASI_MFM_Credit_Note__c = true
            , ASI_MFM_Status__c = 'Draft'
        );

        insert pm;

        List<ASI_MFM_Payment__c> pList = new List<ASI_MFM_Payment__c>();
        pList.add(pm);
        Set<ID> pIDs = new Set<ID>();
        pIDs.add(pm.ID);

        ASI_MFM_MKTEXP_Payment_Queue.add(pIDs);

    Test.stopTest();
    }

    static testMethod void TestBatch3() 
    {
       ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'TR',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&P'); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        insert poi;

        Test.startTest();
        ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment')
            // , ASI_MFM_Accrual_Request__c = ar.ID
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = false
            , ASI_MFM_Currency__c = 'HKD'
            , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po.ID
            , ASI_MFM_PO_1_Amount__c = 1005
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = 1005
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_Status__c = 'Draft'
        );

        insert pm;

        List<ASI_MFM_Payment__c> pList = new List<ASI_MFM_Payment__c>();
        pList.add(pm);
        Set<ID> pIDs = new Set<ID>();
        pIDs.add(pm.ID);

        ASI_MFM_MKTEXP_Payment_Batch obj = new ASI_MFM_MKTEXP_Payment_Batch(pIDs);
        DataBase.executeBatch(obj, 1);

    Test.stopTest();
    }

    static testMethod void TestBatch4() 
    {
       ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'TR',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&P'); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        insert poi;

        Test.startTest();
        ASI_MFM_Accrual_Request__c ar = new ASI_MFM_Accrual_Request__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Accrual_Request__cASI_MFM_MKTEXP_Accrual_Request')
            , ASI_MFM_Company_Code__c = '00326'
            , ASI_MFM_G_L_Date__c = Date.today()
            , ASI_MFM_Interface_Method__c = 'Actual Marketing Expense Allocation'
            , ASI_MFM_Status__c = 'Draft'
        );
        insert ar;

        ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment')
            , ASI_MFM_Accrual_Request__c = ar.ID
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = false
            , ASI_MFM_Currency__c = 'HKD'
            , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po.ID
            , ASI_MFM_PO_1_Amount__c = 1000
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = 1000
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_Status__c = 'Final'
            , ASI_MFM_PO_Receipt_Generation__c = true
            , ASI_MFM_Payment_Line_Generation__c = false
        );

        insert pm;

        ASI_MFM_PO_Receipt__c por = new ASI_MFM_PO_Receipt__c(
      RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_MKTEXP_TR_PO_Receipt'),
      ASI_MFM_Payment__c = pm.ID,
      ASI_MFM_Receipt_Date__c = pm.ASI_MFM_Invoice_Date__c,
      ASI_MFM_Remarks__c = 'Auto-created from ' + pm.Name,
      ASI_MFM_Status__c = 'Draft',
      ASI_MFM_Supplier__c = pm.ASI_MFM_Supplier_Name__c,
      Ownerid = pm.Ownerid,
      ASI_MFM_PO_Owner__c = pm.Ownerid
        );
        insert por;

        ASI_MFM_PO_Receipt_Item__c pori = new ASI_MFM_PO_Receipt_Item__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_MKTEXP_TR_PO_Receipt_Item'),
            ASI_MFM_PO_Receipt__c = por.ID,
            ASI_MFM_Sub_brand_temp__c = poi.ASI_MFM_Sub_brand_Code__c,
            ASI_MFM_A_C_Code_temp__c = poi.ASI_MFM_A_C_Code__c,
            ASI_MFM_AP_Code__c = poi.ASI_MFM_AP_Code__c,
            ASI_MFM_Plan_Line_Item__c = poi.ASI_MFM_Plan_Line_Item__c,
            ASI_MFM_PO_Line_Item__c = poi.ID,
            ASI_MFM_Amount__c = 1000
        );
        insert pori;

        Set<ID> pIDs = new Set<ID>();
        pIDs.add(pm.ID);

        // por.ASI_MFM_Status__c = 'Final';
        // update por;

        ASI_MFM_MKTEXP_Payment_Batch obj = new ASI_MFM_MKTEXP_Payment_Batch(pIDs);
        DataBase.executeBatch(obj, 1);

    Test.stopTest();
    }

    static testMethod void TestBatch5() 
    {
       ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'USD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 7,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'TR',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'USD', ASI_MFM_AP_AD__c = 'A&P'); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        insert poi;

        Test.startTest();
        ASI_MFM_Accrual_Request__c ar = new ASI_MFM_Accrual_Request__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Accrual_Request__cASI_MFM_MKTEXP_Accrual_Request')
            , ASI_MFM_Company_Code__c = '00326'
            , ASI_MFM_G_L_Date__c = Date.today()
            , ASI_MFM_Interface_Method__c = 'Actual Marketing Expense Allocation'
            , ASI_MFM_Status__c = 'ETL Create Payment Completed'
        );
        insert ar;

        ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment')
            , ASI_MFM_Accrual_Request__c = ar.ID
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = false
            , ASI_MFM_Currency__c = 'USD'
            // , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po.ID
            , ASI_MFM_PO_1_Amount__c = 1000
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = 1000
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_Status__c = 'Pending Goods/Service Receipt'
            , ASI_MFM_PO_Receipt_Generation__c = false
            , ASI_MFM_Payment_Line_Generation__c = false
            , ASI_MFM_OCR__c = false
        );

        insert pm;

        pm.ASI_MFM_Payment_Line_Generation__c = true;
        pm.ASI_MFM_Status__c = 'Pending Goods/Service Receipt';
        update pm;

        // pm.ASI_MFM_Status__c = 'Draft';
        // update pm;

        delete pm;

    Test.stopTest();
    }

    static testMethod void TestBatch6() 
    {
        ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'TR',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&P'); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        insert poi;

        Test.startTest();
        ASI_MFM_Accrual_Request__c ar = new ASI_MFM_Accrual_Request__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Accrual_Request__cASI_MFM_MKTEXP_Accrual_Request')
            , ASI_MFM_Company_Code__c = '00326'
            , ASI_MFM_G_L_Date__c = Date.today()
            , ASI_MFM_Interface_Method__c = 'Actual Marketing Expense Allocation'
            , ASI_MFM_Status__c = 'Draft'
        );
        insert ar;

        ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment')
            , ASI_MFM_Accrual_Request__c = ar.ID
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = true
            , ASI_MFM_Currency__c = 'HKD'
            , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po.ID
            , ASI_MFM_PO_1_Amount__c = 1000
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = 1000
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_Status__c = 'Draft'
        );

        insert pm;

        List<ASI_MFM_Payment__c> pList = new List<ASI_MFM_Payment__c>();
        pList.add(pm);
        Set<ID> pIDs = new Set<ID>();
        pIDs.add(pm.ID);

        List<ASI_MFM_Accrual_Request__c> aList = new List<ASI_MFM_Accrual_Request__c>();
        aList.add(ar);
        Set<ID> arIDs = new Set<ID>();
        arIDs.add(ar.ID);

        ASI_MFM_MKTEXP_Payment_Batch obj = new ASI_MFM_MKTEXP_Payment_Batch(pIDs);
        DataBase.executeBatch(obj, 1);
        Test.stopTest();
    }

    static testMethod void TestBatch7() 
    {
        ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'TR',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='India', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        ASI_MFM_Route_Type__c rt2 = new ASI_MFM_Route_Type__c(name='testRT2',ASI_MFM_Module__c='Payment',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        insert rt2;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10000, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        ASI_MFM_Brand_Route_Type_Map__c rtm2 = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=px2.id );
        insert rtm;
        insert rtm2;

        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        ASI_MFM_Role_Prefix_Relationship__c pro2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr2= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt2.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&P'); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        insert poi;

        Test.startTest();
        ASI_MFM_Accrual_Request__c ar = new ASI_MFM_Accrual_Request__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Accrual_Request__cASI_MFM_MKTEXP_Accrual_Request')
            , ASI_MFM_Company_Code__c = '00326'
            , ASI_MFM_G_L_Date__c = Date.today().addDays(-20)
            , ASI_MFM_Interface_Method__c = 'Actual Marketing Expense Allocation'
            , ASI_MFM_Status__c = 'Draft'
        );
        insert ar;

        ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment')
            , ASI_MFM_Accrual_Request__c = ar.ID
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = true
            , ASI_MFM_Currency__c = 'HKD'
            , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po.ID
            , ASI_MFM_PO_1_Amount__c = -100
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = -100
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_Status__c = 'Draft'
        );

        insert pm;

        List<ASI_MFM_Payment__c> pList = new List<ASI_MFM_Payment__c>();
        pList.add(pm);
        Set<ID> pIDs = new Set<ID>();
        pIDs.add(pm.ID);

        List<ASI_MFM_Accrual_Request__c> aList = new List<ASI_MFM_Accrual_Request__c>();
        aList.add(ar);
        Set<ID> arIDs = new Set<ID>();
        arIDs.add(ar.ID);

        ar.ASI_MFM_Status__c = 'Submitted';
        update ar;

        ar.ASI_MFM_Status__c = 'Snapshot Work In Progress';
        update ar;

        ar.ASI_MFM_Status__c = 'ETL Create Payment Completed';
        update ar;

        ASI_MFM_MKTEXP_Payment_Batch obj = new ASI_MFM_MKTEXP_Payment_Batch(pIDs);
        DataBase.executeBatch(obj, 1);

        Test.stopTest();
    }

    static testMethod void TestBatch8() 
    {
       ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'TR',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&D', ASI_MFM_Dummy_Vendor__c = true); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        insert poi;

        Test.startTest();
        ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment')
            // , ASI_MFM_Accrual_Request__c = ar.ID
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = false
            , ASI_MFM_Currency__c = 'HKD'
            , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po.ID
            , ASI_MFM_PO_1_Amount__c = 1000
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = 1000
            , ASI_MFM_Payment_Amount__c = 1000
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_Status__c = 'Draft'
        );

        insert pm;

        List<ASI_MFM_Payment__c> pList = new List<ASI_MFM_Payment__c>();
        pList.add(pm);
        Set<ID> pIDs = new Set<ID>();
        pIDs.add(pm.ID);

        ASI_MFM_MKTEXP_Payment_Batch obj = new ASI_MFM_MKTEXP_Payment_Batch(pIDs);
        DataBase.executeBatch(obj, 1);

    Test.stopTest();
    }

    static testMethod void TestBatch9() 
    {
        ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'TR',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Draft',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&P', ASI_MFM_Reference_2__c = 'CAPEX'); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        List<ASI_MFM_PO_Line_Item__c> poiList = new List<ASI_MFM_PO_Line_Item__c>();
        poiList.add(poi);
        
        insert poiList;

        Test.startTest();
        
        Apexpages.StandardController sc = new Apexpages.StandardController(po);
        ASI_MFM_MKTEXP_POCompleteController ext;

        try
        {
            ext = new ASI_MFM_MKTEXP_POCompleteController(sc);
        }
        catch (exception e)
        {
            po.ASI_MFM_Reference_2__c = '';
            po.ASI_MFM_Status__c = 'Final';
            update po;
        }

        ext.doComplete();
        
        Test.stopTest();
    }

    static testMethod void TestBatch10() 
    {
        ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'TR',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&P'); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        List<ASI_MFM_PO_Line_Item__c> poiList = new List<ASI_MFM_PO_Line_Item__c>();
        poiList.add(poi);

        insert poiList;

        Test.startTest();

        ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment')
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = true
            , ASI_MFM_Currency__c = 'HKD'
            , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po.ID
            , ASI_MFM_PO_1_Amount__c = 900
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = 900
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_Status__c = 'Submitted'
        );
        insert pm;

        ASI_MFM_Payment_Line_Item__c pmi = new ASI_MFM_Payment_Line_Item__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_MKTEXP_TR_Payment_Line_Item'),
            ASI_MFM_Sub_brand__c = poi.ASI_MFM_Sub_brand_Code__c,
            ASI_MFM_A_C_Code__c = poi.ASI_MFM_A_C_Code__c,
            ASI_MFM_AP_Code__c = poi.ASI_MFM_AP_Code__c,
            ASI_MFM_BU__c = poi.ASI_MFM_BU_Code__c,
            ASI_MFM_Payment__c = pm.ID,
            ASI_MFM_PO__c = po.ID,
            ASI_MFM_PO_Line_Item__c = poi.ID,
            ASI_MFM_PO_Receipt_Item__c = null,
            ASI_MFM_Invoice_Number__c = 'INO-1',
            ASI_MFM_Invoice_Date__c = pm.ASI_MFM_Invoice_Date__c,
            ASI_MFM_MKTEXP_Payment_Status__c = 'Finance Verified',
            ASI_MFM_Payment_Amount__c = 900,
            ASI_MFM_Paid_Amount_in_Base_Currency__c = 900,
            ASI_MFM_Paid_Amount_in_PO_Currency__c = 900,
            ASI_MFM_Accrual_Amount_Base_Currency__c = 900
        );
        insert pmi;

        // ASI_MFM_PO__c upo = [
        //     select ID, ASI_MFM_PaidAmount_in_BaseCurrency__c, ASI_MFM_Accrual_Amount__c, ASI_MFM_PO_Amount__c, ASI_MFM_Accrual_Prepayment_Amount__c, ASI_MFM_MKTEXP_PO_Balance__c, ASI_MFM_Reference_2__c, ASI_MFM_Status__c, ASI_MFM_FOC_PO_Remaining_Amount__c
        //     from ASI_MFM_PO__c where ID = :po.ID
        // ];
        
        Apexpages.StandardController sc = new Apexpages.StandardController(po);
        ASI_MFM_MKTEXP_PORelatedPaymentsCtrl ext = new ASI_MFM_MKTEXP_PORelatedPaymentsCtrl(sc);
        
        Test.stopTest();
    }

    static testMethod void TestBatch11() 
    {
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        insert acc;
        Blob b = Blob.valueOf('Test Data');  
          
        Attachment attach = new Attachment(
            ParentId = acc.Id,
            Name = 'Form01-test',
            Body = b
        );  
          
        try
        {
            insert attach;
        }
        catch(exception e)
        {

        }

        Test.startTest();

        ASI_MFM_MKTEXP_EmailAttachmentCtrl ctrl = new ASI_MFM_MKTEXP_EmailAttachmentCtrl();
        ctrl.currentHeaderId = acc.Id;

        List<Attachment> attachs = ctrl.getFileAttachments();
        
        Test.stopTest();
    }

    static testMethod void TestBatch12() 
    {
        ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'TR',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Draft',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&P'); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        List<ASI_MFM_PO_Line_Item__c> poiList = new List<ASI_MFM_PO_Line_Item__c>();
        poiList.add(poi);

        insert poiList;

        Test.startTest();
        try
        {
            ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment')
                , ASI_MFM_Actual_MKT_Expense_Allocation__c = true
                , ASI_MFM_Currency__c = 'HKD'
                , ASI_MFM_Exchange_Rate__c = 1
                , ASI_MFM_Invoice_Date__c = Date.today()
                , ASI_MFM_Invoice_Number__c = 'INV-Test01'
                , ASI_MFM_Payment_Date__c = Date.today()
                , ASI_MFM_PO_1__c = po.ID
                , ASI_MFM_PO_1_Amount__c = 900
                , ASI_MFM_Prefix__c = px2.ID
                , ASI_MFM_MKTEXP_Invoice_Amount__c = 900
                , ASI_MFM_Supplier_Name__c = acc1.ID
                , OwnerID = u.ID
                , ASI_MFM_Status__c = 'Draft'
            );
            insert pm;
        }
        catch (exception e)
        {

        }

        try
        {
            ASI_MFM_Payment__c pm2 = new ASI_MFM_Payment__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment')
                , ASI_MFM_Actual_MKT_Expense_Allocation__c = true
                , ASI_MFM_Currency__c = 'USD'
                , ASI_MFM_Exchange_Rate__c = 1
                , ASI_MFM_Invoice_Date__c = Date.today()
                , ASI_MFM_Invoice_Number__c = 'INV-Test01'
                , ASI_MFM_Payment_Date__c = Date.today()
                , ASI_MFM_PO_1__c = po.ID
                , ASI_MFM_PO_1_Amount__c = 900
                , ASI_MFM_Prefix__c = px2.ID
                , ASI_MFM_MKTEXP_Invoice_Amount__c = 900
                , ASI_MFM_Supplier_Name__c = acc1.ID
                , OwnerID = u.ID
                , ASI_MFM_Status__c = 'Draft'
            );
            insert pm2;
        }
        catch (exception e)
        {

        }

        
        Test.stopTest();
    }

    static testMethod void TestBatch13() 
    {
        ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'HK',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_HK_CRM_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_A_C_Code__c='12345678901');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_HK_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_HK_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326',ASI_MFM_BU_Code__c='hongkong');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='hongkong',ASI_MFM_Default_BU__c=bu.id, ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        ASI_MFM_Route_Type__c rt2 = new ASI_MFM_Route_Type__c(name='testRT2',ASI_MFM_Module__c='Payment',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        insert rt2;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10000, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        ASI_MFM_Brand_Route_Type_Map__c rtm2 = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=px2.id );
        insert rtm;
        insert rtm2;

        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        ASI_MFM_Role_Prefix_Relationship__c pro2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr2= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt2.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_HK_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&P', ASI_MFM_Dummy_Vendor__c = true); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        insert poi;

        Test.startTest();
    ASI_MFM_PO__c po2 = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_HK_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&D', ASI_MFM_Object_Key__c='12345678901'); 
        insert po2;
        
        ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po2.id,
            ASI_MFM_Spread_by_Months__c=false,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        insert poi2;

        ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_HK_Payment')
            // , ASI_MFM_Accrual_Request__c = ar.ID
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = false
            , ASI_MFM_Currency__c = 'HKD'
            , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po.ID
            , ASI_MFM_PO_1_Amount__c = 1000
      , ASI_MFM_PO_2__c = po2.ID
            , ASI_MFM_PO_2_Amount__c = 1000
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = 2000
            , ASI_MFM_Payment_Amount__c = 2000
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_Status__c = 'Draft'
        );

        insert pm;

        Set<ID> pIDs = new Set<ID>();
        pIDs.add(pm.ID);

        ASI_MFM_MKTEXP_Payment_Batch obj = new ASI_MFM_MKTEXP_Payment_Batch(pIDs);
        DataBase.executeBatch(obj, 1);

        Test.stopTest();
    }

  static testMethod void TestBatch14() 
    {
        ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'HK',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_HK_CRM_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_HK_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_HK_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326',ASI_MFM_BU_Code__c='hongkong');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='hongkong',ASI_MFM_Default_BU__c=bu.id, ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        ASI_MFM_Route_Type__c rt2 = new ASI_MFM_Route_Type__c(name='testRT2',ASI_MFM_Module__c='Payment',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        insert rt2;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10000, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        ASI_MFM_Brand_Route_Type_Map__c rtm2 = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=px2.id );
        insert rtm;
        insert rtm2;

        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        ASI_MFM_Role_Prefix_Relationship__c pro2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr2= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt2.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        // ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_HK_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
        //     ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
        //     ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&P'); 
        // insert po;
        
        // ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id,
        //     ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
        //         ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        // insert poi;

    ASI_MFM_PO__c po2 = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_HK_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&D', ASI_MFM_Dummy_Vendor__c = true, ASI_MFM_SG_Customer__c = acc1.ID); 
        insert po2;
        
        ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po2.id,
            ASI_MFM_Spread_by_Months__c=false,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 2000);
        insert poi2;

        ASI_MFM_Payment__c pm1 = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_HK_Payment')
            // , ASI_MFM_Accrual_Request__c = ar.ID
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = true
            , ASI_MFM_Currency__c = 'HKD'
            , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            // , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po2.ID
            , ASI_MFM_PO_1_Amount__c = 1000
      // , ASI_MFM_PO_2__c = po2.ID
            // , ASI_MFM_PO_2_Amount__c = 1000
            , ASI_MFM_Credit_Note__c = true
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = 1000
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_Status__c = 'Draft'
            , ASI_MFM_AlternatePayee__c = acc2.ID
            , ASI_MFM_PO_1_Remark__c = 'Testing DBNote'
            , ASI_MFM_PO_1_Offset_JDE_Sales_Invoice__c = '1'
        );

        insert pm1;

    Test.startTest();
        ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_HK_Payment')
            // , ASI_MFM_Accrual_Request__c = ar.ID
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = true
            , ASI_MFM_Currency__c = 'HKD'
            , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            // , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po2.ID
            , ASI_MFM_PO_1_Amount__c = 1000
      // , ASI_MFM_PO_2__c = po2.ID
            // , ASI_MFM_PO_2_Amount__c = 1000
            , ASI_MFM_Credit_Note__c = true
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = 1000
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_Status__c = 'Draft'
            , ASI_MFM_AlternatePayee__c = acc2.ID
            , ASI_MFM_PO_1_Remark__c = 'Testing DBNote'
            , ASI_MFM_PO_1_Offset_JDE_Sales_Invoice__c = '1'
        );

        try
        {
            insert pm;
        }
        catch(exception e)
        {

        }

        Set<ID> pIDs = new Set<ID>();
        pIDs.add(pm.ID);

        Test.stopTest();
    }

    static testMethod void TestBatch15() 
    {
        ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'HK',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_HK_CRM_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_HK_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_HK_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326',ASI_MFM_BU_Code__c='hongkong');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='hongkong',ASI_MFM_Default_BU__c=bu.id, ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        ASI_MFM_Route_Type__c rt2 = new ASI_MFM_Route_Type__c(name='testRT2',ASI_MFM_Module__c='Payment',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        insert rt2;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10000, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        ASI_MFM_Brand_Route_Type_Map__c rtm2 = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=px2.id );
        insert rtm;
        insert rtm2;

        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        ASI_MFM_Role_Prefix_Relationship__c pro2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr2= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt2.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        // ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_HK_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
        //     ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
        //     ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&P'); 
        // insert po;
        
        // ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id,
        //     ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
        //         ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        // insert poi;

    ASI_MFM_PO__c po2 = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_HK_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&D', ASI_MFM_Dummy_Vendor__c = true); 
        insert po2;
        
        ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po2.id,
            ASI_MFM_Spread_by_Months__c=false,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        insert poi2;

    Test.startTest();
        ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_HK_Payment')
            // , ASI_MFM_Accrual_Request__c = ar.ID
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = true
            , ASI_MFM_Currency__c = 'HKD'
            , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            // , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po2.ID
            , ASI_MFM_PO_1_Amount__c = 1000
      // , ASI_MFM_PO_2__c = po2.ID
            // , ASI_MFM_PO_2_Amount__c = 1000
            , ASI_MFM_Credit_Note__c = true
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = 1000
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_Status__c = 'Final'
        );
        
        insert pm;
        try
        {
            pm.ASI_MFM_Status__c = 'Rejected';
            update pm;
        }
        catch(exception e)
        {

        }

        Set<ID> pIDs = new Set<ID>();
        pIDs.add(pm.ID);

        Test.stopTest();
    }

    static testMethod void TestBatch16() 
    {
        ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'TR',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='India', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        ASI_MFM_Route_Type__c rt2 = new ASI_MFM_Route_Type__c(name='testRT2',ASI_MFM_Module__c='Payment',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        insert rt2;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10000, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        ASI_MFM_Brand_Route_Type_Map__c rtm2 = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=px2.id );
        insert rtm;
        insert rtm2;

        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        ASI_MFM_Role_Prefix_Relationship__c pro2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr2= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt2.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&D'); 
        ASI_MFM_PO__c po2 = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&D');
        List<ASI_MFM_PO__c> poList = new List<ASI_MFM_PO__c>();
        poList.add(po);
        poList.add(po2);
        insert poList;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po2.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        List<ASI_MFM_PO_Line_Item__c> poiList = new List<ASI_MFM_PO_Line_Item__c>();
        poiList.add(poi);
        poiList.add(poi2);
        insert poiList;

        Test.startTest();
        ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment')
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = true
            , ASI_MFM_Currency__c = 'HKD'
            , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po.ID
            , ASI_MFM_PO_1_Amount__c = 1000
            , ASI_MFM_PO_2__c = po2.ID
            , ASI_MFM_PO_2_Amount__c = 1000
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = 2000
            , ASI_MFM_Payment_Amount__c = 2000
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_Status__c = 'Draft'
            , ASI_MFM_Credit_Note__c = true
            , ASI_MFM_AlternatePayee__c = acc2.ID
        );
        insert pm;

        delete pm;

        Test.stopTest();
    }

    static testMethod void TestBatch17() 
    {
        ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'TR',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='India', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        ASI_MFM_Route_Type__c rt2 = new ASI_MFM_Route_Type__c(name='testRT2',ASI_MFM_Module__c='Payment',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        insert rt2;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10000, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        ASI_MFM_Brand_Route_Type_Map__c rtm2 = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=px2.id );
        insert rtm;
        insert rtm2;

        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        ASI_MFM_Role_Prefix_Relationship__c pro2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr2= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt2.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&P'); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        insert poi;

        Test.startTest();

        ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment')
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = false
            , ASI_MFM_Currency__c = 'HKD'
            , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po.ID
            , ASI_MFM_PO_1_Amount__c = -100
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = -100
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_Status__c = 'Draft'
        );

        insert pm;

        List<ASI_MFM_Payment__c> pList = new List<ASI_MFM_Payment__c>();
        pList.add(pm);
        Set<ID> pIDs = new Set<ID>();
        pIDs.add(pm.ID);

        ASI_MFM_MKTEXP_Payment_Batch obj = new ASI_MFM_MKTEXP_Payment_Batch(pIDs);
        DataBase.executeBatch(obj, 1);

        Test.stopTest();
    }

    static testMethod void TestBatch18() 
    {
       ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'TR',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&P'); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        insert poi;

        ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment')
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = false
            , ASI_MFM_Currency__c = 'HKD'
            , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po.ID
            , ASI_MFM_PO_1_Amount__c = 1000
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = 1000
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_Status__c = 'Final'
            , ASI_MFM_PO_Receipt_Generation__c = true
            , ASI_MFM_Payment_Line_Generation__c = false
        );

        insert pm;

        ASI_MFM_PO_Receipt__c por = new ASI_MFM_PO_Receipt__c(
      RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_MKTEXP_TR_PO_Receipt'),
      ASI_MFM_Payment__c = pm.ID,
      ASI_MFM_Receipt_Date__c = pm.ASI_MFM_Invoice_Date__c,
      ASI_MFM_Remarks__c = 'Auto-created from ' + pm.Name,
      ASI_MFM_Status__c = 'Draft',
      ASI_MFM_Supplier__c = pm.ASI_MFM_Supplier_Name__c,
      Ownerid = pm.Ownerid,
      ASI_MFM_PO_Owner__c = pm.Ownerid
        );
        insert por;

         ASI_MFM_PO_Receipt__c por2 = new ASI_MFM_PO_Receipt__c(
      RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_MKTEXP_TR_PO_Receipt'),
      ASI_MFM_Payment__c = pm.ID,
      ASI_MFM_Receipt_Date__c = pm.ASI_MFM_Invoice_Date__c,
      ASI_MFM_Remarks__c = 'Auto-created from ' + pm.Name,
      ASI_MFM_Status__c = 'Draft',
      ASI_MFM_Supplier__c = pm.ASI_MFM_Supplier_Name__c,
      Ownerid = pm.Ownerid,
      ASI_MFM_PO_Owner__c = pm.Ownerid
        );
        insert por2;

        Test.startTest();
            por.ASI_MFM_Status__c = 'Final';
            por2.ASI_MFM_Status__c = 'Final';
            update por;
            update por2;

            por.ASI_MFM_Status__c = 'Rejected';
            update por;
    Test.stopTest();
    }

    static testMethod void TestBatch19() 
    {
        User u2 = TestFactory.createStandardUser('xxx');
        Insert u2;

        ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'TR',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='India', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        ASI_MFM_Route_Type__c rt2 = new ASI_MFM_Route_Type__c(name='testRT2',ASI_MFM_Module__c='Payment',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        insert rt2;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=10000, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u2.id,ASI_MFM_Prefix__c=pxo.id );
        ASI_MFM_Brand_Route_Type_Map__c rtm2 = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt2.id,ASI_MFM_Responsible_By__c=u2.id,ASI_MFM_Prefix__c=px2.id );
        insert rtm;
        insert rtm2;

        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u2.userRole.developerName);
        ASI_MFM_Role_Prefix_Relationship__c pro2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u2.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr2= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt2.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u2.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&D', ASI_MFM_Source_of_A_D__c = 'Advanced Pricing'); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        insert poi;

        Test.startTest();
        po.ASI_MFM_Exchange_Rate__c = 1;
        update po;
        delete po;

        Test.stopTest();
    }
    
    static testMethod void TestBatch20() 
    {
        Test.startTest();
          SchedulableContext sc = null;
            ASI_MFM_MKTEXP_Payment_ScheduleHandler tsc = new ASI_MFM_MKTEXP_Payment_ScheduleHandler();
            tsc.execute(sc);
        Test.stopTest();
    }

    static testMethod void TestBatch21() 
    {
        ASI_MFM_Exchange_Rate__c ex1 = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Counter_Currency__c = 'HKD',
            ASI_MFM_Effective_Date__c = Date.today().addmonths(-12),
            ASI_MFM_Exchange_Rate__c = 1,
            ASI_MFM_Base_Currency__c = 'HKD',
            ASI_MFM_Country__c = 'TR',
            ASI_MFM_Application__c = 'MFM'
        );
        insert ex1;

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 

        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='payment', Plan_Type__c='test1', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px2;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;

        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code'),name='testAP',ASI_MFM_A_C_Code__c = ac.ID);
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
         Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');                    
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test', ASI_MFM_BU_Description__c='hongkong', ASI_MFM_L3__c = '00326');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=200000, ASI_MFM_Original_Total_Cost__c=200000,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201811');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'),ASI_MFM_Route_Type__c=rt.id, name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()
            ,ASI_MFM_Exchange_Rate__c = 1,ASI_MFM_Currency__c = 'HKD', ASI_MFM_AP_AD__c = 'A&P', ASI_MFM_Reference_2__c = ''); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today().addDays(-1), ASI_MFM_Amount__c = 1000);
        List<ASI_MFM_PO_Line_Item__c> poiList = new List<ASI_MFM_PO_Line_Item__c>();
        poiList.add(poi);
        
        insert poiList;

        ASI_MFM_Payment__c pm = new ASI_MFM_Payment__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment')
            , ASI_MFM_Actual_MKT_Expense_Allocation__c = false
            , ASI_MFM_Currency__c = 'HKD'
            , ASI_MFM_Exchange_Rate__c = 1
            , ASI_MFM_Invoice_Date__c = Date.today()
            , ASI_MFM_Invoice_Number__c = 'INV-Test01'
            , ASI_MFM_Payment_Date__c = Date.today()
            , ASI_MFM_PO_1__c = po.ID
            , ASI_MFM_PO_1_Amount__c = 1000
            , ASI_MFM_Prefix__c = px2.ID
            , ASI_MFM_MKTEXP_Invoice_Amount__c = 1000
            , ASI_MFM_Supplier_Name__c = acc1.ID
            , OwnerID = u.ID
            , ASI_MFM_Status__c = 'Submitted'
            , ASI_MFM_PO_Receipt_Generation__c = true
            , ASI_MFM_Payment_Line_Generation__c = false
        );

        insert pm;

        Test.startTest();
        
        Apexpages.StandardController sc = new Apexpages.StandardController(po);
        ASI_MFM_MKTEXP_POCompleteController ext;

        try
        {
            ext = new ASI_MFM_MKTEXP_POCompleteController(sc);
        }
        catch (exception e)
        {
            // po.ASI_MFM_Reference_2__c = '';
            // payment.ASI_MFM_Status__c = 'Final';
            // update po;
        }

        // ext.doComplete();
        
        Test.stopTest();
    }

    private static string getFiscalYear()
    {
        if (Current_Fiscal_year == null)
        {
            Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
            Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
            Datetime GMTdate = Datetime.now();
            String yearA1 = GMTdate.format('YY');
            Integer yearA0 = Integer.valueOf(yearA1) -1;
            Integer yearA2 = Integer.valueOf(yearA1) +1;

            if (system.today() < orgFiscalYear)
            {
                Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
            }
            else
            {
                Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
            }
        }

        return Current_Fiscal_year;
    }
}