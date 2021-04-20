/*
    *Created By: Bryan Trinidad
    *Created Date: June 13,2014
    *   
    *       Updated By:             Date:                   Description:        
    *       Bryan Trinidad          JUN.18.2014             Remove checking of permission for user. Line No.: 301, Line No.: 86-99, Line No.: 107-111
    *       Bryan Trinidad          JUL.11.2014             Counting of brand criteria presence. Updated countOfPresenceBrandCriteria() method.
    *       Rey Magdaong            JAN.12,2015             Update doMobileSave. Bug fix for double insert of competitor brand list.+
    *       CGI SR		            DEC.29,2016             modification of core model (add collect) 
    *       CGI                     JUL.03,2017             LCS-159
    *       CGI                     JUL.03,2017             LCS-158
*/

global with sharing class PRH_Competitor_Brand_Controller {
    
    /*variables*/
    public List<PRH_Competitor_Brands__c> competitorBrandList {get;set;}
    public Id iconicAccountId {get;set;}
    public List<Competitor_Brand_WrapperClass> competitorBrandWrapperList {get;set;}
	public List<PRH_Collect__c> PRH_ActiveCollect {get;set;}
    public String accountURLParam {get;set;}
    //public Boolean renderedCompBrandTable {get;set;}

    /*constructor*/
    public PRH_Competitor_Brand_Controller() {
        try {
            ID activeCollectID;
            //get iconic account id from url
            iconicAccountId = ApexPages.currentPage().getParameters().get('id');
            competitorBrandWrapperList = new List<Competitor_Brand_WrapperClass>();
            Set<String> permissionList = setPermissionMethod(UserInfo.getUserId());
            Integer rowIndex = 0;

            //record id in account or eu account object
            accountURLParam = ApexPages.currentPage().getParameters().get('AcctID');

			// Retrieve active collect linked to the Iconic Account 
			PRH_ActiveCollect =[Select 
                    id, Name, PRH_Active__c, /*PRH_Full_Active_Le_Cercle_Portfolio__c,*/ PRH_Iconic_Account__c, PRH_Number_of_Pernod_Ricard_products__c , PRH_Period_End__c, PRH_Period_Start__c 
                From 
                    PRH_Collect__c 
                Where 
                    PRH_Active__c=true And PRH_Iconic_Account__c=:iconicAccountId LIMIT 1];
			System.debug('==> PRH_Competitor_Brand_Controller, ' + PRH_ActiveCollect.size() + ' Collect(s) retrieved for Iconic account ' + iconicAccountId);	
			System.debug('==> PRH_Competitor_Brand_Controller, PRH_ActiveCollect : ' + PRH_ActiveCollect);	
            
            if (PRH_ActiveCollect.size()>0){
            
				activeCollectID = PRH_ActiveCollect[0].Id;
				
				//query all competitor brands where competitor brand checkbox is equal to true
				competitorBrandList = [SELECT 
										Id, PRH_Presence__c, PRH_Volume__c,PRH_Iconic_Brand__r.Name,
										PRH_Iconic_Brand__r.RecordType.DeveloperName,PRH_Collect__c,
										PRH_Iconic_Brand__c
										FROM PRH_Competitor_Brands__c
										WHERE PRH_Collect__c=:activeCollectID
										AND PRH_Iconic_Brand__r.PRH_Competitor_Brand__c=true
                                        //AND PRH_Iconic_Brand__r.PRH_Active__c=true LCS-159
										AND PRH_Iconic_Account__r.PRH_Suppress_and_archive__c=false
										ORDER BY PRH_Iconic_Brand__r.PRH_Sequence__c,PRH_Iconic_Brand__r.Name];
				System.debug('==> PRH_Competitor_Brand_Controller, ' + competitorBrandList.size() + ' competitorBrandList(s) retrieved for collect Id ' + activeCollectID);	
				System.debug('==> PRH_Competitor_Brand_Controller, competitorBrandList : ' + competitorBrandList);	
				   
				if (competitorBrandList.isEmpty()) {
					system.debug('==> PRH_Competitor_Brand_Controller, competitorBrandList.isEmpty() is true');

					List<PRH_Brand_Luxury_Brand__c> iconicBrandList = new List<PRH_Brand_Luxury_Brand__c>();

					iconicBrandList = [SELECT 
											Id,Name
											FROM PRH_Brand_Luxury_Brand__c
											WHERE PRH_Competitor_Brand__c=true
                                            AND PRH_Active__c=true
											ORDER BY PRH_Sequence__c , Name];

					competitorBrandList = new List<PRH_Competitor_Brands__c>();

					Map<Id,String> brandNameMap = new Map<Id,String>();
					for (PRH_Brand_Luxury_Brand__c iconicBrand:iconicBrandList) {
						brandNameMap.put(iconicBrand.Id,iconicBrand.Name);

						PRH_Competitor_Brands__c compBrand = new PRH_Competitor_Brands__c();
						compBrand.PRH_Iconic_Brand__c = iconicBrand.Id;
						compBrand.PRH_Iconic_Account__c = iconicAccountId;
						competitorBrandList.add(compBrand);
					}

					for (PRH_Competitor_Brands__c cb:competitorBrandList) {
						String nameBrand = brandNameMap.get(cb.PRH_Iconic_Brand__c);
						Competitor_Brand_WrapperClass cbw = new Competitor_Brand_WrapperClass(rowIndex,cb,true,nameBrand);

						competitorBrandWrapperList.add(cbw);
						rowIndex++;
					}
					//ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'No Competitor Brands for this Iconic Account.' );
					//ApexPages.addMessage(msg);

					//renderedCompBrandTable = false;

				//show table of competitor brands
				} else {
					system.debug('==> PRH_Competitor_Brand_Controller, competitorBrandList.isEmpty() is false');
					//renderedCompBrandTable = true;
					
					/*Set<String> permissionSetup = new Set<String>();

					for (String p : permissionList) {
						if (p == 'PRH_Iconic_Platform_Pernod') {
							permissionSetup.add('PRH_Luxury_Account_Pernod');
						}

						if (p == 'PRH_Iconic_Platform_Ricard') {
							permissionSetup.add('PRH_Luxury_Account_Ricard');
						}
					}

					system.debug('@@@@@@@@@permission '+permissionSetup);*/
					
					for (PRH_Competitor_Brands__c cb:competitorBrandList) {	
						//cb.PRH_Volume__c = (cb.PRH_Volume__c == null) ? 0 : cb.PRH_Volume__c;
						Boolean permission = true;                  

						//disable fields base on permission sets
						/*if (!permissionList.contains('PRH_Iconic_Platform_PR_Holding_Admin')) {
							
							permission = permissionSetup.contains(cb.PRH_Iconic_Brand__r.RecordType.DeveloperName);	
						}*/
						
						Competitor_Brand_WrapperClass cbw = new Competitor_Brand_WrapperClass(rowIndex,cb,permission,null);

						competitorBrandWrapperList.add(cbw);
						rowIndex++;
					}
				}
            }
        } catch (Exception e) {
            System.Debug('### error:'+ e.getMessage());
            System.Debug('### error:'+ e.getLineNumber());
            System.Debug('### error:'+ e.getStackTraceString());
        }
    }//end constructor

    /*for brand criteria: auto populate last modified by*/
    public static void setLastModifiedByInAccount(Id userId, Id iconicAcctId) {
        /* LCS-160
        try {
            
            PRH_Luxury_Accounts__c iconicAccount = [SELECT Id,Ricard_Last_Modified_By__c,PRH_Pernod_Last_Modified_By__c
                                                	FROM PRH_Luxury_Accounts__c 
                                                    WHERE Id=:iconicAcctId];

            String userName = [SELECT Name FROM User WHERE Id=:userId].Name;

            Set<String> usersPermissions = setPermissionMethod(userId);
            
            String lastModifiedBy = userName + ', ' + System.now().format('MM/dd/yyyy hh:mm aa');
            
            if (usersPermissions.contains('PRH_Iconic_Platform_Pernod')) {
                iconicAccount.PRH_Pernod_Last_Modified_By__c = lastModifiedBy;
            }

            if(usersPermissions.contains('PRH_Iconic_Platform_Ricard')) {
                iconicAccount.Ricard_Last_Modified_By__c = lastModifiedBy;
            }
                      
            // iconicAccount.PRH_Number_of_Pernod_Ricard_products__c = countOfPresenceBrandCriteria(iconicAcctId);
            update iconicAccount;
        } catch (Exception e) {
            System.Debug('### error:'+ e.getMessage());
            System.Debug('### error:'+ e.getLineNumber());
            System.Debug('### error:'+ e.getStackTraceString());
        }
        */
    }//end setLastModifiedByInAccount() 
    
    
    public static void setNumberOfPRProducts(Id iconicAcctId) {
        try {
            // Collect
            PRH_Collect__c activeCollect = [Select Id,PRH_Number_of_Pernod_Ricard_products__c,PRH_Iconic_Account__c,PRH_Le_Cercle_Brand_Presence__c           
				     					From PRH_Collect__c
                                        Where PRH_Iconic_Account__c=:iconicAcctId
                                        and PRH_Active__c=true
                                        Limit 1];
            System.Debug('### activeCollect.PRH_Le_Cercle_Brand_Presence__c :'+ activeCollect);
            activeCollect.PRH_Number_of_Pernod_Ricard_products__c = countOfPresenceBrandCriteria(iconicAcctId); 
            update activeCollect;
        } catch (Exception e) {
            System.Debug('### error:'+ e.getMessage());
            System.Debug('### error:'+ e.getLineNumber());
            System.Debug('### error:'+ e.getStackTraceString());
        }
    }
    
    //Le Cercle application - evolution LCS-158 - July 2017
    public static void setLCBPresence(Id iconicAcctId) {
        try {
            // Collect
            PRH_Collect__c nbLCBPresence = [Select Id,PRH_Number_of_Pernod_Ricard_products__c,PRH_Le_Cercle_Brand_Presence__c,PRH_Iconic_Account__c           
				     					From PRH_Collect__c
                                        Where PRH_Iconic_Account__c=:iconicAcctId
                                        and PRH_Active__c=true
                                        Limit 1];
            
            System.Debug('### nbLCBPresence PRH_Number_of_Pernod_Ricard_products__c :'+ nbLCBPresence.PRH_Number_of_Pernod_Ricard_products__c);
            if (nbLCBPresence.PRH_Number_of_Pernod_Ricard_products__c == null || nbLCBPresence.PRH_Number_of_Pernod_Ricard_products__c ==0) {  
               nbLCBPresence.PRH_Le_Cercle_Brand_Presence__c=false;
               System.Debug('### nbLCBPresence false :');
            }
            else {
                nbLCBPresence.PRH_Le_Cercle_Brand_Presence__c=true;
                System.Debug('### nbLCBPresence true :');
            }
            update nbLCBPresence;
           System.Debug('### update nbLCBPresence :' + nbLCBPresence);
            
        } catch (Exception e) {
            System.Debug('### error:'+ e.getMessage());
            System.Debug('### error:'+ e.getLineNumber());
            System.Debug('### error:'+ e.getStackTraceString());
        }
    }

    /*for brand criteria: count of brand criteria presence*/
    public static Integer countOfPresenceBrandCriteria(Id iconicAcctId) {
        // Collect
        PRH_Collect__c activeCollect = [Select Id            
				     					From PRH_Collect__c
                                        Where PRH_Iconic_Account__c=:iconicAcctId
                                        and PRH_Active__c=true
                                        Limit 1];
           
        Integer countPresence = [SELECT count()
                                 FROM PRH_Brand_Criteria__c
                                 WHERE PRH_Collect__c= :activeCollect.Id
                                 AND PRH_Presence__c=true
                                 //AND PRH_BRAND__r.PRH_ACTIVE__c=true LCS-159
                                 ];
        return countPresence;
    }

    /* Method for retrieving permission set of user*/
    public static Set<String> setPermissionMethod(Id userId) {  
        List<PermissionSetAssignment> permissionList = [SELECT PermissionSetId
                                                        FROM PermissionSetAssignment
                                                        WHERE AssigneeId = :userId];
        List<ID> idList = new List<ID>();
        for(PermissionSetAssignment psa : permissionList){
            idList.add(psa.PermissionSetId);
        }

        List<PermissionSet> permissionNameList = [Select Name 
                                                    FROM PermissionSet 
                                                    WHERE Id IN :idList];

        Set<String> permissionNames = new Set<String>();
        for(PermissionSet ps : permissionNameList){
            permissionNames.add(ps.Name);
        }

        return permissionNames;
    }
    // end setPermissionMethod()

    /* Method for converting string sets to string delimited by comma*/
    public static String convertSetofString(Set<String> fieldList) {   
        String str = '';
      
        //add field values
        if (fieldList.size()>0) {
            for (String s:fieldList) {
              str += s+',';
            } 
            //remove last comma
            str = str.substring(0, str.length() - 1);
        }
      
      return str;  
    }
    // end convertSetofString()

    /* Method for saving record for desktop*/
    public PageReference doSave() {
        Set<String> noPresenceBrand = new Set<String>();
        iconicAccountId = ApexPages.currentPage().getParameters().get('id');

        try {
            if (!competitorBrandWrapperList.isEmpty()) {
                for (Competitor_Brand_WrapperClass brand : competitorBrandWrapperList) {                   
                    if (brand.brandObj.PRH_Presence__c == false && brand.brandObj.PRH_Volume__c > 0) {
                        noPresenceBrand.add(brand.brandName);
                    }
                }
                
                //error message if there are competitor brands presence uncheck but with volume
                if (noPresenceBrand.size()>0) {
                    String errorMessage = 'Presence - absent for: '+'\n'+convertSetofString(noPresenceBrand);
                    apexpages.message err = new apexpages.message(apexpages.severity.error,errorMessage);
                    apexpages.addmessage(err);
                    return null;
                }

                List<PRH_Competitor_Brands__c> updateCompetitorBrandList = new List<PRH_Competitor_Brands__c>();
                
                for (Competitor_Brand_WrapperClass cbw : competitorBrandWrapperList) {
                    updateCompetitorBrandList.add(cbw.brandObj);    
                }

                upsert updateCompetitorBrandList;

                //update account last modified by pernod or ricard
                //  setLastModifiedByInAccount(UserInfo.getUserId(),iconicAccountId);
               
                PRH_Collect__c updateTimeCollect=[Select PRH_Collect_Last_Modified_Date__c 
                                                  From PRH_Collect__c 
                                                  where PRH_Iconic_Account__c =:iconicAccountId 
                                                  and PRH_Active__c=true Limit 1];
          		updateTimeCollect.PRH_Collect_Last_Modified_Date__c = System.now();    
          		update updateTimeCollect;
          		System.Debug('doSave updateTimeCollect :'+ updateTimeCollect);

                system.debug('doSave, updateCompetitorBrandList : '+updateCompetitorBrandList);
                PRH_Competitor_Brand_Controller.setNumberOfPRProducts(iconicAccountId);
                PRH_Competitor_Brand_Controller.setLCBPresence(iconicAccountId);
            }
        } catch (Exception e) {
            System.Debug('### error:'+ e.getMessage());
            System.Debug('### error:'+ e.getLineNumber());
            System.Debug('### error:'+ e.getStackTraceString());
            return null;
        }

        return doCancel();
    }
    // end doSave()


    /* Method for saving record for mobile*/
    @RemoteAction
    global static String doMobileSave(List<String> cbwStringList) {
        try {
            Set<Id> compBrandIds = new Set<Id>(); 
            Id iconicAccount = null;
           
            if (cbwStringList.size()>0) {
                //get all id parameter in json
                for(String s:cbwStringList){
					Map<String, Object> jsonString = (Map<String, Object>)JSON.deserializeUntyped(s);
					system.debug('@@@@@@@@@@@@@@JSON: '+jsonString.get('Presence')+' '+jsonString.get('Volume')+' '+jsonString.get('IconicAccount'));
					/*
					if (jsonString.get('Id') != '') {
						compBrandIds.add((Id)jsonString.get('Id'));
					} */
					if (jsonString.get('IconicAccount') != '' && iconicAccount == null) {
						iconicAccount  = (Id)jsonString.get('IconicAccount');                    
						break;
					}
                }

                Set<String> errMsgList = new Set<String>();
                Map<Id,PRH_Competitor_Brands__c> compBrandMap = new Map<Id,PRH_Competitor_Brands__c>();
   
                //Add collect
        		PRH_Collect__c activeCollect = [select Id              
				     							From PRH_Collect__c
                                                Where PRH_Iconic_Account__c= :iconicAccount
                                                and PRH_Active__c=true
                                                Limit 1]; 
                system.debug('@@@@@@@@@@@@@@ iconicAccount : '+ iconicAccount);
                 
                /*List <PRH_Competitor_Brands__c> listCompetitorBrands = [SELECT Id,PRH_Iconic_Brand__c, PRH_Iconic_Brand__r.Name,PRH_Volume__c,PRH_Presence__c
                                                                        FROM PRH_Competitor_Brands__c
                                                                        WHERE PRH_Collect__c =:activeCollect.id];
                
                for(PRH_Competitor_Brands__c compBrand: listCompetitorBrands){
                    compBrandMap.put(compBrand.PRH_Iconic_Brand__c, compBrand);
                }*/
				if (activeCollect != null) {
					for(PRH_Competitor_Brands__c compBrand: [SELECT Id, PRH_Iconic_Brand__c, PRH_Iconic_Brand__r.Name, PRH_Iconic_Brand__r.PRH_Active__c, PRH_Volume__c, PRH_Presence__c
                                                                        FROM PRH_Competitor_Brands__c
                                                                        WHERE PRH_Collect__c=:activeCollect.id 
                                                             			//AND PRH_Iconic_Brand__r.PRH_Active__c=true LCS-159
                                                            ]){
						compBrandMap.put(compBrand.PRH_Iconic_Brand__c, compBrand);
					}
					system.debug('@@@@@@@@@@@@@@ compBrand : '+ compBrandMap);
					//if competitor brands already exist on the iconic account, just do an update;
					if(compBrandMap.size() > 0){
						for (String str:cbwStringList) {
							Map<String, Object> jsonString = (Map<String, Object>)JSON.deserializeUntyped(str);
							Id iconicBrand = (Id)jsonString.get('IconicBrand');

							if (iconicBrand != null && compBrandMap.containsKey(iconicBrand)) {
								String brandName = compBrandMap.get(iconicBrand).PRH_Iconic_Brand__r.Name;
								Boolean brandPresence = Boolean.valueOf(jsonString.get('Presence'));
								Object jsonVolume = (jsonString.get('Volume') != '') ? jsonString.get('Volume') : '0';
								Double brandVolume = Double.valueOf(jsonVolume);

								if (brandPresence == false && brandVolume > 0) {
									errMsgList.add(brandName);
								}

								compBrandMap.get(iconicBrand).PRH_Presence__c = brandPresence;
								compBrandMap.get(iconicBrand).PRH_Volume__c = brandVolume;
							}   
						}

						if (!errMsgList.isEmpty()) {
							return 'Presence - absent for: '+'\n'+convertSetofString(errMsgList);
						}

						update compBrandMap.values();
						//setLastModifiedByInAccount(UserInfo.getUserId(),iconicAccount);
				
						system.debug('@@@@@@@@@@@@@@@@@Updated: '+compBrandMap);
                        
					}else{
					    //insert the competiro brands
						List<PRH_Competitor_Brands__c> newCompBrandList = new List<PRH_Competitor_Brands__c>();
					
						for (String str:cbwStringList) {
							Map<String, Object> jsonString = (Map<String, Object>)JSON.deserializeUntyped(str);

							String brandName = String.valueOf(jsonString.get('BrandName'));
							Boolean brandPresence = Boolean.valueOf(jsonString.get('Presence'));
							Object jsonVolume = (jsonString.get('Volume') != '') ? jsonString.get('Volume') : '0';
							Double brandVolume = Double.valueOf(jsonVolume);

							if (brandPresence == false && brandVolume > 0) {
								errMsgList.add(brandName);
							}
							
							PRH_Competitor_Brands__c newCompBrand = new PRH_Competitor_Brands__c();
							newCompBrand.PRH_Iconic_Account__c = (Id)jsonString.get('IconicAccount');
							newCompBrand.PRH_Iconic_Brand__c = (Id)jsonString.get('IconicBrand');
							newCompBrand.PRH_Presence__c = brandPresence;
							newCompBrand.PRH_Volume__c = brandVolume;
							newCompBrandList.add(newCompBrand);
                            system.debug('@@@@@@@@@@@@@@ newCompBrand : '+ newCompBrand);
						}
                        

						if (!errMsgList.isEmpty()) {
							return 'Presence - absent for: '+'\n'+convertSetofString(errMsgList);
						}

						insert newCompBrandList;

						if(newCompBrandList.size()>0) {	
						//	setLastModifiedByInAccount(UserInfo.getUserId(),iconicAccount);
						}
					}
                    PRH_Collect__c updateTimeCollect=[Select PRH_Collect_Last_Modified_Date__c 
                                                          From PRH_Collect__c 
                                                  	      where PRH_Iconic_Account__c =:iconicAccount 
                                                          and PRH_Active__c=true Limit 1];
          				updateTimeCollect.PRH_Collect_Last_Modified_Date__c = System.now();    
          				update updateTimeCollect;
                        System.Debug('doMobileSave updateTimeCollect :'+ updateTimeCollect);
                        
                        PRH_Competitor_Brand_Controller.setNumberOfPRProducts(iconicAccount);
           		        //LCS-158 Verify presence of Le Cercle Brand Product
          				PRH_Competitor_Brand_Controller.setLCBPresence(iconicAccount);
                        system.debug('@@@@@@@@@@@@@@ updateTimeCollect : '+ updateTimeCollect);
                        system.debug('@@@@@@@@@@@@@@ iconicAccount : '+ iconicAccount);
					/*
					if (!compBrandIds.isEmpty()) {

						//select all competitor brands based on retrieved json ids
						List<PRH_Competitor_Brands__c> compBrandQueryList = [SELECT Id,PRH_Iconic_Brand__c, PRH_Iconic_Account__c,
																			PRH_Iconic_Brand__r.Name,PRH_Volume__c,PRH_Presence__c
																			FROM PRH_Competitor_Brands__c
																			WHERE Id IN: compBrandIds];

						//get id for updating iconic account last modified by
						Id iconAcctId = compBrandQueryList[0].PRH_Iconic_Account__c;

						Map<Id,PRH_Competitor_Brands__c> compBrandQueryMap = new Map<Id,PRH_Competitor_Brands__c>();

						//map competitor brands id and brand object                    
						for (PRH_Competitor_Brands__c b:compBrandQueryList) {
							compBrandQueryMap.put(b.Id,b);
						}

						

						//equate json values in queried competitor brands
						for (String str:cbwStringList) {

							Map<String, Object> jsonString = (Map<String, Object>)JSON.deserializeUntyped(str);

							if (compBrandQueryMap.containsKey((Id)jsonString.get('Id'))) {
								
								Id brandId = (Id)jsonString.get('Id');
								String brandName = compBrandQueryMap.get(brandId).PRH_Iconic_Brand__r.Name;
								Boolean brandPresence = Boolean.valueOf(jsonString.get('Presence'));
								Object jsonVolume = (jsonString.get('Volume') != '') ? jsonString.get('Volume') : '0';
								Double brandVolume = Double.valueOf(jsonVolume);

								if (brandPresence == false && brandVolume > 0) {
									errMsgList.add(brandName);
								}

								compBrandQueryMap.get(brandId).PRH_Presence__c = brandPresence;
								compBrandQueryMap.get(brandId).PRH_Volume__c = brandVolume;

							}   
						}

						//error message if there are competitor brands presence uncheck but with volume
						if (!errMsgList.isEmpty()) {

							return 'Presence - absent for: '+'\n'+convertSetofString(errMsgList);

						}

						update compBrandQueryMap.values();

						setLastModifiedByInAccount(UserInfo.getUserId(),iconAcctId);

						system.debug('@@@@@@@@@@@@@@@@@Updated: '+compBrandQueryMap);

				   //insert
				   } else {

						List<PRH_Competitor_Brands__c> newCompBrandList = new List<PRH_Competitor_Brands__c>();
					
						for (String str:cbwStringList) {
							
							Map<String, Object> jsonString = (Map<String, Object>)JSON.deserializeUntyped(str);

							String brandName = String.valueOf(jsonString.get('BrandName'));
							Boolean brandPresence = Boolean.valueOf(jsonString.get('Presence'));
							Object jsonVolume = (jsonString.get('Volume') != '') ? jsonString.get('Volume') : '0';
							Double brandVolume = Double.valueOf(jsonVolume);

							if (brandPresence == false && brandVolume > 0) {
								errMsgList.add(brandName);
							}
							
							PRH_Competitor_Brands__c newCompBrand = new PRH_Competitor_Brands__c();
							newCompBrand.PRH_Iconic_Account__c = (Id)jsonString.get('IconicAccount');
							newCompBrand.PRH_Iconic_Brand__c = (Id)jsonString.get('IconicBrand');
							newCompBrand.PRH_Presence__c = brandPresence;
							newCompBrand.PRH_Volume__c = brandVolume;
							newCompBrandList.add(newCompBrand);
						}

						if (!errMsgList.isEmpty()) {

							return 'Presence - absent for: '+'\n'+convertSetofString(errMsgList);

						}

						insert newCompBrandList;

						if(newCompBrandList.size()>0) {
							
							setLastModifiedByInAccount(UserInfo.getUserId(),newCompBrandList[0].PRH_Iconic_Account__c);
			
						}

				   }
				   */
				}
			}
        } catch (Exception e) {
            System.Debug('### error:'+ e.getMessage());
            System.Debug('### error:'+ e.getLineNumber());
            System.Debug('### error:'+ e.getStackTraceString());
            return 'Exception: '+e.getMessage();
        }

        return null;   
    } //end mobileDoSave()

    /*method for cancelling update of record*/
    public PageReference doCancel() {
        PageReference pageRef;
        
        if (accountURLParam == null) {   
            pageRef = Page.PRH_Luxury_Account;
            pageRef.getParameters().put('id', iconicAccountId);
            pageRef.setRedirect(true);      
        } else {
            //redirect to account or eu account record
            pageRef = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' +accountURLParam);
        }

        return pageRef;
    }//end doCancel()

    /*wrapper class*/
    global class Competitor_Brand_WrapperClass {
        public String brandName {get;set;}
        public Integer indexRow {get;set;}
        public String labelCheckBoxElemId {get;set;}
        public String labelInputTextElemId {get;set;}
        public String checkBoxElemId {get;set;}
        public String inputTextElemId {get;set;}
        public PRH_Competitor_Brands__c brandObj {get;set;}
        public Boolean permission {get;set;}

        /*wrapper class constructor*/
        public Competitor_Brand_WrapperClass(Integer indexRowParam, PRH_Competitor_Brands__c brandParam,
                                                    Boolean permissionParam, String brandNameParam) {
            brandName = (brandParam.PRH_Iconic_Brand__r.Name == null) ? brandNameParam : brandParam.PRH_Iconic_Brand__r.Name;
            indexRow = indexRowParam;
            labelCheckBoxElemId = 'lblcheckboxElem_'+indexRowParam;
            labelInputTextElemId = 'lblinputtextElem_'+indexRowParam;
            checkBoxElemId = 'checkboxElem_'+indexRowParam;
            inputTextElemId = 'inputtextElem_'+indexRowParam;
            brandObj = new PRH_Competitor_Brands__c(Id=brandParam.Id,PRH_Presence__c=brandParam.PRH_Presence__c,
                                                    PRH_Iconic_Brand__c=brandParam.PRH_Iconic_Brand__c,
                                                    PRH_Collect__c=brandParam.PRH_Collect__c);
													/*PRH_Iconic_Account__c=brandParam.PRH_Iconic_Account__c);*/
            brandObj.PRH_Volume__c=  (brandParam.PRH_Volume__c==null) ? 0 : brandParam.PRH_Volume__c;
            permission = true;//permissionParam;
        }//end wrapper class constructor

    }//end wrapper class

}//end class