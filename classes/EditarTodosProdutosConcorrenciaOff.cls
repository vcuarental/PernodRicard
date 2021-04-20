/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* 
* NAME: EditarTodosProdutosConcorrenciaOff.Ccls
* AUTHOR: ROGÉRIO ALVARENGA                       DATE: 
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                         DATE: 10/01/2013 
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/
public with sharing class EditarTodosProdutosConcorrenciaOff{

  public List< Produto_Concorr_ncia__c > prodPRB{get;set;}
  public List< Produto_Concorr_ncia__c > prodConc{get;set;}
  private List< Produto_Concorr_ncia__c > fListProdutos;
  //private set<Id> idRecTypePC;// = RecordTypeForTest.getRecType( 'Produto_Concorr_ncia__c', 'BRA_Standard' );
  private Id idRecTypePC = RecordTypeForTest.getRecType( 'Produto_Concorr_ncia__c', 'BRA_Standard' );
  
  public EditarTodosProdutosConcorrenciaOff( ApexPages.StandardSetController controller )
  {
      if(!Utils.wasMigrationDone('1')) {   
          String idRecTypeDev;
          Id idChecklist;
          prodConc = ( List< Produto_Concorr_ncia__c > )controller.getSelected();
          List< String > lListIds = new List< String >();
          
          if(!prodConc.IsEmpty()){
              //idChecklist = [select ChecklistARG_AR__c from Produto_Concorr_ncia__c where Id =:prodConc[0].Id ].ChecklistARG_AR__c;
              //try{idRecTypeDev = [SELECT Id, Visit_AR__r.RecordType.DeveloperName FROM CLV_ChecklistVisita_ARG__c WHERE id=:idChecklist].Visit_AR__r.RecordType.DeveloperName;}catch(Exception e){}
          
              /*if(idRecTypeDev!=null){
                  idRecTypePC = new set<Id>();
                  if(idRecTypeDev=='VTS_Standard_AR'){
                      idRecTypePC.add(RecordTypeForTest.getRecType( 'Produto_Concorr_ncia__c', 'PPR_Standard_AR'));
                  }else if(idRecTypeDev=='VTS_Standard_UY'){
                      idRecTypePC.add(RecordTypeForTest.getRecType( 'Produto_Concorr_ncia__c', 'PPR_Standard_UY'));
                  }else if(idRecTypeDev=='BRA_Standard'){
                      idRecTypePC.add(RecordTypeForTest.getRecType( 'Produto_Concorr_ncia__c', 'BRA_Standard'));
                  }
              }*/
          
              for ( Produto_Concorr_ncia__c lExp : prodConc ){
                lListIds.add(lExp.id);
              }
              fListProdutos = [Select Produto_PERNOD__c, Produto_PERNOD__r.Name, Pre_o_Garrafa_Pernod__c, Qtde_de_Frentes_Pernod__c, Qtde_de_Pontos_Pernod__c, Confinado_Pernod__c, Produto_Concorrente__c, Produto_Concorrente__r.Name, Volume__c, Pre_o_garrafa_Concorrente__c, Qtde_de_Frentes_Concorrencia__c, Qtde_de_Pontos_Concorrencia__c, Confinado_Concorrente__c, Nao_se_aplica__c, Promo_o__c, Ativa_o__c FROM Produto_Concorr_ncia__c Where id=:lListIds AND RecordTypeId =: idRecTypePC Order by Produto_PERNOD__r.Name, Produto_Concorrente__r.Name];
              
              prodPRB = new List< Produto_Concorr_ncia__c >();
              prodConc = new List< Produto_Concorr_ncia__c >();
              Set< String > lSetProdPRB = new Set< String >();
              Set< String > lSetProdConc = new Set< String >();
              for ( Produto_Concorr_ncia__c lProd : fListProdutos )
              {
                if ( lProd.Produto_PERNOD__r.Name != null && lProd.Produto_PERNOD__r.Name.length() > 0 
                && !lSetProdPRB.contains( lProd.Produto_PERNOD__r.Name ) )
                {
                  lSetProdPRB.add( lProd.Produto_PERNOD__r.Name );
                  prodPRB.add( lProd );
                }
                if ( lProd.Produto_Concorrente__r.Name != null && lProd.Produto_Concorrente__r.Name.length() > 0 
                && !lSetProdConc.contains( lProd.Produto_Concorrente__r.Name ) )
                {
                  lSetProdConc.add( lProd.Produto_Concorrente__r.Name );
                  prodConc.add( lProd );
                }
              }
          }
      }
      //MIGRATED 17/11/2016
      else {
          String idRecTypeDev;
          Id idChecklist;
          prodConc = ( List< Produto_Concorr_ncia__c > )controller.getSelected();
          List< String > lListIds = new List< String >();
          
          if(!prodConc.IsEmpty()){
              //idChecklist = [select ChecklistARG_AR__c from Produto_Concorr_ncia__c where Id =:prodConc[0].Id ].ChecklistARG_AR__c;
              //try{idRecTypeDev = [SELECT Id, Visit_AR__r.RecordType.DeveloperName FROM CLV_ChecklistVisita_ARG__c WHERE id=:idChecklist].Visit_AR__r.RecordType.DeveloperName;}catch(Exception e){}
          
              /*if(idRecTypeDev!=null){
                  idRecTypePC = new set<Id>();
                  if(idRecTypeDev=='VTS_Standard_AR'){
                      idRecTypePC.add(RecordTypeForTest.getRecType( 'Produto_Concorr_ncia__c', 'PPR_Standard_AR'));
                  }else if(idRecTypeDev=='VTS_Standard_UY'){
                      idRecTypePC.add(RecordTypeForTest.getRecType( 'Produto_Concorr_ncia__c', 'PPR_Standard_UY'));
                  }else if(idRecTypeDev=='BRA_Standard'){
                      idRecTypePC.add(RecordTypeForTest.getRecType( 'Produto_Concorr_ncia__c', 'BRA_Standard'));
                  }
              }*/
          
              for ( Produto_Concorr_ncia__c lExp : prodConc ){
                lListIds.add(lExp.id);
              }
              fListProdutos = [Select LAT_Product__c, LAT_Product__r.Name, Pre_o_Garrafa_Pernod__c, Qtde_de_Frentes_Pernod__c, 
                  Qtde_de_Pontos_Pernod__c, Confinado_Pernod__c, Produto_Concorrente__c, Produto_Concorrente__r.Name, Volume__c, 
                  Pre_o_garrafa_Concorrente__c, Qtde_de_Frentes_Concorrencia__c, Qtde_de_Pontos_Concorrencia__c, 
                  Confinado_Concorrente__c, Nao_se_aplica__c, Promo_o__c, Ativa_o__c FROM Produto_Concorr_ncia__c
                   Where id=:lListIds AND RecordTypeId =: idRecTypePC Order by LAT_Product__r.Name, Produto_Concorrente__r.Name];
              
              prodPRB = new List< Produto_Concorr_ncia__c >();
              prodConc = new List< Produto_Concorr_ncia__c >();
              Set< String > lSetProdPRB = new Set< String >();
              Set< String > lSetProdConc = new Set< String >();
              for ( Produto_Concorr_ncia__c lProd : fListProdutos )
              {
                if ( lProd.LAT_Product__r.Name != null && lProd.LAT_Product__r.Name.length() > 0 
                && !lSetProdPRB.contains( lProd.LAT_Product__r.Name ) )
                {
                  lSetProdPRB.add( lProd.LAT_Product__r.Name );
                  prodPRB.add( lProd );
                }
                if ( lProd.Produto_Concorrente__r.Name != null && lProd.Produto_Concorrente__r.Name.length() > 0 
                && !lSetProdConc.contains( lProd.Produto_Concorrente__r.Name ) )
                {
                  lSetProdConc.add( lProd.Produto_Concorrente__r.Name );
                  prodConc.add( lProd );
                }
              }
          }        
      }
  }
  
  public PageReference save() 
  {
    for ( Produto_Concorr_ncia__c lPRB : prodPRB )
    {
      for ( Produto_Concorr_ncia__c lProd : fListProdutos )
      {
        if ( lPRB.id == lProd.id )
        {
          lProd.Pre_o_Garrafa_Pernod__c = lPRB.Pre_o_Garrafa_Pernod__c;
          lProd.Nao_se_aplica__c = lPRB.Nao_se_aplica__c;
          break;
        }
      }
    }
    for ( Produto_Concorr_ncia__c lConc : prodConc )
    {
      for ( Produto_Concorr_ncia__c lProd : fListProdutos )
      {
        if ( lConc.id == lProd.id )
        {
          lProd.Pre_o_garrafa_Concorrente__c = lConc.Pre_o_garrafa_Concorrente__c;
          break;
        }
      }
    }
    update fListProdutos;
    return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
  }

}