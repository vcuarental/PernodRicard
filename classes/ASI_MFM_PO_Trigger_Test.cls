@isTest
public class ASI_MFM_PO_Trigger_Test {
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
    public static ASI_MFM_A_C_Code__c createACCode(){
        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='test',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_SC_A_C_Code')
        );
        insert acCode;
        return acCode;
    }
    public static ASI_MFM_AP_Code__c createAPCode(){
         ASI_MFM_AP_Code__c apCode = new ASI_MFM_AP_Code__c(
             Name='test',
             ASI_MFM_Inactive__c=false,
             recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_SC_AP_Code'),
             ASI_MFM_A_C_Code__c = createACCode().id
         );
         insert apCode;
         return apCode;
    }
    public static ASI_MFM_BU__c createBUCode(){
        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='test',
            ASI_MFM_Inactive__c=false,
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_SC_BU')
        );
        insert buCode;
        return buCode;
    }
    public static Account createAccSupplier (){
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_SC_Supplier'), Name='test');
        insert acc;
        return acc;
    }
    public static Account createAccSubledger  (){
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Subleger'), Name='test');
        insert acc;
        return acc;
    }
    public static ASI_MFM_Prefix__c createPrefix (String name, String module,String DeveloperName){
        ASI_MFM_Prefix__c prefix = new ASI_MFM_Prefix__c
        (
            Name = name,
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SC_Prefix'),
            ASI_MFM_Module__c = module,
            ASI_MFM_Fiscal_year__c = getFiscalYear(),
            ASI_MFM_Inactive__c=false
        );
        insert prefix;

        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefix.id,
            ASI_MFM_Role_Name__c = DeveloperName
        );
        insert rel;
        return prefix;
    }
    public static ASI_MFM_Route_Type__c createApprovalRoute(String module,id prefixid , id userid){
        ASI_MFM_Route_Type__c rt=new ASI_MFM_Route_Type__c(ASI_MFM_EUR_rate__c=10,ASI_MFM_Type__c=module,Name='test',
                                                                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_SC_Route_Type'));
        insert rt;                                                        
        
        ASI_MFM_Brand_Route_Type_Map__c rtm=new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Prefix__c=prefixid ,
                                                                                    ASI_MFM_Active__c = true,
                                                                                    ASI_MFM_Responsible_By__c=userid,
                                                                                    ASI_MFM_Route_Type__c=rt.id);
        insert rtm;
        
        List<ASI_MFM_Route_Rule_Detail__c> rtd =new List<ASI_MFM_Route_Rule_Detail__c>();
        for (integer i=0;i<8;i++){
            rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=userid, ASI_MFM_Minimum_Amount__c=i , ASI_MFM_Route_Type__c =rt.id, 
                                                                                ASI_MFM_Sequence__c=i));
        }
        insert rtd ;
        
        return rt;
    }
    public static ASI_MFM_Plan__c createPlan(id prefixid ){
        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c( Name = 'test',
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SC_Plan'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c =date.today(),
                                                        ASI_MFM_Prefix__c = prefixid, 
                                                        ASI_MFM_Status__c='Final',   
                                                        ASI_MFM_Currency__c='HKD',
                                                        ASI_MFM_Plan_Type__c='OPEX');
        insert plan;        
        return plan;
    }
    public static ASI_MFM_Plan_Line_Item__c createPlanLine(id headerid, id apcodeid ){

        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = ASI_MFM_Plan_Line_Item__c.ASI_MFM_AP_Code_PL__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }

    system.debug('createPlanLine pickListValuesList[0]::'+ pickListValuesList[0]);
    ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = headerid,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_SC_Plan_Line_Item'),
                                                                                 ASI_MFM_Total_Cost__c=100000,
                                                                                 asi_mfm_ap_code__c=apcodeid,
                                                                                 //ASI_MFM_AP_Code_PL__c=pickListValuesList[0],
                                                                                 ASI_MFM_List_Item_Description__c='hello',
                                                                                 ASI_MFM_AP_Group__c='Non-specific'
                                                                                 );
        insert planLine;
        return planLine;
    }
    public static ASI_MFM_PO__c createPO(id prefixid, id planid , id supplierid){
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_SC_Supplier_Name__c = supplierid,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(), 
                                                 ASI_MFM_PO_Start_Date__c =date.today(),
                                                 ASI_MFM_PO_End_Date__c =date.today(),                                              
                                                 ASI_MFM_Status__c = 'Final',
                                                 ASI_MFM_Prefix__c = prefixid,
                                                 ASI_MFM_Plan__c = planid,
                                                 ASI_MFM_Currency__c='USD',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SC_PO'));
            insert po;  
            return po;
    }
    public static ASI_MFM_PO_Line_Item__c createPoLine(id headerid, id apcodeid, id buid , id subledgerid){

        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = ASI_MFM_PO_Line_Item__c.ASI_MFM_AP_Code_PL__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }

        system.debug('createPlanLine pickListValuesList[0]::'+ pickListValuesList[0]);

        ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SC_PO_Line_Item'),
                                                                           ASI_MFM_PO__c = headerid,                                                                             
                                                                           ASI_MFM_Amount__c = 1000,
                                                                           asi_mfm_ap_code__c=apcodeid,
                                                                           ASI_MFM_BU_Code__c=buid,
                                                                           ASI_MFM_SC_Subledger__c=subledgerid,
                                                                           //ASI_MFM_AP_Code_PL__c=pickListValuesList[0],
                                                                           ASI_MFM_List_Item_Description__c='hello',
                                                                           ASI_MFM_AP_Group__c='Non-specific'
                                                                          );
            
            insert po_line; 
        return po_line;
    }
    static testMethod void trigger_test_HK(){
         ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;   
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), name='test',
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(),  ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p; 
        
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),Name='Name3');           
        accList.add(acc2);
        insert accList;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Plan__c=p.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;  
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_HK_A_C_Code'));
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', ASI_MFM_Inactive__c = false, recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert sub;
        
        Id polineId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item');
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = polineId, ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
            ASI_MFM_Amount__c = 1
            );
        insert poi;
        
        po.ASI_MFM_Invoice_Amount_from_JDE__c = 10;
        po.ASI_MFM_Status__c = 'Final';
        update po;
        update poi;
    }
    static testMethod void trigger_test_TW() {
        user u = [SELECT id, userRole.developerName FROM user WHERE id = :userInfo.getUserId()];    
        u.ASI_MFM_Country__c ='TW';
        update u;
        
        System.runAs(u) {            
            
            List<Account> listAcc = new List<Account>();
            listAcc.add(new Account(RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'),Name='Test Outlet',ASI_TH_CRM_Region__c ='North'));  
            listAcc.add(new Account(RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'),Name='Test Customer'));  
            listAcc.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name3')); 
            listAcc.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), Name='Name2'));
            listAcc.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), Name='Name3'));    
            insert listAcc;            
            
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC',ASI_MFM_A_and_P_Tree__c='TOTAL A&P');
            insert ac;
            
            ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), name='testAP');
            insert ap;
            
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand',ASI_CRM_TW_Company__c='PRT', ASI_CRM_Active__c=TRUE, ASI_TH_CRM_Active__c=TRUE,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'));
            insert sub;
            
            
            List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
            ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', Plan_Type__c='rade A&P Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
            prList.add(pxp);
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
            prList.add(pxo);
            ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
            prList.add(pxy);
            insert prList;
            
            List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            insert rprList;
            
            ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
            insert rt;
            
            List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
            ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
            ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
            ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
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
            
            ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
            insert rtm;
            
            ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
            insert rtbr;
                        
            List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
            listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                             ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
            //listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
              //                               ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
            insert listPlan;      
            
            List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
            listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing1',ASI_MFM_Customer_Name__c =listAcc[4].id,
                                                     ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Total_Cost__c=1000));
            listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing2',ASI_MFM_Customer_Name__c =listAcc[4].id,
                                                     ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_Total_Cost__c=2000));
            insert listPL;
            
            List<ASI_MFM_Exchange_Rate__c> listXR = new List<ASI_MFM_Exchange_Rate__c>();
            listXR.add(new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='TWD',ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1)); 
            listXR.add(new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',ASI_MFM_Counter_Currency__c='TWD', ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1)); 
            insert listXR;    
           
            System.debug(Limits.getDMLRows());
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Status__c='Draft',recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TW_PO'), ASI_MFM_Plan__c=listPlan[0].id,ASI_MFM_Supplier_Name__c = listAcc[3].id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Currency__c='TWD');
            insert po;            
            
            List<ASI_MFM_PO_Line_Item__c> poLinelist= new List<ASI_MFM_PO_Line_Item__c> ();
            ASI_MFM_PO_Line_Item__c poi1 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=listAcc[4].id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
            poLinelist.add(poi1);
            ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=listAcc[4].id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
            poLinelist.add(poi2);
            insert poLinelist;
            update po;
            update poLinelist;
        }
    }
    static testMethod void trigger_test_GF() {
        /*
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
                                             ASI_MFM_Status__c ='Draft',ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'),Name='Name3');           
        insert acc2;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
                                                                  ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100);
        insert poi;
        update poi;
        update po;
*/
	}
    static testMethod void trigger_test_TR() {
        /*ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Draft',
                ASI_MFM_TR_PlanCompletionDate__c = Date.today(), ASI_MFM_Reference_1_List__c = 'CAPEX Plan', ASI_MFM_TR_Duration_Month__c = 24);
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAP');
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'), Name='Name3', ASI_HK_CRM_Location__c='hongkong');              
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
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
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',ASI_MFM_Route_Type__c=rt.id,
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today(),
            ASI_MFM_Reference_2__c = 'CAPEX', ASI_MFM_Invoice_Amount_from_JDE__c=8000); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c =10000,ASI_MFM_Base_Currency_Amount__c=10000,
            ASI_MFM_Spread_by_Months__c=false,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        update po;
        update poi;

        test.starttest();

        PageReference testPage = new pagereference('/apex/ASI_MFM_TR_CompletionPOPage');
        Test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('pID', p.Id);
        ASI_MFM_TR_CompletionPOController cont = new ASI_MFM_TR_CompletionPOController();
        PageReference pageref = cont.doComplete();
        PageReference pageref2 = cont.cancel();
        
        test.stoptest();*/
    }
    static testMethod void trigger_test_RM() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_RM_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(),  
                                                 ASI_MFM_End_Date__c=date.today().addMonths(1), ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        
        List<Account> accountToInsert = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_RM_Supplier'),Name='Name2');           
        accountToInsert.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_RM_Customer'),Name='Name3');           
        accountToInsert.add(acc2);
        Account acc3 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_RM_Supplier'),Name='Name3');           
        accountToInsert.add(acc3);
        
        insert accountToInsert;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
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
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id,ASI_MFM_Active__c=true );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                 
        
        List<ASI_MFM_PO__c> poList = new List<ASI_MFM_PO__c>();
        ASI_MFM_PO__c po1 = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_RM_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(), ASI_MFM_Currency__c='HKD', ASI_MFM_Supplier_Name__c = acc1.id);
        poList.add(po1);
        ASI_MFM_PO__c po2 = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_RM_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(), ASI_MFM_Currency__c='HKD', ASI_MFM_Supplier_Name__c = acc1.id);
        poList.add(po2);
        
        insert poList;
        
        Test.startTest();
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        List<ASI_MFM_PO_Line_Item__c> poiList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi1 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_RM_PO_Line_Item'), ASI_MFM_PO__c=po1.id,     
                                                                   ASI_MFM_Amount__c = 100, ASI_MFM_Exchange_Rate__c=1, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poiList.add(poi1);
        
        ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_RM_PO_Line_Item'), ASI_MFM_PO__c=po2.id,     
                                                                   ASI_MFM_Amount__c = 100, ASI_MFM_Exchange_Rate__c=1, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poiList.add(poi2);
        
        insert poiList;
        
        po2.ASI_MFM_Original_PO_for_Adjustment__c = po1.id;
        po2.ASI_MFM_Cloned_PO_ID__c = po1.id;
        po2.ASI_MFM_Status__c = 'Final';
        update po2;
        update poi2;
        
        Test.stopTest();
    }
    static testMethod void trigger_test_JP() {
        //Prefix
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=ASI_MFM_JP_TestClassHelper.getFiscalYear());
        prefixList.add(px); 
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'JP';
        update u;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;
        
        //Plan
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_JP_Plan'), name='test',
                                                ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                                                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        //Brand and Sub-Brand
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_JP_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_JP_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        //AP AC Code
        ASI_MFM_AP_Code__c ap = ASI_MFM_JP_TestClassHelper.createJPAPCode();
        ASI_MFM_A_C_Code__c ac = ASI_MFM_JP_TestClassHelper.createJPACCode();
        
        //Account : Customer  Supplier
        List<Account> accToInsert = new List<Account>();
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Customer'), Name='Name3');           
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        insert accToInsert;
        
        //Plan line 
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_JP_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                     ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        
        //Create PO 
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id,Brand_MFM__c=brand1.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
        insert podr;
        
        //PO 
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_JP_PO'), name='test', ASI_MFM_Prefix__c=pxo.id,ASI_MFM_Currency__c='JPY', ASI_MFM_Status__c='Final',
                                             ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()); 
        insert po;
        
        
        
        // PO Line
        List<ASI_MFM_PO_Line_Item__c> POLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_JP_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=100,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                                                                  ASI_MFM_G_L_Date__c = Date.today());
        POLineList.add(poi);
        ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_JP_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=100,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                                                                  ASI_MFM_G_L_Date__c = Date.today());
        POLineList.add(pol);
        insert POLineList;
        
        update po;
        update poi;
    }
    static testMethod void trigger_test_MY() {
        // Start Plan
        List<ASI_MFM_Prefix__c> preList = new List<ASI_MFM_Prefix__c>();
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        preList.add(px);
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        preList.add(pxo); 
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        preList.add(pxa); 
        insert preList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'MY';
        update u;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRelationList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pro);   
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pra);
        insert PrefixRelationList;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_MY_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        //Set PO 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_MY_Supplier'),Name='Name2');      
        accList.add(acc1);
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_MY_Customer'),Name='Name3');        
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_MFM_MY_Supplier'),Name='Name3');      
        accList.add(acc3);
        
        insert accList;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
        
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        update po;
        update poi;

    }
    static testMethod void trigger_test_SG() {
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
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='Myanmar');
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
        
        test.startTest();
        System.debug(Limits.getDMLRows());
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_SG_Customer'),Name='Name3');           
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        // Set PO 
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today(), ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), ASI_MFM_Market__c = 'Singapore');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        list<ASI_MFM_PO_Line_Item__c> poLineItems = new list<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=10, 
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineItems.add(poi);
        insert poLineItems;
        
        update po;
        update poi;
        test.stopTest();
    }
    static testMethod void trigger_test_KR() {
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c = 'KR';
        u.ASI_KOR_User_Branch_Code__c = '555';
        update u;
        
        System.runAs(u){ 
         
            String FiscalYear = getFiscalYear();
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            //PR Prefix:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            Prefix_List.add(prefixPR);
            
            //Payment PREFIX:
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            Prefix_List.add(prefixPayment);
            
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            //insert prefixPO;
            Prefix_List.add(prefixPO);
            insert Prefix_List;
            
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            //Prefix Relationship
             ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPayment.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_Payment);
            
            
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_PO); 
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
                
            //APPROVAL SETTING:
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            

            //Insert PO
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 //ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po.id,
                                                                            //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                            ASI_MFM_Unit_Price__c = 1000,  
                                                                            ASI_MFM_KR_Quantity__c = 100,    
                                                                            ASI_MFM_Amount__c = 100000,
                                                                            ASI_MFM_Delivery_Date__c =  date.today(),
                                                                            ASI_MFM_G_L_Date__c = date.today()   
                                                                            //ASI_MFM_Purchase_Request_Line__c = PR_Line.id   
                                                                            );
            
            insert po_line;
            update po;
            update po_line;

        }
	}
    static testMethod void trigger_test_TH() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY2021');
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_TH_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription',ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1');   //  ASI_MFM_HK_Supplier       
        accList.add(acc1);
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Customer'),Name='Name3');    //ASI_HK_CRM_Outlet       
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name3', ASI_KOR_Customer_Code__c = 'THS2');       //ASI_MFM_HK_Supplier     
        accList.add(acc3);
        
        insert accList;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Fiscal_year__c='FY2021');
        insert pxo; 
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;     
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO'),name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='THB', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;

        update po;
        update poi;
    }
    static testMethod void trigger_test_PH() {
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
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
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
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
       
        ASI_MFM_A_C_Code__c ac = ASI_MFM_PH_TestClassHelper.createACPHDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_PH_TestClassHelper.CreateDFSBrand();
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_TnE_PH_BU'), name ='test bu');
        
        // Create Plan 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1).toStartOfMonth().addDays(-1),ASI_MFM_Currency__c='SGD',
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
   
        // Create PO
          
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final');
        insert po;
        update po;
        Test.startTest();
        ASI_MFM_PO__c po1 = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),ASI_MFM_Cloned_PO_ID__c=po.id,
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Draft', ASI_MFM_PO_Start_Date__c=date.today(),ASI_MFM_PO_End_Date__c=date.today().addDays(1));
        insert po1;
        
        // Create PO line Items
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        ASI_MFM_PO_Line_Item__c poi1 = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po1.id,ASI_MFM_Amount__c=10000,ASI_MFM_Spread_by_Months__c=true,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(), ASI_MFM_PH_Allocation_Percentage__c=10);
        poLineList.add(poi);
        poLineList.add(poi1);
        insert poLineList;
            
        po1.ASI_MFM_Exchange_Rate__c = 1.5;
        po1.ASI_MFM_PH_Total_PO_Amount_Allocation__c = 100;
        update po1;
        
        List<Database.DeleteResult> deleteResults  = new List<Database.DeleteResult>();
        deleteResults = Database.delete(poLineList, false);
        delete po1;
        test.stopTest(); 
    }
    static testMethod void trigger_test_SC() {
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.ASI_MFM_Country__c = 'SC';
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Hong Kong';
        update u;
        
        string fiscalYear = getFiscalYear();
        
        System.runAs(u){ 
            
            ASI_MFM_AP_Code__c  AP_Code = createAPCode();            
            ASI_MFM_BU__c  BU_Code = createBUCode();
            
            ASI_MFM_Prefix__c prefixPLAN = createPrefix('Plan', 'Plan', Role_Test.DeveloperName);                                 
            ASI_MFM_Prefix__c prefixPO = createPrefix('PO1', 'PO', Role_Test.DeveloperName);
            ASI_MFM_Prefix__c prefixPayment1 = createPrefix('Payment', 'Payment', Role_Test.DeveloperName);  
            ASI_MFM_Prefix__c prefixPayment2 = createPrefix('Payment', 'Payment', Role_Test.DeveloperName);  
            
            ASI_MFM_Plan__c plan = createPlan(prefixPLAN.id);
            ASI_MFM_Plan_Line_Item__c planLine1 = createPlanLine(plan.id, AP_Code.id);
            
            Account acc1 = createAccSupplier();            
            Account acc2 = createAccSubledger();           
            
            ASI_MFM_PO__c po = createPO(prefixPO.id, plan.id , acc1.id);
            ASI_MFM_PO_Line_Item__c po_line = createPoLine(po.id,AP_Code.id,BU_Code.id, acc2.id);
            
            update po;
            update po_line;
        }
    }
    static testMethod void ASI_MFM_PO_MainTest2() { //To  test ASI_MFM_PO_TriggerClass   Get ASI_MFM_Plan__c Users
        
        test.setMock(WebServiceMock.class, new ASI_MFM_WebServiceMock());
        //Set User
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'TH';
        update u;
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='THB',ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='TH', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        // Set Plan Prefix
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='THP14', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY2021');
        insert px;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Plan');
        insert rt;
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        // ASI MFM Route Rule Details Set Approver 
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1,ASI_MFM_Region__c='UPC');
        insert rrd;
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2,ASI_MFM_Region__c='STH');
        insert rrd2;
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=3, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3,ASI_MFM_Region__c='WS');
        insert rrd3;
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=4, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4,ASI_MFM_Region__c='GBKK(High)');
        insert rrd4;
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=5, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5,ASI_MFM_Region__c='GBKK(Low)');
        insert rrd5;
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=6, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        insert rrd6; 
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=7, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        insert rrd7;
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=8, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        insert rrd8;
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=9, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        insert rrd9;
        ASI_MFM_Route_Rule_Detail__c rrd10 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=100, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=10);
        insert rrd10;
        
        
        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TH_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final',ASI_MFM_Approver_1__c=u.id);
        insert p1;
        //Set PO prefix
        px = new ASI_MFM_Prefix__c(name='THP14', ASI_MFM_Module__c='PO',ASI_MFM_Region__c=true, ASI_MFM_Fiscal_year__c='FY2021' );// ASI_MFM_TR_Rec_Type__c='region'
        insert px;
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Route_Type__c rts = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rts;
        
        ASI_MFM_Brand_Route_Type_Map__c rtms = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rts.id, ASI_MFM_Prefix__c=px.id);
        insert rtms;
        
        // ASI MFM  PO Route Rule Details Set Approver 
        ASI_MFM_Route_Rule_Detail__c rrds = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=1,ASI_MFM_Region__c='UPC');
        insert rrds;
        ASI_MFM_Route_Rule_Detail__c rrds2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2,ASI_MFM_Region__c='STH');
        insert rrds2;
        
        
        
        // Create PO
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_TH_Customer'),Name='Name3');        
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_TH_Supplier'),Name='Name2', ASI_KOR_Customer_Code__c = 'THS1'); 
        insert acc1;
        
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TH_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),ASI_MFM_Currency__c='BHT', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addMonths(2), ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_TH_Region__c='UPC;STH;WS;GBKK(High);GBKK(Low)');
        insert po;
        
        // Test Start
        test.startTest();
        
        ASI_MFM_PO__c po1 = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TH_PO'), name='test', ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id,ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c = 'Final',ASI_MFM_CLoned_PO_ID__c=po.id, ASI_MFM_TH_Region__c='UPC;STH;WS;GBKK(High);GBKK(Low)'); 
        insert po1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_TH_CRM_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode',ASI_TH_CRM_Active__c=true, ASI_MFM_Active_for_MFM__c =true );// ASI_HK_CRM_Sub_brand    ASI_TH_CRM_Outlet
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po.id,  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),ASI_MFM_Complete__c = true,ASI_MFM_Amount__c=123);// ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,   
        insert poi;
        
        ASI_MFM_PO_Line_Item__c poi1 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TH_PO_Line_Item'), ASI_MFM_PO__c=po1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(), ASI_MFM_Complete__C = false,ASI_MFM_Amount__c=10,ASI_MFM_POSM_Deposit__c = false ,ASI_MFM_POSM_Balance__c = false);
        insert poi1;
        test.stopTest();
    }
    public testMethod static void testMassUpload(){
        
        ASI_MFM_Budget__c a = ASI_MFM_CAP_TestClassHelper.createBudget();      
        
        List<ASI_MFM_Prefix__c> pList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px1 = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
		pList.add(px1);
		ASI_MFM_Prefix__c px2= new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
		pList.add(px2);
        insert pList; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
		List<ASI_MFM_Role_Prefix_Relationship__c> prList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px1.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
		prList.add(pr1);
		ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
		prList.add(pr2);
        insert prList;
        
		ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=px2.Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CN_Plan'),
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
				ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=userInfo.getUserId(),ASI_MFM_Status__c='Final');
		insert plan;
			
		ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Plan__c = plan.Id, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO'), name='test', ASI_MFM_PO_End_Date__c=Date.today(), ASI_MFM_PO_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Draft', ASI_MFM_Prefix__c=px1.id);
		insert po;
        
        
        test.startTest();
        /*
        ASI_MFM_CN_POSM_MassUploadByBatchCls controller = new ASI_MFM_CN_POSM_MassUploadByBatchCls();
        String[] testGetter = controller.StatusMsgs;
        controller.ObjAPIName ='ASI_MFM_Stock_In_Request__c';
        controller.parentID ='';
        controller.parentField ='';
        controller.fields ='ASI_MFM_PO_POSM_Line_Number__c,ASI_MFM_Lot_Number__c,ASI_MFM_PO_Number__c,ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c,ASI_MFM_Box_Net_Weight__c,ASI_MFM_Lot_Quantity__c,ASI_MFM_Total_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Box__c,ASI_MFM_Fraction_Qty__c,ASI_MFM_Total_Number_Of_Box__c,ASI_Delivery_Date__c';
        controller.fieldsLabel ='PO POSM Line Number,Lot Number,PO Number,Weight/Unit(KG),Case Size(M3),Weight of Case,Quantity of Batch,Total Qunatity Per Bag Box,Quantity Per Bag Box,Quantity Per Box,Fraction Quantity,Total Number Of Box,Delivery Date(YYYYMMDD)';
        //controller.fields ='ASI_MFM_Lot_Number__c,ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c,ASI_MFM_Box_Net_Weight__c,ASI_MFM_Lot_Quantity__c,ASI_MFM_Total_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Box__c,ASI_MFM_Fraction_Qty__c,ASI_MFM_Total_Number_Of_Box__c,ASI_Delivery_Date__c';
        //controller.fieldsLabel ='Lot Number,Weight/Unit(KG),Case Size(M3),Weight of Case,Quantity of Batch,Total Qunatity Per Bag Box,Quantity Per Bag Box,Quantity Per Box,Fraction Quantity,Total Number Of Box,Delivery Date(YYYYMMDD)';
        controller.lookupEXID ='ASI_MFM_PO_POSM_Line__c/ASI_MFM_PO_POSM_Line_Number__c:PO POSM Line Number&name;ASI_MFM_PO__c/ASI_MFM_PO_Number__c:PO Number&name;';
        controller.template ='';
        controller.template2 ='';
        controller.report='';
        controller.recordtypeName ='CN Stock In Request';
        controller.currentPageURL =''; // v
        controller.inlineVF =true;
        controller.reloadNeeded =true;
        controller.defaultValues ='';
        controller.recEXID ='External ID';
        controller.recEXIDcol =''; 
        controller.parentObjectAPIName ='ASI_MFM_Mass_Upload_Log__c';
        controller.ParentObjectUploadMsg ='ASI_MFM_Error_Message__c';
        controller.upsertMode =false;
        controller.batchMode =false;
        controller.opt_allOrNone=true;    
        controller.emailNotification =true;
        controller.monitorFieldName ='ASI_MFM_PO_Number__c';
        controller.init();
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('PO POSM Line Number,送货地点,批次号,PO Number,Item Group Code,单件重量(祼重KG),外箱体积(M3),外箱毛重(KG),最小计量单位单价(RMB),总件数,分批送货数量,每箱有几个大袋/大盒,每大袋/大盒里几个小件,每箱中几个小件,零头箱中礼品件数,产品总箱数(不含零头箱),分批送货日期(YYYYMMDD)x\rPPL-18000017,88酒吧(ONSHA1247),,22180058,X1MLEGT17001,1,1,1,1,11,1,1,1,1,1,1,20181010');
        controller.uploadcsv();        
        
        //Test inLineVF is false;
        controller.inlineVF = false;
        controller.uploadcsv();
            */

        
        
        ASI_MFM_CN_POSM_MassUploadByBatchCls controller = new ASI_MFM_CN_POSM_MassUploadByBatchCls();
        String[] testGetter = controller.StatusMsgs;
        controller.ObjAPIName = 'ASI_MFM_Stock_In_Request__c';
        controller.emailNotification = true;
        controller.recordtypeName = 'CN Stock In Request';
        controller.fields = 'ASI_MFM_PO_Number__c,ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c,ASI_MFM_Length__c,ASI_MFM_SIR_Sent__c,ASI_Delivery_Date__c,ASI_MFM_Width__c,ASI_MFM_Qty_Per_Box__c';
        controller.fieldsLabel = 'PO Number,Weight/Unit(KG),Case Size(M3),Length,Sent,Date,Width,QtyBox';
        controller.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller.lookupEXID ='ASI_MFM_PO_POSM_Line__c/ASI_MFM_PO_POSM_Line_Number__c:PO POSM Line Number&name;ASI_MFM_PO__c/ASI_MFM_PO_Number__c:PO Number&name;';
        controller.currentPageURL = String.valueof(a.id);
        controller.monitorFieldName ='ASI_MFM_PO_Number__c';
        controller.inlineVF = false;
        controller.upsertMode = false;
        controller.DefaultValues = '';
        controller.init();
        controller.upsertMode = false;
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('PO Number,Weight/Unit(KG),Case Size(M3),Length,Sent,Date,Width,QtyBox\rtest,220,420,1,y,20181010,1.11,10');
        controller.uploadcsv();        
        String tmp = controller.monitorValue;
        
        //Test inLineVF is false;
        controller.inlineVF = false;
        controller.uploadcsv();

        
        
        //Test negative case - Wrong field name mapping
        controller.ObjAPIName = 'ASI_MFM_Stock_In_Request__c';        
        controller.recordtypeName = 'CN Stock In Request';
        controller.fields = 'ASI_MFM_Lot_Number__c,ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c,ASI_MFM_Box_Net_Weight__c,ASI_MFM_Lot_Quantity__c,ASI_MFM_Total_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Box__c,ASI_MFM_Fraction_Qty__c,ASI_MFM_Total_Number_Of_Box__c,ASI_Delivery_Date__c';
        //controller.fieldsLabel = 'Lot Number,Weight/Unit(KG),Case Size(M3),Weight of Case,Quantity of Batch,Total Qunatity Per Bag Box,Quantity Per Bag Box,Quantity Per Box,Fraction Quantity,Total Number Of Box,Delivery Date(YYYYMMDD)';
        //controller.lookupEXID = 'ASI_MFM_PO_POSM_Line__c/ASI_MFM_PO_POSM_Line_Number__c:PO POSM Line Number&name;ASI_MFM_PO__c/ASI_MFM_PO_Number__c:PO Number&name;';
        controller.fields = 'ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c';
        controller.fieldsLabel = 'Weight/Unit(KG),Case Size(M3)';
        controller.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = false;
        controller.upsertMode = false;
        controller.DefaultValues = '';
        controller.contentFile = blob.valueOf('name_Error,NumberOfEmployees_Error,AnnualRevenue_Error\rJohn,Error,Error,Test_TooManyFields');
        controller.uploadcsv();
        
        
        //Test negative case - Wrong data
        controller.ObjAPIName = 'ASI_MFM_Stock_In_Request__c';        
        controller.recordtypeName = 'CN Stock In Request';
        //controller.fields = 'ASI_MFM_Lot_Number__c,ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c,ASI_MFM_Box_Net_Weight__c,ASI_MFM_Lot_Quantity__c,ASI_MFM_Total_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Bag_Box__c,ASI_MFM_Qty_Per_Box__c,ASI_MFM_Fraction_Qty__c,ASI_MFM_Total_Number_Of_Box__c,ASI_Delivery_Date__c';
        //controller.fieldsLabel = 'Lot Number,Weight/Unit(KG),Case Size(M3),Weight of Case,Quantity of Batch,Total Qunatity Per Bag Box,Quantity Per Bag Box,Quantity Per Box,Fraction Quantity,Total Number Of Box,Delivery Date(YYYYMMDD)';
        controller.fields = 'ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c';
        controller.fieldsLabel = 'Weight/Unit(KG),Case Size(M3)';
        controller.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.upsertMode = false;
        controller.DefaultValues = 'Delivery Date(YYYYMMDD):2013-01-01';
        
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('Weight/Unit(KG),Case Size(M3)\r220,420');
        controller.uploadcsv();
        
        //Test negative case - File size exceed limit
        
        controller.filesize = 6242880;
        controller.ObjAPIName = 'ASI_MFM_Stock_In_Request__c';        
        controller.recordtypeName = 'CN Stock In Request';
        controller.fields = 'ASI_MFM_Net_Weight__c,ASI_MFM_Box_Size_M3__c';
        controller.fieldsLabel = 'Weight/Unit(KG),Case Size(M3)';
        controller.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.upsertMode = false;
        controller.DefaultValues = '';
        controller.contentFile = blob.valueOf('Weight/Unit(KG),Case Size(M3)\r220,420');
        controller.uploadcsv();
        
        controller.uploadCSVByBatch();
        controller.refreshPage();
        String[] statusMsgs = controller.StatusMsgs;
        
        
        controller.template2 = 'test';
        controller.report = 'test';
        controller.recEXID = 'test';
        controller.recEXIDcol = 'test';
        controller.parentObjectAPIName = 'test';
        controller.ParentObjectUploadMsg = 'test';
        controller.upsertMode = false;
        controller.batchMode = false;
        controller.opt_allOrNone = true;
        controller.monitorFieldName = 'ASI_MFM_Net_Weight__c';
        controller.objName = 'ASI_MFM_Stock_In_Request__c';
        controller.parentID = '123';
        controller.currentPageURLOutput = 'test';
        controller.LOutputRow = new List<ASI_MFM_CN_POSM_MassUploadByBatchCls.Row>();
        controller.AttId = null;
        
        Schema.SObjectType ObjType = Schema.getGlobalDescribe().get('ASI_MFM_PO_POSM_Line__c');
        ASI_MFM_CN_POSM_MassUploadByBatchCls.Row row = new ASI_MFM_CN_POSM_MassUploadByBatchCls.Row(ObjType.newSObject(), 'ASI_MFM_PO__c', po.id+'');
        
        
        test.stopTest();
    }
/*
    public class PoTestObj {
        public Date thisMonth;
        public Date midThisMonth;
        public Date nextMonth;
        public String fy;
        public ASI_MFM_Market_Strategy__c ms;
        public User User1;
        public User User2;
        public  List<User> lstUsr;
        public list<ASI_MFM_Prefix__c> prefixs;
        public list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds;
        public list<ASI_MFM_A_C_Code__c> acs;
        public ASI_MFM_PP_Category__c ppc;
        public list<ASI_MFM_PP_Category_A_C__c> ppcacs;
        public ASI_MFM_Market_Strategy__c mms;
        public List<ASI_MFM_Plan__c> plans;
        public ASI_MFM_Plan__c Plan1;
        public ASI_MFM_Brand__c brand;
        public list<ASI_MFM_Sub_brand__c> subBrands;
        public list<Account> accs;
        public ASI_MFM_Plan_Line_Item__c planLineItem1;
        public ASI_MFM_BU__c bu;
        public ASI_MFM_Exchange_Rate__c ex;
        public list<ASI_MFM_PO__c> pos;
        public list<ASI_MFM_PO_Line_Item__c> polis;
        public ASI_MFM_PO_Receipt__c pOReceipt;
        public ASI_MFM_PO_Receipt_Item__c poreceiptItem;
        

        
        public PoTestObj() {
            ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
            lstUsr = new List<User>();
            User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
            User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
            lstUsr.add(user1);
            lstUsr.add(user2);
            insert lstUsr;
            
			for(user u : [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                          FROM User
                          WHERE id =: user1.id OR id =: user2.id 
                          LIMIT 2]
           	){
                if(user1.id == u.id){
                    user1 = u;
                }else{
                    user2 = u;
               	}
           	}
            
            System.runAs(user1){
                thisMonth = Date.today().toStartOfMonth();
                midThisMonth = thisMonth.addDays(10);
                nextMonth = thisMonth.addMonths(1).addDays(-1);
                fy = ASI_MFM_PO_Trigger_Test.getFiscalYear();
                
                String strRTID;
                
                prefixs = new list<ASI_MFM_Prefix__c>();
                prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
                                                  ,ASI_MFM_Fiscal_year__c=fy,ownerId = user1.id));
                
                //create prefix po
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
                prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                  ASI_MFM_Fiscal_year__c=fy, ASI_MFM_Next_Number__c=86));
                insert prefixs;
                
                prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
                prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
                                                                         ASI_MFM_Role_Name__c =user1.userRole.developerName));            
                prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
                                                                         ASI_MFM_Role_Name__c =user1.userRole.developerName));            
                
                insert prefixChilds;
                
                
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
                acs = new list<ASI_MFM_A_C_Code__c>();
                acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
                acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
                acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
                insert acs;
                
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
                ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
                insert ppc;
                
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
                ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
                ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
                ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
                insert ppcacs; 
                
                mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
                insert mms;
                
                plans = new List<ASI_MFM_Plan__c>();
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan');
                Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
                                                            ,recordTypeId=strRTId ,
                                                            ASI_MFM_End_Date__c = nextMonth, ASI_MFM_Plan_Description__c='testDescription', 
                                                            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=thisMonth, ASI_MFM_Budget_Owner__c=user1.id, 
                                                            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
                plans.add(Plan1);
                insert plans;
                
                
                //create brand
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
                brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
                insert brand; 
                
                subBrands = new list<ASI_MFM_Sub_brand__c>();
                //create sub brand
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_brand');
                subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId, ASI_MFM_Active_for_MFM__c=true));
                subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId, ASI_MFM_Active_for_MFM__c=true));
                subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
                
                insert subBrands;
                

                accs = new list<Account>();
                
                strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
                accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
                
                //ASI_MFM_CN_Supplier 
                strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
                accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                     ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
                accs.add(new Account(Name='TEST',ASI_MFM_Customer_Supplier_Number__c='61202305', 
                                     RecordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Supplier')));
                insert accs;
                
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
                planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                                                        ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
                                                                                        ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =10,ASI_MFM_Remaining_Balance__c=-1,
                                                                                        ASI_MFM_A_C_Code__c=acs[2].id
                                                                                       );
                insert planLineItem1; 
                
                //create BU Code
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
                bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                     ASI_MFM_Base_Currency__c='RMB',recordTypeId=strRTId);
                insert bu;
                
                
                
                //create exchange rate reference
                ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=thisMonth,
                                                                           ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                           ASI_MFM_Application__c='MFM' );
                insert ex;
                
                //create po
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
                pos = new list<ASI_MFM_PO__c>();
                
                pos.add(new ASI_MFM_PO__c(Name='PO66666', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                          ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[2].id, ASI_MFM_Currency__c='RMB',
                                          ASI_MFM_PO_Start_Date__c=thisMonth,ASI_MFM_PO_End_Date__c=nextMonth,
                                          ASI_MFM_Budget_Owner__c =user2.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft',
                                          ASI_MFM_CN_BU_Picklist__c='PRCN'
                                         ));
                insert pos;
                
                
                
                
                //create po line item
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
                polis = new list<ASI_MFM_PO_Line_Item__c>(); 
                polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[0].id, ASI_MFM_G_L_Date__c=midThisMonth,ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                      ASI_MFM_Amount__c  = 20,ASI_MFM_Plan_Line_Item__c = planLineItem1.id,
                                                      ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'  ));
                
                insert polis;
                
                //create receipt header
                strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_CN_PO_Receipt');
                
                pOReceipt = new ASI_MFM_PO_Receipt__c(ASI_MFM_Receipt_Date__c = date.today()
                                                                            , recordTypeId = strRTId
                                                                            , ASI_MFM_Auto_Receipt__c = True
                                                                           );
                insert pOReceipt;
                
                strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_CN_PO_Receipt_item');
                poreceiptItem = new ASI_MFM_PO_Receipt_Item__c(ASI_MFM_Amount__c = 5
                                                                                          , recordTypeId = strRTId
                                                                                          , ASI_MFM_PO_Line_Item__c = polis[0].id
                                                                                          , ASI_MFM_Sub_brand_temp__c = polis[0].ASI_MFM_Sub_brand_Code__c
                                                                                          , ASI_MFM_A_C_Code_temp__c = polis[0].ASI_MFM_A_C_Code__c
                                                                                          , ASI_MFM_PO_Receipt__c = pOReceipt.id
                                                                                          , ASI_MFM_Auto_Receipt__c = True
                                                                                          , ASI_MFM_Receipt_Date__c = date.today()
                                                                                          , ASI_MFM_Currency_Temp__c = polis[0].ASI_MFM_Currency__c
                                                                                         );
                }
            
        }
    }
    
    
    static testMethod void testExtCommitAll(){
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
		PoTestObj testObj = new PoTestObj();
        
        Date thisMonth = testObj.thisMonth;
        Date midThisMonth = testObj.midThisMonth;
        Date nextMonth = testObj.nextMonth;
        String fy = getFiscalYear();
        
        String strRTID;
        User User1 = testObj.lstUsr[0];
        User User2 = testObj.lstUsr[1];
        list<ASI_MFM_PO__c> pos = testObj.pos;
        ASI_MFM_PO_Receipt__c pOReceipt = testObj.pOReceipt;
        
        Id currentUID = UserInfo.getUserId();
        System.runAs(user1){
            Test.startTest();

            List<ASI_MFM_PO_Line_Item__c> polineItemList = testObj.polis;
            
            ASI_MFM_PO__c po = pos[0];
            
            Group objPGp = [SELECT id FROM group WHERE type='Regular' AND name = 'ASI MFM CN Regional User' Limit 1];            
            GroupMember gmember = new GroupMember(UserOrGroupId=user1.id, GroupId=objPGp.Id);
            insert gmember;
            
            list<ASI_MFM_Sub_brand__c> subBrands = testObj.subBrands;
            ASI_MFM_Sub_brand__c sb = subBrands[0];
            ASI_MFM_Sub_brand_Allocation__c sbAllocation = new ASI_MFM_Sub_brand_Allocation__c(Name='Test', ASI_MFM_PO__c=po.id, ASI_MFM_Sub_brand_Code__c=sb.id, recordtypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand_Allocation__cASI_MFM_CN_Sub_Brand_Allocation'));
            insert sbAllocation;
            
            test.setCurrentPage(page.ASI_MFM_CN_InputPOItemsPage);
            apexpages.currentPage().getParameters().put('id', po.id); 
            list<ASI_MFM_PO__c> p_list = new list<ASI_MFM_PO__c>();
            apexpages.standardSetController sc = new apexpages.standardSetController(p_list);  
            ASI_MFM_HK_InputPOItemsController cx = new ASI_MFM_HK_InputPOItemsController(sc); 
            ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
            
            // Assign component attributes
            mcauCon.isFastModeBool = false;
            mcauCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
            mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=T, ASI_MFM_A_C_Code__c&req=T, ASI_MFM_List_Item_Description__c&req=F&width=120px, ASI_MFM_Amount__c&req=T&width=80px';
            mcauCon.fieldToURLParamStr = 'ASI_MFM_PO__c=>id';
            mcauCon.whereStatm = 'ASI_MFM_PO__c = \'' + po.Id + '\'';
            mcauCon.pageBlockTitleStr = 'PO Line Items';
            mcauCon.successLink = '/' + po.Id;
            mcauCon.cancelLink = '/' + po.Id;
            mcauCon.mode = 'BOTH';
            mcauCon.isDefaultEditVal = true;
            mcauCon.ShowAllRT = true;
            mcauCon.ComponentKey = 'massCreateAndUpdate';
            mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c';
            //Boolean initPageBool = mcauCon.dummyVar;
            
            mcauCon.init();
            
            List<ASI_MFM_Sub_brand_Allocation__c> tmp = new List<ASI_MFM_Sub_brand_Allocation__c>();
            tmp.add(sbAllocation);
            
            mcauCon.delItemList = tmp;
            
            ASI_MFM_CN_MassCreateAndUpdateExtCtrl extCon = new ASI_MFM_CN_MassCreateAndUpdateExtCtrl(mcauCon);
            extCon.commitAll();
            extCon.last_plan_balance = -10;
            extCon.commitAll();
            extCon.last_plan_balance = -11;
            extCon.commitAll();
            extCon.last_planline_balanceMap.put(testObj.planLineItem1.id,-11);
            extCon.commitAll();
                     
            extCon.formatMsg('duplicate value found: ASI_MFM_Sys_Deduplication_Key__c');
            for(ASI_MFM_MassCreateAndUpdateController.RecordTypeElement rtEle :mcauCon.theRecordTypeElementList){
                for (ASI_MFM_MassCreateAndUpdateController.TableRow tr : rtEle.myRecordList) {
                    tr.isNew = true;
                }
            }
            extCon.commitAll();   
            
            for(ASI_MFM_MassCreateAndUpdateController.RecordTypeElement rtEle :mcauCon.theRecordTypeElementList){
                for (ASI_MFM_MassCreateAndUpdateController.TableRow tr : rtEle.myRecordList) {
                    tr.isEdit = true;
                    ((ASI_MFM_PO_Line_Item__c)tr.mySObj).ASI_MFM_Amount__c = 11;
                }
            }
            extCon.commitAll();  
/*
            for(ASI_MFM_MassCreateAndUpdateController.RecordTypeElement rtEle :mcauCon.theRecordTypeElementList){
                for (ASI_MFM_MassCreateAndUpdateController.TableRow tr : rtEle.myRecordList) {
                    tr.isDelete = true;
                }
            }
            extCon.commitAll();
            Test.stopTest();
*
        }
    }
*/
	
	static testMethod void test_ASI_MFM_PO_BeforeUpdate_MY() {
		string fy = getFiscalYear();
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        
		ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='USD', ASI_MFM_Counter_Currency__c='EUR', ASI_MFM_Country__c='MY', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = fy);
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
		List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Customer'), Name='Name3');           
        acctList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Supplier'), Name='Name2');           
        acctList.add(acc2);
        
        insert acctList;
		
		ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_MY_Sub_brand'));
        insert sub;
		
		ASI_MFM_BU__c myBU = new ASI_MFM_BU__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_MY_BU'), Name = 'MY BU');
		insert myBU;
		
        ASI_MFM_Plan__c myPlan = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_MY_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert myPlan;


		ASI_MFM_Plan_Line_Item__c myLine =new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = myPlan.id, ASI_MFM_Customer_Name__c = acc1.Id, ASI_MFM_BU_Code__c  = myBU.Id, ASI_MFM_Total_Cost__c=100000,recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_MY_Plan_Line_Item'));
		insert myLine;
				
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;        
        
		test.startTest();
		
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_MY_PO'), ASI_MFM_Plan__c=myPlan.id,ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Prefix__c=px.id, ASI_MFM_BU_Code__c = myBU.Id); 
        insert po;        
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true, ASI_MFM_BU_Code__c = myBU.Id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
		update poi;
		delete poi;
		delete po;
				
        test.stopTest();
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

    static testmethod void test_HK_PO_Webservice_AmountDeductionFail1(){

        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        
       
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_HK_A_C_Code'));
        insert ac;
        
        List<Account> accList = new List<Account>();
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'), Name='Name3');           
        accList.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'), Name='Name2');           
        accList.add(acc1);
        insert accList;

		ASI_HK_CRM_Running_Number__c runNum = new ASI_HK_CRM_Running_Number__c();
        runNum.ASI_HK_CRM_Object_Name__c = 'ASI_TnE_HK_Claim_Header';
        runNum.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1;
        runNum.ASI_HK_CRM_Fiscal_Year__c = 2015;
        insert runNum;        
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();  
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Total_Cost__c = 100);   
            insert pi;  
            
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
            insert pxo; 
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
    
            insert pro;  
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id); 
            insert po;
        
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ASI_MFM_HK_PO_Webservice_AmountDeduction/';  
    	req.httpMethod = 'POST';
        String username = UserInfo.getUserName();
        String request = '{"concurReportId":"Report001","currentUser":"'+username+'","transactions":[{"recordNumber":"92170004", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAA", "expenseType" : "Marketing Expense1"}, {"recordNumber":"AP150004", "expenseAmount": 200, "fxRate" : 1, "concurLineId" : "AAAAAAB", "expenseType" : "CAPEX - Hardware (pre-approved)2"}, {"recordNumber":"92170004", "expenseAmount": 300, "expenseCurrency" : "HKD", "fxRate" : 1, "concurLineId" : "AAAAAAC", "expenseType" : "Marketing Expense3"}]}';
        req.requestBody = Blob.valueOf(request);
        RestContext.request = req;
    	RestContext.response = res;
        
        ASI_MFM_HK_PO_Webservice_AmountDeduction.getPORecord();
        
        Test.stopTest();
    }
    
    static testmethod void ASI_MFM_PO_TriggerClass_TEST1(){
    ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
       List<User> lstUsr = new List<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        lstUsr.add(user2);
        lstUsr.add(user1);
        insert lstUsr;
        user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1];  
/*        list<User> users = new list<User>();
        
        User user2 = ASI_MFM_Function.getManagerCN();
        user2.ASI_MFM_Team__c = 'ABCD';
        System.debug(user2.ASI_MFM_Country__c);
        system.debug(user2.userRole.developerName);
        user2.ASI_MFM_Country__c ='CN';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Team__c = 'ABCD';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        user1.managerid = user2.id;
        users.add(user1);
        
        update users;*/
    
        System.runAs(user1){
        
            String strRTID;
            
            list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                        ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            insert prefixs;
            
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;

            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
            ,recordTypeId=strRTId ,
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            
            //create brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
     
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
            insert subBrands;
                       
            list<Account> accs = new list<Account>();
            
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
             //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                    ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            insert accs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
            ASI_MFM_A_C_Code__c=acs[2].id
            );
            insert planLineItem1; 
            
            //create BU Code
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                ASI_MFM_Base_Currency__c='RMB',recordTypeId=strRTId);
            insert bu;
            
            
            
            //create exchange rate reference
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            //create po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            list<ASI_MFM_PO__c> pos = new list<ASI_MFM_PO__c>();
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            insert pos;
            
            test.startTest();
            
            //create po line item
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            list<ASI_MFM_PO_Line_Item__c> polis = new list<ASI_MFM_PO_Line_Item__c>(); 
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[0].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'
					                                                 ,ASI_MFM_Amount__c=1));
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[1].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'
                                                 						,ASI_MFM_Amount__c=1));
            
            insert polis;
                                    
            pos = [SELECT Id, Name, RecordTypeId, ASI_MFM_Prefix__c, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c,
                                        ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Plan__c, ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Cloned_PO_ID__c,
                                        ASI_MFM_Sys_Sync_Time__c
                                        FROM ASI_MFM_PO__c WHERE Id=:pos[0].Id OR Id=:pos[1].Id];

            pos[0].ASI_MFM_Cloned_PO_ID__c = pos[1].Id;
            pos[1].ASI_MFM_Status__c = 'Complete';
            list<ASI_MFM_PO__c> poOlds = [SELECT Id, Name, RecordTypeId, ASI_MFM_Prefix__c, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c,
                                        ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Plan__c, ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Cloned_PO_ID__c,
                                        ASI_MFM_Sys_Sync_Time__c
                                        FROM ASI_MFM_PO__c WHERE Id=:pos[0].Id OR Id=:pos[1].Id];
            poOlds[0].ASI_MFM_Status__c = 'Submitted';
            poOlds[0].ASI_MFM_Exchange_Rate__c = 99;
            poOlds[0].ASI_MFM_Currency__c = 'HKD';
            poOlds[1].ASI_MFM_Status__c = 'Submitted';
            poOlds[1].ASI_MFM_Exchange_Rate__c = 99;
            poOlds[1].ASI_MFM_Currency__c = 'HKD';

            map<Id,ASI_MFM_PO__c> mapPos = new map<Id,ASI_MFM_PO__c>();
            if(pos[0].Id==poOlds[0].Id)
            {
                mapPos.put(poOlds[0].Id, poOlds[0]);
                mapPos.put(poOlds[1].Id, poOlds[1]);
            }
            else
            {
                mapPos.put(poOlds[1].Id, poOlds[1]);
                mapPos.put(poOlds[0].Id, poOlds[0]);
            }
            
            ASI_MFM_PO_TriggerClass.routineAfterAll(null, mapPos);
            ASI_MFM_PO_TriggerClass.routineAfterAll(pos, mapPos);
            /*ASI_MFM_PO_TriggerClass.routineAfterDelete(pos);
            ASI_MFM_PO_TriggerClass.routineAfterInsert(pos);
            ASI_MFM_PO_TriggerClass.routineAfterUpsert(pos, null);
            ASI_MFM_PO_TriggerClass.routineAfterUpdate(pos, mapPos);
            ASI_MFM_PO_TriggerClass.routineBeforeDelete(pos);
            ASI_MFM_PO_TriggerClass.routineBeforeInsert(pos);
            ASI_MFM_PO_TriggerClass.routineBeforeUpdate(pos, mapPos);
            ASI_MFM_PO_TriggerClass.routineBeforeUpsert(pos, mapPos);
            ASI_MFM_PO_TriggerClass.getCreatableFieldsSOQL('User', 'Id!=null');
            */
            Test.stopTest();
        }        
    }
    
    static testmethod void ASI_MFM_PO_TriggerClass_TEST2(){
    ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
        
  //      list<User> users = new list<User>();
      List<User> lstUsr = new List<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        lstUsr.add(user2);
        lstUsr.add(user1);
        insert lstUsr;
        
        for(user u : [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                      FROM User
                      WHERE id =: user1.id 
                      OR id =: user2.id
                      LIMIT 2]){
                          if(user1.id == u.id){
                              user1 = u;
                          }else{
                              user2 = u;
                          }
                      }
        
        /*user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1];*/
        
     /*   User user2 = ASI_MFM_Function.getManagerCN();
        user2.ASI_MFM_Team__c = 'ABCD';
        System.debug(user2.ASI_MFM_Country__c);
        system.debug(user2.userRole.developerName);
        user2.ASI_MFM_Country__c ='CN';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Team__c = 'ABCD';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        user1.managerid = user2.id;
        users.add(user1);
        
        update users;*/
    
        System.runAs(user1){
        
            String strRTID;
            
            list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                        ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            insert prefixs;
            
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;

            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
            ,recordTypeId=strRTId ,
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            
            //create brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
     
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
            insert subBrands;
                       
            list<Account> accs = new list<Account>();
            
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
             //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                    ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            insert accs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
            ASI_MFM_A_C_Code__c=acs[2].id
            );
            insert planLineItem1; 
            
            //create BU Code
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                ASI_MFM_Base_Currency__c='RMB',recordTypeId=strRTId);
            insert bu;
            
            
            
            //create exchange rate reference
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            //create po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            list<ASI_MFM_PO__c> pos = new list<ASI_MFM_PO__c>();
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            insert pos;
            
            test.startTest();
            
            //create po line item
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            list<ASI_MFM_PO_Line_Item__c> polis = new list<ASI_MFM_PO_Line_Item__c>(); 
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[0].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'
					                                                 ,ASI_MFM_Amount__c=1));
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[1].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'
					                                                 ,ASI_MFM_Amount__c=1));
            
            insert polis;
                                    
            pos = [SELECT Id, Name, RecordTypeId, ASI_MFM_Prefix__c, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c,
                                        ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Plan__c, ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Cloned_PO_ID__c,
                                        ASI_MFM_Sys_Sync_Time__c
                                        FROM ASI_MFM_PO__c WHERE Id=:pos[0].Id OR Id=:pos[1].Id];

            pos[0].ASI_MFM_Cloned_PO_ID__c = pos[1].Id;
            pos[1].ASI_MFM_Status__c = 'Complete';
            list<ASI_MFM_PO__c> poOlds = [SELECT Id, Name, RecordTypeId, ASI_MFM_Prefix__c, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c,
                                        ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Plan__c, ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Cloned_PO_ID__c,
                                        ASI_MFM_Sys_Sync_Time__c
                                        FROM ASI_MFM_PO__c WHERE Id=:pos[0].Id OR Id=:pos[1].Id];
            poOlds[0].ASI_MFM_Status__c = 'Submitted';
            poOlds[0].ASI_MFM_Exchange_Rate__c = 99;
            poOlds[0].ASI_MFM_Currency__c = 'HKD';
            poOlds[1].ASI_MFM_Status__c = 'Submitted';
            poOlds[1].ASI_MFM_Exchange_Rate__c = 99;
            poOlds[1].ASI_MFM_Currency__c = 'HKD';

            map<Id,ASI_MFM_PO__c> mapPos = new map<Id,ASI_MFM_PO__c>();
            if(pos[0].Id==poOlds[0].Id)
            {
                mapPos.put(poOlds[0].Id, poOlds[0]);
                mapPos.put(poOlds[1].Id, poOlds[1]);
            }
            else
            {
                mapPos.put(poOlds[1].Id, poOlds[1]);
                mapPos.put(poOlds[0].Id, poOlds[0]);
            }
            
            /*ASI_MFM_PO_TriggerClass.routineAfterAll(null, mapPos);
            ASI_MFM_PO_TriggerClass.routineAfterAll(pos, mapPos);*/
            ASI_MFM_PO_TriggerClass.routineAfterDelete(pos);
            ASI_MFM_PO_TriggerClass.routineAfterInsert(pos);
            //ASI_MFM_PO_TriggerClass.routineAfterUpsert(pos, null);
            //ASI_MFM_PO_TriggerClass.routineAfterUpdate(pos, mapPos);
            ASI_MFM_PO_TriggerClass.routineBeforeDelete(pos);
            /*ASI_MFM_PO_TriggerClass.routineBeforeInsert(pos);
            ASI_MFM_PO_TriggerClass.routineBeforeUpdate(pos, mapPos);
            ASI_MFM_PO_TriggerClass.routineBeforeUpsert(pos, mapPos);
            ASI_MFM_PO_TriggerClass.getCreatableFieldsSOQL('User', 'Id!=null');*/
            
            Test.stopTest();
        }        
    }
    
    static testmethod void ASI_MFM_PO_TriggerClass_TEST4(){
    ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
        
  //      list<User> users = new list<User>();
      List<User> lstUsr = new List<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        lstUsr.add(user2);
        lstUsr.add(user1);
        insert lstUsr;
        
        for(user u : [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                      FROM User
                      WHERE id =: user1.id 
                      OR id =: user2.id
                      LIMIT 2]){
                          if(user1.id == u.id){
                              user1 = u;
                          }else{
                              user2 = u;
                          }
                      }
        
        /*user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1];*/
        
     /*   User user2 = ASI_MFM_Function.getManagerCN();
        user2.ASI_MFM_Team__c = 'ABCD';
        System.debug(user2.ASI_MFM_Country__c);
        system.debug(user2.userRole.developerName);
        user2.ASI_MFM_Country__c ='CN';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Team__c = 'ABCD';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        user1.managerid = user2.id;
        users.add(user1);
        
        update users;*/
    
        System.runAs(user1){
        
            String strRTID;
            
            list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                        ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            insert prefixs;
            
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;

            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
            ,recordTypeId=strRTId ,
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            
            //create brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
     
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
            insert subBrands;
                       
            list<Account> accs = new list<Account>();
            
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
             //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                    ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            accs.add(new Account(Name='TEST',ASI_MFM_Customer_Supplier_Number__c='61202305', 
                                 RecordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Supplier')));
            insert accs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
            ASI_MFM_A_C_Code__c=acs[2].id
            );
            insert planLineItem1; 
            
            //create BU Code
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                ASI_MFM_Base_Currency__c='RMB',recordTypeId=strRTId);
            insert bu;
            
            
            
            //create exchange rate reference
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            //create po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            list<ASI_MFM_PO__c> pos = new list<ASI_MFM_PO__c>();
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                      ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                      ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                      ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                      ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                      ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                      ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            pos.add(new ASI_MFM_PO__c(Name='PO33333', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                      ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='RMB',
                                      ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                      ASI_MFM_Budget_Owner__c =user2.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            pos.add(new ASI_MFM_PO__c(Name='PO44444', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                      ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[2].id, ASI_MFM_Currency__c='RMB',
                                      ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                      ASI_MFM_Budget_Owner__c =user2.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Final',
                                      ASI_MFM_CN_BU_Picklist__c='PRCN'
                                     ));
            pos.add(new ASI_MFM_PO__c(Name='PO55555', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                      ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[2].id, ASI_MFM_Currency__c='RMB',
                                      ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                      ASI_MFM_Budget_Owner__c =user2.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Submitted',
                                      ASI_MFM_CN_BU_Picklist__c='PRCN'
                                     ));
            pos.add(new ASI_MFM_PO__c(Name='PO66666', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                      ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[2].id, ASI_MFM_Currency__c='RMB',
                                      ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                      ASI_MFM_Budget_Owner__c =user2.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft',
                                      ASI_MFM_CN_BU_Picklist__c='PRCN'
                                     ));
            insert pos;
            
            pos[0].ASI_MFM_Status__c = 'Final';
            pos[5].ASI_MFM_Status__c = 'Final';
            pos[3].ASI_MFM_PO_Start_Date__c = Date.valueof('2014-04-03');
            update pos;
            
            test.startTest();
            
            //create po line item
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            list<ASI_MFM_PO_Line_Item__c> polis = new list<ASI_MFM_PO_Line_Item__c>(); 
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[0].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'
					                                                 ,ASI_MFM_Amount__c=1));
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[1].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'
					                                                 ,ASI_MFM_Amount__c=1));
            
            insert polis;
                                    
            pos = [SELECT Id, Name, RecordTypeId, ASI_MFM_Prefix__c, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c,
                                        ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Plan__c, ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Cloned_PO_ID__c,
                                        ASI_MFM_Sys_Sync_Time__c
                                        FROM ASI_MFM_PO__c WHERE Id=:pos[0].Id OR Id=:pos[1].Id];

            pos[0].ASI_MFM_Cloned_PO_ID__c = pos[1].Id;
            pos[1].ASI_MFM_Status__c = 'Complete';
            list<ASI_MFM_PO__c> poOlds = [SELECT Id, Name, RecordTypeId, ASI_MFM_Prefix__c, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c,
                                        ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Plan__c, ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Cloned_PO_ID__c,
                                        ASI_MFM_Sys_Sync_Time__c
                                        FROM ASI_MFM_PO__c WHERE Id=:pos[0].Id OR Id=:pos[1].Id];
            poOlds[0].ASI_MFM_Status__c = 'Submitted';
            poOlds[0].ASI_MFM_Exchange_Rate__c = 99;
            poOlds[0].ASI_MFM_Currency__c = 'HKD';
            poOlds[1].ASI_MFM_Status__c = 'Submitted';
            poOlds[1].ASI_MFM_Exchange_Rate__c = 99;
            poOlds[1].ASI_MFM_Currency__c = 'HKD';

            map<Id,ASI_MFM_PO__c> mapPos = new map<Id,ASI_MFM_PO__c>();
            if(pos[0].Id==poOlds[0].Id)
            {
                mapPos.put(poOlds[0].Id, poOlds[0]);
                mapPos.put(poOlds[1].Id, poOlds[1]);
            }
            else
            {
                mapPos.put(poOlds[1].Id, poOlds[1]);
                mapPos.put(poOlds[0].Id, poOlds[0]);
            }
            
            /*ASI_MFM_PO_TriggerClass.routineAfterAll(null, mapPos);
            ASI_MFM_PO_TriggerClass.routineAfterAll(pos, mapPos);*/
            //ASI_MFM_PO_TriggerClass.routineAfterDelete(pos);
            //ASI_MFM_PO_TriggerClass.routineAfterInsert(pos);
            ASI_MFM_PO_TriggerClass.routineAfterUpsert(pos, null);
            ASI_MFM_PO_TriggerClass.routineAfterUpdate(pos, mapPos);
            //ASI_MFM_PO_TriggerClass.routineBeforeDelete(pos);
            /*ASI_MFM_PO_TriggerClass.routineBeforeInsert(pos);
            ASI_MFM_PO_TriggerClass.routineBeforeUpdate(pos, mapPos);
            ASI_MFM_PO_TriggerClass.routineBeforeUpsert(pos, mapPos);
            ASI_MFM_PO_TriggerClass.getCreatableFieldsSOQL('User', 'Id!=null');*/
            
            Test.stopTest();
        }        
    }
    
    static testmethod void ASI_MFM_PO_TriggerClass_TEST3(){
    ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
         List<User> lstUsr = new List<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        lstUsr.add(user2);
        lstUsr.add(user1);
        insert lstUsr;
        user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1];
     /*   list<User> users = new list<User>();
        
        User user2 = ASI_MFM_Function.getManagerCN();
        user2.ASI_MFM_Team__c = 'ABCD';
        System.debug(user2.ASI_MFM_Country__c);
        system.debug(user2.userRole.developerName);
        user2.ASI_MFM_Country__c ='CN';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Team__c = 'ABCD';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        user1.managerid = user2.id;
        users.add(user1);
        
        update users;*/
    
        System.runAs(user1){
        
            String strRTID;
            
            list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                        ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            insert prefixs;
            
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;

            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
            ,recordTypeId=strRTId ,
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            
            //create brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
     
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
            insert subBrands;
                       
            list<Account> accs = new list<Account>();
            
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
             //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                    ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            insert accs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
            ASI_MFM_A_C_Code__c=acs[2].id
            );
            insert planLineItem1; 
            
            //create BU Code
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                ASI_MFM_Base_Currency__c='RMB',recordTypeId=strRTId);
            insert bu;
            
            
            
            //create exchange rate reference
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            //create po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            list<ASI_MFM_PO__c> pos = new list<ASI_MFM_PO__c>();
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            insert pos;
            
            test.startTest();
            
            //create po line item
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            list<ASI_MFM_PO_Line_Item__c> polis = new list<ASI_MFM_PO_Line_Item__c>(); 
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[0].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'
					                                                 ,ASI_MFM_Amount__c=1));
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[1].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'
					                                                 ,ASI_MFM_Amount__c=1));
            
            insert polis;
                                    
            pos = [SELECT Id, Name, RecordTypeId, ASI_MFM_Prefix__c, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c,
                                        ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Plan__c, ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Cloned_PO_ID__c,
                                        ASI_MFM_Sys_Sync_Time__c
                                        FROM ASI_MFM_PO__c WHERE Id=:pos[0].Id OR Id=:pos[1].Id];

            pos[0].ASI_MFM_Cloned_PO_ID__c = pos[1].Id;
            pos[1].ASI_MFM_Status__c = 'Complete';
            list<ASI_MFM_PO__c> poOlds = [SELECT Id, Name, RecordTypeId, ASI_MFM_Prefix__c, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c,
                                        ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Plan__c, ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Cloned_PO_ID__c,
                                        ASI_MFM_Sys_Sync_Time__c
                                        FROM ASI_MFM_PO__c WHERE Id=:pos[0].Id OR Id=:pos[1].Id];
            poOlds[0].ASI_MFM_Status__c = 'Submitted';
            poOlds[0].ASI_MFM_Exchange_Rate__c = 99;
            poOlds[0].ASI_MFM_Currency__c = 'HKD';
            poOlds[1].ASI_MFM_Status__c = 'Submitted';
            poOlds[1].ASI_MFM_Exchange_Rate__c = 99;
            poOlds[1].ASI_MFM_Currency__c = 'HKD';

            map<Id,ASI_MFM_PO__c> mapPos = new map<Id,ASI_MFM_PO__c>();
            if(pos[0].Id==poOlds[0].Id)
            {
                mapPos.put(poOlds[0].Id, poOlds[0]);
                mapPos.put(poOlds[1].Id, poOlds[1]);
            }
            else
            {
                mapPos.put(poOlds[1].Id, poOlds[1]);
                mapPos.put(poOlds[0].Id, poOlds[0]);
            }
            
            /*ASI_MFM_PO_TriggerClass.routineAfterAll(null, mapPos);
            ASI_MFM_PO_TriggerClass.routineAfterAll(pos, mapPos);
            ASI_MFM_PO_TriggerClass.routineAfterDelete(pos);
            ASI_MFM_PO_TriggerClass.routineAfterInsert(pos);
            ASI_MFM_PO_TriggerClass.routineAfterUpsert(pos, null);
            ASI_MFM_PO_TriggerClass.routineAfterUpdate(pos, mapPos);
            ASI_MFM_PO_TriggerClass.routineBeforeDelete(pos);*/
            ASI_MFM_PO_TriggerClass.routineBeforeInsert(pos);
            ASI_MFM_PO_TriggerClass.routineBeforeUpdate(pos, mapPos);
            ASI_MFM_PO_TriggerClass.routineBeforeUpsert(pos, mapPos);
            ASI_MFM_PO_TriggerClass.getCreatableFieldsSOQL('User', 'Id!=null');
            
            Test.stopTest();
        }        
    }
    
}