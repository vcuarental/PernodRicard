trigger ASI_eForm_CN_IT_Change_Request_BeforeUpsert on ASI_eForm_IT_Change_Request__c (before insert,before update) {

    List<User> cnUserL=[select id,managerid,Department from user where companyname='Pernod Ricard China' and isactive=true];
    MAp<id,User> userMap=new MAp<id,User>();    
    for(User u : cnUserL){
        userMap.put(u.id,u);
    }
    
    List<ASI_eForm_Route_Type__c> routeTypes = [SELECT ID, Name, ASI_eForm_Form_Type__c, 
                                                    (SELECT ASI_eForm_Approver__c, ASI_eForm_Note__c 
                                                    FROM ASI_eForm_Route_Rule_Details__r)
                                                FROM ASI_eForm_Route_Type__c
                                                WHERE Name in ('ITC-PRCN-IT', 'PRCN')
                                                AND ASI_eForm_Form_Type__c = 'IT Change Request'];
                                                
    Map<String, ASI_eForm_Route_Type__c> routeTypesMap = new Map<String, ASI_eForm_Route_Type__c>();
    for (ASI_eForm_Route_Type__c routeType : routeTypes){
        routeTypesMap.put(routeType.name, routeType);
    }
    
    for (ASI_eForm_IT_Change_Request__c itChangeRequest : trigger.new){
        if (Global_RecordTypeCache.getRt(itChangeRequest.recordTypeid).developerName.equals('ASI_eForm_CN_IT_Change_Request') ||
                Global_RecordTypeCache.getRt(itChangeRequest.recordTypeid).developerName.equals('ASI_eForm_CN_IT_Change_Request_Submitted') ){
            
            if(itChangeRequest.ASI_eForm_CN_Change_Authorizer__c==null){
                if(userMap.get(itChangeRequest.ownerid)!=null)
                    itChangeRequest.ASI_eForm_CN_Change_Authorizer__c=userMap.get(itChangeRequest.ownerid).managerid;
            }
            
            ASI_eForm_Route_Type__c route=routeTypesMap.get('ITC-PRCN-IT');
            /*if(userMap.get(itChangeRequest.ownerid).Department.equals('IT')){
                route=routeTypesMap.get('ITC-PRCN-IT');    
            }else
                route=routeTypesMap.get('PRCN');*/
            
            if(itChangeRequest.ASI_eForm_High_Level_Authorizer__c==null &&(itChangeRequest.ASI_eForm_Change_Category__c=='Medium'||itChangeRequest.ASI_eForm_Change_Category__c=='High') ){                    
                List<ASI_eForm_Route_Rule_Details__c> rd=route.ASI_eForm_Route_Rule_Details__r;
                for(ASI_eForm_Route_Rule_Details__c d:rd){
                    if(d.ASI_eForm_Note__c.equals('High-Level Authorizer')){
                        itChangeRequest.ASI_eForm_High_Level_Authorizer__c=d.ASI_eForm_Approver__c;
                        break;
                    }
                }
            }
            
            if(itChangeRequest.ASI_eForm_Further_Authorizer__c==null && itChangeRequest.ASI_eForm_Change_Category__c=='High'){                    
                List<ASI_eForm_Route_Rule_Details__c> rd=route.ASI_eForm_Route_Rule_Details__r;
                for(ASI_eForm_Route_Rule_Details__c d:rd){
                    if(d.ASI_eForm_Note__c.equals('Further Authorizer')){
                        itChangeRequest.ASI_eForm_High_Level_Authorizer__c=d.ASI_eForm_Approver__c;
                        break;
                    }
                }
            }
            
            if(itChangeRequest.ASI_eForm_CIO_Approver__c==null){                    
                
            }
            
        }//cn            
    }//for
}