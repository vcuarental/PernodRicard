public class ASI_KOR_CustomSettingValidation {

    Map<ID, String> branchSettingMap;
    Map<ID, String> regionSettingMap;
    Map<ID, String> branchNameMap;
    Map<ID, String> regionNameMap;
    

    private boolean checkBranch(){
       branchSettingMap = new Map<ID, String>();
       branchNameMap = new Map<ID, String>();
       
       List<ASI_KOR_Branches__c> branches = 
            [Select Name, ASI_KOR_Region_Code__c, ASI_KOR_Branch_Code__c, ASI_KOR_Branch_Manager__c 
             From ASI_KOR_Branches__c];
       
       List<ID> managerIDs = new List<ID>();
       for(ASI_KOR_Branches__c branch : branches){
           managerIDs.add(branch.ASI_KOR_Branch_Manager__c);
           branchSettingMap.put(branch.ASI_KOR_Branch_Manager__c, branch.ASI_KOR_Region_Code__c +' '+ branch.ASI_KOR_Branch_Code__c);
           branchNameMap.put(branch.ASI_KOR_Branch_Manager__c, branch.Name);
       }
             
       List<User> managerUser = 
           [Select ASI_KOR_User_Region_Code__c, ID, ASI_KOR_User_Branch_Code__c, UserRole.DeveloperName 
            From User where ID in :managerIDs];
            
       for(User manager : managerUser){
          String temp = branchSettingMap.get(manager.ID);
          String temp2 = branchNameMap.get(manager.ID);
          String roleName = manager.UserRole.DeveloperName;
          if(temp!= (manager.ASI_KOR_User_Region_Code__c +' '+ manager.ASI_KOR_User_Branch_Code__c) ||!roleName.contains('ASI_KOR_TL')){
              apexpages.message err = new apexpages.message(apexpages.severity.error, 
                 'Custom Setting for Branch is currently not up to date please contact your System Administrator. Setting Branch Name : ' + temp2 + '.');
              apexpages.addmessage(err); 
              return false;
          }

       }
            
       return true;
    
    }
    
    private boolean checkRegion(){
   
       regionNameMap = new Map<ID, String>();
       regionSettingMap = new Map<ID, String>();
       List<ASI_KOR_Regions__c> regions = 
            [Select Name, ASI_KOR_Region_Code__c, ASI_KOR_Regional_Sales_Director__c 
             From ASI_KOR_Regions__c];
       
       List<ID> managerIDs = new List<ID>();
       for(ASI_KOR_Regions__c region : regions){
           managerIDs.add(region.ASI_KOR_Regional_Sales_Director__c);
           regionSettingMap.put(region.ASI_KOR_Regional_Sales_Director__c , region.ASI_KOR_Region_Code__c);
           regionNameMap.put(region.ASI_KOR_Regional_Sales_Director__c , region.Name);
       }
             
       List<User> managerUser = 
           [Select ASI_KOR_User_Region_Code__c, ID , UserRole.DeveloperName
            From User where ID in :managerIDs];
            
       for(User manager : managerUser){
          String temp = regionSettingMap.get(manager.ID);
          String temp2 = regionNameMap.get(manager.ID);
          String roleName = manager.UserRole.DeveloperName;
          if(!roleName.toLowerCase().contains('off_trade')){
              if(temp!= (manager.ASI_KOR_User_Region_Code__c ) ||!roleName.contains('_Director')){
                  apexpages.message err = new apexpages.message(apexpages.severity.error, 
                     'Custom Setting for Region is currently not up to date please contact your System Administrator. Setting Region Name : ' + temp2 +'.');
                  apexpages.addmessage(err); 
                  return false;
              }
          }

       }
            
       return true;
    
    }
    
    private boolean checkNation(){
    
               
       List<ASI_KOR_Nation__c> nations = 
            [Select ASI_KOR_National_Sales_Director__c
             From ASI_KOR_Nation__c];
       
       List<ID> managerIDs = new List<ID>();
       for(ASI_KOR_Nation__c nation : nations){
           managerIDs.add(nation.ASI_KOR_National_Sales_Director__c);
       }
             
       List<User> managerUser = 
           [Select UserRole.DeveloperName 
            From User where ID in :managerIDs];
            
       for(User manager : managerUser){
          String roleName = manager.UserRole.DeveloperName;
          if(!roleName.contains('ASI_KOR_National_Sales_Director')){
              apexpages.message err = new apexpages.message(apexpages.severity.error, 
                 'Custom Setting for Nation is currently not up to date please contact your System Administrator.');
              apexpages.addmessage(err); 
              return false;
          }

       }
            
       return true;
    
    }

    public boolean isValid(){
    
        return (checkNation() && checkRegion() && checkBranch());
    }

}