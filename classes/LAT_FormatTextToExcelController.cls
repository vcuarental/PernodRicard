public with sharing class LAT_FormatTextToExcelController {
	public string text {get;set;}
	public string textConverted {
		get{return text!=null ? text.replaceAll('<br>','\n').escapeHtml4().replaceAll('\n', '<br/>') : null;}
		set;
	}
}