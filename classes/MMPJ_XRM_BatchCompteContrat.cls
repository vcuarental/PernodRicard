global class MMPJ_XRM_BatchCompteContrat implements Database.Batchable<sObject> {
  Public Id  recordTypeBailleurEspeceID = [Select id, name from RecordType where DeveloperName = 'MMPJ_XRM_Bailleur_Espece' and SobjectType ='MMPJ_Ext_Vign_Societe__c' limit 1].ID; 
  Public String querySegmentation = 'SELECT Id, Name, MMPJ_Ext_Vign_Statut__c, RecordTypeId FROM MMPJ_Ext_Vign_Societe__c WHERE MMPJ_Ext_Vign_Societe_Segmentation__c = \'Champagne\' AND RecordTypeId !=\''+recordTypeBailleurEspeceID+'\'';
    
  global Database.QueryLocator start(Database.BatchableContext bc){
       //String q2 = 'select count() from MMPJ_Ext_Vign_Societe__c WHERE MMPJ_Ext_Vign_Societe_Segmentation__c = \'Champagne\'';
       //System.debug('#### nb acc = ' + Database.countQuery(q2));  
       return Database.getQueryLocator(querySegmentation);
  }
    
  global void execute(Database.BatchableContext BC, List<sObject> scope){
      List<MMPJ_Ext_Vign_Societe__c> ChampagneList = new List<MMPJ_Ext_Vign_Societe__c>();
      List<MMPJ_Ext_Vign_Contrat__c> ListContrat = new List<MMPJ_Ext_Vign_Contrat__c>();

      for(sObject aSObject : scope)
      {
        ChampagneList.add((MMPJ_Ext_Vign_Societe__c)aSObject);
      }

       //Date maDate = Date.newInstance(Date.today().year(),Date.today().month(),Date.today().day());
      Set<Id> accountInCOntrat = new Set<Id>();
      Date startDate = (Date.today() < Date.newInstance(Date.today().year(), 8, 31)) ? Date.newInstance(Date.today().year() - 1, 8, 31) : Date.newInstance(Date.today().year(), 8, 31);

      for(MMPJ_Ext_Vign_Contrat__c con : [SELECT Id, MMPJ_Ext_Vign_Livreur__c, MMPJ_Ext_Vign_Courtier__c, MMPJ_XRM_Pressoir__c FROM MMPJ_Ext_Vign_Contrat__c WHERE 
         (MMPJ_Ext_Vign_Livreur__c  IN:ChampagneList OR MMPJ_Ext_Vign_Courtier__c IN:ChampagneList OR MMPJ_XRM_Pressoir__c IN:ChampagneList) 
         And (MMPJ_Ext_Vign_Date_de_fin_du_contrat__c > :startDate or MMPJ_Ext_Vign_Date_de_fin_du_contrat__c = null) and RecordType.DeveloperName  = 'MMPJ_Ext_Vign_Appro_Press'])
      {
        accountInCOntrat.add(con.MMPJ_Ext_Vign_Livreur__c);
        accountInCOntrat.add(con.MMPJ_Ext_Vign_Courtier__c);
        accountInCOntrat.add(con.MMPJ_XRM_Pressoir__c);
      }

    for(MMPJ_Ext_Vign_Societe__c acc:ChampagneList) {
      if(accountInCOntrat.contains(acc.Id))
        acc.MMPJ_Ext_Vign_Statut__c = 'MMPJ_Ext_Vign_Partenaire';
      else if (!accountInCOntrat.contains(acc.Id) && acc.MMPJ_Ext_Vign_Statut__c != 'MMPJ_Ext_Vign_Prospect')
        acc.MMPJ_Ext_Vign_Statut__c = 'MMPJ_XRM_ExPartenaire';
    }

    Database.SaveResult[] results = Database.update(ChampagneList, false);
    for (Database.SaveResult sr : results) {
      if (!sr.isSuccess()) {         
        for(Database.Error err : sr.getErrors()) {
          System.debug('The following error has occurred.');                    
          System.debug(err.getStatusCode() + ': ' + err.getMessage());
          System.debug('fields that affected this error: ' + err.getFields());
        }
      }
    }
    //update ChampagneList;
   }
   
   global void finish(Database.BatchableContext BC){
   }
}

/*public String querySegmentation = 'SELECT Id, Name, MMPJ_Ext_Vign_Statut__c FROM MMPJ_Ext_Vign_Societe__c WHERE (MMPJ_Ext_Vign_Societe_Segmentation__c = \'Champagne\' And RecordTypeId = \'0127E0000008tjM\')';
    
    global Database.QueryLocator start(Database.BatchableContext bc){   
        return Database.getQueryLocator(querySegmentation);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<MMPJ_Ext_Vign_Societe__c> ChampagneList = new List<MMPJ_Ext_Vign_Societe__c>();
        List<MMPJ_Ext_Vign_Contrat__c> ListContrat = new List<MMPJ_Ext_Vign_Contrat__c>();

        for(sObject aSObject : scope){
            ChampagneList.add((MMPJ_Ext_Vign_Societe__c)aSObject);
        }

        Set<Id> accountInCOntrat = new Set<Id>();
        Map<Id, MMPJ_Ext_Vign_Societe__c> mapSociete = new Map<Id, MMPJ_Ext_Vign_Societe__c>([SELECT Id, MMPJ_Ext_Vign_Statut__c FROM MMPJ_Ext_Vign_Societe__c WHERE (MMPJ_Ext_Vign_Societe_Segmentation__c = 'Champagne' And RecordTypeId = '0127E0000008tjM')]);


        if (Date.today() < Date.newInstance(Date.today().year(),9,1)) {
            Date maDate = Date.newInstance(Date.today().year(),Date.today().month(),Date.today().day());
            String Dquery = 'SELECT Id,MMPJ_Ext_Vign_Livreur__c FROM MMPJ_Ext_Vign_Contrat__c WHERE MMPJ_Ext_Vign_Livreur__c IN:ChampagneList And (MMPJ_Ext_Vign_Date_de_fin_du_contrat__c > :maDate or MMPJ_Ext_Vign_Date_de_fin_du_contrat__c = null)';

            for(MMPJ_Ext_Vign_Contrat__c con : Database.query(Dquery)){
               accountInCOntrat.add(con.MMPJ_Ext_Vign_Livreur__c);
            }
        }

        for(MMPJ_Ext_Vign_Societe__c acc:ChampagneList) {
            if(accountInCOntrat.contains(acc.Id))
                acc.MMPJ_Ext_Vign_Statut__c = 'MMPJ_Ext_Vign_Partenaire';
            else if (mapSociete.get(acc.Id).MMPJ_Ext_Vign_Statut__c != 'MMPJ_Ext_Vign_Prospect')
                acc.MMPJ_Ext_Vign_Statut__c = 'MMPJ_XRM_ExPartenaire';
            }
        update ChampagneList;

    }
    
    global void finish(Database.BatchableContext BC){
    }*/




    
/*    public String querySegmentation = 'SELECT Id, Name, MMPJ_Ext_Vign_Statut__c,RecordType.DeveloperName FROM MMPJ_Ext_Vign_Societe__c WHERE MMPJ_Ext_Vign_Societe_Segmentation__c = \'Champagne\'';
   
   global Database.QueryLocator start(Database.BatchableContext bc){
       //String q2 = 'select count() from MMPJ_Ext_Vign_Societe__c WHERE MMPJ_Ext_Vign_Societe_Segmentation__c = \'Champagne\'';
       //System.debug('#### nb acc = ' + Database.countQuery(q2));  
       return Database.getQueryLocator(querySegmentation);
   }
   
   //global void execute(SchedulableContext SC){ Database.executeBatch(new MMPJ_XRM_BatchCompteContrat()); }
   
   global void execute(Database.BatchableContext BC, List<sObject> scope){
       Map<Id,MMPJ_Ext_Vign_Societe__c> ChampagneList = new Map<Id,MMPJ_Ext_Vign_Societe__c>();
       List<MMPJ_Ext_Vign_Contrat__c> ListContrat = new List<MMPJ_Ext_Vign_Contrat__c>();

       for(sObject aSObject : scope){
          MMPJ_Ext_Vign_Societe__c s = (MMPJ_Ext_Vign_Societe__c)aSObject;
           ChampagneList.put(s.Id,s);
       }

       //Date maDate = Date.newInstance(Date.today().year(),Date.today().month(),Date.today().day());
       Set<Id> accountInCOntrat = new Set<Id>();
       Date startDate = (Date.today() < Date.newInstance(Date.today().year(), 8, 31)) ? Date.newInstance(Date.today().year() - 1, 8, 31) : Date.newInstance(Date.today().year(), 8, 31);

       for(MMPJ_Ext_Vign_Contrat__c con : [SELECT Id,MMPJ_Ext_Vign_Livreur__c FROM MMPJ_Ext_Vign_Contrat__c WHERE MMPJ_Ext_Vign_Livreur__c 
        IN:ChampagneList.KeySet() And (MMPJ_Ext_Vign_Date_de_fin_du_contrat__c > :startDate or MMPJ_Ext_Vign_Date_de_fin_du_contrat__c = null) and RecordType.DeveloperName  = 'MMPJ_Ext_Vign_Appro_Press']){
        accountInCOntrat.add(con.MMPJ_Ext_Vign_Livreur__c);
       }
      Set<Id> pressoirs = new Set<Id>();
      for(MMPJ_Ext_Vign_Societe__c acc:ChampagneList.values()) {
        System.debug('### check account ' + acc.Name + ' with id ' + acc.Id);
        System.debug('### contrat trouvé ? ' + accountInCOntrat.contains(acc.Id));
        if(accountInCOntrat.contains(acc.Id))
        {
          acc.MMPJ_Ext_Vign_Statut__c = 'MMPJ_Ext_Vign_Partenaire';
        } else if (!accountInCOntrat.contains(acc.Id) && acc.MMPJ_Ext_Vign_Statut__c != 'MMPJ_Ext_Vign_Prospect')
        {
          acc.MMPJ_Ext_Vign_Statut__c = 'MMPJ_XRM_ExPartenaire';
          if(acc.RecordType.DeveloperName == 'MMPJ_Ext_Vign_Centre_de_pressurage')
            pressoirs.add(acc.Id);
        }
      }

      if(pressoirs.size() > 0)
      {
        Map<Id,Set<Id>> societesLieesPressoirs = new Map<Id,Set<Id>>();
        for(MMPJ_XRM_RelationSociete__c rel:[select MMPJ_XRM_Livreur__c,MMPJ_XRM_Societe_liee__c from MMPJ_XRM_RelationSociete__c where MMPJ_XRM_Societe_liee__c IN:pressoirs])
        {
          if(!societesLieesPressoirs.containsKey(rel.MMPJ_XRM_Societe_liee__c))
            societesLieesPressoirs.put(rel.MMPJ_XRM_Societe_liee__c,new Set<Id>());

          societesLieesPressoirs.get(rel.MMPJ_XRM_Societe_liee__c).add(rel.MMPJ_XRM_Livreur__c);
        }

        Set<Id> socPressoir = new Set<Id>();
        for(Id pressId:societesLieesPressoirs.keySet())
          socPressoir.addAll(societesLieesPressoirs.get(pressId));

        Set<Id> socWithContract = new Set<Id>();

        for(MMPJ_Ext_Vign_Contrat__c con : [SELECT Id,MMPJ_Ext_Vign_Livreur__c FROM MMPJ_Ext_Vign_Contrat__c WHERE MMPJ_Ext_Vign_Livreur__c 
          IN:socPressoir And (MMPJ_Ext_Vign_Date_de_fin_du_contrat__c > :startDate or MMPJ_Ext_Vign_Date_de_fin_du_contrat__c = null) and RecordType.DeveloperName  = 'MMPJ_Ext_Vign_Appro_Press']){
          socWithContract.add(con.MMPJ_Ext_Vign_Livreur__c);
        }

        for(Id pressId:societesLieesPressoirs.keySet())
        {
          //Delete common element to know if there is societe with contrat in the list.
          //if the size change, there is common element : Partenaire
          //if the size doesn't change, there is no common element : Ex partenaire (so don't change the value already calculated)
          // MARCHE PAS. Pourquoi ??
          Integer nbSoc = societesLieesPressoirs.get(pressId).size();
          societesLieesPressoirs.get(pressId).removeAll(socWithContract);
          if(societesLieesPressoirs.get(pressId).size() != nbSoc)
             ChampagneList.get(pressId).MMPJ_Ext_Vign_Statut__c = 'MMPJ_Ext_Vign_Partenaire';
        }
      }

      Database.SaveResult[] results = Database.update(ChampagneList.values(), false);
      for (Database.SaveResult sr : results) {
        if (!sr.isSuccess()) {         
          for(Database.Error err : sr.getErrors()) {
            System.debug('The following error has occurred.');                    
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('fields that affected this error: ' + err.getFields());
          }
        }
      }
    //update ChampagneList;
   }
   
   global void finish(Database.BatchableContext BC){
   }
}
*/
/*public String querySegmentation = 'SELECT Id, Name, MMPJ_Ext_Vign_Statut__c FROM MMPJ_Ext_Vign_Societe__c WHERE (MMPJ_Ext_Vign_Societe_Segmentation__c = \'Champagne\' And RecordTypeId = \'0127E0000008tjM\')';
    
    global Database.QueryLocator start(Database.BatchableContext bc){   
        return Database.getQueryLocator(querySegmentation);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<MMPJ_Ext_Vign_Societe__c> ChampagneList = new List<MMPJ_Ext_Vign_Societe__c>();
        List<MMPJ_Ext_Vign_Contrat__c> ListContrat = new List<MMPJ_Ext_Vign_Contrat__c>();

        for(sObject aSObject : scope){
            ChampagneList.add((MMPJ_Ext_Vign_Societe__c)aSObject);
        }

        Set<Id> accountInCOntrat = new Set<Id>();
        Map<Id, MMPJ_Ext_Vign_Societe__c> mapSociete = new Map<Id, MMPJ_Ext_Vign_Societe__c>([SELECT Id, MMPJ_Ext_Vign_Statut__c FROM MMPJ_Ext_Vign_Societe__c WHERE (MMPJ_Ext_Vign_Societe_Segmentation__c = 'Champagne' And RecordTypeId = '0127E0000008tjM')]);


        if (Date.today() < Date.newInstance(Date.today().year(),9,1)) {
            Date maDate = Date.newInstance(Date.today().year(),Date.today().month(),Date.today().day());
            String Dquery = 'SELECT Id,MMPJ_Ext_Vign_Livreur__c FROM MMPJ_Ext_Vign_Contrat__c WHERE MMPJ_Ext_Vign_Livreur__c IN:ChampagneList And (MMPJ_Ext_Vign_Date_de_fin_du_contrat__c > :maDate or MMPJ_Ext_Vign_Date_de_fin_du_contrat__c = null)';

            for(MMPJ_Ext_Vign_Contrat__c con : Database.query(Dquery)){
               accountInCOntrat.add(con.MMPJ_Ext_Vign_Livreur__c);
            }
        }

        for(MMPJ_Ext_Vign_Societe__c acc:ChampagneList) {
            if(accountInCOntrat.contains(acc.Id))
                acc.MMPJ_Ext_Vign_Statut__c = 'MMPJ_Ext_Vign_Partenaire';
            else if (mapSociete.get(acc.Id).MMPJ_Ext_Vign_Statut__c != 'MMPJ_Ext_Vign_Prospect')
                acc.MMPJ_Ext_Vign_Statut__c = 'MMPJ_XRM_ExPartenaire';
            }
        update ChampagneList;

    }
    
    global void finish(Database.BatchableContext BC){
    }*/