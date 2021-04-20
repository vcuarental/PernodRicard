/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       |                                                                                        |
|     - Description     | Allows user to post a message associated to a location                             |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 23/07/2013                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
public class ESN_VFC24_CheckInChatterPost {

    /*############################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##############################################################################*/
    public String inputLocUrl { get; set; }
    public String inputLocLng { get; set; }
    public String inputLocLat { get; set; }
    public String inputLocName { get; set; }
    public String inputPostMsg { get; set; }
    public String inputLocation { get; set; }
    public String inputGroup { get; set; }
    public User currUser {get;set;}
    public String errMsg { get; set; }
        
    /*############################################################################
    #   C.O.N.S.T.R.U.C.T.O.R
    ##############################################################################*/
    public ESN_VFC24_CheckInChatterPost() {
        currUser  = [SELECT FirstName, LastName, Name, Id FROM User WHERE Id = :UserInfo.getUserId()];
        inputLocation = '';
        inputPostMsg = '';
    }
    
    /*############################################################################
    #   M.E.T.H.O.D.S
    ##############################################################################*/
    /*
     * Create a check-in record and post on User's profile the message with link to the check-in.
     ***/ 
    public void sharePostLocation() {            
        try{
            errMsg = '';
            if(inputPostMsg != ''){ 
                if(inputLocation != ''){
                    // Create a check-In //
                    ESN_CheckIn__c checkIn = new ESN_CheckIn__c(
                        ESN_Address__c = inputLocation ,
                        ESN_Date__c = Datetime.now(),
                        ESN_Geolocation__Latitude__s = Decimal.valueOf(inputLocLat),
                        ESN_Geolocation__Longitude__s = Decimal.valueOf(inputLocLng),
                        ESN_LocationName__c = inputLocName,
                        ESN_User__c = currUser.Id
                    );
                    insert checkIn;
                    
                    // Create a feeditem
                    FeedItem postCheckIn = new FeedItem( 
                        Title = currUser.FirstName + ' ' + currUser.LastName + ' is in ' + inputLocName,
                        Body = inputPostMsg, 
                        type = 'LinkPost',
                        LinkUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + checkIn.Id,
                        CreatedById = currUser.Id
                    );
                    
                    if(inputGroup == null || inputGroup == 'null' || inputGroup == '') {
                        // Post a message on the QR User profile //
                        postCheckIn.ParentId = currUser.Id;
                    }else{
                        // Post a message on the current Chatter group //
                        postCheckIn.ParentId = inputGroup;
                    }
                    insert postCheckIn;
                } else {
                    // Post a message on the QR User profile //
                    FeedItem postCheckIn = new FeedItem(
                        ParentId = currUser.Id, 
                        Body = inputPostMsg, 
                        type = 'TextPost',
                        CreatedById = currUser.Id
                    );
                    insert postCheckIn;
                }
            } else {
                errMsg = 'Your post is empty. Please try again.';
            }
        }catch (Exception e){
            errMsg = 'An error occurred. Your administrator has been notified.';
            Utils_UsefulMethods.notifyAdminException(Utils_UsefulMethods.adminEmailOfPRCustomSetting(), 'ESN_VFC24_CheckInChatterPost', 'Insert a Check-in by user '+currUser.Name+'[Id : '+currUser.Id+']', e);
        }
    }
}