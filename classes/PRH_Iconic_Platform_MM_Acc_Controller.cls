global with sharing class PRH_Iconic_Platform_MM_Acc_Controller {

    public List<PRH_Brand_Luxury_Brand__c> brandNames {get;set;}
    public List<PRH_Brand_Criteria__c> brandNamesDesktop {get;set;}
    public Boolean rendered{get;set;} 
    public String checklist{get;set;}

    public PRH_Luxury_Accounts__c luxAcc{get;set;}
    
    public PRH_Iconic_Platform_MM_Acc_Controller(ApexPages.StandardController controller) {
        rendered = true;
        Id loggedInUser=  Userinfo.getUserId();
        System.debug('PRH_Iconic_Platform_MM_Acc_Controller : ' + loggedInUser);
        List<PermissionSetAssignment> permissionList = [SELECT PermissionSetId
                                                        FROM PermissionSetAssignment
                                                        WHERE AssigneeId = :loggedInUser];
        System.debug('PRH_Iconic_Platform_MM_Acc_Controller : ' + permissionList);
        List<ID> idList = new List<ID>();
        for(PermissionSetAssignment psa : permissionList){
            idList.add(psa.PermissionSetId);
        }      
        System.debug('PRH_Iconic_Platform_MM_Acc_Controller : ' + idList);                                          
        List<PermissionSet> permissionNameList = [Select Name From PermissionSet Where ID in :idList];                                          
        Set<String> permissionNames = new Set<String>();
        for(PermissionSet ps : permissionNameList){
            permissionNames.add(ps.name);
        }
        System.debug('PRH_Iconic_Platform_MM_Acc_Controller : ' + permissionNameList);
        if(permissionNames.contains('PRH_Iconic_Platform_USA')||permissionNames.contains('PRH_Iconic_Platform_USA_Sales_Directors')||permissionNames.contains('PRH_Iconic_Platform_USA_Regional_Directors')){
            rendered = false;
        }
        luxAcc = ((PRH_Luxury_Accounts__c)controller.getRecord());
        luxAcc = [Select 
                     id, Name,PRH_Account_Type__c , PRH_Existing_Account__r.Name ,PRH_Detailed_address__c,PRH_City__c,PRH_Full_Active_l_Atelier_Portfolio__c,PRH_Telephone__c,PRH_High_Networth_Individuals__c /*,PRH_Contracted__c */ 
                  From 
                     PRH_Luxury_Accounts__c 
                  Where 
                     id = :luxAcc.id Limit 1];
       
		    System.debug('PRH_Iconic_Platform_MM_Acc_Controller : ' + luxAcc);
        
        PRH_Collect__c activeCollect = [Select Id,PRH_Number_of_Pernod_Ricard_products__c              
				     					                  From PRH_Collect__c
										                    Where PRH_Iconic_Account__c= :luxAcc.id
                                        and PRH_Active__c=true
                                        Limit 1];
        
        brandNamesDesktop = [Select  
                              PRH_Brand__c, PRH_Presence__c, PRH_Collect__c,
                              PRH_Brand__r.RecordType.DeveloperName,
                              PRH_Brand__r.PRH_Sequence__c, PRH_Brand__r.Name, PRH_Brand__r.PRH_Active__c, PRH_Branded_Event__c, PRH_Visibility__c
                             From PRH_Brand_Criteria__c 
                             Where PRH_Collect__c = :activeCollect.id
                             //And PRH_Brand__r.PRH_Active__c = true
                             Order by PRH_Brand__r.PRH_Sequence__c, PRH_Brand__r.Name
                            ];  
		    System.debug('PRH_Iconic_Platform_MM_Acc_Controller : ' + brandNamesDesktop);

        //brandNamesPernod = [Select id,Name From PRH_Brand_Luxury_Brand__c Where RecordType.DeveloperName = 'PRH_Luxury_Account_Pernod' order by PRH_Sequence__c , Name ];
        // brandNamesRicard = [Select id,Name From PRH_Brand_Luxury_Brand__c Where RecordType.DeveloperName = 'PRH_Luxury_Account_Ricard' order by PRH_Sequence__c , Name ];    
        brandNames = [Select id,Name, RecordType.DeveloperName From PRH_Brand_Luxury_Brand__c order by PRH_Sequence__c , Name ];
        
        List<PRH_Brand_Criteria__c> existingList = [ Select PRH_Branded_Event__c,PRH_Brand__c, PRH_Presence__c, PRH_Visibility__c,
                                                    PRH_Brand__r.Name,PRH_Volume__c, PRH_Number_of_Branded_Events__c,PRH_Brand__r.RecordType.DeveloperName              
                                                     From PRH_Brand_Criteria__c 
                                                     Where PRH_Collect__c = :activeCollect.id
                                                     And PRH_Brand__r.PRH_Competitor_Brand__c = false
                                                     //And PRH_Brand__r.PRH_Active__c = true
                                                     Order By PRH_Brand__r.PRH_Sequence__c, PRH_Brand__r.Name
        											                     ];     
        
		    System.debug('PRH_Iconic_Platform_MM_Acc_Controller, brandNames : ' + brandNames);
		    System.debug('PRH_Iconic_Platform_MM_Acc_Controller, existingList : ' + existingList);
        checkList = 'All ';
        if(permissionNames.contains('PRH_Iconic_Platform_Pernod')&& permissionNames.contains('PRH_Iconic_Platform_Ricard')) checkList = 'All ';
        else if(permissionNames.contains('PRH_Iconic_Platform_Pernod')) checkList = 'PRH_Iconic_Platform_Ricard' +  ' ' ;
        else if(permissionNames.contains('PRH_Iconic_Platform_Ricard')) checkList = 'PRH_Iconic_Platform_Pernod'+ ' ';
        
        for(PRH_Brand_Criteria__c criteria: existingList){
            checklist += criteria.PRH_Presence__c +' ';
            checklist += criteria.PRH_Visibility__c +' ';
            checklist += criteria.PRH_Branded_Event__c +' ';
        }
    }

    public PageReference customCancel(){
        return new PageReference('/'+luxAcc.PRH_Existing_Account__c);
    }
    
    @RemoteAction
    global static void submitPage(String checkboxes,ID accID){
        List<PRH_Brand_Luxury_Brand__c> brandNames = [Select id,Name,RecordType.DeveloperName From PRH_Brand_Luxury_Brand__c order by PRH_Sequence__c , Name ];
          
        PRH_Collect__c activeCollect = [Select Id,PRH_Number_of_Pernod_Ricard_products__c              
  			     					                  From PRH_Collect__c
  									                    Where PRH_Iconic_Account__c= :accID
                                        and PRH_Active__c=true
                                        Limit 1];

        List<PRH_Brand_Criteria__c> existingList =
        [Select PRH_Collect__c ,PRH_Branded_Event__c,PRH_Brand__c, PRH_Presence__c, PRH_Visibility__c,
                PRH_Brand__r.Name, PRH_Brand__r.PRH_Active__c
         From PRH_Brand_Criteria__c 
         Where PRH_Collect__c = :activeCollect.id
         //And PRH_Brand__r.PRH_Active__c = true
         Order By PRH_Brand__r.PRH_Sequence__c, PRH_Brand__r.Name
        ];
        
        List<String> checkList = checkboxes.split(' ');
        integer count = 0;
        for(PRH_Brand_Criteria__c criteria: existingList){
            criteria.PRH_Presence__c = Boolean.valueOf(checkList.get(count));
            count++;
            criteria.PRH_Visibility__c = Boolean.valueOf(checkList.get(count));
            count++;
            criteria.PRH_Branded_Event__c = Boolean.valueOf(checkList.get(count));
            count++;
            /*
            criteria.PRH_Visibility_Glorifier__c = Boolean.valueOf(checkList.get(count));
            count++;
            criteria.PRH_Visibility_POSM__c = Boolean.valueOf(checkList.get(count));
            count++;
            criteria.PRH_Visibility_Tailor_Made__c = Boolean.valueOf(checkList.get(count));
            count++;
            criteria.PRH_Activation_Staff_incentive__c = Boolean.valueOf(checkList.get(count));
            count++;           
            criteria.PRH_Activation_Tasting__c = Boolean.valueOf(checkList.get(count));
            count++;          
            criteria.PRH_Activation_Event__c = Boolean.valueOf(checkList.get(count));
            count++;
            */
        }
        PRH_Collect__c updateTimeCollect=[Select PRH_Collect_Last_Modified_Date__c 
                                                          From PRH_Collect__c 
                                                  	      where PRH_Iconic_Account__c =:accID 
                                                          and PRH_Active__c=true Limit 1];
          				updateTimeCollect.PRH_Collect_Last_Modified_Date__c = System.now();    
          				update updateTimeCollect;
                        System.Debug('PRH_Iconic_Platform_MM_Acc_Controller submitPage updateTimeCollect :'+ updateTimeCollect);
                        
                        PRH_Competitor_Brand_Controller.setNumberOfPRProducts(accID);
           		        //LCS-158 Verify presence of Le Cercle Brand Product
          				PRH_Competitor_Brand_Controller.setLCBPresence(accID);
                        system.debug('@@@@@@@@@@@@@@ updateTimeCollect : '+ updateTimeCollect);
                        system.debug('@@@@@@@@@@@@@@ iconicAccount : '+ accID);
       // PRH_Luxury_Accounts__c updateTime = [Select PRH_Last_Updated_Date__c From PRH_Luxury_Accounts__c where ID = :accID Limit 1];
       // updateTIme.PRH_Last_Updated_Date__c = System.now();
       // update updateTime;
        try{
            update existingList;
        }
        catch(System.DMLException e){
            /*String errorMessage = 'Presence - absent for: \n';
            for(PRH_Brand_Criteria__c criteria : existingList){
              if(criteria.PRH_Presence__c ==false &&(
              criteria.PRH_Visibility__c ==true||                 
              criteria.PRH_Branded_Event__c ==true)){
                  errorMessage += '<' +criteria.PRH_Brand__r.Name +'>'+'\n';
              }
            }*/
            String errorMessage = 'Presence - absent for existingList: ' + existingList;
            e.setMessage(errorMessage);
            throw e;
        }
    }
    
    public PageReference savePage(){
        try{
            update brandNamesDesktop;
            //PRH_Luxury_Accounts__c updateTime=[Select PRH_Last_Updated_Date__c From PRH_Luxury_Accounts__c where ID = :luxacc.ID Limit 1];
            //updateTIme.PRH_Last_Updated_Date__c = System.now();
            //update updateTime;
            //System.Debug('PRH_Iconic_Platform_MM_Acc_Controller savePage updateTIme :'+ updateTime);
            return new PageReference('/'+luxAcc.PRH_Existing_Account__c);
        }catch(System.DMLException e){
            String errorMessage ='Presence - absent for ';
            for(PRH_Brand_Criteria__c criteria : brandNamesDesktop){
                if(criteria.PRH_Presence__c == false &&
                  (criteria.PRH_Visibility__c == true || criteria.PRH_Branded_Event__c == true)){
                    errorMessage += '"' +criteria.PRH_Brand__r.Name +'", ';
                }
            }
            errorMessage = errorMessage.subString(0,errorMessage.length()-2) + ' ';
             
            apexpages.message err = new apexpages.message(apexpages.severity.error,errorMessage);
            apexpages.addmessage(err);
            return null;
        } 
    }
}