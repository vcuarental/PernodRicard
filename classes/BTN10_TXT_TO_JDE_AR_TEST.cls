/****************************************************
*Dev: Denis Aranda  Version: 1  Consulting: Valuenet*
****************************************************/

@IsTest
public with sharing class BTN10_TXT_TO_JDE_AR_TEST {
    
    static testMethod void UnitTest(){
    
        system.Test.startTest();
        system.runAs(createTesoreriaUser()){

            Account acco = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
            acco.Name='TEST';
            acco.Corporate_Name__c = 'Target Corp';
            insert acco;
            list<id> idsRegister = new list<id>();
            
            RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Name = '1', Account_AR__c = acco.Id, Status_AR__c = 'Receipt Verified', Downpayments_AR__c = 123.1, Discount_AR__c = 321.0 );
            insert recibo;
            idsRegister.add(recibo.id);
            RCP_Receipt_ARG__c recibo1 = new RCP_Receipt_ARG__c(Name = '2', Account_AR__c = acco.Id, Status_AR__c = 'Receipt Verified');
            insert recibo1;
            idsRegister.add(recibo1.id);
            
            system.Test.stopTest();
            
            DCM_Documents_ARG__c doc = new DCM_Documents_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567');
            insert doc;
            
            VLS_Values_ARG__c val = new VLS_Values_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567', 
                                            IssueDate_AR_c__c = date.today(), Bank_AR__c = 'ABC', BranBranch_AR__c = 'ABC');
            insert val;
            
            TXC_TaxCertificates_ARG__c tax = new TXC_TaxCertificates_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567');
            insert tax;
            
            DPT_Deposit_ARG__c dep = new DPT_Deposit_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567');
            insert dep;
        
        
            BTN10_TXT_TO_JDE_AR.txtToJdeButton(idsRegister);
        }
    }
    static testMethod void UnitTest1(){
    
        system.Test.startTest();
        
        system.runAs(createTesoreriaUser()){

            Account acco = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
            acco.Name='TEST';
            acco.Corporate_Name__c = 'Target Corp';
            insert acco;
            list<id> idsRegister = new list<id>();
            
            RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Name = '1',Account_AR__c = acco.Id, Status_AR__c = 'Receipt Verified', Downpayments_AR__c = 123.1, Discount_AR__c = 321.0 );
            insert recibo;
            RCP_Receipt_ARG__c recibo1 = new RCP_Receipt_ARG__c(Name = '2',Account_AR__c = acco.Id, Status_AR__c = 'Receipt Verified');
            insert recibo1;
            
            DCM_Documents_ARG__c doc = new DCM_Documents_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567');
            insert doc;
            
            system.Test.stopTest();
            
            VLS_Values_ARG__c val = new VLS_Values_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567', 
                                                            IssueDate_AR_c__c = date.today(), Bank_AR__c = 'ABC', BranBranch_AR__c = 'ABC');
            insert val;
            
            TXC_TaxCertificates_ARG__c tax = new TXC_TaxCertificates_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567');
            insert tax;
            
            DPT_Deposit_ARG__c dep = new DPT_Deposit_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567');
            insert dep;
            
        
            BTN10_TXT_TO_JDE_AR.txtToJdeButton(idsRegister);
        }
    }
    static testMethod void UnitTest2(){
    
        system.Test.startTest();
        
       system.runAs(createTesoreriaUser()){

            Account acco = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
            acco.Name='TEST';
            acco.Corporate_Name__c = 'Target Corp';
            insert acco;
            list<id> idsRegister = new list<id>();
            
            RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Name = '1',Account_AR__c = acco.Id, Status_AR__c = '123', Downpayments_AR__c = 123.1, Discount_AR__c = 321.0 );
            insert recibo;
            idsRegister.add(recibo.id);
            RCP_Receipt_ARG__c recibo1 = new RCP_Receipt_ARG__c(Name = '2',Account_AR__c = acco.Id, Status_AR__c = '123');
            insert recibo1;
            idsRegister.add(recibo1.id);
            
            DCM_Documents_ARG__c doc = new DCM_Documents_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567');
            insert doc;
            
            system.Test.stopTest();
            
            VLS_Values_ARG__c val = new VLS_Values_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567', 
                                                            IssueDate_AR_c__c = date.today(), Bank_AR__c = 'ABC', BranBranch_AR__c = 'ABC');
            insert val;
            
            TXC_TaxCertificates_ARG__c tax = new TXC_TaxCertificates_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567');
            insert tax;
            
            DPT_Deposit_ARG__c dep = new DPT_Deposit_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567');
            insert dep;
        
        
            BTN10_TXT_TO_JDE_AR.txtToJdeButton(idsRegister);
        }
    }
    static testMethod void UnitTest3(){
    
        system.Test.startTest();
        
        system.runAs(createTesoreriaUser()){

            Account acco = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
            acco.Name='TEST';
            acco.Corporate_Name__c = 'Target Corp';
            insert acco;
            list<id> idsRegister = new list<id>();
            
            RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Name = '1',Account_AR__c = acco.Id, Status_AR__c = 'Receipt Verified', Downpayments_AR__c = 123.1, Discount_AR__c = 321.0 );
            insert recibo;
            idsRegister.add(recibo.id);
            RCP_Receipt_ARG__c recibo1 = new RCP_Receipt_ARG__c(Name = '2',Account_AR__c = acco.Id, Status_AR__c = 'Receipt Verified');
            insert recibo1;
            idsRegister.add(recibo1.id);
            
            DCM_Documents_ARG__c doc = new DCM_Documents_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567', LegalInvoice_AR__c ='1234567890' );
            insert doc;
            
            system.Test.stopTest();
            
            VLS_Values_ARG__c val = new VLS_Values_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567', 
                                                        IssueDate_AR_c__c = date.today(), Bank_AR__c = 'ABC', BranBranch_AR__c = 'ABC');
            insert val;
            
            TXC_TaxCertificates_ARG__c tax = new TXC_TaxCertificates_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567');
            insert tax;
            
            DPT_Deposit_ARG__c dep = new DPT_Deposit_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567');
            insert dep;
        
        
            BTN10_TXT_TO_JDE_AR.txtToJdeButton(idsRegister);
        }
    }
    static testMethod void UnitTest4(){
    
        system.Test.startTest();
        
       system.runAs(createTesoreriaUser()){

            Account acco = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
            acco.Name='TEST';
            acco.Corporate_Name__c = 'Target Corp';
            insert acco;
            list<id> idsRegister = new list<id>();
            
            RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Name = '1',Account_AR__c = acco.Id, Status_AR__c = 'Receipt Verified', Downpayments_AR__c = 123.1, Discount_AR__c = 321.0 );
            insert recibo;
            idsRegister.add(recibo.id);
            RCP_Receipt_ARG__c recibo1 = new RCP_Receipt_ARG__c(Name = '2',Account_AR__c = acco.Id, Status_AR__c = 'Receipt Verified');
            insert recibo1;
            idsRegister.add(recibo1.id);
            
            DBT_Debit_ARG__c deb = new DBT_Debit_ARG__c(ReceiptNo_AR__c = recibo.id, Serial_AR__c = 1234, DebitNoteType_AR__c = 'A', DebitAmount_AR__c = 1234, DebitNo_AR__c = 1234);
            insert deb;
            
            DCM_Documents_ARG__c doc = new DCM_Documents_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567', LegalInvoice_AR__c ='123456789012345' );
            insert doc;
            
            system.Test.stopTest();
            
            VLS_Values_ARG__c val = new VLS_Values_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567', 
                                                        IssueDate_AR_c__c = date.today(), Bank_AR__c = 'ABC', BranBranch_AR__c = 'ABC');
            insert val;
            
            TXC_TaxCertificates_ARG__c tax = new TXC_TaxCertificates_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567');
            insert tax;
            
            DPT_Deposit_ARG__c dep = new DPT_Deposit_ARG__c(ReceiptNo_AR__c = recibo.id, Name = '1234567');
            insert dep;
        
        
            BTN10_TXT_TO_JDE_AR.txtToJdeButton(idsRegister);
        }
    }

    public static User createTesoreriaUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ARG_Tesorería' LIMIT 1]; 
            
        User u = new User(
            Alias = 'testB', 
            Email='testAlias@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='TestUser1', 
            FirstName = 'TestUser1',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='testAlias@testorg.com'
        );      
        insert u;
        
        return u;
    } 
    
}