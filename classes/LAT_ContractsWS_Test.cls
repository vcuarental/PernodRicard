@isTest
public class LAT_ContractsWS_Test {

    @testSetup
    static void testSetup(){
        
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
        LAT_GeneralConfig__c cfg1 = new LAT_GeneralConfig__c(
            name = 'OPP_Verification_Email_Recipients',
            lat_value__c = 'test@zimmic.com,test@zimmic.com');
        insert cfg1;
    }

    public static void setup(User u) { 
        createCreds();
        insert new LAT_GeneralConfig__c (Name= 'LAT_PRODUCT_COST_CHANNELS', LAT_Value__c = '101,102,103,104,112,113,114,115,116');
        Account a = LAT_Account_TestFactory.getAccountOnTradeBraComplete();
        a.Rating_segmentation_targert_market__c = 'STANDARD';
        a.Client_code_AN8__c = '123451236';
        a.OwnerId = u.Id;
        a.Revenue_UF__c = 'SP';
        insert a;
        System.debug('%%%%% en Setup after insert Account : ' + a);
    }

    private static LAT_ReferenceProductGrouping__c parentPG;
    private static LAT_ReferenceProductGrouping__c paymentPG;
    private static LAT_ReferenceProductGrouping__c productCostPG;

    public static LAT_Contract2__c getContract() { 
        return getContract('LAT_OnTrade_CommercialConditionContract');
    }
    public static LAT_Contract2__c getContract(String strDeveloperName) {

        Account a = [SELECT Id FROM Account LIMIT 1]; 
        LAT_Contract2__c con = new LAT_Contract2__c (
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+ strDeveloperName) ,
                Status__c = 'Novo Contrato',
                Account__c = a.Id,
                StartDate__c = Date.today().addDays(-180),
                EndDate__C =  Date.today().addDays(180),
                ROI_Target__c = 12.0
            );
        return con;
    }

    public static LAT_Contract2__c getContractWithManager() {

        Account a = [SELECT Id FROM Account LIMIT 1]; 
        User u = getLAT_BR2Vendas();
        LAT_Contract2__c con = new LAT_Contract2__c (
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_OnTrade_CommercialConditionContract') ,
                Status__c = 'Novo Contrato',
                Account__c = a.Id,
                StartDate__c = Date.today().addDays(-180),
                EndDate__C =  Date.today().addDays(180),
                ROI_Target__c = 12.0,
                OwnerId = u.Id
            );
        return con;
    }
    
    public static LAT_ContractVolume__c getContractVolume(Id idContrato) {
        LAT_ReferenceProductGrouping__c rpg = getParentRefProdGrouping();
        LAT_ContractVolume__c cv = new LAT_ContractVolume__c (
                LAT_Contract__c = idContrato,
                ProductGroup__c = rpg.Id,
                BusinessCondition__c = 10,
                BoxesContract__c = 15
            );
        return cv;
    }

    
    public static void inserCollectsNFLines(String accountId, String idProductGroup) {
        LAT_SelloutCollect__c header = new LAT_SelloutCollect__c (
                ReferencedMonth__c = Date.today().addDays(-1),
                AccountID__c = accountId,
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_SellOutCollect__c'+'LAT_CollectNF')
            );
        insert header;
        LAT_SelloutCollectLine__c line = new LAT_SelloutCollectLine__c (
                SellOutCollect__c = header.Id,
                ReferenceProductGrouping__c = idProductGroup,
                SellOut__c = 10
            );
        insert line;
    }

    public static void inserCollectsNFLinesNoParent(String accountId) {
        LAT_SelloutCollect__c header = new LAT_SelloutCollect__c (
                ReferencedMonth__c = Date.today().addDays(-1),
                AccountID__c = accountId,
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_SellOutCollect__c'+'LAT_CollectNF')
            );
        insert header;
        LAT_ReferenceProductGrouping__c ret = new LAT_ReferenceProductGrouping__c (
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ContractVolume')   ,
                Name = 'Test Parent Prod Grouping 2',
                Order__c = 100,
                GroupType__c ='SKU'
            );
        insert ret;
        LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
            Name = 'Test Product Payment Prod Grouping No PArent',
            Order__c = 10,
            GroupType__c ='SKU',
            Parent__c = ret.Id
        );
        insert rpg;
        LAT_SelloutCollectLine__c line = new LAT_SelloutCollectLine__c (
                SellOutCollect__c = header.Id,
                ReferenceProductGrouping__c = rpg.Id,
                SellOut__c = 10
            );
        insert line;
    }

    public static LAT_Payment__c getPaymentProducto(Id idContrato) {
        LAT_ReferenceProductGrouping__c parentRpg = getParentRefProdGrouping();
        if (paymentPG==null) {
            LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                        RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                        Name = 'Test Product Payment Prod Grouping',
                        Order__c = 100,
                        GroupType__c ='SKU',
                        Parent__c = parentRpg.Id
                    );
            insert rpg;
            paymentPG = rpg;
        }
        LAT_Payment__c cv = new LAT_Payment__c (
                LAT_Contract__c = idContrato,
                PaymentDateDone__c = Date.today(),
                ProductGroup__c = paymentPG.Id,
                PaymentDate__c   = Date.today(),
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'),
                Finality__c = 'Contrato',
                Status__c = 'P',
                Type__c = 'Test',
                Volumen__c = 10
            );
        return cv;
    }


    public static LAT_Payment__c getPaymentProductoWithParent(Id idContrato) {
        LAT_ReferenceProductGrouping__c parentRpg = getParentRefProdGrouping();
        LAT_Payment__c parentPayment = getPaymentParent(idContrato);
        insert parentPayment;
        if (paymentPG==null) {
            LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                        RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                        Name = 'Test Product Payment Prod Grouping',
                        Order__c = 100,
                        GroupType__c ='SKU',
                        Parent__c = parentRpg.Id
                    );
            insert rpg;
            paymentPG = rpg;
        }
        LAT_Payment__c cv = new LAT_Payment__c (
                LAT_Contract__c = idContrato,
                PaymentDateDone__c = Date.today(),
                ProductGroup__c = paymentPG.Id,
                PaymentDate__c   = Date.today(),
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'),
                Finality__c = 'Contrato',
                Status__c = 'P',
                Type__c = 'Test',
                Volumen__c = 10,
                ParentPayment__c = parentPayment.Id
            );
        return cv;
    }

    public static LAT_Payment__c getPaymentDinhero(Id idContrato) {
        LAT_Payment__c cv = new LAT_Payment__c (
                LAT_Contract__c = idContrato,
                PaymentDateDone__c = Date.today(),
                PaymentDate__c   = Date.today(),
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoDinheiro'),
                Finality__c = 'Contrato',
                Status__c = 'P',
                Type__c = 'Test',
                Ammount__c = 1000.00
            );
        return cv;
    }

    public static LAT_Payment__c getPaymentParent(Id idContrato) {
        LAT_Payment__c cv = new LAT_Payment__c (
                LAT_Contract__c = idContrato,
                PaymentDateDone__c = Date.today(),
                PaymentDate__c   = Date.today(),
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PaymentGroup'),
                paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
                Status__c = 'P',
                Ammount__c = 1000.00
            );
        return cv;
    }

    public static LAT_Payment__c getPaymentDinheroWithParent(Id idContrato) {
        LAT_Payment__c parentPayment = getPaymentParent(idContrato);
        insert parentPayment;
        LAT_Payment__c cv = new LAT_Payment__c (
                LAT_Contract__c = idContrato,
                PaymentDateDone__c = Date.today(),
                PaymentDate__c   = Date.today(),
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoDinheiro'),
                Finality__c = 'Contrato',
                Status__c = 'P',
                Type__c = 'Test',
                Ammount__c = 1000.00,
                ParentPayment__c = parentPayment.Id
            );
        return cv;
    }
    
    public static LAT_ReferenceProductGrouping__c getParentRefProdGrouping() {
        if (parentPG == null) {
            LAT_ReferenceProductGrouping__c ret = new LAT_ReferenceProductGrouping__c (
                    RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ContractVolume')   ,
                    Name = 'Test Parent Prod Grouping',
                    Order__c = 100,
                    GroupType__c ='SKU'
                );
            insert ret;
            parentPG = ret;
        }

        return parentPG;
    }

    public static Task getNewTask(Id contractId) {
        Task t = new Task(
                RecordTypeId = Global_RecordTypeCache.getRtId('Task'+'LAT_Contract'),
                LAT_Tipo__c = 'CT-Assinatura',
                status = 'Completed',
                WhatId = contractId
            );
        return t;
    }

    public static LAT_ProductCost__c getProductCost() {
        UDC__c UdcTest = new UDC__c();
        UdcTest.CodUs__c = '03';
        UdcTest.CodProd__c = '101';
        UdcTest.CodDefUsuario__c = '101';
        UdcTest.Internal_Id__c = 'test';
        insert UdcTest;

        LAT_ReferenceProductGrouping__c parentRpg = getParentRefProdGrouping();
        if (productCostPG==null) {
            LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                        RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                        Name = 'Test Product Payment Prod Grouping',
                        Order__c = 100,
                        GroupType__c ='SKU',
                        Parent__c = parentRpg.Id
                    );
            insert rpg;
            productCostPG = rpg;
        }
        String month = String.valueOf(Date.today().month());
        if (month.length()==1) {
            month = '0'+month;
        }
        LAT_ProductCost__c pc = new LAT_ProductCost__c (
                Product__c = productCostPG.Id,
                Canal__c = UdcTest.Id,
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ProductCost__c'+'LAT_ProductPayment')    ,
                CM_Case__c = 100,
                LDCost__c = 100,
                Start_Year__c = String.valueOf(Date.today().year()),
                Start_Month__c = month,
                DistributorCost__c = 100,
                EndDate__c = Date.today().addDays(180),
                StartDate__c = Date.today().addDays(-180),
                UF__c = 'SP'
            );
        return pc;
    }

    @isTest 
    static void test_method_one() {
        User u = getLAT_BR2Vendas();
        System.debug('%%% email : ' + u.Email);
        setup(u);
        LAT_CheckPaymentStatusOnME_Batch.getMockCashPayment();
        try{
        System.runAs(u) {
           
            Test.startTest();
            LAT_Contract2__c c = getContract();
            c.EndDate__c =  Date.today().addDays(130);
            c.Status__c = 'Ativo';
            insert c;

            LAT_ContractVolume__c cv = getContractVolume(c.id);
            insert cv;

            
            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', JSON.serialize(LAT_ContractPaymentsHandlerInt_Test.getMockCashPayment()), mapa));
            if (paymentPG==null) {
                LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                            Name = 'Test Product Payment Prod Grouping',
                            Order__c = 100,
                            GroupType__c ='SKU',
                            Parent__c = parentPG.Id
                        );
                insert rpg;
                paymentPG = rpg;
            }
            inserCollectsNFLines(c.Account__c, paymentPG.Id);
            LAT_Payment__c paymentp = getPaymentProductoWithParent(c.id);
            paymentp.IDMe__c = '12';
            insert paymentp;
            // LAT_Payment__c paymentd = getPaymentDinheroWithParent(c.id);
            // paymentd.IDMe__c = '14';
            // insert paymentd;
            LAT_ContractsCalculations.productCost cost = new LAT_ContractsCalculations.productCost();
            cost.productId = paymentPG.Id;
            cost.skuName = paymentPG.Name;
            cost.nis = 10.00;
            cost.ldCost = 10.00;
            cost.distCost = 10.00;
            cost.cmCase = 10.00;
            cost.unitOfMeasurement = 'LT';
            cost.hasSKU = false;
            
            Map<Id, String> mapConversion = null;
            mapConversion = new Map<Id, String>();
            mapConversion.put(cost.productId,cost.skuName);
            
            Map<Id, Double> mapConversion2 = null;
            mapConversion2 = new Map<Id, Double>();
            mapConversion2.put(cost.productId,20);


            LAT_ContractsWS.applyFactor(cost, 1, 1);
            LAT_ContractsWS.getKeyByProductGroup(new List<LAT_ContractsCalculations.productCost> {cost} ,  mapConversion, 'CA');
            
            try {LAT_ContractsWS.convertEventUnits(new List<LAT_ContractsCalculations.productCost> {cost} ,  mapConversion2, 'CA'); } catch (Exception Ex) {}


            LAT_ContractDA__c conDA = new LAT_ContractDA__c(
                Contract__c = c.Id,
                DANumber__c = 12345,
                Fiscal_Year__c = 'FY17',
                Type__c = 'TE',
                Status__c = 'Ativo'
                );
            insert conDA;
            System.debug('%%%%% 1');
            //LAT_ContractsWS conWS = new LAT_ContractsWS();
            //LAT_ContractsWS.checkPaymentRelease(paymentd.Id);
            LAT_ContractsWS.checkPaymentRelease(paymentp.Id);
            // Any Id
            LAT_ContractsWS.checkPaymentRelease(conDA.Id);
            LAT_ContractsWS.convertUnits(new List<LAT_ContractsCalculations.productCost>{cost},'CA');
            cost.unitOfMeasurement = 'CA';
            LAT_ContractsWS.convertUnits(new List<LAT_ContractsCalculations.productCost>{cost},'LT');
            LAT_ContractsWS.paymentToAprove toAprove = new LAT_ContractsWS.paymentToAprove();
            toAprove.paymentID = String.valueOf(paymentp.Id);
            LAT_ContractsWS.groupPayments(new List<LAT_ContractsWS.paymentToAprove>{toAprove});
            LAT_ContractsWS.runApprovalProcess(new List<String>{String.valueOf(paymentp.Id)});
            System.debug('%%%%% 2');
            LAT_CheckPaymentStatusOnME_Batch b = new LAT_CheckPaymentStatusOnME_Batch();
            try{Database.executeBatch(b);}catch(Exception e){}
            LAT_CheckPaymentStatusOnME_Scheduler sch1 = new LAT_CheckPaymentStatusOnME_Scheduler();
            String sch = '0 0 23 * * ?';
            System.debug('%%%%% 3');
            //system.schedule('Test check', sch, sch1);
            System.debug('%%%%% 4');
            LAT_Contract_Batch lcb = new LAT_Contract_Batch();
            LAT_Contract2__c con = [SELECT Name, owner.Email, Account__r.Name, (Select Ammount__c,Finality__c,Id,LAT_Contract__c,Name, PaymentDateDone__c,PaymentDate__c,ProductGroup__c,RecordTypeId,Status__c,Type__c, ParentPayment__c FROM LAT_Payments__r), EndDate__c,OwnerId,Status__c, ProcessStatus__c FROM LAT_Contract2__c LIMIT 1] ;
            LAT_Contract_Batch.processExpireNextMonthContract(con);
            LAT_Contract_Batch.processProrrogatedContract(con);
            Database.executeBatch(lcb);
            System.debug('%%%%% 5');
            c.EndDate__c =  Date.today().addDays(30);

            //try{update c;}catch(Exception e){}
            System.debug('%%%%% 6');

            try{Test.stopTest();}catch(Exception e){}
            
            System.debug('%%%%% 7');
        }
        }catch(Exception e){}
        System.debug('%%%%% 8');
    }
    @isTest 
    static void test_method_oneJ() {
        User u = getLAT_BR2Vendas();
        System.debug('%%% email : ' + u.Email);
        setup(u);
        try{
        System.runAs(u) {
           
            Test.startTest();
            LAT_Contract2__c c = getContract();
            c.EndDate__c =  Date.today();
            c.Status__c = 'Ativo';
            c.ProcessStatus__c = 'Contrato Prorrogado';
            insert c;

            LAT_ContractVolume__c cv = getContractVolume(c.id);
            insert cv;

            
            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', JSON.serialize(LAT_ContractPaymentsHandlerInt_Test.getMockCashPayment()), mapa));
            if (paymentPG==null) {
                LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                            Name = 'Test Product Payment Prod Grouping',
                            Order__c = 100,
                            GroupType__c ='SKU',
                            Parent__c = parentPG.Id
                        );
                insert rpg;
                paymentPG = rpg;
            }
            inserCollectsNFLines(c.Account__c, paymentPG.Id);
            LAT_Payment__c paymentp = getPaymentProductoWithParent(c.id);
            paymentp.IDMe__c = '12';
            paymentp.Status__c = 'E';
            insert paymentp;
            // LAT_Payment__c paymentd = getPaymentDinheroWithParent(c.id);
            // paymentd.IDMe__c = '14';
            // insert paymentd;
            LAT_ContractsCalculations.productCost cost = new LAT_ContractsCalculations.productCost();
            cost.productId = paymentPG.Id;
            cost.skuName = paymentPG.Name;
            cost.nis = 10.00;
            cost.ldCost = 10.00;
            cost.distCost = 10.00;
            cost.cmCase = 10.00;
            cost.unitOfMeasurement = 'LT';
            cost.hasSKU = false;

            LAT_ContractDA__c conDA = new LAT_ContractDA__c(
                Contract__c = c.Id,
                DANumber__c = 12345,
                Fiscal_Year__c = 'FY17',
                Type__c = 'TE',
                Status__c = 'Ativo'
                );
            insert conDA;
            System.debug('%%%%% 1');
            //LAT_ContractsWS conWS = new LAT_ContractsWS();
            //LAT_ContractsWS.checkPaymentRelease(paymentd.Id);
           
            System.debug('%%%%% 3');
            //system.schedule('Test check', sch, sch1);
            System.debug('%%%%% 4');
            LAT_Contract_Batch lcb = new LAT_Contract_Batch();
            LAT_Contract2__c con = [SELECT Name, owner.Email, Account__r.Name, (Select Ammount__c,Finality__c,Id,LAT_Contract__c,Name, PaymentDateDone__c,PaymentDate__c,ProductGroup__c,RecordTypeId,Status__c,Type__c, ParentPayment__c FROM LAT_Payments__r), EndDate__c,OwnerId,Status__c, ProcessStatus__c FROM LAT_Contract2__c LIMIT 1] ;
            try{LAT_Contract_Batch.processExpireNextMonthContract(con);}catch(Exception e){}
            try{LAT_Contract_Batch.processProrrogatedContract(con);}catch(Exception e){}
            try{LAT_Contract_Batch.processExpireTodayContract(con);}catch(Exception e){}
            try{LAT_Contract_Batch.processEventContract(con);}catch(Exception e){}
            
            Database.executeBatch(lcb);
            System.debug('%%%%% 5');
            c.EndDate__c =  Date.today().addDays(30);

            //try{update c;}catch(Exception e){}
            System.debug('%%%%% 6');

            try{Test.stopTest();}catch(Exception e){}
            
            System.debug('%%%%% 7');
        }
        }catch(Exception e){}
        System.debug('%%%%% 8');
    }

    @isTest 
    static void test_method_oneJJ() {
        User u = getLAT_BR2Vendas();
        System.debug('%%% email : ' + u.Email);
        setup(u);
        try{
        System.runAs(u) {
           
            Test.startTest();
            LAT_Contract2__c c = getContract();
            c.EndDate__c =  Date.today();
            c.Status__c = 'Ativo';
            c.ProcessStatus__c = 'Contrato Prorrogado';
            insert c;

            LAT_ContractVolume__c cv = getContractVolume(c.id);
            insert cv;

            
            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', JSON.serialize(LAT_ContractPaymentsHandlerInt_Test.getMockCashPayment()), mapa));
            if (paymentPG==null) {
                LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                            Name = 'Test Product Payment Prod Grouping',
                            Order__c = 100,
                            GroupType__c ='SKU',
                            Parent__c = parentPG.Id
                        );
                insert rpg;
                paymentPG = rpg;
            }
            inserCollectsNFLines(c.Account__c, paymentPG.Id);
            LAT_Payment__c paymentp = getPaymentParent(c.id);
            paymentp.IDMe__c = '12';
            paymentp.Status__c = 'E';
            insert paymentp;
            // LAT_Payment__c paymentd = getPaymentDinheroWithParent(c.id);
            // paymentd.IDMe__c = '14';
            // insert paymentd;
            LAT_ContractsCalculations.productCost cost = new LAT_ContractsCalculations.productCost();
            cost.productId = paymentPG.Id;
            cost.skuName = paymentPG.Name;
            cost.nis = 10.00;
            cost.ldCost = 10.00;
            cost.distCost = 10.00;
            cost.cmCase = 10.00;
            cost.unitOfMeasurement = 'LT';
            cost.hasSKU = false;

            LAT_ContractDA__c conDA = new LAT_ContractDA__c(
                Contract__c = c.Id,
                DANumber__c = 12345,
                Fiscal_Year__c = 'FY17',
                Type__c = 'TE',
                Status__c = 'Ativo'
                );
            insert conDA;
            System.debug('%%%%% 1');
            //LAT_ContractsWS conWS = new LAT_ContractsWS();
            //LAT_ContractsWS.checkPaymentRelease(paymentd.Id);
           
            System.debug('%%%%% 3');
            //system.schedule('Test check', sch, sch1);
            System.debug('%%%%% 4');
            LAT_Contract_Batch lcb = new LAT_Contract_Batch();
            LAT_Contract2__c con = [SELECT Name, owner.Email, Account__r.Name, (Select Ammount__c,Finality__c,Id,LAT_Contract__c,Name, PaymentDateDone__c,PaymentDate__c,ProductGroup__c,RecordTypeId,Status__c,Type__c, ParentPayment__c FROM LAT_Payments__r), EndDate__c,OwnerId,Status__c, ProcessStatus__c FROM LAT_Contract2__c LIMIT 1] ;
            try{LAT_Contract_Batch.processExpireNextMonthContract(con);}catch(Exception e){}
            try{LAT_Contract_Batch.processProrrogatedContract(con);}catch(Exception e){}
            try{LAT_Contract_Batch.processExpireTodayContract(con);}catch(Exception e){}
            try{LAT_Contract_Batch.processEventContract(con);}catch(Exception e){}
            
            Database.executeBatch(lcb);
            System.debug('%%%%% 5');
            c.EndDate__c =  Date.today().addDays(30);

            //try{update c;}catch(Exception e){}
            System.debug('%%%%% 6');

            try{Test.stopTest();}catch(Exception e){}
            
            System.debug('%%%%% 7');
        }
        }catch(Exception e){}
        System.debug('%%%%% 8');
    }

    @isTest static void test_method_oneNewIMMbatch() {

        addIMMData();
        User u = getLAT_BR2Vendas();
        setup(u);
        
    }

    @isTest static void test_method_oneplus() {
        User u = getLAT_BR2Vendas();
        setup(u);
        System.runAs(u) {
            Test.startTest();
            LAT_Contract2__c c = getContract();
            c.EndDate__c =  Date.today();
            c.Status__c = 'Ativo';
            insert c;

            LAT_ContractVolume__c cv = getContractVolume(c.id);
            insert cv;

            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');

            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', JSON.serialize(LAT_ContractPaymentsHandlerInt_Test.getMockCashPayment()), mapa));
            if (paymentPG==null) {
                LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                            Name = 'Test Product Payment Prod Grouping',
                            Order__c = 100,
                            GroupType__c ='SKU',
                            Parent__c = parentPG.Id
                        );
                insert rpg;
                paymentPG = rpg;
            }
            inserCollectsNFLines(c.Account__c, paymentPG.Id);
            LAT_Payment__c paymentp = getPaymentProductoWithParent(c.id);
            paymentp.IDMe__c = '12';

            LAT_Payment__c paymentp2 = getPaymentProductoWithParent(c.id);

            LAT_Payment__c paymentp3 = getPaymentParent(c.Id);

            List<LAT_Payment__c> payments = new List<LAT_Payment__c>{paymentp,paymentp2,paymentp3};
            insert payments;

            // LAT_Payment__c paymentd = getPaymentDinheroWithParent(c.id);
            // paymentd.IDMe__c = '14';
            // insert paymentd;
            // LAT_ContractsCalculations.productCost cost = new LAT_ContractsCalculations.productCost();
            // cost.productId = paymentPG.Id;
            // cost.skuName = paymentPG.Name;
            // cost.nis = 10.00;
            // cost.ldCost = 10.00;
            // cost.distCost = 10.00;
            // cost.cmCase = 10.00;
            // cost.unitOfMeasurement = 'LT';
            // cost.hasSKU = false;

            // LAT_ContractDA__c conDA = new LAT_ContractDA__c(
            //  Contract__c = c.Id,
            //  DANumber__c = 12345,
            //  Fiscal_Year__c = 'FY17',
            //  Type__c = 'TE',
            //  Status__c = 'Ativo'
            //  );
            // insert conDA;

            // //LAT_ContractsWS conWS = new LAT_ContractsWS();
            // //LAT_ContractsWS.checkPaymentRelease(paymentd.Id);
            // LAT_ContractsWS.checkPaymentRelease(paymentp.Id);
            // // Any Id
            // LAT_ContractsWS.checkPaymentRelease(conDA.Id);
            // LAT_ContractsWS.convertUnits(new List<LAT_ContractsCalculations.productCost>{cost},'CA');
            // cost.unitOfMeasurement = 'CA';
            // LAT_ContractsWS.convertUnits(new List<LAT_ContractsCalculations.productCost>{cost},'LT');
            // LAT_ContractsWS.paymentToAprove toAprove = new LAT_ContractsWS.paymentToAprove();
            // toAprove.paymentID = String.valueOf(paymentp.Id);
            // LAT_ContractsWS.groupPayments(new List<LAT_ContractsWS.paymentToAprove>{toAprove});
            // LAT_ContractsWS.runApprovalProcess(new List<String>{String.valueOf(paymentp.Id)});



            LAT_CheckPaymentStatusOnME_Batch b = new LAT_CheckPaymentStatusOnME_Batch();
            Database.executeBatch(b);
            LAT_CheckPaymentStatusOnME_Scheduler sch1 = new LAT_CheckPaymentStatusOnME_Scheduler();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sch1);

            LAT_Contract_Batch lcb = new LAT_Contract_Batch();
            Database.executeBatch(lcb);

            Test.stopTest();
        }
    }
    @isTest static void test_method_oneplusB() {
        User u = getLAT_BR2Vendas();
        setup(u);
        System.runAs(u) {
            Test.startTest();
            LAT_Contract2__c c = getContract();
            c.EndDate__c =  Date.today();
            c.Status__c = 'Ativo';
            insert c;

            LAT_ContractVolume__c cv = getContractVolume(c.id);
            insert cv;

            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');

            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', JSON.serialize(LAT_ContractPaymentsHandlerInt_Test.getMockCashPayment()), mapa));
            if (paymentPG==null) {
                LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                            Name = 'Test Product Payment Prod Grouping',
                            Order__c = 100,
                            GroupType__c ='SKU',
                            Parent__c = parentPG.Id
                        );
                insert rpg;
                paymentPG = rpg;
            }
            inserCollectsNFLines(c.Account__c, paymentPG.Id);
            LAT_Payment__c paymentp = getPaymentProductoWithParent(c.id);
            paymentp.IDMe__c = '12';

            LAT_Payment__c paymentp2 = getPaymentProductoWithParent(c.id);

            LAT_Payment__c paymentp3 = getPaymentParent(c.Id);

            List<LAT_Payment__c> payments = new List<LAT_Payment__c>{paymentp,paymentp2,paymentp3};
            insert payments;

            // LAT_Payment__c paymentd = getPaymentDinheroWithParent(c.id);
            // paymentd.IDMe__c = '14';
            // insert paymentd;
            // LAT_ContractsCalculations.productCost cost = new LAT_ContractsCalculations.productCost();
            // cost.productId = paymentPG.Id;
            // cost.skuName = paymentPG.Name;
            // cost.nis = 10.00;
            // cost.ldCost = 10.00;
            // cost.distCost = 10.00;
            // cost.cmCase = 10.00;
            // cost.unitOfMeasurement = 'LT';
            // cost.hasSKU = false;

            // LAT_ContractDA__c conDA = new LAT_ContractDA__c(
            //  Contract__c = c.Id,
            //  DANumber__c = 12345,
            //  Fiscal_Year__c = 'FY17',
            //  Type__c = 'TE',
            //  Status__c = 'Ativo'
            //  );
            // insert conDA;

            // //LAT_ContractsWS conWS = new LAT_ContractsWS();
            // //LAT_ContractsWS.checkPaymentRelease(paymentd.Id);
            // LAT_ContractsWS.checkPaymentRelease(paymentp.Id);
            // // Any Id
            // LAT_ContractsWS.checkPaymentRelease(conDA.Id);
            // LAT_ContractsWS.convertUnits(new List<LAT_ContractsCalculations.productCost>{cost},'CA');
            // cost.unitOfMeasurement = 'CA';
            // LAT_ContractsWS.convertUnits(new List<LAT_ContractsCalculations.productCost>{cost},'LT');
            // LAT_ContractsWS.paymentToAprove toAprove = new LAT_ContractsWS.paymentToAprove();
            // toAprove.paymentID = String.valueOf(paymentp.Id);
            // LAT_ContractsWS.groupPayments(new List<LAT_ContractsWS.paymentToAprove>{toAprove});
            // LAT_ContractsWS.runApprovalProcess(new List<String>{String.valueOf(paymentp.Id)});



            LAT_CheckPaymentStatusOnME_Batch b = new LAT_CheckPaymentStatusOnME_Batch();
            Database.executeBatch(b);
            LAT_CheckPaymentStatusOnME_Scheduler sch1 = new LAT_CheckPaymentStatusOnME_Scheduler();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sch1);

            LAT_Contract_Batch lcb = new LAT_Contract_Batch();
            Database.executeBatch(lcb);

            Test.stopTest();
        }
    }
    @isTest static void test_method_oneplus2() {
        User u = getLAT_BR2Vendas();
        setup(u);
        CS001_JDEInterfaceCredentials__c setting = CS001_JDEInterfaceCredentials__c.getInstance('Brasil');
        setting.UseIMM__c = true;
        update setting;
        System.runAs(u) {
            Test.startTest();
            LAT_Contract2__c c = getContract();
            c.EndDate__c =  Date.today();
            c.Status__c = 'Ativo';
            insert c;

            LAT_ContractVolume__c cv = getContractVolume(c.id);
            insert cv;

            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', JSON.serialize(LAT_ContractPaymentsHandlerInt_Test.getMockCashPayment()), mapa));
            if (paymentPG==null) {
                LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                            Name = 'Test Product Payment Prod Grouping',
                            Order__c = 100,
                            GroupType__c ='SKU',
                            Parent__c = parentPG.Id
                        );
                insert rpg;
                paymentPG = rpg;
            }
            inserCollectsNFLines(c.Account__c, paymentPG.Id);
            LAT_Payment__c paymentp = getPaymentProductoWithParent(c.id);
            paymentp.IDMe__c = '10';

            LAT_Payment__c paymentp2 = getPaymentProducto(c.id);
            paymentp2.IDMe__c = '14';

            LAT_Payment__c paymentp3 = getPaymentParent(c.Id);
            paymentp3.IDMe__c = '12';

            LAT_Payment__c paymentp5 = getPaymentParent(c.Id);
            paymentp5.IDMe__c = '12';
            paymentp5.Ammount__c = 0;

            LAT_Payment__c paymentp4 = getPaymentDinhero(c.Id);
            paymentp4.IDMe__c = '11';
            
            List<LAT_Payment__c> payments = new List<LAT_Payment__c>{paymentp,paymentp2,paymentp3,paymentp4,paymentp5};
            insert payments;

            LAT_CheckPaymentStatusOnME_Batch b = new LAT_CheckPaymentStatusOnME_Batch();
            Database.executeBatch(b);
            LAT_CheckPaymentStatusOnME_Scheduler sch1 = new LAT_CheckPaymentStatusOnME_Scheduler();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sch1);

            LAT_Contract_Batch lcb = new LAT_Contract_Batch();
            Database.executeBatch(lcb);

            Test.stopTest();
        }
    }
    @isTest static void test_restapi() {
        User u = getLAT_BR2Vendas();
        setup(u);
        System.runAs(u) {
            Test.startTest();
            LAT_Contract2__c c = getContract();
            insert c;
    
            String JSONMsg = '{"contractId":"'+c.Id+'"}';
    
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
    
            req.requestURI = '/services/apexrest/LAT_ContractCalculationRest/*';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueof(JSONMsg);
    
            RestContext.request = req;
            RestContext.response= res;
    
            LAT_ContractCalculationRest.post(c.id );
    
            Test.StopTest();
        }
    }

    @isTest static void test_method_oneNew() {
        User u = getLAT_BR2Vendas();
        setup(u);
        System.runAs(u) {
            Test.startTest();
            LAT_Contract2__c c = getContract();
            insert c;

            LAT_ContractVolume__c cv = getContractVolume(c.id);
            insert cv;

            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', JSON.serialize(LAT_ContractPaymentsHandlerInt_Test.getMockCashPayment()), mapa));
            if (paymentPG==null) {
                LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                            Name = 'Test Product Payment Prod Grouping',
                            Order__c = 100,
                            GroupType__c ='SKU',
                            Parent__c = parentPG.Id
                        );
                insert rpg;
                paymentPG = rpg;
            }
            inserCollectsNFLines(c.Account__c, paymentPG.Id);

            LAT_Payment__c paymentd = getPaymentDinheroWithParent(c.id);
            paymentd.IDMe__c = '14';
            insert paymentd;
            LAT_ContractsCalculations.productCost cost = new LAT_ContractsCalculations.productCost();
            cost.productId = paymentPG.Id;
            cost.skuName = paymentPG.Name;
            cost.nis = 10.00;
            cost.ldCost = 10.00;
            cost.distCost = 10.00;
            cost.cmCase = 10.00;
            cost.unitOfMeasurement = 'LT';
            cost.hasSKU = false;

            LAT_ContractDA__c conDA = new LAT_ContractDA__c(
                Contract__c = c.Id,
                DANumber__c = 12345,
                Fiscal_Year__c = 'FY17',
                Type__c = 'TE',
                Status__c = 'Ativo'
                );
            insert conDA;

            LAT_ContractsWS conWS = new LAT_ContractsWS();
            LAT_ContractsWS.checkPaymentRelease(paymentd.Id);

            LAT_ContractsWS.convertUnits(new List<LAT_ContractsCalculations.productCost>{cost},'CA');
            cost.unitOfMeasurement = 'CA';
            LAT_ContractsWS.convertUnits(new List<LAT_ContractsCalculations.productCost>{cost},'LT');

            Test.stopTest();
        }
    }

    @isTest static void test_method_two() {
        User u = getLAT_BR2Vendas();
        setup(u);
        LAT_Contract2__c contract = new LAT_Contract2__c();
        List<LAT_Contract2__c> contractResults = [Select OriginalContractNumber__c From LAT_Contract2__c Limit 1];
        if(contractResults.size() > 0){
            contract = contractResults[0];
        }
        LAT_Contract2__c c = getContract();
        c.OriginalContractNumber__c = contract.OriginalContractNumber__c;
        Test.startTest();
        insert c;

        LAT_ContractVolume__c cv = getContractVolume(c.id);
        insert cv;
        if (paymentPG==null) {
            LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                        RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                        Name = 'Test Product Payment Prod Grouping',
                        Order__c = 100,
                        GroupType__c ='SKU',
                        Parent__c = parentPG.Id
                    );
            insert rpg;
            paymentPG = rpg;
        }
        inserCollectsNFLines(c.Account__c, paymentPG.Id);
        inserCollectsNFLinesNoParent(c.Account__c);
        // LAT_Payment__c paymentp = getPaymentProductoWithParent(c.id);
        // insert paymentp;
        LAT_Payment__c paymentd = getPaymentDinheroWithParent(c.id);
        insert paymentd;
        LAT_Payment__c paymentp = getPaymentProducto(c.id);
        insert paymentp;
        LAT_ContractsWS.Contract con = new LAT_ContractsWS.Contract();
        con.ContractTerms = 6;
        con.uf = 'SP';
        con.RecordType = 'On Trade – contrato de patrocínio';
        LAT_ContractsWS.ContractVolume conVol = new LAT_ContractsWS.ContractVolume();
        conVol.boxesMinimum = 120;
        conVol.product = parentPG.Id;
        List<LAT_ContractsWS.ContractVolume> listConVol = new List<LAT_ContractsWS.ContractVolume>{conVol};
        con.contractVolume = listConVol;
        LAT_ContractsWS.Payments conPay = new LAT_ContractsWS.Payments();
        conPay.ProductGroup = paymentPG.Id;
        conPay.RecordType = 'Pagamento Produto';
        conPay.Volumen = 5;
        con.payments = new List<LAT_ContractsWS.Payments>{conPay};

        LAT_ContractsWS conWS = new LAT_ContractsWS();
        LAT_ContractsWS.generatePaymentWS(c.Id);
        LAT_ContractsWS.emulateRoi(c.Id);
        // LAT_ContractsWS.getContractInformation(con);
        LAT_ContractsWS.calculateRoi(con);
        Test.stopTest();
    }

    @isTest static void test_method_twoNew() {
        try{
        User u = getLAT_BR2Vendas();
        setup(u);
        LAT_Contract2__c c = getContract();
        Test.startTest();
        insert c;

        LAT_ContractVolume__c cv = getContractVolume(c.id);
        insert cv;
        if (paymentPG==null) {
            LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                        RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                        Name = 'Test Product Payment Prod Grouping',
                        Order__c = 100,
                        GroupType__c ='SKU',
                        Parent__c = parentPG.Id
                    );
            insert rpg;
            paymentPG = rpg;
        }
        inserCollectsNFLines(c.Account__c, paymentPG.Id);
        inserCollectsNFLinesNoParent(c.Account__c);
        // LAT_Payment__c paymentp = getPaymentProductoWithParent(c.id);
        // insert paymentp;
        LAT_Payment__c paymentd = getPaymentDinheroWithParent(c.id);
        insert paymentd;
        LAT_ContractsWS.Contract con = new LAT_ContractsWS.Contract();
        con.ContractTerms = 6;
        con.uf = 'SP';
        con.roiSegment = 'STANDARD';
        con.RecordType = 'On Trade – contrato de patrocínio';
        LAT_ContractsWS.ContractVolume conVol = new LAT_ContractsWS.ContractVolume();
        conVol.boxesMinimum = 120;
        conVol.product = parentPG.Id;
        List<LAT_ContractsWS.ContractVolume> listConVol = new List<LAT_ContractsWS.ContractVolume>{conVol};
        con.contractVolume = listConVol;
        LAT_ContractsWS.Payments conPay = new LAT_ContractsWS.Payments();
        conPay.ProductGroup = paymentPG.Id;
        conPay.RecordType = 'Pagamento Produto';
        conPay.Volumen = 5;
        con.payments = new List<LAT_ContractsWS.Payments>{conPay};

        LAT_ContractsWS conWS = new LAT_ContractsWS();
        LAT_ContractsWS.sendPayToMe(paymentd.Id);
        LAT_ContractsWS.generatePaymentWS(c.Id);
        LAT_ContractsWS.emulateRoi(c.Id);
        LAT_ContractsWS.getContractInformation(con);
        //LAT_ContractsWS.calculateRoi(con);
        Test.stopTest();
        }catch(Exception e){}
    }

    @isTest static void test_method_three() {

        
        User u = getLAT_SystemAdminUser();
        setup(u);
        System.runAs(u) {
            Test.startTest();
            LAT_ROISegments__c rs = new LAT_ROISegments__c();
            rs.ROI__c = 10;
            rs.Segment__c = 'premium';
            insert rs;

            LAT_Contract2__c c = getContract();

            c.LAT_IsAdmin__c = true;
            c.Name = 'TEST';
            insert c;

            LAT_ContractVolume__c cv = getContractVolume(c.id);
            insert cv;
            if (paymentPG==null) {
                LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                            Name = 'Test Product Payment Prod Grouping',
                            Order__c = 100,
                            GroupType__c ='SKU',
                            Parent__c = parentPG.Id
                        );
                insert rpg;
                paymentPG = rpg;
            }
            inserCollectsNFLines(c.Account__c, paymentPG.Id);
            LAT_Payment__c paymentp = getPaymentProducto(c.id);
            insert paymentp;
            // LAT_Payment__c paymentd = getPaymentDinhero(c.id);
            // insert paymentd;
            LAT_ContractsCalculations.productCost cost = new LAT_ContractsCalculations.productCost();
            cost.productId = paymentPG.Id;
            cost.skuName = paymentPG.Name;
            cost.nis = 10.00;
            cost.ldCost = 10.00;
            cost.distCost = 10.00;
            cost.cmCase = 10.00;
            cost.unitOfMeasurement = 'CA';
            cost.hasSKU = false;

            //LAT_ContractsWS conWS = new LAT_ContractsWS();
            //LAT_ContractsWS.checkPaymentRelease(paymentd.Id);
            LAT_ContractsWS.checkPaymentRelease(paymentp.Id);
            LAT_ContractsWS.Contract con = new LAT_ContractsWS.Contract();
            
            LAT_Product__c p = lat_cota_test.LAT_getProduct();
            p.LAT_IsRefactorProduct__c = 'Y';
            p.LAT_IsActive__c = true;
            p.LAT_SKU__c = 'SKU';
            p.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
            insert p;

            LAT_ReferenceProduct__c rp = new LAT_ReferenceProduct__c();
            rp.LAT_Product__c =p.id;
            rp.IsActive__c=true;
            rp.Type__c='sku';
            rp.ReferenceGrouping__c = paymentPG.Id;
            rp.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_ReferenceProduct__c', 'LAT_ProductPayment' );
            insert rp;

            LAT_UnitConversionRates__c ucr = new LAT_UnitConversionRates__c(
                    Factor__c = 1.00,
                    LAT_KeyUnica__c = '1-SKU-CA-BT'
                );
            insert ucr;
            LAT_UnitConversionRates__c ucr2 = new LAT_UnitConversionRates__c(
                    Factor__c = 1.00,
                    LAT_KeyUnica__c = '1-SKU-BT-LT'
                );
            insert ucr2;

            LAT_ContractsWS.convertUnits(new List<LAT_ContractsCalculations.productCost>{cost},'LT');
            LAT_ContractsWS.cancelDAWS(c.Name);

            cost.unitOfMeasurement = 'LT';
            LAT_ContractsWS.convertUnits(new List<LAT_ContractsCalculations.productCost>{cost},'CA');

            Test.stopTest();
        }
    }

    @isTest static void test_method_four() {
        try{
        User u = getLAT_BR2Vendas();
        setup(u);
        Test.startTest();
        LAT_Contract2__c c = getContract();
        insert c;
        c.Status__c = 'Em Aprovação';
        update c;
        // c.Status__c = 'Aprovado';
        // update c;
        // c.Status__c = 'Ativo';
        // update c;


        //contCalc.totalProductsCalculation(mapa, 'SP');
        Task t = getNewTask(c.Id);
        insert t;
        update t;
        t.LAT_Tipo__c = 'CT-EntregarCliente';
        update t;

        Test.stopTest();
        } catch (Exception e){}
    }

    @isTest static void test_method_four2() {
        User u = getLAT_BR2Vendas();
        setup(u);
        Test.startTest();
        LAT_Contract2__c c = getContract();
        insert c;
        Task t = getNewTask(c.Id);

        LAT_ContractVolume__c cv = getContractVolume(c.id);
        insert cv;
        LAT_ReferenceProductGrouping__c paymentPG;
        if (paymentPG==null) {
            LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                        RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                        Name = 'Test Product Payment Prod Grouping',
                        Order__c = 100,
                        GroupType__c ='SKU',
                        Parent__c = parentPG.Id
                    );
            insert rpg;
            paymentPG = rpg;
        }

        inserCollectsNFLines(c.Account__c, paymentPG.Id);
        LAT_Payment__c paymentp = getPaymentProducto(c.id);
        insert paymentp;
        LAT_Payment__c paymentd = getPaymentDinhero(c.id);
        insert paymentd;

        /*
        LAT_Product__c p = lat_cota_test.LAT_getProduct();
        p.LAT_IsRefactorProduct__c = 'Y';
        p.LAT_IsActive__c = true;
        p.LAT_SKU__c = 'SKU';
        p.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
        insert p;

        LAT_ReferenceProduct__c rp = new LAT_ReferenceProduct__c();
        rp.LAT_Product__c =p.id;
        rp.IsActive__c=true;
        rp.Type__c='sku';
        rp.ReferenceGrouping__c = paymentPG.Id;
        rp.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_ReferenceProduct__c', 'LAT_ProductPayment' );
        insert rp;

        LAT_UnitConversionRates__c ucr = new LAT_UnitConversionRates__c(
                Factor__c = 1.00,
                LAT_KeyUnica__c = '1-SKU-CA-BT'
            );
        insert ucr;
        LAT_UnitConversionRates__c ucr2 = new LAT_UnitConversionRates__c(
                Factor__c = 1.00,
                LAT_KeyUnica__c = '1-SKU-BT-LT'
            );
        insert ucr2;
        LAT_ProductCost__c pc = getProductCost();
        insert pc;
        */


        system.debug(Limits.getQueries());
        LAT_ContractsCalculations contCalc = new LAT_ContractsCalculations();
        contCalc.calculatePaymentsInformation(new Set<Id>{c.Id});


        Test.stopTest();
    }


    // @isTest static void test_method_four() {
    //     LAT_Contract2__c c = getContract();
    //     insert c;
    //     c.Status__c = 'Em Aprovação';
    //     update c;
    //     c.Status__c = 'Aprovado';
    //     update c;
    //     c.Status__c = 'Ativo';
    //     update c;
    //     LAT_ContractVolume__c cv = getContractVolume(c.id);
    //     insert cv;
    //     if (paymentPG==null) {
    //         LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
    //                     RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
    //                     Name = 'Test Product Payment Prod Grouping',
    //                     Order__c = 100,
    //                     GroupType__c ='SKU',
    //                     Parent__c = parentPG.Id
    //                 );
    //         insert rpg;
    //         paymentPG = rpg;
    //     }
    //
    //
    //
    //     inserCollectsNFLines(c.Account__c, paymentPG.Id);
    //     LAT_Payment__c paymentp = getPaymentProducto(c.id);
    //     insert paymentp;
    //     LAT_Payment__c paymentd = getPaymentDinhero(c.id);
    //     insert paymentd;
    //     LAT_ContractsCalculations.productCost cost = new LAT_ContractsCalculations.productCost();
    //     cost.productId = paymentPG.Id;
    //     cost.skuName = paymentPG.Name;
    //     cost.nis = 10.00;
    //     cost.ldCost = 10.00;
    //     cost.distCost = 10.00;
    //     cost.cmCase = 10.00;
    //     cost.unitOfMeasurement = 'CA';
    //     cost.hasSKU = false;
    //
    //
    //     LAT_Product__c p = lat_cota_test.LAT_getProduct();
    //     p.LAT_IsRefactorProduct__c = 'Y';
    //     p.LAT_IsActive__c = true;
    //     p.LAT_SKU__c = 'SKU';
    //     p.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
    //     insert p;
    //
    //     LAT_ReferenceProduct__c rp = new LAT_ReferenceProduct__c();
    //     rp.LAT_Product__c =p.id;
    //     rp.IsActive__c=true;
    //     rp.Type__c='sku';
    //     rp.ReferenceGrouping__c = paymentPG.Id;
    //     rp.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_ReferenceProduct__c', 'LAT_ProductPayment' );
    //     insert rp;
    //
    //     LAT_UnitConversionRates__c ucr = new LAT_UnitConversionRates__c(
    //             Factor__c = 1.00,
    //             LAT_KeyUnica__c = '1-SKU-CA-BT'
    //         );
    //     insert ucr;
    //     LAT_UnitConversionRates__c ucr2 = new LAT_UnitConversionRates__c(
    //             Factor__c = 1.00,
    //             LAT_KeyUnica__c = '1-SKU-BT-LT'
    //         );
    //     insert ucr2;
    //     LAT_ProductCost__c pc = getProductCost();
    //     insert pc;
    //
    //     cost.productId = pc.Product__c;
    //     LAT_ContractsCalculations contCalc = new LAT_ContractsCalculations();
    //     contCalc.calculatePaymentsInformation(new Set<Id>{c.Id});
    //     contCalc.calculateROI(Double.valueOf('100'),Double.valueOf('120'));
    //
    //     String[] canales = new String[2];
    //     canales[0] = '101';
    //     canales[1] = '103';
    //     contCalc.getProductAverages(new List<LAT_ContractsCalculations.productCost>{cost},'SP',canales,'LAT_ProductPayment');
    //     Map<Id,Double> mapa = new Map<Id,Double>();
    //     mapa.put(pc.Id, 100.00);
    //
    //     //contCalc.totalProductsCalculation(mapa, 'SP');
    //  Test.startTest();
    //     Task t = getNewTask(c.Id);
    //     insert t;
    //     update t;
    //     t.LAT_Tipo__c = 'CT-EntregarCliente';
    //     update t;
    //
    //
    //
    //     Test.stopTest();
    // }

    public static LAT_ProductCost__c getProductCost2() {
        UDC__c UdcTest = new UDC__c();
          UdcTest.CodUs__c = '03';
          UdcTest.CodProd__c = '101';
          UdcTest.CodDefUsuario__c = '101';
          UdcTest.Internal_Id__c = 'test';
          insert UdcTest;
        insert new LAT_GeneralConfig__c (Name= 'LAT_PROFILE_UPDATE_PRODUCTCOST', LAT_Value__c = 'LAT_BR2_TradeMarketing');
        insert new LAT_GeneralConfig__c (Name= 'Admin', LAT_Value__c = 'LAT_SystemAdministrator');
        LAT_ReferenceProductGrouping__c parentRpg = getParentRefProdGrouping();
        if (productCostPG==null) {
            LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                        RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')    ,
                        Name = 'Test Product Payment Prod Grouping',
                        Order__c = 100,
                        GroupType__c ='SKU',
                        Parent__c = parentRpg.Id
                    );
            insert rpg;
            productCostPG = rpg;
        }
        String month = String.valueOf(Date.today().month());
        if (month.length()==1) {
            month = '0'+month;
        }
        Account a = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        a.Rating_segmentation_targert_market__c = 'premium';
        a.Client_code_AN8__c = '12344';
        a.Revenue_UF__c = 'SP';
        insert a;
        LAT_ProductCost__c pc = new LAT_ProductCost__c (
                Product__c = productCostPG.Id,
                Canal__c = UdcTest.Id,
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ProductCost__c'+'LAT_ProductPayment')    ,
                CM_Case__c = 100,
                LDCost__c = 100,
                Start_Year__c = String.valueOf(Date.today().year()),
                Start_Month__c = month,
                DistributorCost__c = 100,
                EndDate__c = Date.today().addDays(180),
                StartDate__c = Date.today().addDays(-180),
                UF__c = 'SP',
                Net_Sales_Case__c = 10.00,
                AN8__c = a.Id

            );
        return pc;
    }

    @isTest static void test_method_five() {
        User u = getLAT_SystemAdminUser();
        System.runAs(u) {
            Test.startTest();
            LAT_ProductCost__c pc = getProductCost2();
            insert pc;
            try{ update pc;} catch(Exception e){}

            Test.stopTest();
        }
    }

    @isTest static void test_method_six() {
        System.debug('ESTAMOS!! 1');
        User u = getLAT_BR2Vendas();
        setup(u);
        System.debug('ESTAMOS!! 2');
        
        System.runAs(u) {
        System.debug('ESTAMOS!! 3');

            Test.startTest();
            LAT_Contract2__c c = getContract();
            c.EndDate__c =  Date.today().addDays(90);
            c.Status__c = 'Ativo';

            insert c;
        System.debug('ESTAMOS!! 4');

            LAT_ContractVolume__c cv = getContractVolume(c.id);
            insert cv;
        System.debug('ESTAMOS!! 5');

            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', JSON.serialize(LAT_ContractPaymentsHandlerInt_Test.getMockCashPayment()), mapa));
            if (paymentPG==null) {
                LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                            Name = 'Test Product Payment Prod Grouping',
                            Order__c = 100,
                            GroupType__c ='SKU',
                            Parent__c = parentPG.Id
                        );
                insert rpg;

                paymentPG = rpg;
            }
            inserCollectsNFLines(c.Account__c, paymentPG.Id);
            LAT_Payment__c paymentp = getPaymentDinhero(c.id);
            paymentp.IDMe__c = '12';
            insert paymentp;
            System.debug('ESTAMOS!! 6');

            LAT_ContractsCalculations.productCost cost = new LAT_ContractsCalculations.productCost();
            cost.productId = paymentPG.Id;
            cost.skuName = paymentPG.Name;
            cost.nis = 10.00;
            cost.ldCost = 10.00;
            cost.distCost = 10.00;
            cost.cmCase = 10.00;
            cost.unitOfMeasurement = 'LT';
            cost.hasSKU = false;

            LAT_ContractDA__c conDA = new LAT_ContractDA__c(
                Contract__c = c.Id,
                DANumber__c = 12345,
                Fiscal_Year__c = 'FY17',
                Type__c = 'TE',
                Status__c = 'Ativo'
                );
            insert conDA;
        System.debug('ESTAMOS!! 7');

            //LAT_ContractsWS conWS = new LAT_ContractsWS();
            //LAT_ContractsWS.checkPaymentRelease(paymentd.Id);
            LAT_ContractsWS.checkPaymentRelease(paymentp.Id);
            // Any Id
            LAT_ContractsWS.checkPaymentRelease(conDA.Id);
            LAT_ContractsWS.convertUnits(new List<LAT_ContractsCalculations.productCost>{cost},'CA');
            cost.unitOfMeasurement = 'CA';
            System.debug('ESTAMOS!! 8');

            LAT_ContractsWS.convertUnits(new List<LAT_ContractsCalculations.productCost>{cost},'LT');
            LAT_ContractsWS.paymentToAprove toAprove = new LAT_ContractsWS.paymentToAprove();
            toAprove.paymentID = String.valueOf(paymentp.Id);
            LAT_ContractsWS.groupPayments(new List<LAT_ContractsWS.paymentToAprove>{toAprove});
            
            try {
                LAT_ContractsWS.runApprovalProcess(new List<String>{String.valueOf(paymentp.Id)}); 
            } catch(Exception Ex) {}

            LAT_CheckPaymentStatusOnME_Batch b = new LAT_CheckPaymentStatusOnME_Batch();
            try{Database.executeBatch(b);}catch(Exception e){}
            LAT_CheckPaymentStatusOnME_Scheduler sch1 = new LAT_CheckPaymentStatusOnME_Scheduler();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sch1);

            LAT_Contract_Batch lcb = new LAT_Contract_Batch();
            try{ Database.executeBatch(lcb);}catch(Exception e) {}

            c.EndDate__c =  Date.today().addDays(30);

            //update c;

            try{Database.executeBatch(lcb);}catch(Exception e) {}

            Test.stopTest();
        }
    }
    
    @isTest static void test_method_seven() {
        User u = getLAT_BR2Vendas();
        setup(u);
        System.runAs(u) {
            Test.startTest();
            LAT_ReferenceProductGrouping__c parentPG = getParentRefProdGrouping();
            if (paymentPG==null) {
                LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                            Name = 'Test Product Payment Prod Grouping',
                            Order__c = 100,
                            GroupType__c ='SKU',
                            Parent__c = parentPG.Id
                        );
                insert rpg;
                paymentPG = rpg;
            }
            LAT_Contract2__c c = getContract();
            c.EndDate__c =  Date.today().addDays(30);
            c.Status__c = 'Ativo';
            c.Name = 'TestCancel';
            insert c;
            
            LAT_ContractsWS.Contract con = new LAT_ContractsWS.Contract();
            LAT_ContractVolume__c cv = getContractVolume(c.id);
            insert cv;
            LAT_ContractsWS.ContractVolume conVol = new LAT_ContractsWS.ContractVolume();
            conVol.boxesMinimum = 120;
            conVol.product = parentPG.Id;
            List<LAT_ContractsWS.ContractVolume> listConVol = new List<LAT_ContractsWS.ContractVolume>{conVol};
            con.contractVolume = listConVol;
            LAT_ContractsWS.Payments conPay = new LAT_ContractsWS.Payments();
            conPay.ProductGroup = paymentPG.Id;
            conPay.RecordType = 'Pagamento Produto';
            conPay.Volumen = 5;
            con.payments = new List<LAT_ContractsWS.Payments>{conPay};
                
            LAT_ROISegments__c rs = new LAT_ROISegments__c();
            rs.ROI__c = 10;
            rs.Segment__c = 'premium';
            insert rs;

            LAT_ContractsWS conWS = new LAT_ContractsWS();
            //LAT_ContractsWS.cancelDAWS();
            con.roiSegment = 'premium';
            con.ContractTerms = 6;
            LAT_ContractsWS.getContractInformation(con);
            Test.stopTest();
        }
    }

    @isTest 
    static void test_method_eight() {
        User u = getLAT_BR2Vendas();
        System.debug('%%% email : ' + u.Email);
        setup(u);
        try{
        System.runAs(u) {
           
            Test.startTest();
            LAT_Contract2__c c = getContract();
            c.EndDate__c =  Date.today().addDays(130);
            c.Status__c = 'Ativo';
            insert c;

            LAT_ContractVolume__c cv = getContractVolume(c.id);
            insert cv;

            
            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', JSON.serialize(LAT_ContractPaymentsHandlerInt_Test.getMockCashPayment()), mapa));
            if (paymentPG==null) {
                LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                            Name = 'Test Product Payment Prod Grouping',
                            Order__c = 100,
                            GroupType__c ='SKU',
                            Parent__c = parentPG.Id
                        );
                insert rpg;
                paymentPG = rpg;
            }
            inserCollectsNFLines(c.Account__c, paymentPG.Id);
            LAT_Payment__c paymentp = getPaymentProductoWithParent(c.id);
            paymentp.IDMe__c = '12';
            insert paymentp;
            // LAT_Payment__c paymentd = getPaymentDinheroWithParent(c.id);
            // paymentd.IDMe__c = '14';
            

            LAT_ContractDA__c conDA = new LAT_ContractDA__c(
                Contract__c = c.Id,
                DANumber__c = 12345,
                Fiscal_Year__c = 'FY17',
                Type__c = 'TE',
                Status__c = 'Ativo'
                );
            insert conDA;
            System.debug('%%%%% 1');
            //LAT_ContractsWS conWS = new LAT_ContractsWS();
            //LAT_ContractsWS.checkPaymentRelease(paymentd.Id);
            
            LAT_Contract2__c con = [SELECT Name, owner.Email, Account__r.Name, (Select Ammount__c,Finality__c,Id,LAT_Contract__c,Name, PaymentDateDone__c,PaymentDate__c,ProductGroup__c,RecordTypeId,Status__c,Type__c, ParentPayment__c FROM LAT_Payments__r), EndDate__c,OwnerId,Status__c, ProcessStatus__c FROM LAT_Contract2__c LIMIT 1] ;
            LAT_Contract_Batch.processExpireNextMonthContract(con);
            LAT_Contract_Batch.processProrrogatedContract(con);


            Test.stopTest();
            
            System.debug('%%%%% 7');
        }
        }catch(Exception e){}
        System.debug('%%%%% 8');
    }

    @isTest 
    static void test_method_nine() {
        User u = getLAT_BR2Vendas();
        System.debug('%%% email : ' + u.Email);
        setup(u);
        try{
        System.runAs(u) {
           
            Test.startTest();
            LAT_Contract2__c c = getContract();
            c.EndDate__c =  Date.today().addDays(130);
            c.Status__c = 'Ativo';
            insert c;

            LAT_ContractVolume__c cv = getContractVolume(c.id);
            insert cv;

            
            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', JSON.serialize(LAT_ContractPaymentsHandlerInt_Test.getMockCashPayment()), mapa));
            if (paymentPG==null) {
                LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c (
                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                            Name = 'Test Product Payment Prod Grouping',
                            Order__c = 100,
                            GroupType__c ='SKU',
                            Parent__c = parentPG.Id
                        );
                insert rpg;
                paymentPG = rpg;
            }
            inserCollectsNFLines(c.Account__c, paymentPG.Id);
            LAT_Payment__c paymentp = getPaymentProducto(c.id);
            paymentp.IDMe__c = '12';
            paymentp.Status__c = 'E';
            insert paymentp;
            // LAT_Payment__c paymentd = getPaymentDinheroWithParent(c.id);
            // paymentd.IDMe__c = '14';
            

            LAT_ContractDA__c conDA = new LAT_ContractDA__c(
                Contract__c = c.Id,
                DANumber__c = 12345,
                Fiscal_Year__c = 'FY17',
                Type__c = 'TE',
                Status__c = 'Ativo'
                );
            insert conDA;
            System.debug('%%%%% 1');
            //LAT_ContractsWS conWS = new LAT_ContractsWS();
            //LAT_ContractsWS.checkPaymentRelease(paymentd.Id);
            
            LAT_Contract2__c con = [SELECT Name, owner.Email, Account__r.Name, (Select Ammount__c,Finality__c,Id,LAT_Contract__c,Name, PaymentDateDone__c,PaymentDate__c,ProductGroup__c,RecordTypeId,Status__c,Type__c, ParentPayment__c FROM LAT_Payments__r), EndDate__c,OwnerId,Status__c, ProcessStatus__c FROM LAT_Contract2__c LIMIT 1] ;
            LAT_Contract_Batch.processProrrogatedContract(con);


            Test.stopTest();
            
            System.debug('%%%%% 7');
        }
        }catch(Exception e){}
        System.debug('%%%%% 8');
    }
    public static void createCreds(){
        CS001_JDEInterfaceCredentials__c cred = new CS001_JDEInterfaceCredentials__c(
        Name = 'Brasil',
        Country__c = '1',
        EndPoint_BalanceCheck__c = 'http://crm.test.pernod-ricard.com.br/PernodRicard/BalanceCheck/BalanceCheckProxy',
        EndPoint_ContractManager__c = 'http://crm.test.pernod-ricard.com.br/SalesForce/ContractManager/ContractManagerProxy',
        EndPoint_CustomerHandler__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Customer/CustomerHandlerReq',
        EndPoint_CustomerVerify__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Customer/CustomerVerifyReq',
        EndPoint_PaymentManager__c = 'http://crm.test.pernod-ricard.com.br/PernodRicard/PaymentManager/PaymentManagerProxy',
        EndPoint_PriceCalculation__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Price/PriceCalculationReq',
        EndPoint_RVManager__c = 'http://crm.test.pernod-ricard.com.br/SalesForce/RVManager/RVManagerProxy',
        EndPoint_SalesOrderHandler__c = 'http://crm.test.pernod-ricard.com.br/SFDC/SalesOrder/AsyncSalesOrderHandlerReq',
        EndPoint_ReceiptHandeler__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Collection/CollectionManagerSFDCReq',
        EndPoint_GetStock__c = 'http://crm.test.pernod-ricard.com.br/SFDC/test',
        RemoteHostIP__c = '200.200.10.10',
        System__c = 'X',
        SystemUserID__c = 'cloud2b'
    );
    insert cred;
    }

    public static void addIMMData(){
    LAT_IMM_Operations__c op = new LAT_IMM_Operations__c(EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', operation_Name_header__c ='GetFreeGood', Service_Name_Header__c='IMM', Name = 'GetFreeGood', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
    LAT_IMM_Operations__c op2 = new LAT_IMM_Operations__c(userLDAP__c = 'BSOUZA01', idAlmacen__c = '40',Name = 'CreateCashPayment',operation_Name_header__c = 'CreateCashPayment', EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', Service_Name_Header__c='IMM', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
    LAT_IMM_Operations__c op3 = new LAT_IMM_Operations__c(userLDAP__c = 'BSOUZA01', idAlmacen__c = '40',Name = 'GetCashPayment',operation_Name_header__c = 'GetCashPayment', EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', Service_Name_Header__c='IMM', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
    LAT_IMM_Operations__c op4 = new LAT_IMM_Operations__c(userLDAP__c = 'BSOUZA01', idAlmacen__c = '40',Name = 'CreateAndSendFreeGood',operation_Name_header__c = 'CreateAndSendFreeGood', EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', Service_Name_Header__c='IMM', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
    insert new List<LAT_IMM_Operations__c> {op,op2,op3,op4};


    }

    public static User getLAT_BR2Vendas() {
        
        User usuarioVendas = [SELECT Id, Email FROM User WHERE Profile.Name = 'LAT_BR2_Vendas' AND IsActive = true and Email <> null 
                                AND Id NOT IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = 'LAT_BR_Vendas_Restringido') AND Managerid <> null AND Gerente_regional__c <>null  LIMIT 1];
        return usuarioVendas;
    }

    public static User getLAT_SystemAdminUser() {
        
        return [SELECT Id, Email FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND IsActive = true and Email <> null LIMIT 1];
    }
    /*public static User getLAT_BR2Vendas() {
        User man = getLAT_SystemAdminUser();
        Profile p = [SELECT Id FROM Profile WHERE Name='LAT_BR2_Vendas'];
        User u2 = new User(Alias = 'newUser2', Email='newuser2@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',  ProfileId = p.Id, managerid = man.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR2@mail.com', BypassTriggers__c='Autofollow_User_InsertUpdate');
        insert u2;
        return u2;
    }
    public static User getLAT_SystemAdminUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='LAT_SystemAdministrator'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',  ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR@mail.com', BypassTriggers__c='Autofollow_User_InsertUpdate');
        insert u2;
        return u2;
    }*/

}