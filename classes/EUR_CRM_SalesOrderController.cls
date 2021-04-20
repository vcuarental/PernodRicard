/**
    *  Class for assisting when generating emails for
    *  sales orders
	*
    *  @author:  PZ - Customertimes Corp.
    *  @created: 21.08.18
    *  @version: 1.0
 */
public class EUR_CRM_SalesOrderController {
    /* Property to store necessary document name
     * 
     */
    public String fileName { 
        get; 
        set; 
    }
    /* Method to generate a url for
     * externally available document
     * Used for displaying logo in the email
     * 
     * @return String - logo URL
	 */
	public String getDocumentRelativeLink(){
        String documentURL = null;
            List<Document> doc = [SELECT id, Body FROM Document WHERE DeveloperName  = :fileName LIMIT 1];
            if(!doc.isEmpty()) {
                documentURL = URL.getSalesforceBaseUrl().getProtocol() + '://' + System.URL.getSalesforceBaseUrl().getHost() + '/servlet/servlet.ImageServer?id=' + doc[0].id + '&oid=' + Userinfo.getOrganizationId();
                    
            }
        return documentURL ;
    }
}