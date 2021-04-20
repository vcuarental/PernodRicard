/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* QUANDO É INICIADO UM NOVO ANO FISCAL É GERADO UMA DEMANDA PARA INSERIR TIPO 
* DE VERBA.
*
* NAME: SchedulerContratoGerarDemanda.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 01/10/2012
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 17/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
*
********************************************************************************/

global class SchedulerContratoGerarDemanda implements Schedulable {
	
	/** 
        Código para agendar via execute anonymous.
        SchedulerContratoGerarDemanda sch = new SchedulerContratoGerarDemanda();
        String cron = '0 30 0 1 7 ?';
        System.schedule('SchedulerContratoGerarDemanda', cron, sch);
    */ 
    
    public static String CRON_EXP = '0 30 0 1 7 ?';
    
    //MIGRATED 02/11/2016 
    global void execute( SchedulableContext sc )
    {
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
        
        //MIGRATED 02/11/2016
        if(!Utils.wasMigrationDone('1')){
        	List< LAT_Contract__c > lListContract = [ SELECT id FROM LAT_Contract__c 
        	       WHERE status__c = 'Ativo' AND RecordTypeId =: setRecTypeLatCon ];
        	if ( lListContract.size() == 0 ) return;
        	
        	List< String > lListContractID = new List< String >();
        	for ( LAT_Contract__c c : lListContract )
        	  lListContractID.add( c.id );
        	
        	if ( lListContractID.size() == 0 ) return;
        	
    			Integer lStartMonth = [select FiscalYearStartMonth from Organization 
    			 where id=:Userinfo.getOrganizationId()].FiscalYearStartMonth;
    		  
    		  integer lAnoFiscal = system.today().year();
    		  if ( system.today().month() >= lStartMonth ) lAnoFiscal++;
    		  
        	List< Case > lListCase = new List< Case >();
        	String lRecTypeTVB = RecordTypeForTest.getRecType( 'Case', 'Inserir_o_Tipo_de_Verba' );
        	
        	Id idRecTypeAgr = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
        	
        	List< Agrupamento_Fiscal_Year__c > lListAgrpFiscalYear = [ SELECT LAT_Contract__c,id, LAT_Contract__r.account__c,
        	           LAT_Contract__r.Ownerid,LAT_Contract__r.Finalidades_Acoes__c
        	           FROM Agrupamento_Fiscal_Year__c 
                     WHERE LAT_Contract__c =:lListContractID 
                     AND Ano_fiscal_calculadoag__c =: String.valueOf( lAnoFiscal ) 
                     AND RecordTypeId =: idRecTypeAgr ];
         
         List<String> lStringList = new List<String>();
         for( Agrupamento_Fiscal_Year__c agy : lListAgrpFiscalYear){
         	 lStringList.add( agy.LAT_Contract__r.ownerid );
         }
         
         List<User> listaGerenteArea = [SELECT Gerente_de_area__c, Gerente_regional__c 
                                               FROM User WHERE id =: lStringList];
      
         Map< String, User > gerenteAreaMap = new Map< String, User >();
         
         for ( User user : listaGerenteArea ){
            gerenteAreaMap.put(user.id,user);          
         }
              
         for ( Agrupamento_Fiscal_Year__c lAgr : lListAgrpFiscalYear ){
        		 
        		Case lDemanda = new Case();
    	      lDemanda.RecordTypeId = lRecTypeTVB;
    	      lDemanda.AccountId = lAgr.LAT_Contract__r.account__c;
    	      User lUser = gerenteAreaMap.get(lAgr.LAT_Contract__r.Ownerid);
            if ( lUser != null )
    		      if ( lUser.Gerente_de_area__c != null ) lDemanda.OwnerId = lUser.Gerente_de_area__c;
    		      else lDemanda.OwnerId = lUser.Gerente_regional__c;
              if(Test.isRunningTest()){
                    lDemanda.OwnerId = UserInfo.getUserId();
                }	
    	      lDemanda.Subject = 'Inserir Tipo de Verba';
    	      lDemanda.Status = 'Análise pendente';
    	      lDemanda.Priority = 'Médio';
    	      lDemanda.Origin = 'Demanda Interna PRB';
    	      lDemanda.LAT_Contract__c = lAgr.LAT_Contract__c;
    	      lDemanda.Purposes_Action__c = lAgr.LAT_Contract__r.Finalidades_Acoes__c;
    	      lDemanda.Grouping_Fiscal_Year__c = lAgr.id;
    	      lListCase.add( lDemanda );
        	} 
        	
        	if ( lListCase.size() > 0 ) insert lListCase;
        }else{
            List< LAT_Contract__c > lListContract = [ SELECT id FROM LAT_Contract__c 
                   WHERE status__c = 'Ativo' AND RecordTypeId =: setRecTypeLatCon ];
            if ( lListContract.size() == 0 ) return;
            
            List< String > lListContractID = new List< String >();
            for ( LAT_Contract__c c : lListContract )
              lListContractID.add( c.id );
            
            if ( lListContractID.size() == 0 ) return;
            
                Integer lStartMonth = [select FiscalYearStartMonth from Organization 
                 where id=:Userinfo.getOrganizationId()].FiscalYearStartMonth;
              
              integer lAnoFiscal = system.today().year();
              if ( system.today().month() >= lStartMonth ) lAnoFiscal++;
              
            List< LAT_Case__c > lListCase = new List< LAT_Case__c >();
            String lRecTypeTVB = RecordTypeForTest.getRecType( 'LAT_Case__c', 'Inserir_o_Tipo_de_Verba' );
            
            Id idRecTypeAgr = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
            
            List< Agrupamento_Fiscal_Year__c > lListAgrpFiscalYear = [ SELECT LAT_Contract__c,id, LAT_Contract__r.account__c,
                       LAT_Contract__r.Ownerid,LAT_Contract__r.Finalidades_Acoes__c
                       FROM Agrupamento_Fiscal_Year__c 
                     WHERE LAT_Contract__c =:lListContractID 
                     AND Ano_fiscal_calculadoag__c =: String.valueOf( lAnoFiscal ) 
                     AND RecordTypeId =: idRecTypeAgr ];
         
            List<String> lStringList = new List<String>();
            for( Agrupamento_Fiscal_Year__c agy : lListAgrpFiscalYear){
                lStringList.add( agy.LAT_Contract__r.ownerid );
            }
             
            List<User> listaGerenteArea = [SELECT Gerente_de_area__c, Gerente_regional__c 
                                                   FROM User WHERE id =: lStringList];
          
            Map< String, User > gerenteAreaMap = new Map< String, User >();
             
            for ( User user : listaGerenteArea ){
                gerenteAreaMap.put(user.id,user);          
            }
                  
            for ( Agrupamento_Fiscal_Year__c lAgr : lListAgrpFiscalYear ){
                     
                LAT_Case__c lDemanda = new LAT_Case__c();
                lDemanda.RecordTypeId = lRecTypeTVB;
                lDemanda.LAT_Account__c = lAgr.LAT_Contract__r.account__c;
                User lUser = gerenteAreaMap.get(lAgr.LAT_Contract__r.Ownerid);
                if ( lUser != null )
                      if ( lUser.Gerente_de_area__c != null ) lDemanda.OwnerId = lUser.Gerente_de_area__c;
                      else lDemanda.OwnerId = lUser.Gerente_regional__c;
                if(Test.isRunningTest()){
                    lDemanda.OwnerId = UserInfo.getUserId();
                }	
                  lDemanda.LAT_Subject__c = 'Inserir Tipo de Verba';
                  lDemanda.LAT_Status__c = 'Análise pendente';
                  lDemanda.LAT_Priority__c = 'Médio';
                  lDemanda.LAT_Origin__c = 'Demanda Interna PRB';
                  lDemanda.LAT_Contract__c = lAgr.LAT_Contract__c;
                  lDemanda.LAT_PurposesAction__c = lAgr.LAT_Contract__r.Finalidades_Acoes__c;
                  lDemanda.LAT_GroupingFiscalYear__c = lAgr.id;
                  lListCase.add( lDemanda );
            } 
                
            if ( lListCase.size() > 0 ) insert lListCase;
        }    
    }
}