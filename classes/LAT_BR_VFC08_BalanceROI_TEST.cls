/*************************************************************************************************
*                                         Company: ValueNet                                      *
*------------------------------------------------------------------------------------------------*
*                           Test de la pagina LAT_BR_VFP08_BalanceROI                            *
**************************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 18/11/2016
*
********************************************************************************/

@isTest
private class LAT_BR_VFC08_BalanceROI_TEST {
 
    static testmethod void unitTest(){
        Utils.setMigrationDoneTest(false); 
        
        LAT_BR_CS002_Status__c cs = new LAT_BR_CS002_Status__c();
        cs.Name = 'test';
        insert cs;
        LAT_CRP_Custom_Report__c crp = new LAT_CRP_Custom_Report__c(LAT_ReportName__c = 'TestR', LAT_VisualForceName__c = 'LAT_BR_VFP08_BalanceROI');
        insert crp;
        System.currentPageReference().getParameters().put('IdRep', crp.Id);

        LAT_BR_ContractForecast__c contractF = new LAT_BR_ContractForecast__c();
        contractF.LAT_BR_Region__c = 'REG MT';
        contractF.LAT_BR_Segmentation__c = 'Mainstream';
        contractF.LAT_BR_FiscalYear__c = '2013';
        contractF.LAT_BR_Forecast__c = 5;
        insert contractF;
                
        //REGISTROS   esto es una prueba
        
        UDC__c udc = new UDC__c(
            CodProd__c = '01',
            CodUs__c = '01',
            CodDefUsuario__c = '1',
            Internal_Id__c = '01-01',
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard')
        );
        
        insert udc;
        
        User us = [SELECT Id, C_digo_JDE__c FROM User WHERE Id =: userInfo.getUserId()];
        
        us.C_digo_JDE__c = '7';
        
        update us;
        
        Account acc = new Account(
        RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
        CNPJ__c = '33372251012677',
        Name = 'testAccountTom',
        Regional__c = udc.Id,
        Overdue__c = true,
        Type = 'On_Trade',
        Corporate_Name__c = 'test92569',
        Channel_Type__c = 'Direto',
        Sub_Channel__c = 'Delicatessen',
        Regional_Manager__c = us.Id,
        AddressLine1_AR__c = 'test0',
        Shipping_Neighbourhood__c = 'test3',
        Revenue_Neighbourhood__c = 'test2',
        Billing_Neighbourhood__c ='test1',
        Shipping_Country__c ='test4',
        Revenue_Country__c ='test5',
        Billing_Country__c ='test8',
        Status__c = 'Cliente cadastrado no JDE',
        Client_code_AN8__c = '0',
        Rating_segmentation_targert_market__c = 'Mainstream',
        LAT_BR_RegionalClientOnPremise__c = 'REG MT',
        Segmentation_Type_on_trade__c = 'Mainstream'
        );
        
        
        insert acc;
        
        test.startTest();
        Utils.setMigrationDoneTest(false); 
        Product2 produto = new Product2();
        produto.Name = 'Cloud2b'; 
        produto.IsActive = true;
        produto.CD_Unit__c = 'UN';
        produto.Internal_id__c = '444';
        produto.LAT_IsRefactorProduct__c = 'Y';
        produto.LAT_BR_Descricao_SchedulerC__c = 'test'; 
        //produto.QT_lead_time__c = 5;
        produto.SKU__c = '5666';
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
        //insert produto;
        insert produto;

        Planejamento__c plan = new Planejamento__c(Name = 'Test', 
            M_s_de_Ref_rencia__c = 'Junho', 
            Ano_de_Referencia__c = string.valueof(Integer.ValueOf(Date.today().year()) + 1), 
            recordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard'));
        insert plan;
    
        date fechas = Date.newInstance(Integer.ValueOf(Date.today().year()) + 1, 1, 1);
        Visitas__c vis = new Visitas__c(Name = 'TEST', 
            Planejamento__c = plan.id, 
            Hora_da_Visita__c = '12:00',
            Data_da_Visita__c = fechas, 
            Descrever_Motivo__c = 'Test', Resumo_da_Visita__c = 'Test' , 
            recordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard'));
        insert vis;
            
        Checklist_de_visita__c check = new Checklist_de_visita__c();
        check.Visita__c = vis.Id;
        check.LAT_BR_ValidOnTradeChecklist__c = true;
        insert check;

        Produto_Concorr_ncia__c produConcorrencia = new Produto_Concorr_ncia__c();
        produConcorrencia.Checklist_de_visita__c = check.id;
        produConcorrencia.Produto_PERNOD__c = produto.id;
        produConcorrencia.Qtde_de_Caixas_Estoque__c = 2;
        insert produConcorrencia;
                                  
        list<LAT_Contract__c> toInsert = new list<LAT_Contract__c>();
        
        LAT_Contract__c ActualContract = new LAT_Contract__c();        
        ActualContract.StartDate__c = fechas;
        ActualContract.Status__c = 'Aprovado';
        date fecha = Date.newInstance(Integer.ValueOf(Date.today().year()) + 1, 1, 1);
        ActualContract.LAT_BR_RealValidityDate__c = fecha;
        ActualContract.Account__c = acc.id;
        
        toInsert.add(ActualContract);
        
        LAT_Contract__c contract = new LAT_Contract__c();
        contract.ROI_Dinheiro__c = 5;
        contract.Account__c = acc.id;
        contract.StartDate__c = Date.newInstance(2013, 6, 29);
        contract.ROI_Comentarios_Negativo__c = 'TEST';
        
        toInsert.add(contract);
        
        insert toInsert; 
        /*   
        Planejamento__c plan = new Planejamento__c(Name = 'Test', M_s_de_Ref_rencia__c = 'Junho', Ano_de_Referencia__c = string.valueof(Integer.ValueOf(Date.today().year()) + 1), recordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard'));
        insert plan;
    
        Visitas__c vis = new Visitas__c(Name = 'TEST', Planejamento__c = plan.id, Hora_da_Visita__c = '12:00',Data_da_Visita__c = fechas, Descrever_Motivo__c = 'Test', Resumo_da_Visita__c = 'Test' , recordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard'));
        insert vis;
            
        Checklist_de_visita__c check = new Checklist_de_visita__c();
        check.Visita__c = vis.Id;
        check.LAT_BR_ValidOnTradeChecklist__c = true;
        insert check;
      
        Product2 prod = new Product2();
        prod.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
        prod.IsActive = true;
        prod.CD_Unit__c = 'UN';
        prod.Internal_id__c = '123';
        prod.RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard');
        insert prod;
        
        Produto_Concorr_ncia__c produConcorrencia = new Produto_Concorr_ncia__c();
        produConcorrencia.Checklist_de_visita__c = check.id;
        produConcorrencia.Produto_PERNOD__c = prod.id;
        */
                                       
        //CONSTRUCTOR
        LAT_BR_VFC08_BalanceROI vfcRoi = new LAT_BR_VFC08_BalanceROI();
        
        //FILTROS
        vfcRoi.fiscalYear = '2017';
        vfcRoi.month = '6';
        
        list<SelectOption> option1 = new list<SelectOption>();
        SelectOption opt1 = new SelectOption('REG MT', 'REG MT');
        option1.add(opt1);
        
        list<SelectOption> option2 = new list<SelectOption>();
        SelectOption opt2 = new SelectOption('Mainstream', 'Mainstream');
        option2.add(opt2);
        
        vfcRoi.regionsSelected = option1;
        vfcRoi.segmentsSelected = option2;
        

        //LLAMADOS

        vfcRoi.runReport();
        vfcRoi.getColorTab();
        vfcRoi.getFiscalYears();
        vfcRoi.getStatusAvailable();
        vfcRoi.getSegmentsAvailable();
        vfcRoi.getMonths();
        
        test.stopTest();  
    }
    
    //MIGRATED 21/11/2016
    static testmethod void unitTestB(){
        Utils.setMigrationDoneTest(true); 
        LAT_BR_CS002_Status__c cs = new LAT_BR_CS002_Status__c();
        cs.Name = 'test';
        insert cs;
        LAT_CRP_Custom_Report__c crp = new LAT_CRP_Custom_Report__c(LAT_ReportName__c = 'TestR', LAT_VisualForceName__c = 'LAT_BR_VFP08_BalanceROI');
        insert crp;
        System.currentPageReference().getParameters().put('IdRep', crp.Id);
        LAT_BR_ContractForecast__c contractF = new LAT_BR_ContractForecast__c();
        contractF.LAT_BR_Region__c = 'REG MT';
        contractF.LAT_BR_Segmentation__c = 'Mainstream';
        contractF.LAT_BR_FiscalYear__c = '2013';
        contractF.LAT_BR_Forecast__c = 5;
        insert contractF;
                
        //REGISTROS   esto es una prueba
        
        UDC__c udc = new UDC__c(
            CodProd__c = '01',
            CodUs__c = '01',
            CodDefUsuario__c = '1',
            Internal_Id__c = '01-01',
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard')
        );
        
        insert udc;
        
        User us = [SELECT Id, C_digo_JDE__c FROM User WHERE Id =: userInfo.getUserId()];
        
        us.C_digo_JDE__c = '7';
        
        update us;
        
        Account acc = new Account(
        RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
        CNPJ__c = '33372251012677',
        Name = 'testAccountTom',
        Regional__c = udc.Id,
        Overdue__c = true,
        Type = 'On_Trade',
        Corporate_Name__c = 'test92569',
        Channel_Type__c = 'Direto',
        Sub_Channel__c = 'Delicatessen',
        Regional_Manager__c = us.Id,
        AddressLine1_AR__c = 'test0',
        Shipping_Neighbourhood__c = 'test3',
        Revenue_Neighbourhood__c = 'test2',
        Billing_Neighbourhood__c ='test1',
        Shipping_Country__c ='test4',
        Revenue_Country__c ='test5',
        Billing_Country__c ='test8',
        Status__c = 'Cliente cadastrado no JDE',
        Client_code_AN8__c = '0',
        Rating_segmentation_targert_market__c = 'Mainstream',
        LAT_BR_RegionalClientOnPremise__c = 'REG MT',
        Segmentation_Type_on_trade__c = 'Mainstream'
        );
        
        
        insert acc;
        
        test.startTest();
        Utils.setMigrationDoneTest(true); 
        
        list<LAT_Contract__c> toInsert = new list<LAT_Contract__c>();
        
        LAT_Contract__c ActualContract = new LAT_Contract__c();        
        date fechas = Date.newInstance(Integer.ValueOf(Date.today().year()) + 1, 1, 1);
        ActualContract.StartDate__c = fechas;
        ActualContract.Status__c = 'Aprovado';
        date fecha = Date.newInstance(Integer.ValueOf(Date.today().year()) + 1, 1, 1);
        ActualContract.LAT_BR_RealValidityDate__c = fecha;
        ActualContract.Account__c = acc.id;
        
        toInsert.add(ActualContract);
        
        LAT_Contract__c contract = new LAT_Contract__c();
        contract.ROI_Dinheiro__c = 5;
        contract.StartDate__c = Date.newInstance(2013, 6, 29);
        contract.Account__c = acc.id;
        contract.ROI_Comentarios_Negativo__c = 'TEST';
        
        toInsert.add(contract);
        
        insert toInsert; 
          
        Planejamento__c plan = new Planejamento__c(Name = 'Test', 
            M_s_de_Ref_rencia__c = 'Junho', 
            Ano_de_Referencia__c = string.valueof(Integer.ValueOf(Date.today().year()) + 1), 
            recordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard'));
        insert plan;
    
        Visitas__c vis = new Visitas__c(Name = 'TEST', 
            Planejamento__c = plan.id, 
            Hora_da_Visita__c = '12:00',Data_da_Visita__c = fechas, 
            Descrever_Motivo__c = 'Test', Resumo_da_Visita__c = 'Test' , 
            recordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard'));
        insert vis;
            
        Checklist_de_visita__c check = new Checklist_de_visita__c();
        check.Visita__c = vis.Id;
        check.LAT_BR_ValidOnTradeChecklist__c = true;
        insert check;
      
        LAT_Product__c produto = new LAT_Product__c();
        produto.Name = 'Cloud2b'; 
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalId__c = '444';
        produto.LAT_IsRefactorProduct__c = 'Y';
        produto.LAT_BR_SchedulerCDescription__c = 'test'; 
        //produto.QT_lead_time__c = 5;
        produto.LAT_SKU__c = '5666';
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
        //insert produto;
        insert produto;
        
        Produto_Concorr_ncia__c produConcorrencia = new Produto_Concorr_ncia__c();
        produConcorrencia.Checklist_de_visita__c = check.id;
        produConcorrencia.LAT_Product__c = produto.id;
        produConcorrencia.Qtde_de_Caixas_Estoque__c = 2;
        insert produConcorrencia;
                                       
        //CONSTRUCTOR
        LAT_BR_VFC08_BalanceROI vfcRoi = new LAT_BR_VFC08_BalanceROI();
        
        //FILTROS
        vfcRoi.fiscalYear = '2017';
        vfcRoi.month = '6';
        
        list<SelectOption> option1 = new list<SelectOption>();
        SelectOption opt1 = new SelectOption('REG MT', 'REG MT');
        option1.add(opt1);
        
        list<SelectOption> option2 = new list<SelectOption>();
        SelectOption opt2 = new SelectOption('Mainstream', 'Mainstream');
        option2.add(opt2);
        
        vfcRoi.regionsSelected = option1;
        vfcRoi.segmentsSelected = option2;
        

        //LLAMADOS

        vfcRoi.runReport();
        vfcRoi.getColorTab();
        vfcRoi.getFiscalYears();
        vfcRoi.getStatusAvailable();
        vfcRoi.getSegmentsAvailable();
        vfcRoi.getMonths();
        
        test.stopTest();  
    }
    static testmethod void unitTest2(){
        Utils.setMigrationDoneTest(false);
        LAT_CRP_Custom_Report__c crp = new LAT_CRP_Custom_Report__c(LAT_ReportName__c = 'TestR', LAT_VisualForceName__c = 'LAT_BR_VFP08_BalanceROI');
        insert crp;
        System.currentPageReference().getParameters().put('IdRep', crp.Id); 
        LAT_BR_CS002_Status__c cs = new LAT_BR_CS002_Status__c();
        cs.Name = 'test';
        insert cs;
        LAT_BR_ContractForecast__c contractF = new LAT_BR_ContractForecast__c();
        contractF.LAT_BR_Region__c = 'REG MT';
        contractF.LAT_BR_Segmentation__c = 'Mainstream';
        contractF.LAT_BR_FiscalYear__c = '2013';
        contractF.LAT_BR_Forecast__c = 5;
        insert contractF;
        
        //REGISTROS      

        UDC__c udc = new UDC__c(
            CodProd__c = '01',
            CodUs__c = '01',
            CodDefUsuario__c = '1',
            Internal_Id__c = '01-01',
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard')
        );
        
        insert udc;
        
        User us = [SELECT Id, C_digo_JDE__c FROM User WHERE Id =: userInfo.getUserId()];
        
        us.C_digo_JDE__c = '7';
        
        update us;

       
        Account acc = new Account(
        RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
        CNPJ__c = '33372251012677',
        Name = 'testAccountTom',
        Regional_Manager__c = us.Id,
        Regional__c = udc.Id,
        Overdue__c = true,
        Type = 'On_Trade',
        Corporate_Name__c = 'test92569',
        Channel_Type__c = 'Direto',
        Sub_Channel__c = 'Delicatessen',
        AddressLine1_AR__c = 'test0',
        Shipping_Neighbourhood__c = 'test3',
        Revenue_Neighbourhood__c = 'test2',
        Billing_Neighbourhood__c ='test1',
        Shipping_Country__c ='test4',
        Revenue_Country__c ='test5',
        Billing_Country__c ='test8',
        Status__c = 'Cliente cadastrado no JDE',
        Client_code_AN8__c = '0',
        Rating_segmentation_targert_market__c = 'Mainstream',
        LAT_BR_RegionalClientOnPremise__c = 'REG MT',
        Segmentation_Type_on_trade__c = 'Mainstream'
        );

        
        insert acc;

        Product2 produto = new Product2();
        produto.Name = 'Cloud2b'; 
        produto.IsActive = true;
        produto.CD_Unit__c = 'UN';
        produto.Internal_id__c = '444';
        produto.LAT_IsRefactorProduct__c = 'Y';
        produto.LAT_BR_Descricao_SchedulerC__c = 'test'; 
        //produto.QT_lead_time__c = 5;
        produto.SKU__c = '5666';
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
        //insert produto;
        insert produto;
        test.startTest();

        Utils.setMigrationDoneTest(false); 

        Planejamento__c plan = new Planejamento__c(Name = 'Test', 
            M_s_de_Ref_rencia__c = 'Junho', 
            Ano_de_Referencia__c = string.valueof(Integer.ValueOf(Date.today().year()) + 1), 
            recordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard'));
        insert plan;
        date fechas = Date.newInstance(Integer.ValueOf(Date.today().year()) + 1, 1, 1);
    
        Visitas__c vis = new Visitas__c(Name = 'TEST', 
            Planejamento__c = plan.id, 
            Hora_da_Visita__c = '12:00',Data_da_Visita__c = fechas, 
            Descrever_Motivo__c = 'Test', Resumo_da_Visita__c = 'Test' , 
            recordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard'));
        insert vis;
            
        Checklist_de_visita__c check = new Checklist_de_visita__c();
        check.Visita__c = vis.Id;
        check.LAT_BR_ValidOnTradeChecklist__c = true;
        insert check;

        Produto_Concorr_ncia__c produConcorrencia = new Produto_Concorr_ncia__c();
        produConcorrencia.Checklist_de_visita__c = check.id;
        produConcorrencia.Produto_PERNOD__c = produto.id;
        produConcorrencia.Qtde_de_Caixas_Estoque__c = 2;
        insert produConcorrencia;
        
        list<LAT_Contract__c> toInsert = new list<LAT_Contract__c>();
        
        LAT_Contract__c ActualContract = new LAT_Contract__c();        
        ActualContract.StartDate__c = fechas;
        ActualContract.Status__c = 'Aprovado';
        date fecha = Date.newInstance(Integer.ValueOf(Date.today().year()) + 1, 1, 1);
        ActualContract.LAT_BR_RealValidityDate__c = fecha;
        ActualContract.Account__c = acc.id;
        
        toInsert.add(ActualContract);
        
        
        /*
        LAT_Contract__c contract = new LAT_Contract__c();
        contract.ROI_Dinheiro__c = 5;
        contract.Account__c = acc.id;
        contract.ROI_Comentarios_Negativo__c = 'TEST';
        
        toInsert.add(contract);
        
        insert toInsert;+
        
        
        
        Planejamento__c plan = new Planejamento__c(Name = 'Test', M_s_de_Ref_rencia__c = 'Junho', Ano_de_Referencia__c =  string.valueof(Integer.ValueOf(Date.today().year()) + 1), recordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard'));
        insert plan;
    
        Visitas__c vis = new Visitas__c(Name = 'TEST', Planejamento__c = plan.id, Hora_da_Visita__c = '12:00',Data_da_Visita__c = fechas, Descrever_Motivo__c = 'Test', Resumo_da_Visita__c = 'Test', recordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard') );
        insert vis;
                
        Checklist_de_visita__c check = new Checklist_de_visita__c();
        check.Visita__c = vis.Id;
        check.LAT_BR_ValidOnTradeChecklist__c = true;
        insert check;
          
        Product2 prod = new Product2();
        prod.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
        prod.IsActive = true;
        prod.CD_Unit__c = 'UN';
        prod.Internal_id__c = '123';
        prod.RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard');
        insert prod;
        
        Informacoes_do_Produto__c infProd = new Informacoes_do_Produto__c();
        infProd.Name = 'test';
        infProd.SKU_de_referencia__c = prod.Id;
        insert infProd;
        
        Informacoes_de_Custo_do_Produto__c infCusto = new Informacoes_de_Custo_do_Produto__c();
        infCusto.UF__c = 'AC';
        infCusto.Scheduler_C__c = infProd.Id;
        insert infCusto;
        */
        //CONSTRUCTOR

        insert toInsert;
        LAT_BR_VFC08_BalanceROI vfcRoi = new LAT_BR_VFC08_BalanceROI();

        
        //FILTROS
        vfcRoi.fiscalYear = '2013';
        vfcRoi.month = '6';
        
        list<SelectOption> option1 = new list<SelectOption>();
        SelectOption opt1 = new SelectOption('Brasil', 'Brasil');
        option1.add(opt1);
        
        list<SelectOption> option2 = new list<SelectOption>();
        SelectOption opt2 = new SelectOption('Mainstream', 'Mainstream');
        option2.add(opt2);
        
        vfcRoi.regionsSelected = option1;
        vfcRoi.segmentsSelected = option2;
        

        //LLAMADOS

        vfcRoi.runReport();
        vfcRoi.getColorTab();
        vfcRoi.DoExportExcel();
        vfcRoi.DoExportPDF();
        
        test.stopTest();  
    }   
        //MIGRATED 21/11/2016
        static testmethod void unitTest2B(){
        Utils.setMigrationDoneTest(true); 
        LAT_CRP_Custom_Report__c crp = new LAT_CRP_Custom_Report__c(LAT_ReportName__c = 'TestR', LAT_VisualForceName__c = 'LAT_BR_VFP08_BalanceROI');
        insert crp;
        System.currentPageReference().getParameters().put('IdRep', crp.Id);
        LAT_BR_CS002_Status__c cs = new LAT_BR_CS002_Status__c();
        cs.Name = 'test';
        insert cs;
        LAT_BR_ContractForecast__c contractF = new LAT_BR_ContractForecast__c();
        contractF.LAT_BR_Region__c = 'REG MT';
        contractF.LAT_BR_Segmentation__c = 'Mainstream';
        contractF.LAT_BR_FiscalYear__c = '2013';
        contractF.LAT_BR_Forecast__c = 5;
        insert contractF;
        
        //REGISTROS      

        UDC__c udc = new UDC__c(
            CodProd__c = '01',
            CodUs__c = '01',
            CodDefUsuario__c = '1',
            Internal_Id__c = '01-01',
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard')
        );
        
        insert udc;
        
        User us = [SELECT Id, C_digo_JDE__c FROM User WHERE Id =: userInfo.getUserId()];
        
        us.C_digo_JDE__c = '7';
        
        update us;

       
        Account acc = new Account(
        RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
        CNPJ__c = '33372251012677',
        Name = 'testAccountTom',
        Regional_Manager__c = us.Id,
        Regional__c = udc.Id,
        Overdue__c = true,
        Type = 'On_Trade',
        Corporate_Name__c = 'test92569',
        Channel_Type__c = 'Direto',
        Sub_Channel__c = 'Delicatessen',
        AddressLine1_AR__c = 'test0',
        Shipping_Neighbourhood__c = 'test3',
        Revenue_Neighbourhood__c = 'test2',
        Billing_Neighbourhood__c ='test1',
        Shipping_Country__c ='test4',
        Revenue_Country__c ='test5',
        Billing_Country__c ='test8',
        Status__c = 'Cliente cadastrado no JDE',
        Client_code_AN8__c = '0',
        Rating_segmentation_targert_market__c = 'Mainstream',
        LAT_BR_RegionalClientOnPremise__c = 'REG MT',
        Segmentation_Type_on_trade__c = 'Mainstream'
        );

        
        insert acc;
        
        LAT_Product__c produto = new LAT_Product__c();
        produto.Name = 'Cloud2b'; 
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalId__c = '444';
        produto.LAT_IsRefactorProduct__c = 'Y';
        produto.LAT_BR_SchedulerCDescription__c = 'test'; 
        //produto.QT_lead_time__c = 5;
        produto.LAT_SKU__c = '5666';
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
        //insert produto;
        insert produto;

        test.startTest();
        Utils.setMigrationDoneTest(true); 

        Planejamento__c plan = new Planejamento__c(Name = 'Test', 
            M_s_de_Ref_rencia__c = 'Junho', 
            Ano_de_Referencia__c = string.valueof(Integer.ValueOf(Date.today().year()) + 1), 
            recordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard'));
        insert plan;
        date fechas = Date.newInstance(Integer.ValueOf(Date.today().year()) + 1, 1, 1);
    
        Visitas__c vis = new Visitas__c(Name = 'TEST', 
            Planejamento__c = plan.id, 
            Hora_da_Visita__c = '12:00',Data_da_Visita__c = fechas, 
            Descrever_Motivo__c = 'Test', Resumo_da_Visita__c = 'Test' , 
            recordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard'));
        insert vis;
            
        Checklist_de_visita__c check = new Checklist_de_visita__c();
        check.Visita__c = vis.Id;
        check.LAT_BR_ValidOnTradeChecklist__c = true;
        insert check;

        Produto_Concorr_ncia__c produConcorrencia = new Produto_Concorr_ncia__c();
        produConcorrencia.Checklist_de_visita__c = check.id;
        produConcorrencia.LAT_Product__c = produto.id;
        produConcorrencia.Qtde_de_Caixas_Estoque__c = 2;
        insert produConcorrencia;
        list<LAT_Contract__c> toInsert = new list<LAT_Contract__c>();
        
        LAT_Contract__c ActualContract = new LAT_Contract__c();        
        ActualContract.StartDate__c = fechas;
        ActualContract.Status__c = 'Aprovado';
        date fecha = Date.newInstance(Integer.ValueOf(Date.today().year()) + 1, 1, 1);
        ActualContract.LAT_BR_RealValidityDate__c = fecha;
        ActualContract.Account__c = acc.id;
        
        toInsert.add(ActualContract);
        
        /*
        LAT_Contract__c contract = new LAT_Contract__c();
        contract.ROI_Dinheiro__c = 5;
        contract.Account__c = acc.id;
        contract.ROI_Comentarios_Negativo__c = 'TEST';
        
        toInsert.add(contract);
        
        insert toInsert;+
        
        
        
        Planejamento__c plan = new Planejamento__c(Name = 'Test', M_s_de_Ref_rencia__c = 'Junho', Ano_de_Referencia__c =  string.valueof(Integer.ValueOf(Date.today().year()) + 1), recordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard'));
        insert plan;
    
        Visitas__c vis = new Visitas__c(Name = 'TEST', Planejamento__c = plan.id, Hora_da_Visita__c = '12:00',Data_da_Visita__c = fechas, Descrever_Motivo__c = 'Test', Resumo_da_Visita__c = 'Test', recordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard') );
        insert vis;
                
        Checklist_de_visita__c check = new Checklist_de_visita__c();
        check.Visita__c = vis.Id;
        check.LAT_BR_ValidOnTradeChecklist__c = true;
        insert check;
          
        Product2 prod = new Product2();
        prod.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
        prod.IsActive = true;
        prod.CD_Unit__c = 'UN';
        prod.Internal_id__c = '123';
        prod.RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard');
        insert prod;
        
        Informacoes_do_Produto__c infProd = new Informacoes_do_Produto__c();
        infProd.Name = 'test';
        infProd.SKU_de_referencia__c = prod.Id;
        insert infProd;
        
        Informacoes_de_Custo_do_Produto__c infCusto = new Informacoes_de_Custo_do_Produto__c();
        infCusto.UF__c = 'AC';
        infCusto.Scheduler_C__c = infProd.Id;
        insert infCusto;
        */
        //CONSTRUCTOR
        insert toInsert;
        LAT_BR_VFC08_BalanceROI vfcRoi = new LAT_BR_VFC08_BalanceROI();

        
        //FILTROS
        vfcRoi.fiscalYear = '2013';
        vfcRoi.month = '6';
        
        list<SelectOption> option1 = new list<SelectOption>();
        SelectOption opt1 = new SelectOption('Brasil', 'Brasil');
        option1.add(opt1);
        
        list<SelectOption> option2 = new list<SelectOption>();
        SelectOption opt2 = new SelectOption('Mainstream', 'Mainstream');
        option2.add(opt2);
        
        vfcRoi.regionsSelected = option1;
        vfcRoi.segmentsSelected = option2;
        

        //LLAMADOS

        vfcRoi.runReport();
        vfcRoi.getColorTab();
        vfcRoi.DoExportExcel();
        vfcRoi.DoExportPDF();
        
        test.stopTest();  
    }
    
}