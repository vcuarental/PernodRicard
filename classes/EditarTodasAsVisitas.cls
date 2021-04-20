/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* 
*
* NAME: EditarTodasAsVisitas.cls
* AUTHOR: ROGÉRIO ALVARENGA                         DATE:
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 10/01/2013 
********************************************************************************/
public without sharing class EditarTodasAsVisitas {
  
  List< Visitas__c > fObjs;
  private set<Id> idRecTypeVis;// = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard' );
  
  public EditarTodasAsVisitas( ApexPages.StandardSetController controller )
  {
    String idRecTypeDev;
    Id idVisita;
    
    fObjs = (List<Visitas__c>)controller.getSelected();
    set<String> lListIds = new set<String>();
    
    if(fObjs.IsEmpty()){
    	try{
    		Id planId = ApexPages.currentPage().getParameters().get('retURL').substring(1, 16);
		    for(Visitas__c vis: [SELECT Id FROM Visitas__c WHERE Planejamento__c =:planId]){
		    	fObjs.add(vis);
		    }
    	}catch(Exception e){}
    }
    
    if(!fObjs.IsEmpty())
    {
        try{
            idVisita = [SELECT Planejamento__c FROM Visitas__c WHERE Id =:fObjs[0].Id ].Planejamento__c;
            idRecTypeDev = [SELECT Id, RecordType.DeveloperName FROM Planejamento__c WHERE id=:idVisita].RecordType.DeveloperName;
        }catch(Exception e){}
        if(idRecTypeDev!=null){
            idRecTypeVis = new set<Id>();
            if(idRecTypeDev=='PLV_Standard_AR'){
                idRecTypeVis.add(RecordTypeForTest.getRecType('Visitas__c', 'VTS_Standard_AR'));
            }else if(idRecTypeDev=='PLV_Standard_UY'){
                idRecTypeVis.add(RecordTypeForTest.getRecType('Visitas__c', 'VTS_Standard_UY'));
            }else if(idRecTypeDev=='BRA_Standard'){
                idRecTypeVis.add(RecordTypeForTest.getRecType('Visitas__c', 'BRA_Standard'));
            }
        }
    }
    
    for(Visitas__c lCheck : fObjs){
      lListIds.add(lCheck.id);
    }
    fObjs = [ SELECT Conta__c, Conta__r.name, Tipo_de_Visita__c, Resumo_da_Visita__c, Data_da_Visita__c,
              Hora_da_Visita__c, Visita_n_o_realizada__c, Poss_veis_motivos__c, ciente__c
              FROM Visitas__c WHERE id=:lListIds AND Status__c <> 'Encerrada' 
              AND RecordTypeId IN: idRecTypeVis order by Conta__r.name ];
  }
  
  public List< Visitas__c > getVisitas()
  {
    return fObjs;
  }
  
  public PageReference save() 
  {
     try{
         update fObjs;
         return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
     }
     catch( Exception e )
     {
       ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, e.getMessage() ) );
       return null;
     }
  }
}