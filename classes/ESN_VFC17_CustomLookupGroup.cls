/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | CollaborationGroup		                                                         |
|     - Description     | A custom lookup for search a CollaborationGroup then add it in a input field.		 |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 15/05/2013                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
public class ESN_VFC17_CustomLookupGroup {

    /*############################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##############################################################################*/
    public String errorMsg { get; set; }
    
    public String queryName {get; set;}
    public String byType {get; set;}
    
    public List<CollaborationGroup> results {get; set;}
    public CollaborationGroup currGroup;
    public CollaborationGroup getCurrGroup()    { return currGroup;}
    
    public Boolean display = false;
    public Boolean getDisplay() { return display ; }
  
    /*############################################################################
    #   C.O.N.S.T.R.U.C.T.O.R
    ##############################################################################*/
    public ESN_VFC17_CustomLookupGroup() {
        currGroup = new CollaborationGroup();
    }
    
    /*############################################################################
    #   M.E.T.H.O.D.S
    ##############################################################################*/  
    
    /*
     * Button : Run the query belong to the search parameters : 
     * if null, return all collaborationGroup (limit 20), 
     * if not null, return groups with a name containing the string queried. 
     ***/ 
    public PageReference runQuery() {          
        results = new List<CollaborationGroup>(); 
        CollaborationGroup[] searchResults = new List<CollaborationGroup>() ;
        
        if(queryName == ''){
            searchResults = [SELECT Id,Name,CollaborationType,Description FROM CollaborationGroup LIMIT 20];
        }else{
            queryName =  '%' +queryName+ '%';            
            searchResults = [SELECT Id,Name,CollaborationType,Description FROM CollaborationGroup WHERE Name LIKE :queryName];
        }
        
        if(searchResults.size() == 20)
            errorMsg = 'Your query returns too much results. Only the first 20 are displayed. Please retry with more filters.';
        else if(searchResults.size() == 0)
            errorMsg = 'Your query returns no results. Please retry with another filters.';
        else
            errorMsg = '';
        results.addAll(searchResults);
        display = true; // display the results list.
        return null;
    }
}