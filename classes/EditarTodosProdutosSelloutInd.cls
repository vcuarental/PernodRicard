/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Edita todos os produtos de sellout.
* NAME: EditarTodosProdutosSelloutInd.CLS
* AUTHOR: ROGÉRIO ALVARENGA                       DATE: 
*
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                         DATE: 14/01/2013 
********************************************************************************/
public with sharing class EditarTodosProdutosSelloutInd {
  
  public List< Posicao_Sellout__c > sellout{get;set;}
  public Checklist_de_visita__c checkList{get;set;}
  private Id idRecTypeSO = RecordTypeForTest.getRecType( 'Posicao_Sellout__c', 'BRA_Standard' );
  
  public EditarTodosProdutosSelloutInd( ApexPages.StandardSetController controller )
    {
      sellout = ( List< Posicao_Sellout__c > )controller.getSelected();
      List< String > lListIds = new List< String >();
      for ( Posicao_Sellout__c lSell : sellout )
        lListIds.add( lSell.id );
      sellout = [ Select Produto2__c, QT_Sell_in__c, QT_Sell_out__c, QT_Estoque__c, Nao_se_aplica__c,
                Checklist_de_visita__c from Posicao_Sellout__c Where id=:lListIds 
                AND RecordTypeId =: idRecTypeSO Order by Produto2__c ];
      //dataColeta = System.today();
      if ( sellout.size() > 0 )
      {
        Id lCheckList = sellout[ 0 ].Checklist_de_visita__c;
        checkList = [ select Data_da_Coleta__c from Checklist_de_visita__c where id=:lCheckList ];
        if ( checkList.Data_da_Coleta__c == null ) checkList.Data_da_Coleta__c = system.today();
      }
    }
  
  public PageReference save() 
  {
    update sellout;
    if ( checkList != null ) update checkList;
    return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
  }
  
}