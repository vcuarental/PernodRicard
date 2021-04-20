/*
edit feb 11 2015:
  - added an additional checking to not create apex sharing if owner 2 and owner are the same.
    line 39 and 126
edit january 2017:
  - Modification of core model (add collect) 
edit july 2017 :
  - Evolution 159
*/
public class PRH_Share_Luxury_Account extends PRH_TriggerAbstract {
    public PRH_Share_Luxury_Account() {
        super('PRH_Share_Luxury_Account');
    }
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
		Date todayDate = system.today();
		Integer currentDay = todayDate.day();
		Integer currentMonth = todayDate.month();
		Integer currentYear = todayDate.year();
		Date PRH_PeriodStartDate;
		Date PRH_PeriodEndDate;
		
        if (tAction == TriggerAction.AFTER_INSERT) {
            List<PRH_Luxury_Accounts__c> newLuxAccList = (List<PRH_Luxury_Accounts__c>)sObjList;
            system.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT, newLuxAccList='+newLuxAccList);
            list<PRH_Luxury_Accounts__Share> shareList = new List<PRH_Luxury_Accounts__Share>();
            List<PRH_Brand_Criteria__c> newCriteriaList = new List<PRH_Brand_Criteria__c>();
            List<PRH_Competitor_Brands__c> newCompetitorList = new List<PRH_Competitor_Brands__c>();
			List<PRH_Collect__c> listOfNewCollects = new List<PRH_Collect__c >();
			PRH_Collect__c newCollect;
			ID collectID;
            List<PRH_Brand_Luxury_Brand__c> luxuryBrands = [Select ID, Name, PRH_Active__c, RecordType.DeveloperName, PRH_Competitor_Brand__c from PRH_Brand_Luxury_Brand__c Order By PRH_Sequence__c, Name];
            Map<ID,ID> accountOwner2Map = new Map<ID,ID>();
            Map<String,ID> recordTypeIDNameMap = new Map<String,ID>();
            Set<String> recordTypeSet = new Set<String>();
            for (PRH_Brand_Luxury_Brand__c luxBrand : luxuryBrands) {
                system.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT, luxBrand.RecordType.DeveloperName= '+luxBrand.RecordType.DeveloperName);
				if (!recordTypeSet.contains(luxBrand.RecordType.DeveloperName)) {
					recordTypeSet.add(luxBrand.RecordType.DeveloperName);
				}
            }
            system.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT, recordTypeSet ' + recordTypeSet);
             
            List<RecordType> recordTypeIDs = [Select Id, DeveloperName From RecordType Where SobjectType='PRH_Brand_Criteria__c' and DeveloperName in :recordTypeSet];
            for (RecordType rt : recordTypeIDs) {
                recordTypeIDNameMap.put(rt.DeveloperName,rt.ID);
            }
            system.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT, recordTypeIDNameMap ' + recordTypeIDNameMap);
            
			// Define Start and End date for new collect(s) to create regarding current date (evolution LCS-11)
			if ((currentMonth >= 3) && (currentMonth <= 6)) {
				PRH_PeriodStartDate = date.newInstance(currentYear, 03, 01);
				PRH_PeriodEndDate = date.newInstance(currentYear, 06, 30);
			} else if ((currentMonth >= 7) && (currentMonth <= 10)) {
				PRH_PeriodStartDate = date.newInstance(currentYear, 07, 01);
				PRH_PeriodEndDate = date.newInstance(currentYear, 10, 31);
			} else if ((currentMonth == 11) || (currentMonth == 12)) {
				if (Date.isLeapYear(currentYear+1) == true) { // next year is a leap year
					PRH_PeriodEndDate = date.newInstance(currentYear+1, 02, 29);
				} else {
					PRH_PeriodEndDate = date.newInstance(currentYear+1, 02, 28);
				}
				PRH_PeriodStartDate = date.newInstance(currentYear, 11, 01);  // year, month, day
			} else if ((currentMonth == 1) || (currentMonth == 2)) {
				if (Date.isLeapYear(currentYear) == true) { // this is a leap year
					PRH_PeriodEndDate = date.newInstance(currentYear, 02, 29);
				} else {
					PRH_PeriodEndDate = date.newInstance(currentYear, 02, 28);
				}
				PRH_PeriodStartDate = date.newInstance(currentYear-1, 11, 01);  // year, month, day
			}
			System.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT, PRH_PeriodStartDate=' + PRH_PeriodStartDate + ', PRH_PeriodEndDate='  + PRH_PeriodEndDate);

			// Creation of the collect for the Iconic account
			for (PRH_Luxury_Accounts__c newLuxAcc : newLuxAccList) {
				newCollect = new PRH_Collect__c(PRH_Active__c=true, 
												PRH_Iconic_Account__c=newLuxAcc.id, 
												PRH_Period_Start__c=PRH_PeriodStartDate, 
												PRH_Period_End__c=PRH_PeriodEndDate); 
				listOfNewCollects.add(newCollect);
			}
			if (listOfNewCollects.size() > 0) {
				insert listOfNewCollects; 
				System.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT, ' + listOfNewCollects.size() + ' new collects have been created');
			}
            // Retrieve all IDs of active collects  
			List<PRH_Collect__c> activeCollects = [SELECT id, PRH_Iconic_Account__c, PRH_Active__c FROM PRH_Collect__c WHERE PRH_Active__c=true ORDER BY Name DESC];
			
			// Creation of Competitor and Le Cercle brands related to the collect and Iconic account
            for (PRH_Luxury_Accounts__c newLuxAcc : newLuxAccList) {               
                // Retrieve ID of active collect linked to iconic account
				for (PRH_Collect__c c : activeCollects) {
					if (newLuxAcc.ID == c.PRH_Iconic_Account__c) {
						collectID = c.ID;
						break;
					}
				}
                
                System.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT newLuxAccList' + newLuxAccList);
                PRH_Luxury_Accounts__share newShare = new PRH_Luxury_Accounts__share();
                if (newLuxAcc.PRH_Owner_2__c != null && newLuxAcc.PRH_Owner_2__c != newLuxAcc.OwnerId) {
                    newShare.ParentId = newLuxAcc.id;
                    newShare.UserOrGroupId = newLuxAcc.PRH_Owner_2__c;
                    newShare.AccessLevel = 'Edit';
                    shareList.add(newShare);
                    System.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT, newLuxAcc.id : ' + newLuxAcc.id);
                    System.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT, newLuxAcc.PRH_Owner_2__c : ' + newLuxAcc.PRH_Owner_2__c);
                    accountOwner2Map.put(collectID,newLuxAcc.PRH_Owner_2__c);
                }
				
				System.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT, collectID ' + collectID);
                for (PRH_Brand_Luxury_Brand__c luxBrand : luxuryBrands) {
                    if (luxBrand.PRH_Active__c == true) { // LCS-159 only active brands must be taken into account
                        System.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT, Brand ' + luxBrand.Name + ' is active');
                        if (!luxBrand.PRH_Competitor_Brand__c) {
                            PRH_Brand_Criteria__c newCriteria = new PRH_Brand_Criteria__c();
                            newCriteria.ownerID = newLuxAcc.ownerID;
    						newCriteria.PRH_Collect__c = collectID;
                            if ( newLuxAcc.PRH_Existing_Account__c != null) {
                                newCriteria.PRH_Account_Name__c = newLuxAcc.PRH_Existing_Account__c;
                            }
                            
                            if ( newLuxAcc.PRH_Existing_EU_Account__c != null) {
                                newCriteria.PRH_EU_Account_Name__c = newLuxAcc.PRH_Existing_EU_Account__c;
                            }
                            
                            newCriteria.PRH_Brand__c = luxBrand.ID;
                            if (luxBrand.RecordType.DeveloperName != null) {
                                newCriteria.RecordTypeId = recordTypeIDNameMap.get(luxBrand.RecordType.DeveloperName);
                            }
                            System.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT : Owner ' + newCriteria.ownerID + ' - recordTypeName ' + newCriteria.RecordTypeId + ' - PRH_Brand__c ' + newCriteria.PRH_Brand__c);
                            newCriteriaList.add(newCriteria);
                        } else {
                            PRH_Competitor_Brands__c newCriteria = new PRH_Competitor_Brands__c();
                            newCriteria.ownerID = newLuxAcc.ownerID;
    						newCriteria.PRH_Collect__c = collectID;						
                            newCriteria.PRH_Iconic_Brand__c = luxBrand.ID;                       
                            System.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT : Owner ' + newCriteria.ownerID + ' - PRH_Iconic_Brand__c ' + newCriteria.PRH_Iconic_Brand__c);
                            newCompetitorList.add(newCriteria);
                        }
                    }
                }
            }

			system.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT' + newCriteriaList.size() + ' Le Cercle Brands are going to be created');
            insert newCriteriaList;
			system.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT' + newCompetitorList.size() + ' Competitor Brands are going to be created');
            insert newCompetitorList;
            upsert shareList;
            
            list<PRH_Brand_Criteria__Share> criteriaShareList = new List<PRH_Brand_Criteria__Share>();
            for (PRH_Brand_Criteria__c bc : newCriteriaList) {
                System.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT : ' + bc.ID);
          		System.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_INSERT, accountOwner2map.get(bc.PRH_Collect__c) : ' + accountOwner2map.get(bc.PRH_Collect__c)); 
                if (accountOwner2map.get(bc.PRH_Collect__c) != null) {
                    PRH_Brand_Criteria__share newShare = new PRH_Brand_Criteria__share();
                    newShare.ParentId = bc.ID;
                    newShare.UserOrGroupId = accountOwner2map.get(bc.PRH_Collect__c);
                    newShare.AccessLevel = 'Edit';
                    criteriaShareList.add(newShare);
                }
            }
                  
            upsert criteriaShareList;
        }
        
        if (tAction == TriggerAction.AFTER_UPDATE) {
            system.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_UPDATE : ');
            system.debug('sObjList '+ sObjList );
            system.debug('newmap '+ newmap );
            system.debug('oldmap '+ oldmap );
            List<PRH_Luxury_Accounts__c> newLuxAccList = (List<PRH_Luxury_Accounts__c>)sObjList;
            list<PRH_Luxury_Accounts__Share> shareList = new List<PRH_Luxury_Accounts__Share>();
            
            ID collectID;
            
            List<PRH_Collect__c> listCollect= [SELECT id, PRH_Iconic_Account__c, PRH_Active__c
                                              FROM PRH_Collect__c 
                                              WHERE PRH_Active__c=true 
                                              and PRH_Iconic_Account__c in :newLuxAccList];
            
            List<PRH_Brand_Criteria__c> newCriteriaList = [Select id, PRH_Collect__c, PRH_Collect__r.PRH_Iconic_Account__c From PRH_Brand_Criteria__c where PRH_Collect__c in :listCollect];
            //List<PRH_Brand_Luxury_Brand__c> luxuryBrands = [Select ID, Name, PRH_Active__c, RecordType.DeveloperName from PRH_Brand_Luxury_Brand__c Order By PRH_Sequence__c];
            Map<ID,ID> accountOwner2Map = new Map<ID,ID>();
            Map<ID,ID> accountOwnerMap = new Map<ID,ID>();

            List<ID> oldOwner2 = new List<ID>();
            for (PRH_Luxury_Accounts__c newLuxAcc : newLuxAccList) {
                // Retrieve ID of active collect linked to iconic account
				for (PRH_Collect__c c : listCollect) {
					if (newLuxAcc.ID == c.PRH_Iconic_Account__c) {
						collectID = c.ID;
						break;
					}
				}
                
                PRH_Luxury_Accounts__share newShare = new PRH_Luxury_Accounts__share();     
                //system.debug('test newLuxAcc.id '+ newLuxAcc.id );
                //system.debug('test newLuxAcc.OwnerID '+ newLuxAcc.OwnerID );
                accountOwnerMap.put(collectID,newLuxAcc.OwnerID);
                if (newLuxAcc.PRH_Owner_2__c != null && newLuxAcc.ownerID != newLuxAcc.PRH_Owner_2__c) {
                    newShare.ParentId = newLuxAcc.id;
                    newShare.UserOrGroupId = newLuxAcc.PRH_Owner_2__c;
                    newShare.AccessLevel = 'Edit';
                    shareList.add(newShare);
                    accountOwner2Map.put(collectID,newLuxAcc.PRH_Owner_2__c);
                    if (oldMap.containsKey(newLuxAcc.ID)) {
                        PRH_Luxury_Accounts__c deleteItem = (PRH_Luxury_Accounts__c )oldMap.get(newLuxAcc.ID);
                        oldOwner2.add(deleteItem.PRH_Owner_2__c);
                    }
                }            
            }

            delete [Select id From PRH_Luxury_Accounts__share where ParentID IN :newLuxAccList AND RowCause = 'Manual'];
            upsert shareList;
            
            list<PRH_Brand_Criteria__Share> criteriaShareList = new List<PRH_Brand_Criteria__Share>();
            boolean check = false;
            List<id> oldOwner = new List<id>();
            for (PRH_Brand_Criteria__c bc : newCriteriaList) {
                system.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_UPDATE : bc.PRH_Collect__r.PRH_Iconic_Account__c '+ bc.PRH_Collect__r.PRH_Iconic_Account__c );        
                PRH_Luxury_Accounts__c oldA = (PRH_Luxury_Accounts__c)oldMap.get(bc.PRH_Collect__r.PRH_Iconic_Account__c);
                PRH_Luxury_Accounts__c newA = (PRH_Luxury_Accounts__c)newMap.get(bc.PRH_Collect__r.PRH_Iconic_Account__c);
                if (oldA.OwnerID != newA.OwnerID || oldA.PRH_Owner_2__c != newA.PRH_Owner_2__c) {
                    if (oldA.PRH_Owner_2__c != newA.PRH_Owner_2__c) {
                        oldOwner.add(oldA.PRH_Owner_2__c);
                    }
                    if (accountOwnermap.get(bc.PRH_Collect__c) != null) {
                        bc.OwnerID = accountOwnermap.get(bc.PRH_Collect__c);
                        check=true;
                    }
                    
                    //System.debug('Test trig2 : ' + bc);
              	  	//System.debug('Test trig2  : ' + bc.ID);
          			//System.debug('Test trig2  accountOwner2map.get(bc.PRH_Collect__c) : ' + accountOwner2map.get(bc.PRH_Collect__c));
                    if (accountOwner2map.get(bc.PRH_Collect__c) != null) {
                        System.debug('Test : ' + bc.ID);
                        PRH_Brand_Criteria__share newShare = new PRH_Brand_Criteria__share();
                        newShare.ParentId = bc.ID;
                        newShare.UserOrGroupId = accountOwner2map.get(bc.PRH_Collect__c);
                        newShare.AccessLevel = 'Edit';
                        criteriaShareList.add(newShare);
                    }
                }
            }
            System.debug('PRH_Share_Luxury_Account, executeTriggerAction AFTER_UPDATE, check=' + check + ', newCriteriaList=' + newCriteriaList);
            if (check && newCriteriaList.size()>0) {
                update newCriteriaList;
            }

            delete [Select id From PRH_Brand_Criteria__Share where ParentID IN :newCriteriaList and UserOrGroupId IN :oldOwner and RowCause = 'Manual'];
            upsert criteriaShareList;
        }
    }
}