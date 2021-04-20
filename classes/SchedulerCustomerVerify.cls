/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Scheduler que recupera as informações do cliente
* NAME: SchedulerCustomerVerify.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 26/06/2012
*
*-------------------------------------------------------------------------------
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 17/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
global class SchedulerCustomerVerify implements Schedulable  {
	
  /* 
    Código para testar via execute anonymous.
    SchedulerCustomerVerify sch = new SchedulerCustomerVerify();
    String cron = '0 0 11/2 * * ?';
    System.schedule('SchedulerCustomerVerify', cron, sch);
  */
  
  public static String CRON_EXP = '0 0 11/2 * * ?';
  private Set< Id > setRecTypeAcc = getIds();
  
  private Set< Id > getIds(){
    Set< Id > lSet = new Set< Id >();
    lSet.add( RecordTypeForTest.getRecType( 'Account', 'Eventos'));
    lSet.add( RecordTypeForTest.getRecType( 'Account', 'Off_Trade'));
    lSet.add( RecordTypeForTest.getRecType( 'Account', 'On_Trade'));
    return lSet;
  }
  
  global void execute(SchedulableContext sc)
  {
  	
    List< Account > lListOpp = [ SELECT id FROM Account 
        WHERE Status__c = 'Aprovado - Aguardando retorno do JDE' AND RecordTypeId =: setRecTypeAcc ];
    if ( lListOpp.size() > 0 )
      for ( Account lOpp : lListOpp )
        CustomerVerifyInterface.CustomerVerifyInterfaceJDE( lOpp.id );
    
  }
}