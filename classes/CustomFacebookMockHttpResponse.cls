@isTest
global class CustomFacebookMockHttpResponse implements HttpCalloutMock {
  
  private static Integer step = 0;
  
  public static void setStep(Integer s) {
    step = s;
  } 
  
  public static HTTPResponse getMockResponse(HTTPRequest request) {
    // Optionally, only send a mock response for a specific endpoint
        // and method.
        // Create a fake response
        HttpResponse res = new HttpResponse();
        if (request.getMethod().equals('POST')) {
          res.setBody('{\"access_token\":\"token\",\"token_type\":\"bearer\"}');
        } else if (request.getMethod().equals('GET')) {
          if (step == 0) {
            res.setBody('[' +
			'{' +
				'"id":"684F8BC5-3846-4C58-9779-C37FFF852A0C",' +
				'"fromname":"Sylpheo",' +
				'"message":"test",' +
				'"type":"photo",' +
				'"createdtime":"2014-08-08T10:50:06.000Z",' +
				'"frompicturesmall":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/p50x50/521637",' +
				'"frompicturelarge":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/521637",' +
				'"commentcount":2,' +
				'"sharecount":17,' +
				'"likecount":106,' +
				'"actioncomment":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"actionlike":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"networksourceid":"216BAF1B-EAB8-474A-B160-D3738B7A7FBD",' +
				'"networksourcename":"sylpheo",' +
				'"actionshare":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"mediasmall":"https://scontent-b.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/p320x320/1743448_707419592676461_7228794030569722436_n.png?oh=a6e90ef94afb756c1e27b584214d63aa&oe=54600F2E",' +
				'"medialarge":"https://scontent-b.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/p480x480/1743448_707419592676461_7228794030569722436_n.png?oh=9c3f44b9267f1839ab607eddb48b5c1d&oe=54719F72",' +
				'"actionview":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"externalid":"122125377872555_707419599343127"' +
			'}' +
  		    ']');
          } else if (step == 1) {
              res.setBody('[' +
			'{' +
				'"id":"684F8BC5-3846-4C58-9779-C37FFF852A0C",' +
				'"fromname":"Sylpheo",' +
				'"message":"test",' +
				'"type":"photo",' +
				'"createdtime":"2014-08-08T10:50:06.000Z",' +
				'"frompicturesmall":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/p50x50/521637",' +
				'"frompicturelarge":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/521637",' +
				'"commentcount":2,' +
				'"sharecount":17,' +
				'"likecount":106,' +
				'"actioncomment":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"actionlike":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"networksourceid":"216BAF1B-EAB8-474A-B160-D3738B7A7FBD",' +
				'"networksourcename":"sylpheo",' +
				'"actionshare":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"mediasmall":"https://scontent-b.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/p320x320/1743448_707419592676461_7228794030569722436_n.png?oh=a6e90ef94afb756c1e27b584214d63aa&oe=54600F2E",' +
				'"medialarge":"https://scontent-b.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/p480x480/1743448_707419592676461_7228794030569722436_n.png?oh=9c3f44b9267f1839ab607eddb48b5c1d&oe=54719F72",' +
				'"actionview":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"externalid":"122125377872555_707419599343127"' +
			'},' +
             '{' +
				'"id":"684F8BC5-3846-4C58-9779-C37FFF852A0D",' +
				'"fromname":"Sylpheo",' +
				'"message":"deuxième test",' +
				'"type":"photo",' +
				'"createdtime":"2014-08-08T10:50:06.000Z",' +
				'"frompicturesmall":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/p50x50/521637",' +
				'"frompicturelarge":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/521637",' +
				'"commentcount":2,' +
				'"sharecount":17,' +
				'"likecount":106,' +
				'"actioncomment":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"actionlike":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"networksourceid":"216BAF1B-EAB8-474A-B160-D3738B7A7FBD",' +
				'"networksourcename":"sylpheo",' +
				'"actionshare":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"mediasmall":"https://scontent-b.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/p320x320/1743448_707419592676461_7228794030569722436_n.png?oh=a6e90ef94afb756c1e27b584214d63aa&oe=54600F2E",' +
				'"medialarge":"https://scontent-b.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/p480x480/1743448_707419592676461_7228794030569722436_n.png?oh=9c3f44b9267f1839ab607eddb48b5c1d&oe=54719F72",' +
				'"actionview":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"externalid":"122125377872555_707419599343128"' +
			'}' +
  		    ']');
          } else if (step == 2) {
              res.setBody('[' +
			'{' +
				'"id":"684F8BC5-3846-4C58-9779-C37FFF852A0C",' +
				'"fromname":"Sylpheo",' +
				'"message":"test",' +
				'"type":"photo",' +
				'"createdtime":"2014-08-08T10:50:06.000Z",' +
				'"frompicturesmall":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/p50x50/521637",' +
				'"frompicturelarge":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/521637",' +
				'"commentcount":2,' +
				'"sharecount":17,' +
				'"likecount":106,' +
				'"actioncomment":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"actionlike":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"networksourceid":"216BAF1B-EAB8-474A-B160-D3738B7A7FBD",' +
				'"networksourcename":"sylpheo",' +
				'"actionshare":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"mediasmall":"https://scontent-b.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/p320x320/1743448_707419592676461_7228794030569722436_n.png?oh=a6e90ef94afb756c1e27b584214d63aa&oe=54600F2E",' +
				'"medialarge":"https://scontent-b.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/p480x480/1743448_707419592676461_7228794030569722436_n.png?oh=9c3f44b9267f1839ab607eddb48b5c1d&oe=54719F72",' +
				'"actionview":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"externalid":"122125377872555_707419599343127"' +
			'},' +
             '{' +
				'"id":"684F8BC5-3846-4C58-9779-C37FFF852A0D",' +
				'"fromname":"Sylpheo",' +
				'"message":"deuxième test",' +
				'"type":"photo",' +
				'"createdtime":"2014-08-08T10:52:06.000Z",' +
				'"frompicturesmall":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/p50x50/521637",' +
				'"frompicturelarge":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/521637",' +
				'"commentcount":2,' +
				'"sharecount":17,' +
				'"likecount":106,' +
				'"actioncomment":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"actionlike":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"networksourceid":"216BAF1B-EAB8-474A-B160-D3738B7A7FBD",' +
				'"networksourcename":"sylpheo",' +
				'"actionshare":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"mediasmall":"https://scontent-b.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/p320x320/1743448_707419592676461_7228794030569722436_n.png?oh=a6e90ef94afb756c1e27b584214d63aa&oe=54600F2E",' +
				'"medialarge":"https://scontent-b.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/p480x480/1743448_707419592676461_7228794030569722436_n.png?oh=9c3f44b9267f1839ab607eddb48b5c1d&oe=54719F72",' +
				'"actionview":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"externalid":"122125377872555_707419599343128"' +
			'},' +
             '{' +
				'"id":"684F8BC5-3846-4C58-9779-C37FFF852A0E",' +
				'"fromname":"Sylpheo",' +
				'"message":"troisième test",' +
				'"type":"photo",' +
				'"createdtime":"2014-08-08T10:55:06.000Z",' +
				'"frompicturesmall":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/p50x50/521637",' +
				'"frompicturelarge":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/521637",' +
				'"commentcount":2,' +
				'"sharecount":17,' +
				'"likecount":106,' +
				'"actioncomment":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"actionlike":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"networksourceid":"216BAF1B-EAB8-474A-B160-D3738B7A7FBD",' +
				'"networksourcename":"sylpheo",' +
				'"actionshare":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"mediasmall":"https://scontent-b.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/p320x320/1743448_707419592676461_7228794030569722436_n.png?oh=a6e90ef94afb756c1e27b584214d63aa&oe=54600F2E",' +
				'"medialarge":"https://scontent-b.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/p480x480/1743448_707419592676461_7228794030569722436_n.png?oh=9c3f44b9267f1839ab607eddb48b5c1d&oe=54719F72",' +
				'"actionview":"https://www.facebook.com/122125377872555/posts/707419599343127",' +
				'"externalid":"122125377872555_707419599343129"' +
			'}' +
  		    ']');
          }
        }
        res.setStatusCode(200);
        return res;
  }
  
    global HTTPResponse respond(HTTPRequest request) {
        return CustomFacebookMockHttpResponse.getMockResponse(request);
    }
}