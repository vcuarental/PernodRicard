/****************************************************
 Dev: Denis Aranda  Version: 1  Consulting: Valuenet
****************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/

@isTest
public with sharing class LAT_BR_VFC03_CompetitiveProduct_TEST {
    
    static testMethod void UnitTest() {
        Utils.setMigrationDoneTest(false); 
        
        Map <integer, string> monthsByNum = new Map <integer, string>{1 => 'Janeiro', 2 => 'Fevereiro', 3 => 'Março', 4 => 'Abril', 5 => 'Maio', 6 => 'Junho', 7 => 'Julho', 8 => 'Agosto', 9 => 'Setembro', 10 => 'Outubro', 11 => 'Novembro', 12 => 'Dezembro'};
        String rtOffBrAcc = Global_RecordTypeCache.getRtId('Account' + 'On_Trade');
        String rtOffBrPlan = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard');
        String rtOffBrVis = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard');
        String rtOffBrCheck = Global_RecordTypeCache.getRtId('Checklist_de_visita__c' + 'On_Trade');
        String rtOffBrProd2 = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard');
        
        Account acc = new Account(
            CNPJ__c = '54651716001150',
            Channel__c = 'On Trade',
            RecordTypeId = rtOffBrAcc,
            Name = 'testAccount',
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
            Billing_Country__c ='test',
            LAT_BR_RegionalClientOnPremise__c = 'REG NE',
            Rating_segmentation_targert_market__c = 'Leading'
        );
        insert acc;
        
        
        User usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert usuario; 
        
  

        test.startTest();
        Utils.setMigrationDoneTest(false); 
            Planejamento__c plan = new Planejamento__c(Name = 'Test0', Ano_de_Referencia__c = '2013', M_s_de_Ref_rencia__c = 'Dezembro', Solicitar_aprova_o_para__c = 'Planejamento semana 2', Aprovado_semana_1__c = true, OwnerId = usuario.id, RecordTypeId = rtOffBrPlan );
            insert plan;
            
            Visitas__c vis = new Visitas__c(Name = 'testVis', Planejamento__c = plan.id, Hora_da_Visita__c = '01:00', Data_da_Visita__c = date.today().addDays(-3), Resumo_da_Visita__c = '123', Status__c = 'Planejada', Conta__c =acc.id, RecordTypeId = rtOffBrVis, Tipo_de_Visita__c = 'Execução');
            insert vis;
            
            Checklist_de_visita__c cdvTest = new Checklist_de_visita__c(Visita__c = vis.Id, LAT_BR_ValidOnTradeCheckList__c = true, RecordTypeId =rtOffBrCheck, Tempo_Gasto_no_Cliente_Minutos__c = 11, Motivo_de_nao_visitar__c = 'Outros...', Outros_Motivos__c = 'asd');
            insert cdvTest; 
            
            Product2 prod2 = new Product2(Name = 'CHAMPAGNE', LAT_BR_BrandGrouping__c = 'PERRIER BRUT', LAT_BR_CategoryGrouping__c = 'CHAMPAGNE', CD_Unit__c ='CA', Internal_id__c='83802', RecordTypeId= rtOffBrProd2);
            insert prod2;
            
            Product2 prod3 = new Product2(Name = 'CHAMPAGNE2', LAT_BR_BrandGrouping__c = 'PERRIER BRUT2', LAT_BR_CategoryGrouping__c = 'CHAMPAGNE', CD_Unit__c ='CA', Internal_id__c='83803', RecordTypeId= rtOffBrProd2);
            insert prod3;
            
            Produto_Concorr_ncia__c prod = new Produto_Concorr_ncia__c(Qtde_de_Caixas_Estoque__c= 10, Nao_se_aplica__c= true, Produto_PERNOD__c = prod2.id, Checklist_de_visita__c = cdvTest.id); 
            insert prod;
            
            Produto_Concorr_ncia__c prod1 = new Produto_Concorr_ncia__c(Qtde_de_Caixas_Estoque__c= 10, Nao_se_aplica__c= true, Produto_PERNOD__c = prod3.id, Checklist_de_visita__c = cdvTest.id); 
            insert prod1;
            
            LAT_BR_VFC03_CompetitiveProduct Controller0 = new LAT_BR_VFC03_CompetitiveProduct();
            
            LAT_CRP_Custom_Report__c crp = new LAT_CRP_Custom_Report__c(LAT_ReportName__c = 'TestR', LAT_VisualForceName__c = 'LAT_BR_VFP03_CompetitiveProduct');
            insert crp;
            ApexPages.currentPage().getParameters().put('IdRep', crp.Id); 
            
            LAT_BR_CS001_Segmentacion__c cs = new LAT_BR_CS001_Segmentacion__c(Name='Leading');
            insert cs;
        
            LAT_BR_VFC03_CompetitiveProduct Controller = new LAT_BR_VFC03_CompetitiveProduct();
            Controller.Ejecutar();
            
            LAT_BR_VFC03_CompetitiveProduct Controller1 = new LAT_BR_VFC03_CompetitiveProduct();
            Controller1.selectedRegional.add(new SelectOption('Brasil','Brasil'));
            Controller1.Ejecutar();
            
            LAT_BR_VFC03_CompetitiveProduct Controller2 = new LAT_BR_VFC03_CompetitiveProduct();
            Controller2.selectedRegional.add(new SelectOption('Brasil','Brasil'));
            Controller2.selectedSegmentacion.add(new SelectOption('Leading','Leading'));
            Controller2.Ejecutar();
            
            LAT_BR_VFC03_CompetitiveProduct Controller3 = new LAT_BR_VFC03_CompetitiveProduct();
            Controller3.selectedRegional.add(new SelectOption('Brasil','Brasil'));
            Controller3.selectedSegmentacion.add(new SelectOption('Leading','Leading'));
            Controller3.selectedCat.add(new SelectOption('CHAMPAGNE','CHAMPAGNE'));
            Controller3.Ejecutar();
            
            LAT_BR_VFC03_CompetitiveProduct Controller4 = new LAT_BR_VFC03_CompetitiveProduct();
            Controller4.selectedRegional.add(new SelectOption('Brasil','Brasil'));
            Controller4.selectedSegmentacion.add(new SelectOption('Leading','Leading'));
            Controller4.selectedCat.add(new SelectOption('CHAMPAGNE','CHAMPAGNE'));
            Controller4.selectedBrand.add(new SelectOption('PERRIER BRUT','PERRIER BRUT'));
            Controller4.Ejecutar();
            
            LAT_BR_VFC03_CompetitiveProduct Controller5 = new LAT_BR_VFC03_CompetitiveProduct();
            Controller5.selectedRegional.add(new SelectOption('Brasil','Brasil'));
            Controller5.selectedSegmentacion.add(new SelectOption('Leading','Leading'));
            Controller5.selectedCat.add(new SelectOption('CHAMPAGNE','CHAMPAGNE'));
            Controller5.selectedBrand.add(new SelectOption('PERRIER BRUT','PERRIER BRUT'));
            Controller5.planDesde.M_s_de_Ref_rencia__c = null; 
            Controller5.planDesde.Ano_de_Referencia__c = null; 
            Controller5.planHasta.M_s_de_Ref_rencia__c = null;
            Controller5.planHasta.Ano_de_Referencia__c = null;
            Controller5.Ejecutar();
            
            LAT_BR_VFC03_CompetitiveProduct Controller6 = new LAT_BR_VFC03_CompetitiveProduct();
            Controller6.selectedRegional.add(new SelectOption('Brasil','Brasil'));
            Controller6.selectedSegmentacion.add(new SelectOption('Leading','Leading'));
            Controller6.selectedCat.add(new SelectOption('CHAMPAGNE','CHAMPAGNE'));
            Controller6.selectedBrand.add(new SelectOption('PERRIER BRUT','PERRIER BRUT'));
            Controller6.planDesde.M_s_de_Ref_rencia__c = 'Dezembro'; 
            Controller6.planDesde.Ano_de_Referencia__c = '2013'; 
            Controller6.planHasta.M_s_de_Ref_rencia__c = 'Janeiro';
            Controller6.planHasta.Ano_de_Referencia__c = '2013';
            Controller6.Ejecutar();
            
            LAT_BR_VFC03_CompetitiveProduct Controller7 = new LAT_BR_VFC03_CompetitiveProduct();
            Controller7.selectedRegional.add(new SelectOption('Brasil','Brasil'));
            Controller7.selectedSegmentacion.add(new SelectOption('Leading','Leading'));
            Controller7.selectedCat.add(new SelectOption('CHAMPAGNE','CHAMPAGNE'));
            Controller7.selectedBrand.add(new SelectOption('PERRIER BRUT','PERRIER BRUT'));
            Controller7.planDesde.M_s_de_Ref_rencia__c = 'Janeiro';
            Controller7.planDesde.Ano_de_Referencia__c = '2013'; 
            Controller7.planHasta.M_s_de_Ref_rencia__c = 'Dezembro';
            Controller7.planHasta.Ano_de_Referencia__c = '2015';
            Controller7.Ejecutar();
            
            LAT_BR_VFC03_CompetitiveProduct Controller8 = new LAT_BR_VFC03_CompetitiveProduct();
            Controller8.selectedRegional.add(new SelectOption('Brasil','Brasil'));
            Controller8.selectedSegmentacion.add(new SelectOption('Leading','Leading'));
            Controller8.selectedCat.add(new SelectOption('CHAMPAGNE','CHAMPAGNE'));
            Controller8.selectedBrand.add(new SelectOption('PERRIER BRUT','PERRIER BRUT'));
            Controller8.planDesde.M_s_de_Ref_rencia__c = 'Janeiro'; 
            Controller8.planDesde.Ano_de_Referencia__c = '2013'; 
            Controller8.planHasta.M_s_de_Ref_rencia__c = 'Dezembro';
            Controller8.planHasta.Ano_de_Referencia__c = '2013';
            Controller8.rightOptionsHidden = 'Chivas,,,Test1';
            Controller8.leftOptionsHidden = 'Chivas2,,,Test2';
            Controller8.doAddCategory();
            Controller8.doRemoveCategory();
            Controller8.Ejecutar();
            Controller8.doExportExcel();
            Controller8.doExportPDF();
            controller.getColorTab();
        
        test.stopTest();
    }
    //MIGRATED 21/11/2016
    static testMethod void UnitTestB() {
        Utils.setMigrationDoneTest(true); 
        
        Map <integer, string> monthsByNum = new Map <integer, string>{1 => 'Janeiro', 2 => 'Fevereiro', 3 => 'Março', 4 => 'Abril', 5 => 'Maio', 6 => 'Junho', 7 => 'Julho', 8 => 'Agosto', 9 => 'Setembro', 10 => 'Outubro', 11 => 'Novembro', 12 => 'Dezembro'};
        String rtOffBrAcc = Global_RecordTypeCache.getRtId('Account' + 'On_Trade');
        String rtOffBrPlan = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard');
        String rtOffBrVis = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard');
        String rtOffBrCheck = Global_RecordTypeCache.getRtId('Checklist_de_visita__c' + 'On_Trade');
        String rtOffBrProd2 = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard');
        
        Account acc = new Account(
            CNPJ__c = '54651716001150',
            Channel__c = 'On Trade',
            RecordTypeId = rtOffBrAcc,
            Name = 'testAccount',
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
            Billing_Country__c ='test',
            LAT_BR_RegionalClientOnPremise__c = 'REG NE',
            Rating_segmentation_targert_market__c = 'Leading'
        );
        insert acc;
        
        
        User usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert usuario; 
        
  

        test.startTest();
        Utils.setMigrationDoneTest(true); 
            Planejamento__c plan = new Planejamento__c(Name = 'Test0', Ano_de_Referencia__c = '2013', M_s_de_Ref_rencia__c = 'Dezembro', Solicitar_aprova_o_para__c = 'Planejamento semana 2', Aprovado_semana_1__c = true, OwnerId = usuario.id, RecordTypeId = rtOffBrPlan );
            insert plan;
            
            Visitas__c vis = new Visitas__c(Name = 'testVis', Planejamento__c = plan.id, Hora_da_Visita__c = '01:00', Data_da_Visita__c = date.today().addDays(-3), Resumo_da_Visita__c = '123', Status__c = 'Planejada', Conta__c =acc.id, RecordTypeId = rtOffBrVis, Tipo_de_Visita__c = 'Execução');
            insert vis;
            
            Checklist_de_visita__c cdvTest = new Checklist_de_visita__c(Visita__c = vis.Id, LAT_BR_ValidOnTradeCheckList__c = true, RecordTypeId =rtOffBrCheck, Tempo_Gasto_no_Cliente_Minutos__c = 11, Motivo_de_nao_visitar__c = 'Outros...', Outros_Motivos__c = 'asd');
            insert cdvTest; 
            
            LAT_Product__c prod2 = new LAT_Product__c(Name = 'CHAMPAGNE', LAT_BR_BrandGrouping__c = 'PERRIER BRUT', LAT_BR_CategoryGrouping__c = 'CHAMPAGNE', LAT_CDUnit__c ='CA', LAT_ExternalId__c ='83802', RecordTypeId= rtOffBrProd2);
            insert prod2;
            
            LAT_Product__c prod3 = new LAT_Product__c(Name = 'CHAMPAGNE2', LAT_BR_BrandGrouping__c = 'PERRIER BRUT2', LAT_BR_CategoryGrouping__c = 'CHAMPAGNE', LAT_CDUnit__c ='CA', LAT_ExternalId__c ='83803', RecordTypeId= rtOffBrProd2);
            insert prod3;
            
            Produto_Concorr_ncia__c prod = new Produto_Concorr_ncia__c(Qtde_de_Caixas_Estoque__c= 10, Nao_se_aplica__c= true, LAT_Product__c = prod2.id, Checklist_de_visita__c = cdvTest.id); 
            insert prod;
            
            Produto_Concorr_ncia__c prod1 = new Produto_Concorr_ncia__c(Qtde_de_Caixas_Estoque__c= 10, Nao_se_aplica__c= true, LAT_Product__c = prod3.id, Checklist_de_visita__c = cdvTest.id); 
            insert prod1;
            
            LAT_BR_VFC03_CompetitiveProduct Controller0 = new LAT_BR_VFC03_CompetitiveProduct();
            
            LAT_CRP_Custom_Report__c crp = new LAT_CRP_Custom_Report__c(LAT_ReportName__c = 'TestR', LAT_VisualForceName__c = 'LAT_BR_VFP03_CompetitiveProduct');
            insert crp;
            ApexPages.currentPage().getParameters().put('IdRep', crp.Id); 
            
            LAT_BR_CS001_Segmentacion__c cs = new LAT_BR_CS001_Segmentacion__c(Name='Leading');
            insert cs;
        
            LAT_BR_VFC03_CompetitiveProduct Controller = new LAT_BR_VFC03_CompetitiveProduct();
            Controller.Ejecutar();
            
            LAT_BR_VFC03_CompetitiveProduct Controller1 = new LAT_BR_VFC03_CompetitiveProduct();
            Controller1.selectedRegional.add(new SelectOption('Brasil','Brasil'));
            Controller1.Ejecutar();
            
            LAT_BR_VFC03_CompetitiveProduct Controller2 = new LAT_BR_VFC03_CompetitiveProduct();
            Controller2.selectedRegional.add(new SelectOption('Brasil','Brasil'));
            Controller2.selectedSegmentacion.add(new SelectOption('Leading','Leading'));
            Controller2.Ejecutar();
            
            LAT_BR_VFC03_CompetitiveProduct Controller3 = new LAT_BR_VFC03_CompetitiveProduct();
            Controller3.selectedRegional.add(new SelectOption('Brasil','Brasil'));
            Controller3.selectedSegmentacion.add(new SelectOption('Leading','Leading'));
            Controller3.selectedCat.add(new SelectOption('CHAMPAGNE','CHAMPAGNE'));
            Controller3.Ejecutar();
            
            LAT_BR_VFC03_CompetitiveProduct Controller4 = new LAT_BR_VFC03_CompetitiveProduct();
            Controller4.selectedRegional.add(new SelectOption('Brasil','Brasil'));
            Controller4.selectedSegmentacion.add(new SelectOption('Leading','Leading'));
            Controller4.selectedCat.add(new SelectOption('CHAMPAGNE','CHAMPAGNE'));
            Controller4.selectedBrand.add(new SelectOption('PERRIER BRUT','PERRIER BRUT'));
            Controller4.Ejecutar();
            
            LAT_BR_VFC03_CompetitiveProduct Controller5 = new LAT_BR_VFC03_CompetitiveProduct();
            Controller5.selectedRegional.add(new SelectOption('Brasil','Brasil'));
            Controller5.selectedSegmentacion.add(new SelectOption('Leading','Leading'));
            Controller5.selectedCat.add(new SelectOption('CHAMPAGNE','CHAMPAGNE'));
            Controller5.selectedBrand.add(new SelectOption('PERRIER BRUT','PERRIER BRUT'));
            Controller5.planDesde.M_s_de_Ref_rencia__c = null; 
            Controller5.planDesde.Ano_de_Referencia__c = null; 
            Controller5.planHasta.M_s_de_Ref_rencia__c = null;
            Controller5.planHasta.Ano_de_Referencia__c = null;
            Controller5.Ejecutar();
            
            LAT_BR_VFC03_CompetitiveProduct Controller6 = new LAT_BR_VFC03_CompetitiveProduct();
            Controller6.selectedRegional.add(new SelectOption('Brasil','Brasil'));
            Controller6.selectedSegmentacion.add(new SelectOption('Leading','Leading'));
            Controller6.selectedCat.add(new SelectOption('CHAMPAGNE','CHAMPAGNE'));
            Controller6.selectedBrand.add(new SelectOption('PERRIER BRUT','PERRIER BRUT'));
            Controller6.planDesde.M_s_de_Ref_rencia__c = 'Dezembro'; 
            Controller6.planDesde.Ano_de_Referencia__c = '2013'; 
            Controller6.planHasta.M_s_de_Ref_rencia__c = 'Janeiro';
            Controller6.planHasta.Ano_de_Referencia__c = '2013';
            Controller6.Ejecutar();
            
            LAT_BR_VFC03_CompetitiveProduct Controller7 = new LAT_BR_VFC03_CompetitiveProduct();
            Controller7.selectedRegional.add(new SelectOption('Brasil','Brasil'));
            Controller7.selectedSegmentacion.add(new SelectOption('Leading','Leading'));
            Controller7.selectedCat.add(new SelectOption('CHAMPAGNE','CHAMPAGNE'));
            Controller7.selectedBrand.add(new SelectOption('PERRIER BRUT','PERRIER BRUT'));
            Controller7.planDesde.M_s_de_Ref_rencia__c = 'Janeiro';
            Controller7.planDesde.Ano_de_Referencia__c = '2013'; 
            Controller7.planHasta.M_s_de_Ref_rencia__c = 'Dezembro';
            Controller7.planHasta.Ano_de_Referencia__c = '2015';
            Controller7.Ejecutar();
            
            LAT_BR_VFC03_CompetitiveProduct Controller8 = new LAT_BR_VFC03_CompetitiveProduct();
            Controller8.selectedRegional.add(new SelectOption('Brasil','Brasil'));
            Controller8.selectedSegmentacion.add(new SelectOption('Leading','Leading'));
            Controller8.selectedCat.add(new SelectOption('CHAMPAGNE','CHAMPAGNE'));
            Controller8.selectedBrand.add(new SelectOption('PERRIER BRUT','PERRIER BRUT'));
            Controller8.planDesde.M_s_de_Ref_rencia__c = 'Janeiro'; 
            Controller8.planDesde.Ano_de_Referencia__c = '2013'; 
            Controller8.planHasta.M_s_de_Ref_rencia__c = 'Dezembro';
            Controller8.planHasta.Ano_de_Referencia__c = '2013';
            Controller8.rightOptionsHidden = 'Chivas,,,Test1';
            Controller8.leftOptionsHidden = 'Chivas2,,,Test2';
            Controller8.doAddCategory();
            Controller8.doRemoveCategory();
            Controller8.Ejecutar();
            Controller8.doExportExcel();
            Controller8.doExportPDF();
            controller.getColorTab();
        
        test.stopTest();
    }

}