@istest
public class ASI_MFM_SC_TestClass {

    public static string getFiscalYear() {
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);
        Datetime GMTdate = Datetime.now();
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) - 1;
        Integer yearA2 = Integer.valueOf(yearA1) + 1;
        String Current_Fiscal_year;

        if (system.today() < orgFiscalYear) {
            Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        } else {
            Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
        }

        return Current_Fiscal_year;
    }

    public static ASI_MFM_A_C_Code__c createACCode() {
        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
                Name = 'Home Leave',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_SC_A_C_Code')
        );
        insert acCode;
        return acCode;
    }


    public static ASI_MFM_AP_Code__c createAPCode() {
        ASI_MFM_AP_Code__c apCode = new ASI_MFM_AP_Code__c(
                Name = 'test',
                ASI_MFM_Inactive__c = false,
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_SC_AP_Code'),
                ASI_MFM_A_C_Code__c = createACCode().id
        );
        insert apCode;
        return apCode;
    }

    public static ASI_MFM_BU__c createBUCode() {
        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
                Name = 'test',
                ASI_MFM_Inactive__c = false,
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_SC_BU')
        );
        insert buCode;
        return buCode;
    }

    //Supplier    
    public static Account createAccSupplier() {
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_SC_Supplier'), Name = 'test');
        insert acc;
        return acc;
    }

    //Subledger    
    public static Account createAccSubledger() {
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Subleger'), Name = 'test');
        insert acc;
        return acc;
    }


    public static ASI_MFM_Prefix__c createPrefix(String name, String module, String DeveloperName) {
        ASI_MFM_Prefix__c prefix = new ASI_MFM_Prefix__c
                (
                        Name = name,
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_SC_Prefix'),
                        ASI_MFM_Module__c = module,
                        ASI_MFM_Fiscal_year__c = getFiscalYear(),
                        ASI_MFM_Inactive__c = false
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

    public static ASI_MFM_Route_Type__c createApprovalRoute(String module, id prefixid, id userid) {
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(ASI_MFM_EUR_rate__c = 10, ASI_MFM_Type__c = module, Name = 'test',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_SC_Route_Type'));
        insert rt;

        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Prefix__c = prefixid,
                ASI_MFM_Active__c = true,
                ASI_MFM_Responsible_By__c = userid,
                ASI_MFM_Route_Type__c = rt.id);
        insert rtm;

        List<ASI_MFM_Route_Rule_Detail__c> rtd = new List<ASI_MFM_Route_Rule_Detail__c>();
        for (integer i = 0; i < 8; i++) {
            rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c = userid, ASI_MFM_Minimum_Amount__c = i, ASI_MFM_Route_Type__c = rt.id,
                    ASI_MFM_Sequence__c = i));
        }
        insert rtd ;

        return rt;
    }

    public static ASI_MFM_Plan__c createPlan(id prefixid) {
        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(Name = 'test',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SC_Plan'),
                ASI_MFM_Start_Date__c = date.today(),
                ASI_MFM_End_Date__c = date.today(),
                ASI_MFM_Prefix__c = prefixid,
                ASI_MFM_Status__c = 'Final',
                ASI_MFM_Currency__c = 'HKD',
                ASI_MFM_Plan_Type__c = 'OPEX');
        insert plan;
        return plan;
    }

    public static ASI_MFM_Plan_Line_Item__c createPlanLine(id headerid, id apcodeid) {

        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = ASI_MFM_Plan_Line_Item__c.ASI_MFM_AP_Code_PL__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(pickListVal.getValue());
        }

        system.debug('createPlanLine pickListValuesList[0]::' + pickListValuesList[0]);
        ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = headerid,
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_SC_Plan_Line_Item'),
                ASI_MFM_Total_Cost__c = 100000,
                asi_mfm_ap_code__c = apcodeid,
                //ASI_MFM_AP_Code_PL__c=pickListValuesList[0],
                ASI_MFM_List_Item_Description__c = 'hello',
                ASI_MFM_AP_Group__c = 'Non-specific'
        );
        insert planLine;
        /*
        planLine.ASI_MFM_AP_Code_PL__c = pickListValuesList[0];
        update planLine;
        */
        return planLine;
    }

    public static ASI_MFM_PO__c createPO(id prefixid, id planid, id supplierid) {
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_SC_Supplier_Name__c = supplierid,
                ASI_MFM_PO_Raised_Date__c = date.today(),
                ASI_MFM_PO_Start_Date__c = date.today(),
                ASI_MFM_PO_End_Date__c = date.today(),
                ASI_MFM_Status__c = 'Final',
                ASI_MFM_Prefix__c = prefixid,
                ASI_MFM_Plan__c = planid,
                ASI_MFM_Currency__c = 'USD',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SC_PO'));
        insert po;
        return po;
    }

    public static ASI_MFM_PO_Line_Item__c createPoLine(id headerid, id apcodeid, id buid, id subledgerid) {

        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = ASI_MFM_PO_Line_Item__c.ASI_MFM_AP_Code_PL__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(pickListVal.getValue());
        }

        system.debug('createPlanLine pickListValuesList[0]::' + pickListValuesList[0]);

        ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SC_PO_Line_Item'),
                ASI_MFM_PO__c = headerid,
                ASI_MFM_Amount__c = 1000,
                asi_mfm_ap_code__c = apcodeid,
                ASI_MFM_BU_Code__c = buid,
                ASI_MFM_SC_Subledger__c = subledgerid,
                //ASI_MFM_AP_Code_PL__c=pickListValuesList[0],
                ASI_MFM_List_Item_Description__c = 'hello',
                ASI_MFM_AP_Group__c = 'Non-specific'
        );

        insert po_line;
        return po_line;
    }

    public static ASI_MFM_Payment__c createPayment(id prefixid, id poid, id supplierid) {
        ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft',
                ASI_MFM_Prefix__c = prefixid,
                ASI_MFM_SC_Supplier_Name__c = supplierid,
                ASI_MFM_Currency__c = 'USD',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SC_Payment'),
                ASI_MFM_PO__c = poid);

        insert PaymentHeader;
        return PaymentHeader;
    }

    public static ASI_MFM_Payment_Line_Item__c createPaymentLine(id headerid, id poLid, id supplierid, id apcodeid, id buid, id accodeid) {
        ASI_MFM_Payment_Line_Item__c PaymentDetail = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SC_Payment_Line_Item'),
                ASI_MFM_Invoice_Number__c = '000',
                ASI_MFM_Payment__c = headerid,
                ASI_MFM_PO_Line_Item__c = poLid,
                asi_mfm_ap_code__c = apcodeid,
                ASI_MFM_BU__c = buid,
                ASI_MFM_A_C_Code__c = accodeid,
                ASI_MFM_Payment_Amount__c = 100);
        insert PaymentDetail;
        return PaymentDetail;
    }


    static testMethod void testPayment() {
        userrole Role_Test = new userrole(Name = 'XXXTrade Marketing', developerName = 'test');
        insert Role_Test;

        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1];
        u.ASI_MFM_Country__c = 'SC';
        u.UserRoleid = Role_Test.id;
        u.CompanyName = 'Pernod Ricard Hong Kong';
        update u;

        string fiscalYear = getFiscalYear();

        System.runAs(u) {

            ASI_MFM_AP_Code__c AP_Code = createAPCode();
            ASI_MFM_BU__c BU_Code = createBUCode();

            ASI_MFM_Prefix__c prefixPLAN = createPrefix('Plan', 'Plan', Role_Test.DeveloperName);
            ASI_MFM_Prefix__c prefixPO = createPrefix('PO1', 'PO', Role_Test.DeveloperName);
            ASI_MFM_Prefix__c prefixPayment1 = createPrefix('Payment', 'Payment', Role_Test.DeveloperName);
            ASI_MFM_Prefix__c prefixPayment2 = createPrefix('Payment', 'Payment', Role_Test.DeveloperName);

            ASI_MFM_Plan__c plan = createPlan(prefixPLAN.id);
            ASI_MFM_Plan_Line_Item__c planLine1 = createPlanLine(plan.id, AP_Code.id);

            Account acc1 = createAccSupplier();
            Account acc2 = createAccSubledger();

            ASI_MFM_PO__c po = createPO(prefixPO.id, plan.id, acc1.id);
            ASI_MFM_PO_Line_Item__c po_line = createPoLine(po.id, AP_Code.id, BU_Code.id, acc2.id);

            ASI_MFM_Payment__c PaymentHeader = createPayment(prefixPayment1.id, po.id, acc1.id);

            Test.startTest();
            ASI_MFM_Payment_Line_Item__c PaymentDetail = createPaymentLine(PaymentHeader.id, po_line.id, acc1.id, AP_Code.id, BU_Code.id, AP_Code.ASI_MFM_A_C_Code__c);

            ASI_MFM_Route_Type__c routeType1 = createApprovalRoute('Payment', prefixPayment1.id, u.id);
            ASI_MFM_Route_Type__c routeType2 = createApprovalRoute('Payment', prefixPayment2.id, u.id);

            PaymentDetail.ASI_MFM_Payment_Amount__c = 200;
            update PaymentDetail;


            PaymentHeader.ASI_MFM_Currency__c = 'HKD';
            PaymentHeader.ASI_MFM_Invoice_Number__c = 'test no';
            PaymentHeader.ASI_MFM_Invoice_Date__c = system.today();
            PaymentHeader.ASI_MFM_Approved__c = true;
            PaymentHeader.ASI_MFM_Status__c = 'Submitted';
            PaymentHeader.ASI_MFM_Payment_Amount__c = 100;
            update PaymentHeader ;

            PaymentHeader.ASI_MFM_Status__c = 'Draft';
            update PaymentHeader ;

            PaymentHeader.ASI_MFM_Status__c = 'Final';
            try {
                update PaymentHeader;
                // delete PaymentHeader;
            } catch (Exception e) {

            }

            PageReference paymentDetailPage = Page.ASI_MFM_SC_MgAll_PaymentPage;
            Map<String, String> pageParams = paymentDetailPage .getParameters();
            pageParams.put('id', PaymentHeader.Id);
            Test.setCurrentPage(paymentDetailPage);

            try {
                po.ASI_MFM_status__c = 'Submitted';
                update po;
            } catch (Exception e) {

            }

            ASI_MFM_SC_MgAll_PaymentController paymentController = new ASI_MFM_SC_MgAll_PaymentController(
                    new apexpages.standardSetController(new List<ASI_MFM_Payment_Line_Item__c>{
                            PaymentDetail
                    })
            );

            paymentController.getCurrentApprover(PaymentHeader.Id);

            PaymentHeader.ASI_MFM_Route_Type__c = routeType2.id;
            update PaymentHeader;

            PageReference poPayPage = Page.ASI_MFM_SC_PORelatedPaymentsPage;
            Test.setCurrentPage(poPayPage);
            ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(po);
            ASI_MFM_SC_PORelatedPaymentsController poController = new ASI_MFM_SC_PORelatedPaymentsController(stdController2);


            PaymentHeader.ASI_MFM_Status__c = 'Draft';
            // update PaymentHeader ;

            // delete PaymentDetail;
            // delete PaymentHeader ;

            test.stopTest();

        }
    }


    static testMethod void testPO() {
        userrole Role_Test = new userrole(Name = 'XXXTrade Marketing', developerName = 'test');
        insert Role_Test;

        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1];
        u.ASI_MFM_Country__c = 'SC';
        u.UserRoleid = Role_Test.id;
        u.CompanyName = 'Pernod Ricard Hong Kong';
        update u;

        string fiscalYear = getFiscalYear();

        System.runAs(u) {

            ASI_MFM_AP_Code__c AP_Code = createAPCode();
            ASI_MFM_BU__c BU_Code = createBUCode();

            ASI_MFM_Prefix__c prefixPLAN = createPrefix('Plan', 'Plan', Role_Test.DeveloperName);
            ASI_MFM_Prefix__c prefixPO = createPrefix('PO', 'PO', Role_Test.DeveloperName);

            createApprovalRoute('PO', prefixPO.id, u.id);

            ASI_MFM_Plan__c plan = createPlan(prefixPLAN.id);
            ASI_MFM_Plan_Line_Item__c planLine1 = createPlanLine(plan.id, AP_Code.id);

            Account acc1 = createAccSupplier();
            Account acc2 = createAccSubledger();

            ASI_MFM_PO__c po = createPO(prefixPO.id, plan.id, acc1.id);
            ASI_MFM_PO_Line_Item__c po_line = createPoLine(po.id, AP_Code.id, BU_Code.id, acc2.id);


            Test.startTest();

            po_line.ASI_MFM_Amount__c = 200;
            update po_line;


            po.ASI_MFM_Remarks__c = 'test';
            po.ASI_MFM_status__c = 'Draft';
            po.ASI_MFM_Currency__c = 'USD';
            po.ASI_MFM_Exchange_Rate__c = 20;
            update po;

            PageReference pdfPage = Page.ASI_MFM_SC_PO_PDF_Page;
            Test.setCurrentPage(pdfPage);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);
            ASI_MFM_SC_PO_PDF_PageController pdfController = new ASI_MFM_SC_PO_PDF_PageController(stdController);


            List<ASI_MFM_PO_Line_Item__c> poLineSet = new List<ASI_MFM_PO_Line_Item__c>();
            poLineSet .add(po_line);

            apexpages.standardSetController sc = new apexpages.standardSetController(poLineSet);

            PageReference ManageAllPage = Page.ASI_MFM_SC_InputPOItemsPage;
            Map<String, String> pageParams = ManageAllPage.getParameters();


            pageParams.put('id', po.Id);
            Test.setCurrentPageReference(ManageAllPage);

            try {
                po.ASI_MFM_status__c = 'Submitted';
                update po;
            } catch (Exception e) {

            }

            try {
                ApexPages.currentPage().getParameters().put('pid', po.ASI_MFM_Plan__c);
                ApexPages.currentPage().getParameters().put('POType', 'TEST');
                ApexPages.currentPage().getParameters().put('BudgetOwnerId', 'TEST');
                ApexPages.currentPage().getParameters().put('supplierId', 'TEST');
                ApexPages.currentPage().getParameters().put('RecordType', String.valueof(po.recordtypeid).substring(0, 15));

                ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(po);
                ASI_MFM_SelectPOPrefixController ASI_MFM_SelectPOPrefixController = new ASI_MFM_SelectPOPrefixController(stdController2);
                ASI_MFM_SelectPOPrefixController.getPrefixes();
                ASI_MFM_SelectPOPrefixController.proceed();


            } catch (Exception e) {
            }

            ASI_MFM_SC_InputPOItemsController POManageAllController = new ASI_MFM_SC_InputPOItemsController(sc);

            POManageAllController.getCurrentApprover(po.Id);

            ASI_MFM_SC_MassCreateUpdateController mcauCon = new ASI_MFM_SC_MassCreateUpdateController();

            mcauCon.isFastModeBool = false;
            mcauCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
            mcauCon.displayFieldsStr = 'ASI_MFM_BU_Code__c&width=160px&req=T,ASI_MFM_AP_Code__c&width=160px&req=T,asi_mfm_sc_Subledger__c&req=F&width=160px,ASI_MFM_List_Item_Description__c&req=F&width=160px,ASI_MFM_Amount__c&req=T&width=100px,asi_mfm_Recurring_payment_amount__c';
            mcauCon.fieldToURLParamStr = 'ASI_MFM_PO__c=>id';
            mcauCon.whereStatm = 'ASI_MFM_PO__c = \'' + po.Id + '\'';
            mcauCon.orderByStr = 'Name';
            mcauCon.pageBlockTitleStr = 'PO Line Items';
            mcauCon.successLink = '/' + po.Id;
            mcauCon.cancelLink = '/' + po.Id;
            mcauCon.mode = 'BOTH';
            mcauCon.isDefaultEditVal = true;
            mcauCon.ShowAllRT = true;
            mcauCon.isUseFirstRowForNew = true;
            mcauCon.ComponentKey = 'massCreateAndUpdate';
            mcauCon.lookupToPicklist = 'ASI_MFM_BU_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_A_C_Code__c';
            mcauCon.includeRecordTypes = 'ASI_MFM_SC_PO_Line_Item';

            Boolean initPageBool = mcauCon.dummyVar;

            // Start testing user actions
            pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_PO_Line_Item');

            integer recordIndex = 0;
            for (integer i = 0; i < mcauCon.theRecordTypeElementList.size(); i++) {
                system.debug('mcauCon.theRecordTypeElementList IS ' + mcauCon.theRecordTypeElementList.get(i));
                if (mcauCon.theRecordTypeElementList.get(i).myRecordList.size() > 0) {
                    system.debug('ID IS ' + mcauCon.theRecordTypeElementList.get(i).myRecordList.get(0).id);
                    system.debug(' mcauCon.theRecordTypeElementList.get(i).myRecordList.get(0) IS ' + mcauCon.theRecordTypeElementList.get(i).myRecordList.get(0));

                    recordIndex = i;
                    break;

                }
            }


            delete po_line;
            delete po;

            test.stopTest();

        }
    }


    static testMethod void testPlan() {
        userrole Role_Test = new userrole(Name = 'XXXTrade Marketing', developerName = 'test');
        insert Role_Test;

        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1];
        u.ASI_MFM_Country__c = 'SC';
        u.UserRoleid = Role_Test.id;
        u.CompanyName = 'Pernod Ricard Hong Kong';
        update u;

        group gr = new group (Name = 'test', developerName = 'test');
        insert gr;

        GroupMember gm = new GroupMember(GroupId = gr.id, UserOrGroupId = u.id);
        insert gm;

        string fiscalYear = getFiscalYear();

        System.runAs(u) {

            ASI_MFM_AP_Code__c AP_Code = createAPCode();
            ASI_MFM_BU__c BU_Code = createBUCode();

            ASI_MFM_Prefix__c prefixPLAN = createPrefix('Plan', 'Plan', Role_Test.DeveloperName);


            createApprovalRoute('Plan', prefixPLAN.id, u.id);

            ASI_MFM_Plan__c plan = createPlan(prefixPLAN.id);
            ASI_MFM_Plan_Line_Item__c planLine = createPlanLine(plan.id, AP_Code.id);

            Test.startTest();

            plan.ASI_MFM_Currency__c = 'USD' ;
            update plan;

            PageReference POPage = Page.ASI_MFM_SelectPOPrefixPage;
            Test.setCurrentPage(POPage);
            ApexPages.currentPage().getParameters().put('pid', plan.id);
            ApexPages.currentPage().getParameters().put('rid', String.valueof(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SC_PO')).substring(0, 15));
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(new asi_mfm_po__c());
            /*ASI_MFM_SelectPOPrefixController genPoController = new ASI_MFM_SelectPOPrefixController(stdController);
            genPoController.proceed();*/


            List<ASI_MFM_Plan_Line_Item__c> planLineSet = new List<ASI_MFM_Plan_Line_Item__c>();
            planLineSet.add(planLine);

            apexpages.standardSetController sc = new apexpages.standardSetController(planLineSet);

            PageReference ManageAllPage = Page.ASI_MFM_SC_InputPlanItemsPage;
            Map<String, String> pageParams = ManageAllPage.getParameters();

            pageParams.put('id', plan.Id);
            Test.setCurrentPageReference(ManageAllPage);

            try {
                plan.ASI_MFM_Status__c = 'Submitted';
                update plan;
            } catch (Exception e) {

            }

            ASI_MFM_SC_InputPlanItemsController PlanManageAllController = new ASI_MFM_SC_InputPlanItemsController(sc);
            PlanManageAllController.getCurrentApprover(plan.Id);

            ASI_MFM_SC_MassCreateUpdateController mcauCon = new ASI_MFM_SC_MassCreateUpdateController();

            mcauCon.isFastModeBool = false;
            mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
            mcauCon.displayFieldsStr = 'asi_MFM_PR_Company__c&width=160px,ASI_MFM_AP_Code__c&req=T&width=160px,ASI_MFM_List_Item_Description__c&req=T&width=160px,ASI_MFM_Total_Cost__c&req=T&width=100px';
            mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
            mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + plan.Id + '\'';
            mcauCon.orderByStr = 'Name';
            mcauCon.pageBlockTitleStr = 'Plan Line Items';
            mcauCon.successLink = '/' + plan.Id;
            mcauCon.cancelLink = '/' + plan.Id;
            mcauCon.mode = 'BOTH';
            mcauCon.isDefaultEditVal = true;
            mcauCon.ShowAllRT = true;
            mcauCon.isUseFirstRowForNew = true;
            mcauCon.ComponentKey = 'massCreateAndUpdate';
            mcauCon.lookupToPicklist = 'ASI_MFM_AP_Code__c';
            mcauCon.includeRecordTypes = 'ASI_MFM_SC_Plan_Line_Item';

            Boolean initPageBool = mcauCon.dummyVar;

            // Start testing user actions
            pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_Plan_Line_Item');

            integer recordIndex = 0;
            for (integer i = 0; i < mcauCon.theRecordTypeElementList.size(); i++) {
                system.debug('mcauCon.theRecordTypeElementList IS ' + mcauCon.theRecordTypeElementList.get(i));
                if (mcauCon.theRecordTypeElementList.get(i).myRecordList.size() > 0) {
                    system.debug('ID IS ' + mcauCon.theRecordTypeElementList.get(i).myRecordList.get(0).id);
                    system.debug(' mcauCon.theRecordTypeElementList.get(i).myRecordList.get(0) IS ' + mcauCon.theRecordTypeElementList.get(i).myRecordList.get(0));

                    recordIndex = i;
                    break;

                }
            }
            try {
                delete plan;
            } catch (Exception e) {

            }
            try {

                plan.ASI_MFM_Status__c = 'Draft';
                update plan;
                delete plan;
            } catch (Exception e) {

            }
            test.stopTest();

        }
    }


    static testMethod void testAutoPayment() {
        userrole Role_Test = new userrole(Name = 'XXXTrade Marketing', developerName = 'test');
        insert Role_Test;

        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1];
        u.ASI_MFM_Country__c = 'SC';
        u.UserRoleid = Role_Test.id;
        u.CompanyName = 'Pernod Ricard Hong Kong';
        update u;

        string fiscalYear = getFiscalYear();

        System.runAs(u) {

            ASI_MFM_AP_Code__c AP_Code = createAPCode();
            ASI_MFM_BU__c BU_Code = createBUCode();

            ASI_MFM_Prefix__c prefixPLAN = createPrefix('Plan', 'Plan', Role_Test.DeveloperName);
            ASI_MFM_Prefix__c prefixPO = createPrefix('PO', 'PO', Role_Test.DeveloperName);
            ASI_MFM_Prefix__c prefixPayment = createPrefix('Payment', 'Payment', Role_Test.DeveloperName);

            ASI_MFM_Plan__c plan = createPlan(prefixPLAN.id);
            ASI_MFM_Plan_Line_Item__c planLine1 = createPlanLine(plan.id, AP_Code.id);

            Account acc1 = createAccSupplier();
            Account acc2 = createAccSubledger();

            ASI_MFM_PO__c po = createPO(prefixPO.id, plan.id, acc1.id);

            po.recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SC_PO_Read_Only');
            po.ASI_MFM_Recurring_payment__c = true;
            update po;

            ASI_MFM_PO_Line_Item__c po_line = createPoLine(po.id, AP_Code.id, BU_Code.id, acc2.id);
            po_line.asi_mfm_Recurring_payment_amount__c = 10;
            update po_line;

            Test.startTest();
            ASI_MFM_SC_GenPORecurringPayment_Sche s = new ASI_MFM_SC_GenPORecurringPayment_Sche();
            s.init();

            po.ASI_MFM_Recurring_payment__c = false;
            update po;

            PageReference PaymentPage = Page.ASI_MFM_SC_GenPayment;
            Test.setCurrentPage(PaymentPage);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);
            apexpages.currentPage().getParameters().put('poid', po.id);
            ASI_MFM_SC_GenPaymentController genPayController = new ASI_MFM_SC_GenPaymentController(stdController);
            genPayController.GenPayment();
            ASI_MFM_SC_Logistic_GenPaymentController genLogPayController = new ASI_MFM_SC_Logistic_GenPaymentController(stdController);
            genLogPayController.GenPayment();

            test.stopTest();

        }
    }

    @isTest
    public static void testMassUpdateController1() {
        string fiscalYear = getFiscalYear();

        userrole Role_Test = new userrole(Name = 'XXXTrade Marketing', developerName = 'test');
        insert Role_Test;

        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1];
        u.ASI_MFM_Country__c = 'SC';
        u.UserRoleid = Role_Test.id;
        u.CompanyName = 'Pernod Ricard Hong Kong';
        update u;

        System.runAs(u) {

            ASI_MFM_AP_Code__c AP_Code = createAPCode();
            ASI_MFM_BU__c BU_Code = createBUCode();

            ASI_MFM_Prefix__c prefixPLAN = createPrefix('Plan', 'Plan', Role_Test.DeveloperName);
            ASI_MFM_Prefix__c prefixPO = createPrefix('PO', 'PO', Role_Test.DeveloperName);
            ASI_MFM_Prefix__c prefixPayment = createPrefix('Payment', 'Payment', Role_Test.DeveloperName);

            ASI_MFM_Plan__c plan = createPlan(prefixPLAN.id);
            ASI_MFM_Plan_Line_Item__c planLine = createPlanLine(plan.id, AP_Code.id);

            Account acc1 = createAccSupplier();
            Account acc2 = createAccSubledger();
            ASI_MFM_PO__c po = createPO(prefixPO.id, plan.id, acc1.id);
            ASI_MFM_PO_Line_Item__c po_line = createPoLine(po.id, AP_Code.id, BU_Code.id, acc2.id);

            Test.startTest();

            list<ASI_MFM_Plan_Line_Item__c> planLineList = new list<ASI_MFM_Plan_Line_Item__c>();
            planLineList.add(planLine);


            ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(planLineList);

            PageReference planInputItemsPage = Page.ASI_MFM_SC_InputPlanItemsPage;
            Map<String, String> pageParams = planInputItemsPage.getParameters();
            pageParams.put('id', plan.Id);
            Test.setCurrentPageReference(planInputItemsPage);

            ASI_MFM_SC_InputPlanItemsController planInputItemsController = new ASI_MFM_SC_InputPlanItemsController(standardController);

            ASI_MFM_SC_MassCreateUpdateController mcauCon = new ASI_MFM_SC_MassCreateUpdateController();


            mcauCon.headerPlanID = plan.id;
            mcauCon.isFastModeBool = false;
            mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
            mcauCon.displayFieldsStr = 'ASI_MFM_PR_Company_Lookup__c&width=160px,ASI_MFM_AP_Group__c&width=160px&req=T,ASI_MFM_AP_Code_PL__c&width=160px&req=T,ASI_MFM_AP_Code__c&width=160px&read=a,ASI_MFM_List_Item_Description__c&req=T&width=160px,ASI_MFM_Total_Cost__c&req=T&width=100px&read=A&ckey=a&skipClone=t&lang=a';
            mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
            mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + plan.Id + '\'';
            mcauCon.orderByStr = 'Name';
            mcauCon.pageBlockTitleStr = 'Plan Line Items';
            mcauCon.successLink = '/' + plan.Id;
            mcauCon.cancelLink = '/' + plan.Id;
            mcauCon.mode = 'BOTH';
            mcauCon.isDefaultEditVal = true;
            mcauCon.showAllRT = false;
            mcauCon.isUseFirstRowForNew = true;
            mcauCon.includeRecordTypes = 'ASI_MFM_SC_Plan_Line_Item';
            mcauCon.componentKey = 'massCreateAndUpdate';
            mcauCon.lookupToPicklist = 'ASI_MFM_AP_Code__c,ASI_MFM_PR_Company_Lookup__c';
            mcauCon.isReadOnlyDeleteFilter = '=';
            //mcauCon.PageController = itChangeRequestController.thisController;
            mcauCon.defaultFieldValuesStr = 'ASI_MFM_Quotation__c=Y';
            Boolean initPageBool = mcauCon.dummyVar;
            pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_SC_Plan_Line_Item');
            Integer recordIndex = 0;
            pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
            mcauCon.commitAll();
            mcauCon.enableForEdit();
            mcauCon.cloneRow();
            mcauCon.addNewRow();
            mcauCon.addNewRowByInfo('ASI_MFM_SC_Plan', plan);
            mcauCon.dummyMethod();
            try {
                mcauCon.poAddFieldPo(new List<ASI_MFM_PO_Line_Item__c>{
                        po_line
                });
            } catch (Exception e) {

            }
            List<ASI_MFM_SC_MassCreateUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
            pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
            mcauCon.removeNew();
            mcauCon.addMoreBlankRows();
            pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
            mcauCon.deleteOld();
            mcauCon.clearAll();
            mcauCon.triggerPageBlockAction();
            List<String> testString = new String[]{
                    'tes1', 'test2'
            };
            mcauCon.initDateFields(testString);
            ASI_MFM_SC_MassCreateUpdateController.DisplayField dp = new ASI_MFM_SC_MassCreateUpdateController.DisplayField('labeltest', 'label', false);
            ASI_MFM_SC_MassCreateUpdateController.DisplayField dp3 = new ASI_MFM_SC_MassCreateUpdateController.DisplayField('labeltest', 'label');
            ASI_MFM_SC_MassCreateUpdateController.PageBlockActionBtn dp2 = new ASI_MFM_SC_MassCreateUpdateController.PageBlockActionBtn('testID', 'label');

        }
    }

    @isTest
    public static void testMassUpdateController2() {
        string fiscalYear = getFiscalYear();

        userrole Role_Test = new userrole(Name = 'XXXTrade Marketing', developerName = 'test');
        insert Role_Test;

        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1];
        u.ASI_MFM_Country__c = 'SC';
        u.UserRoleid = Role_Test.id;
        u.CompanyName = 'Pernod Ricard Hong Kong';
        update u;

        System.runAs(u) {

            ASI_MFM_AP_Code__c AP_Code = createAPCode();
            ASI_MFM_BU__c BU_Code = createBUCode();

            ASI_MFM_Prefix__c prefixPLAN = createPrefix('Plan', 'Plan', Role_Test.DeveloperName);
            ASI_MFM_Prefix__c prefixPO = createPrefix('PO1', 'PO', Role_Test.DeveloperName);
            ASI_MFM_Prefix__c prefixPayment1 = createPrefix('Payment', 'Payment', Role_Test.DeveloperName);
            ASI_MFM_Prefix__c prefixPayment2 = createPrefix('Payment', 'Payment', Role_Test.DeveloperName);

            ASI_MFM_Plan__c plan = createPlan(prefixPLAN.id);
            ASI_MFM_Plan_Line_Item__c planLine = createPlanLine(plan.id, AP_Code.id);

            Account acc1 = createAccSupplier();
            Account acc2 = createAccSubledger();

            ASI_MFM_PO__c po = createPO(prefixPO.id, plan.id, acc1.id);
            ASI_MFM_PO_Line_Item__c po_line = createPoLine(po.id, AP_Code.id, BU_Code.id, acc2.id);

            ASI_MFM_Payment__c PaymentHeader = createPayment(prefixPayment1.id, po.id, acc1.id);

            Test.startTest();
            ASI_MFM_Payment_Line_Item__c PaymentDetail = createPaymentLine(PaymentHeader.id, po_line.id, acc1.id, AP_Code.id, BU_Code.id, AP_Code.ASI_MFM_A_C_Code__c);

            ASI_MFM_Route_Type__c routeType1 = createApprovalRoute('Payment', prefixPayment1.id, u.id);
            ASI_MFM_Route_Type__c routeType2 = createApprovalRoute('Payment', prefixPayment2.id, u.id);

            List<ASI_MFM_Plan_Line_Item__c> planLineList = new list<ASI_MFM_Plan_Line_Item__c>();
            planLineList.add(planLine);

            List<ASI_MFM_Payment_Line_Item__c> paymentLineList = new List<ASI_MFM_Payment_Line_Item__c>();

            ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(paymentLineList);

            PageReference planInputItemsPage = Page.ASI_MFM_SC_InputPlanItemsPage;
            Map<String, String> pageParams = planInputItemsPage.getParameters();
            pageParams.put('id', plan.Id);
            Test.setCurrentPageReference(planInputItemsPage);

            ASI_MFM_SC_MassCreateUpdateController mcauCon = new ASI_MFM_SC_MassCreateUpdateController();

            mcauCon.headerPlanID = plan.id;
            mcauCon.isFastModeBool = false;
            mcauCon.sObjTypeStr = 'ASI_MFM_Payment_Line_Item__c';
            mcauCon.displayFieldsStr = 'ASI_MFM_PO_Line_Item__c&width=160px&req=F,ASI_MFM_BU__c&width=160px&req=T,ASI_MFM_AP_Group__c&width=160px&req=F,ASI_MFM_AP_Code_PL__c&width=160px&req=F,ASI_MFM_AP_Code__c&width=160px&read=a&req=T,ASI_MFM_A_C_Code__c&width=160px&read=a,ASI_MFM_SC_Subledger__c&req=F&width=160px,ASI_MFM_List_Item_Description__c&req=F&width=160px,ASI_MFM_Payment_Amount__c&req=T&width=100px,ASI_MFM_Payment_List_Item_Description__c&req=T&width=100px,ASI_MFM_AC_Remark__c&req=F&width=100px';
            mcauCon.fieldToURLParamStr = 'ASI_MFM_Payment__c=>id';
            mcauCon.whereStatm = 'ASI_MFM_Payment__c = \'' + PaymentHeader.Id + '\'';
            mcauCon.orderByStr = 'Name';
            mcauCon.pageBlockTitleStr = 'Payment Line Items';
            mcauCon.successLink = '/' + PaymentHeader.Id;
            mcauCon.cancelLink = '/' + PaymentHeader.Id;
            mcauCon.mode = 'BOTH';
            mcauCon.isDefaultEditVal = true;
            mcauCon.showAllRT = false;
            mcauCon.isUseFirstRowForNew = true;
            mcauCon.includeRecordTypes = 'ASI_MFM_Payment_Line_Item__c';
            mcauCon.componentKey = 'massCreateAndUpdate';
            mcauCon.lookupToPicklist = 'ASI_MFM_AP_Code__c';
            mcauCon.isReadOnlyDeleteFilter = '=';
            //mcauCon.PageController = itChangeRequestController.thisController;
            Boolean initPageBool = mcauCon.dummyVar;
            pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_SC_Payment_Line_Item');
            Integer recordIndex = 0;
            pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
            mcauCon.commitAll();
            
            /*
            mcauCon.enableForEdit();
            mcauCon.cloneRow();
            mcauCon.addNewRow();
            mcauCon.addNewRowByInfo('ASI_MFM_SC_Plan', plan);
            mcauCon.dummyMethod();
            try {
                mcauCon.poAddFieldPo(new List<ASI_MFM_PO_Line_Item__c>{
                        po_line
                });
            } catch (Exception e) {

            }
			
            List<ASI_MFM_SC_MassCreateUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
            pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
            mcauCon.removeNew();
            mcauCon.addMoreBlankRows();
            pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
            mcauCon.deleteOld();
            mcauCon.clearAll();
            mcauCon.triggerPageBlockAction();
            List<String> testString = new String[]{
                    'tes1', 'test2'
            };
            mcauCon.initDateFields(testString);
            ASI_MFM_SC_MassCreateUpdateController.DisplayField dp = new ASI_MFM_SC_MassCreateUpdateController.DisplayField('labeltest', 'label', false);
            ASI_MFM_SC_MassCreateUpdateController.DisplayField dp3 = new ASI_MFM_SC_MassCreateUpdateController.DisplayField('labeltest', 'label');
            ASI_MFM_SC_MassCreateUpdateController.PageBlockActionBtn dp2 = new ASI_MFM_SC_MassCreateUpdateController.PageBlockActionBtn('testID', 'label');
			*/
        }
    }

    @isTest
    public static void testMassUpload() {
        userrole Role_Test = new userrole(Name = 'XXXTrade Marketing', developerName = 'test');
        insert Role_Test;

        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1];
        u.ASI_MFM_Country__c = 'SC';
        u.UserRoleid = Role_Test.id;
        u.CompanyName = 'Pernod Ricard Hong Kong';
        update u;

        System.runAs(u) {

            ASI_MFM_AP_Code__c AP_Code = createAPCode();
            ASI_MFM_BU__c BU_Code = createBUCode();

            ASI_MFM_Prefix__c prefixPLAN = createPrefix('Plan', 'Plan', Role_Test.DeveloperName);
            ASI_MFM_Prefix__c prefixPO = createPrefix('PO', 'PO', Role_Test.DeveloperName);
            ASI_MFM_Prefix__c prefixPayment = createPrefix('Payment', 'Payment', Role_Test.DeveloperName);

            ASI_MFM_Plan__c plan = createPlan(prefixPLAN.id);
            ASI_MFM_Plan_Line_Item__c planLine1 = createPlanLine(plan.id, AP_Code.id);


            test.startTest();

            ASI_MFM_SC_POMassUploadCtrl controller = new ASI_MFM_SC_POMassUploadCtrl();
            controller.namefile = 'test.csv';

            controller.contentFile = blob.valueOf('Plan,Supplier,Reference_1,Reference_2,Remark,Start_Date (YYYY-MM-DD),End_Date (YYYY-MM-DD),Currency,BU,AP,Subledger,List_Item_Description,Amount,Recurring_Day,Recurring_Amount\r\ntest,test,,,,2018-06-28,2018-06-29,HKD,test,test,test,,100,,\r\n');
            controller.uploadcsv();


            Account acc1 = createAccSupplier();
            Account acc2 = createAccSubledger();

            ASI_MFM_PO__c po = createPO(prefixPO.id, plan.id, acc1.id);
            ASI_MFM_PO_Line_Item__c po_line = createPoLine(po.id, AP_Code.id, BU_Code.id, acc2.id);

            ASI_MFM_Payment__c PaymentHeader = createPayment(prefixPayment.id, po.id, acc1.id);


            PageReference PaymentPage = Page.ASI_MFM_SC_PayDetailMassUpload;
            Test.setCurrentPage(PaymentPage);
            apexpages.currentPage().getParameters().put('PayHeader', PaymentHeader.id);
            apexpages.currentPage().getParameters().put('PoHeader', 'test');
            ASI_MFM_SC_PayDetailMassUploadCtrl controller2 = new ASI_MFM_SC_PayDetailMassUploadCtrl();
            controller2.namefile = 'test.csv';

            controller2.contentFile = blob.valueOf('PO Line,BU,AP,Subleger,Amount,Line Description\r\n,test,test,test,10,\r\n');
            controller2.uploadcsv();

            test.stopTest();
        }
    }

    public testMethod static void testEmailAttachment() {
        userrole Role_Test = new userrole(Name = 'XXXTrade Marketing', developerName = 'test');
        insert Role_Test;

        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1];
        u.ASI_MFM_Country__c = 'SC';
        u.UserRoleid = Role_Test.id;
        u.CompanyName = 'Pernod Ricard Hong Kong';
        update u;

        System.runAs(u) {
            ASI_MFM_Prefix__c prefixPLAN = createPrefix('Plan', 'Plan', Role_Test.DeveloperName);
            ASI_MFM_Plan__c plan = createPlan(prefixPLAN.id);
            ASI_MFM_SC_EmailAttachmentController c = new ASI_MFM_SC_EmailAttachmentController();
            c.currentHeaderId = plan.id;
            c.getFileAttachments();
        }

    }


}