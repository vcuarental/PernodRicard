/********************************************************************************
*  Company:Valuenet     Developer:Elena Schwarzböck      Date:09/04/2013        *
********************************************************************************/

@istest
public with sharing class AP01_Receipt_AR_TEST{

    @testSetup static void setup() {
        createAccountAR();        
        createReceiptConfigs();
    }

    @isTest
    static void unitTest1(){
                    
        Account acc = [SELECT Id FROM Account LIMIT 1];
        system.Test.startTest();
        
        RCP_Receipt_ARG__c receipt =getBaseReceipt(acc, 'RCP_ReceiptGeneratedDepositDone_AR', 'C', null);
        insert receipt;
        
        DCM_Documents_ARG__c doc = getBaseDocument(receipt);
        insert doc;
        
        Titulos__c titulo = new Titulos__c(
            NetSRReceipts_AR__c = 200,
            Internal_id_pk__c = 'TEST',
            Cliente__c = acc.id,
            codigoCia__c = 'TEST',
            dataEmissao__c = date.today(),
            dataVencimentoAtual__c = date.today(),
            dataVencimentoOriginal__c = date.today(),
            numeroDocumento__c = 1,
            parcela__c = 'T',
            valorOriginalTitulo__c = 10,
            Ruinusebypendingreceipt_AR__c = receipt.id,
            valorSaldo__c = 10,
            RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'Standard_AR')
        );
        insert titulo;
        
        delete receipt;
        
        system.Test.stopTest();
        
    }

    @isTest
    static  void unitTest2(){
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        system.Test.startTest();
        
        RCP_Receipt_ARG__c rece = getBaseReceipt(acc, 'RCP_ReceiptGeneratedDepositDone_AR', 'C', null);
        rece.Discount_AR__c = 10;
        rece.Comercial_Discount__c = 20;
        insert rece;

        DPT_Deposit_ARG__c dep = getBaseDeposit(rece, '2');
        insert dep;
        
        rece.LAT_AR_DepositAccountType__c = 'R';
        try{update rece;}catch(Exception e){}
        
        rece.LAT_AR_DepositAccountType__c = 'c';
        update rece;
        AP01_Receipt_AR.ValidarRecibosRendidos();
        try{AP01_Receipt_AR.manuallyAdjustReceipt(rece.Id);}catch(Exception e){}

        system.Test.stopTest();
        
    }

    @isTest
    static  void unitTest3(){
                
        Account acc = [SELECT Id FROM Account LIMIT 1];
        system.Test.startTest();
        
        RCP_Receipt_ARG__c rece = getBaseReceipt(acc, 'RCP_ReceiptGeneratedDepositDone_AR', 'C', 'Receipt Deposited');
        insert rece;
        
        DPT_Deposit_ARG__c dep = getBaseDeposit(rece, '2');
        insert dep;

        VLS_Values_ARG__c val = getValueWithDeposit(rece, '333458', dep);
        insert val;
        
        TXC_TaxCertificates_ARG__c tax = getBaseTaxCert(rece);
        insert tax;

        
        
        rece.Status_AR__c = 'Receipt Verified';
        update rece;
        
        system.Test.stopTest();
        
    }

    @isTest
    static void unitTest4() {
        User vendedor = [SELECT Id FROM User WHERE IsActive = True AND Profile.Name = 'LAT_AR2_Vendedor' LIMIT 1];
        User admin = [SELECT Id FROM User WHERE IsActive = True AND Profile.Name = 'LAT_SystemAdministrator' LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        RCP_Receipt_ARG__c rece = getBaseReceipt(acc, 'RCP_ReceiptGeneratedDepositDone_AR', 'C', 'Receipt Deposited');
        insert rece;

        DPT_Deposit_ARG__c dep = getBaseDeposit(rece, '2');
        insert dep;

        update dep;
        try{delete dep;}catch(Exception e) {}

        System.runAs(admin) {
            LAT_Receipt_Range__c range = AP01_Receipt_AR.createRange('APP', vendedor.Id);
            insert range;
            range.nextNumber__c = range.limitNumber__c - 5;

            update range;
            LAT_Receipt_Range__c range2 = AP01_Receipt_AR.createRange('APP', admin.Id);
            insert range2;
            
        
            

            List<LAT_Receipt_Range__c> rangos = new List<LAT_Receipt_Range__c>{range};
            AP01_Receipt_AR.getRedemptionNoString(5);
            AP01_Receipt_AR.validateMobileRange(rangos);
            AP01_Receipt_AR.validateCreation(new List<RCP_Receipt_ARG__c>{rece});
            AP01_Receipt_AR.updateMobileReceipt(rece);
            AP01_Receipt_AR.UpdateReceiptType (new List<RCP_Receipt_ARG__c>(), new Map<Id, RCP_Receipt_ARG__c>());

        }

        rece.Status_AR__c = 'Sent to Redeem Mobile';
        try{update rece;}catch(Exception e){}
        Test.stopTest();
    }


    @isTest
    static  void unitTest5(){
        
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        system.Test.startTest();
        
        RCP_Receipt_ARG__c rece =  getBaseReceipt(acc, 'RCP_ReceiptGeneratedDepositDone_AR', 'R', null);
        insert rece;

        DPT_Deposit_ARG__c dep = getBaseDeposit(rece, '2');
        insert dep;
        
        rece.Status_AR__c = 'Receipt cancelled';
        update rece;

        rece.Status_AR__c = 'Receipt printed Deposit done';
        update rece;
        AP01_Receipt_AR.ValidarRecibosRendidos();
        system.Test.stopTest();
        
    }

    @isTest
    static  void unitTest6(){
                
        Account acc = [SELECT Id FROM Account LIMIT 1];
        system.Test.startTest();
        
        RCP_Receipt_ARG__c rece = getBaseReceipt(acc, 'RCP_ReceiptGeneratedDepositDone_AR', 'C', 'Receipt Deposited');
        insert rece;
        
        DPT_Deposit_ARG__c dep = getBaseDeposit(rece, '2');       
        insert dep;
        
        VLS_Values_ARG__c val = getValueWithDeposit(rece, '333458', dep);
        insert val;
        
        TXC_TaxCertificates_ARG__c tax = getBaseTaxCert(rece);
        insert tax;
        
        rece.Status_AR__c = 'Receipt sent cancel mobile';
        update rece;

        system.Test.stopTest();
        
    }

    @isTest
    static  void unitTest7(){
                
        Account acc = [SELECT Id FROM Account LIMIT 1];
        system.Test.startTest();
        
        RCP_Receipt_ARG__c rece = getBaseReceipt(acc, 'RCP_ReceiptGeneratedDepositDone_AR', 'C', 'Receipt Deposited');
        insert rece;
        
        DPT_Deposit_ARG__c dep = getBaseDeposit(rece, '2');
        dep.From_Document__c = true;       
        insert dep;
        LAT_Deposit.deleteDeposit(new List<DPT_Deposit_ARG__c>{dep});
        delete dep;

        system.Test.stopTest();
        
    }

    @isTest
    static  void unitTest8(){
                
        Account acc = [SELECT Id FROM Account LIMIT 1];
        system.Test.startTest();
        
        RCP_Receipt_ARG__c rece = getBaseReceipt(acc, 'RCP_ReceiptGeneratedDepositDone_AR', 'C', 'Receipt Deposited');
        insert rece;
               
        TXC_TaxCertificates_ARG__c tax = getBaseTaxCert(rece);
        insert tax;
        Map<Id, TXC_TaxCertificates_ARG__c> mapa = new Map<Id, TXC_TaxCertificates_ARG__c>();
        mapa.put(tax.Id, tax);


        LAT_AR_TaxCertificates.TaxCertificatesCheckPrintStatus(mapa);

        system.Test.stopTest();
        
    }

    @isTest
    static  void unitTest9(){
        User admin = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND IsActive=true LIMIT 1];
        system.runAs(admin){ 
            Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'),
            CNPJ__c = '30500008454',
            Name = 'testAccount',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test'
        );
            system.Test.startTest();
        insert acc;
            
            RCP_Receipt_ARG__c rece = getBaseReceipt(acc, 'RCP_ReceiptGeneratedDepositPending_AR', 'C', null);
            rece.Discount_AR__c = 10;
            rece.Comercial_Discount__c = 20;
            insert rece;

            TXC_TaxCertificates_ARG__c tax = getBaseTaxCert(rece);
            insert tax;
            
            update tax;
            delete tax;
            system.Test.stopTest();
        }
    }

    @isTest
    static  void unitTest10(){
                
        Account acc = [SELECT Id FROM Account LIMIT 1];
        system.Test.startTest();
        
        RCP_Receipt_ARG__c rece = getBaseReceipt(acc, 'RCP_ReceiptGeneratedDepositDone_AR', 'C', 'Receipt Deposited');
        insert rece;
        
        rece.Comercial_Discount__c = 10;
        rece.Discount_AR__c         = 10;
        rece.Downpayments_AR__c     = 10;
        update rece;

        List<LAT_Invoice__c> toUpdate = [SELECT Id, LAT_ID_JDE_Invoice__c, LAT_InvoiceType__c FROM LAT_Invoice__c];
        Integer i = 0;
        for (LAT_Invoice__c inv : toUpdate) {
            i++;
            inv.LAT_ID_JDE_Invoice__c = 'ABC'+ i + 'TEST';
            update inv;
        }
       

        DPT_Deposit_ARG__c dep = getBaseDeposit(rece, '2');       
        insert dep;
        
        VLS_Values_ARG__c val = getValueWithDeposit(rece, '333458', dep);
        insert val;

        rece.Status_AR__c = 'Receipt sent cancel mobile';
        update rece;

        system.Test.stopTest();
        
    }

    public static RCP_Receipt_ARG__c getBaseReceipt(Account acc, String recordTypeDevName,String depositAccountType, String status) {
        RCP_Receipt_ARG__c rece = new RCP_Receipt_ARG__c(
            Account_AR__c = acc.id,
            Status_AR__c = status,
            LAT_AR_DepositAccountType__c = depositAccountType,
            RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + recordTypeDevName)
        );
        
        return rece;
    }

    public static VLS_Values_ARG__c getValueWithDeposit(RCP_Receipt_ARG__c rec, String name, DPT_Deposit_ARG__c dep) {
        VLS_Values_ARG__c val = new VLS_Values_ARG__c(
            ReceiptNo_AR__c = rec.id,
            Bank_AR__c = '123',
            BranBranch_AR__c = '123',
            Name = name,
            Deposit_AR__c = dep.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('VLS_Values_ARG__c' + 'VLS_tandard_AR')
        );
        return val;
    }

    public static VLS_Values_ARG__c getBaseValue(RCP_Receipt_ARG__c rec, String name) {
        VLS_Values_ARG__c val = new VLS_Values_ARG__c(
            ReceiptNo_AR__c = rec.id,
            Bank_AR__c = '123',
            BranBranch_AR__c = '123',
            Name = name,
            RecordTypeId = Global_RecordTypeCache.getRtId('VLS_Values_ARG__c' + 'VLS_tandard_AR')
        );
        return val;
    }

    public static DPT_Deposit_ARG__c getBaseDeposit(RCP_Receipt_ARG__c rec, String name) {
        DPT_Deposit_ARG__c dep = new DPT_Deposit_ARG__c(
            ReceiptNo_AR__c = rec.id,
            Amount_AR__c = 123,
            AccType_AR__c = 'Bank Account',
            Name = name,
            Date_AR__c = Date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('DPT_Deposit_ARG__c' + 'DPT_Standard_AR')
        );
        
        return dep;
    }

    public static TXC_TaxCertificates_ARG__c getBaseTaxCert(RCP_Receipt_ARG__c rec) {
        TXC_TaxCertificates_ARG__c tax = new TXC_TaxCertificates_ARG__c(
            ReceiptNo_AR__c = rec.id,
            name = 'TEST',
            RecordTypeId = Global_RecordTypeCache.getRtId('TXC_TaxCertificates_ARG__c' + 'TXC_Standard_AR')
        );
        return tax;
    }
        
    public static DCM_Documents_ARG__c getBaseDocument(RCP_Receipt_ARG__c rec) {
        DCM_Documents_ARG__c doc = new DCM_Documents_ARG__c(
            Amounttoapply_AR__c = 200,
            Internal_id_pk_AR__c = 'TEST',
            ReceiptNo_AR__c = rec.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        return doc;
    }

    public static void createAccountAR() {
        Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'),
            CNPJ__c = '20354266645',
            Name = 'testAccount',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test'
        );
        insert acc;
    }

    public static void createReceiptConfigs() {
        LAT_GeneralConfig__c cs = new LAT_GeneralConfig__c(
                      Name = 'RECEIPT_NRO_APP',
                    LAT_Value__c = '1000');
        insert cs;
        LAT_GeneralConfig__c cs2 = new LAT_GeneralConfig__c(
            Name = 'ALLOW_CREATE_RECEIPT',
            LAT_Value__c = 'true');
        insert cs2;
        LAT_GeneralConfig__c cs3 = new LAT_GeneralConfig__c(
            Name = 'AR_PROFILE_UPDATE_DEPOSITS',
            LAT_Value__c = 'LAT_SystemAdministrator');
        insert cs3;
        LAT_GeneralConfig__c cs4 = new LAT_GeneralConfig__c(
            Name = 'AR_MANUAL_INTEGRATE_RECEIPTS',
            LAT_Value__c = UserInfo.getName());
        insert cs4;
        
    }
}