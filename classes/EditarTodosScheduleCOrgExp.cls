/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* 
* NAME: EditarTodosScheduleCOrgExp.CLS
* AUTHOR: ROGÉRIO ALVARENGA                       DATE: 
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                         DATE: 14/01/2013 
********************************************************************************/
public with sharing class EditarTodosScheduleCOrgExp {
  
  public List< Checklist_Exposicao__c > expOrg{get;set;}
  
  public EditarTodosScheduleCOrgExp( ApexPages.StandardSetController controller )
  {
  	Id idRecTypeCheckE = RecordTypeForTest.getRecType( 'Checklist_Exposicao__c' , 'BRA_Standard' );
  	
    expOrg = ( List< Checklist_Exposicao__c > )controller.getSelected();
    List< String > lListIds = new List< String >();
    for ( Checklist_Exposicao__c lExp : expOrg )
      lListIds.add( lExp.id );
    expOrg = [ SELECT Schedule_C__c, OK__c, Comentarios__c
              FROM Checklist_Exposicao__c WHERE id=:lListIds 
              AND RecordTypeId =: idRecTypeCheckE Order by Schedule_C__c ];
  }
  
  public PageReference save() 
  {
    update expOrg;
    return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
  }

}