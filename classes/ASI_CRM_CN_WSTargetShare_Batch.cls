/*Created by Twinkle Li @01/08/2015
* Apex Sharing Calculation on WS Target
* Sharing at Division level, share to WS Manager (Read)
*/

global class ASI_CRM_CN_WSTargetShare_Batch implements Database.Batchable<sObject>{
   
   global Database.QueryLocator start(Database.BatchableContext BC){
      String soqlQuery;
      if(!Test.isRunningTest())
          soqlQuery = 'SELECT id, ASI_CRM_T2_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c, ASI_CRM_Sales_Team__c FROM ASI_CRM_WS_Target__c WHERE RecordType.DeveloperName = \'ASI_CRM_CN_WS_Target\'';  
      else
          soqlQuery = 'SELECT id, ASI_CRM_T2_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c, ASI_CRM_Sales_Team__c FROM ASI_CRM_WS_Target__c WHERE RecordType.DeveloperName = \'ASI_CRM_CN_WS_Target\' LIMIT 10'; 
      return Database.getQueryLocator(soqlQuery);
   }
   
    global void execute(Database.BatchableContext BC,  List<sObject> scope){
      if (scope == null) return;
      List<ASI_CRM_WS_Target__c> lstWSTarget = scope; 
      List<ASI_CRM_WS_Target__Share> sharesToCreate = new List<ASI_CRM_WS_Target__Share>();
      List<ID> shareIdsToDelete = new List<ID>();
      //List<ASI_CRM_Division_Security_Setting__c> listReadOnlyUsers;
      Map<String, List<ASI_CRM_Division_Security_Setting__c>> cityMapReadOnlyUsersList = new Map<String, List<ASI_CRM_Division_Security_Setting__c>>();
      
      List<ASI_CRM_Division_Security_Setting__c> lstDivSecSetting = [SELECT id, ASI_CRM_Division__c, ASI_CRM_Role__c, ASI_CRM_User__c, ASI_CRM_User__r.IsActive, ASI_CRM_Sales_Team__c, ASI_CRM_Sales_Team__r.Name FROM ASI_CRM_Division_Security_Setting__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Division_Security_Setting' AND ASI_CRM_Role__c = 'WS Manager'];
      Map<String, ASI_CRM_Division_Security_Setting__c> mapDivSecSetting = new Map<String, ASI_CRM_Division_Security_Setting__c>();
      
      for(ASI_CRM_Division_Security_Setting__c obj: lstDivSecSetting){
          if(obj.ASI_CRM_User__c != null && obj.ASI_CRM_User__r.IsActive && obj.ASI_CRM_Role__c == 'WS Manager'){
              
              //20160901 Ben @ Elufa
              String salesTeam = obj.ASI_CRM_Sales_Team__c != NULL ? obj.ASI_CRM_Sales_Team__r.Name : '';
              String divison = '';
              if(obj.ASI_CRM_Division__c != NULL)
                  divison = obj.ASI_CRM_Division__c;
              
              List<ASI_CRM_Division_Security_Setting__c> listOfUser = new List<ASI_CRM_Division_Security_Setting__c>();
              
              //20160901 Ben @ Elufa
                  if(cityMapReadOnlyUsersList.containsKey( '' + divison + salesTeam)){
                      listOfUser = cityMapReadOnlyUsersList.get( '' + divison + salesTeam);
                  }
                  
                  listOfUser.add(obj);
                  
                  cityMapReadOnlyUsersList.put( '' + divison + salesTeam, listOfUser);
              
              /*if(cityMapReadOnlyUsersList.get(obj.ASI_CRM_Division__c) == null){
                  listReadOnlyUsers = new List<ASI_CRM_Division_Security_Setting__c>();
                  listReadOnlyUsers.add(obj);
                  cityMapReadOnlyUsersList.put(obj.ASI_CRM_Division__c, listReadOnlyUsers);
              }
              else{
                  listReadOnlyUsers = new List<ASI_CRM_Division_Security_Setting__c>();
                  listReadOnlyUsers = cityMapReadOnlyUsersList.get(obj.ASI_CRM_Division__c);
                  listReadOnlyUsers.add(obj);
                  cityMapReadOnlyUsersList.put(obj.ASI_CRM_Division__c, listReadOnlyUsers);
              }*/
          }
      }
      
      
      for(ASI_CRM_WS_Target__c target: lstWSTarget){          
          //Share at Division level
          
          //20160901 Ben @ Elufa
          
          List<ASI_CRM_Division_Security_Setting__c> listReadOnlyUsers = new List<ASI_CRM_Division_Security_Setting__c>();
          
          if(cityMapReadOnlyUsersList.containsKey(target.ASI_CRM_T2_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + target.ASI_CRM_Sales_Team__c)){
              
              listReadOnlyUsers.addAll(cityMapReadOnlyUsersList.get(target.ASI_CRM_T2_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + target.ASI_CRM_Sales_Team__c));
          }
          if(cityMapReadOnlyUsersList.containsKey(target.ASI_CRM_T2_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c)){
              
              listReadOnlyUsers.addAll(cityMapReadOnlyUsersList.get(target.ASI_CRM_T2_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c));
          }
          if(cityMapReadOnlyUsersList.containsKey(target.ASI_CRM_Sales_Team__c)){
              
              listReadOnlyUsers.addAll(cityMapReadOnlyUsersList.get(target.ASI_CRM_Sales_Team__c));
          }
          
          if(listReadOnlyUsers.size() > 0){//if(!cityMapReadOnlyUsersList.IsEmpty() && cityMapReadOnlyUsersList.get(target.ASI_CRM_T2_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c) != null){
              for(ASI_CRM_Division_Security_Setting__c obj : listReadOnlyUsers){//cityMapReadOnlyUsersList.get(target.ASI_CRM_T2_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c)){
                  ASI_CRM_WS_Target__Share newRecord = new ASI_CRM_WS_Target__Share();
                  newRecord.ParentId = target.Id;
                  newRecord.UserOrGroupId = obj.ASI_CRM_User__c;
                  newRecord.AccessLevel = 'Read';         
                  
                  if(obj.ASI_CRM_Role__c == 'WS Manager'){     
                      newRecord.RowCause = Schema.ASI_CRM_WS_Target__Share.RowCause.ASI_CRM_CN_Share_To_WS_Manager__c;
                  }
                  sharesToCreate.add(newRecord);
                  shareIdsToDelete.add(target.id);
              }
          }
      }     
      
      if (!shareIdsToDelete.isEmpty())
          delete [SELECT id FROM ASI_CRM_WS_Target__Share WHERE ParentId IN :shareIdsToDelete AND 
                  RowCause =: Schema.ASI_CRM_WS_Target__Share.RowCause.ASI_CRM_CN_Share_To_WS_Manager__c];
      if (!sharesToCreate.isEmpty())
          Database.insert(sharesToCreate);  
   }

   global void finish(Database.BatchableContext BC){
       if(!Test.isRunningTest())
           database.executebatch(new ASI_CRM_CN_AccountsAdditionalShare_Batch(),50);
   } 
}