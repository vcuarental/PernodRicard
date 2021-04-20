/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz o teste de cobertura da classe ContractManagerInterface
* NAME: ContractManagerInterfaceTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 25/09/2012
*
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 09/01/2013 
*******************************************************************************/

@isTest(seeAllData=true)
private class ContractManagerInterfaceTest {

    static testMethod void myUnitTest() 
    {
        /*
        //Recupera os Ids dos tipos de registro do objeto LAT_Contract__c
        Set< Id > setRecTypeLatCon = new Set< Id >();
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOffTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOnTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_aprovado'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_aprovada'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_off'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_on'));
        
      List< LAT_Contract__c > lContract = [ SELECT Id FROM LAT_Contract__c 
            WHERE status__c = 'Ativo' AND Account__r.Channel__c = 'Off Trade' 
            AND RecordTypeId =: setRecTypeLatCon limit 1 ];*/
            
      
                           
        //Cria novo usuario.
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');                                                       
        insert usuario;
        
        //Cria nova UDC.      
            UDC__c regional = new UDC__c();      
            regional.CodDefUsuario__c = '1';      
            regional.CodProd__c     = '01';      
            regional.CodUs__c     = '01';      
            regional.Internal_Id__c   = '01-01';      
            regional.RecordTypeId = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );      
            insert regional;   
            regional.CodDefUsuario__c = '2'; 
            update regional;
            
      Account Acc = new Account();      
            Acc.Name = 'ProdutoOppVerificaCotaExistenteTeste';      
            Acc.CNPJ__c = '48843971000120';      
            Acc.Type = 'Outros';      
            Acc.RecordTypeId = RecordTypeForTest.getRecType('Account','Off_Trade');      
            Acc.Status__c = 'Cliente cadastrado no JDE';      
            Acc.Agency__c = '000';      
            Acc.Current_account__c = '0';      
            Acc.Corporate_Name__c = 'Teste';      
            Acc.Channel__c = 'Off Trade';      
            Acc.Regional__c = regional.Id;      
            Acc.Frequency_of_Visits__c = 'Semanal';     
            Acc.Client_code_AN8__c = '557798';      
            Acc.Price_Group__c = '1';      
            insert Acc;
            
            LAT_Contract__c Lc = new LAT_Contract__c();        
            Lc.OwnerId = usuario.Id;        
            Lc.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo');
            Lc.Account__c = Acc.Id; 
            Lc.Fase__c = 'Estudo';       
            Lc.Status__c = 'Em elaboração';        
            Lc.ROI_Comentarios_Negativo__c = 'Teste';        
            Lc.StartDate__c = System.today();        
            Lc.Gerente_Regional__c = Usuario.Id;
            Lc.Gerente__c = Usuario.Id;
            Lc.Gerente_de_area__c = Usuario.Id;
            Lc.StartDate__c = system.today();
            Lc.ContractTerm__c = 1;
            insert Lc;
            
            Cl_usulas_do_Contrato__c lClausula = new Cl_usulas_do_Contrato__c();
            lClausula.Contrato__c = Lc.Id;
      lClausula.RecordTypeId = RecordTypeForTest.getRecType('Cl_usulas_do_Contrato__c', 'Clausulas_do_Contrato');
            insert lClausula;
            
          Distribui_o_de_Valores__c lDis = new Distribui_o_de_Valores__c();
        lDis.Clausulas_do_Contrato__c = lClausula.ID;
        lDis.Data_de_Referencia_para_Apuracao__c = Lc.StartDate__c.addDays( 5 );
        lDis.RecordTypeId = RecordTypeForTest.getRecType('Distribui_o_de_Valores__c', 'BRA_Standard');
        insert lDis;
            
      ContractManagerInterface.ContractManagerInvoke( Lc.id );
    }
    
    static testMethod void myUnitTest2()
    {
      ContractManager.WBSCTR_Execute_element le = new ContractManager.WBSCTR_Execute_element();
      le.Cavapvrpv = system.today();
      le.Cavhieobr = '';
      le.Cavmotrpv = '';
      le.Cavusrapv = '';
      le.Ctraltdat = System.now();
      le.Ctraltusr = '';
      le.Ctran8cod = 0;
      le.Ctrbancod = '';
      le.Ctremiusr = '';
      le.Ctrfimvig = system.today();
      le.Ctrinivig = system.today();
      le.Ctrnroctr = 0;
      le.Ctrorgcod = '';
      le.Ctrpgttip = '';
      le.Ctrsolusr = '';
      le.Empcod = 0;
      le.Idcrm = '';
      le.Idcrmorig = '';
      le.Paicod = 0;
      
      ContractManager.SDTCTR_ClausulaItem_Valor lc = new ContractManager.SDTCTR_ClausulaItem_Valor();
      lc.VmcFscAno = 0;
      lc.VmcVal = 0;
      lc.VmcValAno = 0;
      lc.VmcValMes = 0;
      
      ContractManager.ArrayOfSDTCTR_DocumentoItem ld = new ContractManager.ArrayOfSDTCTR_DocumentoItem();
      ld.SDTCTR_DocumentoItem = new List< ContractManager.SDTCTR_DocumentoItem >();
      
      ContractManager.ArrayOfSDTCTR_ClausulaItem_Valor lv = new ContractManager.ArrayOfSDTCTR_ClausulaItem_Valor();
      lv.SDTCTR_ClausulaItem_Valor = new List< ContractManager.SDTCTR_ClausulaItem_Valor >();
    }
}