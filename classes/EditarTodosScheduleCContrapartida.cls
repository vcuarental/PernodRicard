/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* 
* NAME: EditarTodosScheduleCContrapartida.cls
* AUTHOR: ROGÉRIO ALVARENGA                       DATE: 
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                         DATE: 10/01/2013 
********************************************************************************/
public  class EditarTodosScheduleCContrapartida {
  
  List< Checklist__c > fObjs;
  public boolean isOnTrace{get;set;}
  private Id idRecTypeCheck = RecordTypeForTest.getRecType( 'Checklist__c', 'BRA_Standard' );
  
  public EditarTodosScheduleCContrapartida( ApexPages.StandardSetController controller )
  {
    fObjs = ( List< Checklist__c > )controller.getSelected();
    List< String > lListIds = new List< String >();
    for ( Checklist__c lCheck : fObjs )
      lListIds.add( lCheck.id );
    fObjs = [ Select Schedule_C__c, OK__c, Comentarios__c, Secao_Contrapartidas__c, Checklist_de_visita__r.RecordTypeId
              from Checklist__c Where id=:lListIds AND RecordTypeId =: idRecTypeCheck 
              Order by Secao_Contrapartidas__c, Schedule_C__c ];
    String lOnTradeId = RecordTypeForTest.getRecType( 'Checklist_de_visita__c', 'On_Trade' );
    isOnTrace = fObjs.size() > 0 && fObjs[ 0 ].Checklist_de_visita__r.RecordTypeId == lOnTradeId;
  }
  
  private List< Checklist__c > getInternalContrapartida( String aSection )
  {
    List< Checklist__c > lResult = new List< Checklist__c >();
    for ( Checklist__c lCheck : fObjs )
    {
      if ( lCheck.Secao_Contrapartidas__c.equalsIgnoreCase( aSection ) )
        lResult.add( lCheck );
    }
    return lResult;
  }
  
  public List< Checklist__c > getContrapartida()
    {
      return getInternalContrapartida( ChecklistVisitaCria.secao_contrapartida[ 1 ] );
    }
  
  public List< Checklist__c > getPotifolio()
  {
    return getInternalContrapartida( ChecklistVisitaCria.secao_contrapartida[ 2 ] );
  }
  
  public List< Checklist__c > getVisibilidade()
  {
    return getInternalContrapartida( ChecklistVisitaCria.secao_contrapartida[ 3 ] );
  }
  
  public List< Checklist__c > getAcordo()
  {
    return getInternalContrapartida( ChecklistVisitaCria.secao_contrapartida[ 4 ] );
  }
  
  public List< Checklist__c > getDetalhamento()
  {
    List< Checklist__c > lList = getInternalContrapartida( ChecklistVisitaCria.secao_contrapartida[ 5 ] );
    if ( lList != null )
    {
      Integer lLen = lList.size();
      for( integer i=0; i<lLen; i++ )
        if ( lList[ i ].Schedule_C__c.indexOf( 'Quantidade' ) > 0 )
        {
          if ( lLen >= 2 ) lList.add( 0, lList.remove( i ) );
          break;
        }
    }
    return lList;
  }
  
  public PageReference save() 
  {
    update fObjs;
    return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
  }

}