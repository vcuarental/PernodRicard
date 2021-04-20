/********************************************************************************************
 * Name: PRH_IconicBriefcaseMappingBatch                                                    *
 * Description: Batch job class for syncing US Brands and Iconic Brands                     *
 *                                                                                          *
 * Version History                                                                          *
 * Date             Developer               Comments                                        *
 * ---------------  --------------------    ------------------------------------------------*
 * 10/03/2015       Laputa                  Created                                         *
 * 03/01/2017       CGI                     Modification of core model (add collect)        * 
 * 03/07/2017       CGI                     Evolution LCS-159                               *
 * 07/12/2017       CGI                     Evolution LCS-218                               *
*********************************************************************************************/

global class PRH_IconicBriefcaseMappingBatch implements Database.Batchable<sObject>{
    global final String brandName;
    global final String emailAdd;
    global final String surveyName;
    global final Boolean branded;
    global Set<String> USbrandName;
    global Map<String, Set<String>> brandUSIconicMaps;
    
    List<PRH_Luxury_Accounts__c > listlux = [SELECT id, PRH_Existing_Account__c
                                             FROM PRH_Luxury_Accounts__c    
                                             WHERE PRH_Existing_Account__c != ''];
    
    
    global PRH_Luxury_Accounts__c retrieveExistingAccForBrandC (PRH_Brand_Criteria__c brandC){
        
        id brandacc= brandC.PRH_Collect__r.PRH_Iconic_Account__c;
        PRH_Luxury_Accounts__c exAcc;
        
        For(PRH_Luxury_Accounts__c luxAcc :listlux){
            if (luxAcc.id==brandacc){
                exAcc=luxAcc;
            }
            else
            {
               exAcc=null; 
            }
        }
            
        system.debug('*** retrieveExistingAccForBrandC : ' + exAcc);
        return exAcc;
    }

    global PRH_Luxury_Accounts__c retrieveExistingAccForCompetitorB (PRH_Competitor_Brands__c compBrand){
        
        id compBrandAcc= compBrand.PRH_Collect__r.PRH_Iconic_Account__c;
        PRH_Luxury_Accounts__c exAcc;
        
        For(PRH_Luxury_Accounts__c luxAcc :listlux){
            if (luxAcc.id==compBrandAcc){
                exAcc=luxAcc;
            }
            else
            {
               exAcc=null; 
            }
        }
            
        system.debug('*** retrieveExistingAccForCompetitorB : ' + exAcc);
        return exAcc;
    }
    
    global PRH_IconicBriefcaseMappingBatch(String brandName, String surveyName, String emailAdd){
        this.brandName = brandName;
        this.emailAdd = emailAdd;
        this.surveyName = surveyName;
        system.debug('*** PRH_IconicBriefcaseMappingBatch() surveyName: ' + surveyName);
        
        //keys: Iconic Brands / Values: US Brands
        brandUSIconicMaps = new Map<String, Set<String>>();
        List<PRH_Iconic_Briefcase_Mapping__c> mappings = PRH_Iconic_Briefcase_Mapping__c.getall().values();
        
        for(PRH_Iconic_Briefcase_Mapping__c maps :mappings){
            if(!brandUSIconicMaps.keySet().contains(maps.PRH_Iconic_Brands__c)){
                Set<String> tempUSBrands = new Set<String>();
                tempUSBrands.add(maps.PRH_US_Brands__c);
                brandUSIconicMaps.put(maps.PRH_Iconic_Brands__c, tempUSBrands);
                system.debug('*** PRH_IconicBriefcaseMappingBatch tempUSBrands: ' + tempUSBrands);
            }else{
                brandUSIconicMaps.get(maps.PRH_Iconic_Brands__c).add(maps.PRH_US_Brands__c);
                system.debug('*** PRH_IconicBriefcaseMappingBatch maps.PRH_US_Brands__c: ' + maps.PRH_US_Brands__c);
            }
        }
        system.debug('*** PRH_IconicBriefcaseMappingBatch brandUSIconicMaps: ' + brandUSIconicMaps);
        
        USbrandName = new Set<String>();
        if(brandName.trim() != 'All'){
            USbrandName = brandUSIconicMaps.get(brandName);
            branded = true;
            system.debug('*** PRH_IconicBriefcaseMappingBatch USbrandName: ' + USbrandName + ' branded: ' + branded);
        }else{
            branded = false;
            system.debug('*** PRH_IconicBriefcaseMappingBatch branded: ' + branded);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        
        if(brandName.trim() == 'All'){
            query = 'Select Id, USA_Survey_Response__c, USA_Survey_Response__r.USA_Account__c, ' +
                        'USA_Question_Header__c, USA_Question_Label__c, USA_Answer__c ' +
                        'From USA_Survey_Answer__c ' +
                        'Where (USA_Answer__c = \'yes\' OR USA_Answer__c = \'no\') ' +
                        'AND USA_Survey__c =: surveyName ' +
                        'ORDER BY USA_Survey_Response__r.USA_Account__c ASC, USA_Answer__c ASC,USA_Question_Label__c ASC, LastModifiedDate ASC';
        }else{
            query = 'Select Id, USA_Survey_Response__c, USA_Survey_Response__r.USA_Account__c, ' +
                        'USA_Question_Header__c, USA_Question_Label__c, USA_Answer__c ' +
                        'From USA_Survey_Answer__c ' +
                        'Where (USA_Answer__c = \'yes\' OR USA_Answer__c = \'no\') ' +
                        'AND USA_Question_Label__c IN: USbrandName ' +
                        'AND USA_Survey__c =: surveyName ' +
                        'ORDER BY USA_Survey_Response__r.USA_Account__c ASC, USA_Question_Label__c ASC';
        }
        system.debug('*** PRH_IconicBriefcaseMappingBatch start query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('*** PRH_IconicBriefcaseMappingBatch execute branded: ' + branded);
        system.debug('*** PRH_IconicBriefcaseMappingBatch execute scope: "' + scope+'"');
        Map<String, Map<String, Set<String>>> accSurveyMap = new Map<String, Map<String, Set<String>>>();
        Map<String, Map<String, Set<String>>> accSurveyNoMap = new Map<String, Map<String, Set<String>>>();
        List<USA_Survey_Answer__c> surveyAnswers = scope;
        
        for(USA_Survey_Answer__c sAns :surveyAnswers){
            if(sAns.USA_Survey_Response__r.USA_Account__c != null){
                system.debug('*** USA_Survey_Response__r.USA_Account__c: ' + sAns.USA_Survey_Response__r.USA_Account__c);
                String accId = sAns.USA_Survey_Response__r.USA_Account__c;
                if(sAns.USA_Answer__c.toUppercase() == 'YES'){
                    system.debug('*** sAns.USA_Answer__c == YES');
                    if(!accSurveyMap.keySet().contains(accId)){
                        system.debug('*** accSurveyMap.keySet().contains(accID) == false');
                        Set<String> tempHeaders = new Set<String>();
                        Map<String, Set<String>> tempLabels = new Map<String, Set<String>>();
                        tempHeaders.add(sAns.USA_Question_Header__c);
                        tempLabels.put(sAns.USA_Question_Label__c, tempHeaders);
                        accSurveyMap.put(accId, tempLabels);
                    }else{
                        system.debug('*** accSurveyMap.keySet().contains(accID) == true - sAns.USA_Question_Label__c=' + sAns.USA_Question_Label__c);
                        if(!accSurveyMap.get(accId).keySet().contains(sAns.USA_Question_Label__c)){
                            Set<String> tempHeaders = new Set<String>();
                            tempHeaders.add(sAns.USA_Question_Header__c);
                            accSurveyMap.get(accId).put(sAns.USA_Question_Label__c, tempHeaders);
                            system.debug('*** accSurveyMap.get(accId).put('+sAns.USA_Question_Label__c+', '+tempHeaders+')');
                        }else{
                            accSurveyMap.get(accId).get(sAns.USA_Question_Label__c).add(sAns.USA_Question_Header__c);
                            system.debug('*** accSurveyMap.get(accId).get('+sAns.USA_Question_Label__c+').add('+sAns.USA_Question_Header__c+')');
                        }
                    }
                }
                if(sAns.USA_Answer__c.toUppercase() == 'NO'){
                    system.debug('--- sAns.USA_Answer__c == NO');
                    if(!accSurveyNoMap.keySet().contains(accId)){
                        system.debug('--- accSurveyNoMap.keySet().contains(accID) == false');
                        Set<String> tempHeaders = new Set<String>();
                        Map<String, Set<String>> tempLabels = new Map<String, Set<String>>();
                        tempHeaders.add(sAns.USA_Question_Header__c);
                        tempLabels.put(sAns.USA_Question_Label__c, tempHeaders);
                        accSurveyNoMap.put(accId, tempLabels);
                    }else{
                        system.debug('--- accSurveyNoMap.keySet().contains(accID) == true - sAns.USA_Question_Label__c=' + sAns.USA_Question_Label__c);
                        if(!accSurveyNoMap.get(accId).keySet().contains(sAns.USA_Question_Label__c)){
                            Set<String> tempHeaders = new Set<String>();
                            tempHeaders.add(sAns.USA_Question_Header__c);
                            accSurveyNoMap.get(accId).put(sAns.USA_Question_Label__c, tempHeaders);
                            system.debug('---accSurveyNoMap.get(accId).put('+sAns.USA_Question_Label__c+', '+tempHeaders+')');
                        }else{
                            accSurveyNoMap.get(accId).get(sAns.USA_Question_Label__c).add(sAns.USA_Question_Header__c);
                            system.debug('---accSurveyNoMap.get(accId).get('+sAns.USA_Question_Label__c+').add('+sAns.USA_Question_Header__c+')');
                        }
                    }
                }
            }
            else
            {
                system.debug('*** USA_Survey_Response__r.USA_Account__c: ' + sAns.USA_Survey_Response__r.USA_Account__c);
            }
        }
        system.debug('===> PRH_IconicBriefcaseMappingBatch accSurveyMap: ' + accSurveyMap);
        system.debug('===> PRH_IconicBriefcaseMappingBatch accSurveyNoMap: ' + accSurveyNoMap);
        
        Map<String, List<PRH_Brand_Criteria__c>> brandNameMap = new Map<String, List<PRH_Brand_Criteria__c>>();
        Map<String, List<PRH_Competitor_Brands__c>> competitorBrandMap = new Map<String, List<PRH_Competitor_Brands__c>>();
        if(accSurveyMap.size() > 0){
            Set<Id> luxAccIds = new Set<Id>();
            Set<Id> activeCollIds = new Set<Id>();
            Set<String> accIds = new Set<String>();
            if(accSurveyNoMap.size() > 0){
                accIds.Addall(accSurveyMap.keySet());
                accIds.Addall(accSurveyNoMap.keySet());
            }else{
                accIds.Addall(accSurveyMap.keySet());
                accIds.Addall(accSurveyNoMap.keySet());
            }
            
            List<PRH_Luxury_Accounts__c> listIconicAccount = new List<PRH_Luxury_Accounts__c>();  
            listIconicAccount=[Select Id, PRH_Existing_Account__c 
                               From PRH_Luxury_Accounts__c 
                               Where PRH_Existing_Account__c IN: accIds];
            
            for(PRH_Luxury_Accounts__c luxAcc :listIconicAccount){
                luxAccIds.add(luxAcc.Id);
            }

            system.debug('*** PRH_IconicBriefcaseMappingBatch luxAccIds.size() : ' + luxAccIds.size());
            //Search Active Collect
            List<PRH_Collect__c> listActiveCollect = new List<PRH_Collect__c>() ;  
            listActiveCollect = [Select Id, PRH_Collect_Last_Modified_Date__c              
                                 From PRH_Collect__c
                                 Where PRH_Iconic_Account__c IN: luxAccIds
                                 and PRH_Active__c = true];
            for(PRH_Collect__c activColl :listActiveCollect){
                activeCollIds.add(activColl.Id);
            }

            //Search Brand Criteria
            List<PRH_Brand_Criteria__c> listBrand = new List<PRH_Brand_Criteria__c>() ;
            listBrand = [Select Id, PRH_Collect__c, PRH_Collect__r.PRH_Iconic_Account__c, PRH_Brand__c, PRH_Presence__c, PRH_Visibility__c, PRH_Brand__r.Name, PRH_Branded_Event__c, 
                         PRH_Number_of_Branded_Events__c, PRH_Brand__r.PRH_Active__c, PRH_Account__r.PRH_Existing_Account__c
                         From PRH_Brand_Criteria__c 
                         Where PRH_Collect__c IN: activeCollIds
                         AND PRH_Brand__r.PRH_Competitor_Brand__c = false
                         AND PRH_Brand__r.PRH_Active__c = true
                         Order by PRH_Brand__r.Name];
            system.debug('*** PRH_IconicBriefcaseMappingBatch listBrand: ' + listBrand);
            
            for(PRH_Brand_Criteria__c brands : listBrand){
                //findExistingAccount(brands);
                PRH_Luxury_Accounts__c exAcc=retrieveExistingAccForBrandC(brands);
                   if (exAcc != null){ 
                    String accId = exAcc.PRH_Existing_Account__c;
                    if(!brandNameMap.keySet().contains(accId)){
                        List<PRH_Brand_Criteria__c> brandsTemp = new List<PRH_Brand_Criteria__c>();
                        brandsTemp.add(brands);
                        brandNameMap.put(accId, brandsTemp);
                    }else{
                        brandNameMap.get(accId).add(brands);
                    }
                }
            }
            
            //Search Comp Brand 
            List<PRH_Competitor_Brands__c> listCompBrand = new List<PRH_Competitor_Brands__c>() ;
            listCompBrand = [Select Id, PRH_Collect__c, PRH_Collect__r.PRH_Iconic_Account__c, PRH_Presence__c, PRH_Iconic_Brand__c, PRH_Iconic_Brand__r.PRH_Active__c,
                             PRH_Iconic_Account__r.PRH_Existing_Account__c, PRH_Iconic_Brand__r.Name
                             From PRH_Competitor_Brands__c
                             Where PRH_Collect__c IN: activeCollIds
                             AND PRH_Iconic_Brand__r.PRH_Active__c = true
                             ];
            system.debug('*** PRH_IconicBriefcaseMappingBatch listCompBrand: ' + listCompBrand);

            for(PRH_Competitor_Brands__c compBrand : listCompBrand){
               PRH_Luxury_Accounts__c exAcc2=retrieveExistingAccForCompetitorB(compBrand);
                   if (exAcc2 !=null){ 
                    String accId = exAcc2.PRH_Existing_Account__c;
                    if(!competitorBrandMap.keySet().contains(accId)){
                        List<PRH_Competitor_Brands__c> brandsTemp = new List<PRH_Competitor_Brands__c>();
                        brandsTemp.add(compBrand);
                        competitorBrandMap.put(accId, brandsTemp);
                    }else{
                        competitorBrandMap.get(accId).add(compBrand);
                    }
                }
            }
        }
        
        system.debug('*** brandNameMap: ' + brandNameMap);
        system.debug('*** competitorBrandMap: ' + competitorBrandMap);
        
        /*****************************************
            Le Cercle - Brands
        *****************************************/
        List<PRH_Brand_Criteria__c> brandsToUpdate = new List<PRH_Brand_Criteria__c>();
        if(brandNameMap.size() > 0){
            Boolean hasPresence;
            for(String acc :brandNameMap.keySet()){
                system.debug('*** brandNameMap.keySet acc: ' + acc);
                List<PRH_Brand_Criteria__c> brandCriteria = brandNameMap.get(acc);
                for(PRH_Brand_Criteria__c brc :brandCriteria){
                    Set<String> brandUSIconic = new Set<String>();
                    system.debug('*****brc.PRH_Brand__r.Name: ' + brc.PRH_Brand__r.Name);
                    if(brandUSIconicMaps.get(brc.PRH_Brand__r.Name) != null){
                        brandUSIconic = brandUSIconicMaps.get(brc.PRH_Brand__r.Name);
                    }
                    system.debug('*****brandCriteria: ' + brandCriteria);
                    system.debug('*****brandUSIconic: ' + brandUSIconic);
                    hasPresence = false;
                    for(String sttBrands :brandUSIconic){
                        system.debug('***sttBrands: ' + sttBrands);
                        if(accSurveyNoMap.size() > 0){
                            if(accSurveyNoMap.get(acc) != null){
                                system.debug('***accSurveyNoMap.get(acc): ' + accSurveyNoMap.get(acc));
                                system.debug('***accSurveyNoMap: ' + accSurveyNoMap.get(acc).keySet().contains(sttBrands));
                                
                                if(branded){
                                    if(accSurveyNoMap.get(acc).keySet().contains(sttBrands) && brandName == brc.PRH_Brand__r.Name){
                                        system.debug('***accSurveyNoMap: update brc ' + brc.PRH_Brand__r.Name + ', case 1');
                                        brc.PRH_Presence__c = false;
                                        brc.PRH_Volume__c = 0; // LCS-218
                                        brc.PRH_Branded_Event__c = false;
                                        brc.PRH_Number_of_Branded_Events__c = 0; // LCS-218
                                        brc.PRH_Visibility__c = false;
                                    }
                                }
                                if(!branded){
                                    if(accSurveyNoMap.get(acc).keySet().contains(sttBrands) && !hasPresence){
                                        system.debug('***accSurveyNoMap: update brc ' + brc.PRH_Brand__r.Name + ', case 2');
                                        brc.PRH_Presence__c = false;
                                        brc.PRH_Volume__c = 0; // LCS-218
                                        brc.PRH_Branded_Event__c = false;
                                        brc.PRH_Number_of_Branded_Events__c = 0; // LCS-218
                                        brc.PRH_Visibility__c = false;
                                    }
                                }
                            }
                        }
                        
                        if(accSurveyMap.size() > 0){
                            if(accSurveyMap.get(acc) != null){
                                if(accSurveyMap.get(acc).keySet().contains(sttBrands)){
                                    system.debug('***accSurveyMap: ' + accSurveyMap.get(acc).keySet() + ', sttBrands=' + sttBrands);
                                    system.debug('***accSurveyMap.get(acc).get('+sttBrands+'): ' + accSurveyMap.get(acc).get(sttBrands));
                                    if(accSurveyMap.get(acc).get(sttBrands).contains('Menu') ||
                                        accSurveyMap.get(acc).get(sttBrands).contains('Cocktail') || 
                                        accSurveyMap.get(acc).get(sttBrands).contains('Distribution')){
                                        system.debug('***accSurveyMap: update brc ' + brc.PRH_Brand__r.Name + ', case 3');
                                        brc.PRH_Presence__c = true;
                                        brc.PRH_Branded_Event__c = false;
                                        brc.PRH_Number_of_Branded_Events__c = 0; // LCS-218
                                        brc.PRH_Visibility__c = false;
                                    }
                                    
                                    if(accSurveyMap.get(acc).get(sttBrands).contains('Activation')){
                                        system.debug('***accSurveyMap: update brc ' + brc.PRH_Brand__r.Name + ', case 4');
                                        brc.PRH_Presence__c = true;
                                        brc.PRH_Branded_Event__c = true;
                                        brc.PRH_Visibility__c = false;
                                    }
                                    
                                    if(accSurveyMap.get(acc).get(sttBrands).contains('POS')){
                                        system.debug('***accSurveyMap: update brc ' + brc.PRH_Brand__r.Name + ', case 5');
                                        brc.PRH_Presence__c = true;
                                        brc.PRH_Visibility__c = true;
                                        brc.PRH_Branded_Event__c = false;
                                        brc.PRH_Number_of_Branded_Events__c = 0; // LCS-218
                                    }
                                    
                                    if((accSurveyMap.get(acc).get(sttBrands).contains('Menu') ||
                                        accSurveyMap.get(acc).get(sttBrands).contains('Cocktail') || 
                                        accSurveyMap.get(acc).get(sttBrands).contains('Distribution')) &&
                                        accSurveyMap.get(acc).get(sttBrands).contains('Activation')){
                                        system.debug('***accSurveyMap: update brc ' + brc.PRH_Brand__r.Name + ', case 6');
                                        brc.PRH_Presence__c = true;
                                        brc.PRH_Branded_Event__c = true;
                                        brc.PRH_Visibility__c = false;
                                    }
                                    
                                    if((accSurveyMap.get(acc).get(sttBrands).contains('Menu') ||
                                        accSurveyMap.get(acc).get(sttBrands).contains('Cocktail') || 
                                        accSurveyMap.get(acc).get(sttBrands).contains('Distribution')) &&
                                        accSurveyMap.get(acc).get(sttBrands).contains('POS')){
                                        system.debug('***accSurveyMap: update brc ' + brc.PRH_Brand__r.Name + ', case 7');
                                        brc.PRH_Presence__c = true;
                                        brc.PRH_Visibility__c = true;
                                        brc.PRH_Branded_Event__c = false;
                                        brc.PRH_Number_of_Branded_Events__c = 0; // LCS-218
                                    }
                                    
                                    if((accSurveyMap.get(acc).get(sttBrands).contains('Menu') ||
                                        accSurveyMap.get(acc).get(sttBrands).contains('Cocktail') || 
                                        accSurveyMap.get(acc).get(sttBrands).contains('Distribution')) &&
                                        (accSurveyMap.get(acc).get(sttBrands).contains('POS') &&
                                        accSurveyMap.get(acc).get(sttBrands).contains('Activation'))){
                                        system.debug('***accSurveyMap: update brc ' + brc.PRH_Brand__r.Name + ', case 8');
                                        brc.PRH_Presence__c = true;
                                        brc.PRH_Visibility__c = true;
                                        brc.PRH_Branded_Event__c = true;
                                    }
                                    hasPresence = true;
                                }
                            }
                        }
                    }
                    brandsToUpdate.add(brc);
                }
            }
        }
        
        /*****************************************
            Competitor - Brands
        *****************************************/
        List<PRH_Competitor_Brands__c> competitorToUpdate = new List<PRH_Competitor_Brands__c>();
        if(competitorBrandMap.size() > 0){
            Boolean hasPresence;
            for(String acc :competitorBrandMap.keySet()){
                List<PRH_Competitor_Brands__c> brandCriteria = competitorBrandMap.get(acc);
                for(PRH_Competitor_Brands__c brc :brandCriteria){
                    Set<String> brandUSIconic = new Set<String>();
                    if(brandUSIconicMaps.get(brc.PRH_Iconic_Brand__r.Name) != null){
                        brandUSIconic = brandUSIconicMaps.get(brc.PRH_Iconic_Brand__r.Name);
                    }
                    
                    hasPresence = false;
                    for(String sttBrands :brandUSIconic){
                        if(accSurveyNoMap.size() > 0){
                            if(accSurveyNoMap.get(acc) != null){
                                if(branded){
                                    if(accSurveyNoMap.get(acc).keySet().contains(sttBrands) && brandName == brc.PRH_Iconic_Brand__r.Name){
                                        system.debug('***accSurveyNoMap: update brc ' + brc.PRH_Iconic_Brand__r.Name + ', case 9');
                                        brc.PRH_Presence__c = false;
                                        brc.PRH_Volume__c = 0; // LCS-218
                                    }
                                }
                                if(!branded){
                                    if(accSurveyNoMap.get(acc).keySet().contains(sttBrands) && !hasPresence){
                                        system.debug('***accSurveyNoMap: update brc ' + brc.PRH_Iconic_Brand__r.Name + ', case 10');
                                        brc.PRH_Presence__c = false;
                                        brc.PRH_Volume__c = 0; // LCS-218
                                    }
                                }
                            }
                        }
                        
                        if(accSurveyMap.size() > 0){
                            if(accSurveyMap.get(acc) != null){
                                if(accSurveyMap.get(acc).keySet().contains(sttBrands)){
                                    system.debug('***accSurveyMap: update brc ' + brc.PRH_Iconic_Brand__r.Name + ', case 11');
                                    brc.PRH_Presence__c = true;
                                    hasPresence = true;
                                }
                            }
                        }
                    }
                    competitorToUpdate.add(brc);
                }
            }
        }
        
        system.debug('PRH_IconicBriefcaseMappingBatch(), brandsToUpdate: ' + brandsToUpdate);
        system.debug('PRH_IconicBriefcaseMappingBatch(), competitorToUpdate: ' + competitorToUpdate);

        /* 
        PRH_Brand_Criteria__c:{Id=aCF8E00000003jqWAA, PRH_Collect__c=aNx8E000000Cc52SAC, PRH_Brand__c=aCE8E000000003fWAA, PRH_Presence__c=false, PRH_Visibility__c=false, PRH_Branded_Event__c=false, PRH_Number_of_Branded_Events__c=0}
        PRH_Competitor_Brands__c:{Id=aFk8E0000004FJVSA2, PRH_Collect__c=aNx8E000000Cc52SAC, PRH_Presence__c=false, PRH_Iconic_Brand__c=aCE8E0000000047WAA} 
        */
        
        if(brandsToUpdate.size() > 0 || competitorToUpdate.size() > 0){
            try {
                // Update of Collect_Last_Modified_Date field of Collects linked to updated barnds 
                PRH_Collect__c collectItem;
                Map<ID, ID> collectsMap = new Map<ID, ID>(); // used to have only one ref of the same collect
                List<PRH_Collect__c> collectsToUpdateList = new List<PRH_Collect__c>();
                for (PRH_Brand_Criteria__c lcb : brandsToUpdate) {
                    collectItem = new PRH_Collect__c();
                    collectItem.Id = lcb.PRH_Collect__c;
                    collectItem.PRH_Collect_Last_Modified_Date__c = System.now();
                    if (!collectsMap.isEmpty()) {
                        if (!collectsMap.containsKey(lcb.PRH_Collect__c)) {
                            collectsMap.put(collectItem.Id, collectItem.Id);
                            collectsToUpdateList.add(collectItem);
                        }
                    } else {
                        collectsMap.put(collectItem.Id, collectItem.Id);
                        collectsToUpdateList.add(collectItem);
                    }
                }
                for (PRH_Competitor_Brands__c cb : competitorToUpdate) {
                    collectItem = new PRH_Collect__c();
                    collectItem.Id = cb.PRH_Collect__c;
                    collectItem.PRH_Collect_Last_Modified_Date__c = System.now();
                    if (!collectsMap.isEmpty()) {
                        if (!collectsMap.containsKey(cb.PRH_Collect__c)) {
                            collectsMap.put(collectItem.Id, collectItem.Id);
                            collectsToUpdateList.add(collectItem);
                        }
                    } else {
                        collectsMap.put(collectItem.Id, collectItem.Id);
                        collectsToUpdateList.add(collectItem);
                    }
                }
                if(collectsToUpdateList.size() > 0) {
                    system.debug('PRH_IconicBriefcaseMappingBatch(), collectsToUpdateList: ' + collectsToUpdateList + 'size=' + collectsToUpdateList.size());
                    update collectsToUpdateList;
                    collectsMap.clear();
                }
                update brandsToUpdate;
                update competitorToUpdate;
            } catch (Exception e) {
                System.Debug('--> PRH_IconicBriefcaseMappingBatch, error: '+ e.getMessage());
                System.Debug('--> PRH_IconicBriefcaseMappingBatch, error: '+ e.getLineNumber());
                System.Debug('--> PRH_IconicBriefcaseMappingBatch, error: '+ e.getStackTraceString());
            } 
        }
    }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob WHERE Id =: BC.getJobId()];
        
        // Send an email to the submitter notifying of job completion.
        String emailA;
        if(emailAdd != null && emailAdd != ''){
            emailA = emailAdd;
        }else{
            emailA = a.CreatedBy.Email;
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {emailA};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('PRH Iconic Admin');
        mail.setSubject('Briefcase Data Sync - ' + a.Status);
        mail.setPlainTextBody('Iconic Sync Status. \nBatch job processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        // Update collects data calling the specific batch used at each collects creation (LCS-218)
        Database.executeBatch(new PRH_UpdateCollectsCalculatedValues(), 50);
    }
  
}