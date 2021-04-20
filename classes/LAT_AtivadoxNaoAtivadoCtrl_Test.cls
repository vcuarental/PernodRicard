@isTest
private class LAT_AtivadoxNaoAtivadoCtrl_Test {
	
	static testMethod void unitTest(){
                 
        
        LAT_CRP_Custom_Report__c crp = new LAT_CRP_Custom_Report__c(
            LAT_VisualForceName__c = 'LAT_BR_VFP07_PositivizationOfPDV'
        );
        insert crp;
        
        Product2 prod = new Product2(
            Name = 'testProd',
            LAT_BR_BrandGrouping__c = 'TestBrand',
            LAT_BR_CategoryGrouping__c='TestCategory',
            LAT_IsRefactorProduct__c = 'Y',
            RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard')
        );
        insert prod;
        
        Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            CNPJ__c = '02745728000178',
            Name = 'test',
            Overdue__c = true,
            Type = 'Outros',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Indireto',
            Channel__c = 'On Trade',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            LAT_BR_RegionalClientOnPremise__c = 'REG CO',
            Status__c = 'Cliente cadastrado no JDE'
        );
        insert acc;
        
        map<integer, string> monthsByNum = new Map <integer, string>{1 => 'Janeiro', 2 => 'Fevereiro', 3 => 'Março', 4 => 'Abril', 5 => 'Maio', 6 => 'Junho', 7 => 'Julho', 8 => 'Agosto', 9 => 'Setembro', 10 => 'Outubro', 11 => 'Novembro', 12 => 'Dezembro'};
        Planejamento__c planejamento = new Planejamento__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard'),
            Name = 'test planejamento',
            M_s_de_Ref_rencia__c = monthsByNum.get(date.today().month()),
            Ano_de_Referencia__c = String.ValueOf(date.today().year())
        );
        insert planejamento;
        
        Visitas__c visita = new Visitas__c(
            Name = 'test visita',
            Planejamento__c = planejamento.Id,
            Conta__c = acc.Id,
            Tipo_de_Visita__c = 'Execução',
            Hora_da_Visita__c = '10:00',
            Resumo_da_Visita__c = 'This is a test',
            Data_da_Visita__c = Date.today().addDays(2),
            RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard')
        );
        insert visita;       
        
        //Checklist para que sume en Ativado
        Checklist_de_visita__c cdvAtivado = new Checklist_de_visita__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Checklist_de_visita__c' + 'On_Trade'),
            Visita__c = visita.Id,
            LAT_BR_ValidOnTradeCheckList__c = true,
            LAT_BR_ValidOnTradeChecklistGE__c = true
        );
        insert cdvAtivado;        

        test.startTest();
        Utils.setMigrationDoneTest(false);

          LAT_KeyBrand__c keyBrand = new LAT_KeyBrand__c();
     		    keyBrand.Name = 'Testing Brand';
    	insert keyBrand;
        
        LAT_Produto_POP__c prodPop = new LAT_Produto_POP__c();
        prodPop.Sku__c = '12';
        prodPop.name = 'ABC';
        prodPop.Evidence__c = true;
        prodPop.Parent_Product__c = 'ABC';
        prodPop.Inventory__c = false;
        prodPop.Key_Brand__c = keyBrand.Id;
        insert prodPop;
        
        Gabarito_de_Execucao__c gdeAtivado = new Gabarito_de_Execucao__c(
            Checklist_de_Visita__c = cdvAtivado.Id,
            Realizada_promocao_de_marcas_na_casa__c = true,
            Frequencia_1_unica_vez__c = 'TestBrand; test'
        );

        insert gdeAtivado;

        Produto_Concorr_ncia__c ppcAtivado = new Produto_Concorr_ncia__c(
            CheckList_de_visita__c = cdvAtivado.Id,
            Produto_PERNOD__c = prod.Id,
            Qtde_de_Caixas_Estoque__c = 5
            
        );
        insert ppcAtivado;

        //Ejecucion de la pagina
        ApexPages.currentPage().getParameters().put('IdRep', crp.Id);
        LAT_AtivadoxNaoAtivadoCtrl controller = new LAT_AtivadoxNaoAtivadoCtrl();
        //Agrego una categoria
        controller.leftOptionsHidden = prod.LAT_BR_CategoryGrouping__c;
        controller.doAddCategory();
        //Borro una categoria
        controller.rightOptionsHidden = prod.LAT_BR_CategoryGrouping__c;
        controller.doRemoveCategory();
        //Agrego una categoria nuevamente
        controller.leftOptionsHidden = prod.LAT_BR_CategoryGrouping__c;
        controller.doAddCategory();
        
        //Ejecuto el reporte (Por defecto el Mes desde (Hoy menos 6 meses) y Mes hasta (Hoy))
        controller.selectedRegional.add(new SelectOption(acc.LAT_BR_RegionalClientOnPremise__c, acc.LAT_BR_RegionalClientOnPremise__c));
        controller.selectedRegional.add(new SelectOption('Brasil', 'Brasil'));
        
        List<String> Regions = new List<String>{'Brasil', 'REG CO'};
        List<String> Categories = new List<String>{'Test'};
        List<String> Brands = new List<String>{'TestBrand', prod.LAT_BR_BrandGrouping__c};
        List<String> pops = new List<String>{'teste'};
        LAT_AtivadoxNaoAtivadoCtrl.doExecuteReport(Regions, Brands, pops, monthsByNum.get(Date.today().month()),String.valueOf(Date.today().addDays(2).year()),monthsByNum.get(Date.today().month()), String.valueOf(Date.today().addDays(2).year()));
  
        //Agrego una marca
        controller.selectedBrand.add(new SelectOption(prod.LAT_BR_BrandGrouping__c, prod.LAT_BR_BrandGrouping__c));
        LAT_AtivadoxNaoAtivadoCtrl.doExecuteReport(Regions, Brands, pops, monthsByNum.get(Date.today().month()),String.valueOf(Date.today().addDays(2).year()),monthsByNum.get(Date.today().month()), String.valueOf(Date.today().addDays(2).year()));
  		//LAT_AtivadoxNaoAtivadoCtrl.doExecuteFull(Regions, Brands, monthsByNum.get(Date.today().month()), String.valueOf(Date.today().year()), monthsByNum.get(Date.today().month()), String.valueOf(Date.today().year()));
        
        controller.doExportExcel();
        controller.doExportPDF();
        controller.getColorTab();
        LAT_AtivadoxNaoAtivadoCtrl.tieneEntrega(acc,Date.today());

        test.stopTest();
    }

	//MIGRATED 21/11/2016
    static testMethod void unitTestB(){
        
        LAT_CRP_Custom_Report__c crp = new LAT_CRP_Custom_Report__c(
            LAT_VisualForceName__c = 'LAT_BR_VFP07_PositivizationOfPDV'
        );
        insert crp;
        
        LAT_Product__c prod = new LAT_Product__c(
            Name = 'testProd',
            LAT_BR_BrandGrouping__c = 'TestBrand',
            LAT_BR_CategoryGrouping__c='TestCategory',
            LAT_IsRefactorProduct__c = 'Y',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard')
        );
        insert prod;
        
        Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            CNPJ__c = '02745728000178',
            Name = 'test',
            Overdue__c = true,
            Type = 'Outros',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Indireto',
            Channel__c = 'On Trade',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            LAT_BR_RegionalClientOnPremise__c = 'REG CO',
            Status__c = 'Cliente cadastrado no JDE'
        );
        insert acc;
        
        map<integer, string> monthsByNum = new Map <integer, string>{1 => 'Janeiro', 2 => 'Fevereiro', 3 => 'Março', 4 => 'Abril', 5 => 'Maio', 6 => 'Junho', 7 => 'Julho', 8 => 'Agosto', 9 => 'Setembro', 10 => 'Outubro', 11 => 'Novembro', 12 => 'Dezembro'};
        Planejamento__c planejamento = new Planejamento__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard'),
            Name = 'test planejamento',
            M_s_de_Ref_rencia__c = monthsByNum.get(date.today().month()),
            Ano_de_Referencia__c = String.ValueOf(date.today().year())
        );
        insert planejamento;
        
        Visitas__c visita = new Visitas__c(
            Name = 'test visita',
            Planejamento__c = planejamento.Id,
            Conta__c = acc.Id,
            Tipo_de_Visita__c = 'Execução',
            Hora_da_Visita__c = '10:00',
            Resumo_da_Visita__c = 'This is a test',
            Data_da_Visita__c = Date.today().addDays(2),
            RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard')
        );
        insert visita;
        
        //Checklist para que sume en Nao Ativado
        Checklist_de_visita__c cdvNaoAtivado = new Checklist_de_visita__c(
            Visita__c = visita.Id,
            LAT_BR_ValidOnTradeCheckList__c = true
        );
        //insert cdvNaoAtivado;             
        
        //Checklist para que sume en Ativado
        Checklist_de_visita__c cdvAtivado = new Checklist_de_visita__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Checklist_de_visita__c' + 'On_Trade'),
            Visita__c = visita.Id,
            LAT_BR_ValidOnTradeCheckList__c = true,
            LAT_BR_ValidOnTradeChecklistGE__c = true
        );
        //insert cdvAtivado;        
        
        insert new List<Checklist_de_visita__c>{cdvNaoAtivado,cdvAtivado};
        

        test.startTest();
        Utils.setMigrationDoneTest(true);

        LAT_KeyBrand__c keyBrand = new LAT_KeyBrand__c();
     		    keyBrand.Name = 'Testing Brand';
    	insert keyBrand;
        
        LAT_Produto_POP__c prodPop = new LAT_Produto_POP__c();
        prodPop.Sku__c = '12';
        prodPop.name = 'ABC';
        prodPop.Evidence__c = true;
        prodPop.Parent_Product__c = 'ABC';
        prodPop.Inventory__c = false;
        prodPop.Key_Brand__c = keyBrand.Id;
        insert prodPop;

        Gabarito_de_Execucao__c gdeNaoAtivado = new Gabarito_de_Execucao__c(
            CheckList_de_visita__c = cdvNaoAtivado.Id,
            Realizada_promocao_de_marcas_na_casa__c = false
        );
        //insert gdeNaoAtivado;
        
        Gabarito_de_Execucao__c gdeAtivado = new Gabarito_de_Execucao__c(
            Checklist_de_Visita__c = cdvAtivado.Id,
            Realizada_promocao_de_marcas_na_casa__c = true,
            Frequencia_1_unica_vez__c = 'TestBrand; test'
        );
        //insert gdeAtivado;

        insert new List<Gabarito_de_Execucao__c>{gdeNaoAtivado,gdeAtivado};

        Produto_Concorr_ncia__c ppcNaoAtivado = new Produto_Concorr_ncia__c(
            CheckList_de_visita__c = cdvNaoAtivado.Id,
            LAT_Product__c = prod.Id,
            Qtde_de_Caixas_Estoque__c = 5
        );
        //insert ppcNaoAtivado;
        Produto_Concorr_ncia__c ppcNaoAtivado2 = new Produto_Concorr_ncia__c(
            CheckList_de_visita__c = cdvNaoAtivado.Id,
            LAT_Product__c = prod.Id,
            Qtde_de_Caixas_Estoque__c = 5
        );
        //insert ppcNaoAtivado2;
        
        Produto_Concorr_ncia__c ppcAtivado = new Produto_Concorr_ncia__c(
            CheckList_de_visita__c = cdvAtivado.Id,
            LAT_Product__c = prod.Id,
            Qtde_de_Caixas_Estoque__c = 5
            
        );
        //insert ppcAtivado;
                
        insert new List<Produto_Concorr_ncia__c>{ppcNaoAtivado ,ppcNaoAtivado2,ppcAtivado};
        
        
        //Ejecucion de la pagina
        ApexPages.currentPage().getParameters().put('IdRep', crp.Id);
        LAT_AtivadoxNaoAtivadoCtrl controller = new LAT_AtivadoxNaoAtivadoCtrl();
        //Agrego una categoria
        controller.leftOptionsHidden = prod.LAT_BR_CategoryGrouping__c;
        controller.doAddCategory();
        //Borro una categoria
        controller.rightOptionsHidden = prod.LAT_BR_CategoryGrouping__c;
        controller.doRemoveCategory();
        //Agrego una categoria nuevamente
        controller.leftOptionsHidden = prod.LAT_BR_CategoryGrouping__c;
        controller.doAddCategory();
        
        //Ejecuto el reporte (Por defecto el Mes desde (Hoy menos 6 meses) y Mes hasta (Hoy))
        controller.selectedRegional.add(new SelectOption(acc.LAT_BR_RegionalClientOnPremise__c, acc.LAT_BR_RegionalClientOnPremise__c));
        controller.selectedRegional.add(new SelectOption('Brasil', 'Brasil'));
        
        List<String> Regions = new List<String>{'Brasil', 'REG CO'};
        List<String> Categories = new List<String>{'Test'};
        List<String> Brands = new List<String>{'TestBrand', prod.LAT_BR_BrandGrouping__c};
        List<String> pops = new List<String>{'teste'};

        LAT_AtivadoxNaoAtivadoCtrl.doExecuteReport(Regions, Brands, pops, monthsByNum.get(Date.today().month()),String.valueOf(Date.today().addDays(2).year()),monthsByNum.get(Date.today().month()), String.valueOf(Date.today().addDays(2).year()));
  
        //Agrego una marca
        controller.selectedBrand.add(new SelectOption(prod.LAT_BR_BrandGrouping__c, prod.LAT_BR_BrandGrouping__c));
        LAT_AtivadoxNaoAtivadoCtrl.doExecuteReport(Regions, Brands, pops, monthsByNum.get(Date.today().month()),String.valueOf(Date.today().addDays(2).year()),monthsByNum.get(Date.today().month()), String.valueOf(Date.today().addDays(2).year()));
  		//LAT_AtivadoxNaoAtivadoCtrl.doExecuteFull(Regions, Brands, monthsByNum.get(Date.today().month()), String.valueOf(Date.today().year()), monthsByNum.get(Date.today().month()), String.valueOf(Date.today().year()));
        
        controller.doExportExcel();
        controller.doExportPDF();
        controller.getColorTab();
        LAT_AtivadoxNaoAtivadoCtrl.tieneEntrega(acc,Date.today());

        test.stopTest();
    }
	
}