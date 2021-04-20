@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura da classe ChecklistVisitaDAO.cls
* NAME: ChecklistVisitaDAOTest.CLS
* AUTHOR: CARLOS CARVALHO                         DATE: 31/05/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                         DATE: 18/01/2013
* DESC: COMENTADO CÓDIGO PARA COBRIR CLASSE DAO. 
********************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
private class ChecklistVisitaDAOTest {
	//MIGRATED 21/11/2016
    static testMethod void ChecklistVisitaDAOTest() {
      
      Test.startTest();
    	
      List<String> lListIdChecklist = new List<String>();
      List<Checklist_de_visita__c> lListCheck = new List<Checklist_de_visita__c>();
      lListCheck = ChecklistVisitaDAO.getInstance().getListChecklistInfoAccount(lListIdChecklist);
      Test.stopTest();
     
    }
}