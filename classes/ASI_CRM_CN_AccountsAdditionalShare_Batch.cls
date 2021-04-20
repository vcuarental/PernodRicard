/*Created by Twinkle Li @01/05/2015
* Apex Sharing Calculation on Customer
* Sharing child outlet to parent outlet owner, max. 3 levels (Read)
* Sharing at Division level, share to BA, Finance, RTMK (Read/Write)
* sharing at Division level, share to channel manager based on "On/Off" & WS Manager (Read)
*/

global class ASI_CRM_CN_AccountsAdditionalShare_Batch implements Database.Batchable<sObject>{
   
   global Database.QueryLocator start(Database.BatchableContext BC){
      String soqlQuery;
      if(!Test.isRunningTest())
          soqlQuery = 'SELECT id, RecordType.DeveloperName, ASI_CRM_CN_PG_Head__c, ASI_CRM_CN_PG_Head__r.IsActive, ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c, ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c, ASI_CRM_CN_Parent_Outlet__c, ASI_CRM_CN_Parent_Outlet__r.ownerId, ASI_CRM_CN_Parent_Outlet__r.owner.IsActive, ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_Parent_Outlet__r.ownerId, ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_Parent_Outlet__r.owner.IsActive, ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c, 	ASI_CRM_CN_Sales_Team__c FROM ASI_CRM_AccountsAdditionalField__c WHERE (RecordType.DeveloperName = \'ASI_CRM_Outlet_CN\' OR RecordType.DeveloperName = \'ASI_CRM_CN_WS\')';  
      else
          soqlQuery = 'SELECT id, RecordType.DeveloperName, ASI_CRM_CN_PG_Head__c, ASI_CRM_CN_PG_Head__r.IsActive, ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c, ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c, ASI_CRM_CN_Parent_Outlet__c, ASI_CRM_CN_Parent_Outlet__r.ownerId, ASI_CRM_CN_Parent_Outlet__r.owner.IsActive, ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_Parent_Outlet__r.ownerId, ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_Parent_Outlet__r.owner.IsActive, ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c, 	ASI_CRM_CN_Sales_Team__c FROM ASI_CRM_AccountsAdditionalField__c WHERE (RecordType.DeveloperName = \'ASI_CRM_Outlet_CN\' OR RecordType.DeveloperName = \'ASI_CRM_CN_WS\') LIMIT 10';  
      return Database.getQueryLocator(soqlQuery);
   }
   
    global void execute(Database.BatchableContext BC,  List<sObject> scope){
      if (scope == null) return;
      List<ASI_CRM_AccountsAdditionalField__c> lstCust = scope; 
      List<ASI_CRM_AccountsAdditionalField__Share> sharesToCreate = new List<ASI_CRM_AccountsAdditionalField__Share>();
      List<Id> shareIdsToDelete = new List<Id>();
      //List<ASI_CRM_Division_Security_Setting__c> listReadOnlyUsers;
      //List<ASI_CRM_Division_Security_Setting__c> listReadWriteUsers;
      //List<ASI_CRM_Division_Security_Setting__c> listCMUsers;
      Map<String, List<ASI_CRM_Division_Security_Setting__c>> cityMapReadOnlyUsersList = new Map<String, List<ASI_CRM_Division_Security_Setting__c>>();
      Map<String, List<ASI_CRM_Division_Security_Setting__c>> cityMapReadWriteUsersList = new Map<String, List<ASI_CRM_Division_Security_Setting__c>>();
      Map<String, List<ASI_CRM_Division_Security_Setting__c>> cityMapCMUsersList = new Map<String, List<ASI_CRM_Division_Security_Setting__c>>();
            
      List<ASI_CRM_Division_Security_Setting__c> lstDivSecSetting = [SELECT id, ASI_CRM_Division__c, ASI_CRM_On_Off__c, ASI_CRM_Role__c, ASI_CRM_User__c, ASI_CRM_User__r.IsActive, ASI_CRM_Sales_Team__c, ASI_CRM_Sales_Team__r.Name FROM ASI_CRM_Division_Security_Setting__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Division_Security_Setting' AND (ASI_CRM_Role__c = 'BA' OR ASI_CRM_Role__c = 'Finance' OR ASI_CRM_Role__c = 'Regional Trade Marketing' OR ASI_CRM_Role__c = 'WS Manager' OR ASI_CRM_Role__c = 'Channel Manager')];     
      //Get Users list map with related region
      for(ASI_CRM_Division_Security_Setting__c obj: lstDivSecSetting){
          if(obj.ASI_CRM_User__c != null && obj.ASI_CRM_User__r.IsActive){
              
              //20160901 Ben @ Elufa
              String salesTeam = obj.ASI_CRM_Sales_Team__c != NULL ? obj.ASI_CRM_Sales_Team__r.Name : '';
              String division = '';
              if(obj.ASI_CRM_Division__c != NULL)
                  division = obj.ASI_CRM_Division__c;
              
              List<ASI_CRM_Division_Security_Setting__c> listOfUser = new List<ASI_CRM_Division_Security_Setting__c>();
              
              //Users with Read/Write Access
              if(obj.ASI_CRM_Role__c == 'BA' || obj.ASI_CRM_Role__c == 'Finance' || obj.ASI_CRM_Role__c == 'Regional Trade Marketing'){
                  
                  if(cityMapReadWriteUsersList.containsKey( '' + division + salesTeam)){
                      listOfUser = cityMapReadWriteUsersList.get( '' + division + salesTeam);
                  }
                  
                  listOfUser.add(obj);
                  
                  cityMapReadWriteUsersList.put( '' + division + salesTeam, listOfUser);
                  
                  /*if(cityMapReadWriteUsersList.get(obj.ASI_CRM_Division__c) == null){
                      listReadWriteUsers = new List<ASI_CRM_Division_Security_Setting__c>();
                      listReadWriteUsers.add(obj);
                      cityMapReadWriteUsersList.put(obj.ASI_CRM_Division__c, listReadWriteUsers);
                  }
                  else{
                      listReadWriteUsers = new List<ASI_CRM_Division_Security_Setting__c>();
                      listReadWriteUsers = cityMapReadWriteUsersList.get(obj.ASI_CRM_Division__c);
                      listReadWriteUsers.add(obj);
                      cityMapReadWriteUsersList.put(obj.ASI_CRM_Division__c, listReadWriteUsers);
                  }*/
              }
              //Users with Read-Only Access
              else if(obj.ASI_CRM_Role__c == 'WS Manager'){
                  
                  if(cityMapReadWriteUsersList.containsKey( '' + division + salesTeam)){
                      listOfUser = cityMapReadWriteUsersList.get( '' + division + salesTeam);
                  }
                  
                  listOfUser.add(obj);
                  
                  cityMapReadWriteUsersList.put( '' + division + salesTeam, listOfUser);
                  
                  /*if(cityMapReadWriteUsersList.get(obj.ASI_CRM_Division__c) == null){
                      listReadWriteUsers = new List<ASI_CRM_Division_Security_Setting__c>();
                      listReadWriteUsers.add(obj);
                      cityMapReadWriteUsersList.put(obj.ASI_CRM_Division__c, listReadWriteUsers);
                  }
                  else{
                      listReadWriteUsers = new List<ASI_CRM_Division_Security_Setting__c>();
                      listReadWriteUsers = cityMapReadWriteUsersList.get(obj.ASI_CRM_Division__c);
                      listReadWriteUsers.add(obj);
                      cityMapReadWriteUsersList.put(obj.ASI_CRM_Division__c, listReadWriteUsers);
                  }*/
              }
              //Channel Manager with on/off
              else if(obj.ASI_CRM_Role__c == 'Channel Manager'){
                  
                  if(cityMapCMUsersList.containsKey( '' + division + salesTeam + obj.ASI_CRM_On_Off__c)){
                      listOfUser = cityMapCMUsersList.get( '' + division + salesTeam + obj.ASI_CRM_On_Off__c);
                  }
                  
                  listOfUser.add(obj);
                  
                  cityMapCMUsersList.put( '' + division + salesTeam + obj.ASI_CRM_On_Off__c, listOfUser);
                  
                  /*if(cityMapCMUsersList.get(obj.ASI_CRM_Division__c+obj.ASI_CRM_On_Off__c) == null){
                      listCMUsers = new List<ASI_CRM_Division_Security_Setting__c>();
                      listCMUsers.add(obj);
                      cityMapCMUsersList.put(obj.ASI_CRM_Division__c+obj.ASI_CRM_On_Off__c, listCMUsers);
                  }
                  else{
                      listCMUsers = new List<ASI_CRM_Division_Security_Setting__c>();
                      listCMUsers = cityMapCMUsersList.get(obj.ASI_CRM_Division__c+obj.ASI_CRM_On_Off__c);
                      listCMUsers.add(obj);
                      cityMapCMUsersList.put(obj.ASI_CRM_Division__c+obj.ASI_CRM_On_Off__c, listCMUsers);
                  }*/
              }
          }
      }
      
      for(ASI_CRM_AccountsAdditionalField__c cust: lstCust){   
          //Share to PG Head
          if(cust.ASI_CRM_CN_PG_Head__c != null && cust.ASI_CRM_CN_PG_Head__r.IsActive){
              ASI_CRM_AccountsAdditionalField__Share newRecord = new ASI_CRM_AccountsAdditionalField__Share();
              newRecord.ParentId = cust.Id;
              newRecord.UserOrGroupId = cust.ASI_CRM_CN_PG_Head__c;
              newRecord.AccessLevel = 'Read';         
              newRecord.RowCause = Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_PG_Head__c;
              sharesToCreate.add(newRecord);
              shareIdsToDelete.add(cust.id);
          }
              
          if(cust.RecordType.DeveloperName == 'ASI_CRM_Outlet_CN'){
              //Share to Parent Outlet's owner
              if(cust.ASI_CRM_CN_Parent_Outlet__c != null && cust.ASI_CRM_CN_Parent_Outlet__r.owner !=  null && cust.ASI_CRM_CN_Parent_Outlet__r.owner.IsActive){
                  ASI_CRM_AccountsAdditionalField__Share newRecord = new ASI_CRM_AccountsAdditionalField__Share();
                  newRecord.ParentId = cust.Id;
                  newRecord.UserOrGroupId = cust.ASI_CRM_CN_Parent_Outlet__r.ownerId;
                  newRecord.AccessLevel = 'Read';         
                  newRecord.RowCause = Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_Parent_Outlet_Owner__c;
                  sharesToCreate.add(newRecord);
                  shareIdsToDelete.add(cust.id);
                  
                  //Share to Parent of Parent Outlet's owner
                  if(cust.ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_Parent_Outlet__c != null && cust.ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_Parent_Outlet__r.owner != null && cust.ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_Parent_Outlet__r.owner.IsActive){
                      newRecord = new ASI_CRM_AccountsAdditionalField__Share();
                      newRecord.ParentId = cust.Id;
                      newRecord.UserOrGroupId = cust.ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_Parent_Outlet__r.ownerId;
                      newRecord.AccessLevel = 'Read';         
                      newRecord.RowCause = Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_PP_Outlet_Owner__c;
                      sharesToCreate.add(newRecord);
                      shareIdsToDelete.add(cust.id);
                  }
              }
          }
          
          //Share at Division level
          if(cust.ASI_CRM_CN_CCity__c != null && cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c != null){
              
              //20160901 Ben @ Elufa
              
              List<ASI_CRM_Division_Security_Setting__c> listReadOnlyUsers = new List<ASI_CRM_Division_Security_Setting__c>();
              List<ASI_CRM_Division_Security_Setting__c> listReadWriteUsers = new List<ASI_CRM_Division_Security_Setting__c>();
              List<ASI_CRM_Division_Security_Setting__c> listCMUsers = new List<ASI_CRM_Division_Security_Setting__c>();
              
              if(cityMapReadWriteUsersList.containsKey(cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + cust.ASI_CRM_CN_Sales_Team__c)){
                  
                  listReadWriteUsers.addAll(cityMapReadWriteUsersList.get(cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + cust.ASI_CRM_CN_Sales_Team__c));
              }
              if(cityMapReadWriteUsersList.containsKey(cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c)){
                  
                  listReadWriteUsers.addAll(cityMapReadWriteUsersList.get(cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c));
              }
              if(cityMapReadWriteUsersList.containsKey(cust.ASI_CRM_CN_Sales_Team__c)){
                  
                  listReadWriteUsers.addAll(cityMapReadWriteUsersList.get(cust.ASI_CRM_CN_Sales_Team__c));
              }
              
              /*if(cityMapReadOnlyUsersList.containsKey(contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + contract.ASI_CRM_Sales_Team__c)){
                  
                  listReadOnlyUsers = cityMapReadOnlyUsersList.get(contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + contract.ASI_CRM_Sales_Team__c);
              }else if(cityMapReadOnlyUsersList.containsKey(contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c)){
                  
                  listReadOnlyUsers = cityMapReadOnlyUsersList.get(contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c);
              }else if(cityMapReadOnlyUsersList.containsKey(contract.ASI_CRM_Sales_Team__c)){
                  
                  listReadOnlyUsers = cityMapReadOnlyUsersList.get(contract.ASI_CRM_Sales_Team__c);
              }*/
              
              String onOff = cust.ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c != NULL ? cust.ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c : ( cust.ASI_CRM_CN_Sub_Channel__c != null && cust.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__c != null ) ? cust.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c : '';
              
              if(cityMapCMUsersList.containsKey(cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + cust.ASI_CRM_CN_Sales_Team__c + onOff)){
                  
                  listCMUsers.addAll(cityMapCMUsersList.get(cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + cust.ASI_CRM_CN_Sales_Team__c + onOff));
              }
              if(cityMapCMUsersList.containsKey(cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + onOff)){
                  
                  listCMUsers.addAll(cityMapCMUsersList.get(cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + onOff));
              }
              if(cityMapCMUsersList.containsKey(cust.ASI_CRM_CN_Sales_Team__c + onOff)){
                  
                  listCMUsers.addAll(cityMapCMUsersList.get(cust.ASI_CRM_CN_Sales_Team__c + onOff));
              }
              
              //Share to users with Read/Write access
              if(listReadWriteUsers.size() > 0){//if(!cityMapReadWriteUsersList.IsEmpty() && cityMapReadWriteUsersList.get(cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c) != null){
                  for(ASI_CRM_Division_Security_Setting__c obj : listReadWriteUsers){//cityMapReadWriteUsersList.get(cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c)){
                      ASI_CRM_AccountsAdditionalField__Share newRecord = new ASI_CRM_AccountsAdditionalField__Share();
                      newRecord.ParentId = cust.Id;
                      newRecord.UserOrGroupId = obj.ASI_CRM_User__c;
                      newRecord.AccessLevel = 'Edit';
                      
                      if(obj.ASI_CRM_Role__c == 'BA'){      
                          newRecord.RowCause = Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_BA__c;
                      }
                      else if(obj.ASI_CRM_Role__c == 'Finance'){        
                          newRecord.RowCause = Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_Finance__c;
                      }
                      else if(obj.ASI_CRM_Role__c == 'Regional Trade Marketing'){
                          newRecord.RowCause = Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_RTMK__c;
                      }
						else if(obj.ASI_CRM_Role__c == 'WS Manager'){
                          newRecord.RowCause = Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_WS_Manager__c;
                      }
                      sharesToCreate.add(newRecord);
                      shareIdsToDelete.add(cust.id);
                  }
              }
              //Share to users with Read-Only access
/*              if(!cityMapReadOnlyUsersList.IsEmpty() && cityMapReadOnlyUsersList.get(cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c) != null){
                  for(ASI_CRM_Division_Security_Setting__c obj : cityMapReadOnlyUsersList.get(cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c)){
                      ASI_CRM_AccountsAdditionalField__Share newRecord = new ASI_CRM_AccountsAdditionalField__Share();
                      newRecord.ParentId = cust.Id;
                      newRecord.UserOrGroupId = obj.ASI_CRM_User__c;
                      newRecord.AccessLevel = 'Read';
                      
                      if(obj.ASI_CRM_Role__c == 'WS Manager'){
                          newRecord.RowCause = Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_WS_Manager__c;
                      }
                      sharesToCreate.add(newRecord);
                      shareIdsToDelete.add(cust.id);
                  }
              }*/
              //Share to Chanel Manager based on channel on/off
              if(listCMUsers.size() > 0){//if(!cityMapCMUsersList.IsEmpty() && cust.ASI_CRM_CN_Sub_Channel__c != null && cust.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__c != null && cityMapCMUsersList.get(cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c+cust.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c) != null){
                  for(ASI_CRM_Division_Security_Setting__c obj : listCMUsers){//cityMapCMUsersList.get(cust.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c+cust.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c)){
                      ASI_CRM_AccountsAdditionalField__Share newRecord = new ASI_CRM_AccountsAdditionalField__Share();
                      newRecord.ParentId = cust.Id;
                      newRecord.UserOrGroupId = obj.ASI_CRM_User__c;
                      newRecord.AccessLevel = 'Read';
                      
                      if(obj.ASI_CRM_Role__c == 'Channel Manager' && obj.ASI_CRM_On_Off__c == 'On'){         
                          newRecord.RowCause = Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_Channel_Manager_On__c;
                      }
                      if(obj.ASI_CRM_Role__c == 'Channel Manager' && obj.ASI_CRM_On_Off__c == 'Off'){      
                          newRecord.RowCause = Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_Channel_Manager_Off__c;                          
                      }
                      sharesToCreate.add(newRecord);
                      shareIdsToDelete.add(cust.id);
                  }
              }
          }
      }     
      
      if (!shareIdsToDelete.isEmpty())
          delete [SELECT id FROM ASI_CRM_AccountsAdditionalField__Share WHERE ParentId IN :shareIdsToDelete AND 
                  (RowCause =: Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_PG_Head__c OR 
                  RowCause =: Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_Parent_Outlet_Owner__c OR 
                  RowCause =: Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_PP_Outlet_Owner__c OR 
                  RowCause =: Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_BA__c OR 
                  RowCause =: Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_Finance__c OR 
                  RowCause =: Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_RTMK__c OR 
                  RowCause =: Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_WS_Manager__c OR
                  RowCause =: Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_Channel_Manager_On__c OR
                  RowCause =: Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.ASI_CRM_CN_Share_To_Channel_Manager_Off__c)];
      if (!sharesToCreate.isEmpty())
          Database.insert(sharesToCreate);  
   }

   global void finish(Database.BatchableContext BC){
   } 
}