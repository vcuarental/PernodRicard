// Le Cercle application - evolution LCS-84 - April 2017
public class PRH_Iconic_Account_Deletion_End implements Database.Batchable<sObject> {

    final String Query;
    
    public PRH_Iconic_Account_Deletion_End() {  
    	List<PermissionSet> listPs = [select id, name
                                      from PermissionSet
                                      where name = 'PRH_Iconic_Platform_Support_LeCercle'];

        System.debug('=> PRH_Iconic_Account_Deletion_End : UserInfo.getUserId() = ' + UserInfo.getUserId());

        if (listPs.size() > 0) {
        	Query = 'SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =\'' + UserInfo.getUserId() + '\' AND PermissionSetId=\'' + listPS[0].Id + '\'';
        } else {
        	Query = '';
        }
        System.debug('=> PRH_Iconic_Account_Deletion_End(), Query = [' + Query + ']');
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(Query);
    }

    public void execute(Database.BatchableContext BC, List<PermissionSetAssignment> psaList) {
        if (psaList.size() > 0) {
            System.debug('PRH_Iconic_Brand_Deletion_End, execute() psaList=' + psaList);
            System.debug('PRH_Iconic_Brand_Deletion_End, execute() PermissionSetAssignment is going to be deleted');       
            delete psaList;        
        }
    }

    public void finish(Database.BatchableContext BC) { 
    }
}