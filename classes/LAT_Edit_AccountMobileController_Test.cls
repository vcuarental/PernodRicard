@isTest
private class LAT_Edit_AccountMobileController_Test {
    

    @testsetup
    public static void prepareTest(){



        /**List<UDC__C> listUDC = new List<UDC__C>();
        List<LAT_BR_ClientSegmentationParameters__c> listpar = new List<LAT_BR_ClientSegmentationParameters__c>();
        UDC__c tab = new UDC__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
                Internal_Id__c = '1-8-01-20',
                CodDefUsuario__c = '8',
                CodProd__c = '01',
                Name = 'TRADING BRANDS',
                CodUs__c = '20'
            ); 
            listUDC.add(tab);
            
            UDC__c tab1 = new UDC__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
                Internal_Id__c = '1-5-01-21',
                CodDefUsuario__c = '5',
                CodProd__c = '01',
                Name = 'SIM',
                CodUs__c = '21'
            ); 
            listUDC.add(tab1);
            
            UDC__c tab2 = new UDC__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
                Internal_Id__c = '1-601-01-03',
                CodDefUsuario__c = '601',
                CodProd__c = '01',
                Name = 'Sub Channel Rating',
                CodUs__c = '03'
            ); 
            listUDC.add(tab2);
            
            UDC__c tab3 = new UDC__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
                Internal_Id__c = '1-8-01-18',
                CodDefUsuario__c = '8',
                CodProd__c = '01',
                Name = 'MAINSTREAM',
                CodUs__c = '18'
            ); 
            listUDC.add(tab3);
            
            UDC__c tab4 = new UDC__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
                Internal_Id__c = '01-06',
                CodProd__c = '01',
                Name = 'Customer Flag',
                CodUs__c = '06'
            ); 
            listUDC.add(tab4);
            
            UDC__c tab5 = new UDC__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
                Internal_Id__c = '1-6-01-19',
                CodDefUsuario__c = '6',
                CodProd__c = '01',
                Name = 'SUPER',
                CodUs__c = '19'
            ); 
            listUDC.add(tab5);
            

            insert listUDC;

            LAT_BR_ClientSegmentationParameters__c par1 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_BusinessTargetAudience__c',
                LAT_BR_Answer__c = 'Mostly Legal Entities',
                LAT_BR_AnswerCode__c = 'A2'
            );
            
            LAT_BR_ClientSegmentationParameters__c par2 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_MainAttentionChannel__c',
                LAT_BR_Answer__c = 'Off Trade',
                LAT_BR_AnswerCode__c = 'B3'
            );
            
            LAT_BR_ClientSegmentationParameters__c par3 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_PerformingArea__c',
                LAT_BR_Answer__c = 'Have sales team within 3 States without a defined territory',
                LAT_BR_AnswerCode__c = 'C3'
            );
            
            LAT_BR_ClientSegmentationParameters__c par4 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_SKUCategoriesAmount__c',
                LAT_BR_Answer__c = 'High categories number and more than 1000 SKUs',
                LAT_BR_AnswerCode__c = 'D4'
            );
            
            LAT_BR_ClientSegmentationParameters__c par5 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_PortfolioType__c',
                LAT_BR_Answer__c = 'Standard Products',
                LAT_BR_AnswerCode__c = 'F2'
            );
            
            LAT_BR_ClientSegmentationParameters__c par6 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_FiscalBenefit__c',
                LAT_BR_Answer__c = 'Yes',
                LAT_BR_AnswerCode__c = 'G1'
            );
            
            LAT_BR_ClientSegmentationParameters__c par7 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_RelationshipLevel__c',
                LAT_BR_Answer__c = 'Trading Brands',
                LAT_BR_AnswerCode__c = 'E3'
            );
            
            LAT_BR_ClientSegmentationParameters__c par8 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Priority Level',
                LAT_BR_Question__c = 'LAT_BR_RelationshipLevel__c',
                LAT_BR_Answer__c = 'Trading Brands',
                LAT_BR_PriorityLevel__c = tab.Id
            );
            
            LAT_BR_ClientSegmentationParameters__c par9 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Business Size',
                LAT_BR_Question__c = 'LAT_BR_StoreSize__c',
                LAT_BR_Answer__c = 'From 5 to 9 cks',
                LAT_BR_BusinessSize__c = tab5.Id
            );
            
            LAT_BR_ClientSegmentationParameters__c par10 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_Key__c = 'A2B3C3D4E3F2G1',
                LAT_BR_Channel__c = 'Off Trade',
                LAT_BR_SubChannel__c = 'Atacadista',
                LAT_BR_FiscalBenefit__c = tab1.Id,
                LAT_BR_Profile__c = tab3.Id,
                LAT_BR_PriorityLevel__c = tab.Id,
                LAT_BR_Segment__c = tab2.Id,
                LAT_BR_CustomerFlag__c = tab4.Id
            );
            
            LAT_BR_ClientSegmentationParameters__c par11 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_StoresTypes__c',
                LAT_BR_Answer__c = 'Self-Service with stores in large format and low level of service',
                LAT_BR_AnswerCode__c = 'H1'
            );
            
            LAT_BR_ClientSegmentationParameters__c par12 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_StoreScope__c',
                LAT_BR_Answer__c = 'Independent local shop range',
                LAT_BR_AnswerCode__c = 'J1'
            );
            
            LAT_BR_ClientSegmentationParameters__c par13 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_StoreSize__c',
                LAT_BR_Answer__c = 'From 5 to 9 cks',
                LAT_BR_AnswerCode__c = 'L3'
            );
            
            LAT_BR_ClientSegmentationParameters__c par14 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_IsKA__c',
                LAT_BR_Answer__c = 'KA',
                LAT_BR_AnswerCode__c = 'K1'
            );
            
            LAT_BR_ClientSegmentationParameters__c par15 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Fiscal Benefit',
                LAT_BR_Question__c = 'LAT_BR_FiscalBenefit__c',
                LAT_BR_Answer__c = 'Yes',
                LAT_BR_AnswerCode__c = 'K1'
            );
            
            LAT_BR_ClientSegmentationParameters__c par16 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_Key__c = 'A1F2H1J1L3',
                LAT_BR_DataType__c = 'Segmentation Key',
                LAT_BR_Channel__c = 'Off Trade',
                LAT_BR_SubChannel__c = 'C&C',
                LAT_BR_FiscalBenefit__c = tab1.Id,
                LAT_BR_Profile__c = tab3.Id,
                LAT_BR_PriorityLevel__c = tab.Id,
                LAT_BR_Segment__c = tab2.Id,
                LAT_BR_CustomerFlag__c = tab4.Id,
                LAT_BR_BusinessSize__c = tab5.Id
            );
            
            listPar.add(par1);
            listPar.add(par2);
            listPar.add(par3);
            listPar.add(par4);
            listPar.add(par5);
            listPar.add(par6);
            listPar.add(par7);
            listPar.add(par8);
            listPar.add(par9);
            listPar.add(par10);
            listPar.add(par11);
            listPar.add(par12);
            listPar.add(par13);
            listPar.add(par14);
            listPar.add(par15);
            listPar.add(par16);
            
            
            insert listPar;**/
    } 

    static testmethod void test_general() {

        LAT_BR_ClientChannelSegmentation__c seg;
        seg = LAT_BR_BTN02_ClientChannelSegment_TEST.clientChannelSegTestFactory();

        PageReference pf = Page.LAT_BR_Edit_AccountMobile;
        pf.getParameters().put('id',seg.LAT_BR_Client__c);
        Account acc = [select Id,Name from account where Id =:seg.LAT_BR_Client__c];
        
        Test.setCurrentPage(pf);
        ApexPages.StandardController ac = new ApexPages.StandardController(acc);
        LAT_Edit_AccountMobileController con = new LAT_Edit_AccountMobileController(ac);
        Test.startTest();
        con.doSave();
        con.selectRType();

        //create segmentation id
        LAT_Mobile_Lookup_Filter__c filter = new LAT_Mobile_Lookup_Filter__c();
        filter.Name = 'Bank__c';
        filter.LAT_Columns__c = 'Name';
        filter.LAT_Filter_Value__c = 'Internal_Id__c != null,';
        insert filter;

        //Test Lookup Fields
        LAT_Edit_AccountMobileController.getLookupFieldInformation('Bank__c','test');
        con.cancelSeg();

        //Test 
        pf.getParameters().put('credId','ttestId');
        pf.getParameters().put('segId','Test');
        Test.setCurrentPage(pf);

        con.saveSegmentation();
        con.editSegmentation();
        Test.stopTest();
        
    }

    static testmethod void sentCreditAnalisisApprove() {

        /*Account acc = new Account(Name= 'Test Account');
        insert acc; */

        Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert acc;

        PageReference pf = Page.LAT_BR_Edit_AccountMobile;
        pf.getParameters().put('id',acc.Id);
        Test.setCurrentPage(pf);
        ApexPages.StandardController ac = new ApexPages.StandardController(acc);
        LAT_Edit_AccountMobileController con = new LAT_Edit_AccountMobileController(ac);
        con.doSave();
        con.selectRType();
        
        //create segmentation id
        LAT_Mobile_Lookup_Filter__c filter = new LAT_Mobile_Lookup_Filter__c();
        filter.Name = 'Bank__c';
        filter.LAT_Columns__c = 'Name';
        filter.LAT_Filter_Value__c = 'Internal_Id__c != null,';
        insert filter;

        //Test Lookup Fields
        LAT_Edit_AccountMobileController.getLookupFieldInformation('Bank__c','test');
        con.cancelSeg();

        //Test         
        con.sendApprovalAccount();

        pf.getParameters().put('credId','ttestId');
        pf.getParameters().put('segId','segIdTest');
        Test.setCurrentPage(pf);

        con.saveSegmentation();
        con.editSegmentation();
    }

    static testmethod void sentoffTradeUpdate() {

        Account acc = LAT_Account_TestFactory.getBRAAccountBase('On_Trade');
        insert acc;
        
        Analise_de_credito__c acred = new Analise_de_credito__c();
        acred.Conta__c = acc.id;
        insert acred;

        PageReference pf = Page.LAT_BR_Edit_AccountMobile;
        pf.getParameters().put('id',acc.Id);
        Test.setCurrentPage(pf);
        ApexPages.StandardController ac = new ApexPages.StandardController(acc);
        LAT_Edit_AccountMobileController con = new LAT_Edit_AccountMobileController(ac);
        con.doSave();
        con.selectRType();
        con.credIdParam = acred.id;
        //create segmentation id
        LAT_Mobile_Lookup_Filter__c filter = new LAT_Mobile_Lookup_Filter__c();
        filter.Name = 'Bank__c';
        filter.LAT_Columns__c = 'Name';
        filter.LAT_Filter_Value__c = 'Internal_Id__c != null,';
        insert filter;
        Test.startTest();
        //Test Lookup Fields
        LAT_Edit_AccountMobileController.getLookupFieldInformation('Bank__c','test');
        con.cancelSeg();

        //Test 
        con.sendApprovalCredit();

        Test.setCurrentPage(pf);

        con.saveSegmentation();
        con.editSegmentation(); 
        Test.stopTest();
    }

    static testmethod void test() {        
        Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'), 
            CNPJ__c = '54651716001150',
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
            Client_code_AN8__c = '123697',
            Billing_Country__c ='test'
        );
        insert acc;
        
        PageReference pf = Page.LAT_BR_Edit_AccountMobile;
        ApexPages.StandardController ac = new ApexPages.StandardController(acc);
        LAT_Edit_AccountMobileController con = new LAT_Edit_AccountMobileController(ac);
        con.doSave();
                    
        CS002_FIeldsIds__c cs002 = new CS002_FIeldsIds__c(
            FieldApiName__c = 'LAT_BR_Client__c',
            Name = 'name',
            FieldId__c= '54386',
            ObjectApiName__c='LAT_BR_ClientChannelSegmentation__c'
        );  
        insert cs002;
                
        pf.getParameters().put('id', acc.Id);
        Test.setCurrentPage(pf);
        con = new LAT_Edit_AccountMobileController(ac);
        con.newSegmentationFlag();
        con.reset();
    }

}