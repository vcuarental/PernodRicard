/*Created by Twinkle Li @01/08/2015
* Apex Sharing Calculation on City Sales Target
* Sharing at Division level, share to BA, Finance, RTMK & WS Manager (Read)
*/

global class ASI_CRM_CN_CitySalesTargetShare_Batch implements Database.Batchable<sObject>{  
    global Database.QueryLocator start(Database.BatchableContext BC){
        String soqlQuery;
        if(!Test.isRunningTest())
            soqlQuery = 'SELECT id, ASI_CRM_City__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c FROM ASI_CRM_City_Sales_Target__c WHERE RecordType.DeveloperName = \'ASI_CRM_CN_City_Sales_Target\'';  
        else
            soqlQuery = 'SELECT id, ASI_CRM_City__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c FROM ASI_CRM_City_Sales_Target__c WHERE RecordType.DeveloperName = \'ASI_CRM_CN_City_Sales_Target\' LIMIT 10'; 
        return Database.getQueryLocator(soqlQuery);
    }   
    global void execute(Database.BatchableContext BC,  List<sObject> scope){
        if (scope == null) return;
        List<ASI_CRM_City_Sales_Target__c> lstCSTarget = scope; 
        List<ASI_CRM_City_Sales_Target__Share> sharesToCreate = new List<ASI_CRM_City_Sales_Target__Share>();
        List<ID> shareIdsToDelete = new List<ID>();
        List<ASI_CRM_Division_Security_Setting__c> listReadOnlyUsers;
        Map<String, List<ASI_CRM_Division_Security_Setting__c>> cityMapReadOnlyUsersList = new Map<String, List<ASI_CRM_Division_Security_Setting__c>>();
      
        List<ASI_CRM_Division_Security_Setting__c> lstDivSecSetting = [SELECT id, ASI_CRM_Division__c, ASI_CRM_Role__c, ASI_CRM_User__c, ASI_CRM_User__r.IsActive FROM ASI_CRM_Division_Security_Setting__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Division_Security_Setting' AND (ASI_CRM_Role__c = 'BA' OR ASI_CRM_Role__c = 'Finance' OR ASI_CRM_Role__c = 'Regional Trade Marketing' OR ASI_CRM_Role__c = 'WS Manager' OR ASI_CRM_Role__c = 'Channel Manager')];
        Map<String, ASI_CRM_Division_Security_Setting__c> mapDivSecSetting = new Map<String, ASI_CRM_Division_Security_Setting__c>();
      
        for(ASI_CRM_Division_Security_Setting__c obj: lstDivSecSetting){
            if(obj.ASI_CRM_User__C != null && obj.ASI_CRM_User__r.IsActive){
                if(obj.ASI_CRM_Role__c == 'BA' || obj.ASI_CRM_Role__c == 'Finance' || obj.ASI_CRM_Role__c == 'Regional Trade Marketing' || obj.ASI_CRM_Role__c == 'WS Manager'){
                    if(cityMapReadOnlyUsersList.get(obj.ASI_CRM_Division__c) == null){
                        listReadOnlyUsers = new List<ASI_CRM_Division_Security_Setting__c>();
                        listReadOnlyUsers.add(obj);
                        cityMapReadOnlyUsersList.put(obj.ASI_CRM_Division__c, listReadOnlyUsers);
                    }
                    else{
                        listReadOnlyUsers = new List<ASI_CRM_Division_Security_Setting__c>();
                        listReadOnlyUsers = cityMapReadOnlyUsersList.get(obj.ASI_CRM_Division__c);
                        listReadOnlyUsers.add(obj);
                        cityMapReadOnlyUsersList.put(obj.ASI_CRM_Division__c, listReadOnlyUsers);
                    }
                }
            }
        }
      
        for(ASI_CRM_City_Sales_Target__c target: lstCSTarget){          
            //Share at Division level
            if(!cityMapReadOnlyUsersList.IsEmpty() && cityMapReadOnlyUsersList.get(target.ASI_CRM_City__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c) != null){
                for(ASI_CRM_Division_Security_Setting__c obj : cityMapReadOnlyUsersList.get(target.ASI_CRM_City__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c)){
                    ASI_CRM_City_Sales_Target__Share newRecord = new ASI_CRM_City_Sales_Target__Share();
                    newRecord.ParentId = target.Id;
                    newRecord.UserOrGroupId = obj.ASI_CRM_User__c;
                    newRecord.AccessLevel = 'Read';        
                  
                    if(obj.ASI_CRM_Role__c == 'BA'){                           
                        newRecord.RowCause = Schema.ASI_CRM_City_Sales_Target__Share.RowCause.ASI_CRM_CN_Share_To_BA__c;                        
                    }
                    else if(obj.ASI_CRM_Role__c == 'Finance'){
                        newRecord.RowCause = Schema.ASI_CRM_City_Sales_Target__Share.RowCause.ASI_CRM_CN_Share_To_Finance__c;
                    }
                    else if(obj.ASI_CRM_Role__c == 'Regional Trade Marketing'){   
                        newRecord.RowCause = Schema.ASI_CRM_City_Sales_Target__Share.RowCause.ASI_CRM_CN_Share_To_RTMK__c;
                    }
                    else if(obj.ASI_CRM_Role__c == 'WS Manager'){     
                        newRecord.RowCause = Schema.ASI_CRM_City_Sales_Target__Share.RowCause.ASI_CRM_CN_Share_To_WS_Manager__c;
                    }
                    sharesToCreate.add(newRecord);
                    shareIdsToDelete.add(target.id);
              }
          }
      }     
      
      if (!shareIdsToDelete.isEmpty())
          delete [SELECT id FROM ASI_CRM_City_Sales_Target__Share WHERE ParentId IN :shareIdsToDelete AND 
                  (RowCause =: Schema.ASI_CRM_City_Sales_Target__Share.RowCause.ASI_CRM_CN_Share_To_BA__c OR 
                  RowCause =: Schema.ASI_CRM_City_Sales_Target__Share.RowCause.ASI_CRM_CN_Share_To_Finance__c OR 
                  RowCause =: Schema.ASI_CRM_City_Sales_Target__Share.RowCause.ASI_CRM_CN_Share_To_RTMK__c OR 
                  RowCause =: Schema.ASI_CRM_City_Sales_Target__Share.RowCause.ASI_CRM_CN_Share_To_WS_Manager__c)];
          Database.insert(sharesToCreate);  
   }

   global void finish(Database.BatchableContext BC){
   }
}