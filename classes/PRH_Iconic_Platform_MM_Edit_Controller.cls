global with sharing class PRH_Iconic_Platform_MM_Edit_Controller {

    public List<PRH_Brand_Luxury_Brand__c> brandNames {get;set;}
    public List<PRH_Brand_Criteria__c> brandNamesDesktop {get;set;}
    public Boolean rendered{get;set;} 
    public String checklist{get;set;}
    public PRH_Collect__c nbPresence{get;set;}
    public PRH_Luxury_Accounts__c luxAcc{get;set;}
      public String PRH_ActiveCollectTitle{get;set;}
   
    public PRH_Competitor_Brand_Controller competitorBrandCon {get;set;}
    public List <PRH_Brand_Criteria__c> existingList {get;set;}
    public Boolean refreshPage {get;set;}
    public String currentURL {get;set;}
    public String accountURLParam {get;set;}
    public PRH_Iconic_Platform_MM_Edit_Controller(ApexPages.StandardController controller) {
        
        PRH_Collect__c activeCollect;  
        competitorBrandCon = new PRH_Competitor_Brand_Controller();
        refreshPage = false;
        rendered = true;
        Id loggedInUser=  Userinfo.getUserId();
            String periodStart;
            String periodEnd;
        System.debug('PRH_Iconic_Platform_MM_Edit_Controller, loggedInUser : ' + loggedInUser);
        
        //record id in account or eu account object
        accountURLParam = ApexPages.currentPage().getParameters().get('AcctID');
        
        List<PermissionSetAssignment> permissionList = [SELECT PermissionSetId
                                                        FROM PermissionSetAssignment
                                                        WHERE AssigneeId = :loggedInUser];
        System.debug('PRH_Iconic_Platform_MM_Edit_Controller, permissionList : ' + permissionList);
        List<ID> idList = new List<ID>();
        for(PermissionSetAssignment psa : permissionList){
            idList.add(psa.PermissionSetId);
        }      
        System.debug('PRH_Iconic_Platform_MM_Edit_Controller, idList : ' + idList);                                          
        List<PermissionSet> permissionNameList = [Select Name From PermissionSet Where ID in :idList];                                          
        Set<String> permissionNames = new Set<String>();
        for(PermissionSet ps : permissionNameList){
            permissionNames.add(ps.name);
        }
        System.debug('PRH_Iconic_Platform_MM_Edit_Controller, permissionNameList : ' + permissionNameList);
        if(permissionNames.contains('PRH_Iconic_Platform_USA')||permissionNames.contains('PRH_Iconic_Platform_USA_Sales_Directors')||permissionNames.contains('PRH_Iconic_Platform_USA_Regional_Directors')){
            rendered = false;
        }

        luxAcc = ((PRH_Luxury_Accounts__c)controller.getRecord());
        System.debug('PRH_Iconic_Platform_MM_Edit_Controller : ' + luxAcc);
        luxAcc =[Select 
                     id, Name, PRH_Account_Type__c, PRH_Existing_Account__r.Name, PRH_Detailed_address__c, PRH_City__c, PRH_Telephone__c, PRH_High_Networth_Individuals__c /*, PRH_Contracted__c */
                 From 
                     PRH_Luxury_Accounts__c 
                 Where 
                     id = :luxAcc.id Limit 1];
      
        /* brandNamesDesktop = 
        [Select  
                PRH_Account__c ,PRH_Brand__c, PRH_Presence__c,
                PRH_Brand__r.RecordType.DeveloperName ,
                PRH_Brand__r.PRH_Sequence__c,PRH_Brand__r.Name,PRH_Branded_Event__c, PRH_Visibility__c, 
                PRH_Volume__c, PRH_Number_of_Branded_Events__c
         From PRH_Brand_Criteria__c 
         Where PRH_Account__c = :luxAcc.id
         AND PRH_Brand__r.PRH_Competitor_Brand__c=false
         Order by PRH_Brand__r.PRH_Sequence__c , PRH_Brand__r.Name
        ];  */
 
        //brandNamesPernod = [Select id,Name From PRH_Brand_Luxury_Brand__c Where RecordType.DeveloperName = 'PRH_Luxury_Account_Pernod' order by PRH_Sequence__c , Name ];
        //brandNamesRicard = [Select id,Name From PRH_Brand_Luxury_Brand__c Where RecordType.DeveloperName = 'PRH_Luxury_Account_Ricard' order by PRH_Sequence__c , Name ];    
        brandNames = [Select id,Name, RecordType.DeveloperName From PRH_Brand_Luxury_Brand__c WHERE PRH_Competitor_Brand__c=false order by PRH_Sequence__c , Name ];
    
        //Add collect
        activeCollect = [Select Id, PRH_Number_of_Pernod_Ricard_products__c, PRH_Period_End__c, PRH_Period_Start__c              
                                   From PRH_Collect__c
                                     Where PRH_Iconic_Account__c = :luxAcc.id
                                     And PRH_Active__c = true
                           Limit 1];
        
        System.debug('PRH_Iconic_Platform_MM_Edit_Controller, activeCollect : ' + activeCollect);
        if(activeCollect!=null){
            //Query informations of PRH_Brand_Criteria__c with the collect
            existingList = [select PRH_Brand__c, PRH_Presence__c , PRH_Visibility__c, PRH_Brand__r.Name, PRH_Account_Name__c, PRH_Branded_Event__c, PRH_Volume__c, PRH_Number_of_Branded_Events__c, PRH_Brand__r.PRH_Active__c, PRH_Brand__r.RecordType.DeveloperName
                                        From PRH_Brand_Criteria__c
                                Where PRH_Collect__c = :activeCollect.Id
                                //And PRH_Brand__r.PRH_Active__c = True    // LCS-159
                              Order By PRH_Brand__r.PRH_Sequence__c, PRH_Brand__r.Name];
                   
                System.debug('PRH_Iconic_Platform_MM_Edit_Controller, brandNames : ' + brandNames);
                System.debug('PRH_Iconic_Platform_MM_Edit_Controller, existingList : ' + existingList);
                
                periodStart = activeCollect.PRH_Period_Start__c.day() + '/' + activeCollect.PRH_Period_Start__c.month() + '/' + activeCollect.PRH_Period_Start__c.year();
                periodEnd = activeCollect.PRH_Period_End__c.day() + '/' + activeCollect.PRH_Period_End__c.month() + '/' + activeCollect.PRH_Period_End__c.year();
                PRH_ActiveCollectTitle = 'Collect ' + periodStart + ' to ' + periodEnd; 
            
            checkList='All ';
            if(permissionNames.contains('PRH_Iconic_Platform_Pernod')&& permissionNames.contains('PRH_Iconic_Platform_Ricard')) checkList = 'All ';
            else if(permissionNames.contains('PRH_Iconic_Platform_Pernod')) checkList = 'PRH_Iconic_Platform_Ricard' +  ' ' ;
            else if(permissionNames.contains('PRH_Iconic_Platform_Ricard')) checkList = 'PRH_Iconic_Platform_Pernod'+ ' ';
            
            for(PRH_Brand_Criteria__c criteria: existingList){
                checklist += criteria.PRH_Presence__c + ' ';
                checklist += criteria.PRH_Visibility__c + ' ';
                checklist += criteria.PRH_Branded_Event__c + ' ';
                checklist += criteria.PRH_Number_of_Branded_Events__c + ' ';
                checklist += criteria.PRH_Volume__c + ' ';      
            }
            equateFieldsToZero();
        }
    }
   
    //SAVE COMPETITOR BRAND
    @RemoteAction
    global static String doMobileSave(List<String> cbwStringList) {
        return PRH_Competitor_Brand_Controller.doMobileSave(cbwStringList);
    }

    public void equateFieldsToZero() {        
        System.debug('equateFieldsToZero, existingList.size() : ' + existingList.size());
        //equate to zero
        if (existingList != null && existingList.size()>0) {
            for (PRH_Brand_Criteria__c b: existingList) {
                System.debug('equateFieldsToZero, PRH_Brand_Criteria__c : ' + b.PRH_Account_Name__c);

                b.PRH_Volume__c = (b.PRH_Volume__c == null) ? 0: b.PRH_Volume__c;
                b.PRH_Number_of_Branded_Events__c = (b.PRH_Number_of_Branded_Events__c == null) ? 0: b.PRH_Number_of_Branded_Events__c;
            }
        }
    }
    
    public PageReference customCancel(){
        PageReference pageRef;
                   
        if (accountURLParam != null) {
            pageRef = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' +accountURLParam);
        } else {
            pageRef = new PageReference('/apex/PRH_Luxury_Account?id='+luxAcc.id);  
        }
        return pageRef;
    }
   
    
    //SAVE LE CERCLE BRAND
    @RemoteAction
    global static String submitPage(String checkboxes,ID accID){
        List<PRH_Brand_Luxury_Brand__c> brandNames = [Select id,Name,RecordType.DeveloperName From PRH_Brand_Luxury_Brand__c WHERE PRH_Competitor_Brand__c=false order by PRH_Sequence__c , Name ];        
          
        //Add collect
        PRH_Collect__c activeCollect = [Select Id, PRH_Number_of_Pernod_Ricard_products__c, PRH_Le_Cercle_Brand_Presence__c             
                                                          From PRH_Collect__c
                                                            Where PRH_Iconic_Account__c = :accID
                                        And PRH_Active__c = true
                                        Limit 1];
        
        List<PRH_Brand_Criteria__c> existingList = [ Select Name, PRH_Branded_Event__c, PRH_Brand__c, PRH_Presence__c, PRH_Visibility__c,
                                                     PRH_Brand__r.Name, PRH_Volume__c, PRH_Number_of_Branded_Events__c,
                                                     PRH_Brand__r.RecordType.DeveloperName, PRH_Brand__r.PRH_Active__c              
                                                     From PRH_Brand_Criteria__c 
                                                     Where PRH_Collect__c = :activeCollect.id
                                                     And PRH_Brand__r.PRH_Competitor_Brand__c = false
                                                     //And PRH_Brand__r.PRH_Active__c = true    // LCS-159
                                                     Order By PRH_Brand__r.PRH_Sequence__c, PRH_Brand__r.Name
                                                                         ];

        List<String> checkList = checkboxes.split(' ');
        system.debug('@@@checklist: '+checkList);
        system.debug('@@@@@@@@@@@@@@@@@ existingList.size'+existingList.size());
        system.debug('@@@@@@@@@@@@@@@@@ existingList='+existingList);
          
        integer count = 0;
        for(PRH_Brand_Criteria__c criteria: existingList){
            criteria.PRH_Presence__c =Boolean.valueOf(checkList.get(count));
            system.debug('@@@@@@@@@@@@@@@@@ criteria.PRH_Presence__c='+criteria.PRH_Presence__c);
            system.debug('@@@@@@@@@@@@@@@@@ count='+count);
            count++;
            criteria.PRH_Visibility__c = Boolean.valueOf(checkList.get(count));
            count++;
            criteria.PRH_Branded_Event__c = Boolean.valueOf(checkList.get(count));
            count++;
            criteria.PRH_Number_of_Branded_Events__c = Integer.valueOf(checklist.get(count));
            count++; 
            criteria.PRH_Volume__c = Integer.valueOf(checkList.get(count));           
            count++;         
        }
        Set<String> errMessageSet = new Set<String>();
        String errMessage = '';

        for (PRH_Brand_Criteria__c criteria : existingList){
            if(criteria.PRH_Presence__c == false && (
                criteria.PRH_Visibility__c == true||                 
                criteria.PRH_Branded_Event__c == true || 
                criteria.PRH_Volume__c > 0 || criteria.PRH_Number_of_Branded_Events__c > 0)){
                    errMessageSet.add(criteria.PRH_Brand__r.Name+'\n');
            }
            if (criteria.PRH_Branded_Event__c == false && criteria.PRH_Number_of_Branded_Events__c>0) {
                errMessageSet.add(criteria.PRH_Brand__r.Name+'\n');
            }
        }
        errMessage = PRH_Competitor_Brand_Controller.convertSetofString(errMessageSet);
        system.debug('@@@@@@@@@@@1 '+errMessage);

        if (errMessage != '') {
            return 'Presence or Branded Event - absent for: ' + '\n' + errMessage;
        } else {
            // Not use because last modification of collect shall not appear in iconic account
            // PRH_Luxury_Accounts__c updateTime=[Select PRH_Last_Updated_Date__c From PRH_Luxury_Accounts__c where ID = :accID Limit 1];
            // updateTIme.PRH_Last_Updated_Date__c = System.now();
            // update updateTime;
            try{
                update existingList;
                  // Not use because last modification of collect shall not appear in iconic account
                //PRH_Competitor_Brand_Controller.setLastModifiedByInAccount(UserInfo.getUserId(),accID);
                
                PRH_Collect__c updateTimeCollect=[Select PRH_Collect_Last_Modified_Date__c 
                                                  From PRH_Collect__c 
                                                  where PRH_Iconic_Account__c = :accID 
                                                  and PRH_Active__c=true 
                                                  Limit 1];
                updateTimeCollect.PRH_Collect_Last_Modified_Date__c = System.now();    
                update updateTimeCollect;
                System.Debug('updateTimeCollect :'+ updateTimeCollect);
                
                  PRH_Competitor_Brand_Controller.setNumberOfPRProducts(accID);
                //LCS-158 Verify presence of Le Cercle Brand Product
                PRH_Competitor_Brand_Controller.setLCBPresence(accID);
            }catch(System.DMLException e){
                System.Debug('### error:'+ e.getMessage());
                System.Debug('### error:'+ e.getLineNumber());
                System.Debug('### error:'+ e.getStackTraceString());
                throw e;            
            }
        }

        return null;
    }

    public String getFiscalYrLabel() {  
        Datetime dt = System.now();
        String objColumnLabel = '';
        String julyOnwardsMonth = 'FYTD '+String.valueOf(dt.year()).substring(2,4)
                    +'/'+String.valueOf(dt.year()+1).substring(2,4)+ ' Vol (in Liters)';
        String belowJulyMonth = 'FYTD '+String.valueOf(dt.year()-1).substring(2,4)+'/'
                    +String.valueOf(dt.year()).substring(2,4) + ' Vol (in Liters)';
        objColumnLabel = (dt.month()>=7) ? julyOnwardsMonth : belowJulyMonth;

        return objColumnLabel;
    }

    public String getFiscalYrNbActivation() {
        Datetime dt = System.now();
        String objColumnLabel = '';
        String julyOnwardsMonth = 'FYTD '+String.valueOf(dt.year()).substring(2,4)
                    +'/'+String.valueOf(dt.year()+1).substring(2,4) + ' N° Activations';
        String belowJulyMonth = 'FYTD '+String.valueOf(dt.year()-1).substring(2,4)+'/'
                    +String.valueOf(dt.year()).substring(2,4) + ' N° Activations';
        objColumnLabel = (dt.month()>=7) ? julyOnwardsMonth : belowJulyMonth;

        return objColumnLabel;
    }
    
    public PageReference savePage(){    
        try{
            String errorMessage ='Presence - absent for ';
            String brandedEvtErrMsg = 'Branded Event - absent for ';
            Boolean presenceWithError = false;
            Boolean brandedEvtWithError = false;
            Integer nbPoductsPresence =0;
            system.debug('savePage(): '+existingList);
            for(PRH_Brand_Criteria__c criteria : existingList){
                if(criteria.PRH_Presence__c == false &&(
                criteria.PRH_Visibility__c == true ||     
                criteria.PRH_Branded_Event__c == true ||
                criteria.PRH_Volume__c > 0 || criteria.PRH_Number_of_Branded_Events__c > 0)){
                    presenceWithError = true;
                    errorMessage += '"' + criteria.PRH_Brand__r.Name +'", ';
                }

                if (criteria.PRH_Branded_Event__c == false && criteria.PRH_Number_of_Branded_Events__c > 0) {
                    brandedEvtWithError = true;
                    brandedEvtErrMsg += '"'+criteria.PRH_Brand__r.Name + '", ';
                }
                // if (criteria.PRH_Presence__c == true ) {
                // nbPoductsPresence = nbPoductsPresence +1;
                // }
            }
            // system.debug('Test nbPresence: '+nbPoductsPresence);
            
            if (presenceWithError) {
                errorMessage = errorMessage.subString(0,errorMessage.length()-2) + ' ';             
                apexpages.message err = new apexpages.message(apexpages.severity.error,errorMessage);
                apexpages.addmessage(err);
            }

            if (brandedEvtWithError) {
                brandedEvtErrMsg = brandedEvtErrMsg.subString(0,brandedEvtErrMsg.length()-2) + ' ';
                apexpages.message err2 = new apexpages.message(apexpages.severity.error,brandedEvtErrMsg);
                apexpages.addmessage(err2);
            } 

            if (presenceWithError || brandedEvtWithError) {
                refreshPage = false;
                return null;
            }
            
            try {
                update existingList;
                //PRH_Luxury_Accounts__c updateTime=[Select PRH_Last_Updated_Date__c From PRH_Luxury_Accounts__c where ID = :luxacc.ID Limit 1];
                //updateTIme.PRH_Last_Updated_Date__c = System.now();
                // update updateTime;
                
                PRH_Collect__c updateTimeCollect=[Select PRH_Collect_Last_Modified_Date__c 
                                                  From PRH_Collect__c 
                                                  where PRH_Iconic_Account__c = :luxacc.ID 
                                                  and PRH_Active__c=true 
                                                  Limit 1];
                updateTimeCollect.PRH_Collect_Last_Modified_Date__c = System.now();    
                update updateTimeCollect;
                System.Debug('updateTimeCollect :'+ updateTimeCollect);
                /* PRH_Collect__c updateNumberPRProducts=[select PRH_Number_of_Pernod_Ricard_products__c              
                         From PRH_Collect__c
                        Where PRH_Iconic_Account__c= :luxAcc.id
                        and PRH_Active__c=true
                          Limit 1];
                
                updateNumberPRProducts.PRH_Number_of_Pernod_Ricard_products__c=nbPoductsPresence;
                update updateNumberPRProducts;*/
                                               
                // Not use because last modification of collect shall not appear in iconic account
                // PRH_Competitor_Brand_Controller.setLastModifiedByInAccount(UserInfo.getUserId(),luxAcc.id);
               
                PRH_Competitor_Brand_Controller.setNumberOfPRProducts(luxAcc.id);
                
                //LCS-158 Verify presence of Le Cercle Brand Product
                PRH_Competitor_Brand_Controller.setLCBPresence(luxAcc.id);
                refreshPage = true;
            } 
            catch(System.DMLException e)
            {
                System.Debug('### error:'+ e.getMessage());              
            }
            
            currentURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + luxAcc.id;
            System.debug('Test accountURLParam :'  + accountURLParam );
            if (accountURLParam != null) {
                return new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' +accountURLParam);   
            }
            return null;  
            
            //return new PageReference('/apex/PRH_Luxury_Account?id='+luxAcc.id);
        }
        catch(System.DMLException e){
            /*String errorMessage ='Presence - absent for ';
            for(PRH_Brand_Criteria__c criteria : brandNamesDesktop){
              if(criteria.PRH_Presence__c ==false &&(
              criteria.PRH_Visibility__c ==true ||     
              criteria.PRH_Branded_Event__c ==true ||
              criteria.PRH_Volume__c > 0)){
                  errorMessage += '"' +criteria.PRH_Brand__r.Name +'", ';
              }
            } 
            errorMessage = errorMessage.subString(0,errorMessage.length()-2) + ' ';*/
            System.Debug('### error:'+ e.getMessage());
            System.Debug('### error:'+ e.getLineNumber());
            System.Debug('### error:'+ e.getStackTraceString());
            
            //apexpages.message err = new apexpages.message(apexpages.severity.error,''+e);
            //apexpages.addmessage(err);
            refreshPage = false;
            return null;
        }
    }
}