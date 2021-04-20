/*Created by Twinkle Li @01/08/2015
* Apex Sharing Calculation on Payment Request
* Sharing at Division level, share to BA & Finance, RTMK (Read & Write)
* sharing at Division level, share to Channel Manager based on "On/Off" & WS Manager (Read)
*/

global class ASI_CRM_CN_PaymentRequestShare_Batch implements Database.Batchable<sObject>{
   
   global Database.QueryLocator start(Database.BatchableContext BC){
      String soqlQuery;
      if(!Test.isRunningTest())
          soqlQuery = 'SELECT id, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Parent_Outlet__r.ownerId, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Parent_Outlet__r.owner.IsActive, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_Parent_Outlet__r.ownerId, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_Parent_Outlet__r.owner.IsActive, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c, ASI_CRM_Sales_Team__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c FROM ASI_TH_CRM_PaymentRequest__c WHERE RecordType.DeveloperName = \'ASI_CRM_CN_Payment_Request\'';  
      else
          soqlQuery = 'SELECT id, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Parent_Outlet__r.ownerId, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Parent_Outlet__r.owner.IsActive, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_Parent_Outlet__r.ownerId, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_Parent_Outlet__r.owner.IsActive, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c, ASI_CRM_Sales_Team__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c FROM ASI_TH_CRM_PaymentRequest__c WHERE RecordType.DeveloperName = \'ASI_CRM_CN_Payment_Request\' LIMIT 10'; 
      return Database.getQueryLocator(soqlQuery);
   }
   
    global void execute(Database.BatchableContext BC,  List<sObject> scope){
      if (scope == null) return;
      List<ASI_TH_CRM_PaymentRequest__c> lstPR = scope; 
      List<ASI_TH_CRM_PaymentRequest__Share> sharesToCreate = new List<ASI_TH_CRM_PaymentRequest__Share>();
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
              //Users with Read/Write Access
              
              //20160901 Ben @ Elufa
              String salesTeam = obj.ASI_CRM_Sales_Team__c != NULL ? obj.ASI_CRM_Sales_Team__r.Name : '';
              String divison = '';
              if(obj.ASI_CRM_Division__c != NULL)
                  divison = obj.ASI_CRM_Division__c;
              List<ASI_CRM_Division_Security_Setting__c> listOfUser = new List<ASI_CRM_Division_Security_Setting__c>();
              
              if(obj.ASI_CRM_Role__c == 'BA' || obj.ASI_CRM_Role__c == 'Finance' || obj.ASI_CRM_Role__c == 'Regional Trade Marketing'){
                  
                  //20160901 Ben @ Elufa
                  if(cityMapReadWriteUsersList.containsKey( '' + divison + salesTeam)){
                      listOfUser = cityMapReadWriteUsersList.get( '' + divison + salesTeam);
                  }
                  
                  listOfUser.add(obj);
                  
                  cityMapReadWriteUsersList.put( '' + divison + salesTeam, listOfUser);
                  
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
              //Channel Manager with on/off
              else if(obj.ASI_CRM_Role__c == 'Channel Manager'){
                  
                  //20160901 Ben @ Elufa
                  
                  if(cityMapCMUsersList.containsKey( '' + divison + salesTeam + obj.ASI_CRM_On_Off__c)){
                      listOfUser = cityMapCMUsersList.get( '' + divison + salesTeam + obj.ASI_CRM_On_Off__c);
                  }
                  
                  listOfUser.add(obj);
                  
                  cityMapCMUsersList.put( '' + divison + salesTeam + obj.ASI_CRM_On_Off__c, listOfUser);
                  
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
      
      for(ASI_TH_CRM_PaymentRequest__c pr : lstPR){    
          //Share to Parent Outlet
          if(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Parent_Outlet__c != null){
              if(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Parent_Outlet__r.owner != null && pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Parent_Outlet__r.owner.IsActive){
                  ASI_TH_CRM_PaymentRequest__Share newRecord = new ASI_TH_CRM_PaymentRequest__Share();
                  newRecord.ParentId = pr.Id;
                  newRecord.UserOrGroupId = pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Parent_Outlet__r.ownerId;
                  newRecord.AccessLevel = 'Read';         
                  newRecord.RowCause = Schema.ASI_TH_CRM_PaymentRequest__Share.RowCause.ASI_CRM_CN_Share_To_Parent_Outlet_Owner__c;
                  sharesToCreate.add(newRecord);
                  shareIdsToDelete.add(pr.id);
                  
                  //Share to Parent's Parent Outlet
                  if(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_Parent_Outlet__c != null && pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_Parent_Outlet__r.owner != null && pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_Parent_Outlet__r.owner.IsActive){
                      newRecord = new ASI_TH_CRM_PaymentRequest__Share();
                      newRecord.ParentId = pr.Id;
                      newRecord.UserOrGroupId = pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_Parent_Outlet__r.ownerId;
                      newRecord.AccessLevel = 'Read';         
                      newRecord.RowCause = Schema.ASI_TH_CRM_PaymentRequest__Share.RowCause.ASI_CRM_CN_Share_To_PP_Outlet_Owner__c;
                      sharesToCreate.add(newRecord);
                      shareIdsToDelete.add(pr.id);
                  }
              }
          }
                
          //Share at Division level
          if(pr.ASI_CRM_CN_OutletWS__c != null && pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__c != null&& pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c != null){
              
              //20160901 Ben @ Elufa
              
              List<ASI_CRM_Division_Security_Setting__c> listReadOnlyUsers = new List<ASI_CRM_Division_Security_Setting__c>();
              List<ASI_CRM_Division_Security_Setting__c> listReadWriteUsers = new List<ASI_CRM_Division_Security_Setting__c>();
              List<ASI_CRM_Division_Security_Setting__c> listCMUsers = new List<ASI_CRM_Division_Security_Setting__c>();
              
              if(cityMapReadWriteUsersList.containsKey(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + pr.ASI_CRM_Sales_Team__c)){
                  
                  listReadWriteUsers.addAll(cityMapReadWriteUsersList.get(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + pr.ASI_CRM_Sales_Team__c));
              }
              if(cityMapReadWriteUsersList.containsKey(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c)){
                  
                  listReadWriteUsers.addAll(cityMapReadWriteUsersList.get(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c));
              }
              if(cityMapReadWriteUsersList.containsKey(pr.ASI_CRM_Sales_Team__c)){
                  
                  listReadWriteUsers.addAll(cityMapReadWriteUsersList.get(pr.ASI_CRM_Sales_Team__c));
              }
              
              if(cityMapReadOnlyUsersList.containsKey(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + pr.ASI_CRM_Sales_Team__c)){
                  
                  listReadOnlyUsers.addAll(cityMapReadOnlyUsersList.get(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + pr.ASI_CRM_Sales_Team__c));
              }
              if(cityMapReadOnlyUsersList.containsKey(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c)){
                  
                  listReadOnlyUsers.addAll(cityMapReadOnlyUsersList.get(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c));
              }
              if(cityMapReadOnlyUsersList.containsKey(pr.ASI_CRM_Sales_Team__c)){
                  
                  listReadOnlyUsers.addAll(cityMapReadOnlyUsersList.get(pr.ASI_CRM_Sales_Team__c));
              }
              
              String onOff = pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c != NULL ? pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c : ( pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Sub_Channel__c != null && pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__c != null ) ? pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c : '';
              
              if(cityMapCMUsersList.containsKey(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + pr.ASI_CRM_Sales_Team__c + onOff)){
                  
                  listCMUsers.addAll(cityMapCMUsersList.get(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + pr.ASI_CRM_Sales_Team__c + onOff));
              }
              if(cityMapCMUsersList.containsKey(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + onOff)){
                  
                  listCMUsers.addAll(cityMapCMUsersList.get(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c + onOff));
              }
              if(cityMapCMUsersList.containsKey(pr.ASI_CRM_Sales_Team__c + onOff)){
                  
                  listCMUsers.addAll(cityMapCMUsersList.get(pr.ASI_CRM_Sales_Team__c + onOff));
              }
              
              //Share to users with Read/Write access
              if(listReadWriteUsers.size() > 0){//if(!cityMapReadWriteUsersList.IsEmpty() && cityMapReadWriteUsersList.get(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c) != null){
                  for(ASI_CRM_Division_Security_Setting__c obj : listReadWriteUsers){//cityMapReadWriteUsersList.get(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c)){
                      ASI_TH_CRM_PaymentRequest__Share newRecord = new ASI_TH_CRM_PaymentRequest__Share();
                      newRecord.ParentId = pr.Id;
                      newRecord.UserOrGroupId = obj.ASI_CRM_User__c;
                      newRecord.AccessLevel = 'Edit';   
                          
                      if(obj.ASI_CRM_Role__c == 'BA'){      
                          newRecord.RowCause = Schema.ASI_TH_CRM_PaymentRequest__Share.RowCause.ASI_CRM_CN_Share_To_BA__c;
                      }
                      else if(obj.ASI_CRM_Role__c == 'Finance'){
                          newRecord.RowCause = Schema.ASI_TH_CRM_PaymentRequest__Share.RowCause.ASI_CRM_CN_Share_To_Finance__c;
                      }
                      else if(obj.ASI_CRM_Role__c == 'Regional Trade Marketing'){
                          newRecord.RowCause = Schema.ASI_TH_CRM_PaymentRequest__Share.RowCause.ASI_CRM_CN_Share_To_RTMK__c;
                      }
                      sharesToCreate.add(newRecord);
                      shareIdsToDelete.add(pr.id);
                  }
              }
              //Share to users with Read-Only access
              if(listReadOnlyUsers.size() > 0){//if(!cityMapReadOnlyUsersList.IsEmpty() && cityMapReadOnlyUsersList.get(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c) != null){
                  for(ASI_CRM_Division_Security_Setting__c obj : listReadOnlyUsers){//cityMapReadOnlyUsersList.get(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c)){
                      ASI_TH_CRM_PaymentRequest__Share newRecord = new ASI_TH_CRM_PaymentRequest__Share();
                      newRecord.ParentId = pr.Id;
                      newRecord.UserOrGroupId = obj.ASI_CRM_User__c;
                      newRecord.AccessLevel = 'Read';         
                          
                      if(obj.ASI_CRM_Role__c == 'WS Manager'){
                          newRecord.RowCause = Schema.ASI_TH_CRM_PaymentRequest__Share.RowCause.ASI_CRM_CN_Share_To_WS_Manager__c;
                      }
                      sharesToCreate.add(newRecord);
                      shareIdsToDelete.add(pr.id);
                  }
              }
              //Share to Chanel Manager based on channel on/off
              if(listCMUsers.size() > 0){//if(!cityMapCMUsersList.IsEmpty() && pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Sub_Channel__c != null && pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__c != null && cityMapCMUsersList.get(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c+pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c) != null){
                  for(ASI_CRM_Division_Security_Setting__c obj : listCMUsers){//cityMapCMUsersList.get(pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c+pr.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c)){
                      ASI_TH_CRM_PaymentRequest__Share newRecord = new ASI_TH_CRM_PaymentRequest__Share();
                      newRecord.ParentId = pr.Id;
                      newRecord.UserOrGroupId = obj.ASI_CRM_User__c;
                      newRecord.AccessLevel = 'Read'; 
                      
                      if(obj.ASI_CRM_Role__c == 'Channel Manager' && obj.ASI_CRM_On_Off__c == 'On'){
                          newRecord.RowCause = Schema.ASI_TH_CRM_PaymentRequest__Share.RowCause.ASI_CRM_CN_Share_To_Channel_Manager_On__c;
                      }
                      if(obj.ASI_CRM_Role__c == 'Channel Manager' && obj.ASI_CRM_On_Off__c == 'Off'){     
                          newRecord.RowCause = Schema.ASI_TH_CRM_PaymentRequest__Share.RowCause.ASI_CRM_CN_Share_To_Channel_Manager_Off__c;
                      }
                      sharesToCreate.add(newRecord);
                      shareIdsToDelete.add(pr.id);
                  }
              }
          }
      }     
      
      if (!shareIdsToDelete.isEmpty())
          delete [SELECT id FROM ASI_TH_CRM_PaymentRequest__Share WHERE ParentId IN :shareIdsToDelete AND 
                  (RowCause =: Schema.ASI_TH_CRM_PaymentRequest__Share.RowCause.ASI_CRM_CN_Share_To_Parent_Outlet_Owner__c OR 
                  RowCause =: Schema.ASI_TH_CRM_PaymentRequest__Share.RowCause.ASI_CRM_CN_Share_To_PP_Outlet_Owner__c OR 
                  RowCause =: Schema.ASI_TH_CRM_PaymentRequest__Share.RowCause.ASI_CRM_CN_Share_To_BA__c OR 
                  RowCause =: Schema.ASI_TH_CRM_PaymentRequest__Share.RowCause.ASI_CRM_CN_Share_To_Finance__c OR 
                  RowCause =: Schema.ASI_TH_CRM_PaymentRequest__Share.RowCause.ASI_CRM_CN_Share_To_RTMK__c OR 
                  RowCause =: Schema.ASI_TH_CRM_PaymentRequest__Share.RowCause.ASI_CRM_CN_Share_To_WS_Manager__c OR
                  RowCause =: Schema.ASI_TH_CRM_PaymentRequest__Share.RowCause.ASI_CRM_CN_Share_To_Channel_Manager_On__c OR
                  RowCause =: Schema.ASI_TH_CRM_PaymentRequest__Share.RowCause.ASI_CRM_CN_Share_To_Channel_Manager_Off__c)];
          Database.insert(sharesToCreate);  
   }

   global void finish(Database.BatchableContext BC){
       if(!Test.isRunningTest())
           database.executebatch(new ASI_CRM_CN_WSTargetShare_Batch());
   } 
}