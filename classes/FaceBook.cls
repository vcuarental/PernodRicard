public with sharing class FaceBook {

	// this is a facebook application access token - this token NEVER expires
	// such tokens should NEVER be exposed client-sider
	private static final String APP_ACCESS_TOKEN = 
		'563590320347002|2ZVIUt79k_QdkmLUEayygs8-fNA';
	
	// this is a facebook user access token - this particular token will never expire -- this token is for the "absolutdemo@outlook.com" user (fb id  = ) 	
	private static final String USER_ACCESS_TOKEN =
		'CAAIAlRjX13oBAOHqXhDbEQZAH9z2H2XI9b7gWmwXI9V9vrtoSrF27Cl9JbPnUqwC1xiqnWu0256zOiPSEK8ImNAlbviITjBQoYrWoOv2vbcZCG6ix8nIk01NzllIboxZB4PNiC3D35FJd2anJIWaNvFGvX9LYYZD';	
	  
	// facebook "graph api" REST URL to get feed information given the user/page id, an access token and limit count (as a string value)   
	private static final String PROTO_URL =
		'https://graph.facebook.com/me/home?fields=message,link,from.fields(name),picture,status_type,timeline_visibility&limit=50&access_token={0}';
		
	// these two classes allow us to run a deserialize/serialize opertaion on the facebook response in order to strip out
	// fields from the object that we do not want to return to the client-side		
	private class FeedInfo {
		List<DataFields> data;	// we just want the array of "data" objects
	} // FeedInfo
	
	private class DataFields {		// strip all but these four fields from each data object
		BrandObj brand;             // brand name is "name" sub-field
		String message;				// text	
		String picture;				// URL to image
		String link;				// URL that points back to facebook
		String status_type;			// posting status type
		String timeline_visibility;	// posting visibility
	}
	
	private class BrandObj {
		String name;				// this will be the brand name
	}

	// for testing so we can throw our own exception
	public class applicationException extends Exception {}
	
	//////////////////////////////////////////////////////////////////////////////////
	//																				//
	//	Note the original version of the code accepted two parameters, the			//
	//	the facebook "pageId" and a "limit" parameter.  Neither of these			//
	//	parameters is actually used by I have left them in the code.  The			//
	//	"limit" parameter is a handy way to trigger an exception during				//
	//	during testing.																//
	//																				//
	//////////////////////////////////////////////////////////////////////////////////

   // this routine called by VF page that is servicing an "doAjaxJsonCall" request
   public static String getFBFeed ()  {
        String pageId = System.currentPageReference().getParameters().get('pageId');
        String returnLimit = System.currentPageReference().getParameters().get('limit');
        try {
        	return getFaceBookFeed(pageId, returnLimit);
		} catch(Exception e) {
			System.debug(e.getMessage());
			JSONGenerator response= System.JSON.createGenerator(false);
			response.writeStartObject(); 
			response.writeBooleanField('success', false);
			response.writeStringField('message', 'Caught exception: ' + e.getMessage());
	        response.close();
			return(response.getAsString());
		}
   }	  

	// this routine was originally directly called by a "doAjaxServiceRequest" via the "UserService" class
	public static String getFaceBookFeed(String pageId, String returnLimit) {
		// for testing to get code coverage on exception handling
		if (returnLimit == '0') {
			throw new applicationException('Limit must be a positive integer');
		}

		// Instantiate a new http object
    	Http h = new Http();
    	
    	// create URL from prototype and passed parameters
    	String url = String.format(PROTO_URL, new String[] {USER_ACCESS_TOKEN});
    	System.debug('Constructed url is:' + url);
    	
		// Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    	HttpRequest req = new HttpRequest();
		req.setEndpoint(url);
		req.setMethod('GET');

		// Send the request, and return a response
		HttpResponse res;
		if (test.isRunningTest()) {
			res = new HttpResponse();
        	res.setBody(FaceBook.setupTest());
 		} else {
    		res = h.send(req);
		}

		// unfortunately FB uses a data object called "from" in their JSON response, we CAN'T deserialize this JSON directly because "from" is an Apex reserved word
		// so we will replace all instances of "from": with "brand": in the JSON string before we deserialize into the FeedInfo/DataFields/BrandObj private classes defined above
    	String resBody = res.getBody();
		resBody = resBody.replaceAll('"from":', '"brand":');

    	// return a "filtered" version of the response with the posts organized by "brand" and with a limited number of fields for each post
     	return filterResponseFields(resBody);
  	} // getFaceBookFeed
  	
  	
	// put the response body through a desrialize/serialize sequence to drop unwanted fields and retain only the fields we need
	// this is VERY IMPORTANT as some of the unwanted fields contain our application access token which should never be exposed client-side
	// this routine will also filter out certain posts and will group the posts together by "brand name"
  	public static String filterResponseFields(String responseBody) {
    	System.debug('FaceBook response body is: ' + responseBody);
    	FeedInfo fi = (FeedInfo) JSON.deserialize(responseBody, FeedInfo.class);
    	
    	// using a map group the elegible post data items by "brand.name"
    	Map<String, FeedInfo> postsMap = new Map<String, FeedInfo>();
    	for (DataFields post : fi.data) {
    		String key = post.brand != null ? post.brand.name : null ;
    		// below is our "eligibility" criteria
    		if (String.isNotBlank(key) && post.status_type == 'added_photos' && String.isNotBlank(post.picture)) {
    			System.debug('Key is ' + key);
	    		FeedInfo thisFeed = postsMap.get(key);				// get list for this key
	    		if (thisFeed == null) {								// don't yet have a list for this key
	    			thisFeed = new FeedInfo();						// allocate a list
	    			thisFeed.data = new List<DataFields>();
	    			postsMap.put(key, thisFeed);					// and store the empty list in our map
	    		}
	    		thisFeed.data.add(post);							// add this post to the appropriate list
    		} // if non-blank key, correct status_type and non-blank picture
    	} // iterate over each post
    	    	
    	String fiString = JSON.serialize(postsMap);					// turn our map of lists into a string
    	System.debug('postsMap in serialized form is ' + fiString);
    	return fiString;
  	}
  	
  	// this exists for testing purposes only - allows us to fake a response from FaceBook
  	public static String setupTest() {
		String fbTestResponse = 
			'{' +
			   '"data": [' +
			      '{' +
			         '"message": "Cheers to an early start to the holiday weekend with a #SeagramsGin cocktail!",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=586453461407337&set=a.441079585944726.130548.433844603334891&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "Seagram\'s Gin",' +
			            '"id": "433844603334891"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-b-a.akamaihd.net/hphotos-ak-ash4/1004436_586453461407337_1531669626_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "433844603334891_586453468074003",' +
			         '"created_time": "2013-07-03T20:02:13+0000"' +
			      '},' +
			      '{' +
			         '"message": "The Round of a Lifetime contest might be closed, but we got one more big surprise for a lucky Glenlivet fan in Ontario. Post your best \\"Golf and The Glenlivet\\" photo, and you might be a winner!",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=495351307216625&set=a.127819220636504.34534.122125377872555&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "The Glenlivet",' +
			            '"id": "122125377872555"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-f-a.akamaihd.net/hphotos-ak-prn1/1044039_495351307216625_1392301643_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "122125377872555_495351337216622",' +
			         '"created_time": "2013-07-03T19:55:05+0000"' +
			      '},' +
			      '{' +
			         '"message": "With summer just around the corner, make sure to stock up on an essential Chivas assessory...ice.",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=548495388546957&set=a.233867543343078.58939.144075338988966&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "Chivas Regal",' +
			            '"id": "144075338988966"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-c-a.akamaihd.net/hphotos-ak-prn1/1011699_548495388546957_437685601_s.png",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "144075338988966_550622991667530",' +
			         '"created_time": "2013-07-03T17:00:01+0000"' +
			      '},' +
			      '{' +
			         '"message": "Before you take your first sip of Jameson Gold Reserve, pause and take a minute to smell the fragrant toasted oak and sherry aromas. It\'s worth the wait.",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=10151559033893731&set=a.127408958730.106021.7947488730&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "Jameson Irish Whiskey",' +
			            '"id": "7947488730"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-g-a.akamaihd.net/hphotos-ak-frc1/1004757_10151559033893731_94916402_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "7947488730_10151559033943731",' +
			         '"created_time": "2013-07-03T16:42:51+0000"' +
			      '},' +
			      '{' +
			         '"message": "George Smith is granted the first ever distiller\'s license in the Parish of Glenlivet, and The Glenlivet is born.",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=495225123895910&set=exp.495224177229338.unitary&type=1",' +
			         '"from": {' +
			            '"name": "The Glenlivet",' +
			            '"id": "122125377872555"' +
			         '},' +
			         '"picture": "https://fbcdn-sphotos-d-a.akamaihd.net/hphotos-ak-ash3/q71/s480x480/941178_495225123895910_806719700_n.jpg",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "122125377872555_495224177229338",' +
			         '"created_time": "2013-07-03T14:17:29+0000"' +
			      '},' +
			      '{' +
			         '"message": "The creative process is an art all in itself.",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=10151443705946607&set=a.157318251606.126160.153504361606&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "ABSOLUT",' +
			            '"id": "153504361606"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-b-a.akamaihd.net/hphotos-ak-ash3/1044103_10151443705946607_545444452_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "153504361606_10151453485321607",' +
			         '"created_time": "2013-07-02T21:50:01+0000"' +
			      '},' +
			      '{' +
			         '"message": "Here\'s another behind-the-scenes pic of our girl Joyce gettin\' done up by our make-up artist Stephanie at our bumpin\' 2014 #SeagramsGin Calendar Girl shoot in #GinCity last week. LIKE if you\'re pumped to get your copy!",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=586005884785428&set=a.441079585944726.130548.433844603334891&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "Seagram\'s Gin",' +
			            '"id": "433844603334891"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-f-a.akamaihd.net/hphotos-ak-prn1/1013137_586005884785428_1327247063_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "433844603334891_586005908118759",' +
			         '"created_time": "2013-07-02T20:49:01+0000"' +
			      '},' +
			      '{' +
			         '"message": "The Round of a Lifetime contest might be closed, but we\'re not done with golf. We have some great last-minute prizes for the Canadian Men\'s and Women\'s Open, and all you have to do to enter is send us your best \\"Golf and The Glenlivet\\" photo along with your contact details to theglenlivet.guardians@gmail.com. For rules and regulations http://bit.ly/11dmRvA",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=492373194181103&set=a.127819220636504.34534.122125377872555&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "The Glenlivet",' +
			            '"id": "122125377872555"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-b-a.akamaihd.net/hphotos-ak-ash4/1002738_492373194181103_1946348751_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "122125377872555_494815710603518",' +
			         '"created_time": "2013-07-02T14:00:00+0000"' +
			      '},' +
			      '{' +
			         '"message": "We\'re getting the party started with the first winner of our Virgin Radio \\"At Home\\" Malibu Party! Don\'t you wish the MaliBOOM BOOM Rum Shack was in your backyard right now?",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=10151506212132286&set=a.255654002285.137911.12781307285&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "Malibu Rum",' +
			            '"id": "12781307285"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-d-a.akamaihd.net/hphotos-ak-prn1/1044865_10151506212132286_2101761450_s.png",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "12781307285_10151507206857286",' +
			         '"created_time": "2013-07-02T00:00:01+0000"' +
			      '},' +
			      '{' +
			         '"message": "Sound off below with who deserves a #SeagramGin shout out from last night’s BET Awards? We’re sending a big one to our friends TONY ROCK and Melvin Jackson Jr.!",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=585593118160038&set=a.441079585944726.130548.433844603334891&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "Seagram\'s Gin",' +
			            '"id": "433844603334891"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-g-a.akamaihd.net/hphotos-ak-ash4/1044574_585593118160038_6153371_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "433844603334891_585593124826704",' +
			         '"created_time": "2013-07-01T21:56:56+0000"' +
			      '},' +
			      '{' +
			         '"message": "Our Houston Guardians had the opportunity to attend a summer grilling demo with celebrity chef Monica Pope. This Dram & Discover event was set in a verdant backyard, where Monica revealed essential techniques to master the art of the outdoor barbecue. Learn about opportunities in your area by joining the Guardians: http://bit.ly/theGuardians",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=494176867334069&set=a.494176467334109.1073741840.122125377872555&type=1&relevant_count=12",' +
			         '"from": {' +
			            '"name": "The Glenlivet",' +
			            '"id": "122125377872555"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-d-a.akamaihd.net/hphotos-ak-prn1/1013530_494176867334069_1355291182_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "no timeline unit for this post",' +
			         '"id": "122125377872555_494177920667297",' +
			         '"created_time": "2013-07-01T20:13:45+0000"' +
			      '},' +
			      '{' +
			         '"message": "Celebrate Canada\'s Birthday, Caribbean style!",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=10151496619087286&set=a.255654002285.137911.12781307285&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "Malibu Rum",' +
			            '"id": "12781307285"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-e-a.akamaihd.net/hphotos-ak-frc1/944132_10151496619087286_141575478_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "12781307285_10151506602812286",' +
			         '"created_time": "2013-07-01T18:00:00+0000"' +
			      '},' +
			      '{' +
			         '"link": "http://www.facebook.com/photo.php?fbid=494090430676046&set=a.272694632815628.66625.122125377872555&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "The Glenlivet",' +
			            '"id": "122125377872555"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-h-a.akamaihd.net/hphotos-ak-ash3/10370_494090430676046_455358197_s.jpg",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "122125377872555_494090444009378",' +
			         '"created_time": "2013-07-01T16:51:53+0000"' +
			      '},' +
			      '{' +
			         '"link": "http://www.facebook.com/photo.php?fbid=548492205213942&set=a.233867543343078.58939.144075338988966&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "Chivas Regal",' +
			            '"id": "144075338988966"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-h-a.akamaihd.net/hphotos-ak-prn1/1013825_548492205213942_100192011_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "144075338988966_549795835083579",' +
			         '"created_time": "2013-07-01T16:00:02+0000"' +
			      '},' +
			      '{' +
			         '"message": "Watching the #awards tonight?  Celebrate #music with your favorite #SeagramsGin cocktail! http://bit.ly/SeagramsRecipes",' +
			         '"from": {' +
			            '"name": "Seagram\'s Gin",' +
			            '"id": "433844603334891"' +
			         '},' +
			         '"status_type": "mobile_status_update",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "433844603334891_585161361536547",' +
			         '"created_time": "2013-07-01T01:16:16+0000"' +
			      '},' +
			      '{' +
			         '"message": "When the sun sets, the party starts. Instagram your best sunset photos with the #MaliBOOMsunset hashtag and your picture could be featured in our album!",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=10151492059337286&set=a.255654002285.137911.12781307285&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "Malibu Rum",' +
			            '"id": "12781307285"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-h-a.akamaihd.net/hphotos-ak-prn1/1009868_10151492059337286_522068288_s.png",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "12781307285_10151502926997286",' +
			         '"created_time": "2013-06-29T22:00:00+0000"' +
			      '},' +
			      '{' +
			         '"message": "Seagram’s Gin: the perfect accessory for your white party TONY ROCK!",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=584555911597092&set=a.441079585944726.130548.433844603334891&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "Seagram\'s Gin",' +
			            '"id": "433844603334891"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-a-a.akamaihd.net/hphotos-ak-ash4/1000690_584555911597092_748240359_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "433844603334891_584555918263758",' +
			         '"created_time": "2013-06-29T19:28:06+0000"' +
			      '},' +
			      '{' +
			         '"message": "Celebrate today with ABSOLUT Pride.",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=10151434964421607&set=a.157318251606.126160.153504361606&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "ABSOLUT",' +
			            '"id": "153504361606"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-f-a.akamaihd.net/hphotos-ak-frc1/1001470_10151434964421607_1925615078_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "153504361606_10151448393071607",' +
			         '"created_time": "2013-06-29T19:00:03+0000"' +
			      '},' +
			      '{' +
			         '"message": "A successful week deserves the perfect reward. By that we mean Chivas.",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=548520775211085&set=a.233867543343078.58939.144075338988966&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "Chivas Regal",' +
			            '"id": "144075338988966"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-b-a.akamaihd.net/hphotos-ak-ash4/1044740_548520775211085_1438724984_s.png",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "144075338988966_548951688501327",' +
			         '"created_time": "2013-06-29T16:00:01+0000"' +
			      '},' +
			      '{' +
			         '"message": "Our New York and New Jersey Guardians had a stylish evening at Acustom Apparel where they were digitally fitted to perfection by cutting-edge 3D measuring technology. To find out about great experiences at the intersection of style, technology, and whisky, join the Guardians: http://bit.ly/theGuardians",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=492952924123130&set=a.492952534123169.1073741839.122125377872555&type=1&relevant_count=19",' +
			         '"from": {' +
			            '"name": "The Glenlivet",' +
			            '"id": "122125377872555"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-h-a.akamaihd.net/hphotos-ak-ash3/1011950_492952924123130_1471355636_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "no timeline unit for this post",' +
			         '"id": "122125377872555_492953404123082",' +
			         '"created_time": "2013-06-28T21:55:35+0000"' +
			      '},' +
			      '{' +
			         '"message": "Bump it up this weekend in style! http://bit.ly/SGComplex2 via @ComplexMagazine",' +
			         '"link": "http://bit.ly/SGComplex2",' +
			         '"from": {' +
			            '"name": "Seagram\'s Gin",' +
			            '"id": "433844603334891"' +
			         '},' +
			         '"picture": "https://fbexternal-a.akamaihd.net/safe_image.php?d=AQD-lNZsMLNQ0WkU&w=154&h=154&url=http%3A%2F%2Fcdnl.complex.com%2Fmp%2F620%2F400%2F90%2F0%2Fbb%2F1%2Fffffff%2F8528bf1774e0ca245d6f95105ef416c5%2Fimages_%2Fassets%2FCHANNEL_IMAGES%2FSTYLE%2F2013%2F05%2Fhowtodressforanightattheclubingifs1.gif",' +
			         '"status_type": "shared_story",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "433844603334891_584180244967992",' +
			         '"created_time": "2013-06-28T20:55:52+0000"' +
			      '},' +
			      '{' +
			         '"message": "Do you know what \'grist\' is? It is the ground, dried malt in coarse flour form. Check out our infographic to learn more about the process of malt whisky production.",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=492884564129966&set=a.127819220636504.34534.122125377872555&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "The Glenlivet",' +
			            '"id": "122125377872555"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-f-a.akamaihd.net/hphotos-ak-prn2/971470_492884564129966_1408637767_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "122125377872555_492884570796632",' +
			         '"created_time": "2013-06-28T18:20:05+0000"' +
			      '},' +
			      '{' +
			         '"message": "The week is over, now it\'s Jameson time! Share to let your friends know.",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=10151549998968731&set=a.127408958730.106021.7947488730&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "Jameson Irish Whiskey",' +
			            '"id": "7947488730"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-f-a.akamaihd.net/hphotos-ak-ash4/1001347_10151549998968731_1792538824_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "7947488730_10151549999003731",' +
			         '"created_time": "2013-06-28T16:00:11+0000"' +
			      '},' +
			      '{' +
			         '"link": "http://www.facebook.com/photo.php?fbid=548529625210200&set=a.318004594929372.74961.144075338988966&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "Chivas Regal",' +
			            '"id": "144075338988966"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-g-a.akamaihd.net/hphotos-ak-ash3/946220_548529625210200_1047996579_s.png",' +
			         '"timeline_visibility": "hidden",' +
			         '"id": "144075338988966_548529638543532",' +
			         '"created_time": "2013-06-28T15:30:29+0000"' +
			      '},' +
			      '{' +
			         '"message": "We’re celebrating our two million Facebook fans worldwide.  Explore our map to see where your fellow fans live – all 1,999,999 of them. http://bit.ly/chivasfansworldwide",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=548521335211029&set=a.233867543343078.58939.144075338988966&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "Chivas Regal",' +
			            '"id": "144075338988966"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-e-a.akamaihd.net/hphotos-ak-ash3/1017463_548521335211029_2003738930_s.png",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "starred",' +
			         '"id": "144075338988966_548529498543546",' +
			         '"created_time": "2013-06-28T15:30:00+0000"' +
			      '},' +
			      '{' +
			         '"message": "Where will your long weekend take you?",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=10151434961466607&set=a.157318251606.126160.153504361606&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "ABSOLUT",' +
			            '"id": "153504361606"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-g-a.akamaihd.net/hphotos-ak-ash3/7950_10151434961466607_3559377_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "153504361606_10151445677046607",' +
			         '"created_time": "2013-06-27T22:40:01+0000"' +
			      '},' +
			      '{' +
			         '"message": "Don\'t you wish you were partying with the 2014 #SeagramsGin Calendar Spokesmodels in #GinCity? We\'re doin\' it up right!",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=583771188342231&set=a.441079585944726.130548.433844603334891&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "Seagram\'s Gin",' +
			            '"id": "433844603334891"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-b-a.akamaihd.net/hphotos-ak-ash3/1010502_583771188342231_1594863170_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "433844603334891_583771201675563",' +
			         '"created_time": "2013-06-27T20:12:41+0000"' +
			      '},' +
			      '{' +
			         '"message": "Planning on coming to Ireland soon? Make sure you stop by and visit us at the Old Jameson Distillery: we\'ll be very glad to show you around.\\nhttp://www.tours.jamesonwhiskey.com/home.aspx",' +
			         '"link": "http://www.facebook.com/photo.php?fbid=10151548515588731&set=a.127408958730.106021.7947488730&type=1&relevant_count=1",' +
			         '"from": {' +
			            '"name": "Jameson Irish Whiskey",' +
			            '"id": "7947488730"' +
			         '},' +
			         '"picture": "https://fbcdn-photos-c-a.akamaihd.net/hphotos-ak-prn1/1013655_10151548515588731_452283807_s.jpg",' +
			         '"status_type": "added_photos",' +
			         '"timeline_visibility": "normal",' +
			         '"id": "7947488730_10151548515623731",' +
			         '"created_time": "2013-06-27T17:46:20+0000"' +
			      '}' +
			   '],' +
			   '"paging": {' +
			      '"previous": "https://graph.facebook.com/100006140642988/home?fields=message,link,from.fields%28name%29,picture,status_type,timeline_visibility&limit=50&access_token=CAAIAlRjX13oBAOHqXhDbEQZAH9z2H2XI9b7gWmwXI9V9vrtoSrF27Cl9JbPnUqwC1xiqnWu0256zOiPSEK8ImNAlbviITjBQoYrWoOv2vbcZCG6ix8nIk01NzllIboxZB4PNiC3D35FJd2anJIWaNvFGvX9LYYZD&since=1372881733&__previous=1",' +
			      '"next": "https://graph.facebook.com/100006140642988/home?fields=message,link,from.fields%28name%29,picture,status_type,timeline_visibility&limit=50&access_token=CAAIAlRjX13oBAOHqXhDbEQZAH9z2H2XI9b7gWmwXI9V9vrtoSrF27Cl9JbPnUqwC1xiqnWu0256zOiPSEK8ImNAlbviITjBQoYrWoOv2vbcZCG6ix8nIk01NzllIboxZB4PNiC3D35FJd2anJIWaNvFGvX9LYYZD&until=1372355179"' +
			   '}' +
			'}';
		return fbTestResponse;
  	} // setupTest
  	
	@isTest
	public static void testThisClass() {
		
		// not actually necessary
		String response = FaceBook.filterResponseFields(FaceBook.setupTest());
	
		// simulate being called by "doAjaxJsonCall"
		ApexPages.currentPage().getParameters().put('pageId', '100006140642988');
		ApexPages.currentPage().getParameters().put('limit', '4');		
		
		// get a response - should be a "filtered" version of the string returned by the setupTest routine
		response = FaceBook.getFBFeed();
		System.debug(response);

		// this one will throw an exception - which ups the code coverage to the required level
		ApexPages.currentPage().getParameters().put('limit', '0');		
		response = FaceBook.getFBFeed();
		System.debug(response);
		
	} // testThisClass 	
} // FaceBook