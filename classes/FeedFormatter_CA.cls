public class FeedFormatter_CA{
	public static String formatBodyText(ConnectApi.FeedBody body) {
        String formattedText = '';
        
        for (ConnectApi.MessageSegment seg : body.messageSegments) {
            if (seg instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mention = (ConnectApi.MentionSegment)seg;
                formattedText += ' <a href=\"/'+mention.user.id+'\" style=\"color:#015ba7;text-decoration:none;\" onmouseover=\"this.style.textDecoration = \'underline\'\" onmouseout=\"this.style.textDecoration = \'none\'\">@' + mention.user.name + '</a> ';
            } else if (seg instanceof ConnectApi.HashtagSegment) {
                ConnectApi.HashtagSegment hashtag = (ConnectApi.HashtagSegment)seg;
                formattedText += ' <a href=\"/_ui/core/chatter/topics/TopicPage?name='+hashtag.tag+'&ref=hash_mention\" style=\"color:#015ba7;text-decoration:none;\" onmouseover=\"this.style.textDecoration = \'underline\'\" onmouseout=\"this.style.textDecoration = \'none\'\">#' + hashtag.tag + '</a> ';
            } else if (seg instanceof ConnectApi.LinkSegment) {
                ConnectApi.LinkSegment link = (ConnectApi.LinkSegment)seg;
                formattedText += ' <a href=\"' + link.url + '\">' + link.url + '</a> ';
            } else {
                // Default.
                formattedText += seg.text;
            }
        }
        return formattedText;
    }
}